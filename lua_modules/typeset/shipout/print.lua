local shipout_node = require("typeset.shipout.node")
local set_on_stock = require("typeset.set_on_stock")

return function(stock_width, stock_height)
	return function(page)
		shipout_node(set_on_stock(page, stock_width, stock_height))
	end
end