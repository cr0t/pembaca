CarrierWave.configure do |config|
  config.grid_fs_database = Mongoid.database.name
  config.grid_fs_host = Mongoid.config.master.connection.host_to_try[0]
  config.storage = :grid_fs
  config.grid_fs_access_url = "/uploads"
end