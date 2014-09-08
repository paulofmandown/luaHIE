--- An Example source connector with a fileReader and the text datatype
local source={ connectortype  ='file', -- Specifies the FileReader connector
               dir            ='/tmp/',-- Local directory that will have files that need to be read
               filename       ='.*',   -- Specifies the exact filename or a lua pattern (see 'http://www.lua.org/manual/5.1/manual.html#5.4.1')
               pollrate       ='60',   -- Time (in seconds) to wait before checking for more files.
               deletefiles    =true,   -- true if you want to permanently delete files after reading. else false.
               -- The remainder apply only to the text datatype
               datatype       ='text', -- Specifies the text datatype
               columnseparator=',',    -- Specifies the character that separates column values
               rowseparator   ='\n'    -- Specifies the character that separates rows.
             }

--- An Example destination connector with a fileWriter
-- FileWriters can take a function that generates a filename.
local function genFileName()
    return getDate()
end
local dest  ={connectortype='file',         -- Specifies the fileWriter connector
              dir          ='/home/myUser', -- Specifies the dir that will receive files
              filename     =genFileName,    -- A function that returns a string to be used as a filename,
                                            -- Or a constant string to be used as a filename
              append       =false           -- Specifies wether files should be appended to, or overwritten.
             }

local fileChannel=Channel:new("My File Channel", source, dest)

return fileChannel
