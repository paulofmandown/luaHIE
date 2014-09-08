local message=Class { }
message.__name='Message Object'

function message:__init(connector, status, data, response, err, qfn)
    self._connector=connector
    self._status=status
    self._data=tostring(data)
    self._response=response~='' and response
    self._error=err
    self._date=getFormattedDate()
    message.setQueueFileName(self, qfn)
end

function message:getDataObject()
    return self._connector:_getDataObject(self._data)
end

function message:getConnector() return self._connector end
function message:getData() return self._data end
function message:getDate() return self._date end
function message:getError() return self._error end
function message:getResponse() return self._response end
function message:getStatus() return self._status end
function message:getQueueFileName() return self._queuefilename end

function message:setId(id) self._id=id end
function message:setData(data) self._data=data end
function message:setDate(date) self._date=date end
function message:setResponse(resp) self._response=resp end

function message:setError(err)
    self._error=err
    self:setStatus(MESSAGE_STATUS.ERROR)
end

function message:setStatus(status)
    if type(status)=='number' then
        self._status=status
    end
end

function message:setQueueFileName()
    self._queuefilename=gettime()
end

return message
