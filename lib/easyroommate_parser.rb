$:.push File.expand_path(File.dirname(__FILE__) + '/easyroommate_parser')
require "person"
require "result_parser"
require "notes_parser"
require "nokogiri"

class EasyroommateParser
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
  end

  def display_new_people
    new_people = @notes_parser.reject_existing_people(@result_parser.people)
    puts "People so far not listed\n\n"
    puts new_people.join("\n")
  end
end
