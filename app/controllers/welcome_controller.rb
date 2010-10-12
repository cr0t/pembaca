class WelcomeController < ApplicationController
  def index
    if user_signed_in?
      @public_books = Upload.find(:all, :conditions => { :public => true, :converted => true, :user_id.ne => current_user.id }).descending(:created_at)
      @own_books    = current_user.uploads.where({ :converted => true }).descending(:created_at)
    else
      @public_books = Upload.find(:all, :conditions => { :public => true, :converted => true}).descending(:created_at)
    end
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
