#!/usr/bin/ruby
$: << "lib"
$: << "bin"
require 'simopts'
puts "rm -f sim.now"
puts "mkdir -p sim/dups/%s" % SimOpts.new.name
puts "ln -s sim/dups/%s sim.now" % SimOpts.new.name

