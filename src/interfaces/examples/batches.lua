local function myBatchProcessor(msg, rsp)
    local t={}
    local tmpMsg
    for _,k in msg:segments() do
        local segType=k._type
        if segType == 'MSH' then
            if tmpMsg ~= '' then table.insert(t, tmpMsg) end
            tmpMsg=''
        end
        if not segType:match('[B|F][H|T]S') then
            tmpMsg=tmpMsg .. msg._segmentSeparator .. tostring(k)
        end
    end
    return t
end

local source={
    processAsBatch=true, -- Set processAsBatch to true to enable batch processing on the source
    batchHandler=myBatchProcessor, -- Set a custom function to split batches.
                                   -- Function should receive a luaHIE object and return a table of strings.
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
