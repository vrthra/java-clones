#!/bin/env ruby
# Inspects the java files and tries to determine junit classes.

require 'find'

class FindTests
  def initialize(src)
    @src = case src
           when /src\/*/
             src[4..-1]
           else
             src
           end
    @proj = 'src/' + @src
    @dir = "testcalls/#{@src}"
  end

  def process_java(j)
    ff = File.basename(j)
    if File.exists?("#{@dir}/.#{ff}")
      out = IO.read("#{@dir}/.#{ff}")
    else
      out = %x[java -cp ./lib/jars/parseit.jar:./lib/jars/javaparser-1.0.8.jar parse.ClassPrinter #{j}]
      File.open("#{@dir}/.#{ff}", 'w') do |w|
        w.puts out
      end
    end
    clas = out.split(' ')[0]
    return nil if clas.nil?
    cfile = "#{@dir}/#{clas}"
    if File.exists?(cfile)
      return {:klass => out, :methods => File.readlines(cfile)}
    end
    if out !~ /Test/ then
      return nil
    end
    f = File.readlines(j).map{|l|
       l.strip().gsub(%r(//.*$),' ')
    }.join(' ').gsub(%r(/\*.*?\*/)m, ' ').gsub(/"[^"]*"/,' ').gsub(/[(),{}'<>;=+-.\[\]]/,' ').split(' ').find_all{|f|
      f.length > 2
    }.sort().uniq()
    File.open(cfile, 'w') do |fd|
      fd.puts f
    end
    return {:klass => out, :methods => f}
  end
  def gettests
    %x[mkdir -p #{@dir}]
    tsts = []
    Find.find(@proj) do |f|
      case f.strip
      when /\.java$/
        res = process_java(f)
        tsts << res if res
      end
    end
    tsts
  end
end

f = FindTests.new(ARGV[0])
f.gettests.each do |x|
  puts x[:klass]
  x[:methods].each do |y|
    puts "\t#{y}"
  end
end

