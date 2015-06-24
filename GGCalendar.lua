-----------------------------------------------------------------------------------------------
-- Client Lua Script for GGCalendar
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
require "ICComm"
require "ICCommLib"
 
-----------------------------------------------------------------------------------------------
-- GGCalendar Module Definition
-----------------------------------------------------------------------------------------------
local GGCalendar = {} 

GGCalendar.JSON = Apollo.GetPackage("Lib:dkJSON-2.5").tPackage
GGCalendar.ADDON_VERSION = 0.1

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function GGCalendar:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- initialize variables here

    return o
end

function GGCalendar:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- GGCalendar OnLoad
-----------------------------------------------------------------------------------------------
function GGCalendar:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("GGCalendar.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- GGCalendar OnSave OnRestore
-----------------------------------------------------------------------------------------------

function GGCalendar:OnSave(eLevel)
	local tSave = {}

	if (eLevel == GameLib.CodeEnumAddonSaveLevel.Account) then		
		tSave = {tEvents = self.tEvents}

		return tSave
	end
end

function GGCalendar:OnRestore(eLevel, tSavedData)
	if (eLevel == GameLib.CodeEnumAddonSaveLevel.Account) then
		if tSavedData.tEvents ~= nil then 
			self.tEvents = tSavedData.tEvents
		end
	end
end

-----------------------------------------------------------------------------------------------
-- GGCalendar OnDocLoaded
-----------------------------------------------------------------------------------------------
function GGCalendar:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "GGCalendarForm", nil, self)
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
		Apollo.RegisterSlashCommand("ggc", "OnGGCalendarOn", self)
		Apollo.RegisterSlashCommand("ggcshow", "OnGGCalendarShow", self)
		Apollo.RegisterSlashCommand("ggcadd", "OnGGCalendarAdd", self)

		-- setup chat network
		self:SetupChat()

		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- GGCalendar Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/ggc"
function GGCalendar:OnGGCalendarOn(strCmd, strArgs)		
	self.wndMain:Invoke() -- show the window
end

-- on SlashCommand "/ggcshow"
function GGCalendar:OnGGCalendarShow()
	self:SyncCalendar()

	local strMsg = GGCalendar.JSON.encode(self.tEvents)
	Print("Events: "..strMsg)
end

-- on SlashCommand "/ggcadd"
function GGCalendar:OnGGCalendarAdd(strCmd, strArgs)
	local now = os.date("*t")
	now.hour = now.hour + 3
	
	local event = self:NewEvent(strArgs, now)
	self:AddEvent(event)
end


-----------------------------------------------------------------------------------------------
-- GGCalendarForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function GGCalendar:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function GGCalendar:OnCancel()
	self.wndMain:Close() -- hide the window
end

-----------------------------------------------------------------------------------------------
-- GGCalendar Instance
-----------------------------------------------------------------------------------------------
local GGCalendarInst = GGCalendar:new()
GGCalendarInst:Init()
