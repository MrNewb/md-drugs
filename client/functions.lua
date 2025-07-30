local QBCore = exports['qb-core']:GetCoreObject()

local ReturnMinigameSuccesstype = Config.ReturnMinigameSuccesstype
function ReturnMinigameSuccess()
	local time = 0
	local game = Config.ReturnMinigameSuccesss
	if ReturnMinigameSuccesstype == 'ps_circle' then
		local check
		exports['ps-ui']:Circle(function(success)
			check = success
		end, game['ps_circle'].amount, game['ps_circle'].speed)
		return check
	elseif ReturnMinigameSuccesstype == 'ps_maze' then
		local check
		exports['ps-ui']:Maze(function(success)
			check = success
		end, game['ps_maze'].timelimit)
		repeat Wait(10) until check ~= nil
		return check
	elseif ReturnMinigameSuccesstype == 'ps_scrambler' then
		local check
		exports['ps-ui']:Scrambler(function(success)
			check = success
		end, game['ps_scrambler'].type, game['ps_scrambler'].time, game['ps_scrambler'].mirrored)
		repeat Wait(10) until check ~= nil
		return check
	elseif ReturnMinigameSuccesstype == 'ps_var' then
		local check
		exports['ps-ui']:VarHack(function(success)
			check = success
		end, game['ps_var'].numBlocks, game['ps_var'].time)
		repeat Wait(10) until check ~= nil
		return check
	elseif ReturnMinigameSuccesstype == 'ps_thermite' then
		local check
		exports['ps-ui']:Thermite(function(success)
			check = success
		end, game['ps_thermite'].time, game['ps_thermite'].gridsize, game['ps_thermite'].incorrect)
		repeat Wait(10) until check ~= nil
		return check
	elseif ReturnMinigameSuccesstype == 'ox' then
		local success = lib.skillCheck(game['ox'], { '1', '2', '3', '4' })
		return success
	elseif ReturnMinigameSuccesstype == 'blcirprog' then
		local success = exports.bl_ui:CircleProgress(game['blcirprog'].amount, game['blcirprog'].speed)
		return success
	elseif ReturnMinigameSuccesstype == 'blprog' then
		local success = exports.bl_ui:Progress(game['blprog'].amount, game['blprog'].speed)
		return success
	elseif ReturnMinigameSuccesstype == 'blkeyspam' then
		local success = exports.bl_ui:KeySpam(game['blkeyspam'].amount, game['blprog'].difficulty)
		return success
	elseif ReturnMinigameSuccesstype == 'blkeycircle' then
		local success = exports.bl_ui:KeyCircle(game['blkeycircle'].amount, game['blkeycircle'].difficulty,
			game['blkeycircle'].keynumbers)
		return success
	elseif ReturnMinigameSuccesstype == 'blnumberslide' then
		local success = exports.bl_ui:NumberSlide(game['blnumberslide'].amount, game['blnumberslide'].difficulty,
			game['blnumberslide'].keynumbers)
		return success
	elseif ReturnMinigameSuccesstype == 'blrapidlines' then
		local success = exports.bl_ui:RapidLines(game['blrapidlines'].amount, game['blrapidlines'].difficulty,
			game['blrapidlines'].numberofline)
		return success
	elseif ReturnMinigameSuccesstype == 'blcircleshake' then
		local success = exports.bl_ui:CircleShake(game['blcircleshake'].amount, game['blcircleshake'].difficulty,
			game['blcircleshake'].stages)
		return success
	elseif ReturnMinigameSuccesstype == 'glpath' then
		local settings = { gridSize = game['glpath'].gridSize, lives = game['glpath'].lives, timeLimit = game['glpath']
		.timelimit }
		local successes = false
		exports["glow_ReturnMinigameSuccesss"]:StartReturnMinigameSuccess(function(success)
			if success then successes = true else successes = false end
		end, "path", settings)
		repeat
			Wait(1000)
			time = time + 1
		until successes or time == 100
		if successes then return true end
	elseif ReturnMinigameSuccesstype == 'glspot' then
		local settings = { gridSize = game['glspot'].gridSize, timeLimit = game['glspot'].gridSize, charSet = game
		['glspot'].charSet, required = game['glspot'].required }
		local successes = false
		exports["glow_ReturnMinigameSuccesss"]:StartReturnMinigameSuccess(function(success)
			if success then successes = true else successes = false end
		end, "spot", settings)
		repeat
			Wait(1000)
			time = time + 1
		until successes or time == 100
	elseif ReturnMinigameSuccesstype == 'glmath' then
		local settings = { timeLimit = game['glmath'].timeLimit }
		local successes = false
		exports["glow_ReturnMinigameSuccesss"]:StartReturnMinigameSuccess(function(success)
			if success then successes = true else successes = false end
		end, "math", settings)
		repeat
			Wait(1000)
			time = time + 1
		until successes or time == 100
	elseif ReturnMinigameSuccesstype == 'none' then
		return true
	else
		print "^1 SCRIPT ERROR: Md-Drugs set your ReturnMinigameSuccess with one of the options!"
	end
