local server=Class { }
server.__name='LuaHIE Server'

function server:__init()
    self._pendingConnections={}
    self._activeConnections ={}
    self._coroutineManager  =CR_Manager:new()
    self._channelDir        ='interfaces'
    math.randomseed(gettime())
end

function server:start()
    LOGGER:info("Starting Server")
    self:_catch(luahiexpcall(self._loadChannels, self))
    self:_catch(luahiexpcall(self._initChannels, self))
end

function server:run()
    while true do
        self:update()
        if FORCE_GARBAGE_COLLECT then
            collectgarbage(GC_TYPE, GC_ARG)
        end
        -- debug.debug()
    end
end

function server:update()
    LOGGER:debug("Start Server Update")
    self:_catch(luahiexpcall(self._updateChannels, self))
end

function server:setChannelDir(dir)
    self._channelDir=dir
end

function server:_loadChannels()
    LOGGER:info("Loading Channel(s)")
    self._channels={}
    local dir=self._channelDir
    for file in lfs.dir(dir) do
        if lfs.attributes(dir .. PATH_SEPARATOR .. file, 'mode')=='file' then
            file=file:sub(1,file:find('.lua')-1)
            local c = require(dir .. PATH_SEPARATOR .. file)
            -- Handle outdated (pre_0.3.0 interfaces) IF creation
            -- Removing in 0.4.0
            if c.__name~=Channel.__name then
                c=self:convertPreZeroThreeZeroChannel(c)
            end
            LOGGER:info("Loaded Channel: %s", c.name)
            table.insert(self._channels, c)
        end
    end
end

-- DEPRECATED - Removing in 0.4.0
function server:convertPreZeroThreeZeroChannel(c)
    LOGGER:warn("Please review ./interfaces/examples for details on using luaHIE in v0.3.0 and above.")
    local s=c[1]
    local t=c[2]
    local d=c[3]
    local cnl=Channel:new("Pre 0.3.0 Channel")
    cnl:setSource(s)
    d.transformer=t
    cnl:addDestination(d)
    return cnl
end

function server:_initChannels()
    LOGGER:info("Initializing Channel(s)")
    local startedChannels=0
    for _,c in pairs(self._channels) do
        local status, results=c:init()
        if status and self._coroutineManager:add(c.run, c) then
            startedChannels=startedChannels+1
        else
            LOGGER:error(results)
        end
    end
    local ifsStartedMsg=startedChannels .. ' interfaces successfully started.'
    LOGGER:info(ifsStartedMsg)
end

--- Need to get receiver and sender sockets separately
function server:_updateChannels()
    local sockets={}
    local nextPoll=math.huge
    for _,c in pairs(self._channels) do
        for _,s in pairs(c:getSockets()) do
            table.insert(sockets, s)
        end
        local p=c._receiver:nextPoll()
        nextPoll=p<nextPoll and p or nextPoll
    end
    local t=nextPoll-os.time()
    if t>0 and #sockets>0 then
        socket.select(sockets, {}, DEFAULT_TIMEOUT)
    else
        socket.sleep(CYCLE_WAIT_TIME)
    end
    self._coroutineManager:step()
end

function server:_stopChannels()
    for _,c in pairs(self._channels) do
        if c.started then c:stop() end
    end
end

function server:_catch(status, err)
    if not status then LOGGER:error(err) end
end

return server
