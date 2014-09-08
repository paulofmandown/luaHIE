require 'socket'
require('engine' .. PATH_SEPARATOR .. 'lib' .. PATH_SEPARATOR .. 'newFuncs')
_STARTUP_TIME=gettime()

require 'config'

LOGGER_GEN=require('engine' .. PATH_SEPARATOR .. 'lib' .. PATH_SEPARATOR .. 'logging.rolling_file')
local logName='logs' .. PATH_SEPARATOR .. 'luaHIE.log'
LOGGER=LOGGER_GEN(logName, MAX_LOG_FILE_SIZE, MAX_LOG_FILES)
LOGGER:setLevel(LOG_LEVEL)
LOGGER:debug('Logger Started')

local e={}
local function isModuleAvailable(name)
    if package.loaded[name] then
        return true
    else
    for _, searcher in ipairs(package.searchers or package.loaders) do
        local loader = searcher(name)
            if type(loader) == 'function' then
                package.preload[name] = loader
                return true
            end
        end
        table.insert(e, name)
        return false
    end
end

-- Load Deps
if isModuleAvailable('lfs') then
    require 'lfs'
end
if isModuleAvailable('ssl') then
    require 'ssl'
end
if isModuleAvailable('https') then
    require 'https'
end
if isModuleAvailable('LuaXml') then
    require 'LuaXml'
end

if #e>0 then
    local s=''
    if #e>1 then
        if #e>2 then
            while #e>2 do
                s=s .. table.remove(e, 1) .. ', '
            end
        end
        s=s .. table.remove(e, 1) .. (s:find(',') and ',' or '') .. ' and '
    end
    s=s .. table.remove(e, 1)
    s='The module(s) ' .. s .. ' are missing.\nSome channels may not function properly\nPlease install ' .. s .. '.\n'

    LOGGER:warn(s)
end

-- Load Objects
function GET_CHANNEL_LOGGER(name)
    local filename = 'logs' .. PATH_SEPARATOR .. name .. PATH_SEPARATOR .. 'channel.log'
    return LOGGER_GEN(filename, MAX_LOG_FILE_SIZE, MAX_LOG_FILES)
end

function _YIELD()
    if coroutine.running() then
        coroutine.yield()
    end
end

Class    =require('engine' .. PATH_SEPARATOR .. 'lib' .. PATH_SEPARATOR .. '30log')
CR_Manager=require('engine' .. PATH_SEPARATOR .. 'crman')
SERVER   =require('engine' .. PATH_SEPARATOR .. 'server'):new()
Channel  =require('engine' .. PATH_SEPARATOR .. 'channel')
Connector=require('engine' .. PATH_SEPARATOR .. 'transport' .. PATH_SEPARATOR .. 'connector')
SourceConnector=require('engine' .. PATH_SEPARATOR .. 'transport' .. PATH_SEPARATOR .. 'source' .. PATH_SEPARATOR .. 'sourceConnector')
DestinationConnector=require('engine' .. PATH_SEPARATOR .. 'transport' .. PATH_SEPARATOR .. 'destination' .. PATH_SEPARATOR .. 'destinationConnector')
Message  =require('engine' .. PATH_SEPARATOR .. 'message')
Transaction=require('engine' .. PATH_SEPARATOR .. 'transaction')

local sorcPath='engine' .. PATH_SEPARATOR .. 'transport' .. PATH_SEPARATOR .. 'source' .. PATH_SEPARATOR
local destPath='engine' .. PATH_SEPARATOR .. 'transport' .. PATH_SEPARATOR .. 'destination' .. PATH_SEPARATOR
local dataPath='engine' .. PATH_SEPARATOR .. 'data' .. PATH_SEPARATOR

-- Sources
FileReader  =require(sorcPath .. 'file')
FtpReader   =require(sorcPath .. 'ftp')
ScriptReader=require(sorcPath .. 'script')
TcpListener =require(sorcPath .. 'tcp')
LlpListener =require(sorcPath .. 'llp')

-- Destinations
FileWriter  =require(destPath .. 'file')
FtpWriter   =require(destPath .. 'ftp')
HTTPSender  =require(destPath .. 'http')
ScriptWriter=require(destPath .. 'script')
TcpSender   =require(destPath .. 'tcp')
LlpSender   =require(destPath .. 'llp')

-- Datatypes
Hl7         =require(dataPath .. 'hl7')
HL7Segment  =require(dataPath .. 'hl7Segment')
Text        =require(dataPath .. 'text')
X12         =require(dataPath .. 'x12')
X12Segment  =require(dataPath .. 'x12Segment')
Xml         =require(dataPath .. 'xml')

-- Static
ACK_RECEIVED_LOG        ='# Response Received'
ACK_SENT_LOG            ='# Response Sent'
AT                      ='@'
CHANNEL_START_ERR       ='ERROR: Problem encountered while starting channel (%s)'
CLOSED_ERR              ='closed'
CR                      ='\r'
DATE_PATTERN            ='%x %X'
DEAD_DESTINATION_ERR    ='Destination has died, message not sent. (Usually this means a destination failed to connect at startup.)'
DEST_QUEUE              ='destination_queue'
DEST_QUEUE_PROCESSED_LOG='Message processed from %s'
END_OF_MESSAGE_ACK_ERR  ='No End of Message Char in ACK'
END_OF_MESSAGE_ERR      ='No End of Message Char in Message Received'
FILE_WRITTEN_RESPONSE   ='SUCCESS: File Writen'
FTP_PROTOCOL            ='ftp://'
LF                      ='\n'
MSG_RECEIVED_LOG        ='# Message Received @ %s\n%s'
MSG_TRANSFORMED_LOG     ='# Message Transformed @ %s\n%s'
MSG_SENT_LOG            ='# Message Sent @ %s\n'
MSG_PROCESSED_FROM_Q_LOG='# Message Sent from Queue @ %s\n%s'
MSG_QUEUED_LOG          ='# Message Picked up from Queue @ %s\n%s'
NIL_DIR_ERR             ='Must init file connector with dir'
NIL_SCRIPT_ERR          ='Must init script connector with script'
NO_CHANNELS_LOADED_ERR  ='No channels were loaded'
QUEUE_PROCESSED_LOG     ='Messages Sent From Queue'
RECEIVER_ERROR_LOG      ='# Receiver ERROR'
RESPONSE_RECEIVED_LOG   ='# Response Received @%s\n%s'
SENDER_ERROR_LOG        ='# Sender ERROR'
SOURCE_QUEUE            ='source_queue'
SQL_NULL                ='NULL'
START_OF_MESSAGE_ACK_ERR='No Start of Message Char in ACK'
START_OF_MESSAGE_ERR    ='No Start of Message Char in Message Received'
TIMEOUT_ERR             ='timeout'
TRANSACTION_STARTED_LOG ='Transaction started @ %s'
TRANSACTION_FINISHED_LOG='Transaction completed @ %s'
-- Enum
MESSAGE_STATUS={}
MESSAGE_STATUS.RECEIVED   =1
MESSAGE_STATUS.TRANSFORMED=2
MESSAGE_STATUS.SENT       =3
MESSAGE_STATUS.ERROR      =4
MESSAGE_STATUS.FILTERED   =5
MESSAGE_STATUS.QUEUED     =6

SOURCE=1
DESTINATION=2

local custDir="custom_lib"
for file in lfs.dir(custDir) do
    local fullName=custDir .. PATH_SEPARATOR .. file
    -- Is a lua file
    if lfs.attributes(fullName).mode=='file' and file:sub(#file-3)==".lua" then
        pcall(dofile, fullName)
    end
end
