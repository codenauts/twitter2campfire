CACHE_FILE = 'archived_latest.txt'
OPTIONS = {} # not supported yet

require 'twitter2campfire'

t = Twitter2Campfire.new "your search query here", nil, CACHE_FILE, OPTIONS
t.publish_entries
