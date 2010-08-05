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
    
    Dir.new(".").each do |filename|
    	if filename.match(/.pdf$/)
    		Converter.run(filename)
    		File.delete(filename)
    	end
    end
    
    #set_converted
    
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
  		`rm -rf #{@upload_id}/*.pdf` # all sliced pages of the source file
  		`rm -rf #{@upload_id}/#{@upload_id}` # the source file
  	end
  	
  	# moves uploaded binary file from mongo db to the local fs
  	def get_the_source_file
  		mongo_filename = @upload_id + "/" + @filename
  		
  		local_filename = 
  		
    	gridfs_file = Mongo::GridFileSystem.new(@db).open(mongo_filename, 'r')
    
    	File.open(@upload_id, 'w') { |f| f.write(gridfs_file.read) }
  	end
  	
  	# sets the converted flag to true
  	def set_converted
  		@db.collection('uploads').update({ "_id" => BSON::ObjectID(@upload_id) }, { "$set" => { "converted" => true } })
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
	def self.run(filename, density = 150)
		convert_cmd = `which convert`.strip
		
		output_filename = filename + ".png"
		
		cmd = "#{convert_cmd} -density #{density} \"#{filename}\" \"#{output_filename}\""
		
		puts "Processing '#{filename}'..."
		
		`#{cmd}`
	end
end