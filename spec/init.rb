require 'bacon'
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/risky"

Bacon.summary_on_exit

begin
  Riak.disable_list_keys_warnings = true
rescue
end

Risky.riak = Riak::Client.new(:host => '10.0.0.14', :protocol=>'http', :http_port => 8098)
