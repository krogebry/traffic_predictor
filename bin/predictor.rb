#!/usr/bin/ruby
##
# Predict things.
# Pull out the patterns in the change of the segment states.
##
require 'init.rb'

begin
	coll = DBConn.collection( "segment_states" )
	collLog = DBConn.collection( "segment_log" )



	#res = coll.map_reduce( 
		#"function(){ emit( this.segmentId,{ reading: this.reading, cnt: 1 ); }", 
		#"function( key,values ){ var i = 0; values.forEach(function( v ){ i += v; }); return i}",
		##"function( key,values ){ var ro = { count: 0, reading}; values.forEach(function( v ){ i += v; }); return i}",
		#{ 
			#:sort => [ "updated","ASC" ],
			#:query => { :location => 5 } 
		#}
	#)
	#res.find.each do |row|
		#Log.debug( "Row" ){ row.inspect }
	#end



	#rows = coll.find({ :location => 167, :direction => "NB" })
	#rows = coll.find({ :location => 5 },{ :sort => ["milepost","ASC"] })
	#rows = coll.find({ :location => 5, :direction => { "$in" => ["N","NB","EB"] }},{ :sort => ["milepost","ASC"] })
	#rows = coll.find({ :location => 5, :direction => { "$in" => ["S","SB","WB"] }},{ :sort => ["milepost","ASC"] })
	rows = coll.find({ 
		:location => 5, 
		:direction => { "$in" => ["S","SB","WB"] }},
		{ 
			:sort => ["milepost","ASC"], 
			:limit => 5
		}
	)
	#Log.debug( "Num rows" ){ rows.count() }

	rows.each do |row|
		#Log.debug( "Row" ){ row.inspect }
		Log.debug( "Direction" ){ "%s -- %s -- %s -- %s" % [row["direction"],row["milepost"],row["title"],row["_id"]] }

		#tsUpdated = Time.parse( "10/10/2010 11:37:01 PM" ).to_f()
		#states = collLog.find({ 
			#:segmentId => row["_id"], 
			#:tsUpdated => { 
				#"$gt" => (tsUpdated - (3*60)), 
				#"$lt" => (tsUpdated + (3*60)) 
			#} 
		#})

		states = collLog.find({ :segmentId => row["_id"] })
		states.each do |state|
			#Log.debug( "State" ){ state.inspect }
			str = "%s"
			if(state["reading"] == "WideOpen")
				str = "%s"	

			elsif(state["reading"] == "Moderate")
				str = " %s"

			elsif(state["reading"] == "Heavy")
				str = "  %s"

			elsif(state["reading"] == "StopAndGo")
				str = "   %s"

			end
			Log.warn( "Reading" ){ str % state["reading"] }
		end

		#Log.warn( "Num States" ){ states.count() }

		#states.each do |state|
			#Log.debug( "Row" ){ state.inspect }
			#Log.info( "State" ){ state["reading"] }
		#end
		#Log.debug( "Reading" ){ row["reading"] }

		#res = collLog.map_reduce( 
			#"function(){ emit( this.tsUpdated,this.reading ); }", 
			#"function( key,values ){ var reading = ''; values.forEach(function( v ){ reading = v; }); return reading;}",
			##"function( key,values ){ var ro = { count: 0, reading}; values.forEach(function( v ){ i += v; }); return i}",
			#{ 
				#:sort => [ "tsUpdated","ASC" ],
				#:query => { :location => 5, :direction => { "$in" => ["S","SB","WB"] }} 
			#}
		#)

		#res.find.each do |row|
			#Log.debug( "Row" ){ row.inspect }
		#end

	end

rescue => e
	puts "Caught exception: #{$!}"
	puts e.backtrace()

end

