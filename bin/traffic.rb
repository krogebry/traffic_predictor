#!/usr/bin/ruby
##
# Traffic engine.
# http://webpub3qa.wsdot.wa.gov/traffic/api/TrafficFlow/rss.aspx
##
require 'init.rb'
require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

WSDOT_URL = "http://webpub3qa.wsdot.wa.gov/traffic/api/TrafficFlow/rss.aspx"

def getContent()
	content = "" # raw content of rss feed will be loaded here
	Log.debug( "Updating content" )
	open( WSDOT_URL ) do |s| content = s.read end
	#open( "../data/wsdot_01" ) do |s| content = s.read end
	Log.debug( "Done Updating content" )
	return content
end

begin
	collState = DBConn.collection( "segment_states" )
	collLog = DBConn.collection( "segment_log" )

	while( true )
		content = getContent()
		rss = RSS::Parser.parse( content,false )
		#Log.debug( "RSS" ){ rss.inspect }
		#Log.debug( "RSS lastBuildDate" ){ rss.channel.lastBuildDate }
		#Log.debug( "Num RSS Items" ){ rss.items.length }

		rss.items.each do |item|
			#Log.debug( "GUID" ){ item.guid.content }

			#Log.debug( "Noko start" )
			n = Nokogiri::HTML.parse( item.description )
			#Log.debug( "Noko done" ){ n.inspect }

			ps = n.xpath( "//p" )
			#ps.each do |p|
				#Log.debug( "PTag" ){ p.text }
			#end
			#Log.debug( "P tag" ){ ps[0].text }

			obj = { :guid => item.guid.content.to_i() }

			(location,milepost) = ps[0].text.scan( /^Located\son\s([0-9]{1,}).*milepost\s(.*)$/ )[0]
			#Log.warn( "Located:" ){ "%s at %s" % [location,milepost] }
			#Log.warn( "Located:" ){ "%s at %s" % [scan[0][0],scan[0][1]] }

			obj[:location] = location.to_i()
			obj[:milepost] = milepost.to_f()

			obj[:direction] = ps[1].text.scan( /^Direction:\s([A-Z]{1,})\s.*$/ )[0][0]
			#Log.warn( "Direction" ){ "[%s]" % obj[:direction] }

			(lat,long) = ps[2].text.scan( /^Latitude:\s(.*),\sLongitude:\s(.*)$/ )[0]
			obj[:loc] = [lat.to_f(),long.to_f()]
			#Log.debug( "Three" ){ ps[2].text }
			#Log.warn( "Loc" ){ "%.12f x %.12f" % obj[:loc] }

			reading = ps[3].text.scan( /^Reading:\s(.*)$/ )[0][0]
			#Log.debug( "Reading" ){ reading }
	
			timeOfReading = ps[4].text.scan( /^Time\sof\sreading:\s(.*)$/ )[0][0]
			#Log.warn( "TimeOfReading" ){ timeOfReading }

			#Log.debug( "Three" ){ ps[5].text }

			## Search for this segment
			search = collState.find({ :guid => obj[:guid] })

			## Save the segment information
			collState.save( obj ) if(search.count() == 0)

			## Create the log entry
			logId = collLog.save({
				:updated => timeOfReading,
				:reading => reading,
				:tsUpdated => Time.parse( timeOfReading ).to_f(),
				:segmentGUID => obj[:guid]
			})
			#Log.debug( "LogId" ){ logId }

		end

		Log.warn( "Sleeping" )
		sleep 300
		Log.debug( "Awake" )

	end

rescue => e
	puts "Caught exception: #{$!}"
	puts e.backtrace()

end

