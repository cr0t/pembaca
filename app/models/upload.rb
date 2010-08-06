require 'carrierwave/orm/mongoid'
require_or_load 'convert_job'

class Upload
  include Mongoid::Document
  
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
  
  protected
  def start_convert
    upload_id = self._id.to_s
    filename  = self.file_filename
    
    Resque.enqueue(ConvertJob, upload_id, filename)
  end
end
