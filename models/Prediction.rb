##
# Prediction
##

class Prediction
	@todHour
	@todMinute

	@highway
	@direction

	attr_accessor :todHour, :todMinute, :highway, :direction
	def initialize()
	end

	def getCursor()
		DBConn.collection( "segment_states" ).find({
			:location => @highway.to_i()
		},{
			:sort => [["milepost","DESC"]]
		})
	end

	def getSegments()
		c = self.getCursor()
		ro = []

		c.each do |segment|
			next if(segment["loc"][0] == 0)
			ro.push( segment )
		end

		return ro
	end

	##
	# 0: nil
	# 1: green ( 0000ff )
	# 2: yellow ( ffdd00 )
	# 3: pink ( ffcccc )
	# 4: red ( ff0000 )
	##
	def getColor( readings )
		total = 0
		return "#000000" if(readings == nil)
		readings.map(){|r| total+=r }
		return "#000000" if(total == 0)
		#Log.debug( "Total" ){ total }
		#Log.debug( "Reading" ){ readings.inspect }

		baseColor = [255,255,255]

		p = (( readings[1].to_f / total)*255)
		#puts "Green: #{p}"
		baseColor[0] -= p.to_i()
		baseColor[2] -= p.to_i()

		p = (( readings[2].to_f / total)*255)
		baseColor[0] += (p*0.75).to_i()
		baseColor[1] += (p*0.25).to_i()
		baseColor[2] -= p.to_i()

		p = (( readings[4].to_f / total)*255)
		baseColor[0] += p.to_i()
		baseColor[1] -= p.to_i()
		baseColor[2] -= p.to_i()

		p = (( readings[4].to_f / total)*255)
		baseColor[0] += p.to_i()
		baseColor[1] -= p.to_i()
		baseColor[2] -= p.to_i()

		baseColor.map!{|bc| (bc > 255 ? 255 : (bc < 0 ? 0 : bc )) }

		#red = ( baseColor[0] == 0 ? "00" : baseColor[0].to_s( 16 ) )
		#green = ( baseColor[1] == 0 ? "00" : baseColor[1].to_s( 16 ) )
		#blue = ( baseColor[2] == 0 ? "00" : baseColor[2].to_s( 16 ) )

		return "#"+
			baseColor[0].to_s( 16 ).rjust(2,'0') + 
			baseColor[1].to_s( 16 ).rjust(2,'0') + 
			baseColor[2].to_s( 16 ).rjust(2,'0')
	end

	def getPredictions()
		i = 0
		ro = []

		segments = self.getSegments()

		segments.each do |segment|
			segNext = segments[i+1]
			#Log.debug( "Next" ){ segments[i+1].inspect }

			if(segNext != nil && segment["readings"] != nil)
				readings = segment["readings"][@todHour][@todMinute]
				#Log.debug( "Readings" ){ readings.inspect }

				color = self.getColor( readings )

				ro.push({
					:name => segment["title"],
					:color => color,
					:start => segment["loc"],
					:end => segNext["loc"],
					:readings => readings
				})
			end
			i+=1
		end

		return ro
	end

end
