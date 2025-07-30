local tableout = false
local dirtylsd = false
local function createLabKit(coord, head)
    local labkit = CreateObject("v_ret_ml_tablea", coord.x, coord.y, coord.z - 1, true, false)
    SetEntityHeading(labkit, head)
    PlaceObjectOnGroundProperly(labkit)
    local options = {
        { event = "md-drugs:client:heatliquid",        icon = "fa-solid fa-temperature-high", label = locale("targets.lsd.heat"),   data = labkit, canInteract = function() if not dirtylsd then return true end end },
        { event = "md-drugs:client:refinequalityacid", icon = "fa-solid fa-temperature-high", label = locale("targets.lsd.refine"), data = labkit, canInteract = function() if not dirtylsd then return true end end },
        { event = "md-drugs:client:maketabpaper",      icon = "fa-regular fa-note-sticky",    label = locale("targets.lsd.dab"),    data = labkit, canInteract = function() if not dirtylsd then return true end end },
        { event = "md-drugs:client:getlabkitback",     icon = "fas fa-box-circle-check",      label = locale("targets.lsd.back"),   data = labkit, canInteract = function() if not dirtylsd then return true end end },
        {
            icon = "fa-solid fa-hand-sparkles",
            label = locale("targets.lsd.clean"),
            data = labkit,
            action = function()
                if not ItemCheck('cleaningkit') then return end
                if not progressbar(locale("lsd.clean"), 4000, 'clean') then return end
                local check = lib.callback.await('md-drugs:server:removecleaningkit')
                if check then
                    dirtylsd = false
                end
            end,
            canInteract = function() if dirtylsd then return true end end
        }
    }
    AddMultiModel(labkit, options, labkit)
end

RegisterNetEvent("md-drugs:client:getlysergic", function(data)
    if not minigame() then return end
    if not progressbar(locale("lsd.steallys"), 4000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:getlysergic", data.data)
end)


RegisterNetEvent("md-drugs:client:getdiethylamide", function(data)
    if not minigame() then return end
    if not progressbar(locale("lsd.stealdie"), 4000, 'uncuff') then return end
    TriggerServerEvent('md-drugs:server:getdiethylamide', data.data)
end)


lib.callback.register("md-drugs:client:setlsdlabkit", function()
    if tableout then
        Notify(locale("lsd.tableout"), 'error')
        return false
    else
        tableout = true
        local loc, head = StartRay()
        if not loc then
            tableout = false
            return
        end
        if not progressbar(locale("lsd.place"), 4000, 'uncuff') then return end
        createLabKit(loc, head)
        return true, loc
    end
end)

RegisterNetEvent("md-drugs:client:getlabkitback", function(data)
    if not progressbar(locale("lsd.tablepack"), 4000, 'uncuff') then return end
    DeleteObject(data.data)
    TriggerServerEvent('md-drugs:server:getlabkitback')
    tableout = false
end)

RegisterNetEvent("md-drugs:client:heatliquid", function(data)
    local PedCoords, head = GetEntityCoords(data.data), GetEntityHeading(data.data)
    local dict = "scr_ie_svm_technical2"
    if not ItemCheck('lysergic_acid') then return end
    if not ItemCheck('diethylamide') then return end
    if not minigame() then
        dirtylsd = true
        loadParticle(dict)
        local exitPtfx = StartParticleFxLoopedOnEntity("scr_dst_cocaine", data.data, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5,
            false, false, false)
        SetParticleFxLoopedAlpha(exitPtfx, 3.0)
        Wait(100)
        AddMultiModel(dirtylabkit,
            { { event = "md-drugs:client:cleanlabkit", icon = "fa-solid fa-hand-sparkles", label = locale("targets.lsd.clean"), data = dirtylabkit } },
            nil)
        return
    end
    if not progressbar(locale("lsd.heat"), 7000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:heatliquid")
end)


RegisterNetEvent("md-drugs:client:refinequalityacid", function()
    if not ItemCheck('lsd_one_vial') then return end
    if not minigame() then
        TriggerServerEvent("md-drugs:server:failrefinequality")
        return
    end
    if not progressbar(locale("lsd.refine"), 4000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:refinequalityacid")
end)

RegisterNetEvent("md-drugs:client:maketabpaper", function()
    if not ItemCheck('tab_paper') then return end
    if not minigame() then
        TriggerServerEvent("md-drugs:server:failtabs")
        return
    end
    if not progressbar(locale("lsd.dip"), 4000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:maketabpaper")
end)

RegisterNetEvent("md-drugs:client:buytabs", function(data)
    if not progressbar(locale("lsd.buypaper"), 4000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:gettabpaper", data.data)
end)

RegisterNetEvent("md-drugs:client:buylabkit", function()
    if hasItem('lsdlabkit') then
        Notify(locale("lsd.hav"), 'error')
        return
    end
    if not progressbar(locale("lsd.buykit"), 4000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:getlabkit")
end)
