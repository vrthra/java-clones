#!/usr/bin/env ruby

require 'rubygems'
require 'net/https'
require 'json'
require 'nokogiri'

$http = Net::HTTP.new('github.com', 443)
$http.use_ssl = true

def request(i, key)
  req = Net::HTTP::Get.new "/search?q=language%3Ajava+#{key}&repo=&langOverride=&start_value=#{i}&type=Repositories&language=Java"
  $http.request req do |res|
    page =  Nokogiri::HTML(res.body)
    page.css('div[class=results]').each do |p|
      p.css('h2[class=title]').css('a').each do |a|
        $last = a.attribute('href')
        yield $last
      end
    end
  end
end

$last = ''
def engine
  used = []
  d = %x[cat /usr/share/dict/words].split("\n").map(&:strip)
  key = ''
  while true do
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
