local WeedPlant = {}
local exploded, drying = false, false

local function pick(loc)
	if not BeginProgressBar(locale("Weed.pick"), 4000, 'uncuff') then return end
	TriggerServerEvent("weed:pickupCane", loc)
end

RegisterNetEvent('weed:respawnCane', function(loc)
	local v = GlobalState.WeedPlant[loc]
	local hash = GetHashKey(v.model)
	if not HasModelLoaded(hash) then RegisterModelRequest(hash) end
	if not WeedPlant[loc] then
		WeedPlant[loc] = CreateObject(hash, v.location.x, v.location.y, v.location.z - 3.5, false, true, true)
		Freeze(WeedPlant[loc], true, v.heading)
		AddSingleModel(WeedPlant[loc],
			{ icon = "fas fa-hand", label = locale("targets.weed.pick"), action = function() pick(loc) end }, loc)
	end
end)

RegisterNetEvent('weed:removeCane', function(loc)
	if DoesEntityExist(WeedPlant[loc]) then DeleteEntity(WeedPlant[loc]) end
	WeedPlant[loc] = nil
end)

RegisterNetEvent("weed:init", function()
	for k, v in pairs(GlobalState.WeedPlant) do
		local hash = GetHashKey(v.model)
		RegisterModelRequest('prop_weed_01')
		if not v.taken then
			WeedPlant[k] = CreateObject(hash, v.location.x, v.location.y, v.location.z - 3.5, false, true, true)
			Freeze(WeedPlant[k], true, v.heading)
			AddSingleModel(WeedPlant[k],
				{ icon = "fas fa-hand", label = locale("targets.weed.pick"), action = function() pick(k) end }, k)
		end
	end
end)

CreateThread(function()
	local config = lib.callback.await('md-drugs:server:getLocs', false)
	AddBoxZoneMulti('weeddry', config.WeedDry, {
		name = 'dryweed',
		icon = "fas fa-sign-in-alt",
		label = locale("targets.weed.dry"),
		distance = 1,
		action = function()
			if not VerifyPlayerHasItem('wetcannabis') then return end
			if drying then
				Notify(locale("Weed.busy"), "error")
			else
				local loc = GetEntityCoords(PlayerPedId())
				local weedplant = CreateObject("bkr_prop_weed_drying_01a", loc.x, loc.y + .2, loc.z, true, false)
				drying = true
				FreezeEntityPosition(weedplant, true)
				Notify(locale("Weed.wait"), "success")
				Wait(math.random(1000, 5000))
				Notify(locale("Weed.take"), "success")
				AddSingleModel(weedplant, {
					icon = "fa-solid fa-cannabis",
					label = locale("targets.weed.dpick"),
					action = function()
						DeleteEntity(weedplant)
						drying = false
						TriggerServerEvent('md-drugs:server:dryoutweed')
					end,
					canInteract = function()
						if ValidatePlayerJob(Config.weedjob) then return true end
					end
				}, nil)
			end
		end,
		canInteract = function()
			if ValidatePlayerJob(Config.weedjob) then return true end
		end
	})

	AddBoxZoneSingle('teleinweedout', config.singleSpot.weedTeleout,
		{
			name = 'teleout',
			icon = "fa-solid fa-door-closed",
			label = locale("targets.coke.exit"),
			distance = 2.0,
			action = function() SetEntityCoords(PlayerPedId(), config.singleSpot.weedTelein) end,
			canInteract = function() if ValidatePlayerJob(Config.weedjob) then return true end end
		})
	AddBoxZoneSingle('teleinweedin', config.singleSpot.weedTelein,
		{
			name = 'teleout',
			icon = "fa-solid fa-door-open",
			label = locale("targets.coke.enter"),
			distance = 2.0,
			action = function() SetEntityCoords(PlayerPedId(), config.singleSpot.weedTeleout) end,
			canInteract = function() if ValidatePlayerJob(Config.weedjob) then return true end end
		})
	AddBoxZoneSingle('MakeButterCrafting', config.singleSpot.MakeButter,
		{
			label = locale("targets.weed.butt"),
			action = function() lib.showContext('ButterCraft') end,
			icon = "fa-solid fa-cookie",
			canInteract = function() if ValidatePlayerJob(Config.weedjob) then return true end end
		})

	AddBoxZoneSingle('makeoil', config.singleSpot.MakeOil, {
		name = 'Oil',
		icon = "fa-solid fa-oil-can",
		label = locale("targets.weed.oil"),
		action = function()
			if not VerifyPlayerHasMultipleItems({ 'butane', 'grindedweed' }) then return end
			if not ReturnMinigameSuccess() then
				local loc = GetEntityCoords(PlayerPedId())
				AddExplosion(loc.x, loc.y, loc.z, 49, 10, true, false, true)
				exploded = true
				Notify(locale("Weed.stovehot"), "error")
				Wait(1000 * 30)
				exploded = false
				return
			end
			if not BeginProgressBar(locale("Weed.shat"), 4000, 'uncuff') then return end
			TriggerServerEvent("md-drugs:server:makeoil")
		end,
		canInteract = function()
			if ValidatePlayerJob(Config.weedjob) and exploded == false then return true end
		end,
	})
	local stove = CreateObject("prop_cooker_03", config.singleSpot.MakeButter.x, config.singleSpot.MakeButter.y,
		config.singleSpot.MakeButter.z - 1, true, false)
	SetEntityHeading(stove, 270.00)
	FreezeEntityPosition(stove, true)
	local stove2 = CreateObject("prop_cooker_03", config.singleSpot.MakeOil.x, config.singleSpot.MakeOil.y,
		config.singleSpot.MakeOil.z - 1, true, false)
	SetEntityHeading(stove2, 90.00)
	FreezeEntityPosition(stove2, true)
end)



