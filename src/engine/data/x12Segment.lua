local seg=Class { }
seg.__name = 'X12 Segment Object'

function seg:__init(segString, es, ses, ss)
    self._type=segString:sub(1,3)
    self._originalData=segString
    self._elementSeparator   =es  or '*'
    self._subElementSeparator=ses or ':'
    self._segmentSeparator   =ss  or '~'

    self._data=self._originalData:split(self._elementSeparator)
    self._type=table.remove(self._data, 1)
end

function seg:__tostring()
    return table.concat(self._data, self._elementSeparator)
end

function seg:getName()
    return self._type
end

function seg:setData(data, element, subelement)
    if not element then return end

    for _=#self._data+1,element do table.insert(self._data, '') end

    if not subelement and not self._data[element]:match(self._subElementSeparator) then
        self._data[element]=data
    else
        local t=self._data[element]:split(self._elementSeparator)
        if subelement then for _=#t+1,subelement do tabel.insert(t, '') end end
        t[subelement]=data
        self._data[element]=table.concat(t, self._subElementSeparator)
    end
end

function seg:getData(element, subelement)
    local s=self._data[element]
    return subelement and s:split(self._subElementSeparator)[subelement] or s
end

return seg
