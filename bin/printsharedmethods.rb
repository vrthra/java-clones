#!/bin/env ruby
# This method tries to find the number of methods in a project that it shares
# with the wider repository

require 'find'
require 'yaml'

$repo = {}


def process_java_file(project, java, l)
  $repo[project.intern] ||= {}
  # get methods
  $repo[project.intern][java] = File.readlines(l).map(&:strip).select{|x| x.length > 0 }.map(&:to_sym)
end

def save_yaml
  len = %x[find methods | wc -l].strip.to_i
  STDERR.puts len
  Find.find('methods') do |l|
    case l[8..-1]
    when /(.*)\/(.*)\.java\.method$/
      project = $1
      java = $2
      next if File.exists?("src/#{project}/.duplicate")
      process_java_file(project, java, l.chomp)
    end
    len -=1
    STDERR.puts len if len % 1000 == 0
  end
  STDERR.puts "saving"
  File.open("methods/methods.yaml",'w') do |f|
    f.puts $repo.to_yaml
  end
end

save_yaml
STDERR.puts "saved"
#$repo = YAML::load( File.open( 'methods/methods.yaml' ) )
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
  # Get all methods shared such that there is one extra proj atleast after proj
  # i.e if we share it with another, there has to be atleast one another.
  arr1 = []
  arr2 = $proj_methods[proj]
  $proj_methods[proj].each do |method|
    arr1 << method if $repo_methods[method].keys.length > 2
  end
  arr1.uniq.sort{|a,b| a.to_s <=> b.to_s}.each do |a|
    puts "#{proj}\t#{a} : #{$repo_methods[a].keys.delete_if{|f| f == proj}.join(' ')}"
  end
end
