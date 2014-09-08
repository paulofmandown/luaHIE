local tcpListener=SourceConnector:extends()
tcpListener.__name='TCP Listener'

function tcpListener:__init(data, channelName, logger)
    tcpListener.super.__init(self, data, channelName, logger)
    self._host               =self._configTable.host or DEFAULT_SOURCE_HOST
    self._port               =self._configTable.port or DEFAULT_SOURCE_PORT
    self._timeout            =self._configTable.receiveTimeout or DEFAULT_TIMEOUT
    self._maxConnections     =self._configTable.maxConnections or DEFAULT_SOURCE_MAX_CONNECTIONS
    self._buildCustomResponse=self._configTable.responder
    self._startMessageChars=self._configTable.startMessageChars
    self._endMessageChars  =self._configTable.endMessageChars

    self._openConnections  ={}
end

function tcpListener:start()
    LOGGER:debug("Starting socket listener on %s:%s", self._host, self._port)
    local status
    local s=socket.tcp()
    if s then
        status=self:_catch(s:bind(self._host, self._port) and s:listen(self._maxConnections))
        s:settimeout(0)
        self._srvr=s
    end
    return status
end

function tcpListener:receiveMessage()
    self:_checkForNewConnection()
    return self:_checkForMessages()
end

function tcpListener:_checkForNewConnection()
    local c,err=self._srvr:accept()
    if c then
        LOGGER:debug("Accepting new connection from %s:%s", c:getpeername())
        c:settimeout(0)
        table.insert(self._openConnections, c)
    elseif err~=TIMEOUT_ERR then self:_catch(nil, err) end
end

function tcpListener:_checkForMessages()
    local SOM=self._startMessageChars
    local EOM=self._endMessageChars
    for k,v in pairs(self._openConnections) do
        local message={}
        if self._useSSL then
            self:_catch(tcpListener.super.secure(self, v))
        end
        local stats
        while true do
            local s,r=self:receiveBytes(k, v, message)
            if not s then break end
            if EOM then
                local j=1
                for i=#message-#EOM+1,#message+1 do
                    if message[i]==EOM:sub(j,j) then
                        j=j+1
                    end
                end
                if j>#EOM then break end
            end
            _YIELD()
        end
        if #message<1 then return end
        message=table.concat(message)
        LOGGER:debug(message)
        if SOM and EOM then
            self:_catch(message:match(SOM), START_OF_MESSAGE_ERR)
            self:_catch(message:match(EOM), END_OF_MESSAGE_ERR)
            message=message:match(SOM..'(.*)'..EOM)
        end
        local filterstatus=self:_doFilter(message)
        local rsp=self:_buildResponse(message, filterstatus)
        if rsp then self:_catch(v:send(SOM..rsp..EOM)) end
        return message, true, filterstatus
    end
end

function tcpListener:receiveBytes(clientId, client, messageTable)
    local limit=2^10
    for i=1,limit do
        local byte,err=client:receive(1)
        if byte then
            table.insert(messageTable, byte)
        else
            self._catch(err~=TIMEOUT_ERR and err~=CLOSED_ERR, err)
            if err==CLOSED_ERR then
                self._openConnections[clientId]=nil
            end
            return false
        end
    end
    return true
end

function tcpListener:_buildResponse(msg, status)
    if self._buildCustomResponse then
        return self._buildCustomResponse(msg, status)
    end
    return nil
end

function tcpListener:getSockets()
    local t={}
    for _,v in pairs(self._openConnections) do
        table.insert(t, v)
    end
    return t
end

return tcpListener
