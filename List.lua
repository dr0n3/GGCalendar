local WHC = Apollo.GetAddon("WHCCalendar")
local List = { }

function List.Init()
	local self = {
		d = { }	
	}
	
	function self:new()
		return {first = 0, last = -1}
	end
	
	function self:push(list, value)
		local last = list.last + 1
		list.last = last
		list[last] = value
	end
	
	function self:pop(list)
		local first = list.first
		if first > list.last then return nil end
		local value = list[first]
		list[first] = nil
		list.first = first + 1
		
		return value
	end
	
	return self
end

Apollo.RegisterPackage(List, "WHCCalendar:List", 1, {})
