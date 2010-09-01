$:.push File.expand_path(File.dirname(__FILE__) + '/../lib/easyroommate_parser')
require "listing_parser"

describe "Listing" do

  it "should determine the genders wanted" do
    listing = Listing.new_using_filename("real_data/listing_1.html")
    listing.genders_preferred_include?(:male).should be_false
    listing.genders_preferred_include?(:female).should be_true
  end

  it "should know the gender of existing flatmates" do
    listing = Listing.new_using_filename("real_data/listing_1.html")
    listing.genders_existing_include?(:female).should be_true
    listing.genders_existing_include?(:male).should be_false
    pending("should know the genders of flatmates other than the individual listing it")
  end

  it "should know the age wanted" do
    listing = Listing.new_using_filename("real_data/listing_1.html")
    listing.ages_preferred_include?(99).should be_true
    listing.ages_preferred_include?(100).should be_false
  end
end
