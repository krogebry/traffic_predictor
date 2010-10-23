##
# Main
##
class App < Sinatra::Base
  
	get '/' do
		segCoords = []
		erb(:index, {}, { :segCoords => segCoords })
	end

	post '/predict/?' do
		day = params[:day]
		todHour = params[:todHour].to_i()
		todMinute = params[:todMinute].to_i()

		highway = params[:highway]
		direction = "NB"

		p = Prediction.new()
		p.highway = highway
		p.direction = direction
		p.todHour = todHour
		p.todMinute = todMinute
		Log.debug( "p" ){ p.inspect }

		data = p.getPredictions()

		return { :success => true, :data => data }.to_json()

		#cursor = DBConn.collection( "segment_states" ).find({
			#:location => highway,
			#:direction => direction
		#},{
			#:sort => [["milepost","DESC"]]
		#})
		#Log.debug( "Segments" ){ segments.count }

		#segments = []
		#cursor.each do |segment|
			#next if(segment["loc"][0] == 0)
			#segments.push( segment )
		#end

		#segCoords = []
		#i = 0
		#segments.each do |segment|
			#segNext = segments[i+1]
			#Log.debug( "Next" ){ segments[i+1].inspect }
			#if(segNext != nil)
				#segCoords.push({
					#:start => segment["loc"],
					#:name => segment["title"],
					#:end => segNext["loc"],
					#:color => "#aa"+rand(9).to_s()+rand(9).to_s()+rand(9).to_s()+rand(9).to_s()
				#})
			#end
			#i+=1
		#end

		#segCoords = segments.map{|s| s["loc"] }
		#Log.debug( "Coords" ){ segCoords };
		#segCoords.each do |sC|
			#Log.debug( "Sc" ){ sC.inspect }
		#end
		
		#erb(:index, {}, { :segCoords => segCoords })
	end

end
