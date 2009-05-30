require 'rubygems'
require 'mechanize'
require 'sqlite3'

class IpAddress 
  @db = SQLite3::Database.new("ip.db")
  HOURS_TO_WAIT = 24

  def self.use_ip(ip_address=current_ip)
    begin
      rows = @db.execute "select * from ips where ip = '#{ip_address}'"
    rescue SQLite3::SQLException
      create_table
      retry
    end
    ip_info = rows.last
    if ip_info
      return false unless enough_time_has_passed?(ip_info.last)
    else
      @db.execute "insert into ips values ('#{ip_address}', '#{Time.now}');"
    end
    true
  end
  
  def self.current_ip
    begin
      new_mech_agent.get('http://www.whatismyip.com').links[3].text
    rescue Exception
      sleep 5
      retry
    end
  end

protected
  def self.create_table
    @db.execute 'create table ips (ip varchar, last_used_at datetime);'
  end
  
  def self.new_mech_agent
    agent = WWW::Mechanize.new
    agent.user_agent_alias = 'Windows IE 6'
    agent.redirect_ok = true
    agent.max_history = 0
    agent.set_proxy('web-rentals.com', 8888)
    agent
  end

  def self.enough_time_has_passed?(last_used_at)
    ((Time.parse(last_used_at) + (60 * 60 * HOURS_TO_WAIT)) - Time.now) < 0
  end
end


