local seg=Class { }
seg.__name = 'HL7 Segment Object'

function seg:__init(segString, fs, cs, rs, e, scs, ss)
    self._type=segString:sub(1,3)

    if self._type=='MSH' then
        self._fieldSeparator       =segString:sub(4,4)
        self._componentSeparator   =segString:sub(5,5)
        self._repetitionSeparator  =segString:sub(6,6)
        self._escapeCharacter      =segString:sub(7,7)
        self._subComponentSeparator=segString:sub(8,8)
    else
        self._fieldSeparator       =fs  or '|'
        self._componentSeparator   =cs  or '^'
        self._repetitionSeparator  =rs  or '~'
        self._escapeCharacter      =e   or '\\'
        self._subComponentSeparator=scs or '&'
        self._segmentSeparator     =ss  or '\r'
    end
    self._data=seg._buildData(self, segString)
end

function seg:_buildData(str)
    str=str:sub(5)
    local d=str:split(self._fieldSeparator)
    if self._type=="MSH" then
        table.insert(d, 1, self._fieldSeparator)
    end
    for k,v in pairs(d) do
        d[k]=v:split(self._repetitionSeparator)
        for l,w in pairs(d[k]) do
            d[k][l]=w:split(self._componentSeparator)
            for m,x in pairs(d[k][l]) do
                d[k][l][m]=x:split(self._subComponentSeparator)
            end
        end
    end
    return d
end

function seg:__tostring()
    local t={self._type, self._fieldSeparator}
    local fields={}
    for k,field in pairs(self._data) do
        local reps={}
        for l,rep in pairs(field) do
            local coms={}
            for m,com in pairs(rep) do
                table.insert(coms, table.concat(com, self._subComponentSeparator))
            end
            table.insert(reps, table.concat(coms, self._componentSeparator))
        end
        table.insert(fields, table.concat(reps, self._repetitionSeparator))
    end
    if self._type=="MSH" then table.remove(fields, 1) end
    table.insert(t, table.concat(fields, self._fieldSeparator))
    return table.concat(t)
end

function seg:getName()
    return self._type
end

function seg:setData(data, field, component, repetition, subcomponent)
    field       =tonumber(field)
    component   =tonumber(component)
    repetition  =tonumber(repetition) or 1
    subcomponent=tonumber(subcomponent) or 1

    if self._type=='MSH' then
        if tonumber(field)==1 then
            self:setFieldSeparator(data)
            return true
        elseif tonumber(field)==2 then
            self:setMSH2Chars(data)
        end
    end

    self:ensureExists(field, component, repetition, subcomponent)

    self._data[field][repetition][component][subcomponent]=data

    return true
end

function seg:getData(field, component, repetition, subcomponent)
    field       =tonumber(field)
    component   =tonumber(component)
    repetition  =tonumber(repetition) or 1
    subcomponent=tonumber(subcomponent) or 1
    self:ensureExists(field, component, repetition, subcomponent)
    return self._data[field][repetition][component][subcomponent]
end

function seg:setFieldSeparator(fs)
    self._fieldSeparator=fs
end

function seg:setMSH2Chars(s)
    local cs =s:sub(1,1)
    local rs =s:sub(2,2)
    local ec =s:sub(3,3)
    local scs=s:sub(4,4)
    self._componentSeparator=cs
    self._repetitionSeparator=rs
    self._escapeCharacter=ec
    self._subComponentSeparator=scs
end

function seg:ensureExists(field, component, repetition, subcomponent)
    if not self._data[field] then
        while not self._data[field] do
            table.insert(self._data, {{{''}}})
        end
    end

    if not self._data[field][repetition] then
        while not self._data[field][repetition] do
            table.insert(self._data[field], {{''}})
        end
    end

    if not self._data[field][repetition][component] then
        while not self._data[field][repetition][component] do
            table.insert(self._data[field][repetition], {''})
        end
    end

    if not self._data[field][repetition][component][subcomponent] then
        while not self._data[field][repetition][component][subcomponent] do
            table.insert(self._data[field][repetition][component], '')
        end
    end
end

return seg
