Bridge = exports.community_bridge:Bridge()

function locale(message, ...)
    return Bridge.Language.Locale(message, ...)
end

function GetItemInfo(itemName)
    return Bridge.Inventory.GetItemInfo(itemName)
end

if IsDuplicityVersion() then
    function InitializeSQL()
        local result = MySQL.query.await('SHOW TABLES LIKE "deliveriesdealer"')
        if #result == 0 then
            MySQL.query.await('CREATE TABLE deliveriesdealer (id INT AUTO_INCREMENT PRIMARY KEY, cid VARCHAR(50), itemdata VARCHAR(50), timestart VARCHAR(50), timestop VARCHAR(50), maxtime VARCHAR(50), location VARCHAR(255))')
            print(tostring(GetCurrentResourceName()).." Setting Up The  deliveriesdealer SQL Tables For You. This only runs once and is here to make it easy for you.")
            Wait(1000)
        end
        local result2 = MySQL.query.await('SHOW TABLES LIKE "drugrep"')
        if #result2 == 0 then
            MySQL.query.await('CREATE TABLE drugrep (id INT AUTO_INCREMENT PRIMARY KEY, cid VARCHAR(50), drugrep VARCHAR(255), name VARCHAR(50))')
            print(tostring(GetCurrentResourceName()).." Setting Up The  drugrep SQL Tables For You. This only runs once and is here to make it easy for you.")
            Wait(1000)
        end
    end

    AddEventHandler('onResourceStart', function(resourceName)
        if resourceName ~= GetCurrentResourceName() then return end
        Bridge.Version.VersionChecker("Mustachedom/md-drugs", false)
        InitializeSQL()
    end)

    AddItem = Bridge.Inventory.AddItem

    RemoveItem = Bridge.Inventory.RemoveItem

    function ValidateItemCount(src, item, count)
        local itemCount = Bridge.Inventory.GetItemCount(src, item)
        return itemCount >= count
    end

    function Notify(src, text, type)
        return Bridge.Notify.SendNotify(src, text, type, 5000)
    end

    function RegisterUsableItems(item, useFunction)
        Bridge.Framework.RegisterUsableItem(item, function(src, itemData)
            local _src = src
            -- fuck
        end)
    end

    -- function RegisterUsableItems(item, useFunction)
    --     QBCore.Functions.CreateUseableItem(item, useFunction)
    -- end

    function GetPlayerFrameworkName(src)
        local first, last =  Bridge.Framework.GetPlayerName(src)
        return string.format('%s %s', first, last)
    end

    GetPlayerFrameworkIdentifier = Bridge.Framework.GetPlayerIdentifier

    SetPlayerFrameworkMetadata = Bridge.Framework.SetPlayerMetadata

    GetPlayerFrameworkMetadata = Bridge.Framework.GetPlayerMetadata

