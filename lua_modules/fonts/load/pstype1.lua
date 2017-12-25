local load_pstype1 = require("fontlib.load.postscript-type1.fontforge")
local load_warnings = require("fonts.load_warnings")
local load_errors = require("fonts.load_errors")

return function(afm_path, pfx_path)
	local r1, r2, r3 = load_pstype1(afm_path, pfx_path)
	if r1 then
		load_warnings(pfx_path, r2)
		
		if not r3 then
			return r1
		else
			tex.error("Cannot apply AFM file", r3)
		end
	else
		load_errors(r2)
	end
end
