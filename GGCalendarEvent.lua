local GGCalendar = Apollo.GetAddon("GGCalendar")
local tCurrent = os.date("*t") -- date/month the UI is displaying

-- EVENTS TABLE:
-- ID: 			(playername..time of creation)
-- -- NAME 		(Veteran Kel Voreth)
-- -- ID 		(playername..time of creation)
-- -- CREATOR 	(Finn Walker)
-- -- DATE 		(25.06.15)
-- -- CHANGED	(time of last change)
-- -- CANCELED	(true or false)

function GGCalendar:NewEvent(strName, strDate)
	local playername = GameLib.GetPlayerUnit():GetName()
	local playername = playername:gsub(" ", "")
	
	local id = playername..os.time()
	
	local tEvent = {
		ID = id,
		NAME = strName,
		CREATOR = playername,
		DATE = strDate,
		CHANGED = os.time(),
		CANCELED = false
	}
	
	return tEvent
end

function GGCalendar:AddEvent(tEvent)	
	GGCalendar.tEvents[tEvent.ID] = tEvent
end

function GGCalendar:BuildCalendar()
	local month = tCurrent.month
	local year = tCurrent.year
	local daysInMonth = GetDaysInMonth(month, year)
	local strMonth = GetNameOfMonth(month)
	local dowFirst = GetDayOfWeek(1, month, year) -- month starts on dow, Monday = 0
	local dowLast = GetDayOfWeek(daysInMonth, month, year) -- month starts on dow, Monday = 0
	
	self.wndCalendar:DestroyChildren()
	
	daysPreviousMonth = GetDaysInMonth(ChangeDate(month - 1, year))
	
	-- fill first row with last days of previous month
	for i = daysPreviousMonth - dowFirst + 1, daysPreviousMonth do
		item = Apollo.LoadForm(self.xmlDoc, "CalendarItem", self.wndCalendar, self)
		item:FindChild("lblDate"):SetText(i)
		item:FindChild("lblDate"):SetTextColor("UI_BtnTextHoloDisabled")
	end
	
	-- do the current month
	for i = 1, daysInMonth do
		item = Apollo.LoadForm(self.xmlDoc, "CalendarItem", self.wndCalendar, self)
		item:FindChild("lblDate"):SetText(i)
	end
	
	local totalDaysYet = dowFirst + daysInMonth -- number of days, that are now displayed
	
	-- fill rest of calendar with first days of next month
	for i = totalDaysYet + 1, 42 do
		item = Apollo.LoadForm(self.xmlDoc, "CalendarItem", self.wndCalendar, self)
		item:FindChild("lblDate"):SetText(i - totalDaysYet)
		item:FindChild("lblDate"):SetTextColor("UI_BtnTextHoloDisabled")
	end
	
	self.wndCalendarControl:FindChild("lblMonthYear"):SetText(strMonth..", "..year)
	
	self.wndCalendar:ArrangeChildrenTiles()
end

-----------------------------------------------------------------------------------------------
-- CalendarControl Buttons
-----------------------------------------------------------------------------------------------

function GGCalendar:OnBtnNextMonth()
	local month, year = ChangeDate(tCurrent.month + 1, tCurrent.year)
	self:SetCurrent(month, year)
end

function GGCalendar:OnBtnLastMonth()
	local month, year = ChangeDate(tCurrent.month - 1, tCurrent.year)
	self:SetCurrent(month, year)
end

function GGCalendar:SetCurrent(month, year)
	tCurrent = os.date("*t", os.time{year=year, month=month, day=1})
	self:BuildCalendar()
end

-----------------------------------------------------------------------------------------------
-- Other Functions
-----------------------------------------------------------------------------------------------

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

