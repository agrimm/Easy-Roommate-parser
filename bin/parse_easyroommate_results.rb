$:.push File.expand_path(File.dirname(__FILE__) + '/../lib')

require "person"
require "result_parser"
require "nokogiri"

if __FILE__ == $0
  result_parser = ResultParser.new(File.open(ARGV[0]))
  puts result_parser.people.join("\n")
end
