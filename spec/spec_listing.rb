$:.push File.expand_path(File.dirname(__FILE__) + '/../lib/easyroommate_parser')
require "listing_parser"

# The following class isn't really fully fleshed out yet, so that's why it's in the test section

class Searcher
  attr_reader :gender, :age, :desired_genders

  def initialize(searcher_gender, searcher_age, searcher_desired_genders)
    @gender, @age, @desired_genders = searcher_gender, searcher_age, searcher_desired_genders
  end

  def genders_desired_include?(existing_genders)
    # Possibly hackish implementation
    @desired_genders.any? do |desired_gender|
      existing_genders.include?(desired_gender)
    end
  end
end


describe "Listing" do
  # Properties of listing 1:
  # # Their preferred gender is female only
  # # Their existing gender is female only
  # # Their preferred ages are 16 to 99
  LISTING_1_FILENAME = "real_data/listing_1.html"

  def create_searcher(searcher_gender, searcher_age, searcher_desired_genders)
    searcher = Searcher.new(searcher_gender, searcher_age, searcher_desired_genders)
  end

  it "should determine the genders wanted" do
    listing = Listing.new_using_filename(LISTING_1_FILENAME)
    listing.genders_preferred_include?(:male).should be_false
    listing.genders_preferred_include?(:female).should be_true
  end

  it "should know the gender of listing flatmate" do
    listing = Listing.new_using_filename(LISTING_1_FILENAME)
    listing.genders_existing_include?(:female).should be_true
    listing.genders_existing_include?(:male).should be_false
    pending("should know the genders of flatmates other than the individual listing it")
  end

  it "should know the age wanted" do
    listing = Listing.new_using_filename(LISTING_1_FILENAME)
    listing.ages_preferred_include?(99).should be_true
    listing.ages_preferred_include?(100).should be_false
  end

  it "should describe incompatibility issues in English" do
    listing = Listing.new_using_filename(LISTING_1_FILENAME)
    searcher = create_searcher(:male, 102, [:male])
    incompatibility_messages = listing.incompatibility_messages_for_searcher(searcher)
    incompatibility_messages.should include("Searcher gender is male when the listing prefers someone female")
    incompatibility_messages.should include("Searcher age is 102 when the listing prefers ages 16 to 99")
    incompatibility_messages.should include("Existing flatmates are all female when you want at least one male flatmate")
  end

end
