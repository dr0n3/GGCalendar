local GGCalendar = Apollo.GetAddon("GGCalendar")

GGCalendar.MessageType = {
	SYNC = 1,
	NEW_EVENT = 2
}

local tCommChannel

function GGCalendar:SetupChat()	
	Apollo.RegisterTimerHandler("SetupCommChannel", "SetupCommChannel", self)
	Apollo.CreateTimer("SetupCommChannel", 5, false)
	Apollo.StartTimer("SetupCommChannel")
	
	-- self:SyncCalendar()
end

-- taken from the GroupFinder addon
function GGCalendar:SetupCommChannel()
	Print("Setting up channel")
	if not tCommChannel then
		Print("joining channel")
		tCommChannel = ICCommLib.JoinChannel("GGCalendar", ICCommLib.CodeEnumICCommChannelType.Global)
	end
	
	if tCommChannel:IsReady() then
		Print("joined channel")
		tCommChannel:SetSendMessageResultFunction("OnSendMessageResultEvent", self)
        tCommChannel:SetJoinResultFunction("OnJoinResultEvent", self)
        tCommChannel:SetThrottledFunction("OnThrottledEvent", self)
		tCommChannel:SetReceivedMessageFunction("OnMessageReceived", self)
	else
		Apollo.StartTimer("SetupCommChannel")
	end
end

function GGCalendar:OnSendMessageResultEvent(iccomm, eResult, idMessage)
    Print("Send result: "..eResult.." - "..idMessage)
end

function GGCalendar:OnJoinResultEvent(iccomm, eResult)
    Print("Join result: "..eResult)
end

function GGCalendar:OnThrottledEvent(iccomm, strSender, idMessage)
    
end

function GGCalendar:OnMessageReceived(tChannel, tData)
	Print("received")
	tMsg = GGCalendar.JSON.decode(tData)
	
	Print("Data: "..tMsg)
end

function GGCalendar:BroadcastMessage(nType, strMsg)
	tMsg = {
		TYPE = nType,
		MSG = strMsg
	}
	
	tCommChannel:SendMessage(GGCalendar.JSON.encode(tMsg))
	Print("sent")
end

function GGCalendar:SyncCalendar()
	self:BroadcastMessage(self.MessageType.SYNC, "")
end