require "uri"
require "cgi"

class Person
  attr_reader :firstname, :suburb, :url, :easyroommate_id

  def initialize(firstname, area, listing_link)
    @firstname = firstname
    @suburb = /^([^,]+),[^,]+$/.match(area)[1]
    @url = URI.join("http://au.easyroommate.com", listing_link).to_s
    query_fragment = URI.split(@url)[-2]
    parsed_query_fragment = CGI.parse(query_fragment)
    @easyroommate_id = parsed_query_fragment.fetch("code").first
  end

  def to_s
    "#@firstname of #@suburb profile page: #{@url}"
  end

  def actually_an_apartment?
    @firstname =~ /Bedroom/
  end

  def already_downloaded?
    File.exist?(self.download_filename)
  end

  def download_filename
    File.join("real_data", "#{@easyroommate_id}.html")
  end
end
