local source ={
    connectortype="FTP",
    host='someftp.com', -- FTP URL or IP
    port='21',          -- FTP Port
    dir ='ftpDir',      -- Dir on FTP server for writing
    username='user',    -- Username for ftp login, nil if anon
    password='123asdf', -- password for ftp login, nil if anon
    filename='file.txt',-- filename for ftp write, can be a string or a function that returns a string
    delete=true,         -- delete the file after reading if true
    pollrate=60          -- Time between ftp reads in seconds
}

local dest   ={
    connectortype="FTP",
    host    ='someftp.com',-- FTP URL or IP
    port    ='21',         -- FTP Port
    dir     ='ftpDir',     -- Dir on FTP server for writing
    username='user',       -- Username for ftp login, nil if anon
    password='pass',       -- password for ftp login, nil if anon
    filename='name.txt'    -- filename for ftp write, can be a string or a function that returns a string
}

return Channel:new("My FTP Channel", source, dest)
