require "open-uri"
require "nokogiri"
require "json"

class OttaScraper
  def self.scrape
    queries = [ "web developer", "full stack" ]

    queries.each do |query|
      url = "https://www.otta.com/jobs?q=#{URI.encode_www_form_component(query)}"
      html = URI.open(url, "User-Agent" => "Mozilla/5.0").read
      doc = Nokogiri::HTML(html)

      json_data = doc.at("script#__NEXT_DATA__")&.text
      next unless json_data

      parsed = JSON.parse(json_data)
      jobs = parsed.dig("props", "pageProps", "jobs") || []

      jobs.each do |job_data|
        title = job_data.dig("job", "title") || "Untitled"
        company = job_data.dig("company", "name") || "Unknown"
        location = job_data.dig("job", "location", "name") || "Remote"
        slug = job_data.dig("job", "slug") || ""
        apply_url = "https://www.otta.com#{slug}"
        tags = (job_data.dig("job", "tech_tags") || []).join(", ")
        raw_description = job_data.dig("job", "summary") || "No description provided."
        description = ActionView::Base.full_sanitizer.sanitize(raw_description)

        Job.find_or_create_by(title: title, company: company, location: location) do |job|
          job.tags = tags
          job.description = description
          job.salary_min = nil
          job.salary_max = nil
          job.apply_url = apply_url
          job.source = "Otta"
          job.created_at = Time.now
        end
      end
    end
  end
end
