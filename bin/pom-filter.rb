#!/bin/env ruby

require 'rubygems'
require 'json'
require 'net/https'


File.readlines(ARGV[0]).each do |l|
  author,repo = l.gsub('/', ' ').strip.split(' ')
  http = Net::HTTP.new("github.com",443)
  http.use_ssl = true
  http.start do |h|
    response = h.get("/#{author}/#{repo}")
    if response.body.to_s =~ /pom.xml/
      puts l.strip
      STDOUT.flush
      STDERR.puts l.strip
    else
      STDERR.puts "\t No Pom in #{l.strip}"
    end
  end
end

