local WHCCalendar = Apollo.GetAddon("WHCCalendar")

-- tEvents:
-- ID: 			(playername..time of creation)
-- -- NAME 		(Veteran Kel Voreth)
-- -- CREATOR 	(Finn Walker)
-- -- DATE 		({day, month, year})
-- -- TIME		({hour, min})
-- -- NATTENDEES (number of attendees)
-- -- CHANGED	(time of last change)
-- -- CANCELED	(true or false)

WHCCalendar.tEvents = {}

-- date the UI is displaying, day is either 1 or selected day
WHCCalendar.tCurrentDate = {} -- { day, month, year }

function WHCCalendar:NewEvent(strName, iAttendees, tDate, tTime)
	local playername = GameLib.GetPlayerUnit():GetName()
	local playername = playername:gsub(" ", "")
	
	local tEvent = {
		NAME = strName,
		CREATOR = playername,
		DATE = deepcopy(tDate),
		TIME = deepcopy(tTime),
		NATTENDEES = iAttendees,
		CHANGED = os.time(),
		CANCELED = false
	}
	
	return tEvent
end

function WHCCalendar:AddEvent(tEvent)
	local id = tEvent.CREATOR..os.time()
	WHCCalendar.tEvents[id] = tEvent
end

function WHCCalendar:OnCalendarFormShow(wndHandler, wndControl)
	local now = os.date("*t")
	self:SetCurrentDate(now.day, now.month, now.year)
	
	self:BuildCalendar()
	self:RefreshEventList()
end

function WHCCalendar:BuildCalendar()
	local month = self.tCurrentDate.month
	local year = self.tCurrentDate.year
	local daysInMonth = GetDaysInMonth(month, year)
	local dowFirst = GetDayOfWeek(1, month, year) -- month starts on dow, Monday = 0
	local dowLast = GetDayOfWeek(daysInMonth, month, year) -- month ends on dow
	
	self.wndCalendar:DestroyChildren()
	
	local previousMonth, previousYear = ChangeDate(month - 1, year)
	local nextMonth, nextYear = ChangeDate(month + 1, year)
	local daysPreviousMonth = GetDaysInMonth(previousMonth, previousYear)
	
	-- fill first row with last days of previous month
	for i = daysPreviousMonth - dowFirst + 1, daysPreviousMonth do
		local item = Apollo.LoadForm(self.xmlDoc, "CalendarItem", self.wndCalendar, self)
		item:FindChild("lblDate"):SetText(i)
		item:FindChild("lblDate"):SetTextColor("UI_BtnTextHoloDisabled")
		item:SetData({day=i, month=previousMonth, year=previousYear})
	end
	
	-- do the current month
	for i = 1, daysInMonth do
		local item = Apollo.LoadForm(self.xmlDoc, "CalendarItem", self.wndCalendar, self)
		item:FindChild("lblDate"):SetText(i)
		item:SetData({day=i, month=month, year=year})
		
		local now = os.date("*t")
		
		if now.day == i and now.month == month and now.year == year then
			item:FindChild("lblDate"):SetTextColor("AddonError")
		end
		
		if self.tCurrentDate.day == i and self.tCurrentDate.month == month and self.tCurrentDate.year == year then
			item:FindChild("SelectedMarker"):SetSprite("BK3:sprHolo_ResizeHandle") -- apparently, there is no way to change the visibility on runtime
		end
		
		local events = self:FindEventsOnDate({day = i, month = month, year = year})
		
		if next(events) ~= nil then
			item:FindChild("EventMarker"):SetSprite("BK3:UI_Icon_CharacterCreate_Class_Medic")
		end
	end
	
	local totalDaysYet = dowFirst + daysInMonth -- number of days, that are now displayed
	
	-- fill rest of calendar with first days of next month
	for i = totalDaysYet + 1, 42 do
		local item = Apollo.LoadForm(self.xmlDoc, "CalendarItem", self.wndCalendar, self)
		item:FindChild("lblDate"):SetText(i - totalDaysYet)
		item:FindChild("lblDate"):SetTextColor("UI_BtnTextHoloDisabled")
		item:SetData({day=(i - totalDaysYet), month=nextMonth, year=nextYear})
		
		local events = self:FindEventsOnDate({day = (i - totalDaysYet), month = nextMonth, year = nextYear})
		if next(events) ~= nil then
			item:FindChild("EventMarker"):SetSprite("BK3:UI_Icon_CharacterCreate_Class_Medic")
			item:FindChild("EventMarker"):SetBGColor("darkgray")
		end
	end
	
	local strMonth = GetNameOfMonth(month)
	self.wndCalendarControl:FindChild("lblMonthYear"):SetText(strMonth..", "..year)
	
	self.wndCalendar:ArrangeChildrenTiles()
