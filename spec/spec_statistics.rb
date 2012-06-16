$:.push File.expand_path(File.dirname(__FILE__))
$:.push File.expand_path(File.dirname(__FILE__) + '/../lib/easyroommate_parser')
require "spec_helper"
require "listing_parser"
require "statistics"

describe "Statistics" do
  it "list suburbs" do
    listing = Listing.new(nil, nil, "Bondi Junction", 250)
    listings = [listing, listing]
    statistics = Statistics.new(listings)
    statistics.suburbs.should include "Bondi Junction"
    statistics.rents_for_suburb("Bondi Junction").should eq [250, 250]
  end
end
