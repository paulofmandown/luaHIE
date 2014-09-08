-- Transformers in luaHIE are just functions that receive an object representing a datatype and return the same or another object.
-- The returned value should be able to have tostring called on it to produce a message to be sent

-- The most basic example just returns what it received.
-- msg is a custom object that represents a received message
function myTransformer(msg)
    return msg
end

-- Transforming hl7 data
function hl7Transformer(msg)
    -- Retrieving a value from an HL7 field
    -- getData takes up to 5 parameters:
    -- Segment, field, component, repetition, subcomponent
    -- For the segment 'PID|1||visit_id|...'
    local value=msg:getData('PID', 3, 1)   -- value now holds 'visit_id'

    -- Accessing a repetition
    -- For the segment 'PID|1||visit_id~med-rec_num|...'
    local value=msg:getData('PID', 3, 1, 2)   -- value now holds 'med-rec_num'

    -- Altering HL7 data
    msg:setData('A08', 'MSH', 9, 1) -- Sets MSH.9.1 to A08

    -- Adding a segment
    -- If the provided segment does not exist
    -- setData will add it for you.
    msg:setData('blah', 'PBT', 1, 1) -- Adds PBT segment and sets PBT.1.1 to blah

    -- Forcing a new segment
    -- If a certain segment type already exists
    -- You can add an additional with addSegment()
    local seg=msg:addSegment('OBX') -- appends 'OBX|\r' to end of message, and returns segment

    -- You can now operate on that segment individually
    seg:setData('>2', 5, 1) -- Sets the segments 5.1 field to '>2'

    -- Iterating through repeating segments
    for i, segment in msg:segments('OBX') do
        print(segment:getData(5, 1)) -- will print all OBX.5.1 values to the console.
    end

    -- Iterating through all segments
    -- Omitting the argument in segments will cycle through all of them
    for i, segment in msg:segments() do
        print(segment:getData(5, 1)) -- will print all Segments' 5.1 values to the console.
    end
    return msg
end

-- Working with delimitted text
function textTransformer(msg)
    -- Retrieving a value from a row and column
    local value=msg:getData(1,3) -- Gets the value stored at row 1, column 3

    -- Altering a value in a row/column
    msg:setData('new_value', 1, 3) -- Sets row 1, column 3 to 'new_value'

    -- Iterating through rows
    for i, row in msg:rows() do
        -- returned rows are just tables storing columns
        row[3]='blah' -- sets every row's column 3 to 'blah'
    end
    return msg
end

-- Working with X12 or EDI
function ediTransformer(msg)
    -- Retrieving a value from a segment, element, subelement
    local value=msg:getData('UMB', 1, 2) -- Gets the value from segment UMB, element 1, subelement 2

    -- Altering a value in a segment
    msg:setData('words', 'UMB', 3) -- Set the value of UMB-3 to 'words'

    -- Iterating through all segments
    -- Like the HL7 object, The segment argument can be omitted to cycle through all
    for i, segment in msg:segments() do
        segment:setData('value', 1) -- sets all segments first element to 'value'
    end
    return msg
end

function xmlTransformer(msg)
    -- Retrieving a value from a tag
    -- There is no limit to the number of arguments you can provide
    -- If the path exists, you should get the value
    local value=msg:getData('Child', 'Grandchild') -- Gets the value from <root><Child><Grandchild>value</Grandchild></Child></root>

    -- Setting the value of a tag
    -- This will overwrite existing tags, or create one if none exist
    msg:setData('value', 'Child', 'Other_Grandchild') -- sets Child.Other_Grandchild to value

    -- Adding a new tag even if one already exists
    msg:addTag('value', 'Child', 'Other_Grandchild') -- Adds a new Other_Grandchild tag to the existing Child and sets it to 'value'

    -- Iterating through repeating tags
    for tag in msg:tags('Repeater') do  -- XML requires that you send a value to its iterator
        tag[1]='value'  -- tag is a table as built by LuaXml
                        -- It's inner value can be set by accessing index 1.
                        -- It's name can be set by accessing index 0.
    end
    return msg
end

-- adding 'datatype' to the destination table in your interface file
-- will supply an additional argument to the transformer function.
-- an optional 'template' element can be an example string used to
-- create the tmp argument
local source     ={connectortype='TCP', host='*', port='8580',
                   datatype='XML'}
local hl7Template='MSH|^~\\&|SW|SWA|SV|SVA||BLAH|||D|2.3|\r'
local destination={connectortype='LLP', host='555.0.0.1', port='8580',
                   datatype='HL7', template=hl7Template}
function usingTmp(msg, tmp)
    local function xmlToHl7(tags, ... )
        tmp:setData(msg:getData(unpack(tags)), ... )
    end

    xmlToHl7({'parent', 'child'}, 'PID', 5, 1)

    return msg:getData('parent', 'childTwo')=='Good_Message' -- return true or false (true to send tmp to the destination, false to stop processing this message)
end
-- return {source, usingTmp, destination}


-- Implementing luaHIE's data structures
function changeDataStructure(msg)
    local tmp=Xml:new('<Root_Tag />') -- XML requires you provide a template

    local tmp=Hl7:new()               -- Can be provided a template or will default to 'MSH|^~\&<CR>'
                                      -- The default can be edited in config.lua

    local tmp=X12:new('UMD*')         -- X12 requires you provide a template

    local tmp=Text:new('1,2,3,4\n')   -- Can be provided a template or will default to ''

    return tmp
end
