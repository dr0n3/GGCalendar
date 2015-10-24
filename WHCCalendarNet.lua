local WHCCalendar = Apollo.GetAddon("WHCCalendar")

WHCCalendar.MessageType = {
	SYNC = 1
}

-- MESSAGE FORMAT:
-- TYPE		(MessageType)
-- MSG		(Message/Data, not necessarily string)
-- VERSION	(Version of the message protocol)

local tCommChannel
local MessageVersion = "1"

function WHCCalendar:SetupChat()	
	Apollo.RegisterTimerHandler("SetupCommChannel", "SetupCommChannel", self)
	Apollo.CreateTimer("SetupCommChannel", 1, false)
	Apollo.StartTimer("SetupCommChannel")
	
	-- Apollo.RegisterTimerHandler("PeriodicSync", "PeriodicSync", self)
	-- Apollo.CreateTimer("PeriodicSync", 30, true)
	-- Apollo.StartTimer("PeriodicSync")
end

-- taken from the GroupFinder addon (https://bitbucket.org/jonasfriberg/groupfinder)
function WHCCalendar:SetupCommChannel()
	if not tCommChannel then
		tCommChannel = ICCommLib.JoinChannel("whcWeHaveCandy2", ICCommLib.CodeEnumICCommChannelType.Global)
	end
	
	if tCommChannel:IsReady() then
		tCommChannel:SetReceivedMessageFunction("OnMessageReceived", self)
		tCommChannel:SetSendMessageResultFunction("OnMessageResult", self)
	else
		Apollo.StartTimer("SetupCommChannel")
	end
end

function WHCCalendar:PeriodicSync()
	WHCCalendar:SyncCalendar()
end

function WHCCalendar:OnMessageReceived(tChannel, tData)
	local tMsg = WHCCalendar.JSON.decode(tData)
	Print("Received!")
	
	if tMsg == nil then return end
	
	if tonumber(tMsg.VERSION) > tonumber(MessageVersion) then
		Print("Der Gildenkalender ist veraltet! Bitte installiere die neuste Version.")
		return
	end
	
	if tMsg.TYPE == WHCCalendar.MessageType.SYNC then
		local tNewEvents = tMsg.EVENTS
		
		for id,event in pairs(tNewEvents) do
			local myEvent = WHCCalendar.tEvents[id]
			
			if myEvent == nil or myEvent.CHANGED < event.CHANGED then
				WHCCalendar:AddEvent(event)
			end
		end
	end
end

function WHCCalendar:OnMessageResult(channel, eResult, idMessage)
	Print("Result: "..WHCCalendar.JSON.encode(eResult))
end

function WHCCalendar:BroadcastMessage(nType, tEvents)
	local tMsg = {
		TYPE = nType,
		EVENTS = tEvents,
		VERSION = MessageVersion
	}
	
	local strMsg = WHCCalendar.JSON.encode(tMsg)
	tCommChannel:SendMessage(strMsg)
	Print("Send!")
end

function WHCCalendar:SyncCalendar()
	self:BroadcastMessage(self.MessageType.SYNC, WHCCalendar.tEvents)
end