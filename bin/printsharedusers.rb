#!/bin/env ruby
# This method tries to find the number of users in a project that it shares
# with the wider repository

require 'find'
require 'yaml'

$repo = {}


def process_file(project, l)
  $repo[project.intern] ||= {}
  # get methods
  $repo[project.intern] = File.readlines(l).map(&:strip).select{|x| x.length > 0 }.map(&:to_sym)
end

def save_yaml
  len = %x[find committers | wc -l].strip.to_i
  STDERR.puts len
  Find.find('committers') do |l|
    case l
    when /committers.(.*)\.users$/
      project = $1
      process_file(project, l.chomp)
    end
    len -=1
    STDERR.puts len if len % 1000 == 0
  end
  STDERR.puts "saving"
  File.open("committers/committers.yaml",'w') do |f|
    f.puts $repo.to_yaml
  end
end

save_yaml
STDERR.puts "saved"
#$repo = YAML::load( File.open( 'methods/methods.yaml' ) )
STDERR.puts 'loaded'

$repo_users = {}
$proj_users = {}

$repo.keys.each do |proj|
  uarr = []
  #STDERR.puts '>' + proj.to_s
  $repo[proj].each do |u|
      $repo_users[u] ||= []
      $repo_users[u] << proj
      uarr << u
  end
  $proj_users[proj] = uarr
end

STDERR.puts 'process'

$repo.keys.each do |proj|
  # Get all methods shared such that there is one extra proj atleast after proj
  # i.e if we share it with another, there has to be atleast one another.
  arr1 = []
  arr2 = $proj_users[proj]
  $proj_users[proj].each do |user|
    arr1 << user if $repo_users[user].length > 2
  end
  arr1.uniq.sort{|a,b| a.to_s <=> b.to_s}.each do |a|
    puts "#{proj}\t#{a} : #{$repo_users[a].delete_if{|f| f == proj}.sort{|a,b| a.to_s <=> b.to_s}.uniq.join(' ')}"
  end
end
