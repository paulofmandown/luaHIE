local tcpSender=DestinationConnector:extends { }
tcpSender.__name='TCP Sender'

function tcpSender:__init(data, channelName, logger)
    tcpSender.super.__init(self, data, channelName, logger)
    self._host=self._configTable.host or DEFAULT_DEST_HOST
    self._port=self._configTable.port or DEFAULT_DEST_PORT
    self._timeout=self._configTable.sendtimeout or DEFAULT_SEND_TIMEOUT
    self._useSSL=self._configTable.useSSL
    if self._useSSL then
        self._sslParams=DEFAULT_SSL_SENDER_PARAMS
        for k,v in pairs(self._configTable.sslParams) do
            self._sslParams[k]=v
        end
    end
    tcpSender.testConnection(self)
end

function tcpSender:testConnection()
    LOGGER:debug("Testing connection to %s:%s", self._host, self._port)
    local status,c,err
    c,err=socket.connect(self._host, self._port)
    if c then
        if self._useSSL then
            self:_catch(tcpSender.super.secure(self, c))
        end
        c:close()
    else
        self:_catch(c, err)
    end
end

function tcpSender:send(message, endOfResponse)
    LOGGER:debug("Sending message to %s:%s", self._host, self._port)
    local status, client=self:_sendData(message)
    if status and client and not client then
        self:_getResponse(client, endOfResponse)
    end
end

function tcpSender:_sendData(data)
    local client=self:_catch(socket.connect(self._host, self._port))
    if not client then return end
    client:settimeout(self._timeout)

    if self._useSSL then
        self:_catch(tcpSender.super.secure(self, client))
    end
    local status,details=client:send(tostring(message))
    self:_catch(status, details)
    return status, client
end

function tcpSender:_getResponse(c, endOfResponse)
    local response=''
    while true do
        local byte=self:_catch(c:receive(1))
        if byte then
            response=response..byte
        else
            self:_catch(c:close())
            break
        end

        if response:sub(#response-#endOfResponse+1, #response+1)==endOfResponse then
            self:_catch(c:close())
            break
        end
    end
    print(response)
    c:close()
    return response
end

return tcpSender
