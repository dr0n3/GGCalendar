local WHC = Apollo.GetAddon("WHCCalendar")
local StateWAITOFF = { }

function StateWAITOFF.Init()
	local self = {
		d = { }	
	}
	
	function self:OnMessage(tChannel, tMsg, strSender)
		if tMsg.TYPE ~= WHC.MessageType.SYNC_OFF then
			return
		end
	
		Print(strSender.." offers sync")
		
		if WHC.MasterNodes[strSender] then
			Print(strSender.." is a master node - accepting sync")
			WHC:SendMessage(WHC.MessageType.SYNC_ACK, nil, strSender)
			WHC:SwitchState(WHC.StateSYNC)
		end
	end
	
	function self:GetTimeout()
		return 10
	end
	
	function self:Do()
	end
	
	return self
end

Apollo.RegisterPackage(StateWAITOFF, "WHCCalendar:StateWAITOFF", 1, {})