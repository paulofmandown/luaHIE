local scriptReader=SourceConnector:extends()
scriptReader.__name='Script Reader'

function scriptReader:__init(data, channelName, logger)
    scriptReader.super.__init(self, data, channelName, logger)
    scriptReader._catch(self, self._configTable.script, NIL_SCRIPT_ERR)

    self._script  =self._configTable.script
    self._pollRate=self._configTable.pollrate or DEFAULT_POLL_RATE
    self._lastPoll=nil
end

function scriptReader:receiveMessage()
    if self._nextPoll and self._nextPoll>self._pollRate then
        return nil
    end
    self._nextPoll=os.clock()+self._pollRate
    LOGGER:debug("Executing Script")
    self._lastPoll=os.clock()
    return self._script()
end

return scriptReader
