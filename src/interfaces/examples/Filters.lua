function myFilter(msg)
    if msg:getData('MSH', 9, 1) == "A08" then
        return false
    else
        return true
    end
end

local source={
    filter=myFilter, -- Function to reject message at source so no destinations process it.
                     -- Return true to allow message, false to reject
                     -- Filters are applied pre-unbatching, plan accordingly.
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

