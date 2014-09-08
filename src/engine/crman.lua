local crman=Class {
    __name="Coroutine Manager"
}

function crman:__init()
    self._coroutines={}
end

function crman:add(cr, ...)
    local c=coroutine.create(cr)
    local status,results=coroutine.resume(c, ...)
    if status then
        table.insert(self._coroutines, c)
        return true
    else
        LOGGER:error(results)
        return false
    end
end

function crman:step()
    for k,cr in pairs(self._coroutines) do
        local status,result=coroutine.resume(cr)
        if not status then LOGGER:error(result) end
        if coroutine.status(cr)=="dead" then
            self._coroutines[k]=nil
        end
    end
end

return crman
