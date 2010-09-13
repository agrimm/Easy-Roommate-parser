$:.push File.expand_path(File.dirname(__FILE__) + '/easyroommate_parser')
require "person"
require "result_parser"
require "notes_parser"
require "searcher"
require "listing_parser"

require "nokogiri"

class EasyroommateParser
  UNDOWNLOADED_PEOPLE_FILENAME = "real_data/undownloaded_people.yml"

  def self.new_using_filenames(results_filename, notes_filename)
    File.open(results_filename) do |results_file|
      File.open(notes_filename) do |notes_file|
        new(results_file, notes_file)
      end
    end
  end

  def initialize(results_file, notes_file)
    @result_parser = ResultParser.new(results_file)
    @notes_parser = NotesParser.new(notes_file)
    @new_people = @notes_parser.reject_existing_people(@result_parser.people)
    @undownloaded_people = @new_people.reject{|person| person.already_downloaded?}
  end

  def display_new_people
    puts "#{@new_people.length} people so far not listed in your notes"
  end

  def display_undownloaded_people
    puts "#{@undownloaded_people.length} people so far not downloaded to be parsed by this program"
  end

  def export_undownloaded_people
    return if @undownloaded_people.empty?
    abort "File #{UNDOWNLOADED_PEOPLE_FILENAME} already exists. Please delete the file if you've downloaded the people listed in it" if File.exist?(UNDOWNLOADED_PEOPLE_FILENAME)
    filenames_and_urls = @undownloaded_people.map do |person|
      {:filename => person.download_filename, :url=> person.url}
    end
    File.open(UNDOWNLOADED_PEOPLE_FILENAME, "w") do |undownloaded_people_file|
      YAML.dump(filenames_and_urls, undownloaded_people_file)
    end
  end

  def exit_if_people_undownloaded
    return if @undownloaded_people.empty?
    abort "Please run bin/download_listings.rb to download new people."
  end

  def display_suitability_of_new_people
    searcher = Searcher.new(:male, 31, [:female]) # Fixme: make this configurable by 2011
    new_people_and_listings = @new_people.map {|new_person| [new_person, Listing.new_using_filename(new_person.download_filename)]}
    suitable_people_and_listings, less_suitable_people_and_listings = new_people_and_listings.partition {|person, listing| listing.incompatibility_messages_for_searcher(searcher).empty?}
    puts "SUITABLE PEOPLE:\n\n"
    suitable_people_and_listings.each do |person, listing|
      puts person.to_s
      puts
    end
    puts "\n\nLESS SUITABLE PEOPLE:\n\n"
    less_suitable_people_and_listings.each do |person, listing|
      puts person.to_s
      puts listing.incompatibility_messages_for_searcher(searcher).join("\n")
      puts
    end
  end

end
