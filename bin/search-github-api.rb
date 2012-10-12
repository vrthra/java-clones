#!/usr/bin/env ruby

require 'rubygems'
require 'net/https'
require 'json'

$http = Net::HTTP.new('api.github.com', 443)
$http.use_ssl = true

def request(i, key)
  req = Net::HTTP::Get.new "/legacy/repos/search/:keyword?keyword=#{key}&start_page=#{i}&language=Java"
  $http.request req do |res|
    j = JSON.parse(res.body)
    return if j['repositories'].length ==0
    $last = j['repositories'][0]['name']
    j['repositories'].each do |r|
      result = "#{r['owner']}/#{r['name']} #{r['language']}"
      yield result
    end
  end
end

$last = ''
def engine
  used = []
  d = %x[cat /usr/share/dict/words].split("\n").map(&:strip)
  while true do
    key = ''
    while true do
       key = d.choice
       break if !used.include? key
    end
    used << key
    mylast = ''
    catch :next do
      (1..100).each do |i|
        STDERR.puts "#{key}#{i}"
        request(i,key) do |res|
          puts res
        end
        if mylast == $last
          STDERR.puts "i over"
          throw :next
        end
        mylast = $last
        STDERR.puts $last
      end
    end
    STDERR.puts "starting next key."
  end
end

engine
