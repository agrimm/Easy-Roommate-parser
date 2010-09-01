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
    preferred_flatmate_ages = determine_preferred_flatmate_ages
    preferred_flatmate = Listing::PreferredFlatmate.new(preferred_flatmate_genders, preferred_flatmate_ages)
    existing_flatmate_genders = determine_existing_flatmate_genders
    existing_flatmates = Listing::ExistingFlatmates.new(existing_flatmate_genders)
    @listing = Listing.new(preferred_flatmate, existing_flatmates)
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

  def determine_existing_flatmate_genders
    # Much of this is copy and pasted from determine_preferred_flatmate_genders
    gender_info_nodes = @document.xpath('.//tr[contains(@id, "IndividualGenderInfo")]/td')
    gender_info_contents = gender_info_nodes.map(&:content)
    listing_flatmate_gender = case gender_info_contents[0]
      when "Female" then :female
      when "Male" then :male
      else raise "Untested scenario"
    end
    # Fixme: doesn't look at other flatmates yet
    [listing_flatmate_gender]
  end

  def determine_preferred_flatmate_ages
    age_info_nodes = @document.xpath('.//tr[contains(@id, "IndividualAgeInfo")]/td')
    age_info_contents = age_info_nodes.map(&:content)
    preferred_flatmate_age_info_content = age_info_contents[1]
    preferred_flatmate_ages_regexp = /from (\d+) to (\d+) yrs. old/
    match = preferred_flatmate_ages_regexp.match(preferred_flatmate_age_info_content)
    preferred_flatmate_ages = Range.new(Integer(match[1]), Integer(match[2]), false)
    preferred_flatmate_ages
  end

end

class Listing
  def self.new_using_filename(listing_filename)
    listing_parser = ListingParser.new_using_filename(listing_filename)
    listing_parser.listing
  end

  def initialize(preferred_flatmate, existing_flatmates)
    @preferred_flatmate = preferred_flatmate
    @existing_flatmates = existing_flatmates
  end

  def genders_preferred_include?(gender)
    @preferred_flatmate.genders_preferred_include?(gender)
  end

  def genders_existing_include?(gender)
    @existing_flatmates.genders_include?(gender)
  end

  def ages_preferred_include?(age)
    @preferred_flatmate.ages_preferred_include?(age)
  end

end

class Listing::PreferredFlatmate
  def initialize(preferred_genders, preferred_ages)
    @preferred_genders = preferred_genders
    @preferred_ages = preferred_ages
    raise "Invalid genders in #{@preferred_genders.inspect}" unless (@preferred_genders - [:male, :female]).empty?
  end

  def genders_preferred_include?(gender)
    @preferred_genders.include?(gender)
  end

  def ages_preferred_include?(age)
    @preferred_ages.include?(age)
  end

end

class Listing::ExistingFlatmates

  def initialize(existing_genders)
    @existing_genders = existing_genders
  end

  def genders_include?(gender)
    @existing_genders.include?(gender)
  end

end
