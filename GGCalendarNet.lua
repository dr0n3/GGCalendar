local GGCalendar = Apollo.GetAddon("GGCalendar")

GGCalendar.MessageType = {
	SYNC = 1
}

-- MESSAGE FORMAT:
-- TYPE		(MessageType)
-- MSG		(Message/Data, not necessarily string)
-- VERSION	(Version of the message protocol)

local tCommChannel
local MessageVersion = "1"

function GGCalendar:SetupChat()	
	Apollo.RegisterTimerHandler("SetupCommChannel", "SetupCommChannel", self)
	Apollo.CreateTimer("SetupCommChannel", 1, false)
	Apollo.StartTimer("SetupCommChannel")
	
	Apollo.RegisterTimerHandler("PeriodicSync", "PeriodicSync", self)
	Apollo.CreateTimer("PeriodicSync", 30, true)
	Apollo.StartTimer("PeriodicSync")
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

function GGCalendar:PeriodicSync()
	GGCalendar:SyncCalendar()
end

function GGCalendar:OnMessageReceived(tChannel, tData)
	local tMsg = GGCalendar.JSON.decode(tData)
	
	if tMsg == nil then return end
	
	if tonumber(tMsg.VERSION) > tonumber(MessageVersion) then
		Print("GGCalendar ist veraltet! Bitte installiere die neuste Version.")
		return
	end
	
	if tMsg.TYPE == GGCalendar.MessageType.SYNC then
		local tNewEvents = tMsg.EVENTS
		
		for id,event in pairs(tNewEvents) do
			local myEvent = GGCalendar.tEvents[id]
			
			if myEvent == nil or myEvent.CHANGED < event.CHANGED then
				GGCalendar:AddEvent(event)
			end
		end
	end
end

function GGCalendar:BroadcastMessage(nType, tEvents)
	local tMsg = {
		TYPE = nType,
		EVENTS = tEvents,
		VERSION = MessageVersion
	}
	
	local strMsg = GGCalendar.JSON.encode(tMsg)
	tCommChannel:SendMessage(strMsg)
end

function GGCalendar:SyncCalendar()
	self:BroadcastMessage(self.MessageType.SYNC, GGCalendar.tEvents)
end