local hl7=Class { }
hl7.__name='HL7 Message Object'
hl7._type='HL7'

function hl7:__init(hl7String)
    self._originalData=hl7String and hl7String or DEFAULT_HL7_MESSAGE

    self._fieldSeparator       =self._originalData:sub(4,4)
    self._componentSeparator   =self._originalData:sub(5,5)
    self._repetitionSeparator  =self._originalData:sub(6,6)
    self._escapeCharacter      =self._originalData:sub(7,7)
    self._subComponentSeparator=self._originalData:sub(8,8)
    self._segmentSeparator     =self._originalData:sub(#self._originalData,#self._originalData)

    self._data={}

    local segs=self._originalData:split(self._segmentSeparator)
    for i=1,#segs do
        if segs[i] and segs[i]~='' then
            local seg=HL7Segment:new(
                segs[i],
                self._fieldSeparator,
                self._componentSeparator,
                self._repetitionSeparator,
                self._escapeCharacter,
                self._subComponentSeparator,
                self._segmentSeparator
            )
            table.insert(self._data, seg)
        end
    end
end

function hl7:__tostring()
    local s=''
    local data=self._data
    for i=1,#data do
        s=s .. tostring(data[i]) .. self._segmentSeparator
    end
    return s
end

function hl7:getData(segment, field, component, repetition, subcomponent)
    local data=self._data
    for i=1,#data do
        if data[i]._type==segment then
            return data[i]:getData(field, component, repetition, subcomponent)
        end
    end
    return nil
end

function hl7:setData(data, segment, field, component, repetition, subcomponent)
    local d=self._data
    if segment=='MSH' then
        if tostring(field)=='1' then
            self._fieldSeparator=data
            for i=1,#d do d[i]:setFieldSeparator(data, field, component, repetition, subcomponent) end
            return true
        elseif tostring(field)=='2' and #data>3 then
            self:setMSH2Chars(data)
            for i=1,#d do d[i]:setMSH2Chars(data) end
            return true
        end
    end
    for i=1,#d do
        if d[i]._type==segment then
            return d[i]:setData(data, field, component, repetition, subcomponent)
        end
    end
    local seg=HL7Segment:new(
        segment .. self._fieldSeparator,
        self._fieldSeparator,
        self._componentSeparator,
        self._repetitionSeparator,
        self._escapeCharacter,
        self._subComponentSeparator,
        self._segmentSeparator
    )
    seg:setData(data, field, component, repetition, subcomponent)
    table.insert(self._data, seg)
    return true
end

function hl7:addSegment(segment)
    local seg=HL7Segment:new(
        segment .. self._fieldSeparator,
        self._fieldSeparator,
        self._componentSeparator,
        self._repetitionSeparator,
        self._escapeCharacter,
        self._subComponentSeparator,
        self._segmentSeparator
    )
    table.insert(self._data, seg)
    return seg
end

function hl7._segments(data, n)
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

function hl7:segments(segName)
    return self._segments, {self, segName}, 0
end

function hl7:setFieldSeparator(s)
    self._fieldSeparator=s
    for _,seg in self:segments() do
        seg:setFieldSeparator(s)
    end
end

function hl7:setMSH2Chars(s)
    self._componentSeparator   =s:sub(1,1)
    self._repetitionSeparator  =s:sub(2,2)
    self._escapeCharacter      =s:sub(3,3)
    self._subComponentSeparator=s:sub(4,4)
    for _,seg in self:segments() do
        seg:setMSH2Chars(s)
    end
end

function hl7:unbatch()
    local t={}
    local msg
    for _,k in self:segments() do
        local segType=k._type
        if segType == 'MSH' then
            if msg ~= '' then
                table.insert(t, msg)
            end
            msg=''
        end
        if not segType:match('[B|F][H|T]S') then
            msg=msg .. tostring(k) .. self._segmentSeparator
        end
    end
    table.insert(t, msg)
    return t
end

return hl7
