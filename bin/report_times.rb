#!/usr/bin/ruby
##
# Run the prediction logic and store it on the relavant collection.
##
require 'init.rb'

begin
	collSegments= DBConn.collection( "segment_states" )
	collLog = DBConn.collection( "expanded_segment_log" )

	#segment = collSegments.find( {},{ :sort => [["tsCreated","ASC"]], :limit => 1 }).first()
	#segment = collSegments.find({ :title => "216th St SE", :milepost => 27.44 }).first()
	#segment = collSegments.find({ :title => "Richmond Rd", :milepost => 28.08 }).first()
	#segments = collSegments.find() 

	#Log.debug( "Segment" ){ segment.inspect }

	#chunk = segment["readings"][13][5]
	#Log.debug( "Chunk" ){ chunk.inspect }

	#(0..SegmentStates.length).each do |i|
	#(0..(chunk.length-1)).each do |i|
		#Log.debug( "State" ){ SegmentStates[i] } if( chunk[i] > 0 )
	#end

	#segments = collSegments.find({ 
		#:location => 405, 
		#:direction => "SB",
		#:milepost => { "$gte" => 4.12, "$lte" => 13.6 }
	#},{
		#:sort => [["milepost","ASC"]]
	#})

	segments = collSegments.find({ 
		:location => 18, 
		:direction => "NB"
		#:milepost => { "$gte" => 4.12, "$lte" => 13.6 }
	},{
		:sort => [["milepost","ASC"]]
	})

	rangeStart = [17,0]
	rangeEnd = [18,0]

	numIterations = ((rangeEnd[0]-rangeStart[0])*12) + (rangeEnd[1]-rangeStart[1])
	Log.debug( "Num Iteration" ){ numIterations }

	segments.each do |segment|
		Log.debug( "Segment" ){ "%s %s" % [segment["title"],segment["milepost"]] }
		currRange = [rangeStart[0],rangeStart[1]]

		numIterations.times do |i|
			#Log.debug( "Range" ){ currRange.inspect }

			chunk = segment["readings"][currRange[0]][currRange[1]]
			Log.warn( "Chunk" ){ chunk.inspect }
			totals = {}
			total = 0
			(0..(chunk.length-1)).each do |i|
				#if(chunk[i] > 0)
					#total += chunk[i]
					#weight += (chunk[i] * (i*0.75))
				#end
				
				#Log.warn( "%s:%s" % [currRange[0],(currRange[1]*5)] ){ 
					#"%s (%s)" % [SegmentStates[i],chunk[i]] 
				#} if( chunk[i] > 0 )

				if(chunk[i] > 0)
					totals[SegmentStates[i]] ||= 0
					totals[SegmentStates[i]] += chunk[i]
					total += chunk[i]
				end
			end

			#if(weight > total)
				#Log.debug( "Total" ){ "%.2f %i %.2f" % [weight,total,(weight-total)] }
			#end

			totals.each do |state,cnt|
				pct = ((cnt.to_f() / total.to_f())*100)
				Log.debug( state ){ "%i %i%%" % [cnt,pct] }
			end

			if(currRange[1]+1 == 11)
				currRange[0] += 1
				currRange[1] = 0
			else
				currRange[1] += 1
			end
		end

	end

rescue => e
	puts "Caught exception: #{$!}"
	puts e.backtrace()

end

