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

GGCalendar.tEvents = {}

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

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("ggc", "OnGGCalendarOn", self)
		Apollo.RegisterSlashCommand("ggcshow", "OnGGCalendarShow", self)

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
	tEvent = self:NewEvent(strArgs, "01.01.1970")
	self:AddEvent(tEvent)
	
	-- self.wndMain:Invoke() -- show the window
end

-- on SlashCommand "/ggcshow"
function GGCalendar:OnGGCalendarShow()
	strMsg = GGCalendar.JSON.encode(self.tEvents)
	Print("Events: "..strMsg)
	
	self:SyncCalendar()
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
