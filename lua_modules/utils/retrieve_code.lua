local assert = assert
local tostring = tostring
local lua_getbytecode = lua.getbytecode
local texio_write = texio.write
local texio_write_nl = texio.write_nl

local registry = lua_getbytecode(3)()

return function(name)
	texio_write_nl("log", "Lua code retriever: ")
	local slot = registry[name]
	if slot then
		texio_write("log", name, " found in bytecode slot ", tostring(slot))
		
		return assert(lua_getbytecode(slot))()
	else
		texio_write("log", name, " not found")
	end
end
