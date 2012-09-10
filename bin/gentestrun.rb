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

  def initialize(proj, alltests=false, test=nil)
    @proj = proj
    if alltests
      if File.exist? "coverage/update/#{proj}/@all"
        puts "coverage/update/#{proj}/@all"
      else
        doalltest(proj)
      end
      return
    end
    unless test.nil?
      dotest(test, proj)
      return
    end
    FindTests.new('src/' + proj).show.each do |t|
      next if File.exist? "coverage/update/#{proj}/#{t}"
      dotest(t, proj)
    end
  end
  def dotest(t, proj)
    y = t.chomp
    puts t
    puts "==================================="
    puts %[cd src/#{proj}; mvn -Dtest=#{y}  -DfailIfNoTests=false emma:emma]
    puts %x[cd src/#{proj}; mvn -Dtest=#{y}  -DfailIfNoTests=false emma:emma]
    runemma(t,proj)
  end
  def doalltest(proj)
    puts "==================================="
    puts %[cd src/#{proj}; mvn -DfailIfNoTests=false emma:emma]
    puts %x[cd src/#{proj}; mvn -DfailIfNoTests=false emma:emma]
    runemma('@all',proj)
  end

  def runemma(t,proj)
    puts %x[mkdir -p coverage/update/#{proj}]
    emmalst = findemma()
    emmalst.each do |cov|
      case cov
      when /(.*target.site.emma)$/
        emma = $1
        emmaname = emma.gsub("src/#{proj}/",'').gsub(/\//,'%')
        %x[mkdir -p coverage/update/#{proj}/#{t}/]
        puts %[cp -r #{emma} coverage/update/#{proj}/#{t}/#{emmaname}]
        puts "==================================="
        puts %x[cp -r #{emma} coverage/update/#{proj}/#{t}/#{emmaname}]
      end
    end
  end
end

case ARGV[0]
when /-all/
cov = File.open('coverage/cov.lst').readlines.each do |x|
  case x
  when /([^ ]+) +([^ ]+)/
    puts $1
  TestRun.new($1.chomp)
  end
end
when /-each/
  TestRun.new(ARGV[1].chomp.split('/')[1])
when /-one/
  TestRun.new(ARGV[1].chomp.split('/')[1], false, ARGV[2])
when /-chunk/
  TestRun.new(ARGV[1].chomp.split('/')[1], true)
else
  puts <<EOF
$0 -all | -each src/xxx | -chunk src/xxx | -one src/xxx test"
EOF
end
