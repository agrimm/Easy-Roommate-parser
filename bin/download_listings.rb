$:.push File.expand_path(File.dirname(__FILE__) + '/../lib')

require "yaml"
require "easyroommate_parser"

class ListingDownloader
  def self.new_using_yaml_filename(yaml_filename)
    download_tasks = YAML.load_file(yaml_filename)
    new(download_tasks)
  end

  def initialize(download_tasks)
    @download_tasks = download_tasks
  end

  def run
    @download_tasks.each do |download_task|
      url, filename = download_task.values_at(:url, :filename)
      with_pauses(5) do
        raise "#{filename} already exists" if File.exist?(filename)
        File.open(filename, "wb") do |output_file|
          raise NotImplementedError, "Insert mechanize code here"
        end
        STDERR.puts "downloaded " + url + "\n"
      end
    end
  end

  def with_pauses(time)
    sleep time
    yield
  end
end

if __FILE__ == $0
  listing_downloader = ListingDownloader.new_using_yaml_filename(EasyroommateParser::UNDOWNLOADED_PEOPLE_FILENAME)
  listing_downloader.run
end
