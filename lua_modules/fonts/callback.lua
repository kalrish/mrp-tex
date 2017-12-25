local tostring = tostring
local texio_write = texio.write
local texio_write_nl = texio.write_nl

local cache = {}

local generators_dispatcher = {
	type1 = require("fontlib.generator.postscript-type1"),
	truetype = require("fontlib.generator.truetype"),
	opentype = require("fontlib.generator.opentype")
}

return function(fonts)
	return function(name, size, id)
		local cached = cache[name]
		
		if cached then
			cached = cached[size]
		else
			cache[name] = {}
		end
		
		if cached then
			texio_write_nl("log", "font loader: define_font callback: reusing font '")
			texio_write("log", name, "' ")
			
			if size > 0 then
				texio_write("log", "at ", tostring(size), "sp")
			else
				texio_write("log", "scaled ", -size / 1000, " times")
			end
			
			texio_write("log", " from the cache (id: ", tostring(cached), ")")
			
			return cached
		else
			local stored = fonts[name]
			if stored then
				local tex_font_table = generators_dispatcher[stored.format](stored, size)
				
				tex_font_table.type = "real"
				tex_font_table.format = stored.format
				tex_font_table.filename = stored.filename
				tex_font_table.embedding = "subset"
				tex_font_table.cache = "no"
				
				cache[name][size] = id
				
				return tex_font_table
			else
				local tex_font_table = font.read_tfm(name, size)
				
				return tex_font_table
			end
		end
	end
end
