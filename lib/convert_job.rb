require 'net/ssh'
require 'net/scp'

class ConvertJob
  @queue = :convert
  
  class << self
    def perform(upload_id, filename, density = 150)
      mongoid_conf = YAML::load_file(Rails.root.join('config/mongoid.yml'))[Rails.env]
      
    	@upload_id = upload_id
    	@filename  = filename
    	@db = Mongo::Connection.new(mongoid_conf['host']).db(mongoid_conf['database'])

      setup_environment
      
      begin
        get_the_source_file

        Slicer.run(@upload_id)
        
        upload_conf = YAML::load_file(Rails.root.join('config/static_servers.yml'))[Rails.env]

        @static_dir  = upload_conf["servers"][0]["directory"] + @upload_id
        @static_host = upload_conf["servers"][0]["hostname"]
      	@static_user = upload_conf["servers"][0]["username"]
      	@static_pass = upload_conf["servers"][0]["password"]

      	prepare_upload_dir
      	
      	total_pages_to_convert = `ls *-page-*.pdf | wc -l`.strip.to_i
      	
      	@db.collection('uploads').update({ "_id" => BSON::ObjectID(@upload_id) }, {
    			"$set" => { "total_pages" => total_pages_to_convert }
    		})

      	converted_count = 0

        Dir.new(".").each do |filename|
        	if filename.match(/.pdf$/)
        		out_file = Converter.run(filename, density)
        		#upload_converted_file(out_file)
        		
        		converted_count += 1
        		
        		@db.collection('uploads').update({ "_id" => BSON::ObjectID(@upload_id) }, {
        		  "$set" => { "already_converted" => converted_count }
        		})
        		
        		#File.delete(out_file)
        		File.delete(filename)
        	end
        end
        
        # remove the source file
        File.delete(@upload_id)
        
        tar_filename = @upload_id + ".tar"
        
        `tar cf #{tar_filename} *`
        
        upload_and_unpack_converted_file(tar_filename)
        
        set_converted_data
      rescue
        # TODO: log this somewhere?
        #puts "There are was some errors during converting this file"
        raise
      ensure
        clean_environment
      end
    end
    
    
  	protected
  	
  	def setup_environment
  		`mkdir /tmp/#{@upload_id}`
  		Dir.chdir("/tmp/" + @upload_id)
  	end
  	
  	def clean_environment
  		#Dir.chdir("..")
  		`rm -rf /tmp/#{@upload_id}` # all sliced pages of the source file
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
  				"converted"   => true,
  				"static_host" => @static_host,
  				"doc_data"    => doc_data
  			}
  		})
  	end
  	
  	def prepare_upload_dir
  		Net::SSH.start(@static_host, @static_user, :password => @static_pass) do |ssh|
  			ssh.exec! "mkdir #{@static_dir}"
  		end
  	end
  	
  	# sends file to the remote ("static") host and unpack it there
  	def upload_and_unpack_converted_file(local_filename)
  		Net::SCP.start(@static_host, @static_user, :password => @static_pass) do |scp|
  			scp.upload! local_filename, @static_dir + "/" + local_filename
  		end
  		
  		Net::SSH.start(@static_host, @static_user, :password => @static_pass) do |ssh|
  			ssh.exec! "cd #{@static_dir}"
  			ssh.exec! "tar xf #{local_filename}"
  			ssh.exec! "rm -f #{local_filename}"
  		end
  	end
  end
end

class Slicer
	def self.run(filename)
		pdftk_cmd = `which pdftk`.strip
		
		`#{pdftk_cmd} #{filename} burst output \"#{filename}-page-%06d.pdf\"`
	end
end

class Converter
	def self.run(filename, density = 100)
		convert_cmd = `which convert`.strip
		
		output_filename = filename.gsub(".pdf", "").gsub("-page", "") + ".png"
		
		`#{convert_cmd} -density #{density} "#{filename}" "#{output_filename}"`
		
		output_filename
	end
end