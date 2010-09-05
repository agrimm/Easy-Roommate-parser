# The following class isn't really fully fleshed out yet.

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
