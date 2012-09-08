
%x[ls *sim].split("\n").map(&:chomp).each do |l|
  puts "mv #{l} #{l.gsub(/sim$/,'.sim')}"
end
