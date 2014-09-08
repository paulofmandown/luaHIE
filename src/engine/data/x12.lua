local x12=Class { }
x12.__name='X12 Message Object'
x12._type='X12'

function x12:__init(x12String, connector)
    x12String=x12String:gsub('[\r\n]', '')
    self._elementSeparator=connector and connector._configTable.elementseparator or '*'
    self._segmentSeparator=connector and connector._configTable.segmentseparator or '~'
    self._subelementSeparator=connector and connector._configTable.subelementseparator or ':'
    self._originalData=x12String

    self._data={}
    local segs=self._originalData:split(self._segmentSeparator)
    for i=1,#segs do
        if segs[i] and segs[i]~='' then
            local seg=X12Segment:new(segs[i],
                                  self._elementSeparator,
                                  self._subelementSeparator,
                                  self._segmentSeparator)
            table.insert(self._data, seg)
        end
    end
end

function x12:__tostring()
    local s=''
    local data=self._data
    for i=1,#data do
        s=s .. tostring(data[i]) .. self._segmentSeparator
    end
    return s
end

function x12:getData(segment, element, subelement)
    local data=self._data
    for i=1,#data do
        if data[i]._type==segment then
            return data[i]:getData(element, element, subelement or 1)
        end
    end
    return nil
end

function x12:setData(data, segment, element, subelement)
    local d=self._data
    for i=1,#d do
        if d[i]._type==segment then
            return d[i]:setData(data, element, subelement or 1)
        end
    end
    local seg=X12Segment:new(segment .. self._fieldSeparator)
    seg:setData(data, element, subelement)
    table.insert(self._data, seg)
    return true
end

function x12:addSegment(seg)
    local seg=X12Segment:new(seg,
                          self._elementSeparator,
                          self._subelementSeparator,
                          self._segmentSeparator)
    table.insert(self._data, seg)
end

function x12._segments(data, n)
    local self   =data[1]
    local segName=data[2]
    local segs=self._data
    while segs[n+1] do
        n=n+1
        if not segName or segs[n]._type==segName then
            return n, segs[n]
        end
    end
end

function x12:segments(segName)
    return self._segments, {self, segName}, 0
end

function x12:unbatch()
    LOGGER:warn("unbatch() not implemented for x12. This is an issue I'd like to resolve as soon\n" ..
                "as I understand more about x12 and it's batching schema. You can work around this\n" ..
                "by adding your own unbatch function to the source connector. The function should\n" ..
                "receive an X12 message as its argument and return a table of strings that can be\n" ..
                "built into X12 messages before being sent to the destination transformers.")
    return self._originalData
end

return x12
