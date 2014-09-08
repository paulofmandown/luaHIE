local ftpReader=SourceConnector:extends()
ftpReader.__name='FTP Writer'

function ftpReader:__init(data, channelName, logger)
    ftpReader.super.__init(self, data, channelName, logger)
    ftpReader._catch(self, data.host and data.filename, 'Must init ftpReader with host and filename')
    self.host=self._configTable.host
    self.port=tonumber(self._configTable.port or DEFAULT_FTP_PORT)
    self.dir =self._configTable.dir or ""
    self.un  =self._configTable.username
    self.pw  =self._configTable.password
    self.filename=self._configTable.filename
    self._pollRate=self._configTable.pollrate or DEFAULT_POLL_RATE
    self._delete=self._configTable.delete
    self._url=ftpReader._buildURL(self)
end

function ftpReader:receiveMessage()
    if self._nextPoll and self._nextPoll>self._pollRate then
        return nil
    end
    self._nextPoll=os.clock()+self._pollRate
    local f=require 'socket.ftp'
    local url=self._url
    LOGGER:debug("Polling %s", url)
    local conf,sink=self:_buildConfig()
    local status, contents=f.get(conf)
    if not status then
        LOGGER:error(contents)
        return nil
    end
    if self._delete then
        local u=require 'socket.url'
        local l=require 'ltn12'
        local t={}
        local p=u.parse(url)
        p.command="DELE"
        p.sink=l.sink.table(t)
        self:_catch(f.get(p))
    end
    return table.concat(sink)
end

function ftpReader:_buildConfig()
    local t={}
    local l=require 'ltn12'
    local u=require 'socket.url'
    local fn=self.filename
    local c=u.parse(self._url)
    c.sink=l.sink.table(t)
    return c, t
end

function ftpReader:_buildURL()
    local urltbl={FTP_PROTOCOL}
    if self.un and self.pw then
        table.insert(urltbl, self.un)
        table.insert(urltbl, ':')
        table.insert(urltbl, self.pw)
        table.insert(urltbl, AT)
    end
    table.insert(urltbl, self.host)
    table.insert(urltbl, ':')
    table.insert(urltbl, self.port)
    table.insert(urltbl, '/')
    if self.dir then
        table.insert(urltbl, self.dir)
        if not self.dir:match("/$") then
            table.insert(urltbl, '/')
        end
    end
    local fn=self.filename
    table.insert(urltbl, type(fn) == 'function' and fn() or fn)
    return table.concat(urltbl)
end

return ftpReader
