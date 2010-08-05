require 'convert_job'

class WelcomeController < ApplicationController
  def index
    @users = User.all
    @uploads = Upload.find(:all, :conditions => { :public => true })
    
    # enqueue a new convert job and give it the id of the uploaded file
    #
  end

  def about
  end

end
