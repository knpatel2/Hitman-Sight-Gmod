CreateConVar("hitman_sight_slowmode_enabled", 1)
CreateConVar("hitman_sight_enabled", 1)

if (CLIENT) then
	
	hook.Add( "AddToolMenuCategories", "hitman_sight_category", function()
		spawnmenu.AddToolCategory( "Options", "Hitman Sight", "#Hitman Sight" )
	end)
	
	hook.Add( "PopulateToolMenu", "hitman_sight_menu", function()
		spawnmenu.AddToolMenuOption( "Options", "Hitman Sight", "Sight_Options", "#Sight Options", "", "", function(panel)
			panel:ClearControls()

			panel:AddControl("Checkbox", {
				Label = "Enabled",
				Command = "hitman_sight_enabled"
			})

			panel:AddControl("Numpad", {
				Label = "Set the bind key (Default: Left Ctrl)",
				Command = "hitman_sight_bindkey"
			})

			panel:AddControl("Checkbox", {
				Label = "Slowmode enabled",
				Command = "hitman_sight_slowmode_enabled"
			})
			
			local slider = vgui.Create("DNumSlider", panel)
			slider:SetText("Game time when in slowmode (Default: 0.3)")
			slider:SetConVar("hitman_sight_slowmode_intensity")
			slider:SetMin(0.1)
			slider:SetMax(0.9)
			slider:SetDecimals(1)
--			slider:SetValue(GetConVar(" "):GetInt())
			panel:AddItem(slider)

			--[[panel:AddControl("Checkbox", {
				Label = "Admin only",
				Command = "hitman_sight_admin"
			})]]

		end)
	end)
end

if (SERVER) then
	AddCSLuaFile("autorun/init.lua")
end