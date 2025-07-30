CreateThread(function()
	local config = lib.callback.await('md-drugs:server:getLocs', false)
	if not config then
		print('Yo Dawg You Broke Your Locations.lua')
		return
	end
	AddBoxZoneSingle('telecokein', config.singleSpot.CokeTeleIn,
		{ action = function() tele(config.singleSpot.CokeTeleOut) end, icon = 'fa-solid fa-door-open', label = locale(
		"targets.coke.enter") })                                                                                                                                                                         -- coke
	AddBoxZoneSingle('telecokeout', config.singleSpot.CokeTeleOut,
		{ action = function() tele(config.singleSpot.CokeTeleIn) end, icon = "fa-solid fa-door-closed", label = locale(
		"targets.coke.exit") })                                                                                                                                                                          -- coke
	AddBoxZoneMulti('makepowder', config.MakePowder,
		{ event = "md-drugs:client:makepowder", icon = "fa-solid fa-scissors", label = locale("targets.coke.chop") })                                                                                    -- coke
	AddBoxZoneMulti('steallysergic', config.lysergicacid,
		{ event = "md-drugs:client:getlysergic", icon = "fa-solid fa-prescription-bottle", label = locale(
		"targets.lsd.lys") })                                                                                                                                                                            -- lsd
	AddBoxZoneMulti('stealdiethylamide', config.diethylamide,
		{ event = "md-drugs:client:getdiethylamide", icon = "fa-solid fa-prescription-bottle", label = locale(
		"targets.lsd.die") })                                                                                                                                                                            -- lsd
	AddBoxZoneMulti('gettabs', config.gettabs,
		{ event = "md-drugs:client:buytabs", icon = "fa-solid fa-eye-dropper", label = locale("targets.lsd.buyt") })                                                                                     -- lsd
	AddBoxZoneMulti('dryheroin', config.dryplant,
		{ event = "md-drugs:client:dryplant", icon = "fa-solid fa-temperature-full", label = locale("targets.heroin.dry") })                                                                             -- heroin
	AddBoxZoneMulti('cutheroin', config.cutheroinone,
		{ event = "md-drugs:client:cutheroin", icon = "fa-solid fa-flask", label = locale("targets.heroin.cut") })                                                                                       -- heroin
	AddBoxZoneMulti('fillneedle', config.fillneedle,
		{ event = "md-drugs:client:fillneedle", icon = "fa-solid fa-syringe", label = locale("targets.heroin.fill") })                                                                                   -- heroin
	AddBoxZoneMulti('makecrack', config.makecrack,
		{ event = "md-drugs:client:makecrackone", icon = "fa-solid fa-temperature-high", label = locale(
		"targets.crack.cook") })                                                                                                                                                                         -- crack
	AddBoxZoneMulti('bagcrack', config.bagcrack,
		{ event = "md-drugs:client:bagcrack", icon = "fa-solid fa-weight-scale", label = locale("targets.crack.bag") })                                                                                  -- crack
	AddBoxZoneMulti('fillprescription', config.FillPrescription,
		{ event = "md-drugs:client:fillprescription", icon = "fa-solid fa-prescription", label = locale(
		"targets.pharma.fill") })                                                                                                                                                                        -- pharma
	AddBoxZoneSingle('payfortruck', config.singleSpot.Payfortruck,
		{ event = "md-drugs:client:GetOxyCar", icon = "fa-solid fa-truck-moving", label = locale("targets.oxy.pay") })                                                                                   -- oxy runs
	AddBoxZoneSingle('drymescaline', config.singleSpot.DryOut,
		{ event = "md-drugs:client:drymescaline", icon = "fa-solid fa-temperature-full", label = locale(
		"targets.mescaline.dry") })                                                                                                                                                                      -- mescaline
	AddBoxZoneMulti('stealisosafrole', config.isosafrole,
		{ event = "md-drugs:client:stealisosafrole", icon = "fa-solid fa-vial", label = locale("targets.xtc.iso") })                                                                                     -- xtc
	AddBoxZoneMulti('stealmdp2p', config.mdp2p,
		{ event = "md-drugs:client:stealmdp2p", icon = "fa-solid fa-vial", label = locale("targets.xtc.mdp") })                                                                                          -- xtc
	AddBoxZoneMulti('rawxtcloc', config.rawxtcloc,
		{ event = "md-drugs:client:makingrawxtc", icon = "fa-solid fa-tablets", label = locale("targets.xtc.raw") })                                                                                     -- xtc
	AddBoxZoneSingle('buypress', config.singleSpot.buypress,
		{ event = "md-drugs:client:buypress", icon = "fa-solid fa-mortar-pestle", label = locale("targets.xtc.press") })                                                                                 -- xtc
	AddBoxZoneMulti('stamp', config.stamp,
		{ event = "md-drugs:client:stampwhite", icon = "fa-solid fa-tablets", label = locale("targets.xtc.stamp") })                                                                                     -- xtc
end)
