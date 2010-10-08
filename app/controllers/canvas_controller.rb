class CanvasController < ApplicationController
  def index
    @uploads = Upload.find(:all, :conditions => { :public => true, :converted => true }).descending(:created_at)
    render "welcome/index", :layout => "facebook"
  end

end
