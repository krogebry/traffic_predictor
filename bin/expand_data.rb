#!/usr/bin/ruby
##
# Run the prediction logic and store it on the relavant collection.
##
require 'init.rb'

#t = Time.at(1286980652)
#t = Time.at(Time.new.to_i() - (1*86400))
#puts t
#exit

MaxNumLogs = 20000
MaxNumBuckets = 5

begin
	collSegments= DBConn.collection( "segment_states" )
	collLog = DBConn.collection( "segment_log" )

	expLog = DBConn.collection( "expanded_segment_log" )
	expLog.remove()

	logsPerBucket = (MaxNumLogs / MaxNumBuckets)
	#buckets = []
	#bucketId = 0
	threads = []

	#(MaxNumBuckets+1).times do |bucketId|
		#threads << Thread.new do 
			#bId = bucketId

			Log.debug( "Getting a bucket" )
			logs = collLog.find({
				:tsUpdated => { "$gt" => (Time.new.to_i() - (1*86400)), "$lt" => Time.new.to_i() }
			},{ 
				#:skip => (logsPerBucket*bId),
				#:limit => MaxNumLogs, 
				:sort => [["tsUpdated","ASC"]] 
			})
			Log.debug( "Done getting a bucket" ){ logs.count() }
	
			logs.each do |log|
				#int+=1
				(1..3).each do |i|
					tsLastWeek = (log["tsUpdated"] - (86400*(7*i)))

					#Log.warn( "Log" ){ log.inspect }
					#Log.warn( "New" ){ "%s %s" % [log["updated"],Time.at( tsLastWeek ).strftime( "%m/%d/%Y %I:%M:%S %p" )] }

					expLog.save({
						:reading => log["reading"],
						:updated => Time.at( tsLastWeek ).strftime( "%m/%d/%Y %I:%M:%S %p" ),
						:segmentId => log["segmentId"],
						:tsUpdated => tsLastWeek
					})

					#res = expLog.save( o )
					#Log.warn( "Res" ){ res.inspect }
				end
			end

		#end
	#end

	#threads.each do |t| t.join end

rescue => e
	puts "Caught exception: #{$!}"
	puts e.backtrace()

end

