#!/usr/bin/ruby
##
# Reporting.
##
require 'init.rb'

begin
	coll = DBConn.collection( "segment_states" )
	collLog = DBConn.collection( "segment_log" )

	#res = coll.map_reduce( 
		#"function(){ emit( this.reading,1 ); }", 
		#"function( key,values ){ var i = 0; values.forEach(function( v ){ i += v; }); return i}"
	#)

	#res = coll.map_reduce( 
		#"function(){ emit( this.location,1 ); }", 
		#"function( key,values ){ var i = 0; values.forEach(function( v ){ i += v; }); return i}"
	#)

	#res = coll.map_reduce( 
		#"function(){ emit( this.direction,1 ); }", 
		#"function( key,values ){ var i = 0; values.forEach(function( v ){ i += v; }); return i}"
	#)

	#res = coll.map_reduce( 
		#"function(){ emit( this.direction,1 ); }", 
		#"function( key,values ){ var i = 0; values.forEach(function( v ){ i += v; }); return i}",
		#{ :query => { :location => 5 } }
	#)

	#res.find.each do |row|
		#Log.debug( "Row" ){ row.inspect }
	#end

	#Log.debug( "Res" ){ res.inspect }

	#rows = coll.find({ :location => 167, :direction => "NB" })
	#rows = coll.find({ :location => 5 },{ :sort => ["milepost","ASC"] })
	#rows = coll.find({ :location => 5, :direction => { "$in" => ["N","NB","EB"] }},{ :sort => ["milepost","ASC"] })
	rows = coll.find({ :location => 5, :direction => { "$in" => ["S","SB","WB"] }},{ :sort => ["milepost","ASC"] })
	#Log.debug( "Num rows" ){ rows.count() }

	rows.each do |row|
		#Log.debug( "Row" ){ row.inspect }
		Log.debug( "Direction" ){ "%s -- %s -- %s" % [row["direction"],row["milepost"],row["title"]] }
		states = collLog.find({ :segmentId => row["_id"] })
		states.each do |state|
			Log.warn( "State" ){ state["reading"] }
		end
		#Log.debug( "Reading" ){ row["reading"] }
	end

rescue => e
	puts "Caught exception: #{$!}"
	puts e.backtrace()

end

