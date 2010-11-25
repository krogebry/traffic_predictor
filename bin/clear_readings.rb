#!/usr/bin/ruby
##
# Run the prediction logic and store it on the relavant collection.
##
require 'init.rb'

begin
	CollSegments= DBConn.collection( "segment_states" )
	CollLog = DBConn.collection( "segment_log" )
	#CollLog = DBConn.collection( "expanded_segment_log" )

	segments = CollSegments.find()
	#segments = CollSegments.find({ :title => "005 SB milepost 116.51" })
	#segments = CollSegments.find().sort( [[:lastUpdatedAt,-1]] ).limit( 100 )

	segments.each do |segment|
		segment["readings"] = []
		Log.debug( "Segment" ){ segment.inspect }
		CollSegments.update({ :_id => segment["_id"] },segment )
	end 

rescue => e
	puts "Caught exception: #{$!}"
	puts e.backtrace()

end

