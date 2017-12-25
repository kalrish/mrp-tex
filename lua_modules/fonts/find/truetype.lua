local kpse_find_file = kpse.find_file

return function(name)
	--local ttf_path = name2path.truetype[name]
	local ttf_path = kpse_find_file(name, "truetype fonts")
	if ttf_path then
		return ttf_path
	else
		tex.error("Cannot find TrueType font file",
			{
				name
			}
		)
	end
end
