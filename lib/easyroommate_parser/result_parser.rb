class ResultParser
  attr_reader :people

  def initialize(file)
    @document = Nokogiri::HTML(file)
    @people = find_people
  end

  def find_people
    possible_people = @document.xpath("//div[@class='listingpreview']").map do |listing_node|
      firstname_node = listing_node.xpath('.//a[contains(@id, "FirstName")]').first
      firstname_text = firstname_node.content

      area_node = listing_node.xpath('.//tr[contains(@id, "Area")]/td').first
      area_text = area_node.content

      listing_link_node = listing_node.xpath('.//a[contains(@id, "ViewProfileLink")]').first
      listing_link_text = listing_link_node["href"]

      person = Person.new(firstname_text, area_text, listing_link_text)
      person
    end
    actual_people = possible_people.reject(&:actually_an_apartment?)
    actual_people
  end

end
