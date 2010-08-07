class WelcomeController < ApplicationController
  def index
    @users = User.all
    @uploads = Upload.find(:all, :conditions => { :public => true, :converted => true }).limit(10)
  end

  def about
  end

end
