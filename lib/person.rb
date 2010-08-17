class Person

  def initialize(firstname, area)
    @firstname, @area = firstname, area
  end

  def to_s
    "#@firstname of #@area"
  end

  def actually_an_apartment?
    @firstname =~ /Bedroom/
  end
end
