--- Build Connector Objects
-- SourceConnector must implement start and receiveMessage
-- Provide the normal config info as part of the extends operation
local mySrcCon=SourceConnector:extends {
    datatype="Text",
    processAsBatch=false,
    batchHandler=customBatchingFunction,
    useCache=false,
    filter=filterFunction
}
-- start must return true for the channel to be loaded
-- You can return false and an error message if something goes wrong during this process
function mySrcCon:start()
    print("Running Start")
    local status=true
    return status, status and "Successful Start" or "Start Failed"
end
-- receiveMessage must return a string copy of a message to be processed or nil
function mySrcCon:receiveMessage()
    print("Receiving Message")
    return "message string"
end

-- DestinationConnector must implement send
local myDestCon=DestinationConnector:extends {
    transformer=function(msg)
        msg:setData("Transformed", 1, 2)
        return msg
    end,
    datatype="Text",
    enablequeueing=false
}
function myDestCon:send(msg)
    print("Sending Message: ", msg)
end

local myChannel=Channel:new("My Custom Channel", mySrcCon, myDestCon)
return myChannel
