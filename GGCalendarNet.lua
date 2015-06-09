local GGCalendar = Apollo.GetAddon("GGCalendar")

GGCalendar.MessageType = {
	SYNC = 1
}

-- MESSAGE FORMAT:
-- TYPE		(MessageType)
-- MSG		(Message/Data, not necessarily string)

local tCommChannel

function GGCalendar:SetupChat()	
	Apollo.RegisterTimerHandler("SetupCommChannel", "SetupCommChannel", self)
	Apollo.CreateTimer("SetupCommChannel", 1, false)
	Apollo.StartTimer("SetupCommChannel")
end

-- taken from the GroupFinder addon (https://bitbucket.org/jonasfriberg/groupfinder)
function GGCalendar:SetupCommChannel()
	if not tCommChannel then
		tCommChannel = ICCommLib.JoinChannel("GGCalendar", ICCommLib.CodeEnumICCommChannelType.Global)
	end
	
	if tCommChannel:IsReady() then
		tCommChannel:SetReceivedMessageFunction("OnMessageReceived", self)
	else
		Apollo.StartTimer("SetupCommChannel")
	end
end

function GGCalendar:OnMessageReceived(tChannel, tData)
	local tMsg = GGCalendar.JSON.decode(tData)
	
	if tMsg.TYPE == GGCalendar.MessageType.SYNC then
		local tNewEvents = tMsg.MSG
		
		for id,event in pairs(tNewEvents) do
			local myEvent = GGCalendar.tEvents[id]
			
			if myEvent == nil or myEvent.CHANGED < event.CHANGED then
				GGCalendar:AddEvent(event)
			end
		end
	end
end

function GGCalendar:BroadcastMessage(nType, tData)
	local tMsg = {
		TYPE = nType,
		MSG = tData
	}
	
	local strMsg = GGCalendar.JSON.encode(tMsg)
	tCommChannel:SendMessage(strMsg)
end

function GGCalendar:SyncCalendar()
	self:BroadcastMessage(self.MessageType.SYNC, GGCalendar.tEvents)
end