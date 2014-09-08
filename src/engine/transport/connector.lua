local connector=Class { }
connector.__name='Connector Object'

function connector:__init(data, name, logger, ctype)
    LOGGER:debug("Initializing Connector of type: %s, with datatype: %s", data.connectortype or "Custom", data.datatype or "Text(Default)")
    self._configTable=data
    self._datatype=connector.createDataType(data.datatype)
    self.name=data.name or ''
    self.logger=logger
    if not data.name then
        for _,v in pairs(data) do
            if type(v)=="string" then
                self.name=self.name .. v:match("[%w%d%.]*")
            end
        end
    end
    connector.createQueueDir(self, name, ctype)
end

function connector:_getDataObject(message)
    if self._datatype then
        return self._datatype:new(message, self)
    end
    return message
end

function connector:start() return true end

-- Receive a socket and establish an ssl connection with it
function connector:secure(conn)
    LOGGER:debug("Securing Socket")
    conn = ssl.wrap(conn, self._sslParams)
    conn:settimeout(self._timeout)
    local succ, msg
    while not succ do
        succ, msg = conn:dohandshake()
        if msg == "wantread" then
            socket.select({conn}, nil)
        elseif msg == "wantwrite" then
            socket.select(nil, {conn})
        else
            return false, msg
        end
        _YIELD()
    end
    return succ
end

function connector:_catch(status, err)
    if not status then LOGGER:error(debug.traceback(err, 2)) end
    return status
end

function connector.createDataType(t)
    if t then
        t=t:upper()
        if t=='HL7' then
            return Hl7
        elseif t=='XML' then
            return Xml
        elseif t=='X12' or t=='EDI' then
            return X12
        end
    end
    return Text
end

function connector:createQueueDir(channelName, ctype)
    LOGGER:debug("Creating queue/cache dir with args: %s", channelName)
    local dirTable={
        LOGS_DIR,
        channelName
    }
    if ctype==SOURCE then
        table.insert(dirTable, SOURCE_QUEUE)
    else
        table.insert(dirTable, DEST_QUEUE)
        table.insert(dirTable, self.name)
    end
    local dirStr=''
    for _,v in pairs(dirTable) do
        dirStr=dirStr .. v .. PATH_SEPARATOR
        lfs.mkdir(dirStr)
    end
    self.queueDir=dirStr
end

function connector:writeToQueue(message, qfn)
    if not message or message=='' then return end
    qfn=qfn or gettime()
    local dir=self.queueDir
    local f=io.open(dir .. qfn, 'w')
    if f then
        LOGGER:debug("Writing message to queue: %s%s", self.queueDir, qfn)
        f:write(message)
        f:close()
    end
end

function connector:getNextQueuedMessage()
    local qfile=nil
    for file in lfs.dir(self.queueDir) do
        if lfs.attributes(self.queueDir .. file).mode=="file" then
            if not qfile or file<qfile then
                qfile=file
            end
        end
    end
    if not qfile then return nil end
    LOGGER:debug("Getting next message from queue: %s%s", self.queueDir, qfile)
    local f=io.open(self.queueDir .. qfile, 'r')
    local data=f:read("*a")
    if data=="" then data=nil end
    f:close()
    return data, qfile
end

function connector:getSockets() return {} end

return connector
