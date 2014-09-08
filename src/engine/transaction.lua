local transaction=Class { }
transaction.__name='Transaction Record Object'

function transaction:__init(startTime, sourceConnector, receivedMessage, sentResponse, sourceError)
    if sourceError then
        self._erredOnSource=true
    end
    self._startTime=startTime or gettime()
    local status=sourceError and MESSAGE_STATUS.ERROR or MESSAGE_STATUS.RECEIVED
    self._receivedMessage=Message:new(sourceConnector, status, receivedMessage, sentResponse, sourceError)
    self._sentMessages={}
    self._processedQueueMessages={}
end

function transaction:getRawData() return self._receivedMessage._data end
function transaction:getMsg() return self._receivedMessage:getDataObject() end

function transaction:addSentMessage(destinationConnector, sentMessage, receivedResponse)
    local status=destinationError and MESSAGE_STATUS.ERROR or qfn and MESSAGE_STATUS.QUEUED or MESSAGE_STATUS.SENT
    local m=Message:new(destinationConnector, status, sentMessage, receivedResponse)
    table.insert(self._sentMessages, m)
    self._finishedTime=getFormattedDate()
end

return transaction
