class CanvasController < ApplicationController
  layout "facebook"
  
  def index
    unless params[:fb_sig_user].nil?
      @user = User.first(:conditions => { :facebook_id => params[:fb_sig_user] })
      if @user.persisted?
        sign_in @user
      end
    end
    
    @uploads = Upload.find(:all, :conditions => { :public => true, :converted => true }).descending(:created_at)
  end
  
  def viewer
    @book = Upload.first(:conditions => { :_id => BSON::ObjectId(params[:id]) })
  end

end
