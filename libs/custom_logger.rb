##
# Custom logger that uses colors in output
##
class Logger
  class Formatter
  	RED		= "\e[0;31m"
  	BRIGHT_RED		= "\e[1;31m"
  	GREEN 	= "\e[1;32m"
  	YELLOW	= "\e[1;33m"
  	BLUE	= "\e[1;34m"
  	PURPLE	= "\e[1;35m"
	CLOSE	= "\e[0m"

	@colors
	@format
	@datetime_format

	def initialize()
		@colors	= {
			:fatal	=> Logger::Formatter::BRIGHT_RED,
			:error	=> Logger::Formatter::RED,
			:warn	=> Logger::Formatter::YELLOW,
			:info	=> Logger::Formatter::PURPLE,
			:debug	=> Logger::Formatter::BLUE
		}
  		@format	= "%s[%s#%d] %s: %s #{Logger::Formatter::CLOSE}\n"
		@datetime_format = nil
	end

  	def call( severity,time,progname,msg )
		@format % [ @colors[severity.downcase.to_sym()], time, $$, progname, msg2str( msg )]
	end
  end
end
