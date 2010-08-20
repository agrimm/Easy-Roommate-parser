class Person
  attr_reader :firstname, :suburb

  def initialize(firstname, area)
    @firstname = firstname
    @suburb = /^([^,]+),[^,]+$/.match(area)[1]
  end

  def to_s
    "#@firstname of #@suburb"
  end

  def actually_an_apartment?
    @firstname =~ /Bedroom/
  end

end
