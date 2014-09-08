local channel=Class { }
channel.__name='Channel'

function channel:__init(name, source, ... )
    self.name=name or "Channel"
    LOGGER:debug("Initializing Channel: %s", tostring(name))
    self.logger=GET_CHANNEL_LOGGER(self.name)
    self._destinations={}
    if source then
        self._receiver=channel.createSourceConnector(source, self.name, self.logger)
    end
    local dests={ ... }
    for _,d in pairs(dests) do
        channel.addDestination(self, d)
    end
end

function channel:getSourceConnector() return self._receiver end
function channel:getDestinationConnectors() return self._destinations end

function channel:setSource(s)
    self._receiver=channel.createSourceConnector(s, self.name, self.logger)
    LOGGER:info("Channel (%s) Set Source: %s", self.name, s.connectortype)
end

function channel:addDestination(d)
    local dest=channel.createDestinationConnector(d, self.name, self.logger)
    table.insert(self._destinations, dest)
    LOGGER:info("Channel (%s) Added Destination: %s", self.name, dest.name)
end

function channel:init()
    LOGGER:debug("Starting Channel: %s", self.name)
    return self._receiver:start()
end

function channel:stop() end

function channel:run()
    while true do
        self:processNewMessage()
        self:processQueues()
        _YIELD()
    end
end

function channel:processNewMessage()
    LOGGER:debug("Channel (%s), checking for new message", self.name)
    local transaction=self:startTransaction()
    if not transaction then return end
    LOGGER:debug("Got new message, sending to destination(s)")
    self.logger:info(MSG_RECEIVED_LOG, getFormattedDate(), transaction:getRawData())
    for _,dest in pairs(self._destinations) do
        dest:processNewMessage(transaction)
    end
end

function channel:processQueues()
    LOGGER:debug("Checking destination queues")
    local qLog={QUEUE_PROCESSED_LOG}
    for _,dest in pairs(self._destinations) do
        local status,rsp=dest:processQueue()
        if status then
            table.insert(qLog, string.format(DEST_QUEUE_PROCESSED_LOG, dest.name))
        end
    end
    return qLog
end

function channel:startTransaction()
    local startTime=getFormattedDate()
    local message=self._receiver:resume()
    return message and Transaction:new(startTime, self._receiver, message)
end

function channel:getSockets()
    return self._receiver:getSockets()
end

function channel.createSourceConnector(config, name, logger)
    if getmetatable(config)==SourceConnector then
        LOGGER:debug("Receiving source connector for channel: %s", name)
        return config:new(config, name, logger)
    end
    LOGGER:debug("Building Source Connector of type %s for channel %s", tostring(config.connectortype), name)
    local con=SourceConnector
    local t=config.connectortype or 'LLP'
    t=t:upper()
    if t=='TCP' then
        con=TcpListener
    elseif t=='LLP' then
        con=LlpListener
    elseif t=='FILE' then
        con=FileReader
    elseif t=='SCRIPT' then
        con=ScriptReader
    elseif t=='FTP' then
        con=FtpReader
    end
    return con:new(config, name, logger)
end

function channel.createDestinationConnector(config, name, logger)
    if getmetatable(config)==DestinationConnector then
        LOGGER:debug("receiving destination connector")
        return config:new(config, name, logger)
    end
    local con=DestinationConnector
    LOGGER:debug("building Destination Connector of type %s", tostring(config.connectortype))
    local t=config.connectortype or 'LLP'
    t=t:upper()
    if t=='TCP' then
        con=TcpSender
    elseif t=='LLP' then
        con=LlpSender
    elseif t=='FILE' then
        con=FileWriter
    elseif t=='SCRIPT' then
        con=ScriptWriter
    elseif t=='FTP' then
        con=FtpWriter
    elseif t=='HTTP' then
        con=HTTPSender
    elseif t=='CUSTOM' then
        return con
    end
    return con:new(config, name, logger)
end

return channel
