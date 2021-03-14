local hitman_sight_bindkey = CreateClientConVar("hitman_sight_bindkey", tostring(KEY_LCONTROL), true, false, "Hitman sight key. Recommended to change in Options > Hitman Sight.")
--local hitman_sight_slowmode_enabled = CreateClientConVar("hitman_sight_slowmode_enabled", 1, true, false, "Hitman sight slowmode enabled toggle. Recommended to change in Options > Hitman Sight.")
local hitman_sight_slowmode_intensity = CreateClientConVar("hitman_sight_slowmode_intensity", 0.3, true, false, "Hitman sight slowmode intensity amount. Recommended to change in Options > Hitman Sight.")
local hitman_sight_toggle = CreateClientConVar("hitman_sight_toggle", 0, true, false, "Hitman sight toggle options. Recommended to change in Options > Hitman Sight.")
local hitman_sight_gray_screen = CreateClientConVar("hitman_sight_gray_screen", 1, true, false, "Hitman sight gray screen toggle. Recommended to change in Options > Hitman Sight.")

local debounce = false
local pressed = 0
local key = 0

local settings = {
    [ "$pp_colour_addr" ] = 0,
    [ "$pp_colour_addg" ] = 0,
    [ "$pp_colour_addb" ] = 0,
    [ "$pp_colour_brightness" ] = -0.01,
    [ "$pp_colour_contrast" ] = 1,
    [ "$pp_colour_colour" ] = 0,
    [ "$pp_colour_mulr" ] = 0,
    [ "$pp_colour_mulg" ] = 0,
    [ "$pp_colour_mulb" ] = 0
}

local function checkHook(hooks, name)
    if hook.GetTable()[hooks][name] == nil then
        return false
    else
        return true
    end
end

local function addRenders(enemies)
    hook.Add("PreDrawEffects", "hitman_sight_fill", function()
    
        local EyeAngles = EyeAngles()
        EyeAngles = Angle(EyeAngles.p + 90, EyeAngles.y, 0)
        
        cam.Start3D2D(EyePos() + EyeAngles():Forward() * 10, EyeAngles, 1 )
        render.SetBlend(0)
        render.ClearStencil()
        render.SetStencilEnable(true)
        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.SetStencilReferenceValue(15)
        render.SetStencilFailOperation(STENCILOPERATION_KEEP)
        render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
        render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
        
        surface.SetDrawColor(100, 25, 25, 100)
        local w,h = ScrW(), ScrH()
        for k, v in ipairs(enemies) do
            render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
    
  
            local prevNoDraw = v:GetNoDraw()
            v:SetNoDraw(false)
            local prevRenderMode = v:GetRenderMode()
            v:SetRenderMode(RENDERMODE_WORLDGLOW)
            v:DrawModel()
            --v:SetRenderMode(prevRenderMode)
            v:SetNoDraw(prevNoDraw)
                
            render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
               
            surface.DrawRect(-w,-h,w*2,h*2)
        end
        render.SetStencilEnable(false)
        render.SetBlend(1)
        cam.End3D2D()
    
    end)
    
    
    --hook.Remove("PreDrawEffects","IG_DrawSoulVision-testy")
    --hook.Remove("PreDrawHalos", "EnemyHalosHMAN")
    
        
end

local white = Color(255, 255, 255)
net.Receive("hitman_sight_friends", function()
    local friends = net.ReadTable()
    
    if checkHook("PreDrawHalos", "EnemyHalos") == true then
        hook.Remove("PreDrawHalos", "EnemyHalos")
    end

    if checkHook("PreDrawHalos", "FriendsHalos") == true then
        hook.Remove("PreDrawHalos", "FriendsHalos")
    end

    hook.Add("PreDrawHalos", "FriendsHalos", function()
        halo.Add(friends, white, 0, 1, 3, 1, 1, false, true)
    end)
end)

