local fileWriter=DestinationConnector:extends { }
fileWriter.__name = 'File Writer'

function fileWriter:__init(data, channelName, logger)
    fileWriter.super.__init(self, data, channelName, logger)
    fileWriter._catch(self, data.dir and data.filename, 'Must init file writer with dir and filename')
    self._dir     =self._configTable.dir
    if not self._dir:match(PATH_SEPARATOR .. "$") then
        self._dir=self._dir .. PATH_SEPARATOR
    end
    self._filename=self._configTable.filename
    self._append  =self._configTable.append
    self._eol     =self._configTable.endofline or LF
    local status, err = lfs.mkdir(self._dir)
    fileWriter._catch(self, status, err~='File exists' and err or nil)
end

function fileWriter:send(message)
    local name=type(self._filename)=='function' and self._filename() or self._filename
    local file, results=io.open(self._dir .. name, self._append and 'a' or 'w')
    if file then
        LOGGER:debug("Writing message to file: %s%s", self._dir, name)
        status=self:_catch(file:write(tostring(message) .. self._eol))
        status=self:_catch(file:close())
    else
        self._catch(false, results)
    end
    return status and FILE_WRITTEN_RESPONSE or nil
end

return fileWriter
