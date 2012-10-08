#!/bin/env ruby
# gets a count of total number of methos it shares with the whole project.
# not used.

all={}

File.readlines("methods.cmp").each do |l|
  case l
  when /.*<$/
    ll  = l.split(" ")
    v1 = ll[1]
    v2 = ll[2]
    all[v1] = 0 if all[v1].nil?
    all[v2] = 0 if all[v2].nil?
    all[v1] += ll[0].to_i
    all[v2] += ll[0].to_i
  end
end

all.keys.sort.each do |k|
  puts "#{k} #{all[k]}"
end
