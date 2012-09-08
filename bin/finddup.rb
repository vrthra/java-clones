#!/usr/bin/ruby
require 'rubygems'

class DupAnalyze
  def initialize(from, to)
    @from = from
    @to = to
    out = self.class.exec(from, to)
    @lines = out.split("\n").map(&:chomp)
  end

  def self.exec(from, to)
    simian='./tools/simian/bin/simian-2.3.33.jar'
    simopts = File.read('.simopts').read.gsub("\n", " ")
    javaopts="-Xss16m -Xmx1024m"
    %x[find #{from} #{to} -name \*.java \
      |./bin/xa java #{javaopts} -XX:-UseConcMarkSweepGC -jar #{simian} #{simopts} | tee /tmp/simian.out]
  end

  def from_base(f)
    f.sub(/^.*clone-junit\/src\//,'')
  end
  def show
    collect = []
    others = []
    lines = 0
    total = 0
    @result = []
    @collected = []
    xx = []
    @lines.each do|l|
      case l.chomp
      when /Found (\d+) duplicate lines in the following files:/
        @result << processdup(collect, lines, xx) unless collect.empty?
        lines = $1.to_i
        collect = []
        xx = []
      when /Between lines (\d+) and (\d+) in (.+)$/
        c ={:from => $1.to_i, :to => $2.to_i, :file => from_base($3)}
        c[:count] = c[:to] - c[:from]
        collect << c
      when /Processed a total of (\d+) significant \((\d+) raw\) lines in (\d+) files/
        total = $2.to_i
        @result << processdup(collect, lines, xx)
      else
        xx << l.chomp
      end
    end
    [@collected.inject(0, &:+), total]
  end

  def fmt(name, cov,total)
    "%s\t%s\t%s" % [name, cov.to_s, total.to_s]
  end

  def result
    @result
  end

  def r
    cov,total = self.show
  end

  def sim
    cov,total = self.show
    cov*100.0/(total+0.00001)
  end

  def get_base(f)
    f.split('/')[0]
  end

  def processdup(c, count, xx)
     prev_base = nil
     show = false
     c.each do |l|
        base = get_base(l[:file])
        if prev_base && base != prev_base
           show = true
           break
        end
        prev_base = base
     end
     files = []
     if show
       #STDERR.puts"-----------------------"
       c.each do |l|
         #STDERR.puts l[:file]
         files << l[:file]
       end
       @collected << count
     end
     {:files => files, :count => count, :matches => xx}
  end
end

if __FILE__ == $0
  case ARGV[0]
  when /-i/
    from=ARGV[1]
    to=ARGV[2]
    puts DupAnalyze.new(from, to).sim
  when /-a/
    from=ARGV[1]
    to=ARGV[2]
    d = DupAnalyze.new(from, to)
    d.show()
    i = 0
    dir = 'dups/'+ from.split('/')[1]+'.'+to.split('/')[1]
    exit(0) if File.exists?(dir)
    Dir.mkdir(dir)
    d.result().each do |p|
      r = p[:files]
      next if r.empty?
      File.open(dir + '/' + p[:count].to_s() + '.i.' + i.to_s, 'w') do |f|
        f.puts r.sort().uniq()
      end
      File.open(dir + '/' + p[:count].to_s() + '.m.' + i.to_s, 'w') do |f|
        f.puts p[:matches]
      end
    end
  when /-f/
    fromf=ARGV[1]
    todir=ARGV[2]
    d = DupAnalyze.new(from, to)
    puts d.show
  else
    puts <<-EOF
    #{$0} -all <fromdir> <todir>
      searches for all matching between <fromdir> and <todir>
      ignores same dir matching

    #{$0} -i <fromdir> <todir>
      prints the similarity between two projects.

    #{$0} -f <file> <dir>
      finds the highest similarity file for <file> in <dir>
    EOF

  end
end
