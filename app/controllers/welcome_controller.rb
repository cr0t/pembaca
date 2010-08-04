class WelcomeController < ApplicationController
  def index
    @users = User.all
    @uploads = Upload.find(:all, :conditions => { :public => true })
  end

  def about
  end

end
