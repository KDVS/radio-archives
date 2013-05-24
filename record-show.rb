#!/usr/bin/env ruby

require 'shellwords'

# Records a single show
HOST = "169.237.101.239"
PORT = 8000
PATH = "/kdvs192"

# Load supporting code and models
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file}
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file}

unless ARGV.length == 2
  puts "Usage: record-show.rb <show-id> <duration-in-mins>\n"
  exit
end

s = Show.find_by_id(ARGV[0])
r = Recording.new
r.show = s
r.started = Time.now
duration = ARGV[1]
r.title = Time.now.strftime("%A %B %d, %Y")
filename = "#{s.artist} - #{s.title} (#{r.title}).mp3"

# Record the show
`#{which('fIcy')} -M #{duration}m -o "/tmp/#{filename}" -d #{HOST} #{PORT} #{PATH}`

# Write metadata
`#{which('id3tool')} -t #{Shellwords.escape r.title} -a #{Shellwords.escape s.title} -r #{Shellwords.escape s.artist} -y #{Time.now.year} -g #{Shellwords.escape s.genre} /tmp/#{Shellwords.escape filename}`

r.finished = Time.now

# Ensure recordings directory exists
`mkdir -p ~/Music/radio-archives`
`mv /tmp/#{Shellwords.escape filename} ~/Music/radio-archives/`

r.filename = "~/Music/radio-archives/#{filename}"
r.save

