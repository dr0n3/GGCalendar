local WHC = Apollo.GetAddon("WHCCalendar")
local StateIDLE = { }

function StateIDLE.Init()
	local self = {
		d = { }	
	}
	
	function self:OnMessage(tChannel, tMsg, strSender)
		if tMsg.TYPE ~= WHC.MessageType.SYNC_REQ then
			return
		end
		
		Print(strSender.." requests sync")
		
		if WHC.MasterNodes[GameLib.GetPlayerUnit():GetName()] then
			Print("Sending sync offer")
			WHC:SendMessage(WHC.MessageType.SYNC_OFF, nil, strSender)
			WHC:SwitchState(WHC.StateWAITACK)
		end
	end
	
	function self:GetTimeout()
		return 0
	end
	
	function self:Do()
	end
	
	return self
end

Apollo.RegisterPackage(StateIDLE, "WHCCalendar:StateIDLE", 1, {})
