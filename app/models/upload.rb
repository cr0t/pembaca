require 'carrierwave/orm/mongoid'

class Upload
  include Mongoid::Document
  
  references_one :user
  
  mount_uploader :file, PdfUploader
end