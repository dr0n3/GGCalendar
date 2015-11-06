local WHC = Apollo.GetAddon("WHCCalendar")
local StateWAITACK = { }

function StateWAITACK.Init()
	local self = {
		d = { }	
	}
	
	function self:OnMessage(tChannel, tMsg, strSender)
		if tMsg.TYPE ~= WHC.MessageType.SYNC_ACK then
			return
		end
	
		Print(strSender.." accepts sync")
		WHC:SwitchState(WHC.StateSENDSYNC)
		WHC.StateSENDSYNC:InitSync(strSender)
	end
	
	function self:GetTimeout()
		return 5
	end
	
	function self:Do()
	end
	
	return self
end

Apollo.RegisterPackage(StateWAITACK, "WHCCalendar:StateWAITACK", 1, {})
