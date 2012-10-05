#!/bin/env ruby

class DirCmp
  def initialize(a,b)
    @src_a,@src_b = [a,b].sort
  end
  def getsim
    a_len = File.readlines("files/#{@src_a}.lst").length
    b_len = File.readlines("files/#{@src_b}.lst").length
    a_b_sim = %x[comm -12 files/#{@src_a}.lst files/#{@src_b}.lst].split("\n").length
    return "#{a_b_sim * 200.0/(a_len + b_len)} #{a_b_sim} #{@src_a}:#{a_len} #{@src_b}:#{b_len}"
  end
end

d = DirCmp.new(ARGV[0], ARGV[1])
puts d.getsim
