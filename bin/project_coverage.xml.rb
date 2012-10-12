#!/bin/env ruby
require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'find'

class ParseCoverXml
  def initialize(xml)
    @xml = xml
  end

  def xml()
    File.open(@xml) do |f|
      doc = Nokogiri::XML(f)
      yield doc
    end
  end

  def show
    p = self.compute()
    "#{p[:%]}  (#{p[:covered]}/#{p[:total]})"
  end

  def compute
    val = {}
    self.xml do |doc|
      doc.xpath("/report/data/all/coverage").each do |n|
        case n.attr('type')
        #when /line/
        when /block/
          case n.attr('value')
          when /(\d+)%\s+\(([\d.]+)\/([\d.]+)\)/
            val = {:% => $1.to_f, :covered => $2.to_i, :total => $3.to_i}
          end
        end
      end
    end
    val
  end
end

def cover_project(proj)
  complete = {:% => 0.0, :covered => 0, :total => 0}
  count = 0
  Find.find("coverage/update/#{proj}") do |f|
    case f.strip
    when /coverage.xml$/
      count += 1
      #puts ParseCoverXml.new(f.strip).show
      v = ParseCoverXml.new(f.strip).compute
      complete[:covered] += v[:covered] || 0.001  # did not get a line count.
      complete[:total] += v[:total] || 0.001  # did not get a line count.
    end
  end
  if count > 0
    complete[:total] = complete[:total] / count
    complete[:covered] = complete[:covered] / count
    complete[:%] = complete[:total] == 0 ? 0 : complete[:covered] * 100.0 / complete[:total]
  end
  return complete
end

if __FILE__ == $0
  case ARGV[0]
  when /-all/
    if ARGV[1].nil?
      puts "names/all.lst ?"
      exit 0
    end
    puts "  coverage.p"# coverage.covered_lines coverage.total_lines"
    File.readlines(ARGV[1]).each do |l|
      if File.exists?("src/#{l.strip}/.duplicate") or File.exists?("src/#{l.strip}/.skip")
        puts "#{l.strip} -1" # #{complete[:covered]} #{complete[:total]}"
      else
        complete = cover_project(l.strip)
        puts "#{l.strip} #{complete[:%]}" # #{complete[:covered]} #{complete[:total]}"
      end
    end
  when /-i/
    case ARGV[1]
    when /src\/(.*)/
      proj = $1
      complete = cover_project(proj)
      puts "#{complete[:%]}" # #{complete[:covered]} #{complete[:total]}"
    end
  when /-xml/
      complete = ParseCoverXml.new(ARGV[1].strip).compute
      puts "#{complete[:%]}" # #{complete[:covered]} #{complete[:total]}"
  else
      puts <<-EOF
      #{$0} -i src/<proj> prints the coverage% as reported by Emma in R data
          The line counts are not given because as far as emma is concerned,
          blocks are a better way to measure coverage.
      #{$0} -xml <coverage.xml>
      #{$0} -all dumps all.
      #{$0} -i src/<proj>
      EOF
  end
end

