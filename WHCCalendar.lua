-----------------------------------------------------------------------------------------------
-- Client Lua Script for WHCCalendar
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
require "ICComm"
require "ICCommLib"
 
-----------------------------------------------------------------------------------------------
-- WHCCalendar Module Definition
-----------------------------------------------------------------------------------------------
local WHCCalendar = {} 

WHCCalendar.JSON = Apollo.GetPackage("Lib:dkJSON-2.5").tPackage
WHCCalendar.ADDON_VERSION = 0.2

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function WHCCalendar:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- initialize variables here

    return o
end

function WHCCalendar:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- WHCCalendar OnLoad
-----------------------------------------------------------------------------------------------
function WHCCalendar:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("WHCCalendar.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- WHCCalendar OnSave OnRestore
-----------------------------------------------------------------------------------------------

function WHCCalendar:OnSave(eLevel)
	local tSave = {}

	if (eLevel == GameLib.CodeEnumAddonSaveLevel.Character) then		
		tSave = {tEvents = self.tEvents, MasterNodes = self.MasterNodes}

		return tSave
	end
end

function WHCCalendar:OnRestore(eLevel, tSavedData)
	if (eLevel == GameLib.CodeEnumAddonSaveLevel.Character) then
		if tSavedData.tEvents ~= nil then 
			self.tEvents = tSavedData.tEvents
			self.MasterNodes = tSavedData.MasterNodes or self.MasterNodes
		end
	end
end

-----------------------------------------------------------------------------------------------
-- WHCCalendar OnDocLoaded
-----------------------------------------------------------------------------------------------
function WHCCalendar:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "WHCCalendarForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)
	
		self.wndCalendar = self.wndMain:FindChild("CalendarGrid")
		self.wndCalendarControl = self.wndMain:FindChild("CalendarControlGrid")
		
		self.wndEvents = self.wndMain:FindChild("Events")
		self.wndSelectedDate = self.wndEvents:FindChild("lblSelectedDate")
		self.wndEventList = self.wndEvents:FindChild("EventList")
		
		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("whc", "OnWHCCalendarOn", self)
		Apollo.RegisterSlashCommand("whcshow", "OnWHCCalendarShow", self)
		Apollo.RegisterSlashCommand("whccd", "OnWHCCalendarCD", self)
		Apollo.RegisterSlashCommand("whcsync", "OnWHCCalendarSync", self)
		Apollo.RegisterSlashCommand("whcmaster", "OnWHCCalendarMaster", self)
		Apollo.RegisterSlashCommand("whcaddmn", "OnWHCCalendarAddMN", self)
		Apollo.RegisterSlashCommand("whcremovemn", "OnWHCCalendarRemoveMN", self)

		-- setup chat network
		self:SetupNet()

		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- WHCCalendar Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/whc"
function WHCCalendar:OnWHCCalendarOn(strCmd, strArgs)		
	self.wndMain:Invoke() -- show the window
end

-- on SlashCommand "/whcshow"
function WHCCalendar:OnWHCCalendarShow()
	-- self:SyncCalendar()

	local strMsg = WHCCalendar.JSON.encode(self.tEvents)
	Print("Events: "..strMsg)
	
	for node, b in pairs(self.MasterNodes) do
		Print("Master Node: "..node)
	end
	
	Print("MN Changed: "..self.MasterNodes.CHANGED)
end

-- on SlashCommand "/whccd"
function WHCCalendar:OnWHCCalendarCD(strCmd, strArgs)
	local up = ICCommLib.GetUploadCapacityByType(ICCommLib.CodeEnumICCommChannelType.Guild)
	local down = ICCommLib.GetDownloadCapacityByType(ICCommLib.CodeEnumICCommChannelType.Guild)
	Print("up: "..up.." down: "..down)
end

-- on SlashCommand "/whcsync"
function WHCCalendar:OnWHCCalendarSync()
	self:RequestSync()
end

-- on SlashCommand "/whcmaster"
function WHCCalendar:OnWHCCalendarMaster()
	self:MasterSync()
end

-- on SlashCommand "/whcaddmn"
function WHCCalendar:OnWHCCalendarAddMN(strCmd, strArgs)
	local name = strArgs
	
	if name == nil or name == "" then return end
	self.MasterNodes[name] = true
	self.MasterNodes.CHANGED = os.time()
end

function WHCCalendar:OnWHCCalendarRemoveMN(strCmd, strArgs)
	local name = strArgs
	
	if name == nil or name == "" then return end
	self.MasterNodes[name] = nil
	self.MasterNodes.CHANGED = os.time()
end

-----------------------------------------------------------------------------------------------
-- WHCCalendarForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function WHCCalendar:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function WHCCalendar:OnCancel()
	self.wndMain:Close() -- hide the window
end

-----------------------------------------------------------------------------------------------
-- WHCCalendar Instance
-----------------------------------------------------------------------------------------------
local WHCCalendarInst = WHCCalendar:new()
WHCCalendarInst:Init()
