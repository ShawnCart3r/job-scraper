class JobsController < ApplicationController
 def index
  @jobs = Job.order(created_at: :desc)

  if params[:q].present?
    query = params[:q].downcase
    @jobs = @jobs.where("LOWER(title) LIKE :q OR LOWER(company) LIKE :q OR LOWER(tags) LIKE :q", q: "%#{query}%")
  end

  if params[:source].present?
    @jobs = @jobs.where(source: params[:source])
  end

  @jobs = @jobs.page(params[:page]).per(10)  # 👈 This enables pagination
end


  def refresh
  RemoteOkScraper.scrape
  WeWorkRemotelyScraper.scrape
  RemotiveScraper.scrape
   AuthenticJobsScraper.scrape
     OttaScraper.scrape
  redirect_to jobs_path, notice: "Jobs refreshed from all sources!"
  end

  def search
    query = params[:q].to_s.downcase

    @jobs = Job.where(
      "LOWER(title) LIKE :q OR LOWER(company) LIKE :q OR LOWER(tags) LIKE :q",
      q: "%#{query}%"
    ).order(created_at: :desc)

    render :index
  end
end
