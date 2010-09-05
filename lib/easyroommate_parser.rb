$:.push File.expand_path(File.dirname(__FILE__) + '/easyroommate_parser')
require "person"
require "result_parser"
require "notes_parser"
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
    raise "File #{UNDOWNLOADED_PEOPLE_FILENAME} already exists" if File.exist?(UNDOWNLOADED_PEOPLE_FILENAME)
    filenames_and_urls = @undownloaded_people.map do |person|
      {:filename => person.download_filename, :url=> person.url}
    end
    File.open(UNDOWNLOADED_PEOPLE_FILENAME, "w") do |undownloaded_people_file|
      YAML.dump(filenames_and_urls, undownloaded_people_file)
    end
  end
end
