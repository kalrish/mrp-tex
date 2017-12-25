local string_gsub = string.gsub
local texio_write = texio.write
local texio_write_nl = texio.write_nl

return function(filename, warnings)
	if warnings then
		texio_write_nl("log", "font loader: ")
		texio_write("log", filename, ": warnings:")
		
		local i = 1
		local warning = warnings[1]
		while warning do
			texio_write_nl("log", "  - ")
			texio_write("log", string_gsub(warning, "\n", "\n     "))
			
			i = i + 1
			warning = warnings[i]
		end
	end
end
