#!/usr/bin/env ruby

SERVER = '172.16.2.5:20080'

require 'net/http'
require 'uri'
require 'json'

TIMESPAN = 3

def begin_time(hour)
  h = (hour / TIMESPAN) * TIMESPAN
  return format("%02d:%02d:%02d", h, 0, 0)
end

###########################################################
# main
###########################################################

t = Time.now
host = ARGV[0]

url = "http://#{SERVER}/olb-view.cgi"
url += "?acri=acri"
url += "&year=#{t.year}"
url += "&month=#{t.month}"
url += "&date=#{t.day}"
url += "&host=#{host}"

res = Net::HTTP.get(URI.parse(url))
contents = JSON.parse(res.strip)
user = contents[begin_time(t.hour)]
print user unless user.nil?
