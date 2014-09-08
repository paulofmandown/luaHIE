local scriptWriter=DestinationConnector:extends { }
scriptWriter.__name='Script Writer'

function scriptWriter:__init(data, channelName, logger)
    scriptWriter.super.__init(self, data, channelName, logger)
    scriptWriter._catch(self, self._configTable.script, NIL_SCRIPT_ERR)
    self._script=self._configTable.script
end

function scriptWriter:send(message)
    LOGGER:debug("Executing script")
    return self._script(tostring(message))
end

return scriptWriter
