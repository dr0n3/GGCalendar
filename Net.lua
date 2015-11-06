local WHCCalendar = Apollo.GetAddon("WHCCalendar")

-- MESSAGE FORMAT:
-- TYPE		(MessageType)
-- MSG		(Message/Data, not necessarily string)
-- VERSION	(Version of the message protocol)
local MessageVersion = "1"
local tCommChannel
local tState = { }

WHCCalendar.masterSyncInProgress = false
WHCCalendar.MessageType = {
	SYNC_REQ = 1,
	SYNC_OFF = 2,
	SYNC_ACK = 3,
	SYNC = 4
}

local Channel = {
	GLOBAL = 1,
	PRIVATE = 2
}

WHCCalendar.MasterNodes = {
	["Finn Walker"] = true,
	["Pasha Brekov"] = true
}

function WHCCalendar:SetupNet()
	self.StateIDLE = Apollo.GetPackage("WHCCalendar:StateIDLE").tPackage.Init()
	self.StateWAITOFF = Apollo.GetPackage("WHCCalendar:StateWAITOFF").tPackage.Init()
	self.StateWAITACK = Apollo.GetPackage("WHCCalendar:StateWAITACK").tPackage.Init()
	self.StateSENDSYNC = Apollo.GetPackage("WHCCalendar:StateSENDSYNC").tPackage.Init()
	self.StateSYNC = Apollo.GetPackage("WHCCalendar:StateSYNC").tPackage.Init()
	self.StateMASTERSYNC = Apollo.GetPackage("WHCCalendar:StateMASTERSYNC").tPackage.Init()
	
	tState.current = self.StateIDLE
	tState.cooldown = 0

	Apollo.RegisterTimerHandler("SetupCommChannel", "SetupCommChannel", self)
	Apollo.CreateTimer("SetupCommChannel", 1, false)
	Apollo.StartTimer("SetupCommChannel")
	
	--Apollo.RegisterTimerHandler("PeriodicSync", "PeriodicSync", self)
	--Apollo.CreateTimer("PeriodicSync", 1, true)
	--Apollo.StartTimer("PeriodicSync")
	
	Apollo.RegisterTimerHandler("CheckState", "CheckState", self)
	Apollo.CreateTimer("CheckState", 2, true)
	Apollo.StartTimer("CheckState")
end

-----------------------------------------------------------------------------------------------
-- tCommChannel = global channel, where we are listing for sync requests
-----------------------------------------------------------------------------------------------

-- taken from the GroupFinder addon (https://bitbucket.org/jonasfriberg/groupfinder)
function WHCCalendar:SetupCommChannel()
	if not tCommChannel then
		local guilds = GuildLib.GetGuilds() or {}
		for i, guild in ipairs(guilds) do
			if guild:GetType() == GuildLib.GuildType_Guild then
				self.guild = guild
				break
			end
		end
		
		tCommChannel = ICCommLib.JoinChannel("whcWeHaveCandy", ICCommLib.CodeEnumICCommChannelType.Guild, self.guild)
	end
	
	if tCommChannel:IsReady() then
		tCommChannel:SetReceivedMessageFunction("OnCommMessageReceived", self)
		tCommChannel:SetSendMessageResultFunction("OnCommMessageResult", self)
	else
		Apollo.StartTimer("SetupCommChannel")
	end
end

function WHCCalendar:OnCommMessageResult(channel, eResult, idMessage)
	-- Print("Result: "..WHCCalendar.JSON.encode(eResult))
end

-----------------------------------------------------------------------------------------------
-- Message functions
-----------------------------------------------------------------------------------------------

function WHCCalendar:SendMessage(nType, tData, strRecipient)
	local channel = self:GetChannelType(nType)
	if strRecipient ~= nil then channel = Channel.PRIVATE end
	
	local tMsg = {
			TYPE = nType,
			MSG = tData,
			VERSION = MessageVersion
	}

	local strMsg = WHCCalendar.JSON.encode(tMsg)
	
	if (channel == Channel.GLOBAL) then
		tCommChannel:SendMessage(strMsg)
	else
		tCommChannel:SendPrivateMessage(strRecipient, strMsg)
	end
end

function WHCCalendar:OnCommMessageReceived(tChannel, tData, strSender)
	local tMsg = WHCCalendar.JSON.decode(tData)	
	
	if tMsg == nil then return end
	if tMsg.MSG == nil then tMsg.MSG = "" end
	
	if self:CheckForUpdate(tMsg.VERSION) then
		return
	end
	
	tState.current:OnMessage(tChannel, tMsg, strSender)
end

-----------------------------------------------------------------------------------------------
-- Sync functions
-----------------------------------------------------------------------------------------------

function WHCCalendar:RequestSync()
	self:SendMessage(self.MessageType.SYNC_REQ, nil, nil)
	self:SwitchState(self.StateWAITOFF)
end

-- sync with every master node available
function WHCCalendar:MasterSync()
	self:SwitchState(self.StateMASTERSYNC)
	tState.current:InitMasterSync()
	tState.current:Do()
end

-----------------------------------------------------------------------------------------------
-- Timers
-----------------------------------------------------------------------------------------------

function WHCCalendar:PeriodicSync()
	-- WHCCalendar:SyncCalendar()
end

function WHCCalendar:CheckState()
	if tState.current == self.StateSENDSYNC then
		tState.current:Do()
	end
	
	if tState.current ~= self.StateIDLE then
		if tState.timeout < os.time() then
			if self.masterSyncInProgress then
				self:SwitchState(self.StateMASTERSYNC)
				tState.current:Do()
			else
				self:SwitchState(self.StateIDLE)
				Print("New State: IDLE")
			end
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Other
-----------------------------------------------------------------------------------------------

function WHCCalendar:ResetTimeout()
	tState.timeout = os.time() + tState.current:GetTimeout()
end

function WHCCalendar:SwitchState(newState)
	tState.current = newState
	tState.timeout = os.time() + newState:GetTimeout()
end

function WHCCalendar:CheckForUpdate(version)
	if tonumber(version) > tonumber(MessageVersion) then
		Print("Der Gildenkalender ist veraltet! Bitte installiere die neuste Version.")
		return true
	end
	
	return false
end

function WHCCalendar:GetChannelType(messageType)
	if messageType == self.MessageType.SYNC_REQ then
		return Channel.GLOBAL
	else
		return Channel.PRIVATE
	end
end
