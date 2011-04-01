CACHE_FILE = 'archived_latest.txt'
OPTIONS = {} # not supported yet

require 'twitter2campfire'

t = Twitter2Campfire.new "your search query here", nil, CACHE_FILE, OPTIONS
# call t.publish_entries(false) instead to test output to console instead of campfire for testing
t.publish_entries
