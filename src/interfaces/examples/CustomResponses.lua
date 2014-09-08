--- A custom response building function
local function buildResponse(originalMessage, status)
    local msg=HL7:new(originalMessage)
    local ack=HL7:new()
    ack:setData(msg:getData('MSH', 3, 1), 'MSH', 5, 1)
    ack:setData(msg:getData('MSH', 4, 1), 'MSH', 6, 1)
    ack:setData(msg:getData('MSH', 10, 1), 'MSH', 10, 1)
    local code=status and "AA" or "AE"
    ack:setData(code, 'MSA', 1, 1)
    ack:setData(getDate(), 'MSA', 2, 1)
    return tostring(ack)
end

local source={
    responder=buildResponse, -- A function that will generate responses to be sent to the sending entity
                             -- Except for LLP Receivers, responses are only sent when this element is populated.
    connectortype='LLP',
    host='*',
    port='5000',
    maxConnections=10,
    startMessageChars=string.char(0x0B),
    endMessageChars=string.char(0x1C,0x0D),
    datatype='HL7'
}

local dest={
    connectortype='LLP',
    host='127.0.0.1',
    port='5000',
    sendtimeout=10,
    startMessageChars=string.char(0x0B),
    endMessageChars=string.char(0x1C,0x0D)
}

return Channel:new("My LLP Channel", source, dest)

