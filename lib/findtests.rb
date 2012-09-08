#!/usr/bin/ruby

require 'rubygems'
require 'find'

class FindTests
  def initialize(dir)
    @dir = dir
  end

  def show
    classes = []
    Find.find(@dir) do |f|
      case f
      when /test.*\.java$/
        c = process(f)
        classes << c if c
      end
    end
    classes
  end

  def process(file)
    pkg = nil
    cl = nil
    File.open(file).readlines.each do |l|
      case l
      when /^\s*package\s*([^ ]+);/
        pkg = $1
      when /^\s*public\s+class\s+([^ ]+)/
        cl = $1
      end
    end
    #return file + ' ' + pkg + '.' + cl
    unless pkg.nil? or cl.nil?
      return pkg + '.' + cl
    else
      return nil
    end
  end
end


if __FILE__ == $0
  case ARGV[0]
  when /-l/
    puts FindTests.new(ARGV[1]).show
  else
    puts <<-EOF
    #{$0} -l : list all test cases in a directory by their class name.
    EOF
  end
end
