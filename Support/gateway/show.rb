# annotate gateway
require File.dirname(__FILE__) + '/../lib/git.rb'

filepath = ARGV[0]
revision = ARGV[1]
line = ARGV[2]
if revision.empty?
  tm_open(filepath, :line => line)
  abort
end

Dir.chdir(ENV['TM_PROJECT_DIRECTORY'])
git = SCM::Git::Log.new
tmp_file = git.show_to_tmp_file(filepath, revision)
puts tmp_file 
fork do
  tm_open(tmp_file, :line => line, :wait => true)
  File.delete(tmp_file)
end
