require 'open-uri'

class RandomIdentity
  STATES = [
      [ "Alabama", "AL" ], 
      [ "Alaska", "AK" ], 
      [ "Arizona", "AZ" ], 
      [ "Arkansas", "AR" ], 
      [ "California", "CA" ], 
      [ "Colorado", "CO" ], 
      [ "Connecticut", "CT" ], 
      [ "Delaware", "DE" ], 
      [ "District Of Columbia", "DC" ], 
      [ "Florida", "FL" ], 
      [ "Georgia", "GA" ], 
      [ "Hawaii", "HI" ], 
      [ "Idaho", "ID" ], 
      [ "Illinois", "IL" ], 
      [ "Indiana", "IN" ], 
      [ "Iowa", "IA" ], 
      [ "Kansas", "KS" ], 
      [ "Kentucky", "KY" ], 
      [ "Louisiana", "LA" ], 
      [ "Maine", "ME" ], 
      [ "Maryland", "MD" ], 
      [ "Massachusetts", "MA" ], 
      [ "Michigan", "MI" ], 
      [ "Minnesota", "MN" ], 
      [ "Mississippi", "MS" ], 
      [ "Missouri", "MO" ], 
      [ "Montana", "MT" ], 
      [ "Nebraska", "NE" ], 
      [ "Nevada", "NV" ], 
      [ "New Hampshire", "NH" ], 
      [ "New Jersey", "NJ" ], 
      [ "New Mexico", "NM" ], 
      [ "New York", "NY" ], 
      [ "North Carolina", "NC" ], 
      [ "North Dakota", "ND" ], 
      [ "Ohio", "OH" ], 
      [ "Oklahoma", "OK" ], 
      [ "Oregon", "OR" ], 
      [ "Pennsylvania", "PA" ], 
      [ "Rhode Island", "RI" ], 
      [ "South Carolina", "SC" ], 
      [ "South Dakota", "SD" ], 
      [ "Tennessee", "TN" ], 
      [ "Texas", "TX" ], 
      [ "Utah", "UT" ], 
      [ "Vermont", "VT" ], 
      [ "Virginia", "VA" ], 
      [ "Washington", "WA" ], 
      [ "West Virginia", "WV" ], 
      [ "Wisconsin", "WI" ], 
      [ "Wyoming", "WY" ]
    ]
  FEMALE_URL = "http://www.fakenamegenerator.com/index.php?gen=female&n=us&c=us"
  MALE_URL   = "http://www.fakenamegenerator.com/index.php?gen=male&n=us&c=us"
  
  attr_reader :full_name, :first_name, :last_name, :city, :state_abbr, :zip, :gender
    
  def initialize(gender=nil)
    @gender = gender
    if @gender.nil?
      @gender = rand(2) == 0 ? 'male' : 'female'
    end
    populate_from_internets
  end
  
  def state
    STATES.detect { |name, abbr| abbr == state_abbr }.first
  end
  
  def login
    if @login
      return @login
    end
    case rand(5)
    when 0 : @login = full_name.gsub('.','').gsub(' ', '') + "#{rand(999)}"
    when 1 : @login = first_name.slice(0,1) + last_name + "#{rand(9999)}"
    when 2 : @login = first_name + last_name + "#{rand(99999)}"
    when 3 : @login = first_name + last_name.slice(0,1) + "#{rand(9999)}"
    when 4 : @login = last_name + "#{rand(99999)}"
    end   
  end
  
  def birth_year
    (1950 + rand(34)).to_s
  end
  
  def email
    login + "@yahoo.com"
  end
protected
  def populate_from_internets
    if gender == "male"
      url = MALE_URL
    else
      url = FEMALE_URL
    end
    open(url) do |f|
      html = f.read
      tagline = html.split("<td><p>").last.split("Website").first
      @full_name = tagline.split('<b').first
      @first_name = @full_name.split(' ').first
      @last_name = @full_name.split(' ').last
      @city = tagline.split('<br />').last.split(',').first
      @state_abbr = tagline.split('<br />').last.split(', ').last.split(" ").first
      @zip = tagline.split('<br />').last.split(' ').last
    end
  end
end