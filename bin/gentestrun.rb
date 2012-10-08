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

  def x(v)
    puts v
    %x[#{v}]
  end

  def initialize(proj, alltests=false, test=nil)
    @proj = proj
    if alltests
      if File.exist? "coverage/update/#{proj}/@all" and ENV['overwrite'] != 'yes'
        puts "coverage/update/#{proj}/@all"
      else
        doalltest(proj)
      end
      return
    end
    x %[mkdir -p testrun/#{proj}]
    unless test.nil?
      dotest(test.strip, proj)
      return
    end
    FindTests.new('src/' + proj).show.each do |t|
      next if File.exist? "coverage/update/#{proj}/#{t}" and ENV['overwrite'] != 'yes'
      dotest(t.strip, proj)
    end
  end
  def dotest(t, proj)
    y = t.chomp
    puts y
    puts "==================================="
    x %[(cd src/#{proj}; ../../bin/checkrun -t 3000 mvn -Dtest=#{y}  -DfailIfNoTests=false emma:emma) | ./bin/ub > ./testrun/#{proj}/#{y}.build.out]
    runemma(y,proj)
  end
  def doalltest(proj)
    puts "==================================="
    x %[(cd src/#{proj}; mvn clean; ../../bin/checkrun -t 3000 mvn -DfailIfNoTests=false emma:emma) | ./bin/ub > ./testrun/#{proj}.build.out]
    runemma('@all',proj)
  end

  def runemma(t,proj)
    x %[mkdir -p coverage/update/#{proj};]
    emmalst = findemma()
    x %[mkdir -p coverage/update/#{proj}/#{t}/;]
    emmalst.each do |cov|
      case cov
      when /(.*target.site.emma)$/
        emma = $1
        emmaname = emma.gsub("src/#{proj}/",'').gsub(/\//,'%')
        puts %[cp -r #{emma} coverage/update/#{proj}/#{t}/#{emmaname}]
        puts "==================================="
        x %[cp -r #{emma} coverage/update/#{proj}/#{t}/#{emmaname}]
      end
    end
  end
end

case ARGV[0]
when /-all/
cov = File.open('names/cov.best_least').readlines.each do |x|
  #case x
  #when /([^ ]+) +([^ ]+)/
  #  puts $1
  # TestRun.new($1.chomp,true)
  # end
  puts x
  TestRun.new(x.chomp,true)
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
