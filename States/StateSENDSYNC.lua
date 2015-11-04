local WHC = Apollo.GetAddon("WHCCalendar")
local StateSENDSYNC = { }
local List = Apollo.GetPackage("WHCCalendar:List").tPackage.Init()
local syncList = nil
local strRecipient = nil

function StateSENDSYNC.Init()
	local self = {
		d = { }	
	}
	
	function self:OnMessage(tChannel, tMsg, strSender)
		
	end
	
	function self:GetTimeout()
		return 15
	end
	
	function self:Do()
		local event = List:pop(syncList)
		if not (event == nil or strRecipient == nil) then
			WHC:SendMessage(WHC.MessageType.SYNC, event, strRecipient)
			WHC:ResetTimeout()
			Print("Send Sync: "..event)
		end
	end
	
	function self:InitSync(strRec)
		syncList = List:new()
		List:push(syncList, "test1")
		List:push(syncList, "test2")
		List:push(syncList, "test3")
		
		strRecipient = strRec
	end
	
	return self
end

Apollo.RegisterPackage(StateSENDSYNC, "WHCCalendar:StateSENDSYNC", 1, {})