class StickersController < ApplicationController  
  def create
    @sticker = Sticker.new(params[:sticker])
    @sticker.upload = Upload.find(params[:book_id])
    @sticker.user   = current_user
    
    respond_to do |format|
      if @sticker.save
        format.html { redirect_to(@sticker, :notice => 'Sticker was successfully created.') }
        format.json { render :json => @sticker.to_json }
        format.xml  { render :xml => @sticker, :status => :created, :location => @sticker }
      else
        format.html { render :action => "new" }
        format.json { render :json => @sticker.errors.to_json }
        format.xml  { render :xml => @sticker.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    @sticker = Sticker.find(params[:id])
  end
  
  # PUT /stickers/1
  # PUT /stickers/1.xml
  def update
    @sticker = Sticker.find(params[:id])
    
    respond_to do |format|
      if @sticker.update_attributes(params[:sticker])
        format.html { redirect_to(@sticker, :notice => 'Sticker was successfully updated.') }
        format.json { render :json => @sticker.to_json }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @sticker.errors.to_json }
        format.xml  { render :xml => @sticker.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /stickers/1
  # DELETE /stickers/1.xml
  def destroy
    @sticker = Sticker.find(params[:id])
    @sticker.destroy

    respond_to do |format|
      format.html { redirect_to(uploads_url) }
      format.json { render :json => { :result => "success" }.to_json }
      format.xml  { head :ok }
    end
  end
end
