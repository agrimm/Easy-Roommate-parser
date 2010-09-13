$:.push File.expand_path(File.dirname(__FILE__) + '/../lib')

require "yaml"
require "easyroommate_parser"

if __FILE__ == $0
  abort "#{__FILE__} search_page.html notes.rtf" if ARGV.length < 2
  easyroommate_parser = EasyroommateParser.new_using_filenames(ARGV[0], ARGV[1])
  easyroommate_parser.display_new_people
  easyroommate_parser.display_undownloaded_people
  easyroommate_parser.export_undownloaded_people
  easyroommate_parser.exit_if_people_undownloaded
  easyroommate_parser.display_suitability_of_new_people
end
