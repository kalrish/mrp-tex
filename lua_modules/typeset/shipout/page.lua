local advance_page_count
do
	local tex_getcount = tex.getcount
	local tex_setcount = tex.setcount
	
	advance_page_count = function()
		tex_setcount(0, tex_getcount(0) + 1)
	end
end

return function(shipout_function)
	return function(page)
		advance_page_count()
		
		shipout_function(page)
	end
end
