require 'carrierwave/orm/mongoid'

class Upload
  include Mongoid::Document
  include UploadsHelper
  
  field :public, :type => Boolean, :default => true
  field :converted, :type => Boolean, :default => false
  field :static_host, :type => String, :default => nil
  field :total_pages, :type => Integer, :default => 0
  field :already_converted, :type => Integer, :default => 0
  field :doc_data, :type => String, :default => ""
  
  validates_presence_of :user_id
  
  referenced_in :user
  
  mount_uploader :file, PdfUploader
  
  after_save :start_convert
  before_destroy :remove_static_files
  
  protected
  def start_convert
    enqueue_convert_job(_id.to_s, file_filename)
  end
  
  def remove_static_files
    clean_static_files(_id.to_s)
  end
end
