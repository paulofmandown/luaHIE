local http=DestinationConnector:extends { }
http.__name='HTTP Sender'

function http:__init(data, channelName, logger)
    http.super.__init(self, data, channelName, logger)
    local u=require 'socket.url'
    if not self._configTable.url:find(':') then self._configTable.url=DEFAULT_URL_VALUES.scheme .. '://' .. self._configTable.url end
    self._url=u.build(u.parse(self._configTable.url), DEFAULT_URL_VALUES)
    self._method=self._configTable.method
    self._headers=self._configTable.headers or
                  {['Accept']='*/*',
                   ['Accept-Encoding']='gzip, deflate',
                   ['Accept-Language']='en-us',
                   ['Content-Type']='text/plain'
                  }
    self._proxy=self._configTable.proxy
    if self._configTable.redirect~=nil then self._redir=self._configTable.redirect end
    self._useSSL=self._configTable.useSSL
    self._sslParams=DEFAULT_SSL_SENDER_PARAMS
    if self._useSSL and self._configTable.sslParams then
        for k,v in pairs(self._configTable.sslParams) do
            self._sslParams[k]=v
        end
    end
end

function http:send(message)
    local h -- "Bound for the Floor"
    local l=require 'ltn12'
    local t={}
    local params={ url=self._url,
                   sink=l.sink.table(t),
                   method=self._method,
                   headers=self._headers
                 }

    if message then
        message=tostring(message)
        params.source=l.source.string(message)
        params.headers['content-length']=#message
    else
        params.headers['content-length']='0'
    end
    if self._proxy then params.proxy=self._proxy end
    if self._redir~=nil then params.redirect=self._redir end

    if self._useSSL then
        for k,v in pairs(self._sslParams) do
            params[k]=v
        end
        h=ssl.https
    else
        h=require 'socket.http'
    end

    LOGGER:debug("Sending message to %s", self._url)
    self:_catch(h.request(params))

    return table.concat(t)
end

return http
