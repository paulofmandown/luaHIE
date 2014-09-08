local fileReader=SourceConnector:extends()
fileReader.__name='File Reader'

function fileReader:__init(data, channelName, logger)
    fileReader.super.__init(self, data, channelName, logger)
    fileReader:_catch(self, self._configTable.dir, NIL_DIR_ERR)
    self._dir=self._configTable.dir
    if not self._dir:match(PATH_SEPARATOR .. "$") then
        self._dir=self._dir .. PATH_SEPARATOR
    end
    self._pollRate=self._configTable.pollrate or DEFAULT_POLL_RATE --Time in seconds
    self._filename=self._configTable.filename or '.*'
    if self._configTable.deletefiles then
        self._delAfterRead=true
    else
        self._delAfterRead=false
    end
    self._toRead={}
end

function fileReader:start()
    local status,result=lfs.mkdir(self._dir)
    if result=="File exists" then status=true end
    return status, result
end

function fileReader:receiveMessage()
    self:_pollForNewFiles()
    return self:_readNextFile()
end

function fileReader:_pollForNewFiles()
    if self._nextPoll and self._nextPoll>self._pollRate then
        return nil
    end
    self._nextPoll=os.clock()+self._pollRate
    LOGGER:debug("Polling %s for pattern(%s)", self._dir, self._filename)
    for file in lfs.dir(self._dir) do
        self:queueFileForRead(file)
    end
end

function fileReader:_readNextFile()
    local file=table.remove(self._toRead)
    if file then
        LOGGER:debug("Reading %s%s", self._dir, file)
        local f=io.open(self._dir .. file)
        local t={}
        while true do
            local s=f:read(2^10)
            if not s then break end
            table.insert(t, s)
            _YIELD()
        end
        f:close()
        if self._delAfterRead then
            os.remove(self._dir .. file)
            LOGGER:info("Deleted File: %s%s", self._dir, file)
        end
        return table.concat(t)
    end
    return nil
end

function fileReader:queueFileForRead(file)
    -- Is not file
    if lfs.attributes(self._dir .. file).mode~='file' then
        return
    end
    -- name is invalid
    if file~=self._filename and not file:match(self._filename) then
        return
    end
    -- Is already queued up
    for k,v in pairs(self._toRead) do
        if v==file then
            return
        end
    end
    LOGGER:info("Queued File For Read: %s%s", self._dir, file)
    table.insert(self._toRead, file)
end

return fileReader
