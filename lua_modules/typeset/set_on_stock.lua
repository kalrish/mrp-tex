local assert = assert
local math_min = math.min
local node = node
local node_new = node.new
local node_copy = node.copy
local node_hpack = node.hpack
local node_vpack = node.vpack
local tex_get = tex.get

local node_id_glue = node.id("glue")
local node_id_rule = node.id("rule")

local make_hrulebar = function(rule_length, width)
	local hrule1 = node_new(node_id_rule)
	hrule1.width = rule_length
	hrule1.height = 26214 -- 0.4pt
	hrule1.depth = 0
	
	local fill = node_new(node_id_glue)
	fill.stretch = 2^16
	fill.stretch_order = 1
	
	local hrule2 = node_copy(hrule1)
	
	hrule1.next = fill
	fill.next = hrule2
	
	return (node_hpack(hrule1, width, "exactly"))
end

local make_hrulebar_fit = function(rule_length, width, stock_width)
	local fill1 = node_new(node_id_glue)
	fill1.stretch = 2^16
	fill1.stretch_order = 1
	
	local hrulebar = make_hrulebar(rule_length, width)
	
	local fill2 = node_copy(fill1)
	
	fill1.next = hrulebar
	hrulebar.next = fill2
	
	return (node_hpack(fill1, stock_width, "exactly"))
end

local make_vrulebar = function(rule_length, height)
	local vrule1 = node_new(node_id_rule)
	vrule1.width = 26214 -- 0.4pt
	vrule1.height = rule_length
	vrule1.depth = 0
	
	local fill = node_new(node_id_glue)
	fill.stretch = 2^16
	fill.stretch_order = 1
	
	local vrule2 = node_copy(vrule1)
	
	vrule1.next = fill
	fill.next = vrule2
	
	return (node_vpack(vrule1, height, "exactly"))
end

return function(page, stock_width, stock_height)
	stock_width = stock_width or tex_get("pagewidth")
	stock_height = stock_height or tex_get("pageheight")
	
	local page_width = page.width
	local page_height = page.height --+ page.depth
	
	--print(page_width / 65536 / 72.27 * 2.54 * 10)
	--print(page_height / 65536 / 72.27 * 2.54 * 10)
	
	assert(page_width <= stock_width)
	assert(page_height <= stock_height)
	
	local rule_length = math_min(page_width / 5, page_height / 5)
	
	if stock_width > page_width then
		local fill1 = node_new(node_id_glue)
		fill1.stretch = 2^16
		fill1.stretch_order = 1
		
		local vrulebar1 = make_vrulebar(rule_length, page_height)
		
		local vrulebar2 = node_copy(vrulebar1)
		
		local fill2 = node_copy(fill1)
		
		fill1.next = vrulebar1
		vrulebar1.next = page
		page.next = vrulebar2
		vrulebar2.next = fill2
		
		page = node_hpack(fill1, stock_width, "exactly")
	end
	
	if stock_height > page_height then
		local fill1 = node_new(node_id_glue)
		fill1.stretch = 2^16
		fill1.stretch_order = 1
		
		local hrulebar1 = make_hrulebar_fit(rule_length, page_width, stock_width)
		
		local hrulebar2 = node_copy(hrulebar1)
		
		local fill2 = node_copy(fill1)
		
		fill1.next = hrulebar1
		hrulebar1.next = page
		page.next = hrulebar2
		hrulebar2.next = fill2
		
		page = node_vpack(fill1, stock_height, "exactly")
	end
	
	--[[
	if stock_height > ht and stock_width > wd then
		local fill = node_new(node_id_glue)
		fill.stretch = 2^16
		fill.stretch_order = 2
		
		local hrulebar
		do
			local hrule = node_new(node_id_rule)
			hrule.width = rule_length
			hrule.height = 0.4 * 65536
			hrule.depth = 0
			
			local hrule1 = node_copy(hrule)
			local fillc = node_copy(fill)
			local hrule2 = hrule
			
			hrule1.next = fillc
			fillc.next = hrule2
			
			local fill1 = node_copy(fill)
			local cpack = node_hpack(hrule1, wd, "exactly")
			local fill2 = node_copy(fill)
			
			fill1.next = cpack
			cpack.next = fill2
			
			hrulebar = node_hpack(fill1, stock_width, "exactly")
		end
		
		local chpack
		do
			local vrulebar
			do
				local vrule = node_new(node_id_rule)
				vrule.width = 0.4 * 65536 --tex.sp("0.4pt")
				vrule.height = rule_length
				vrule.depth = 0
				
				local vrule1 = node_copy(vrule)
				local fillc = node_copy(fill)
				local vrule2 = vrule
				
				vrule1.next = fillc
				fillc.next = vrule2
				
				vrulebar = node_vpack(vrule1, ht, "exactly")
			end
			
			local f1 = node_copy(fill)
			local rb1 = node_copy_list(vrulebar)
			local rb2 = vrulebar
			local f2 = node_copy(fill)
			
			f1.next = rb1
			rb1.next = page
			page.next = rb2
			rb2.next = f2
			
			chpack = node_hpack(f1, stock_width, "exactly")
		end
		
		do
			local fill1 = node_copy(fill)
			local rulebar1 = node_copy_list(hrulebar)
			local rulebar2 = hrulebar
			local fill2 = fill
			
			fill1.next = rulebar1
			rulebar1.prev = fill1
			rulebar1.next = chpack
			chpack.prev = rulebar1
			chpack.next = rulebar2
			rulebar2.prev = chpack
			rulebar2.next = fill2
			fill2.prev = rulebar2
			
			return (node_vpack(fill1, stock_height, "exactly"))
		end
	else
		return page
	end
	]]
	
	return page
end