VERSION       ='UNRELEASED'
SPLASH        ='LuaHIE ' .. VERSION .. ' (c)' .. os.date('%Y') .. ' Paul Lewis'
PATH_SEPARATOR=package.config:sub(1,1)

require ('engine' .. PATH_SEPARATOR .. 'init')
LOGGER:debug("LuaHIE engine components loaded")

SERVER:start()
print(SPLASH)
LOGGER:info(SPLASH)
LOGGER:info("Startup in %dms", gettime()-_STARTUP_TIME)
SERVER:run()
