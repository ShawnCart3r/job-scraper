require "open-uri"
require "nokogiri"

class AuthenticJobsScraper
  AUTHENTIC_JOBS_URL = "https://authenticjobs.com/api/jobs/index?format=json&api_key=YOUR_API_KEY"

  def self.scrape
    response = HTTParty.get(AUTHENTIC_JOBS_URL)
    jobs = JSON.parse(response.body)["listings"]["listing"] rescue []

    jobs.each do |job_data|
      title = job_data["title"]
      company = job_data.dig("company", "name") || "Unknown"
      location = job_data["location"] || "Remote"
      description = job_data["description"] || "See job posting for more details."
      apply_url = job_data["url"]
      tags = job_data["category"] || ""
      created_at = Time.parse(job_data["post_date"]) rescue Time.now

      Job.find_or_create_by(title: title, company: company, location: location) do |job|
        job.tags = tags
        job.description = ActionView::Base.full_sanitizer.sanitize(description)
        job.salary_min = nil
        job.salary_max = nil
        job.apply_url = apply_url
        job.source = "Authentic Jobs"
        job.created_at = created_at
      end
    end
  end
end
