$:.push File.expand_path(File.dirname(__FILE__))
$:.push File.expand_path(File.dirname(__FILE__) + '/../lib/easyroommate_parser')
require "spec_helper"
require "person"

describe "Person" do

  def create_sample_person
    person =  Person.new("test_name_a", "test_suburb, test_region", "/content/common/listing_detail.aspx?code=H123456789012&from=L123456789012345")
  end

  it "should use Easy roommate's ID for unique identification" do
    person = create_sample_person
    person.download_filename.should be == "real_data/H123456789012.html"
  end

  #Important to guarantee this, so that I don't get in trouble for hammering the web site
  it "should know when it has already been downloaded" do
    person = create_sample_person
    person.should be_already_downloaded
  end
end
