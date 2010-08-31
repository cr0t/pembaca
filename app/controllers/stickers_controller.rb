class StickersController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /stickers
  # GET /stickers.js
  # GET /stickers.xml
  def index
    @stickers = Sticker.all.descending(:created_at)

    respond_to do |format|
      format.html # index.html.erb
      format.js # index.js.erb
      format.xml  { render :xml => @uploads }
    end
  end
  
  # GET /stickers/1
  # GET /stickers/1.xml
  def show
    @sticker = Sticker.find(params[:id])
  end
  
  # GET /stickers/new
  # GET /stickers/new.xml
  def new
    @sticker = Sticker.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sticker }
    end
  end
  
  # GET /stickers/1/edit
  def edit
    @sticker = Sticker.find(params[:id])
  end
  
  # POST /stickers
  # POST /stickers.xml
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
