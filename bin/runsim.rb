#!/usr/bin/ruby
$:.push "lib"
require 'simopts'
require 'rubygems'
require 'popen4'


class Sim
  def initialize(lst)
    s = SimOpts.new
    @simian='./lib/jars/simian-2.3.33.jar'
    @simopts = s.opts
    @javaopts="-Xss16m -Xmx1024m -XX:-UseConcMarkSweepGC"
    @list = lst
  end
  def run
    POpen4::popen4("./bin/xa java #{@javaopts} -jar #{@simian} #{@simopts}") do |out, err, sin, pid|
        @list.each do |l|
          sin.puts l
        end
        sin.close
        print out.read
      end
  end
end
if __FILE__ == $0
  lst = []
  case ARGV[0]
  when /-d/
    lst = %x[find #{ARGV[1]} -name \*.java ].split("\n").map(&:chomp)
  when /-l/
    lst = File.open(ARGV[1]).readlines.map(&:chomp)
  when /-x/
    lst = STDIN.readlines.map(&:chomp)
  else
    puts "-d -l -x"
    exit
  end
  s = Sim.new(lst)
  s.run()
end
