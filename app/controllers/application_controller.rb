class ApplicationController < ActionController::Base
  def index
    @jobs = Job.all.order(created_at: :desc)
  end

  def refresh
    RemoteOkScraper.scrape
    redirect_to jobs_path, notice: "Jobs refreshed!"
  end
end