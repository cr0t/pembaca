require_or_load 'lib/convert_job'
require_or_load 'lib/clean_job'

module UploadsHelper
  def enqueue_convert_job(upload_id, filename)
    Resque.enqueue(ConvertJob, upload_id, filename)
  end
  
  def clean_static_files(upload_id)
    Resque.enqueue(CleanJob, upload_id)
  end
  
  def converted_percent(upload_model)
    percent_done = (upload_model.already_converted / (upload_model.total_pages / 100.0)).to_f
    
		if (percent_done.nan? || percent_done.infinite?) 
		  0
		else
		  percent_done.round
		end
  end
  
  def thumbnail_url(upload, page = 1, height = 130)
    page = page.to_s.rjust(6, "0")
    "http://#{upload.static_host}/#{upload.id}/#{upload.id}-#{page}-thumb-height-#{height}.png"
  end
end
