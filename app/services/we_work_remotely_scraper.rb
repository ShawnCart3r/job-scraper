require 'open-uri'
require 'nokogiri'

class WeWorkRemotelyScraper
  def self.scrape
    url = "https://weworkremotely.com/categories/remote-programming-jobs"
    html = URI.open(url)
    doc = Nokogiri::HTML(html)

    jobs = doc.css('section.jobs li:not(.view-all)')

    jobs.each do |job_node|
      link = job_node.at_css('a')&.[]('href')
      next unless link

      full_link = "https://weworkremotely.com#{link}"
      company = job_node.at_css('.company')&.text&.strip || "Unknown"
      title = job_node.at_css('.title')&.text&.strip || "No Title"
      location = job_node.at_css('.region')&.text&.strip || "Remote"
      tags = job_node.css('.tags .tag').map(&:text).join(", ")

      job = Job.find_or_initialize_by(apply_url: full_link)
      job.assign_attributes(
        title: title,
        company: company,
        location: location,
        tags: tags,
        description: "See full job listing for details.",
        salary_min: nil,
        salary_max: nil,
        source: "We Work Remotely"
      )
      job.save!
    end
  end
end
