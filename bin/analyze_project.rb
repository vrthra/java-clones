#!/usr/bin/ruby

$:.push 'bin'
$:.push 'lib'

require 'finddup'
require 'coverage.xml'
require 'simopts'

$s = SimOpts.new
$dupdir = 'sim/dups/' + $s.name + '/'
def populate_dup(from, to)
  STDERR.puts "#{from}, #{to}"
  dir = $dupdir + from.split('/')[1]+'.'+to.split('/')[1]
  if File.exists?(dir)
    puts "has #{dir}"
    return
  end

  d = DupAnalyze.new(from, to)
  d.show()
  i = 0
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
end

def compare_to_best_cov(cproj)
  @s = SimOpts.new
  best_covered_100 = File.open('cov.lst').readlines.reverse[0..99].map{|x| x.split(' ')[0]}
  %x[mkdir -p #{$dupdir}]
  # -----------------------------------------------------------
  # First populate dups/ dir
  # -----------------------------------------------------------
  best_covered_100.each do |bproj|
    next if bproj == cproj
    populate_dup ("src/%s" % bproj), ("src/%s" % cproj)
  end
  # -----------------------------------------------------------
  # We want to find files in bproj that are similar to cproj.
  # so we get files of bproj only.
  # -----------------------------------------------------------
  return
  best_covered_100.each do |bproj|
    lines = %x[cat %s/%s.%s/*] % [dupdir, bproj,cproj].split("\n")\
      .map(&:chomp).sort.uniq.select_if{|l|
      l.start_with?(bproj) && l.end_with?('java')}
    lines.each do |l|
      name = File.basename(l)
      puts "---------------------------------------------------"
      puts name
      # next check if it is worth looking at. That is, is the file we selected
      # covered in any tests?  We ask ack to list the coverage.xml files that
      # contain the given basename because coverage.xml has class based
      # coverage. So the class name would be mentioned.
      covered = %x[ack --noenv -l  -G 'coverage\.xml' ${name%.java} cov.all/$p1/ --sort-files]\
        .split("\n").map(&:chomp)
      covered.each do |cov|
        c = ParseCoverXml.new(cov, name).show
        puts "#{File.basename(File.dirname(cov))} #{c}"
      end
    end
  end
end

# assume src in ARGV.
compare_to_best_cov ARGV[0]

