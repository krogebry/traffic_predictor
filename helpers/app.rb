module Sinatra
  module AppHelpers

	def unauthorized()
		return [ 302, { 'Location' => "/login?redirect=#{@requestURI}" },[ "" ] ]
	end

	def requestFailure( msg )
		return [ 302, { 'Location' => "/error" },[ "" ] ]
	end

	##
	# Escape a string of html
	#
    def h(text)
      Rack::Utils.escape_html(text)
    end

	##
	# Escape a string
	##
	def e( str )
      Rack::Utils.escape( str )
	end

	##
	# UnEscape a string
	##
	def u( str )
      Rack::Utils.unescape( str )
	end
    
	##
	# Internationalize a string
	##
	def i( str )
		str
	end

  end
end
