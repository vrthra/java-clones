#!/bin/env ruby
# This method tries to find the number of methods in a project that it shares
# with the wider repository : use it to load into R.

require 'find'
require 'yaml'

$repo = YAML::load( File.open( 'methods/methods.yaml' ) )
STDERR.puts 'loaded'

$repo_methods = {}
$proj_methods = {}

$repo.keys.each do |proj|
  marr = []
  STDERR.puts '>' + proj.to_s
  $repo[proj].keys.each do |j|
    $repo[proj][j].each do |m|
      $repo_methods[m] ||= {}
      $repo_methods[m][proj] = {}
      marr << m
    end
  end
  $proj_methods[proj] = marr
end

STDERR.puts 'process'

$repo.keys.each do |proj|
  STDERR.puts proj
  # Get all methods shared such that there is one extra proj atleast after proj
  # i.e if we share it with another, there has to be atleast one another.
  arr1 = []
  arr2 = $proj_methods[proj]
  $proj_methods[proj].each do |method|
    arr1 << method if $repo_methods[method].keys.length > 2
  end
  puts "#{proj} #{arr1.length} #{arr2.length} #{arr1.length*100.0/(arr2.length+1)}"
end
