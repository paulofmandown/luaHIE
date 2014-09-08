--- An example source with a scriptReader
local function mymessagegenerator()
    local message='Here is a message to be processed and sent.'
    return message
end

local source  ={connectortype='script',          -- Specifies the scriptReader connector
                pollrate     =60,                -- Time in seconds between script execution.
                script       =mymessagegenerator -- The function to be run at execution. Must return a string to process and send.
                }

--- An example destination with a script writer
-- If there is a response from your endpoint,
-- make sure it is returned by this function
local function mymessagewriter(message)
    io.write(message, '\n')
    io.flush()
    return 'SUCCESS: Write Completed.'
end

local dest    ={connectortype='script',        -- Specifies the scriptWriter connector
                script       =mymessagewriter -- The function to accept a received message. Should return a string for logging purposes.
               }

return Channel:new("My Script Channel", source, dest)
