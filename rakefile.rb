require 'sprout'
sprout 'as3'

task :default => :build_swc

desc "Build the IMAPSocket.swc"
compc :build_swc do |t|
  t.output = 'bin/IMAPSocket.swc'
  t.include_sources << 'src'
end


 
 

