#!/usr/bin/env ruby

# update-archives.rb: Creates or updates the cron jobs which generate/maintain the archives
#
# Version 0.1 (2012-06-17)
# Written by Christopher Thielen (cthielen@gmail.com)

# Requirements:
#     This script requires a number of command line utilities, included in the source distribution
#     for sanity: fIcy (for ripping the stream), id3tool (for tagging the rips)

require 'json'
require 'net/http'
require 'pp'

## Parameters

# The URL of the schedule in the documented JSON format (see README)
schedule_url = "http://library.kdvs.org/ajax/streamingScheduleJSON"
# Streaming URL to rip
stream_url = "http://127.0.0.1:8000/kdvs192"
# An optional blocklist of show titles not to archive
show_blocklist = ["Joe Frank", "Democracy Now: The War & Peace Report", "Free Speech Radio News"]

# Ensures the necessary command-line tools are installed
def check_requirements

end

# Generates the cronjobs necessary to archive the given show
def generate_cronjob(show)
  dj_names = show["dj_names"].nil? ? "Unspecified" : show["dj_names"]
  show_name = show["show_name"].nil? ? "Untitled" : show["show_name"]

  filename = dj_names + " - " + show_name + " (Monday, July 23, 2012).mp3"

  pp filename
end



## Main script body

check_requirements

# Fetch the schedule
resp = Net::HTTP.get_response(URI.parse(schedule_url))
data = resp.body

schedule = JSON.parse(data)

# Parse the schedule, generating the cron jobs
schedule.each do |entry|
  id = entry[0]
  show = entry[1]

  # Avoid shows in the optional blocklist
  unless show_blocklist.include? show["show_name"]
    generate_cronjob(show)
  end
end

# Cross-platform way of finding an executable in the $PATH.
# (Taken from http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby)
#
#   which('ruby') #=> /usr/bin/ruby
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = "#{path}/#{cmd}#{ext}"
      return exe if File.executable? exe
    }
  end
  return nil
end
