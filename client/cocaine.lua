local cuttingcoke = nil
local baggingcoke = nil

local function pick(loc)
    if not BeginProgressBar(locale("Coke.picking"), 4000, 'uncuff') then return end
        TriggerServerEvent("coke:pickupCane", loc)  
    return true
end

RegisterNetEvent('coke:respawnCane', function(loc)
    local v = GlobalState.CocaPlant[loc]
    local hash = GetHashKey(v.model)
    if not CocaPlant[loc] then
        CocaPlant[loc] = CreateObject(hash, v.location, false, true, true)
        Freeze(CocaPlant[loc], true, v.heading)
        AddSingleModel(CocaPlant[loc],
        {
            icon = "fa-solid fa-seedling",
            label = locale("targets.coke.pick"),
            action = function()
                if not pick(loc) then return end
            end
        }, loc)
    end
end)

RegisterNetEvent('coke:removeCane', function(loc)
    if DoesEntityExist(CocaPlant[loc]) then DeleteEntity(CocaPlant[loc]) end
    CocaPlant[loc] = nil
end)

RegisterNetEvent("coke:init", function()
    for k, v in pairs (GlobalState.CocaPlant) do
        local hash = GetHashKey(v.model)
        RegisterModelRequest(hash)
        if not v.taken then
            CocaPlant[k] = CreateObject(hash, v.location.x, v.location.y, v.location.z, false, true, true)
            Freeze(CocaPlant[k], true, v.heading)
            AddSingleModel(CocaPlant[k], {icon = "fa-solid fa-seedling", label = locale("targets.coke.pick"), action = function() if not pick(k) then return end end}, k)
        end
    end
end)

RegisterNetEvent("md-drugs:client:makepowder", function(data)
    if not VerifyPlayerHasItem('coca_leaf') then return end
    if not BeginProgressBar(locale("Coke.makepow"), 4000, 'uncuff') then return end
	TriggerServerEvent("md-drugs:server:makepowder", data.data)
end)

RegisterNetEvent("md-drugs:client:cutcokeone", function(data)
    if not VerifyPlayerHasItem('bakingsoda') then return end
	cuttingcoke = true
    if Config.FancyCokeAnims then
	    CutCoke()
    else
         if not BeginProgressBar(locale("Coke.cutting"), 5000, 'uncuff') then cuttingcoke = nil return end
    end
	TriggerServerEvent("md-drugs:server:cutcokeone", data.data)
	cuttingcoke = nil
end)

RegisterNetEvent("md-drugs:client:bagcoke", function(data) 
    if not VerifyPlayerHasItem('empty_weed_bag') then return end
	baggingcoke = true
    if Config.FancyCokeAnims then
	    BagCoke()
    else
        if not BeginProgressBar(locale("Coke.bagging"), 5000, 'uncuff') then baggingcoke = nil return end
    end
	TriggerServerEvent("md-drugs:server:bagcoke", data.data)
	baggingcoke = nil
end)


