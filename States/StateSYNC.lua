local WHC = Apollo.GetAddon("WHCCalendar")
local StateSYNC = { }

function StateSYNC.Init()
	local self = {
		d = { }	
	}
	
	function self:OnMessage(tChannel, tMsg, strSender)
		if not tMsg.TYPE == WHC.MessageType.SYNC then
		 return
		end
		
		WHC:ResetTimeout()
		Print("Got Sync "..tMsg.MSG)
	end
	
	function self:GetTimeout()
		return 15
	end
	
	function self:Do()
	end
	
	return self
end

Apollo.RegisterPackage(StateSYNC, "WHCCalendar:StateSYNC", 1, {})
