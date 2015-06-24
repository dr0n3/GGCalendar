local GGCalendar = Apollo.GetAddon("GGCalendar")


-----------------------------------------------------------------------------------------------
-- AddEventForm Buttons
-----------------------------------------------------------------------------------------------

function GGCalendar:OnBtnNewEventAccept()
	local name = self.wndAddEvent:FindChild("tbName"):GetText()
	local hour = self.wndAddEvent:FindChild("tbHour"):GetText()
	local min = self.wndAddEvent:FindChild("tbMin"):GetText()
	local attendees = self.wndAddEvent:FindChild("tbNumberAttendees"):GetText()
	local error = false
	
	hour, min, attendees = tonumber(hour), tonumber(min), tonumber(attendees)
	
	if hour == nil or hour < 0 or hour > 23 then Print("'Stunde' ist keine gültige Eingabe."); error = true end
	if min == nil or min < 0 or min > 59 then Print("'Minute' ist keine gültige Eingabe."); error = true end
	if attendees == nil or attendees < 0 then Print("'Teilnehmeranzahl' ist keine gültige Eingabe."); error = true end
	
	if not error then
		local tEvent = self:NewEvent(name, attendees, GGCalendar.tCurrentDate, {hour = hour, min = min})
		self:AddEvent(tEvent)
		self:BuildCalendar()
		self:RefreshEventList()
	end
	
	self.wndAddEvent:Destroy()
	self.wndAddEvent = nil
	self.wndMain:Enable(true)
end

function GGCalendar:OnBtnNewEventCancel()
	self.wndAddEvent:Destroy()
	self.wndAddEvent = nil
	self.wndMain:Enable(true)
end