local red = Color(255, 0, 0)
net.Receive("hitman_sight_enemies", function()
    local enemies = net.ReadTable()
    
    if checkHook("PreDrawHalos", "FriendsHalos") == true then
        hook.Remove("PreDrawHalos", "FriendsHalos")
    end

    if checkHook("PreDrawHalos", "EnemyHalos") == true then
        hook.Remove("PreDrawHalos", "EnemyHalos")
    end

    hook.Add("PreDrawHalos", "EnemyHalos", function()
        halo.Add(enemies, red, 0, 1, 3, 1, 1, false, true)
    end)
end)

local blue = Color(30, 84, 247)
net.Receive("hitman_sight_players", function()
    local players = net.ReadTable()
    
    if checkHook("PreDrawHalos", "hitman_sight_players") == true then
        hook.Remove("PreDrawHalos", "hitman_sight_players")
    end

    hook.Add("PreDrawHalos", "PlayersHalos", function()
        halo.Add(players, blue, 0, 1, 3, 1, 1, false, true)
    end)
end)

local function onCtrlDown()    
    if debounce == false then
        debounce = true
        if GetConVar("hitman_sight_enabled"):GetInt() == 0 then return end

        if hitman_sight_gray_screen:GetInt() == 1 then
            hook.Add("RenderScreenspaceEffects", "hitman_sight_gray_screen", function()
                DrawColorModify(settings)
            end)
        end
        
        net.Start("hitman_sight_clicked")
        net.WriteFloat(hitman_sight_slowmode_intensity:GetFloat(), 4)
        net.SendToServer()
    end
end

local function onCtrlUp()
    if checkHook("RenderScreenspaceEffects", "hitman_sight_gray_screen") == true then
        hook.Remove("RenderScreenspaceEffects", "hitman_sight_gray_screen")
    end
    
    net.Start("hitman_sight_unclicked")
    net.WriteUInt(1, 4)
    net.SendToServer()
    
    hook.Remove("PreDrawHalos", "EnemyHalos")
    hook.Remove("PreDrawHalos", "FriendsHalos")
    hook.Remove("PreDrawHalos", "PlayersHalos")
    
    debounce = false
end

local clicked = false
local function toggle()
    if pressed == 0 then
        clicked = true
        pressed = 1
        if GetConVar("hitman_sight_enabled"):GetInt() == 0 then return end

        if hitman_sight_gray_screen:GetInt() == 1 then
            hook.Add("RenderScreenspaceEffects", "hitman_sight_gray_screen", function()
                DrawColorModify(settings)
            end)
        end
        
        net.Start("hitman_sight_clicked")
        net.WriteFloat(hitman_sight_slowmode_intensity:GetFloat(), 4)
        net.SendToServer()
    elseif pressed == 1 then
        clicked = false
        onCtrlUp()
        pressed = 0
    end
end

hook.Add("Tick", "CheckForCtrl", function()
    if input.IsKeyDown(hitman_sight_bindkey:GetInt()) == true then
        
        if hitman_sight_toggle:GetInt() == 0 then
            clicked = true
            onCtrlDown()
        else
            if key ~= 1 then
                key = 1
                toggle()
            end
        end
    elseif input.IsKeyDown(hitman_sight_bindkey:GetInt()) == false then
        key = 0
        if hitman_sight_toggle:GetInt() == 0 and debounce == true then
            clicked = false
            onCtrlUp()
        end        
    end
end)

cvars.AddChangeCallback("hitman_sight_gray_screen", function(hitman_sight_gray_screen, value_old, value_new)
    if clicked == false then return end
    
    value_new = tonumber(value_new)

    if value_new == 0 then
        if checkHook("RenderScreenspaceEffects", "hitman_sight_gray_screen") == true then
            hook.Remove("RenderScreenspaceEffects", "hitman_sight_gray_screen")
        end
    elseif value_new == 1 then
        if checkHook("RenderScreenspaceEffects", "hitman_sight_gray_screen") == false then
            hook.Add("RenderScreenspaceEffects", "hitman_sight_gray_screen", function()
                DrawColorModify(settings)
            end)
        end
    end
end)

net.Start("hitman_sight_clicked")
net.WriteUInt( 1, 4 )
net.SendToServer()

net.Start("hitman_sight_unclicked")
net.WriteUInt( 1, 4 )
net.SendToServer()