end

function GetRep()
	local rep = lib.callback.await('md-drugs:server:GetRep', false)
	return rep
end

function sorter(sorting, value)
	table.sort(sorting, function(a, b) return a[value] < b[value] end)
end

function makeMenu(name, rep)
	local menu = {}
	local data = lib.callback.await('md-drugs:server:menu', false, name)
	for k, v in pairs(data.table) do
		local allow = false
		if rep == nil then
			allow = true
		else
			if rep.dealerrep >= v.minrep then allow = true end
		end
		if allow then
			menu[#menu + 1] = {
				icon = GetItemInfo(v.name).image or "fa-solid fa-question",
				description = '$' .. v.price,
				title = GetItemInfo(v.name).label,
				onSelect = function()
					local settext = "Cost: $" .. v.price
					local dialog = exports.ox_lib:inputDialog(v.name .. "!", {
						{ type = 'select', label = "Payment Type",  default = "cash",      options = { { value = "cash" }, { value = "bank" }, } },
						{ type = 'number', label = "Amount to buy", description = settext, min = 0,                                           max = v.amount, default = 1 },
					})
					if not dialog[1] then return end
					TriggerServerEvent("md-drugs:server:purchaseGoods", dialog[2], dialog[1], v.name, v.price, data
					.table, k)
				end,
			}
		end
	end
	sorter(menu, 'title')
	lib.registerContext({ id = data.id, title = data.title, options = menu })
end

function GetCops(number)
	if number == 0 then return true end
	local amount = lib.callback.await('md-drugs:server:GetCoppers', false)
	if amount >= number then return true else Notify('You Need ' .. number - amount .. ' More Cops To Do This', 'error') end
end

function Freeze(entity, toggle, head)
	SetEntityInvincible(entity, toggle)
	SetEntityAsMissionEntity(entity, true, true)
	FreezeEntityPosition(entity, toggle)
	SetEntityHeading(entity, head)
	SetBlockingOfNonTemporaryEvents(entity, toggle)
end

function tele(coords)
	DoScreenFadeOut(500)
	Wait(1000)
	SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
	Wait(1000)
	DoScreenFadeIn(500)
end

function AddBoxZoneSingle(name, loc, data)
	if Config.Target == 'qb' then
		exports['qb-target']:AddBoxZone(name, loc, 1.5, 1.75, { name = name, minZ = loc.z - 1, maxZ = loc.z + 1 },
			{
				options = {
					{
						type = data.type or nil,
						event = data.event or nil,
						action = data.action or nil,
						icon = data.icon or "fa-solid fa-eye",
						label = data.label,
						data = data.data,
						canInteract = data.canInteract,
					}
				},
				distance = 2.0
			})
	elseif Config.Target == 'ox' then
		exports.ox_target:addBoxZone({
			coords = loc,
			size = vec3(1, 1, 1),
			options = {
				{
					type = data.type or nil,
					event = data.event or nil,
					onSelect = data.action or nil,
					distance = 2.5,
					icon = data.icon or "fa-solid fa-eye",
					label = data.label,
					data = data.data,
					canInteract = data.canInteract,
				}
			},
		})
	elseif Config.Target == 'interact' then
		exports.interact:AddInteraction({
			coords = vector3(loc.x, loc.y, loc.z),
			distance = 2.5,
			interactDst = 2,
			id = name,
			options = {
				{
					type = data.type or nil,
					event = data.event or nil,
					onSelect = data.action or nil,
					distance = 2.5,
					label = data.label,
					data = data.data,
					canInteract = data.canInteract,
				},
			}
		})
	end
