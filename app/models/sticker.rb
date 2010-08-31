class Sticker
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :page_number, :type => Integer, :default => nil
  field :text,        :type => String,  :default => nil
  field :top,         :type => Integer, :default => 50
  field :left,        :type => Integer, :default => 100
  field :public,      :type => Boolean, :default => true
  
  validates_presence_of :upload, :page_number, :text, :top, :left
  
  referenced_in :upload
  referenced_in :user
end
