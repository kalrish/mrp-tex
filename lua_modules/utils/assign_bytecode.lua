local lua_setbytecode = lua.setbytecode

return function(registry, name, slot, func)
	for k, v in pairs(registry) do
		if v == slot then
			tex.error("Lua bytecode slot has already been assigned",
				{
					"Slot number " .. tostring(slot) .. " is being assigned to " .. name .. ", but it was already assigned to " .. k
				}
			)
			
			return
		end
	end
	
	registry[name] = slot
	
	lua_setbytecode(slot, func)
end
