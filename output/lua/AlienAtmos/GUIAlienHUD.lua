
--[[
local oldUpdate = GUIAlienHUD.Update
function GUIAlienHUD:Update(deltaTime)
	oldUpdate(self, deltaTime)
	
    local player = Client.GetLocalPlayer()
	local offset
	if player then
	
		if not player._GUI_shove then
			player._GUI_shove = 0
		end
		offset = Vector(0, GUIScale(player._GUI_shove * 1.5), 0) 
		
	else
		offset = Vector(0, 0, 0) 
		
	end
	
	self.resourceBackground:SetPosition( offset )
	--self.inventoryDisplay:SetPosition( offset )
	
end

]]--