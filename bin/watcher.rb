#!/usr/bin/ruby
# watches for stuck processes and kills them.
limit = 60 * 15
now = %x[pgrep java].chomp.to_i
sleep limit
while true
  puts now
  nxt = %x[pgrep java].chomp.to_i
  if nxt != 0 && nxt == now
    puts "kill #{nxt}"
    %x[kill -9 #{nxt}]
  else
    puts "#{now} != #{nxt}"
  end
  sleep limit
  now = nxt
end

