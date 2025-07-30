local carryPackage = nil

RegisterNetEvent("md-drugs:client:GetOxyCar", function()
	RegisterModelRequest("burrito3")
	local paid = lib.callback.await('md-drugs:server:payfortruck', false)
	if not paid then return end
	local loca = lib.callback.await('md-drugs:server:getLocs', false)
	local loc = loca.singleSpot.truckspawn
	local oxycar = CreateVehicle("burrito3",loc.x, loc.y,loc.z, loc.w, true, false)
    exports[Config.Fuel]:SetFuel(oxycar, 100.0)
    TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(oxycar))
	Notify(locale("oxy.truck"), 'success')
	TriggerEvent("md-drugs:client:getoxylocationroute")
	AddSingleModel(oxycar,  { event = "md-drugs:client:getfromtrunk", icon = "fa-solid fa-box", label = locale("targets.oxy.pack")}, nil )
end)

RegisterNetEvent("md-drugs:client:getoxylocationroute", function()
	local config = lib.callback.await('md-drugs:server:getLocs', false)
    local loc = config.oxylocations[math.random(#config.oxylocations)]
	if loc == nil then return end
	SetNewWaypoint(loc.x, loc.y)
	local current = "g_m_y_famdnf_01"
	RegisterModelRequest(current)
	local oxybuyer = CreatePed(0, current,loc.x,loc.y,loc.z-1, loc.w, false, false)
	Freeze(oxybuyer, true, loc.w)
	repeat
		Wait(1000)
	until #(GetEntityCoords(PlayerPedId()) - vector3(loc.x,loc.y,loc.z)) < 5.0
	SendDispatchEvent(Config.PoliceAlertOxy)
	AddSingleModel(oxybuyer,  { type = "client", label = locale("targets.oxy.talk"), icon = "fa-solid fa-dollar-sign",
	action = function()
		if not carryPackage then return Notify(locale("oxy.empty"), "error") end
		if not BeginProgressBar(locale("oxy.hand"), 4000, 'uncuff') then return end
		TriggerServerEvent("md-drugs:server:giveoxybox")
		DeleteEntity(oxybuyer)
		DetachEntity(carryPackage, true, true)
		DeleteObject(carryPackage)
		carryPackage = nil
	end}, oxybuyer)
end)


RegisterNetEvent("md-drugs:client:getfromtrunk", function() 
	if carryPackage then return Notify(locale("oxy.carrying"), "error") end
	local pos = GetEntityCoords(PlayerPedId(), true)
	RegisterAnimDict('anim@heists@box_carry@')
	TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 5.0, -1, -1, 50, 0, false, false, false)
	RegisterModelRequest("hei_prop_drug_statue_box_big")
	local object = CreateObject("hei_prop_drug_statue_box_big", pos.x, pos.y, pos.z, true, true, true)
	AttachEntityToEntity(object, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
	carryPackage = object
end)


RegisterNetEvent("md-drugs:client:giveoxybox", function(data) 
	if not carryPackage then return Notify(locale("oxy.empty"), "error") end
	if not BeginProgressBar(locale("oxy.hand"), 4000, 'uncuff') then return end
	TriggerServerEvent("md-drugs:server:giveoxybox")
	DeleteEntity(data.ped)
	DetachEntity(carryPackage, true, true)
	DeleteObject(carryPackage)
	carryPackage = nil
end)

