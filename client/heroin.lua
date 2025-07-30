local PoppyPlants = {}
local herointable = false
local dirty = false

local function createLabKit(coord, head)
    local heroinlabkit = CreateObject("v_ret_ml_tablea", coord.x, coord.y, coord.z - 1, true, false, false)
    SetEntityHeading(heroinlabkit, head)
    PlaceObjectOnGroundProperly(heroinlabkit)
    AddMultiModel(heroinlabkit, {
        { data = heroinlabkit, event = "md-drugs:client:heatliquidheroin",  icon = "fa-solid fa-temperature-high", label = locale("targets.heroin.cook"),  canInteract = function() if not dirty then return true end end },
        { data = heroinlabkit, event = "md-drugs:client:getheroinkitback",  icon = "fas fa-box-circle-check",      label = locale("targets.heroin.up"),    canInteract = function() if not dirty then return true end end },
        { data = heroinlabkit, event = "md-drugs:client:cleanheroinlabkit", icon = "fa-solid fa-hand-sparkles",    label = locale("targets.heroin.clean"), canInteract = function() if dirty then return true end end } },
        heroinlabkit)
end

local function pickher(loc)
    if not BeginProgressBar(locale("Heroin.pick"), 4000, 'uncuff') then return end
    TriggerServerEvent("heroin:pickupCane", loc)
end

RegisterNetEvent('heroin:respawnCane', function(loc)
    local v = GlobalState.PoppyPlants[loc]
    local hash = GetHashKey(v.model)
    if not PoppyPlants[loc] then
        PoppyPlants[loc] = CreateObject(hash, v.location, false, true, true)
        Freeze(PoppyPlants[loc], true, v.heading)
        AddSingleModel(PoppyPlants[loc],
            { icon = "fa-solid fa-seedling", label = locale("targets.heroin.pick"), action = function() pickher(loc) end },
            loc)
    end
end)

RegisterNetEvent('heroin:removeCane', function(loc)
    if DoesEntityExist(PoppyPlants[loc]) then DeleteEntity(PoppyPlants[loc]) end
    PoppyPlants[loc] = nil
end)

RegisterNetEvent("heroin:init", function()
    for k, v in pairs(GlobalState.PoppyPlants) do
        local hash = GetHashKey(v.model)
        if not HasModelLoaded(hash) then RegisterModelRequest(hash) end
        if not v.taken then
            PoppyPlants[k] = CreateObject(hash, v.location.x, v.location.y, v.location.z, false, true, true)
            Freeze(PoppyPlants[k], true, v.heading)
            AddSingleModel(PoppyPlants[k],
                { icon = "fa-solid fa-seedling", label = locale("targets.heroin.pick"), action = function() pickher(k) end },
                k)
        end
    end
end)

RegisterNetEvent("md-drugs:client:dryplant", function(data)
    if not BeginProgressBar(locale("Heroin.dryout"), 4000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:dryplant", data.data)
end)

RegisterNetEvent("md-drugs:client:cutheroin", function(data)
    if not VerifyPlayerHasItem('bakingsoda') then return end
    if not BeginProgressBar(locale("Heroin.cutting"), 4000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:cutheroin", data.data)
end)

RegisterNetEvent("md-drugs:client:buyheroinlabkit", function()
    if not BeginProgressBar(locale("Heroin.secret"), 4000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:getheroinlabkit")
end)

lib.callback.register("md-drugs:client:setheroinlabkit", function()
    if herointable then return false, Notify(locale("Heroin.tableout"), 'error') end
    herointable = true
    local location, head = StartRay()
    if not location then
        herointable = false
        return
    end
    if not BeginProgressBar(locale("Heroin.table"), 4000, 'uncuff') then return end
    createLabKit(location, head)
    return true, location
end)

RegisterNetEvent("md-drugs:client:heatliquidheroin", function(data)
    local loc, head = GetEntityCoords(data.data), GetEntityHeading(data.data)
    if not VerifyPlayerHasItem('emptyvial') then return end
    if not ReturnMinigameSuccess() then
        dirty = true
        TriggerServerEvent("md-drugs:server:failheatingheroin")
        LoadParticle("core")
        local heroinkit = StartParticleFxLoopedOnEntity("exp_air_molotov", data.data, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5,
            false, false, false)
        SetParticleFxLoopedAlpha(heroinkit, 3.0)
        SetPedToRagdoll(PlayerPedId(), 1300, 1300, 0, 0, 0, 0)
        return
    end
    if not BeginProgressBar(locale("Heroin.success"), 4000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:heatliquidheroin")
end)

RegisterNetEvent("md-drugs:client:cleanheroinlabkit", function(data)
    if not VerifyPlayerHasItem('cleaningkit') then return end
    if not BeginProgressBar(locale("Heroin.clean"), 4000, 'clean') then return end
    local done = lib.callback.await('removeCleaningkit', false)
    if done then dirty = false end
end)

RegisterNetEvent("md-drugs:client:deletedirtyheroin", function(data)
    local location, head = GetEntityCoords(data), GetEntityHeading(data)
    DeleteObject(data)
    createLabKit(location, head)
end)

RegisterNetEvent("md-drugs:client:getheroinkitback", function(data)
    if not BeginProgressBar(locale("Heroin.pickup"), 4000, 'uncuff') then return end
    herointable = false
    DeleteObject(data.data)
    TriggerServerEvent("md-drugs:server:getheroinlabkitback")
end)

RegisterNetEvent("md-drugs:client:fillneedle", function(data)
    if not ReturnMinigameSuccess() then
        TriggerServerEvent("md-drugs:server:failheroin", data.data)
        return
    end
    if not BeginProgressBar(locale("Heroin.needles"), 4000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:fillneedle", data.data)
end)
