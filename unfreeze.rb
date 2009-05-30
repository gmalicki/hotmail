require 'rubygems'
require 'right_aws'
require 'ezcrypto'
require 'yaml'
require 'hpricot'
require 'watir'
require 'rand'
require 'fileutils'
require 'random_names'

LOGIN_URL = "http://www.hotmail.com"
AWS_ACCESS_KEY_ID = '1GZFKYFWGM2WEAZFZ202'
AWS_SECRET_ACCESS_KEY = 'gcD9Y9FYrJ8XvJptCNVnjG+jdgT+ozLnaV+WHfoC'
AWS_SQS_CRYPTO_KEY = "Hikaru No Go"
AWS_FROZEN_QUEUE = 'ms-agent-frozen'
AWS_UNFROZEN_QUEUE = 'ms-agent-unfrozen'

# prepare the cloud infrastructure 
$sqs_connection = RightAws::Sqs.new(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
$sqs_crypto_key = EzCrypto::Key.with_password("Hikaru No Go", "Ashbury & Frederick")
$frozen_queue  = $sqs_connection.queue(AWS_FROZEN_QUEUE)
$unfrozen_queue = $sqs_connection.queue(AWS_UNFROZEN_QUEUE)

class BadDomainErr < Exception; end
class PageMissingErr < Exception; end  

class Cookies
  def self.delete(file= "/Users/gabrielmalicki/Library/Application Support/Firefox/Profiles/w6vskww9.default/cookies.txt")
    FileUtils.rm file
  rescue Exception
  end
  
  def self.kill_browser
    `killall firefox-bin`
  end
end

def login(email, pass)
  $browser.goto LOGIN_URL
  $browser.text_field(:name => 'login').set(email)
  $browser.text_field(:name => 'passwd').set(pass)
  $browser.button(:id => 'idSIButton9').click
rescue Exception => e
  puts "caught login exception #{e.inspect}"
end

def sleep_until_browser_closed
  loop do
    sleep 2
    break unless `ps aux` =~ /firefox-bin/
  end
end

def next_frozen
  YAML.load($sqs_crypto_key.decrypt64($frozen_queue.pop.to_s).to_s)
rescue
  nil
end

def mark_unfrozen(email, pass)
  $unfrozen_queue.send_message($sqs_crypto_key.encrypt64([email].to_yaml))
end


Cookies.delete
while account = next_frozen
  $browser = Watir::Browser.new
  login(*account)
  sleep_until_browser_closed
  mark_unfrozen(*account)
  Cookies.delete
end