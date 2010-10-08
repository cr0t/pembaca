class CanvasController < ApplicationController
  layout "facebook"
  
  def index
    @uploads = Upload.find(:all, :conditions => { :public => true, :converted => true }).descending(:created_at)
  end
  
  def viewer
    @book = Upload.first(:conditions => { :_id => BSON::ObjectID(params[:id]) })
  end

end
