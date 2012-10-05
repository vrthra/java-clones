#!/usr/bin/ruby
# Gets the method names of a complete java project
require 'find'
$:.push 'bin'
$:.push 'lib'


class FindMethods
  def initialize(src)
    case src
    when /src[\/].*/
      @src = src[4..-1]
    else
      @src = src
    end
  end

  def processjava(j)
    f = "methods/#{@src}/#{File.basename(j)}.method"
    if File.exists?(f)
      return File.readlines(f)
    end
    ls = []
    out = %x[java -cp ./lib/jars/parseit.jar:./lib/jars/javaparser-1.0.8.jar MethodPrinter #{j} x]
    out.split("\n").map(&:chomp).each do |l|
      case l
      when /^>.*/
      else
        ls << l
      end
    end
    %x[mkdir -p methods/#{@src}/]
    File.open(f, "w") do |fd|
      fd.puts ls.join("\n")
    end
    return ls
  end

  def getmethods()
    ls = []
    Find.find("src/" + @src) do |l|
      case l
      when /\/test\//
      when /(.*)[.]java$/
        STDERR.puts l
        ls << processjava(l)
      end
    end
    puts ls.sort.uniq
  end

end


if __FILE__ == $0
  src = ''
  case ARGV[0]
  when /-l/
    src = ARGV[1]
  else
    puts <<EOF
  #{$0} -l src/<project>
  Gets the method names of a complete java project
EOF
    exit
  end
  f = FindMethods.new(src)
  f.getmethods
end


