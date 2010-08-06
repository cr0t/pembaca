require 'net/ssh'
require 'net/scp'

class ConvertJob
  @queue = :convert
  
  def self.perform(upload_id, filename)
  	@upload_id = upload_id
  	@filename  = filename
  	
  	@db = Mongo::Connection.new("192.168.1.35").db('liberty_development')
  	
    puts "You're trying to convert '#{filename}' file"
    
    setup_environment
    
    get_the_source_file
    
    Slicer.run(@upload_id)
    
    @static_dir = "/var/www/nginx-default/" + @upload_id
    @static_host = '192.168.1.100'
  	@static_user = 'cr0t'
  	@static_pass = 'fuck0ff'
  	
  	prepare_upload_dir
  	
  	@pages_count = 0
    
    Dir.new(".").each do |filename|
    	if filename.match(/.pdf$/)
    		out_file = Converter.run(filename)
    		upload_converted_file(out_file)
    		@pages_count += 1
    		
    		@db.collection('uploads').update({ "_id" => BSON::ObjectID(@upload_id) }, { "$set" => { "already_converted" => @pages_count } })
    		
    		File.delete(out_file)
    		File.delete(filename)
    	end
    end
    
    set_converted_data
    
    clean_environment
  end
  
  class << self
  	protected
  	
  	def setup_environment
  		`mkdir #{@upload_id}`
  		Dir.chdir(@upload_id)
  	end
  	
  	def clean_environment
  		Dir.chdir("..")
  		`rm -rf #{@upload_id}` # all sliced pages of the source file
  	end
  	
  	# moves uploaded binary file from mongo db to the local fs
  	def get_the_source_file
  		mongo_filename = @upload_id + "/" + @filename
  		
    	gridfs_file = Mongo::GridFileSystem.new(@db).open(mongo_filename, 'r')
    
    	File.open(@upload_id, 'w') { |f| f.write(gridfs_file.read) }
  	end
  	
  	# sets the converted flag to true and add some fields
  	def set_converted_data
  		doc_data = ""
  		File.open("doc_data.txt", "r") do |file|
  			file.each_line do |line|
  				doc_data += line
  			end
  		end
  		
  		@db.collection('uploads').update({ "_id" => BSON::ObjectID(@upload_id) }, {
  			"$set" => {
  				"converted" => true,
  				"static_host" => @static_host,
  				"total_pages" => @pages_count,
  				"doc_data" => doc_data
  			}
  		})
  	end
  	
  	def prepare_upload_dir
  		Net::SSH.start(@static_host, @static_user, :password => @static_pass) do |ssh|
  			ssh.exec! "mkdir #{@static_dir}"
  		end
  	end
  	
  	# sends files to the remote ("static") host
  	def upload_converted_file(local_filename)
  		Net::SCP.start(@static_host, @static_user, :password => @static_pass) do |scp|
  			scp.upload! local_filename, @static_dir + "/" + local_filename
  		end
  	end
  end
end

class Slicer
	def self.run(filename)
		pdftk_cmd = `which pdftk`.strip
		
		cmd = "#{pdftk_cmd} #{filename} burst output \"#{filename}-page-%06d.pdf\""
		
		`#{cmd}`
	end
end

class Converter
	def self.run(filename, density = 100)
		convert_cmd = `which convert`.strip
		
		output_filename = filename.gsub(".pdf", "").gsub("-page", "") + ".png"
		
		cmd = "#{convert_cmd} -density #{density} \"#{filename}\" \"#{output_filename}\""
		
		puts "Processing '#{filename}'..."
		
		`#{cmd}`
		
		output_filename
	end
end