#!/usr/bin/ruby
$:.push 'bin'
require 'findtests'
require 'find'

class TestRun
  def findemma()
    cov = []
    Find.find('src/' + @proj) do |f|
      case f
      when /coverage.xml/
        cov << File.dirname(f.chomp)
      end
    end
    return cov
  end

  def initialize(proj)
    @proj = proj
    emmalst = findemma()
    FindTests.new('src/' + proj).show.each do |t|
      y = t.chomp
      puts t
      unless File.exist? "cov.all/#{proj}"
        puts "==================================="
        puts %[cd src/#{proj}; mvn -Dtest=#{y}  -DfailIfNoTests=false emma:emma]
        puts %x[cd src/#{proj}; mvn -Dtest=#{y}  -DfailIfNoTests=false emma:emma]
        puts %x[mkdir -p cov.all/#{proj}]
      end
      puts %[cp -r #{emma} cov.all/#{proj}/#{y}]
      emma = findemma()
      puts "==================================="
      puts %x[cp -r #{emma} cov.all/#{proj}/#{y}]
    end
  end
end
