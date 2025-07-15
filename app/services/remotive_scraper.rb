require "httparty"
require "json"

class RemotiveScraper
  REMOTIVE_URL = "https://remotive.io/api/remote-jobs?category=software-dev"

  def self.scrape
    response = HTTParty.get(REMOTIVE_URL)
    jobs = JSON.parse(response.body)["jobs"]

    jobs.each do |job_data|
      title = job_data["title"]
      company = job_data["company_name"]
      location = job_data["candidate_required_location"] || "Remote"
      description = job_data["description"] || "See job posting for more details."
      apply_url = job_data["url"]
      tags = job_data["tags"].join(", ")
      created_at = Time.parse(job_data["publication_date"]) rescue Time.now

      Job.find_or_create_by(title: title, company: company, location: location) do |job|
        job.tags = tags
        job.description = ActionView::Base.full_sanitizer.sanitize(description)
        job.salary_min = nil
        job.salary_max = nil
        job.apply_url = apply_url
        job.source = "Remotive"
        job.created_at = created_at
      end
    end
  end
end
