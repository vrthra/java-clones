#!/bin/env ruby
#
# Tries to find suitable tests from other projects.

require 'find'

$repo = {}

class RecommendTests
  def initialize(src)
    @src = case src
           when /src\//
             src[4..-1]
           else
             src
           end
    shared = File.readlines('methods_sharedby_projects.txt').map{|l| l.strip}
    @myshared = shared.find_all{|l| l =~ /^#{@src}/}
  end

  def run
    $repo[@src] = {}
    Find.find("methods/#{@src}/") do |j|
      recfile = "recommendations/#{@src}.rec"
      next if j =~ /\/$/
      #if File.exists?(recfile)
      #  return File.readlines(recfile).map(&:chomp)
      #end
      ls = []
      java = j.split('/')[2].gsub('.method','')
      lines = File.readlines(j).map(&:strip).delete_if{|l| l=~ /^[\t ]*$/}
      next if lines.length == 0
      mylines = lines.map{|l| l.split("\t")[0]}.delete_if{|f| f =~ /^[\t ]*$/}.sort.uniq
      #puts "> #{java.gsub('.method','')}"
      ls << "> #{java}"
      mylines.each do |m|
        $repo[@src][java + ":" + m] ||= []
        # are we covering it in our own test case?
        s = %x[grep '^#{m}$' testcalls/#{@src}/* 2>/dev/null].split("\n").delete_if{|l| l=~ /^[\t ]*$/}
        if s.length > 0
          #puts "\t#{m} UnitTest: #{s.map{|x|x.split('/')[2]}}"
          ls << "\t#{m} UnitTest: #{s.map{|x|x.split('/')[2]}}"
        else
          #puts ">>\t#{m}"
          ls << ">>\t#{m}"
          lns = @myshared.find_all{|f| f =~ /^#{@src}\t#{m}/ }.sort.uniq
          lns.each do |ll|
            ll.split(':')[1].strip().split(" ").each do |project|
              # now this project also contains that method. So let us
              # see if that project has a test case that covers it.
              s = %x[grep '^#{m}$' testcalls/#{project}/* 2>/dev/null].split("\n").delete_if{|l| l=~ /^[\t ]*$/}
              if s.length > 0
                #puts "- \t\t#{project}"
                STDERR.puts "#{@src}\t#{java}\t#{m}\t#{project}#{s.map{|x| x.split('/')[2]}.join(",")}"
                ls << "- \t\t#{project}"
                s.each do |ss|
                  sss = ss.split('/')[2]
                  #puts "  \t\t\t#{sss}"
                  ls << "  \t\t\t#{sss}"
                  $repo[@src][java.gsub('.method','') + ":" + m] << "#{project}:#{sss}"
                end
              else
                #puts "  \t\t#{project}"
                ls << "  \t\t#{project}"
              end
            end
          end
        end
      end
      #File.open(recfile, 'w') do |fd|
      #  fd.puts ls.join("\n")
      #end
    end
  end

end
File.readlines("names/cov.best_least").each do |l|
  STDERR.puts l.strip
  r = RecommendTests.new(l.strip)
  r.run
end
#$repo.each do |k,v|
#  STDERR.puts k
#  v.each do |k1,v1|
#    puts "#{k}\t#{k1}\t#{v1.join(' ')}"
#  end
#end

