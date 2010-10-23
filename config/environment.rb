require 'rubygems'
require 'memcache'
require 'bcrypt'
$KCODE = "UTF8"
require 'jcode'
require 'unicode'
require 'net/https'
require 'rack'
require 'time'
require 'ftools'
require 'erubis'
require 'sinatra/base'
require 'mongo'
require 'mongo_mapper'
include Mongo

require 'config/config.rb'
require 'libs/custom_logger'

begin
	Log = Logger.new(STDOUT)
	Log.formatter	= Logger::Formatter.new()
	Log.level = Logger::DEBUG

	ENV['RACK_ENV'] ||= 'development'

	## Init the db connector for the mapped objects
	MongoMapper.connection = Connection.new( DBHostname,DBPort,{ :slave_ok => true })
	MongoMapper.database = DBName

	DBConn = Connection.new( DBHostname,DBPort ).db( DBName,{ :slave_ok => true })
	Collection = DBConn.collection( DBName )

	## Load helpers, modoles, libs, and mounts
	["helpers", "models", "models", "libs", "mounts", "mounts" ].each do |path|
		Dir.glob(File.join(path, '*.rb')).sort.each { |f| require f }
	end

	#MCache = MemCache.new( MCServers )

rescue => e
	puts "Exception caught while trying to pre-cache elements: #{$!}"
	puts e.backtrace()
	exit

end

case ENV['RACK_ENV']
 when 'development'
	Log.debug( 'APPLICATION_STARTUP' ){ 'Starting in development mode..' }
 	APP_LOG 	= STDOUT
 	ACCESS_LOG 	= STDOUT

 when 'production'
	'Starting in production mode..'

  	APP_LOG 	= File.new( FSProdAppLogFile,"a" )
  	ACCESS_LOG 	= File.new( FSProdErrorLogFile,"a" )
  	STDOUT.reopen APP_LOG
  	STDERR.reopen APP_LOG
  
 else
  raise 'Configuration not found for this environment.'

end
