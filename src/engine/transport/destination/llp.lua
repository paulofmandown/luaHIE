local llpSender=TcpSender:extends { }
llpSender.__name='LLP Sender'

function llpSender:__init(data, channelName, logger)
    llpSender.super.__init(self, data, channelName, logger)
    self._startMessageChars=self._configTable.startMessageChars or DEFAULT_LLP_START_OF_MESSAGE
    self._endMessageChars  =self._configTable.endMessageChars or DEFAULT_LLP_END_OF_MESSAGE
end

function llpSender:send(message)
    local SOM       =self._startMessageChars
    local EOM       =self._endMessageChars

    LOGGER:debug("Building LLP payload")
    local llpPayload=SOM..tostring(message)..EOM

    local response=llpSender.super.send(self, llpPayload, EOM)
    if response then
        if not response:match(SOM) then self:_catch(nil, START_OF_MESSAGE_ACK_ERR) end
        if not response:match(EOM) then self:_catch(nil, END_OF_MESSAGE_ACK_ERR) end
        response=response:match(SOM..'(.*)'..EOM)
    end
    return response
end

return llpSender
