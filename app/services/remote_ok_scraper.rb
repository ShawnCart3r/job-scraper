

require "httparty"
require "json"

class RemoteOkScraper
  REMOTE_OK_URL = "https://remoteok.com/remote-dev-jobs.json"

  def self.scrape
    response = HTTParty.get(REMOTE_OK_URL)
    jobs = JSON.parse(response.body)[1..] # skip metadata row

    jobs.each do |job_data|
      tags = (job_data["tags"] || []).join(", ")
      position = job_data["position"] || ""
      company = job_data["company"] || ""
      location = job_data["location"] || "Remote"
      description = job_data["description"] || "See job posting for more details."
      apply_url = "https://remoteok.com#{job_data['url']}"
      salary = job_data["salary"] || ""
      logo = job_data["logo"] || ""
      created_at = Time.at(job_data["epoch"]) rescue Time.now

      Job.find_or_create_by(title: position, company: company, location: location) do |job|
        job.tags = tags
        job.description = ActionView::Base.full_sanitizer.sanitize(description)
        job.salary_min = nil
        job.salary_max = nil
        job.apply_url = apply_url
        job.source = "RemoteOK"
        job.created_at = created_at
      end
    end
  end
end
