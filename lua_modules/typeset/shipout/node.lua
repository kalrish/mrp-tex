local tex_get = tex.get
local tex_setbox = tex.setbox
local tex_shipout = tex.shipout

return function(n, outputbox)
	outputbox = outputbox or tex_get("outputbox") or 255
	tex_setbox(outputbox, n)
	tex_shipout(outputbox)
end