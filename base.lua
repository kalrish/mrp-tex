tex.enableprimitives("",
	{
		"dimexpr",
		"luafunction",
		"outputbox",
		"outputmode",
		"pageheight",
		"pagewidth",
		--"protrudechars"
	}
)

local loadfile = loadfile
local lua_setbytecode = lua.setbytecode
local texio_write = texio.write
local texio_write_nl = texio.write_nl
--local assign_bytecode = require("utils.assign_bytecode")
local read_file = require("utils.read_file")
local store_table = require("utils.store_table")

local bytecode_registry = {}

local collect_modules = lua.getbytecode(2) ~= nil

do
	local texlua_bytecode_extension = read_file("texlua_bytecode_extension")
	if texlua_bytecode_extension then
		texio_write_nl("term and log", "Lua bytecode file name extension: ")
		texio_write("term and log", texlua_bytecode_extension)
		
		lua.name[1] = "document." .. texlua_bytecode_extension
		
		do
			texio_write_nl("term", "Preloading Lua setup loading function")
			
			--local setuploader_bytecode_slot = 4
			--tex.setattribute("setuploaderbytecodeslot", setuploader_bytecode_slot)
			--local setuploader_bytecode_slot = tex.getattribute("setuploaderbytecodeslot")
			local setuploader_bytecode_slot = token.create("setuploaderbytecodeslot").mode
			if collect_modules then
				local loader, error_message = loadfile("setup." .. texlua_bytecode_extension, "b")
				if loader then
					lua_setbytecode(setuploader_bytecode_slot, loader)
					
					texio_write_nl("log", "Lua setup loading function stored in bytecode register ")
					texio_write("log", tostring(setuploader_bytecode_slot))
				else
					tex.error("Cannot load Lua setup script",
						{
							error_message
						}
					)
				end
			else
				lua_setbytecode(setuploader_bytecode_slot,
					function()
						_G.assert(_G.loadfile("setup.lua", "t"))()
					end
				)
				
				texio_write_nl("log", "Lua setup loading function stored in bytecode register ")
				texio_write("log", tostring(setuploader_bytecode_slot))
			end
		end
		
		do
			local tex_sp = tex.sp
			local load_table = require("utils.load_table")
			
			do
				local papers, error_message = load_table("papers." .. texlua_bytecode_extension)
				if papers then
					texio_write_nl("term", "Storing papers table")
					
					for k, v in pairs(papers) do
						texio_write_nl("log", "stored paper '")
						texio_write("log", k, "' with height ", tostring(v.height), " and width ", tostring(v.width))
						texio_write_nl("term", "  paper ")
						texio_write("term", k, ":")
						texio_write_nl("term", "     height:  ")
						texio_write("term", tostring(v.height))
						texio_write_nl("term", "     width :  ")
						texio_write("term", tostring(v.width))
						
						v[1] = tex_sp(v.width)
						v.width = nil
						
						v[2] = tex_sp(v.height)
						v.height = nil
					end
					
					bytecode_registry["papers"] = 6
					store_table(papers, 6)
				else
					tex.error("Cannot load papers table",
						{
							error_message
						}
					)
				end
			end
			
			do
				local page_layout, error_message = load_table("page_layout." .. texlua_bytecode_extension)
				if page_layout then
					do -- dimensions
						local purify
						purify = function(t)
							for k, v in pairs(t) do
								if type(v) == "table" then
									purify(v)
								else
									t[k] = tex_sp(v)
								end
							end
						end
						
						purify(page_layout)
					end
					
					texio_write_nl("term", "Storing page layout specification")
					
					bytecode_registry["page_layout"] = 5
					store_table(page_layout, 5)
				else
					tex.error("Cannot load page layout",
						{
							error_message
						}
					)
				end
			end
		end
	end
end

--[[
do
	local f = io.open("fonts.txt", "rb")
	if f then
		local list = f:read("*a")
		
		f:close()
		
		if list then
			local name2path = {
				tfm = {},
				pk = {},
				pstype1m = {},
				pstype1g = {},
				truetype = {},
				opentype = {}
			}
			
			for name, format, path in string.gmatch(list, "([^ \t\r\n]+)\t+([^ \t\r\n]+)\t+([^\r\n]+)") do
				name2path[format][name] = path
			end
			
			texio_write_nl("term", "Storing font paths table")
			
			store_table(name2path, 6)
		else
			tex.error("Cannot read fonts.txt")
		end
	else
		tex.error("Cannot open fonts.txt")
	end
end
]]

store_table(bytecode_registry, 3)
