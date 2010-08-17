class WelcomeController < ApplicationController
  def index
    @uploads = Upload.find(:all, :conditions => { :public => true, :converted => true }).limit(10)
  end
  
  def terms
  end
  
  def privacy
  end
  
  def about
  end
  
  def help
  end
  
  def team
  end

end
