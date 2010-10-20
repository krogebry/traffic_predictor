#!/usr/bin/ruby
##
# Predict Time of Day.
##
require 'init.rb'

begin
	coll = DBConn.collection( "segment_states" )
	collLog = DBConn.collection( "segment_log" )

	prediction = {
		:tsTimeOfDay => [ "1:00",60 ],
		:segment => 167,
		:direction => :south
	}

	#query = {
		#:location => 167,
		#:milepost => { "$gt" => 22.34 },
		#:direction => "NB"
	#}

	query = {
		:location => 405,
		:milepost => { "$gt" => 4.12, "$lt" => 13.6 },
		:direction => "NB"
	}

	segments = coll.find( query, { 
		:sort => ["milepost","ASC"], 
		:limit => 500
	})

	segments.each do |segment|
		#Log.debug( "Row" ){ row.inspect }
		Log.debug( "Segment" ){ "%s %s" % [segment["title"],segment["milepost"]] }
		#next 

		histStates = { :cnt => 0 }

		(10..12).each do |day|
			#Log.debug( "Day" ){ day }

			tsRangeStart = Time.parse( "10/#{day}/2010 12:30:00 PM" ).to_f()
			tsRangeEnd = Time.parse( "10/#{day}/2010 12:35:00 PM" ).to_f()

			#Log.debug( "Ts Range" ){ "%.2f %.2f" % [tsRangeStart,tsRangeEnd] }

			logQuery = {
				:segmentId => segment["_id"],
				#:updated => /\s3:0[0-4]:[0-9]{1,}\sPM/
				:tsUpdated => { "$gt" => tsRangeStart, "$lt" => tsRangeEnd }
			}

			log = collLog.find( logQuery ).first()
			if(log != nil)
				histStates[log["reading"]] ||= 0
				histStates[log["reading"]] += 1
				histStates[:cnt] += 1
			end

			#Log.debug( "Num status" ){ logs.count() }
			#numEntries = logs.count()

			#logs.each do |log|
				#Log.debug( "Log" ){ log.inspect }
				#Log.warn( "Entry" ){ "%s %s" % [log["updated"],log["reading"]] }
			#end

		end

		#Log.debug( "Hist" ){ histStates.inspect }

		histStates.each do |reading,count|
			Log.warn( reading ){ "%i %.2f%%" % [count,((count.to_f()/histStates[:cnt])*100)] }
		end

	end

rescue => e
	puts "Caught exception: #{$!}"
	puts e.backtrace()

end

