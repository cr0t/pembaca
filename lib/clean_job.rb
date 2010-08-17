require 'jobs_common/static_manager'

class CleanJob
  @queue = :clean

  class << self
    def perform(upload_id)
      @manager = StaticManager.new(upload_id)
      @manager.remove_static_path
    end
  end
end