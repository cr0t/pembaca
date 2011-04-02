class CanvasController < ApplicationController
  layout "facebook"
  
  def index
    unless params[:fb_sig_user].nil?
      @user = User.first(:conditions => { :facebook_id => params[:fb_sig_user] })
      if @user.persisted?
        sign_in @user
      end
    end
    
    if user_signed_in?
      @public_books = Upload.find(:all, :conditions => { :public => true, :converted => true, :user_id.ne => current_user.id }).descending(:created_at)
      @own_books    = current_user.uploads.where({ :converted => true }).descending(:created_at)
    else
      @public_books = Upload.find(:all, :conditions => { :public => true, :converted => true}).descending(:created_at)
    end
  end
  
  def viewer
    @book = Upload.first(:conditions => { :_id => BSON::ObjectId(params[:id]) })
  end

end
