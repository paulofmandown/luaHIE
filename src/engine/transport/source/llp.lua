local llpListener=TcpListener:extends()
llpListener.__name='LLP Listener'

function llpListener:__init(data, channelName, logger)
    if not data.startMessageChars then
        data.startMessageChars=DEFAULT_LLP_START_OF_MESSAGE
    end
    if not data.endMessageChars then
        data.endMessageChars=DEFAULT_LLP_END_OF_MESSAGE
    end
    llpListener.super.__init(self, data, channelName, logger)
end

function llpListener:_buildResponse(msg, status)
    local rsp=llpListener.super._buildResponse(self, msg, status)
    if rsp then return rsp end
    msg=self._datatype:new(msg, self._configTable)
    local ack=self._datatype:new(nil, self._configTable)
    ack:setData(msg:getData('MSH', 3, 1), 'MSH', 5, 1)
    ack:setData(msg:getData('MSH', 4, 1), 'MSH', 6, 1)
    ack:setData(msg:getData('MSH', 10, 1), 'MSH', 10, 1)
    local code=status and "AA" or "AE"
    ack:setData(code, 'MSA', 1, 1)
    ack:setData(getDate(), 'MSA', 2, 1)
    return tostring(ack)
end

return llpListener
