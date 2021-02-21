util.AddNetworkString("hitman_sight_clicked")
util.AddNetworkString("hitman_sight_unclicked")
util.AddNetworkString("hitman_sight_get_enabled")

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
    local speed = net.ReadFloat(4)
    timeScale(false, speed)
    getNPCs(ply)
end)

net.Receive("hitman_sight_unclicked", function(len, ply)
    timeScale(true)
end)

net.Receive("hitman_sight_get_enabled", function(len, ply)
    print("server")
    util.AddNetworkString("hitman_sight_recieve_enabled")
    net.Start("hitman_sight_recieve_enabled")
    net.WriteInt(GetConVar("hitman_sight_enabled"):GetInt(), 4)
    net.Send(ply)
    print(GetConVar("hitman_sight_enabled"):GetInt())
end)