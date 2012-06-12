#! /usr/bin/env python

# Version 0.8
# Last updated: 2012-06-12

# Maintained by Christopher Thielen
# Python version originally by Scott Biggart
# Original Perl script by Christopher Thielen

import json
import urllib
import datetime
import re # to use re.escape(string)

url = "http://library.kdvs.org/ajax/streamingScheduleJSON"
stream_user_home = "/home/stream/"
this_script_path = stream_user_home + "setup_cron_rips.py"
this_script_output_path = stream_user_home + "crontab.streams"
archives_path = "/var/www/archives/"
podscript_path = "/usr/local/bin/podcast_add_episode.pl"
ficy_path = "/usr/local/bin/fIcy"
icecast_ip = "127.0.0.1"
icecast_port = "8000"
bitrates = {'32': '/kdvs32', '128': '/kdvs128', '192': '/kdvs192', '320': '/kdvs320'}
podcast_bitrate = '128'
extra_time = 5 #extra time to rip show (in min)
id3tool_path = "/usr/local/bin/id3tool"
mp3comment = "KDVS 90.3fm Davis, California"

#rsync constants
RSYNC_KEY = "/usr/local/etc/rsync-key"
ARCHIVE_HOST = "169.237.101.92"

def getId3toolCmd(show, mp3fname):
    "creates the command used to tag the mp3 with id3 info"
    id3tool_cmd = id3tool_path
    id3tool_cmd += ' -r "' + show['dj_names'] + '"'  #artist
    id3tool_cmd += ' -t "' + show['show_name'] + '"'  #title
    id3tool_cmd += ' -y ' + str(datetime.date.today().year)          #year
    id3tool_cmd += ' -n "' + mp3comment + '"'                    #note
    id3tool_cmd += ' "' + mp3fname + '"'
    return id3tool_cmd
    
def getFicyCmd(show, mp3fname, mount):
    "creates the command used to rip the mp3"
    length = ((int(show['end_hour']) - int(show['start_hour'])) * 60) + (int(show['end_min']) - int(show['start_min']))
    length_sec = (length * 60) + extra_time * 60
    ficy_cmd = ficy_path
    ficy_cmd += ' -d' #do not dump to stdout
    ficy_cmd += ' -s .mp3' #file suffix
    ficy_cmd += ' -o "' + mp3fname + '"' #filename
    ficy_cmd += ' -M ' + str(length_sec) #time to rip in seconds
    ficy_cmd += ' ' + icecast_ip + ' ' + icecast_port + ' ' + mount
    return ficy_cmd

def getMp3Fname(show, bitrate):
    "returns mp3 filename"
    fname = archives_path
    fname += '$(date +\%Y-\%m-\%d)' + '_' + str(show['show_id']) + '_' + str(bitrate) + 'kbps.mp3'
    return fname

def getPodcastCmd(show, bitrate):
    "get command to insert mp3 into podcast xml"
    length = ((int(show['end_hour']) - int(show['start_hour'])) * 60) + (int(show['end_min']) - int(show['start_min']))
    xmlfname = str(show['show_id']) + '.xml'
    podcast_cmd = podscript_path + ' "' + show['show_name'] + '" "' + show['dj_names']
    podcast_cmd += '" "' + getMp3Fname(show, bitrate) + '" ' + str(length + extra_time)
    return podcast_cmd

def getCronTime(show):
    "create time format for cron"
    cron_time = str(int(show['start_min'])) + ' ' + str(show['start_hour']) + ' '
    cron_time += '* * ' + str(show['dotw'])
    return cron_time


f = urllib.urlopen(url) #grab above url
json_txt = f.read() #read the json object that represents the current schedule
f.close()

obj = json.read(json_txt) #convert json to python dict (sweet!)
cron_commands = ""

for index, show in obj.iteritems(): #for each show on schedule
    for bitrate, mount in bitrates.iteritems(): # for each bitrate/mount to rip
        fname = getMp3Fname(show, bitrate)
        cron_time = getCronTime(show)
        ficy_cmd = getFicyCmd(show, fname, mount)
        id3tool_cmd = getId3toolCmd(show, fname)
        podcast_cmd = getPodcastCmd(show, bitrate)
        cron_commands += cron_time + ' ' + ficy_cmd + ' ; ' + id3tool_cmd + " \n"

#rsync commands
#cron_commands += str(extra_time + 1) + ' * * * * rsync -az -e "ssh -i ' + RSYNC_KEY + '" ' + archives_path + '* rsyncer@' + ARCHIVE_HOST + ':' + archives_path + "\n"
#cron_commands += str(30 + extra_time + 1) + ' * * * * rsync -az -e "ssh -i ' + RSYNC_KEY + '" ' + archives_path + '* rsyncer@' + ARCHIVE_HOST + ':' + archives_path + "\n"

#remove mp3's older than one month
# find 128 and 320  kbps files older than 31 days old
cron_commands += '0 0 * * * find ' + archives_path + ' -name "*128kbps.mp3" -mtime +31 -delete > /dev/null 2>&1' + " \n"
cron_commands += '0 0 * * * find ' + archives_path + ' -name "*320kbps.mp3" -mtime +31 -delete > /dev/null 2>&1' + " \n"
# find 32 and 192  kbps files older than 365 days old
cron_commands += '0 0 * * * find ' + archives_path + ' -name "*32kbps.mp3" -mtime +365 -delete > /dev/null 2>&1' + " \n"
cron_commands += '0 0 * * * find ' + archives_path + ' -name "*192kbps.mp3" -mtime +365 -delete > /dev/null 2>&1' + " \n"

#add cron commands to run this file (yay recursion) and then update cron with newly created commands
cron_commands += '0 0 * * * ' + this_script_path + ' ; ' + 'crontab ' + this_script_output_path + " \n"

#save cron commands in file
cron_file = open(this_script_output_path, 'w')
unicode = cron_commands.encode('utf-8')
cron_file.write(unicode)
#print cron_commands        
