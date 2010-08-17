require_or_load 'lib/convert_job'
require_or_load 'lib/clean_job'

module UploadsHelper
  def enqueue_convert_job(upload_id, filename)
    Resque.enqueue(ConvertJob, upload_id, filename)
  end
  
  def clean_static_files(upload_id)
    Resque.enqueue(CleanJob, upload_id)
  end
end
