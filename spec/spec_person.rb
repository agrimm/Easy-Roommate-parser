$:.push File.expand_path(File.dirname(__FILE__) + '/../lib/easyroommate_parser')
require "person"

describe "Person" do

  #Important to guarantee this, so that I don't get in trouble for hammering the web site
  it "should know when it has already been downloaded" do
    person = Person.new("test_name_a", "test_suburb, test_region", "/content/common/listing_detail.aspx?code=H123456789012&from=L123456789012345")
    person.should be_already_downloaded
  end
end
