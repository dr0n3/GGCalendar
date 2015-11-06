local WHC = Apollo.GetAddon("WHCCalendar")
local List = Apollo.GetPackage("WHCCalendar:List").tPackage.Init()
local StateMASTERSYNC = { }
local masterList = nil

function StateMASTERSYNC.Init()
	local self = {
		d = { }	
	}
	
	function self:OnMessage(tChannel, tMsg, strSender)
		
	end
	
	function self:GetTimeout()
		return 20
	end
	
	function self:Do()
		local node = List:pop(masterList)
		if node ~= nil then
			WHC.masterSyncInProgress = true
			WHC:SendMessage(WHC.MessageType.SYNC_REQ, nil, node)
			WHC:SwitchState(WHC.StateWAITOFF)
			return
		end
		WHC.masterSyncInProgress = false
	end
	
	function self:InitMasterSync()
		masterList = List:new()
	
		for node, b in pairs(WHC.MasterNodes) do
			if node ~= GameLib.GetPlayerUnit():GetName() then
				List:push(masterList, node)
			end
		end
	end
	
	return self
end

Apollo.RegisterPackage(StateMASTERSYNC, "WHCCalendar:StateMASTERSYNC", 1, {})