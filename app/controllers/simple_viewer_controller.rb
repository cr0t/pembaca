class SimpleViewerController < ApplicationController
  layout "light"
  
  def view
    cookies.permanent[:last_book_id]  = params[:id]
    cookies.permanent[:last_page_num] = params[:page]
    
    @book = Upload.first(:conditions => { :_id => BSON::ObjectId(params[:id]) })
    redirect_to root_path, :notice => "We can not find book for the given id" if @book.nil?
    @page = params[:page].rjust(6, "0")
  end
  
  def view_last_book
    if cookies[:last_book_id].nil?
      redirect_to root_path, :notice => "You haven't read any book before"
    else
      @book = Upload.first(:conditions => { :_id => BSON::ObjectId(cookies[:last_book_id]) })
      @page = cookies[:last_page_num].rjust(6, "0")

      render :view
    end
  end
end
