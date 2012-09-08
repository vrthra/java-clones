
class SimOpts
  def initialize
    @simopts = File.open('.simopts').readlines.sort.join(" ").gsub("\n",' ')
    @simname = @simopts.gsub(/ +/, '%')
  end
  def opts
    @simopts
  end
  def name
    @simname
  end
end
