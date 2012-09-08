#!/usr/bin/ruby
# This is to be run exclusively if we get time.

$:.push 'lib'
require 'findtests'
require 'find'

$pwd=%x[pwd].chomp
class TestRun
  def findemma()
    cov = []
    Find.find('src/' + @proj) do |f|
      case f
      when /coverage.xml/
        cov << File.dirname(f.chomp).gsub($pwd,'')
      end
    end
    return cov
  end

  def initialize(proj)
    @proj = proj
    FindTests.new('src/' + proj).show.each do |t|
      next if File.exist? "cov.update/#{proj}/#{t}"
      y = t.chomp
      puts t
      puts "==================================="
      puts %[cd src/#{proj}; mvn -Dtest=#{y}  -DfailIfNoTests=false emma:emma]
      puts %x[cd src/#{proj}; mvn -Dtest=#{y}  -DfailIfNoTests=false emma:emma]
      puts %x[mkdir -p cov.update/#{proj}]
      emmalst = findemma()
      emmalst.each do |cov|
        case cov
        when /(.*target.site.emma)$/
          emma = $1
          emmaname = emma.gsub("src/#{proj}/",'').gsub(/\//,'%')
          %x[mkdir -p cov.update/#{proj}/#{t}/]
          puts %[cp -r #{emma} cov.update/#{proj}/#{t}/#{emmaname}]
          puts "==================================="
          puts %x[cp -r #{emma} cov.update/#{proj}/#{t}/#{emmaname}]
        end
      end
    end
  end
end

cov = File.open('cov.lst').readlines.each do |x|
  case x
  when /([^ ]+) +([^ ]+)/
    puts $1
  TestRun.new($1.chomp)
  end
end
