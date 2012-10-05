#!/usr/bin/ruby
# Gets the method names of a complete java project
require 'find'
$:.push 'bin'
$:.push 'lib'


class FindFiles
  def initialize(src)
    case src
    when /src[\/].*/
      @src = src[4..-1]
    else
      @src = src
    end
  end

  def getfiles()
    f = "files/#{@src}.lst"
    if File.exists?(f)
      return File.readlines(f)
    end
    ls = []
    Find.find("src/" + @src) do |l|
      case l
      when /test/
      when /(.*)[.]java$/
        ls << File.basename(l).downcase
      end
    end
    myls = ls.sort.uniq
    File.open(f, "w") do |fd|
      fd.puts myls.join("\n")
    end
    myls
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
  Gets the files of a complete java project
EOF
    exit
  end
  f = FindFiles.new(src)
  puts f.getfiles
end