end

function WHCCalendar:RefreshEventList()
	self.wndEventList:DestroyChildren()
	local events = self:FindEventsOnDate(self.tCurrentDate)

	for i, id in pairs(events) do
		local listItem = Apollo.LoadForm(self.xmlDoc, "ListItem", self.wndEventList, self)
		
		local name = self.tEvents[id].NAME
		local hour = self.tEvents[id].TIME.hour
		local min = self.tEvents[id].TIME.min
		local creator = self.tEvents[id].CREATOR
				
		listItem:FindChild("Title"):SetText(name)
		listItem:FindChild("Time"):SetText(AddLeadingZero(hour)..":"..AddLeadingZero(min))
		listItem:FindChild("Creator"):SetText("Erstellt von: "..creator)
		listItem:SetData({id=id})
	end
	
	self.wndEventList:ArrangeChildrenVert()
	
	local day = self.tCurrentDate.day
	local month = self.tCurrentDate.month
	
	self.wndSelectedDate:SetText("Events am "..AddLeadingZero(day).."."..AddLeadingZero(month).."."..self.tCurrentDate.year)
end

-----------------------------------------------------------------------------------------------
-- CalendarControl Buttons
-----------------------------------------------------------------------------------------------

function WHCCalendar:OnBtnNextMonth()
	local month, year = ChangeDate(self.tCurrentDate.month + 1, self.tCurrentDate.year)
	self:SetCurrentDate(1, month, year)
	self:BuildCalendar()
	self:RefreshEventList()
end

function WHCCalendar:OnBtnLastMonth()
	local month, year = ChangeDate(self.tCurrentDate.month - 1, self.tCurrentDate.year)
	self:SetCurrentDate(1, month, year)
	self:BuildCalendar()
	self:RefreshEventList()
end

-----------------------------------------------------------------------------------------------
-- EventControl Buttons
-----------------------------------------------------------------------------------------------

function WHCCalendar:OnBtnAddEvent()
	if self.wndAddEvent == nil then
		self.wndAddEvent = Apollo.LoadForm(self.xmlDoc, "AddEventForm", nil, self)
		self.wndMain:Enable(false)
	end
end

-----------------------------------------------------------------------------------------------
-- CalendarItem Events
-----------------------------------------------------------------------------------------------

function WHCCalendar:OnCalendarItemClick(wndHandler, wndControl)
	local tDate = wndControl:GetParent():GetData()
	self:SetCurrentDate(tDate.day, tDate.month, tDate.year)
	
	self:BuildCalendar()
	self:RefreshEventList()
end

-----------------------------------------------------------------------------------------------
-- EventListItem Events
-----------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------
-- Other Functions
-----------------------------------------------------------------------------------------------

function WHCCalendar:SetCurrentDate(day, month, year)	
	self.tCurrentDate = {day=day, month=month, year=year}
end

function WHCCalendar:FindEventsOnDate(tDate)
	local day, month, year = tDate.day, tDate.month, tDate.year
	local listEvents = {} -- list of IDs of events on tDate
	
	for id, event in pairs(self.tEvents) do
		if event.DATE.day == day and event.DATE.month == month and event.DATE.year == year then
			table.insert(listEvents, id)
		end
	end
	
	return listEvents
end

function AddLeadingZero(number)
	number = tonumber(number)
	
	if number < 10 then number = "0"..number end
	
	return number
end

-- returns the number of days in a given month and year
-- Compatible with Lua 5.0 and 5.1.
-- from sam_lie (http://lua-users.org/wiki/DayOfWeekAndDaysInMonthExample)
function GetDaysInMonth(month, year)
	local days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }   
	local d = days_in_month[month]
   
	-- check for leap year
	if (month == 2) then
		if (math.mod(year,4) == 0) then
			if (math.mod(year,100) == 0) then
				if (math.mod(year,400) == 0) then
					d = 29
				end
			else
				d = 29
			end
		end
	end

	return d
end

function GetDayOfWeek(day, month, year)
	dow = os.date('*t', os.time{year=year,month=month,day=day})['wday']
	return (dow + 5) % 7
end

function GetNameOfMonth(month)
	local months = {
		"Januar",
		"Februar",
		"März",
		"April",
		"Mai",
		"Juni",
		"Juli",
		"August",
		"September",
		"Oktober",
		"November",
		"Dezember"
	}
	
	return months[month]
end

function ChangeDate(month, year)
	while month > 12 do
		month = month - 12
		year = year + 1
	end
	
	while month < 1 do
		month = month + 12
		year = year - 1
	end

	return month, year
end

-- from http://lua-users.org/wiki/CopyTable
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

