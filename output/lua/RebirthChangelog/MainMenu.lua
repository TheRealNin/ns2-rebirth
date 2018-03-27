 
Script.Load("lua/RebirthChangelog/GUIRebirthChangelog.lua")

local changelog

local oldMainMenu_Preload = MainMenu_Preload
function MainMenu_Preload()
    oldMainMenu_Preload()

	if not changelog then
		local mm = GetGUIMainMenu and GetGUIMainMenu()
		if mm then
			changelog = CreateMenuElement(mm.mainWindow, "GUIRebirthChangelog")

            
			local eventCallbacks =
			{
				OnShow = function (self)
					changelog:SetIsVisible(MainMenu_IsInGame())
				end,
			}
			mm.mainWindow:AddEventCallbacks(eventCallbacks)
		end

		-- show initially only if in game
		if MainMenu_IsInGame() then
			changelog:SetIsVisible(true)
		end
	end
    
end

local oldMainMenu_Open = MainMenu_Open
function MainMenu_Open()
    oldMainMenu_Open()
    
    if changelog then
        changelog:SetIsVisible(true)
    end
end

local oldLeaveMenu = LeaveMenu
function LeaveMenu()

    if changelog then
        changelog:SetIsVisible(false)
    end
    
    oldLeaveMenu()
    
end
