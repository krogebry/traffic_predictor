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
	collLog = DBConn.collection( "segment_log" )

	#logs = collLog.find({ :tsUpdated => { "$gt" => 1286919022 }, :tsUpdated => /Oct/ })
	#logs = collLog.find({ :tsUpdated => { "$gt" => 1286850602 } })
	#logs = collLog.find({}, { :sort => [["tsUpdated","DESC"]], :skip => 300000, :limit => 100000})
	logs = collLog.find()
	#logs = collLog.find({ :_id => BSON::ObjectID("4cb4d3f2a9ec705efe0006ab") })
	#Log.debug( "Logs" ){ logs.count() }

	#collLog.find().each do |log|
	logs.each do |log|
		#Log.debug( "Log" ){ log.inspect }
		#Log.warn( "Class" ){ log["tsUpdated"].class }
		#if(log["tsUpdated"].class != Fixnum)
			#if(log["tsUpdated"].match( /^Tue/ ))
			#if(log["tsUpdated"].respond_to?( :strftime ))
				#tsUpdated = Time.parse( log["updated"] )
				#Log.debug( "TsUpdated" ){ "%.2f %s" % [tsUpdated.to_f(),tsUpdated] }
				log["tsUpdated"] = log["tsUpdated"].to_i()
				collLog.update({ :_id => log["_id"] },log )
			#end
		#else
		#end
	end

rescue => e
	puts "Caught exception: #{$!}"
	puts e.backtrace()

end