RegisterNetEvent("md-drugs:client:dodabs", function()
	if not BeginProgressBar('Doing Dabs', 4000, 'bong2') then
		AlienEffect()
		return
	end
	AlienEffect()
end)

local function createBluntOptions(contextId, contextTitle, eventLabelPrefix, tableName)
	local options = {}
	local items = lib.callback.await('md-drugs:server:GetRecipe', false, 'weed', tableName)
	for k, v in pairs(items) do
		local label = {}
		local item = ''
		for m, d in pairs(v.take) do table.insert(label, GetItemInfo(m).label .. ' X ' .. d) end
		for m, d in pairs(v.give) do item = m end
		options[#options + 1] = {
			icon = GetItemInfo(item).image or "fa-solid fa-question",
			description = table.concat(label, ", "),
			title = GetItemInfo(item).label,
			event = "md-drugs:client:MakeWeedItems",
			args = {
				item = item,
				recipe = 'weed',
				num = k,
				label = eventLabelPrefix .. GetItemInfo(item).label,
				table = tableName
			}
		}
	end
	sorter(options, 'title')
	lib.registerContext({ id = contextId, title = contextTitle, options = options })
end

CreateThread(function()
	createBluntOptions('ButterCraft', "Edible Cooking", 'Cooking A ', 'edibles')
	createBluntOptions('mddrugsblunts', "Roll Blunts", 'Rolling A ', 'blunts')
	createBluntOptions('mddrugsbluntwraps', "Dipping Syrup", 'Dipping Syrup To Make ', 'bluntwrap')
end)

RegisterNetEvent("md-drugs:client:MakeWeedItems", function(data)
	if not ReturnMinigameSuccess() then return end
	if not BeginProgressBar('Making ' .. data.item, 4000, 'uncuff') then return end
	TriggerServerEvent('md-drugs:server:MakeWeedItems', data)
end)

RegisterNetEvent('md-drugs:client:makeBluntWrap', function(data)
	lib.showContext('mddrugsbluntwraps')
end)

RegisterNetEvent('md-drugs:client:rollBlunt', function(data)
	lib.showContext('mddrugsblunts')
end)