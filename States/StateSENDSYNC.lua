local WHC = Apollo.GetAddon("WHCCalendar")
local List = Apollo.GetPackage("WHCCalendar:List").tPackage.Init()
local StateSENDSYNC = { }
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
		for i=0,4 do
			local event = List:pop(syncList)
			if not (event == nil or strRecipient == nil) then
				WHC:SendMessage(WHC.MessageType.SYNC, event, strRecipient)
				WHC:ResetTimeout()
			end
		end
	end
	
	function self:InitSync(strRec)
		syncList = List:new()
		for id, event in pairs(WHC.tEvents) do
			List:push(syncList, { ID = id, EVENT = event })
		end		
		
		strRecipient = strRec
	end
	
	return self
end

Apollo.RegisterPackage(StateSENDSYNC, "WHCCalendar:StateSENDSYNC", 1, {})