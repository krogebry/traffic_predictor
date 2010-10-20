# thin start -p 4567 -R config.ru
# thin start -p 4567 -e production -R config.ru
require 'config/environment'



use Rack::CommonLogger, ACCESS_LOG
use Rack::ShowExceptions if ENV['RACK_ENV'] == 'development'
use Rack::MethodOverride



#srvs	= ["192.168.1.89:11212:1","192.168.1.89:11211:10"]
use Rack::Session::Memcache, :memcache_server => MCServers
#use Rack::Auth::Custom



#Sinatra::Base.set :logging, true
# These can be pushed back into the App class if you prefer, or if you would like to make multiple classes representing mini apps.
Sinatra::Base.set :static, true

Sinatra::Base.set :root, File.expand_path(File.dirname(__FILE__).gsub(/config/,''))
Sinatra::Base.set :public, File.join(Sinatra::Base.root, 'static')
Sinatra::Base.set :dump_errors, true

Sinatra::Base.helpers Sinatra::AppHelpers

run App
