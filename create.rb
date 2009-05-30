require 'rubygems'
require 'win32ole'
require 'right_aws'
require 'ezcrypto'
require 'yaml'
require 'hpricot'
require 'firewatir'
require 'rand'
require 'fileutils'
require 'random_names'
require 'ip_tracker'

# this this song.. who's afraid of detroit (stanton warriors) claude vonstroke

CREATE_URL = "http://www.hotmail.com"
ACCOUNT_PASS = "janewayjaneway"
AWS_ACCESS_KEY_ID = '1GZFKYFWGM2WEAZFZ202'
AWS_SECRET_ACCESS_KEY = 'gcD9Y9FYrJ8XvJptCNVnjG+jdgT+ozLnaV+WHfoC'
AWS_SQS_CRYPTO_KEY = "Hikaru No Go"
AWS_CREATED_QUEUE = 'ms-created'

# prepare the cloud infrastructure 
$sqs_connection = RightAws::Sqs.new(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
$sqs_crypto_key = EzCrypto::Key.with_password("Hikaru No Go", "Ashbury & Frederick")
$created_queue  = $sqs_connection.queue(AWS_CREATED_QUEUE)

class BadDomainErr < Exception; end
class PageMissingErr < Exception; end  

class Cookies
  def self.delete(file= 'C:\Documents and Settings\Owner\Application Data\Mozilla\Firefox\Profiles\eejbh2sv.default\cookies.txt')
    FileUtils.rm file
  end
  
  def self.kill_browser
    `killall firefox-bin`
  end
end

def create_page_url html
  html.split('top.location = \'').last.split('\'').first
end

def sleep_until_browser_closed
  loop do
    sleep 2
    break unless firefox_running?
    puts $browser.url
    if $browser.url == "http://mail.live.com/?rru=inbox"
      $browser.close
    end
  end
end

def firefox_running?
  procs = WIN32OLE.connect("winmgmts:\\\\.")
  procs.InstancesOf("win32_process").each do |p|
    return true if p.name.to_s.downcase == "firefox.exe"
  end
  false
end

def create_accounts(domain="hotmail.com")
  # prepare the web browser
  raise BadDomainErr unless domain == "hotmail.com" || domain == "live.com"
  loop do
    check_ip
    if $ip_ok && $create_count < 2
      $browser = Watir::Browser.new
      identity = RandomIdentity.new
      $browser.goto CREATE_URL
      $browser.goto create_page_url($browser.html)
      $browser.select_lists[1].select domain
      $browser.text_field(:name, 'imembernamelive').value= (identity.login) ; sleep 1
      $browser.text_field(:name, 'iPwd').value = ACCOUNT_PASS
      $browser.text_field(:name, 'iRetypePwd').value= (ACCOUNT_PASS)
      $browser.text_field(:name, 'iAltEmail').value = (identity.email)
      $browser.text_field(:name, 'iFirstName').value = (identity.first_name)
      $browser.text_field(:name, 'iLastName').value = (identity.last_name)
      $browser.select_list(:name, 'iRegion').select(identity.state)
      $browser.text_field(:name, 'iZipCode').value = (identity.zip)
      $browser.text_field(:name, 'iBirthYear').value = (identity.birth_year)
      if identity.gender == 'male'
        $browser.radios[1].click
      else
        $browser.radios[2].click
      end
      sleep_until_browser_closed
      success_rec = {'login' => identity.login, 'pass' => ACCOUNT_PASS, 'domain' => domain}
      $created_queue.send_message($sqs_crypto_key.encrypt64(success_rec.to_yaml))
      Cookies.delete
      puts "created: #{success_rec['login']}/#{success_rec['domain']}"
      $create_count += 1
    else
      puts "."
      sleep 20
    end
  end
end

def check_ip
  ip = IpAddress.current_ip
  if ip != $current_ip
    if $ip_ok = IpAddress.use_ip(ip)
      puts "green ip: #{ip}"
      $create_count = 0
    else
      puts "unable to use ip: #{ip}"
    end
    $current_ip = ip
  end
end

$current_ip = IpAddress.current_ip
$ip_ok = IpAddress.use_ip($current_ip)
$create_count = 0
if rand(1) == 0
  a_type = "live.com"
else
  a_type = "hotmail.com"
end
create_accounts(a_type)