local text=Class { }
text.__name='Text Message Object'
text._type='TEXT'
function text:__init(textString, connector)
    self._originalData=textString or ""
    self._columnSeparator=connector and connector._configTable.columnseparator or ','
    self._rowSeparator   =connector and connector._configTable.rowseparator or '\n'

    local data=self._originalData:split(self._rowSeparator)
    self._data={}
    for i=1,#data do
        table.insert(self._data, data[i]:split(self._columnSeparator))
    end
end

function text:__tostring()
    local s=""
    for i=1,#self._data do
        s=s .. table.concat(self._data[i], self._columnSeparator) .. self._rowSeparator
    end
    return s
end

function text:getData(row, column)
    return self._data[row][column]
end

function text:setData(data, row, column)
    if not self._data[row] or not self._data[row][column] then
        for _=1,row-#self._data do table.insert(self._data, {}) end
        for _=1,column-#self._data[row] do table.insert(self._data[row], "") end
    end
    self._data[row][column] = data
    return true
end

function text:_rows(n)
    n=n+1
    if self._data[n] then
        return n, self._data[n]
    end
end

function text:rows()
    return self._rows, self, 0
end

--- Text batches are split by row separator
function text:unbatch()
    return self._originalData:split(self._rowSeparator)
end

return text
