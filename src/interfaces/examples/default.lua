local source={connectortype='LLP', datatype='HL7', host='*', port='5000'}

local function xform(msg)
    return msg
end

local destination={
    name='Default Message Destination', -- Name of the Destination (In a future release, logging will be destination-specific)
    connectortype='LLP', -- Transmission Type (TCP, LLP, File, HTTP, Script)
    datatype='HL7', -- Data Type (HL7, Text, X12, XML)
    host='127.0.0.1', -- Destination IP
    port='5001', -- Destination Port
    transformer=xform -- Transformer Function (NEW in 0.3.0)
}

--- Create a new Channel Object
-- Channel:new() takes 3 main arguments:
-- channelName, SourceConnectorTable, and DestinationConnectorTabe.
local myChannel=Channel:new("Default Channel", source, destination)

--- You can pass as many destinations to Channel:new() as you want
-- ie: local c=Channel:new(name, source, destOne, destTwo, destThree, ... )

return myChannel
