require 'rubygems'
require 'tinder'
require 'open-uri'
require 'json'
require 'cgi'

class Twitter2Campfire
  attr_accessor :room, :query, :cachefile, :campfire, :options
  
  SITE = "http://search.twitter.com/search.json?q="

  def initialize(query, config_file = nil, cachefile = 'archived_latest.txt', options = {})
    config_file ||= File.join(File.dirname(__FILE__), "config/campfire.yml")
    self.query = query
    self.cachefile = cachefile
    self.options = options

    config = YAML.load_file(config_file)
    account = config["subdomain"]
    token = config["token"]
    room_name = config["room"]

    self.campfire = Tinder::Campfire.new account,
      :token => token,
      :ssl => true

    self.room = campfire.find_room_by_name room_name
  end
  
  def entries
    url = SITE + url_encode(query)
    buffer = open(url, "User-Agent" => "your_domain_name.com").read
    results = JSON.parse(buffer)
    results["results"]    
  end
  
  def latest_tweet
    entries.first
  end
  
  def save_latest
    # overwrite it with just the latest id_str
    File.open(cachefile, 'w') do |f|
      f.write(latest_tweet["id_str"])
    end
  end
  
  def archived_id_str
    archive_file.strip
  end
  
  def archive_file
    begin
      return File.read(cachefile)
    #rescue
    #  ''
    end
  end
  
  def posts
    entries.select { |e| e["id_str"] > archived_id_str }
  end
  
  def publish_entries(to_campfire = true)
    posts.reverse.each do |post|
      if to_campfire
        room.tweet "https://twitter.com/#{post['from_user']}/statuses/#{post['id_str']}"
      else
        puts "https://twitter.com/#{post['from_user']}/statuses/#{post['id_str']}"
      end
    end
    save_latest
  end

  def url_encode(plaintext)
    CGI.escape(plaintext.to_s).gsub('+', '%20')#.gsub('%7E', '~')
  end
end