else
    -- Global Tables
    Mescaline = {}
    CocaPlant = {}
    PoppyPlants = {}
    Shrooms = {}
    WeedPlant = {}

    function LoadParticle(dict)
        local timeOut = 30000
        local count = 0
        if not HasNamedPtfxAssetLoaded(dict) then RequestNamedPtfxAsset(dict) end
        while not HasNamedPtfxAssetLoaded(dict) and count < timeOut do
            Wait(0)
            count = count + 1
        end
        SetPtfxAssetNextCall(dict)
    end

    --lib.requestModel
    CreatePropModel = Bridge.Utility.CreateProp

    CreaveVehicleModel = Bridge.Utility.CreateVehicle

    CreatePedModel = Bridge.Utility.CreatePed

    RegisterAnimDict = Bridge.Utility.RequestAnimDict

    RegisterModelRequest = Bridge.Utility.LoadModel

    GetPlayerJobData = Bridge.Framework.GetPlayerJobData

    VerifyPlayerHasItem = Bridge.Inventory.HasItem

    SendPlayerEmail = Bridge.Phone.SendEmail

    function Notify(text, type)
        return Bridge.Notify.SendNotify(text, type, 5000)
    end

    function ValidatePlayerJob(job)
        local playerJob = GetPlayerJobData()
        return playerJob and playerJob.jobName == job
    end

    function CheckForEmsType()
        local playerJob = GetPlayerJobData()
        for k, v in pairs(Config.EmsJobs) do
            if playerJob.jobName == v then
                return true
            end
        end
        return false
    end

    function VerifyPlayerHasMultipleItems(items)
        local _searchList = items or {}
        local neededCount = #_searchList
        local foundCount = 0
        for k, v in pairs(_searchList) do
            if VerifyPlayerHasItem(v) then
                foundCount = foundCount + 1
            end
        end
        return foundCount == neededCount
    end

    function SendDispatchEvent(alertChance)
        local roll = math.random(1, 100)
	    if roll >= alertChance then return end
        local ped = PlayerPedId()
        Bridge.Dispatch.SendAlert({
            message = locale('DispatchAlerts.DispatchMessage'),
            code = '10-80',
            icon = "fa-solid fa-car-crash",
            priority = 2,
            coords = GetEntityCoords(ped),
            vehicle = nil,
            plate = nil,
            time = 10000,
            blipData = {
                sprite = 38,
                color = 15,
                scale = 0.8
            },
            jobs = { 'police' },
        })
    end

    function BeginProgressBar(label, duration, animation)
        local success = Bridge.BeginProgressBar.Open({
            duration = duration,
            label = label,
            disable = { move = true, combat = true },
            anim = { dict = animation.dict, clip = animation.clip, },
            canCancel = true,
        })
        TriggerEvent('animations:client:EmoteCommandStart', { animation }) 
        return success
    end

    AddEventHandler('onResourceStop', function(resourceName)
        if GetCurrentResourceName() ~= resourceName then return end
        SetModelAsNoLongerNeeded(joaat('prop_cactus_03'))
        for k, v in pairs(Mescaline) do
            if DoesEntityExist(v) then
                SetEntityAsMissionEntity(v, true, true)
                DeleteEntity(v)
            end
        end
    end)

    AddEventHandler('onResourceStop', function(resourceName)
        if GetCurrentResourceName() ~= resourceName then return end
        SetModelAsNoLongerNeeded(joaat('prop_plant_01a'))
        for k, v in pairs(CocaPlant) do
            if DoesEntityExist(v) then
                SetEntityAsMissionEntity(v, true, true)
                DeleteEntity(v)
            end
        end
    end)

    AddEventHandler('onResourceStop', function(resourceName)
        if GetCurrentResourceName() ~= resourceName then return end
        SetModelAsNoLongerNeeded(joaat('prop_plant_01b'))
        for k, v in pairs(PoppyPlants) do
            if DoesEntityExist(v) then
                SetEntityAsMissionEntity(v, true, true)
                DeleteEntity(v)
            end
        end
    end)

    AddEventHandler('onResourceStop', function(resourceName)
        if GetCurrentResourceName() ~= resourceName then return end
        SetModelAsNoLongerNeeded(joaat('mushroom'))
        for k, v in pairs(Shrooms) do
            if DoesEntityExist(v) then
                SetEntityAsMissionEntity(v, true, true)
                DeleteEntity(v)
            end
        end
    end)


    AddEventHandler('onResourceStop', function(resourceName)
        if GetCurrentResourceName() ~= resourceName then return end
        SetModelAsNoLongerNeeded(joaat('bkr_prop_weed_lrg_01b'))
        for k, v in pairs(WeedPlant) do
            if DoesEntityExist(v) then
                SetEntityAsMissionEntity(v, true, true)
                DeleteEntity(v)
            end
        end
    end)

    CreateThread(function()
        SpawnDealer()
    end)

    CreateThread(function()
        for k, v in pairs(QBConfig.NoSellZones) do
            local box = lib.zones.box({
                coords = v.loc,
                size = vec3(v.width, v.length, v.height),
                rotation = 180.0,
                debug = false,
                onEnter = function()
                    inZone = true
                end,
                onExit = function()
                    inZone = false
                end
            })
        end
    end)

    CreateThread(function()
        local config = lib.callback.await('md-drugs:server:getLocs', false)
        if Config.FancyCokeAnims == false then
            AddBoxZoneMulti('cuttcoke', config.CuttingCoke,
                {
                    type = "client",
                    event = "md-drugs:client:cutcokeone",
                    icon = "fa-solid fa-mortar-pestle",
                    label = locale("targets.coke.cut")
                }
            )
            AddBoxZoneMulti('baggcoke', config.BaggingCoke,
                {
                    type = "client",
                    event = "md-drugs:client:bagcoke",
                    icon = "fa-solid fa-sack-xmark",
                    label = locale("targets.coke.bag")
                }
            )
        else
            AddBoxZoneSingle('cutcoke', config.singleSpot.cutcoke,
                {
                    data = config.singleSpot.cutcoke,
                    type = "client",
                    event = "md-drugs:client:cutcokeone",
                    icon = "fa-solid fa-mortar-pestle",
                    label = locale("targets.coke.cut"),
                    canInteract = function()
                        if cuttingcoke == nil and baggingcoke == nil then return true end
                    end
                }
            )
            AddBoxZoneSingle('bagcokepowder', config.singleSpot.bagcokepowder,
                {
                    data = config.singleSpot.bagcokepowder,
                    type = "client",
                    event = "md-drugs:client:bagcoke",
                    icon = "fa-solid fa-sack-xmark",
                    label = locale("targets.coke.bag"),
                    canInteract = function()
                        if baggingcoke == nil and cuttingcoke == nil then return true end
                    end
                }
            )
        end
    end)

    CreateThread(function()
        RegisterModelRequest('prop_plant_01b')
        RegisterModelRequest('prop_plant_01a')
        RegisterModelRequest('prop_cactus_03')
        RegisterModelRequest('prop_weed_01')
        TriggerEvent('weed:init')
        TriggerEvent('heroin:init')
        TriggerEvent('coke:init')
        TriggerEvent('Mescaline:init')
        TriggerEvent('Shrooms:init')
        TriggerEvent('weed:init')
    end)

    CreateThread(function()
        local config = lib.callback.await('md-drugs:server:getLocs', false)
        local num = lib.callback.await('md-drugs:server:GetMerchant', false)
        local model = {"g_m_y_famdnf_01", 's_m_m_doctor_01', 'u_m_m_jesus_01', "prop_cooker_03"}
        for k, v in pairs (model) do
            RegisterModelRequest(v)
        end
        local tabdealer = CreatePed(0, 'g_m_y_famdnf_01',config.singleSpot.buylsdlabkit.x,config.singleSpot.buylsdlabkit.y,config.singleSpot.buylsdlabkit.z-1,config.singleSpot.buylsdlabkit.w, false, false)
        local heroinkitdealer = CreatePed(0,"g_m_y_famdnf_01",config.singleSpot.buyheroinlabkit.x, config.singleSpot.buyheroinlabkit.y, config.singleSpot.buyheroinlabkit.z-1, config.singleSpot.buyheroinlabkit.w, false, false)
        local SyrupLocation = CreatePed(0, 's_m_m_doctor_01', config.singleSpot.SyrupVendor.x,config.singleSpot.SyrupVendor.y,config.singleSpot.SyrupVendor.z-1, config.singleSpot.SyrupVendor.w, false, false)
        local WeedGuy = CreatePed(0,'u_m_m_jesus_01',config.singleSpot.WeedSaleman.x,config.singleSpot.WeedSaleman.y,config.singleSpot.WeedSaleman.z-1, config.singleSpot.WeedSaleman.w, false, false)
        local methdealer = CreatePed(0, "g_m_y_famdnf_01", config.singleSpot.MethHeistStart.x, config.singleSpot.MethHeistStart.y, config.singleSpot.MethHeistStart.z - 1, false, false)
        local travellingmerchant = CreatePed(0, "g_m_y_famdnf_01",num.x,num.y,num.z-1, num.w, false, false)
        Freeze(tabdealer, true,config.singleSpot.buylsdlabkit.w)
        Freeze(SyrupLocation, true, config.singleSpot.SyrupVendor.w)
        Freeze(heroinkitdealer, true, config.singleSpot.buyheroinlabkit.w)
        Freeze(WeedGuy, true, config.singleSpot.WeedSaleman.w)
        Freeze(methdealer, true, 220.0)
        Freeze(travellingmerchant, true, num.w)
        AddSingleModel(tabdealer,{ type = "client", label = locale("targets.lsd.buy"), icon = "fa-solid fa-money-bill", event = "md-drugs:client:buylabkit", distance = 2.0}, tabdealer )
        AddSingleModel(heroinkitdealer, { label = locale("targets.heroin.kit"), icon = "fa-solid fa-money-bill", event = "md-drugs:client:buyheroinlabkit", distance = 2.0}, nil )
        AddSingleModel(SyrupLocation, { type = "client", label = locale("targets.lean.git"), icon = "fa-solid fa-circle-info", event = "md-drugs:client:getsyruplocationtobuy", distance = 2.0}, nil )
        AddSingleModel(WeedGuy, {label = locale("targets.weed.shop"),icon = "fa-solid fa-cannabis", action = function() makeMenu('WeedShop') lib.showContext('WeedShop')end}, nil)
        AddSingleModel(methdealer,{label = locale("targets.meth.mission"), icon = "fa-solid fa-circle-info", action = function() Notify(locale("meth.mission"), "success") SpawnMethCarPedChase() end,},nil )
        AddSingleModel(travellingmerchant, {label = locale("targets.travel.travel"), icon = "fa-solid fa-cart-shopping", action = function() makeMenu('travellingMerchant') lib.showContext('travellingMerchant') end}, nil)
    end)

    InitializeIpls()

end