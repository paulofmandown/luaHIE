local source = Connector:extends { }
source.__name = "Source Connector"

function source:__init(data, name, logger)
    source.super.__init(self, data, name, logger, SOURCE)
    LOGGER:debug("Creating new source: %s", self.name)
    self.processAsBatch=data.processAsBatch
    self.batchHandler=data.batchHandler
    self.useCache=data.cachemessages or CACHE_RECEIVED_MESSAGES
    self.filter=data.filter
    self._unprocessed={}
end

function source:start() return true end

function source:resume()
    local msg, didFilter, filterStatus=self:receiveMessage()
    if msg then
        if didFilter then
            if not filterStatus then return end
        elseif not self:_doFilter(msg) then
            return
        end
        if self.processAsBatch then
            self:_handleBatch(msg)
        else
            self:_addUnprocessedMessage(msg)
        end
    end
    return self:nextMessage()
end

function source:nextPoll() return self._nextPoll or math.huge end

function source:_doFilter(msg)
    if self.filter and not self.filter(self._datatype:new(msg)) then
        LOGGER:info("Source %s: Rejected message from filter", self.name)
        return false
    end
    return true
end

function source:_addUnprocessedMessage(msg)
    LOGGER:debug("Source %s: Adding unprocessed message")
    if self.useCache then
        self:_writeToCache(msg)
    else
        table.insert(self._unprocessed, msg)
    end
end

function source:_writeToCache(msg)
    local qfn=gettime()
    LOGGER:debug("Source %s: writing unprocessed message to cache", self.name)
    self:writeToQueue(msg, qfn)
end

function source:_handleBatch(msg)
    LOGGER:debug("Source %s: starting unbatching", self.name)
    local message=self._datatype:new(msg, self)
    if self._configTable.batchHandler then
        return self._configTable.batchHandler(msg)
    end
    local t=message:unbatch()
    for _,v in pairs(t) do
        self:_addUnprocessedMessage(v)
    end
end

function source:nextMessage()
    if self.useCache then
        local m,f=self:getNextQueuedMessage()
        os.remove(self.queueDir .. f)
        return m
    else
        return table.remove(self._unprocessed, 1)
    end
end

return source
