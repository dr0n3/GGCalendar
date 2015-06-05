local GGCalendar = Apollo.GetAddon("GGCalendar")

-- EVENTS:
-- ID: 			(playername..time of creation)
-- -- NAME 		(Veteran Kel Voreth)
-- -- CREATOR 	(Finn Walker)
-- -- DATE 		(25.06.15)

function GGCalendar:AddEvent(tEvent)
	GGCalendar.tEvents[tEvent.ID] = tEvent
end
