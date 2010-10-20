##
# Configuration file for main application
##
ApplicationName	= "traf_sim"

## Database settings
DBName  	= "traf_sim"
DBPort  	= 10021
DBHostname	= "devel01"
#DBHostname	= "localhost"

RTMPHost	= "192.168.1.89"

URLMediaShare	= "http://traf_sim.devel.ksonsoftware.com/ms"

FSProdAppLogFile	= "/var/log/thin/traf_sim.app.log"
FSProdErrorLogFile	= "/var/log/thin/traf_sim.error.log"

FSFilesContainer	= "/usr/local/data/traf_sim/files"
FSVideosContainer	= "/usr/local/data/traf_sim/videos"

FSDocRoot	= "/var/www/ksonsoftware.com/dev/traf_sim"

MCServers   = ["devel01:11211"]

SegmentStates = [ "NoData", "WideOpen", "Moderate", "Heavy", "StopAndGo" ]

RoadSystems = [ 2,5,9,14,16,18,26,84,90,99,167,202,205,217,405,500,509,512,518,520,522,525,526,599 ]
