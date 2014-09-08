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

local source={ -- These elements configure the LLP Connector
               connectortype    ='LLP',  -- Specifies that this is an LLP server
               host             ='*',    -- Specifies the Listen IP address. ('*' Will listen for all incoming connections)
               port             ='5000', -- Specifies the incoming port
               maxConnections   =10,     -- Specifies the max number of concurrent inbound connections
               startMessageChars=string.char(0x0B),      -- Specifies the LLP start of message character
               endMessageChars  =string.char(0x1C,0x0D), -- Specifies the LLP end of message characters
               datatype         ='HL7' -- Specifies that this connector will receive HL7 data.
             }

--- An example destination connector with an LLPListener.
-- Destinations do not need a datatype, They receive a string and send only what is received.
local dest  ={ -- These elements configure the LLP Connector
               connectortype    ='LLP',       -- Specifies that this is an LLP Sender
               host             ='127.0.0.1', -- Specifies the destination IP address
               port             ='5000',      -- Specifies the destination port
               sendtimeout      =10,          -- Time in seconds to wait for the destination to accept the connection
               startMessageChars=string.char(0x0B),     -- Specifies the LLP start of message character
               endMessageChars  =string.char(0x1C,0x0D),-- Specifies the LLP end of message characters
               datatype         ='HL7'        -- This connector will send HL7 data.
             }

return Channel:new("My LLP Channel", source, dest)
