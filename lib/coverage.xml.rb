#!/usr/bin/ruby
require 'rubygems'
require 'net/http'
require 'nokogiri'
require 'find'

class ParseCoverXml
  def initialize(xml, java)
    @xml = xml
    @java = java
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
      # we just get block coverage as this is the fundamental for emma.
      # http://emma.sourceforge.net/faq.html#q.blockcoverage
      #doc.xpath("/report/data/package/srcfile/coverage").each do |n|
      #doc.xpath("/report/data/all/package/srcfile[@name=#{@java}]/coverage").each do |n|
      doc.xpath("/report/data/all/package/srcfile[contains(@name,'#{@java}')]/coverage").each do |n|
        next unless n.attr('type') =~ /block/
        case n.attr('value')
        when /(\d+)%\s+\((\d+)\/(\d+)\)/
          val = {:% => $1.to_i, :covered => $2.to_i, :total => $3.to_i}
        end
      end
    end
    val
  end

end

if __FILE__ == $0
  case ARGV[0]
  when /-i/
    puts ParseCoverXml.new(ARGV[1], ARGV[2]).show
  else
    puts "-i <coverage.xml> class.java"
  end
end

