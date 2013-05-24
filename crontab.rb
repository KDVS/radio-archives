#!/usr/bin/env ruby

# Reads the database and outputs the corresponding crontab entries

require 'shellwords'

# Load supporting code and models
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file}

def generate_cronjob(show)
  cron_timestamp = "#{show.start.min} #{show.start.hour} * * #{show.dotw}"

  command = "#{cron_timestamp} record-show.rb #{show.id}"
  print command + "\n"
end

Show.all.each do |s|
  generate_cronjob(s)
end

