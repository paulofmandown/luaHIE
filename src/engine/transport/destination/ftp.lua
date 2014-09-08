local ftpWriter=DestinationConnector:extends { }
ftpWriter.__name='FTP Writer'

function ftpWriter:__init(data, channelName, logger)
    ftpWriter.super.__init(self, data, channelName, logger)
    ftpWriter._catch(self, data.host and data.filename, 'Must init ftpWriter with host and filename')
    self.host=self._configTable.host
    self.port=self._configTable.port or DEFAULT_FTP_PORT
    self.dir =self._configTable.dir
    self.un  =self._configTable.username
    self.pw  =self._configTable.password
    self.filename=self._configTable.filename
end

function ftpWriter:send(message)
    local f=require 'socket.ftp'
    local url={FTP_PROTOCOL}
    if self.un and self.pw then
        table.insert(url, self.un)
        table.insert(url, ':')
        table.insert(url, self.pw)
        table.insert(url, AT)
    end
    table.insert(url, self.host)
    table.insert(url, ':')
    table.insert(url, self.port)
    table.insert(url, "/")
    if self.dir then
        table.insert(url, self.dir)
        if not self.dir:match("/$") then table.insert(url, "/") end
    end
    local fn=self.filename
    table.insert(url, type(fn) == 'function' and fn() or fn)

    local urlStr=table.concat(url)
    LOGGER:debug("Sending message to %s", urlStr)
    local status=self:_catch(f.put(urlStr, tostring(message)))
    return status and FILE_WRITTEN_RESPONSE or nil
end

return ftpWriter
