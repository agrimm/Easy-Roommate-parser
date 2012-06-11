require "ternary_logic"
require "nokogiri"

class ListingParser
  attr_reader :listing

  def self.new_using_filename(listing_filename)
    begin
      File.open(listing_filename) do |listing_file|
        return new(listing_file)
      end
    rescue
      raise $!, "Problem with file #{listing_filename}: #{$!}"
    end
  end

  def initialize(listing_file)
    @document = Nokogiri::HTML(listing_file)
    preferred_flatmate_genders = determine_preferred_flatmate_genders
    preferred_flatmate_ages = determine_preferred_flatmate_ages
    preferred_flatmate = Listing::PreferredFlatmate.new(preferred_flatmate_genders, preferred_flatmate_ages)
    existing_flatmate_genders = determine_existing_flatmate_genders
    existing_flatmates = Listing::ExistingFlatmates.new(existing_flatmate_genders)
    # FIXME duplicating code in Person#initialize and ResultParser#find_people
    suburb = determine_suburb
    rent = determine_rent
    @listing = Listing.new(preferred_flatmate, existing_flatmates, suburb, rent)
  end

  def determine_preferred_flatmate_genders
    gender_info_nodes = @document.xpath('.//tr[contains(@id, "IndividualGenderInfo")]/td')
    gender_info_contents = gender_info_nodes.map(&:content)
    #preferred_flatmate_genders = Listing::Genders.new_using_strings(gender_info_contents[1])
    preferred_flatmate_genders = Listing::Genders.new_using_strings(gender_info_contents)
  end

  def determine_existing_flatmate_genders
    # Much of this is copy and pasted from determine_preferred_flatmate_genders
    gender_info_nodes = @document.xpath('.//tr[contains(@id, "IndividualGenderInfo")]/td')
    gender_info_contents = gender_info_nodes.map(&:content)
    listing_flatmate_gender_string = gender_info_contents[0]
    gender_strings = [listing_flatmate_gender_string]
    # The website doesn't provide direct metadata on which node has the gender information of the whole household
    # The following SO question may help, but it sounds a little complicated
    # http://stackoverflow.com/questions/1968641/xpath-html-select-node-based-on-related-node
    household_gender_info_nodes = @document.xpath('.//table[contains(@id, "HouseholdInfoTable")]/tr[7]/td')
    unless household_gender_info_nodes.empty?
      household_gender_string = household_gender_info_nodes.first.content
      gender_strings = [listing_flatmate_gender_string, household_gender_string]
    end
    Listing::Genders.new_using_strings(gender_strings)
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

  def determine_suburb
    area_node = @document.xpath('.//tr[contains(@id, "e_phMain_FullListing_AreaTr")]').children[-2].children[0]
    area_text = area_node.text
    suburb = /^([^,]+),[^,]+$/.match(area_text)[1]
    suburb
  end

  def determine_rent
    full_listing_nodes = @document.xpath('.//table[contains(@class, "fulllistingfigures")]')
    raw_rent_text = full_listing_nodes[0].children[0].children[2].children[2].children[0].text
    /\$(?<specific_rent_string>\d+) per Week/ =~ raw_rent_text
    Integer(specific_rent_string, 10)
  end
end

class Listing
  attr_reader :suburb, :rent

  def self.new_using_filename(listing_filename)
    listing_parser = ListingParser.new_using_filename(listing_filename)
    listing_parser.listing
  end

  def initialize(preferred_flatmate, existing_flatmates, suburb, rent)
    @preferred_flatmate = preferred_flatmate
    @existing_flatmates = existing_flatmates
    @suburb = suburb
    @rent = rent
  end

  def genders_preferred_include?(gender)
    @preferred_flatmate.genders_preferred_include?(gender)
  end

  # Returns true when it's definitely true, UNKNOWN when it's not known, and false when it's definitely false
  # Warning: possesses truthiness even when UNKNOWN
  def genders_existing_include?(gender)
    @existing_flatmates.genders_include?(gender)
  end

  def ages_preferred_include?(age)
    @preferred_flatmate.ages_preferred_include?(age)
  end

  # Ideally, this should use something like ActiveModel rather than hand-rolling a list of validations
  def incompatibility_messages_for_searcher(searcher)
    messages = []
    messages << "Searcher gender is #{searcher.gender} when the listing prefers someone #{@preferred_flatmate.genders_as_string}" unless genders_preferred_include?(searcher.gender)
    messages << "Searcher age is #{searcher.age} when the listing prefers ages #{@preferred_flatmate.ages_preferred_as_string}" unless ages_preferred_include?(searcher.age)
    messages << "Existing flatmates are all #{@existing_flatmates.genders_as_string} when you want at least one #{searcher.desired_genders.join} flatmate" unless (searcher.genders_desired_include?(@existing_flatmates.genders))
    messages
  end

end

class Listing::PreferredFlatmate
  def initialize(preferred_genders, preferred_ages)
    @preferred_genders = preferred_genders
    @preferred_ages = preferred_ages
  end

  def genders_preferred_include?(gender)
    @preferred_genders.include?(gender)
  end

  def ages_preferred_include?(age)
    @preferred_ages.include?(age)
  end

  def ages_preferred_as_string
    [@preferred_ages.first, "to", @preferred_ages.last].join(" ")
  end

  def genders
    @preferred_genders
  end

  def genders_as_string
    @preferred_genders.as_string
  end
end

class Listing::ExistingFlatmates
  def genders
    @existing_genders
  end

  def initialize(existing_genders)
    @existing_genders = existing_genders
  end

  # Returns true when it's definitely true, UNKNOWN when it's not known, and false when it's definitely false
  # Warning: possesses truthiness even when UNKNOWN
  def genders_include?(gender)
    @existing_genders.include?(gender)
  end

  def genders_as_string
    @existing_genders.as_string
  end
end

class Listing::Genders
  def self.new_using_strings(strings)
    genders = strings.inject([]) do |result, string|
      case string
      when "Male" then result + [:male]
      when "Female" then result + [:female]
      when "Mixed" then result + [:male, :female]
      when "Couple" then result + [:male, :female] # Not unit tested
      when "Doesn't Matter" then result + [:male, :female]
      when "Not Disclosed" then result + [:unknown]
      else raise "Can't handle #{string}"
      end
    end
    genders.uniq!
    new(genders)
  end

  def initialize(genders)
    @genders = genders
  end

  # Returns true when it's definitely true, UNKNOWN when it's not known, and false when it's definitely false
  # Warning: possesses truthiness even when UNKNOWN
  def include?(gender)
    case
    when @genders.include?(gender) == true then return true
    when @genders.include?(:unknown) then return UNKNOWN
    else return false
    end
  end

  def as_string
    @genders.join(", ")
  end
end
