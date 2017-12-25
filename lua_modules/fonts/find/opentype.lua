local kpse_find_file = kpse.find_file

return function(name)
	local otf_path = kpse_find_file(name, "opentype fonts")
	if otf_path then
		return otf_path
	else
		tex.error("Cannot find OpenType font file",
			{
				name
			}
		)
	end
end
