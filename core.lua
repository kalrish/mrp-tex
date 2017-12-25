local setup_module_loader_source = function()
	texio.write_nl("log", "loading own Lua modules from sources")
	
	local path_separator = string.match(package.config, "^([^\n]+)")
	local path = "lua_modules" .. path_separator .. "?.lua"
	
	table.insert(package.searchers or package.loaders,
		function(module_name)
			local filename = package.searchpath(module_name, path)
			if filename then
				local r1, r2 = loadfile(filename, "t")
				return r1 or r2 or "\n\tcouldn't load module"
			else
				return "\n\tno file named that way"
			end
		end
	)
end

setup_module_loader_source()

local loadfile = loadfile
local lua_setbytecode = lua.setbytecode
local texio_write = texio.write
local texio_write_nl = texio.write_nl
--local assign_bytecode = require("utils.assign_bytecode")
local read_file = require("utils.read_file")
local store_table = require("utils.store_table")

local collect_modules

do
	local redump_lua_modules = false
	
	local lua_module_list_file = io.open("lua_module_list", "rb")
	if lua_module_list_file then
		collect_modules = true
		
		local lua_module_list = lua_module_list_file:read("*a")
		
		lua_module_list_file:close()
		
		if lua_module_list then
			texio_write_nl("term", "Preloading Lua modules")
			
			local name2slot = {}
			
			local offset = 10
			local i = 1
			
			for path in string.gmatch(lua_module_list, "[^ \r\n]+") do
				local module_name = string.gsub(string.match(path, "^lua_modules/([^.]+)%..+$"), "/", ".")
				local module_loader, error_message = loadfile(path, "b")
				if module_loader then
					if redump_lua_modules then
						module_loader = assert(load(string.dump(module_loader, true), "dump", "b"))
					end
					
					local slot = offset + i
					
					name2slot[module_name] = slot
					
					lua_setbytecode(slot, module_loader)
					
					texio_write_nl("log", "Lua module preloader: module '")
					texio_write("log", module_name, "' stored in bytecode register ", tostring(slot))
					texio_write_nl("term", "  ")
					texio_write("term", module_name)
				else
					tex.error("Cannot load Lua module",
						{
							--module_name,
							error_message
						}
					)
				end
				
				i = i + 1
			end
			
			store_table(name2slot, 2)
		else
			tex.error("Cannot read Lua module list",
				{
					"Read operation failed"
				}
			)
		end
	else
		collect_modules = false
	end
end

texio_write_nl("term", "Preloading Lua module loading setup function")
if collect_modules then
	lua_setbytecode(1,
		function()
			local tostring = tostring
			local lua_getbytecode = lua.getbytecode
			local texio_write = texio.write
			local texio_write_nl = texio.write_nl
			
			texio_write_nl("log", "loading own Lua modules from the format")
			
			local name2slot = lua_getbytecode(2)()
			
			local searcher = function(name)
				local slot = name2slot[name]
				if slot then
					texio_write_nl("log", "Lua module loader: module '")
					texio_write("log", name, "' found in bytecode slot ", tostring(slot))
					
					return lua_getbytecode(slot)
				else
					texio_write_nl("log", "Lua module loader: module '")
					texio_write("log", name, "' not found in the format")
					
					return "\n\tno slot assigned"
				end
			end
			
			-- We can not just replace the default searcher because we use external modules, i.e. not every module we use is collected and stored in the format
			-- package_searchers[2] = searcher
			table.insert(package.searchers or package.loaders, 2, searcher)
		end
	)
else
	lua_setbytecode(1, setup_module_loader_source)
end
