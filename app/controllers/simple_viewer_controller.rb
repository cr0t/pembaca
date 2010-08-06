class SimpleViewerController < ApplicationController
  layout "light"
  
  def view
    @book = Upload.first(:conditions => {:_id=>BSON::ObjectID(params[:id])})
    @page = params[:page].rjust(6, "0")
  end
end
