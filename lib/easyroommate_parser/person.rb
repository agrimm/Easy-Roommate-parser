require "uri"

class Person
  attr_reader :firstname, :suburb, :url

  def initialize(firstname, area, listing_link)
    @firstname = firstname
    @suburb = /^([^,]+),[^,]+$/.match(area)[1]
    @url = URI.join("http://au.easyroommate.com", listing_link).to_s
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
    escaped_firstname, escaped_suburb = [@firstname, @suburb].map{|string| string.gsub(/[^a-zA-Z]/, "")}
    File.join("real_data","#{escaped_firstname}_of_#{escaped_suburb}.html")
  end
end
