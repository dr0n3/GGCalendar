local GGCalendar = Apollo.GetAddon("GGCalendar")

-- EVENTS TABLE:
-- ID: 			(playername..time of creation)
-- -- NAME 		(Veteran Kel Voreth)
-- -- ID 		(playername..time of creation)
-- -- CREATOR 	(Finn Walker)
-- -- DATE 		(25.06.15)
-- -- CHANGED	(time of last change)
-- -- CANCELED	(true or false)

function GGCalendar:NewEvent(strName, strDate)
	playername = GameLib.GetPlayerUnit():GetName()
	playername = playername:gsub(" ", "")
	
	id = playername..os.time()
	
	tEvent = {
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
