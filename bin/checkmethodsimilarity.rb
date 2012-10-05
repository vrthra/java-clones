#!/usr/bin/ruby

class CompareMethods
  def initialize(srca,srcb)
    case srca
    when /src..*/
      @src_a = "methods/" + srca[4..-1]
    else
      @src_a = srca
    end
    case srcb
    when /src..*/
      @src_b =  "methods/" + srcb[4..-1]
    else
      @src_b = srcb
    end
  end
  def showsim()
    lines_a = %x[cat #{@src_a}/*].split("\n").map(&:strip).sort.uniq
    lines_b = %x[cat #{@src_b}/*].split("\n").map(&:strip).sort.uniq
    return lines_a & lines_b
    #puts %x[echo "comm -12 <(cat #{@src_a}/* |sort -u) <(cat #{@src_b}/* | sort -u)" | bash]
  end
end



if __FILE__ == $0
  src = ''
  case ARGV[0]
  when /-l/
    srca = ARGV[1]
    srcb = ARGV[2]
  else
    puts <<EOF
#{$0} -l <projectA> <prouectB>
  given two projects, it checks if the method names match up
EOF
    exit
  end
  f = CompareMethods.new(srca,srcb)
  s = f.showsim()
  puts "---------------------------------"
  puts "#{s.length} #{[srca,srcb].sort.join(" ")} <"
  puts s
end



