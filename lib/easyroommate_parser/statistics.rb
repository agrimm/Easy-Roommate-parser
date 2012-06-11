class Statistics
  def initialize(listings)
    @listings = listings
  end

  def suburbs
    @listings.map(&:suburb).uniq
  end

  def rents_for_suburb(suburb)
    @listings.find_all{|listing| listing.suburb == suburb}.map(&:rent)
  end
end
