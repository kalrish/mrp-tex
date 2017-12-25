local next = next
local pairs = pairs
local tostring = tostring
local type = type
local string_len = string.len
local string_rep = string.rep
local texio_write = texio.write
local texio_write_nl = texio.write_nl

local print_table
print_table = function(t, l) -- table, nesting level
	local max_len = 0
	
	do
		local i = next(t)
		while i do
			local len = string_len(tostring(i))
			if len > max_len then
				max_len = len
			end
			
			i = next(t, i)
		end
	end
	
	max_len = max_len + 4
	
	local ind = string_rep("\t", l)
	
	for k, v in pairs(t) do
		local k_str = tostring(k)
		texio_write_nl("log", "")
		texio_write("log", ind, k_str, string_rep(" ", max_len-string_len(k_str)), tostring(v))
		if type(v) == "table" then
			print_table(v, l+1)
		end
	end
end

return function(t)
	print_table(t, 0)
	texio_write_nl("log", "")
end
