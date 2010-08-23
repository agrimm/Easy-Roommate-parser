require "nokogiri"

class ListingParser
  attr_reader :listing

  def self.new_using_filename(listing_filename)
    File.open(listing_filename) do |listing_file|
      return new(listing_file)
    end
  end

  def initialize(listing_file)
    @document = Nokogiri::HTML(listing_file)
    preferred_flatmate_genders = determine_preferred_flatmate_genders
    preferred_flatmate = Listing::PreferredFlatmate.new(preferred_flatmate_genders)
    @listing = Listing.new(preferred_flatmate)
  end

  def determine_preferred_flatmate_genders
    gender_info_nodes = @document.xpath('.//tr[contains(@id, "IndividualGenderInfo")]/td')
    gender_info_contents = gender_info_nodes.map(&:content)
    preferred_flatmate_genders = case gender_info_contents[1]
    when "Male" then [:male]
    when "Female" then [:female]
    when "Doesn't Matter" then [:male, :female]
    else raise "Unexpected scenario"
    end
  end
end

class Listing
  def self.new_using_filename(listing_filename)
    listing_parser = ListingParser.new_using_filename(listing_filename)
    listing_parser.listing
  end

  def initialize(preferred_flatmate)
    @preferred_flatmate = preferred_flatmate
  end

  def genders_allowed_include?(gender)
    @preferred_flatmate.genders_allowed_include?(gender)
  end
end

class Listing::PreferredFlatmate
  def initialize(preferred_genders)
    @preferred_genders = preferred_genders
    raise "Invalid genders in #{@preferred_genders.inspect}" unless (@preferred_genders - [:male, :female]).empty?
  end

  def genders_allowed_include?(gender)
    @preferred_genders.include?(gender)
  end
end