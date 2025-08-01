local sell = false
local sold = false
local targbusy = false
local inZone = false
local active = false

local function reset(targ)
    FreezeEntityPosition(targ, false)
    ClearPedTasks(targ)
    local coords = GetEntityCoords(targ)
    TaskWanderInArea(targ, coords.x, coords.y, coords.z, 100.0, 2, 10.0)
    Wait(10000)
    DeletePed(targ)
    targbusy = false
    sold = true
    active = false
end

local function walkAway(targ)
    FreezeEntityPosition(targ, false)
    ClearPedTasks(targ)
    local coords = GetEntityCoords(targ)
    TaskWanderInArea(targ, coords.x, coords.y, coords.z, 100.0, 2, 10.0)
    Wait(10000)
    DeletePed(targ)
    targbusy = false
    active = false
end

local function sellDrug(item, amount, price, targ)
    SendDispatchEvent(20)
    targbusy = true
    if IsPedInAnyVehicle(PlayerPedId(), true) then
        Notify(locale("Cornerselling.inveh"), 'error')
        reset(targ)
        return
    end
    if not BeginProgressBar(locale("Cornerselling.selling", GetItemInfo(item).label, price), 4000, 'uncuff') then return end
    TriggerServerEvent('md-drugs:server:sellCornerDrugs', item, amount, price)
    reset(targ)
end

local function deny(targ)
    SendDispatchEvent(20)
    targbusy = true
    if not BeginProgressBar(locale("Cornerselling.deny"), 4000, 'argue5') then return end
    reset(targ)
end

function Cornersell()
    if active then return false end
    local targ = lib.GetClosestPed(GetEntityCoords(PlayerPedId()), 8)
    if targ == nil then return end
    if IsPedInAnyVehicle(targ, false) or GetEntityHealth(targ) == 0 or not IsPedHuman(targ) then return end
    local data = lib.callback.await('md-drugs:server:cornerselling:getAvailableDrugs', false, targ)
    if data.item == 'nothing' then
        Notify(locale("Cornerselling.nodrugs"), 'error')
        sell = false
        FreezeEntityPosition(targ, false)
        ClearPedTasks(targ)
        active = false
        return false
    end
    TaskGoToCoordAnyMeans(targ, GetEntityCoords(PlayerPedId()), 1.0, 0, 0, 0, 0)
    active = true
    repeat
        Wait(1000)
    until #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(targ)) < 2.0
    RegisterAnimDict("rcmme_tracey1")
    TaskStartScenarioInPlace(targ, "WORLD_HUMAN_STAND_IMPATIENT_UPRIGHT", 0, false)
    FreezeEntityPosition(targ, true)
    AddMultiModel(data.ped, {
        {
            label = locale("targets.CornerSell.sell", data.amount, GetItemInfo(data.item).label, data.price),
            icon = "fa-solid fa-money-bill",
            action = function()
                sellDrug(data.item, data.amount, data.price, targ)
            end,
            canInteract = function()
                if not targbusy then return true end
            end,
        },
        {
            label = locale("targets.CornerSell.deny"),
            icon = "fa-solid fa-person-harassing",
            action = function() deny(targ) end,
            canInteract = function()
                if not targbusy then return true end
            end,
        }
    }, nil)
    local timer = 45
    repeat
        Wait(1000)
        timer = timer - 1
    until sold or timer == 0
    if sold then
        sold = false
        return true
    end
    if timer == 0 then
        Notify(locale("Cornerselling.timeout"), 'error')
        targbusy = true
        walkAway(targ)
        return false
    end
end

RegisterNetEvent('md-drugs:client:cornerselling', function()
    if not GetCops(QBConfig.MinimumDrugSalePolice) then return end
    if inZone then return Notify(locale("Cornerselling.no"), 'error') end
    local hasItem = lib.callback.await('md-drugs:server:hasDrugs', false)
    if not hasItem then return Notify(locale("Cornerselling.nodrugs"), 'error') end
    if sell then
        TriggerServerEvent('md-drugs:server:cornerselling:stop')
        Notify(locale("Cornerselling.stop"), 'error')
        sell = false
        active = false
    else
        sell = true
        Notify(locale("Cornerselling.start"), 'success')
        repeat
            Wait(1000)
            Cornersell()
        until not sell
    end
end)

RegisterNetEvent('md-drugs:client:cornerselling:remove', function(ped)
    DeletePed(ped)
end)