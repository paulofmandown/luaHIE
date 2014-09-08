function string:split(delim, maxNb)
    -- Eliminate bad cases...
    if string.find(self, delim) == nil then
        return { self }
    end
    local result = {}
    if delim == '' or not delim then
        for i=1,#self do
            result[i]=self:sub(i,i)
        end
        return result
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(self, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(self, lastPos)
    end
    return #result>1 and result or {self}
end

function string:rpad(c, n)
    if not c or not n or n==0 then return self
    elseif n==1 then return self..c end
    local s=''
    while #s < n do s=s..c end
    return self..s
end

function write(str)
    io.write(str..'\n')
end
function gettime()
    return tostring(socket.gettime()*1000):match("^%d*")
end
function getFormattedDate()
    local ms=tostring(socket.gettime()):match("%.(%d?%d?%d?)")
    return os.date(DATE_PATTERN) .. "." .. ms
end
function getDate()
    local ms=tostring(socket.gettime()):match("%.(%d?%d?%d?)")
    return os.date('%Y%m%d%H%M%S') .. ms
end
function luahiexpcall(foo, ... )
    local args={ ... }
    return xpcall(function() return foo(unpack(args)) end, debug.traceback)
end