end

function AddBoxZoneMulti(name, table, data)
	for k, v in pairs(table) do
		if v.gang == nil or v.gang == '' or v.gang == "" then v.gang = 1 end
		if Config.Target == 'qb' then
			exports['qb-target']:AddBoxZone(name .. k, v.loc, 1.5, 1.75,
				{ name = name .. k, minZ = v.loc.z - 1.50, maxZ = v.loc.z + 1.5 },
				{
					options = {
						{
							type = data.type or nil,
							event = data.event or nil,
							action = data.action or nil,
							icon = data.icon or "fa-solid fa-eye",
							label = data.label,
							data = k,
							canInteract = data.canInteract or function()
								if QBCore.Functions.GetPlayerData().gang.name == v.gang or v.gang == 1 then return true end
							end
						}
					},
					distance = 2.5
				})
		elseif Config.Target == 'ox' then
			exports.ox_target:addBoxZone({
				coords = v.loc,
				size = vec3(1, 1, 1),
				options = {
					{
						type = data.type or nil,
						event = data.event or nil,
						onSelect = data.action or nil,
						icon = data.icon or "fa-solid fa-eye",
						label = data.label,
						data = k,
						distance = 2.5,
						canInteract = data.canInteract or function()
							if QBCore.Functions.GetPlayerData().gang.name == v.gang or v.gang == 1 then return true end
						end
					}
				},
			})
		elseif Config.Target == 'interact' then
			exports.interact:AddInteraction({
				coords = vector3(v.loc.x, v.loc.y, v.loc.z),
				distance = 2.5,
				interactDst = 2,
				id = name,
				options = {
					{
						type = data.type or nil,
						event = data.event or nil,
						action = data.action or nil,
						distance = 2.5,
						label = data.label or "fa-solid fa-eye",
						data = k,
						canInteract = data.canInteract or function()
							if QBCore.Functions.GetPlayerData().gang.name == v.gang or v.gang == 1 then return true end
						end
					},
				}
			})
		end
	end
end

function AddBoxZoneMultiOptions(name, loc, data)
	local options = {}
	for k, v in pairs(data) do
		table.insert(options, {
			icon = v.icon or "fa-solid fa-eye",
			label = v.label,
			event = v.event or nil,
			action = v.action or nil,
			onSelect = v.action,
			data = v.data,
			canInteract = v.canInteract or nil,
			distance = 2.0,
		})
	end
	if Config.Target == 'qb' then
		exports['qb-target']:AddBoxZone(name, loc, 1.5, 1.75, { name = name, minZ = loc.z - 1.50, maxZ = loc.z + 1.5 },
			{ options = options, distance = 2.5 })
	elseif Config.Target == 'ox' then
		exports.ox_target:addBoxZone({ coords = loc, size = vec3(1, 1, 1), options = options })
	elseif Config.Target == 'interact' then
		exports.interact:AddInteraction({ coords = vector3(loc.x, loc.y, loc.z), distance = 2.5, interactDst = 2, id =
		name, options = options })
	end
end

function AddSingleModel(model, data, num)
	if Config.Target == 'qb' then
		exports['qb-target']:AddTargetEntity(model, {
			options = {
				{ icon = data.icon or "fa-solid fa-eye", label = data.label, event = data.event or nil, action = data.action or nil, data = num }
			},
			distance = 2.5
		})
	elseif Config.Target == 'ox' then
		exports.ox_target:addLocalEntity(model,
			{ icon = data.icon, label = data.label, event = data.event or nil, onSelect = data.action or nil, data = num, distance = 2.5 })
	elseif Config.Target == 'interact' then
		exports.interact:AddLocalEntityInteraction({ entity = model, offset = vec3(0.0, 0.0, 1.0), id = 'mddrugs' ..
		model, distance = 2.5, interactDst = 2.5, options = { label = data.label, event = data.event or nil, action = data.action or nil, data = num, distance = 2.5 } })
	end
end

