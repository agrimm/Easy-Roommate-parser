$:.push File.expand_path(File.dirname(__FILE__) + '/../lib/easyroommate_parser')
require "listing_parser"

describe "Listing" do

  it "should determine the genders wanted" do
    listing = Listing.new_using_filename("real_data/listing_1.html")
    listing.genders_allowed_include?(:male).should be_false
    listing.genders_allowed_include?(:female).should be_true
  end
end
