local function pick(loc)
    if not BeginProgressBar(locale("Shrooms.pick"), 4000, 'uncuff') then return end
    TriggerServerEvent("Shrooms:pickupCane", loc)
end

RegisterNetEvent('Shrooms:respawnCane', function(loc)
    local v = GlobalState.Shrooms[loc]
    local hash = GetHashKey(v.model)
    if not Shrooms[loc] then
        Shrooms[loc] = CreateObject(hash, v.location, false, true, true)
        Freeze(Shrooms[loc], true, v.heading)
        AddSingleModel(Shrooms[loc],{ icon = "fas fa-hand", label = locale("targets.Shrooms.pick"), action = function() pick(loc) end }, loc )
    end
end)

RegisterNetEvent('Shrooms:removeCane', function(loc)
    if DoesEntityExist(Shrooms[loc]) then DeleteEntity(Shrooms[loc]) end
    Shrooms[loc] = nil
end)

RegisterNetEvent("Shrooms:init", function()
    for k, v in pairs (GlobalState.Shrooms) do
        local hash = GetHashKey(v.model)
        if not HasModelLoaded(hash) then RegisterModelRequest(hash) end
        if not v.taken then
            Shrooms[k] = CreateObject(hash, v.location.x, v.location.y, v.location.z, false, true, true)
            Freeze(Shrooms[k], true, v.heading)
            AddSingleModel(Shrooms[k],{ icon = "fas fa-hand", label = locale("targets.Shrooms.pick"), action = function() pick(k) end }, k )
        end
    end
end)

RegisterNetEvent('md-drugs:client:takeShrooms', function()
    if not BeginProgressBar(locale("Shrooms.eat"), 500, 'eat')  then return end
    TriggerEvent("evidence:client:SetStatus", "widepupils", 300)
    EcstasyEffect()
end)