function AddMultiModel(model, data, num)
	local options = {}
	for k, v in pairs(data) do
		table.insert(options, {
			icon = v.icon or "fa-solid fa-eye",
			label = v.label,
			event = v.event or nil,
			action = v.action or nil,
			onSelect = v.action,
			data = v.data,
			canInteract = v.canInteract or nil,
			distance = 2.0,
		})
	end
	if Config.Target == 'qb' then
		exports['qb-target']:AddTargetEntity(model, { options = options, distance = 2.5 })
	elseif Config.Target == 'ox' then
		exports.ox_target:addLocalEntity(model, options)
	elseif Config.Target == 'interact' then
		local loc = GetEntityCoords(model)
		exports.interact:AddLocalEntityInteraction({ entity = model, offset = vec3(0.0, 0.0, 1.0), id = 'mddrugss' ..
		model, distance = 2.5, interactDst = 2.5, options = data })
	end
end

local created = false
local heading = 180.0
function StartRay()
	local run = true
	local pedcoord = GetEntityCoords(PlayerPedId())
	RegisterModelRequest('v_ret_ml_tablea')
	local table = CreateObject('v_ret_ml_tablea', pedcoord.x, pedcoord.y, pedcoord.z + 1, heading, false, false)
	repeat
		local hit, entityHit, endCoords, surfaceNormal, matHash = lib.raycast.cam(511, 4, 10)
		if not created then
			created = true
			lib.showTextUI([[[E] To Place
			[DEL] To Cancel
			[<-] To Move Left
			[->] To Move Right]])
		else
			SetEntityCoords(table, endCoords.x, endCoords.y, endCoords.z + 1)
			SetEntityHeading(table, heading)
			SetEntityCollision(table, false, false)
			SetEntityAlpha(table, 100)
		end
		if IsControlPressed(0, 174) then
			heading = heading - 2
		end
		if IsControlPressed(0, 175) then
			heading = heading + 2
		end
		if IsControlPressed(0, 38) then
			lib.hideTextUI()
			run = false
			DeleteObject(table)
			created = false
			return endCoords, heading
		end

		if IsControlPressed(0, 178) then
			lib.hideTextUI()
			run = false
			created = false
			DeleteObject(table)
			return nil, nil
		end
		Wait(0)
	until run == false
end

function StartRay2()
	local run = true
	local pedcoord = GetEntityCoords(PlayerPedId())
	RegisterModelRequest('bkr_prop_coke_press_01aa')
	local table = CreateObject('bkr_prop_coke_press_01aa', pedcoord.x, pedcoord.y, pedcoord.z + 1, heading, false, false)
	repeat
		local hit, entityHit, endCoords, surfaceNormal, matHash = lib.raycast.cam(511, 4, 10)
		if not created then
			created = true
			lib.showTextUI([[[E] To Place
			[DEL] To Cancel
			[<-] To Move Left
			[->] To Move Right]])
		else
			SetEntityCoords(table, endCoords.x, endCoords.y, endCoords.z + 1)
			SetEntityHeading(table, heading)
			SetEntityCollision(table, false, false)
			SetEntityAlpha(table, 100)
		end
		if IsControlPressed(0, 174) then
			heading = heading - 2
		end
		if IsControlPressed(0, 175) then
			heading = heading + 2
		end
		if IsControlPressed(0, 38) then
			lib.hideTextUI()
			run = false
			DeleteObject(table)
			created = false
			return endCoords, heading
		end

		if IsControlPressed(0, 178) then
			lib.hideTextUI()
			run = false
			created = false
			DeleteObject(table)
			return nil, nil
		end
		Wait(0)
	until run == false
end



lib.callback.register('md-drugs:client:uncuff', function(data)
	if not BeginProgressBar(data, 4000, 'uncuff') then return end
	return true
end)

RegisterCommand('DrugRep', function()
	if not Config.TierSystem then return end
	local rep = lib.callback.await('md-drugs:server:GetRep', false)
	lib.registerContext({
		id = 'DrugRep',
		title = 'Drug Reputation',
		options = {
			{ icon = "fa-solid fa-face-flushed", title = 'Cocaine: ' .. rep.coke },
			{ icon = "fa-solid fa-syringe",      title = 'Heroin: ' .. rep.heroin },
			{ icon = "fa-solid fa-vial",         title = 'LSD: ' .. rep.lsd },
			{ icon = "fa-solid fa-plug",         title = 'Dealer: ' .. rep.dealerrep },
			{ icon = "fa-solid fa-money-bill",   title = 'Corner Selling: ' .. rep.cornerselling.rep, description = 'Rank: ' .. rep.cornerselling.label }
		}
	})
	lib.showContext('DrugRep')
end, false)
