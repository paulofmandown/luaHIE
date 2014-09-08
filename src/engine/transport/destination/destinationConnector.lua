local destConnector = Connector:extends()
destConnector.__name = "Destination Connector"

function destConnector:__init(data, channelName, logger)
    destConnector.super.__init(self, data, channelName, logger, DESTINATION)
    self._transformer=data.transformer
    self.enablequeueing=data.enablequeueing
    LOGGER:debug("Creating new destination: %s", self.name)
end

function destConnector:processNewMessage(xaction)
    local msg,status,message,rsp
    msg=xaction:getMsg()
    status,message=self:transformMessage(msg)
    if not self:queueIsEmpty() then
        LOGGER:debug("Destination %s has messages in its queue", self.name)
        self.logger:info(MSG_QUEUED_LOG, getFormattedDate(), tostring(message))
        return self:writeToQueue(message)
    end
    if status and message then
        status,rsp=self:sendMessage(message)
    else
        self:_catch(status,message)
    end

    xaction:addSentMessage(self, message, rst)
end

function destConnector:transformMessage(msg)
    if not self._transformer then return true, tostring(msg) end
    local tmp=self:_getDataObject()
    LOGGER:debug("Transforming new message")
    local status, results=luahiexpcall(self._transformer, msg, tmp)
    local resultStr=tostring(results)
    if status and results~=false then
        self.logger:info(MSG_TRANSFORMED_LOG, getFormattedDate(), resultStr)
        return true, resultStr
    end
    return status, resultStr
end

function destConnector:sendMessage(message, qfn)
    if not message or not self.send then return false end
    LOGGER:debug("Sending message")
    local results=self:send(message)
    if results then
        if qfn then
            LOGGER:debug("Successfully processed queued message (%s%s), removing from queue", self.queueDir, qfn)
            self.logger:info(MSG_PROCESSED_FROM_Q_LOG, getFormattedDate(), tostring(results or 'No Response'))
            os.remove(self.queueDir .. qfn)
        else
            LOGGER:debug("Successfully processed new message")
            self.logger:info(MSG_SENT_LOG, getFormattedDate())
            if results then
                self.logger:info(RESPONSE_RECEIVED_LOG, getFormattedDate(), tostring(results))
            end
        end
    else
        self._lastSendFailure=gettime()
        if self.enablequeueing then
            self:writeToQueue(message, dest, qfn)
        end
    end
    return results
end

function destConnector:processQueue()
    local status, results= self:sendMessage(self:getNextQueuedMessage())
    return status, results
end

function destConnector:queueIsEmpty()
    if not self.queueDir then return true end
    for file in lfs.dir(self.queueDir) do
        if lfs.attributes(self.queueDir .. file).mode=="file" then
            return false
        end
    end
    return true
end

return destConnector
