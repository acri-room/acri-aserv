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

table = {}

t = Time.now + 30*60

puts "Date: #{t.year}/#{t.month}/#{t.day}"

["as001", "as002", "as003", "as004", "ag001"].each do |host|
  url = "http://#{SERVER}/olb-view.cgi"
  url += "?acri=acri"
  url += "&year=#{t.year}"
  url += "&month=#{t.month}"
  url += "&date=#{t.day}"
  url += "&host=#{host}"
  res = Net::HTTP.get(URI.parse(url))
  printf "%s ", host
  puts res
end
