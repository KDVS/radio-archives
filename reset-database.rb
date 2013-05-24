#!/usr/bin/env ruby

require 'json'
require 'net/http'

# Load supporting code and models
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file}

## Parameters

# The URL of the schedule in the documented JSON format (see README)
schedule_url = "http://library.kdvs.org/ajax/streamingScheduleJSON"
# An optional blocklist of show titles not to archive
show_blocklist = ["Joe Frank", "Democracy Now: The War & Peace Report", "Free Speech Radio News"]

# Ensures the necessary command-line tools are installed
def check_requirements
  # fIcy is used to rip the stream
  if which('fIcy') == nil
    puts "You do not appear to have fIcy installed. Please correct this."
    puts "A copy of fIcy is located in the tools/ directory of this script's source distribution."
    abort
  end
  # fResync is recommended by fIcy before tagging
  if which('fResync') == nil
    puts "You do not appear to have fResync installed. Please correct this."
    puts "A copy of fResync (included with fIcy) is located in the tools/ directory of this script's source distribution."
    abort
  end
  # id3tool is used to tag the MP3s
  if which('id3tool') == nil
    puts "You do not appear to have id3tool installed. Please correct this."
    puts "A copy of id3tool is located in the tools/ directory of this script's source distribution."
    abort
  end
end


# Adds show to database
def register_show(show)
  s = Show.new
  s.artist = show["dj_names"].nil? ? "Unspecified" : show["dj_names"]
  s.title = show["show_name"].nil? ? "Untitled" : show["show_name"]
  s.save
  puts s.title
  return s
end

## Main script body

check_requirements

# Fetch the schedule
puts "Downloading schedule..."
resp = Net::HTTP.get_response(URI.parse(schedule_url))
data = resp.body

schedule = JSON.parse(data)

puts "Parsing schedule and adding to database..."
# Parse the schedule, generating the cron jobs
schedule.each do |entry|
  id = entry[0]
  show = entry[1]

  # Avoid shows in the optional blocklist
  unless show_blocklist.include? show["show_name"]
    s = register_show(show)
  end
end
