--local kpse_find_file = kpse.find_file
local find_pstype1 = require("fontlib.find.postscript-type1.kpathsea.procedural")

return function(name)
	local afm_path, pfx_path = find_pstype1(name)
	--local afm_path = kpse_find_file(name, "afm")
	--local pfx_path = kpse_find_file(name, "type1 fonts")
	if afm_path and pfx_path then
		return afm_path, pfx_path
	else
		local error_table = {
			name
		}
		
		if not afm_path then
			error_table[2] = "Cannot find metrics file"
		end
		
		if not pfx_path then
			table.insert(error_table, "Cannot find glyph file")
		end
		
		tex.error("Cannot find PostScript Type 1 font files", error_table)
	end
end
