LuaHIE
===
LuaHIE is a set of tools for receiving, manipulating, and transmitting data.
This was designed mainly as a tool to test more reliable healthcare integration systems.

Supported Data Types
---
- HL7
- XML
- EDI/X12
- Delimited Text

Supported Transport Types
---
- TCP
- LLP
- Local File
- FTP
- HTTP (as a destination only)
- Custom Functions

Requirements
---
luaHIE requires that you have [Lua](http://www.lua.org), [LuaSocket](http://luasocket.luaforge.net), [LuaFileSystem](http://keplerproject.github.io/luafilesystem) installed.

Other functionality will require the following: [LuaXml](http://viremo.eludi.net/LuaXML/), [LuaSec](http://luaforge.net/projects/luasec).

Notes on dependencies
---
All of the required libraries can be installed with [LuaRocks](http://www.luarocksporg/)

Using LuaHIE
---
See the interfaces/examples directory in the luaHIE install directory.
There are examples for all connector and data types.

Other Notes
---
luaHIE uses [30Log](https://github.com/Yonaba/30log) by Roland Yonaba. see LICENSE.
30Log is an OOP solution for lua, and it is very useful.

As of v0.3.0, luaHIE uses [LuaLogging](https://github.com/Neopallium/lualogging), see LICENSE.
LuaLogging is a log4j styled logging library.
