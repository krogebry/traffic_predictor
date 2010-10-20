#!/usr/bin/ruby
##
# Load some data into the db.
##
require 'init.rb'

#@dbConn		= Connection.new( DBHostname,DBPort ).db( DBName )
#@dbConn.collection_names.each do |name|
	#@dbConn.collection( name ).clear()
#end

begin

rescue => e
	puts "Caught exception: #{$!}"
	puts e.backtrace()

end

