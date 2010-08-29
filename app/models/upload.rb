require 'carrierwave/orm/mongoid'

class Upload
  include Mongoid::Document
  include UploadsHelper
  
  field :public, :type => Boolean, :default => true
  field :total_pages, :type => Integer, :default => 0
  field :doc_data, :type => Array, :default => []
  field :converted, :type => Boolean, :default => false
  field :failed, :type => Boolean, :default => false
  field :already_converted, :type => Integer, :default => 0
  field :static_host, :type => String, :default => nil
  field :convert_errors, :type => Array, :default => []
  
  validates_presence_of :user_id
  
  referenced_in :user
  
  mount_uploader :file, PdfUploader
  
  def content_type
    mongo_filename = _id.to_s + "/" + file_filename
    file = Mongoid.master.collection('fs.files').find_one({ :filename => mongo_filename })
    file['contentType']
  end
  
  def reset_to_defaults
    self.converted         = false
    self.total_pages       = 0
    self.doc_data          = []
    self.failed            = false
    self.already_converted = 0
    self.static_host       = nil
    self.convert_errors    = []
    save!
  end
  
  after_create :start_convert
  before_destroy :remove_static_files
  
  protected
  def start_convert
    enqueue_convert_job(_id.to_s, file_filename)
  end
  
  def remove_static_files
    clean_static_files(_id.to_s)
  end
end
