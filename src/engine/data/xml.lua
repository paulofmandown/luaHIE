local Xml=Class { }
Xml.__name='XML Message Object'
Xml._type='XML'
function Xml:__init(dataStr)
    self._data=xml.eval(dataStr)
end

function Xml:__tostring()
    return tostring(self._data)
end

-- Give a full path
function Xml:getData( ... )
    local arg={ ... }
    local x=self._data
    local i=1
    while true do
        if not x then return nil end
        if type(x)=='string' then return x end
        x=self._findTagInBlock(x, arg[i])
        i=i+1
    end
end

-- Give newData, then a full path, overwrites existing tags if available or inserts a new tag.
function Xml:setData(data, ... )
    local arg={ ... }
    local x=self._data
    local parent=nil
    i=1
    while true do
        if type(x)=='string' then return nil end
        if not arg[i] then
            x[1]=data
            break
        end
        local pId=nil
        x, parent, pId=self._findTagInBlock(x, arg[i])
        if not x then
            parent[pId]={}
            parent[pId][0]=arg[i]
            if i==#arg then
                parent[pId][1]=data
                return nil
            end
            x=parent[pId]
        end
        i=i+1
    end
end

-- Like setData, but inserts a new tag
function Xml:addTag(data, ... )
    local arg={ ... }
    local x=self._data
    local parent=nil
    i=1
    while true do
        if type(x)=='string' then return nil end
        if not arg[i] then
            x[1]=data
            break
        end
        local pId=nil
        x, parent, pId=self._findTagInBlock(x, arg[i])
        if not x or i==#arg then
            parent[pId+1]={}
            parent[pId+1][0]=arg[i]
            if i==#arg then
                parent[pId+1][1]=data
                return nil
            end
            x=parent[pId+1]
        end
        i=i+1
    end
end

function Xml:_tags(tagName)
    local ps={{self._data, 1}}
    while true do
        local tbl =ps[#ps][1]
        local id  =ps[#ps][2]
        local nTbl=tbl[id]
        if type(nTbl)=='table' then
            if nTbl[0]==tagName then
                coroutine.yield(nTbl)
            end
            ps[#ps][2]=ps[#ps][2]+1
            table.insert(ps, {nTbl, 1})
        else
            table.remove(ps, #ps)
        end
        if not ps or #ps<1 then break end
    end
end

function Xml:tags(tagName)
    return coroutine.wrap(function() self:_tags(tagName) end)
end

function Xml._findTagInBlock(xmlOb, tagName)
    local bigV=1
    for k,v in pairs(xmlOb) do
        if tonumber(k) and k~=0 then
            if k>bigV then bigV=k end
            if v[0]==tagName then
                return v, xmlOb, k
            end
        end
    end
    return nil, xmlOb, bigV
end

function Xml:unbatch()
    LOGGER:warn("unbatch() not implemented for xml. You can work around this by adding your own\n" ..
                "unbatch function to the source connector. The function should receive an XML\n" ..
                "message as its argument and return a table of strings that can be built into XML\n" ..
                "messages before being sent to the destination transformers.")
    return self._originalData
end

return Xml
