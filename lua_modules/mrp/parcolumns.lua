local setmetatable = setmetatable
local node = node
local node_next = node.next
local node_new = node.new
local node_tail = node.tail
local node_set_attribute = node.set_attribute

local node_id_glue = node.id("glue")
local node_id_rule = node.id("rule")
local node_id_hlist = node.id("hlist")
local node_id_vlist = node.id("vlist")

local width_plus_depth = function(n)
	return n.height + n.depth
end

local compute_node_height_methods = setmetatable(
	{
		[node_id_glue] = function(n)
			return n.width
		end,
		[node_id_rule] = width_plus_depth,
		[node_id_hlist] = width_plus_depth,
		[node_id_vlist] = width_plus_depth
	},
	{
		__index = function(n)
			error("unhandled node type (id: " .. tostring(n.id) .. ")")
		end
	}
)

local compute_node_height = function(n)
	return compute_node_height_methods[n.id](n)
end

local append_node = function(obj, column, node)
	local tails = obj.tails
	local heights = obj.heights
	
	local height = compute_node_height(node)
	
	local column_tail = tails[column]
	if column_tail then
		column_tail.next = node
	else
		obj.heads[column] = node
	end
	
	tails[column] = node
	
	heights[column] = heights[column] + height
end

--[[
local compute_list_height = function(head)
	local vp = node.vpack(node.copy_list(head))
	local wd, ht, dp = node.dimensions(vp)
	node.flush_node(vp)
	return ht+dp
end
]]
--[[
local compute_list_height = function(n, tail)
	local th = 0
	
	local past_tail
	if tail then
		past_tail = node_next(tail)
	end
	
	repeat
		th = th + compute_node_height(n)
		
		n = node_next(n)
	until n == nil or n == past_tail
	
	return th
end
]]

local append_list = function(obj, column, head_or_n, tail)
	--[[
	local tails = obj.tails
	local heights = obj.heights
	
	do
		local height = compute_node_height(head_or_n)
		
		local column_tail = tails[column]
		if column_tail then
			column_tail.next = head_or_n
		else
			obj.heads[column] = head_or_n
		end
		
		tails[column] = head_or_n
		
		heights[column] = heights[column] + height
	end
	
	head_or_n = node_next(head_or_n)
	
	local past_tail = node_next(tail)
	
	while head_or_n ~= nil and head_or_n ~= past_tail do
		local height = compute_node_height(head_or_n)
		
		tails[column].next = head_or_n
		
		tails[column] = head_or_n
		
		heights[column] = heights[column] + height
		
		head_or_n = node_next(head_or_n)
	end
	]]
	
	----[[
	tail = tail or node_tail(head_or_n)
	
	local past_tail = node_next(tail)
	
	repeat
		append_node(obj, column, head_or_n)
		
		head_or_n = node_next(head_or_n)
	until head_or_n == nil or head_or_n == past_tail
	--]]
	
	--[[
	local height = compute_list_height(head, tail)
	
	local column_tail = obj.tails[column]
	if column_tail then
		column_tail.next = head
	else
		obj.heads[column] = head
	end
	
	obj.tails[column] = tail
	
	obj.heights[column] = obj.heights[column] + height
	]]
end

local balance_top = function(obj)
	local columns = obj.columns
	local heads = obj.heads
	local tails = obj.tails
	local heights = obj.heights
	--local lastb = obj.lastb
	
	local max_height = 0
	
	for i = 1, columns do
		local height = heights[i]
		if height > max_height then
			max_height = height
		end
	end
	
	for i = 1, columns do
		local adjust_glue = node_new(node_id_glue)
		adjust_glue.width = max_height - heights[i]
		
		node_set_attribute(adjust_glue, 1, 2)
		
		--[[
		local tail = tails[i]
		if tail then
			tail.next = adjust_glue
			tails[i] = adjust_glue
		else
			heads[i] = adjust_glue
			tails[i] = adjust_glue
		end
		
		heights[i] = heights[i] + adjust_glue.width
		]]
		append_node(obj, i, adjust_glue)
		
		--[[
		heights[i] = 0
		]]
		
		--lastb[i] = adjust_glue
	end
end

--[[
local balance_center = function(obj)
	local heights = {}
	local max_height = 0
	
	local columns = obj.columns
	local lastb = obj.lastb
	local tails = obj.tails
	
	for i = 1, columns do
		local head = lastb[i].next
		if head then
			local height = compute_total_height(head)
			
			heights[i] = height
			
			if height > max_height then
				max_height = height
			end
		else
			heights[i] = 0
		end
	end
	
	for i = 1, columns do
		local adjust_glue1 = node_new(node_id_glue)
		adjust_glue1.width = ( max_height - heights[i] ) / 2
		
		local adjust_glue2 = node.copy(adjust_glue1)
		
		local head = lastb[i]
		local prevnext = head.next
		head.next = adjust_glue1
		adjust_glue1.next = prevnext
		
		local tail = tails[i]
		if tail then
			tail.next = adjust_glue2
			tails[i] = adjust_glue2
		else
			heads[i] = adjust_glue2
			tails[i] = adjust_glue2
		end
		
		lastb[i] = adjust_glue2
	end
end
--]]

local length = function(obj)
	return obj.columns
end

local metatable = {
	__len=length,
	__index={
		append_node = append_node,
		append_list = append_list,
		balance = balance_top,
		--balance_top = balance_top,
		--balance_center = balance_center,
	},
	--__metatable=false
}

return {
	append_node = append_node,
	append_list = append_list,
	balance = balance_top,
	--balance_top = balance_top,
	--balance_center = balance_center,
	length = length,
	new = function(columns)
		local heights = {}
		
		for i = 1, columns do
			heights[i] = 0
		end
		
		return setmetatable(
			{
				columns = columns,
				heads = {},
				tails = {},
				heights = heights,
				--lastb = {}
			},
			metatable
		)
	end
}