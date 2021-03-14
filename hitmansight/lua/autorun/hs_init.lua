CreateConVar("hitman_sight_slowmode_enabled", 1)
CreateConVar("hitman_sight_enabled", 1)
CreateConVar("hitman_sight_admin_only", 1)
CreateConVar("hitman_sight_update_hightlights", 0.5)

if (CLIENT) then
	
	hook.Add( "AddToolMenuCategories", "hitman_sight_category", function()
		spawnmenu.AddToolCategory( "Options", "Hitman Sight", "#Hitman Sight" )
	end)
	
	hook.Add( "PopulateToolMenu", "hitman_sight_menu", function()
		spawnmenu.AddToolMenuOption( "Options", "Hitman Sight", "Sight_Options", "#Sight Options", "", "", function(panel)
			panel:ClearControls()

			panel:AddControl("Label", {
				Text = "Server"
			})

			panel:AddControl("Checkbox", {
				Label = "Enabled",
				Command = "hitman_sight_enabled"
			})

			panel:AddControl("Checkbox", {
				Label = "Slowmode enabled",
				Command = "hitman_sight_slowmode_enabled"
			})

			local slider = vgui.Create("DNumSlider", panel)
			slider:SetText("Highlight color update time (Default: 0.7)")
			slider:SetConVar("hitman_sight_update_hightlights")
			slider:SetMin(0.5)
			slider:SetMax(5)
			slider:SetDecimals(1)
			panel:AddItem(slider)

			panel:AddControl("Label", {
				Text = "Client"
			})

			panel:AddControl("Checkbox", {
				Label = "Toggled",
				Command = "hitman_sight_toggle"
			})

			panel:AddControl("Checkbox", {
				Label = "Gray screen enabled",
				Command = "hitman_sight_gray_screen"
			})

			panel:AddControl("Numpad", {
				Label = "Set the bind key (Default: Left Ctrl)",
				Command = "hitman_sight_bindkey"
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

	hook.Add("InitPostEntity", "hitman_sight_load_players", function()
		if IsValid(LocalPlayer()) and LocalPlayer():IsAdmin() == true then   
			spawnmenu.AddToolMenuOption( "Options", "Hitman Sight", "Admin_Options", "#Admin Options", "", "", function(panel)
				panel:AddControl("Checkbox", {
					Label = "Admin only",
					Command = "hitman_sight_admin_only"
				})
			end)   
		end
	end)
end

if (SERVER) then
	AddCSLuaFile("autorun/init.lua")
end