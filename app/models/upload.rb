require 'carrierwave/orm/mongoid'

class Upload
  include Mongoid::Document
  
  field :public, :type => Boolean, :default => true
  
  validates_presence_of :user_id
  
  referenced_in :user
  
  mount_uploader :file, PdfUploader
end
