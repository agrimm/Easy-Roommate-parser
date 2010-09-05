$:.push File.expand_path(File.dirname(__FILE__) + '/../lib')

require "yaml"
require "easyroommate_parser"
require "mechanize"

class ListingDownloader
  ACCOUNT_FILENAME = "config/account.yml"

  def self.new_using_yaml_filename(yaml_filename)
    download_tasks = YAML.load_file(yaml_filename)
    abort "You need to set up #{ACCOUNT_FILENAME}" unless File.exist?(ACCOUNT_FILENAME)
    account_configuration = YAML.load_file(ACCOUNT_FILENAME)
    new(download_tasks, account_configuration)
  end

  def initialize(download_tasks, account_configuration)
    @download_tasks = download_tasks
    @account_configuration = account_configuration
  end

  def run
    agent = create_agent_and_log_in
    @download_tasks.each do |download_task|
      url, filename = download_task.values_at(:url, :filename)
      with_pauses(5) do
        raise "#{filename} already exists" if File.exist?(filename)
        agent.get(url)
        agent.page.save_as(filename)
        puts "downloaded " + url + " at #{Time.now}" + "\n"
      end
    end
  end

  def create_agent_and_log_in
    agent = Mechanize.new
    agent.get("http://au.easyroommate.com")
    form = agent.page.forms.first
    form.txtemail = @account_configuration.fetch("txtemail")
    form.txtpassword = @account_configuration.fetch("txtpassword")
    form.submit

    agent
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
