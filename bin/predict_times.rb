#!/usr/bin/ruby
##
# Run the prediction logic and store it on the relavant collection.
##
require 'init.rb'

def runSegment( segment )
	Log.debug( "Segment" ){ "%s %s %s" % [segment["title"],segment["milepost"],segment["_id"]] }

	logs = CollLog.find({
		:segmentId => segment["_id"], 
		:tsUpdated => { "$ne" => nil },
		:reading => { "$ne" => nil }
	},{
		:sort => [["tsUpdated","ASC"]] 
	})

	readings = {}

	logs.each do |log|
		#Log.warn( "Log" ){ log["reading"] }
		split = log["updated"].scan( /([0-9]{1,}):([0-9]{1,}):[0-9]{1,}\s(.*)$/ )[0]
		hour = split[0].to_i() + (split[2] == 'PM' ? 12 : 0)
		minuteBucket = 0;

		if(split[1].to_i() >= 5)
			minuteBucket = (split[1].to_f()/5.0).to_i()
		end

		readings[hour] ||= {}
		readings[hour][minuteBucket] ||= {}
		readings[hour][minuteBucket][log["reading"]] ||= 0
		readings[hour][minuteBucket][log["reading"]] += 1
		#Log.debug( "Bucket" ){ "%s :: %s" % [hour,minuteBucket] }
	end

	#Log.debug( "Readings" ){ readings.inspect }

	store = []
	(1..24).each do |hour|
		aryMin = []
		readings[hour] ||= {}
		(0..11).each do |minute|
			readings[hour][minute] ||= {}
			aryState = []
			SegmentStates.each do |state|
				aryState.push(( readings[hour][minute][state] != nil ? readings[hour][minute][state] : 0 ))
			end
			aryMin.push( aryState )
		end
		store.push( aryMin )
	end

	#Log.debug( "Store" ){ store.inspect }
	CollSegments.update({ :_id => segment["_id"] },segment.merge({ :readings => store }) )
end

MaxNumBuckets = 5

begin
	CollSegments= DBConn.collection( "segment_states" )
	CollLog = DBConn.collection( "segment_log" )
	#CollLog = DBConn.collection( "expanded_segment_log" )

	segments = CollSegments.find() 
	segments.each do |segment|
		begin
			#Log.debug( "Segment" ){ segment.inspect }
			#Log.debug( "Segment (%s)" % bId ){ "%s %s" % [segment["title"],segment["milepost"]] }
			runSegment( segment )

		rescue => e
			puts "Caught exception in thread: #{$!}"
			puts e.backtrace()

		end
	end 

rescue => e
	puts "Caught exception: #{$!}"
	puts e.backtrace()

end

