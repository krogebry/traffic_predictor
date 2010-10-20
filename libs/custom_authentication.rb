##
# Custom authentication handler for a Sinatra based service.
##
require "rack/auth/abstract/handler"
require "rack/auth/abstract/request"

module Rack
 module Auth
   	class Custom < AbstractHandler

		def unauthorized()
			return [ 302, { 'Location' => "/login?redirect=#{@requestURI}" },[ "" ] ]
		end

		def requestFailure( msg )
			return [ 302, { 'Location' => "/error" },[ "" ] ]
		end

		def call( env )
			@requestURI	= env["REQUEST_URI"]

			## Ignore the user check for login/logout actions
			if(env["REQUEST_URI"].match( /log.*/ )) 
				return @app.call( env )
			end

			## No session means the user has not logged in yet, or has just logged out
			#env.each do |k,v| puts "#{k}: #{v}" end

			#Log.debug( "env" ){ env.inspect }
			#Log.debug( "rack.session" ){ env["rack.session"].inspect }
			if(env["rack.session"] == nil || env["rack.session"][:userId] == nil)
				Log.info( "Authentication" ){ "Invalid session" }
				return unauthorized()
			end

			user	= User.all( :conditions => { :_id => env["rack.session"][:userId] })
			## Call the mount point *only* if the user exists and is authorized to login
			if(user.count == 1 && user[0].authorized?() )
				return unauthorized() if(user[0]._disabled == true)
				env[:user] = user[0]
				return @app.call( env )
			end
			return unauthorized()
		end

	end ## Custom
 end ## Auth
end ## Rack
