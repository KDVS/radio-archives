# set :output, "/path/to/my/cron_log.log"
#

# Load supporting code and models
Dir[File.dirname(__FILE__) + '/../lib/*.rb'].each {|file| load file}
Dir[File.dirname(__FILE__) + '/../models/*.rb'].each {|file| load file}

def generate_cronjob(show)
  cron_timestamp = "#{show.start.min} #{show.start.hour} * * #{show.dotw}"

  command = "/home/christopher/proj/radio-archives/record-show.rb #{show.id}"
  [cron_timestamp, command]
end

Show.all.each do |s|
  cron_info = generate_cronjob(s)
  every cron_info[0] do
    command cron_info[1]
  end
end

