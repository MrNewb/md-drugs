local amonia = nil
local tray = nil
local heated = nil
local active = nil

local function startcook()
	if not VerifyPlayerHasItem('empty_weed_bag') then return end
	if not VerifyPlayerHasItem('acetone') then return end
	if not VerifyPlayerHasItem('ephedrine') then return end
	if amonia ~= nil then return Notify(locale("meth.inside"), "error") end
	active = true
	TriggerServerEvent("md-drugs:server:startcook")
	MethCooking()
	amonia = true
end

local function dials()
	if amonia ~= true then return end
	if not ReturnMinigameSuccess() then
		AddExplosion(1005.773, -3200.402, -38.524, 49, 10, true, false, true)
		ClearPedTasks(PlayerPedId())
		amonia = nil
		active = nil
		return
	end
	Notify(locale("meth.increaseheat"), "success")
	ClearPedTasks(PlayerPedId())
	heated = true
end

local function smash()
	if not tray then return end
	tray = false
	DeleteObject(trays)
	local bucket = CreateObject("bkr_prop_meth_bigbag_03a", vector3(1012.85, -3194.29, -39.2), true, true, true)
	Freeze(bucket, true, 90.0)
	SmashMeth()
	Wait(100)
	AddSingleModel(bucket,
	{
		name = 'bucket',
		icon = "fa-solid fa-sack-xmark",
		label = locale("targets.meth.bag"),
		canInteract = function() if active == nil then return false end end,
		action = function()
			active = nil
			DeleteObject(bucket)
			amonia = nil
			heated = nil
			tray = nil
			BagMeth()
			TriggerServerEvent('md-drugs:server:getmeth')
		end,
	}, bucket)
end

local function trayscarry()
	if not amonia then return end
	local pos = GetEntityCoords(PlayerPedId(), true)
	RequestAnimDict('anim@heists@box_carry@')
	while (not HasAnimDictLoaded('anim@heists@box_carry@')) do
		Wait(7)
	end
	TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 5.0, -1, -1, 50, 0, false, false,
		false)
	RegisterModelRequest("bkr_prop_meth_tray_02a")
	trays = CreateObject("bkr_prop_meth_tray_02a", pos.x, pos.y, pos.z, true, true, true)
	AttachEntityToEntity(trays, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.01, -0.2,
		-0.2, 20.0, 0.0, 0.0, true, true, false, true, 1, true)
	tray = true
end


CreateThread(function()
	local config = lib.callback.await('md-drugs:server:getLocs', false)
	AddBoxZoneSingle("methTeleOut", config.singleSpot.MethTeleIn,
		{ name = 'teleout', icon = "fa-solid fa-door-open", label = locale("targets.meth.enter"), action = function()
			SetEntityCoords(PlayerPedId(), config.singleSpot.MethTeleOut) end })
	AddBoxZoneSingle("methtelein", config.singleSpot.MethTeleOut,
		{ name = 'teleout', icon = "fa-solid fa-door-closed", label = locale("targets.meth.exit"), action = function()
			SetEntityCoords(PlayerPedId(), config.singleSpot.MethTeleIn) end })
	local options = {
		{
			name = 'methcook',
			icon = "fa-solid fa-temperature-high",
			label = locale("targets.meth.cook"),
			distance = 2.5,
			action = function() startcook() end,
			canInteract = function()
				if amonia == nil and active == nil then
					return true
				end
			end,
		},
		{
			name = 'grabtray',
			icon = "fas fa-sign-in-alt",
			label = locale("targets.meth.tray"),
			distance = 2.5,
			action = function() trayscarry() end,
			canInteract = function()
				if heated and amonia and tray == nil then return true end
			end,
		},
	}
	AddBoxZoneMultiOptions("cookmeth", vector3(1005.72, -3200.33, -38.52), options)
	AddBoxZoneSingle('boxmeth', vector3(1012.15, -3194.04, -39.20),
		{
			name = 'boxmeth',
			icon = "fa-solid fa-weight-scale",
			label = locale("targets.meth.box"),
			action = function() smash() end,
			canInteract = function()
				if tray then return true end
			end
		})
	AddBoxZoneSingle('adjustdials', vector3(1007.89, -3201.17, -38.99),
		{
			name = 'adjustdials',
			icon = "fa-solid fa-temperature-three-quarters",
			label = locale("targets.meth.adjust"),
			distance = 5,
			action = function() dials() end,
			canInteract = function()
				if amonia and heated == nil then return true end
			end
		})
	if Config.MethHeist == false then
		AddBoxZoneMulti('methep', config.MethEph,
			{ icon = "fa-solid fa-bucket", label = locale("targets.meth.eph"), event = 'md-drugs:client:stealeph' })
		AddBoxZoneMulti('methace', config.Methace,
			{ icon = "fa-solid fa-bucket", label = locale("targets.meth.ace"), event = 'md-drugs:client:stealace' })
	end
end)

RegisterNetEvent("md-drugs:client:stealeph", function(data)
	if not BeginProgressBar('Stealing Ephedrine', 4000, 'uncuff') then return end
	TriggerServerEvent("md-drugs:server:geteph", data.data)
end)

RegisterNetEvent("md-drugs:client:stealace", function(data)
	if not BeginProgressBar('Stealing Acetone', 4000, 'uncuff') then return end
	TriggerServerEvent("md-drugs:server:getace", data.data)
end)
