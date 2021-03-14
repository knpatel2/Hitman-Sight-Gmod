util.AddNetworkString("hitman_sight_clicked")
util.AddNetworkString("hitman_sight_unclicked")
util.AddNetworkString("hitman_sight_get_enabled")

local speed

local function timeScale(reverse, speed)
    if reverse == true then
        if game.GetTimeScale() == 1 or GetConVar("hitman_sight_slowmode_enabled"):GetInt() == 0 then
            return
        end

        for i = (game.GetTimeScale() * 10), 10 do
            timer.Simple(0.05, function() game.SetTimeScale(i / 10) end)
        end
    else
        if game.GetTimeScale() == speed or GetConVar("hitman_sight_slowmode_enabled"):GetInt() == 0 then
            return
        end

        for i = (game.GetTimeScale() * 10), speed * 10, -1 do
            timer.Simple(0.05, function() game.SetTimeScale(i / 10) end)
        end
    end
end

local function getNPCs(ply)
    local friends = {}
    local enemies = {}
    local players = {}
    
    for i, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent:IsNPC() then
            if ent:GetEnemy() ~= Entity( 1 ) then
                table.insert(friends, #friends + 1, ent)
            elseif ent:GetEnemy() == Entity( 1 ) then
                table.insert(enemies, #enemies + 1, ent)
            end
        elseif IsValid(ent) and ent:IsPlayer() then
            table.insert(players, #players + 1, ent)
        end
    end
    
    if #friends ~= 0 then
        util.AddNetworkString("hitman_sight_friends")
        net.Start("hitman_sight_friends")
        net.WriteTable(friends)
        net.Send(ply)
    end

    if #enemies ~= 0 then
        util.AddNetworkString("hitman_sight_enemies")
        net.Start("hitman_sight_enemies")
        net.WriteTable(enemies)
        net.Send(ply)
    end

    if #players ~= 0 then
        util.AddNetworkString("hitman_sight_players")
        net.Start("hitman_sight_players")
        net.WriteTable(players)
        net.Send(ply)
    end

end

net.Receive("hitman_sight_clicked", function(len, ply)
    ply:SetNWBool("clicked", true)

    speed = net.ReadFloat(4)
    timeScale(false, speed)
    getNPCs(ply)

    local debounce = false
    hook.Add("Tick", "hitman_sight_reload_nets", function()
        if debounce == false then
            debounce = true
            if ply:GetNWBool("clicked") == true then
                getNPCs(ply)            
            else
                hook.Remove("Tick", "hitman_sight_reload_nets")
            end

            timer.Simple( GetConVar("hitman_sight_update_hightlights"):GetFloat(), function()
                debounce = false
            end)
        end
    end)
end)

net.Receive("hitman_sight_unclicked", function(len, ply)
    ply:SetNWBool("clicked", false)
    timeScale(true)
end)

net.Receive("hitman_sight_get_enabled", function(len, ply)
    util.AddNetworkString("hitman_sight_recieve_enabled")
    net.Start("hitman_sight_recieve_enabled")
    net.WriteInt(GetConVar("hitman_sight_enabled"):GetInt(), 4)
    net.Send(ply)
end)

cvars.AddChangeCallback("hitman_sight_slowmode_enabled", function(hitman_sight_slowmode_enabled, value_old, value_new)
    local clicked
    for i, ent in ipairs(ents.GetAll()) do
        if ent:IsPlayer() then
            if ent:GetNWBool("clicked") == true then
                clicked = true
                break
            else
                clicked = false
            end
        end
    end

    if clicked == false then return end
    
    value_new = tonumber(value_new)

    if value_new == 0 then
        if game.GetTimeScale() ~= 1 then
            game.SetTimeScale(1)
        end
    elseif value_new == 1 then
        if game.GetTimeScale() == 1 then
            game.SetTimeScale(speed)
        end
    end
end)