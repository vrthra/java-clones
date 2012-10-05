#!/bin/env ruby

lines = []
method = ''
File.readlines(ARGV[0]).each do |x|
  case x
  when /^.etDescription/
  when /^.etName/
  when /^toString/
  when /^main\t/
  when /^close\t/
  when /^run\t/
  when /^get/
  when /^set/
  when /^ *$/
  when /^hashCode/
  when /^equals/
  when /^initialize\t/
  when /^=+$/
    if lines.length >= 1
      puts "----------------------"
      puts method.strip + "\t" + lines.length.to_s
      puts lines
    end
  when /^methods\//
    method = x
    lines = []
  else
    lines << x
  end
end

