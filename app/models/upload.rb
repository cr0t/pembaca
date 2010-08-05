require 'carrierwave/orm/mongoid'

class Upload
  include Mongoid::Document
  
  field :public, :type => Boolean, :default => true
  field :converted, :type => Boolean, :default => false
  
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
