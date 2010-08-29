require 'jobs_common/static_manager'

class ConvertJob
  @queue = :convert
  
  class << self
    def perform(upload_id, filename, density = 150)
      @convert_errors = Array.new
      
      begin
        mongoid_conf = YAML::load_file(Rails.root.join('config/mongoid.yml'))[Rails.env]

      	@upload_id = upload_id
      	@filename  = filename
      	@db = Mongo::Connection.new(mongoid_conf['host']).db(mongoid_conf['database'])

        setup_environment
        
        get_the_source_file
        
        if @content_type != 'application/pdf'
          try_to_unoconv
        end

        slice_by_pages(@upload_id)
        
        @static_manager = StaticManager.new(@upload_id)
      	@static_manager.create_upload_dir
      	
      	total_pages_to_convert = `ls *-page-*.pdf | wc -l`.strip.to_i
      	
      	if total_pages_to_convert == 0
      	  @convert_errors.push("Can't get total pages number")
    	  end
      	
      	@db.collection('uploads').update({ "_id" => BSON::ObjectID(@upload_id) }, {
    			"$set" => { "total_pages" => total_pages_to_convert }
    		})

      	converted_count = 0

        Dir.new(".").each do |filename|
        	if filename.match(/.pdf$/)
        		out_file = convert_file(filename, density)
        		create_thumb(out_file)
        		
        		converted_count += 1
        		
        		@db.collection('uploads').update({ "_id" => BSON::ObjectID(@upload_id) }, {
        		  "$set" => { "already_converted" => converted_count }
        		})
        		
        		File.delete(filename)
        	end
        end
        
        # remove the source file
        File.delete(@upload_id)
        
        tar_filename = @upload_id + ".tar"
        
        `tar cf #{tar_filename} *`
        
        @static_manager.upload_and_unpack_converted_file(tar_filename)
        
        set_converted_data(@static_manager.host)
      rescue Exception => e
        @convert_errors.push("General converting error: " + e.message)
        raise
      ensure
        set_convert_errors
        clean_environment
      end
    end
    
    
  	protected
  	
  	# creates new temporary working directory and chdir to it
  	def setup_environment
  		`mkdir /tmp/#{@upload_id}`
  		Dir.chdir("/tmp/" + @upload_id)
  	end
  	
  	# moves uploaded binary file from mongo db to the local fs
  	def get_the_source_file
  	  begin
  	    mongo_filename = @upload_id + "/" + @filename
      	gridfs_file = Mongo::GridFileSystem.new(@db).open(mongo_filename, 'r')
      	File.open(@upload_id, 'w') { |f| f.write(gridfs_file.read) }
	    rescue
	      @convert_errors.push("Can't get the source file from MongoDB")
	    end
    	# FIXME: здесь может можно узнать contentType и у gridfs_file
    	file = @db.collection('fs.files').find_one({ :filename => mongo_filename })
    	@content_type = file['contentType']
  	end
  	
  	# tryies to use unoconv to convert source file to the pdf format
  	def try_to_unoconv
  	  unoconv_cmd = `which unoconv`.strip
  	  
  	  unoconv_cmd.empty? and raise "There is no 'unoconv' utility on this worker"
  	  
  	  # changing last 3 characters to "pdf"
  		pdf_filename = @filename.dup
  		pdf_filename[-3, 3] = "pdf"
  		
  		cmd = "mv '#{@upload_id}' '#{@filename}' && #{unoconv_cmd} -f pdf '#{@filename}' && rm -f '#{@filename}' && mv '#{pdf_filename}' '#{@upload_id}' 2>&1"
  	  
  		if !system(cmd)
  		  @convert_errors.push("Errors during running unoconv utility")
		  end
	  end
  	
  	# slice pdf source file page-by-page (to save RAM while converting it)
  	def slice_by_pages(filename)
  		pdftk_cmd = `which pdftk`.strip
  		
  		pdftk_cmd.empty? and raise "There is no 'pdftk' utility on this worker"
  		
  		out = `#{pdftk_cmd} #{filename} burst output "#{filename}-page-%06d.pdf" 2>&1`
  		
  		if !out.empty?
  		  @convert_errors.push("pdftk error:\n" + out)
		  end
  	end
  	
  	# runs the convert command line utility to convert pdf to png for a given file
  	def convert_file(filename, density = 150)
  		convert_cmd = `which convert`.strip
  		
  		convert_cmd.empty? and raise "There is no 'convert' utility on this worker"

  		output_filename = filename.gsub(".pdf", "").gsub("-page", "") + ".png"

  		if !system("#{convert_cmd} -density #{density} \"#{filename}\" \"#{output_filename}\" 2>&1")
  		  @convert_errors.push("Errors during running convert utility on file '#{filename}'")
		  end

  		output_filename
  	end
  	
  	# converts the page image file to the thumbnailed version (resized by height)
  	def create_thumb(filename, height = 130)
  	  convert_cmd = `which convert`.strip
  	  
  	  output_filename = filename.gsub(".png", "") + "-thumb-height-#{height}.png"
  	  
  	  if !system("#{convert_cmd} -resize 'x#{height}' \"#{filename}\" \"#{output_filename}\" 2>&1")
  		  @convert_errors.push("Errors during running convert utility (thumbnailing) on file '#{filename}'")
		  end

  		output_filename
	  end
  	
  	# sets the converted flag to true and add some fields
  	def set_converted_data(static_host)
  	  doc_data = parse_doc_data
  	  
  	  converted = true
  	  failed    = false
  	  if !@convert_errors.empty?
  	    converted = false
  	    failed    = true
	    end
  		
  		@db.collection('uploads').update({ "_id" => BSON::ObjectID(@upload_id) }, {
  			"$set" => {
  				"converted"   => converted,
  				"failed"      => failed,
  				"static_host" => static_host,
  				"doc_data"    => doc_data
  			}
  		})
  	end
  	
  	# parses doc_data.txt file to array of hashes
    def parse_doc_data
      begin
        raw_data = File.open("doc_data.txt", "r").read
        ary_data = raw_data.split(/\n/)

        parsed_info = []

        ary_data.each_with_index do |elem, i|
          next_elem = ary_data[i + 1]

          if (elem.match(/InfoKey/) && (next_elem.match(/InfoValue/)))
            parsed_info.push(elem.split(/\:/, 2)[1].strip => next_elem.split(/\:/, 2)[1].strip)
          else
            if (!elem.match(/InfoValue/))
              parsed_info.push(elem.split(/\:/, 2)[0].strip => elem.split(/\:/, 2)[1].strip)
            end
          end
        end
      rescue
        parsed_info = []
        @convert_errors.push("There is no generated 'doc_data.txt' file during converting file")
      end

      return parsed_info
    end
    
    # sets the convert errors field if any was during converting
  	def set_convert_errors
  		@db.collection('uploads').update({ "_id" => BSON::ObjectID(@upload_id) }, {
  			"$set" => {
  				"convert_errors" => @convert_errors
  			}
  		})
  	end
    
    # removes the working directory with all working temporary files
    def clean_environment
  		`rm -rf /tmp/#{@upload_id}` # all sliced pages of the source file
  	end
  end
end