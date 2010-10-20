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
			#Log.debug( "Item" ){ item.inspect }
			#Log.warn( "Item title" ){ item.title }

			#Log.warn( "Item content" ){ item.description.inspect }
			# <p>Located on 520         milepost 0.83</p><p>Direction: EB        </p><p>Latitude: 47.643831471, Longitude: -122.306443076</p><p>Reading: WideOpen</p><p>Time of reading: 10/10/2010 2:04:22 PM</p><div style=\"background-color: beige; border-top: solid 1px black; border-bottom: solid 1px black;\"><b>Last Updated At: 10/10/2010 2:04:22 PM</b>

			obj = {}

			# <p>Located on 520         milepost 0.83</p>
			locScan = item.description.scan( /Located\son\s([0-9]{1,}).*milepost\s(.*)<\/p><p>Direction:/ )[0]
			#Log.debug( "Located at" ){ locScan[0] }
			#Log.debug( "Milepost" ){ locScan[1] }
			obj[:location] = locScan[0].to_i()
			obj[:milepost] = locScan[1].to_f()

			# <p>Direction: EB        </p>
			direction = item.description.scan( /Direction:\s([A-Z]{1,})\s/ )[0]
			#Log.debug( "Direction" ){ direction[0] }
			obj[:direction] = direction[0]

			# <p>Latitude: 47.643831471, Longitude: -122.306443076</p>
			latScan = item.description.scan( /Latitude:\s(.*),\sLongitude:\s(.*)<\/p><p>Reading/ )[0]
			#Log.debug( "Lat, Long" ){ "%s -- %s" % [latScan[0],latScan[1]] }
			obj[:loc] = [ latScan[0].to_f(), latScan[1].to_f() ]

			# <p>Reading: WideOpen</p>
			reading = item.description.scan( /Reading:\s(.*)<\/p><p>Time/ )[0]
			#Log.warn( "Reading" ){ reading[0] }
			obj[:reading] = reading[0]

			# <p>Time of reading: 10/10/2010 2:04:22 PM</p>
			timeOfReading = item.description.scan( /Time\sof\sreading:\s(.*)<\/p><div/ )[0]
			#Log.warn( "Time of reading" ){ timeOfReading[0] }
			obj[:timeOfReading] = timeOfReading[0]

			# <b>Last Updated At: 10/10/2010 2:04:22 PM</b>
			lastUpdatedAt = item.description.scan( /Last\sUpdated\sAt:\s(.*)<\/b>/ )[0]
			#Log.warn( "Last updated at" ){ lastUpdatedAt[0] }
			obj[:lastUpdatedAt] = lastUpdatedAt[0]

			obj[:title] = item.title

			search = collState.find({ :title => obj[:title] })
			segmentId = nil

			if(search.count() == 0)
				#Log.debug( "Creating" ){ obj.inspect }
				segmentId = collState.save( obj )

			else
				row = search.first()
				#Log.warn( "Row" ){ row.inspect }

				if(row["lastUpdatedAt"] != obj[:lastUpdatedAt])
					#Log.debug( "Updating" ){ row["_id"] }
					#Collection.remove({ :_id => row["_id"] })
					#saved = Collection.save( obj )
					collState.update({ :_id => row["_id"] }, row.merge(obj))
					#Log.debug( "Updated" ){ saved.inspect }

					collLog.save({
						:updated => obj[:lastUpdatedAt],
						:reading => obj[:reading],
						:segmentId => row["_id"],
						:tsUpdated => Time.parse( obj[:lastUpdatedAt] ).to_i()
					})
				end

				#Log.debug( "Count" ){ search.count() }
				#search.each do |row|
					#Log.warn( "Row" ){ row.inspect }
				#end

				#segmentId = row["_id"]

			end


		end

		Log.warn( "Sleeping" )
		sleep 300
		Log.debug( "Awake" )
	end

rescue => e
	puts "Caught exception: #{$!}"
	puts e.backtrace()

end

