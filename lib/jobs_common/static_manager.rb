require 'net/ssh'
require 'net/scp'

class StaticManager
  attr_reader :host
  
  def initialize(upload_id)
    upload_conf = YAML::load_file(Rails.root.join('config/static_servers.yml'))[Rails.env]

    @host = upload_conf["servers"][0]["hostname"]
  	@user = upload_conf["servers"][0]["username"]
  	@pass = upload_conf["servers"][0]["password"]
  	@path = upload_conf["servers"][0]["directory"] + upload_id
  end
  
  def create_upload_dir
		Net::SSH.start(@host, @user, :password => @pass) do |ssh|
			ssh.exec! "mkdir #{@path}"
		end
	end
  
  # sends file to the remote ("static") host and unpack it there
	def upload_and_unpack_converted_file(local_filename)
		Net::SCP.start(@host, @user, :password => @pass) do |scp|
		  remote_file = @path + "/" + local_filename
			scp.upload! local_filename, remote_file
		end
		
		Net::SSH.start(@host, @user, :password => @pass) do |ssh|
			ssh.exec! "cd #{@path} && tar xf #{local_filename} && rm -f #{local_filename}"
		end
	end
	
	# removes whole remote directory (with converted files)
	def remove_static_path
		Net::SSH.start(@host, @user, :password => @pass) do |ssh|
			ssh.exec! "rm -rf #{@path}"
		end
	end
  
end