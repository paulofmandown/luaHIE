--- A custom response building function
local function buildResponse(originalMessage, status)
    return status and 'Message received successfully' or 'Error receiving message'
end

--- An example source connector with an TCPListener and the XML datatype.
local source={ -- These elements configure the TCP Connector
               connectortype    ='TCP',  -- Specifies that this is an TCP server
               host             ='*',    -- Specifies the Listen IP address. ('*' Will listen for all incoming connections)
               port             ='5000', -- Specifies the incoming port
               receiveTimeout   =10,     -- Time in seconds to keep a connection open before timing out.
               maxConnections   =10,     -- Specifies the max number of concurrent inbound connections
               responder        =buildResponse, -- A function that will generate responses to be sent to the sending entity
                                                   -- Responses are only sent when this element is populated.
               datatype         ='XML' -- Specifies that this connector will receive XML data.
             }

--- An example destination connector with an TCPListener.
-- Destinations do not need a datatype, They receive a string and send only what is received.
local dest  ={ -- These elements configure the TCP Connector
               connectortype    ='TCP',       -- Specifies that this is an TCP Sender
               host             ='127.0.0.1', -- Specifies the destination IP address
               port             ='5000',      -- Specifies the destination port
               sendtimeout      =10           -- Time in seconds to wait for the destination to accept the connection
             }

return Channel:new("My TCP Channel", source, dest)
