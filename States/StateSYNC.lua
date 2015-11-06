local WHC = Apollo.GetAddon("WHCCalendar")
local StateSYNC = { }

function StateSYNC.Init()
	local self = {
		d = { }	
	}
	
	function self:OnMessage(tChannel, tMsg, strSender)
		if tMsg.TYPE ~= WHC.MessageType.SYNC then
		 return
		end
		
		WHC:ResetTimeout()
		
		-- override the event, if the received one is newer
		local event = WHC.tEvents[tMsg.MSG.ID]
		if event ~= nil then
			if event.CHANGED >= tMsg.MSG.EVENT.CHANGED then
				return
			end
		end
		
		WHC.tEvents[tMsg.MSG.ID] = tMsg.MSG.EVENT
		
		Print("Got Sync "..tMsg.MSG.ID)
	end
	
	function self:GetTimeout()
		return 15
	end
	
	function self:Do()
	end
	
	return self
end

Apollo.RegisterPackage(StateSYNC, "WHCCalendar:StateSYNC", 1, {})
