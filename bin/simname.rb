#!/usr/bin/ruby
require 'lib/simopts'
puts "rm sim.now"
puts "ln -s %s sim.now" % SimOpts.new.name

