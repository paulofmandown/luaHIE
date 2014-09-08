--- True if you would like to log message that pass through an interface.
-- the received message, response sent, sent message, and response received
-- are all appended to the end of the newest log file
LOG_MESSAGES=true

--- True if you would like received messages to be stored to disk before
-- processing on all channels by default. This option will prevent loss of
-- data if luaHIE crashes while processing a large number of received
-- messages. This option can be turned on for each channel individually
-- by enabling cachemessages on the source connector.
CACHE_RECEIVED_MESSAGES=false

--- Identifies directory where logs will be created and stored.
-- The relative path here is the location of the hie.lua file.
LOGS_DIR='logs'

--- Logging lever passed to LuaLogging object
-- valid entries are:
-- 'DEBUG'
-- 'INFO'
-- 'WARN'
-- 'ERROR'
-- 'FATAL'
LOG_LEVEL='INFO'

--- Max size of log files
-- Once a log file reaches this size (in bytes)
-- it is moved out of the way and a
-- new file is created to store the next message set
MAX_LOG_FILE_SIZE=10000000

--- Number of log files to use
-- for a given interface, only keep this
-- number of log files. Once there are
-- more files than specified, the oldest files
-- are deleted.
MAX_LOG_FILES=10

--- Enabling this will attempt to free unused memory constantly
-- as opposed to waiting on lua to do it.
-- Only has a minor effect on frequency of gc
FORCE_GARBAGE_COLLECT=true

--- Passed to the garbagecollect() call in the main loop if
-- FORCE_GARBAGE_COLLECT is enabled.
-- "collect": performs a full garbage-collection cycle. This is the default option.
-- "stop": stops the garbage collector.
-- "restart": restarts the garbage collector.
-- "count": returns the total memory in use by Lua (in Kbytes).
-- "step": performs a garbage-collection step. The step "size" is controlled by arg (larger values mean more steps) in a non-specified way. If you want to control the step size you must experimentally tune the value of arg. Returns true if the step finished a collection cycle.
GC_TYPE='collect'
-- Used where arg is referenced above.
GC_ARG =nil

--- Specifies the amount of time (in seconds) the server will
-- wait when idle. (-1 will wait forever, don't do that.)
-- Server considers itself idle when polling source
-- connectors are more than 1 second away from their next poll
-- and there are no active source sockets.
CYCLE_WAIT_TIME=.05

--- Specifies the amount of time (in seconds) that a channel will
-- wait before attempting to send queued records between failures.
QUEUE_WAIT_TIME=10

--- A global table designed to be used by the user.
-- init values here and feel free to overwrite in your scripts
USER_TABLE={}

--- Default values used throughout the software
DEFAULT_DEST_HOST             ='127.0.0.1'            -- Default destination IP Address (LLP/TCP Sender)
DEFAULT_DEST_PORT             ='5001'                 -- Default destinations Port (LLP/TCP Sender)
DEFAULT_SEND_TIMEOUT          =10                     -- Time in seconds to wait for the destination to accept the connection
DEFAULT_HL7_MESSAGE           ='MSH|^~\\&\r'          -- Default HL7 message used for Hl7:new()
DEFAULT_POLL_RATE             =60                     -- Time in seconds between execution (Script/File Readers)
DEFAULT_SOURCE_HOST           ='*'                    -- Default source IP Address (LLP/TCP Listener)
DEFAULT_SOURCE_PORT           ='5000'                 -- Default source port (LLP/TCP Listener)
DEFAULT_SOURCE_MAX_CONNECTIONS=10                     -- Default number of incoming connections allowed (LLP/TCP Listener)
DEFAULT_LLP_START_OF_MESSAGE  =string.char(0x0B)      -- Specifies the LLP start of message character
DEFAULT_LLP_END_OF_MESSAGE    =string.char(0x1C,0x0D) -- Specifies the LLP end of message characters
DEFAULT_FTP_PORT              ='21'                   -- Default port to use for ftp connections
DEFAULT_TIMEOUT               =10                     -- Default Socket Timeout (Used for all sockets, not just channels, be careful with this)
DEFAULT_URL_VALUES={url=nil,
                    scheme='http',
                    authority=nil,
                    path=nil,
                    params=nil,
                    query=nil,
                    fragment=nil,
                    userinfo=nil,
                    host=nil,
                    port=nil,
                    user=nil,
                    password=nil
                    }

--- Default Parameters used secure connections.
-- The reference files may or may not exist on your system.
DEFAULT_SSL_SENDER_PARAMS={mode="client",
                           protocol="tlsv1",
                           key="/etc/certs/clientkey.pem",
                           certificate="/etc/certs/client.pem",
                           cafile="/etc/certs/CA.pem",
                           verify="peer",
                           options="all"
                           }
DEFAULT_SSL_RECEIVER_PARAMS={mode = "server",
                             protocol = "tlsv1",
                             key = "/etc/certs/serverkey.pem",
                             certificate = "/etc/certs/server.pem",
                             cafile = "/etc/certs/CA.pem",
                             verify = {"peer", "fail_if_no_peer_cert"},
                             options = {"all", "no_sslv2"},
                             ciphers = "ALL:!ADH:@STRENGTH"
                             }
