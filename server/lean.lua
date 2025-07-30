local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('md-drugs:server:givelean', function()
	local chance = math.random(1,100)
	local amount = math.random(1,5)
	if chance <= 50 then 
		if AddItem(source, 'mdlean', amount) then
			Notify(Lang.Lean.lean, "success")
			Log(GetPlayerFrameworkName(source) .. ' Got ' .. amount .. ' Of Lean' , 'lean')
		end
	else
		if AddItem(source, 'mdreddextro', amount) then
			Notify(Lang.Lean.dextro, "success")
			Log(GetPlayerFrameworkName(source) .. ' Got ' .. amount .. ' Of Red Dextro' , 'lean')
		end
	end	
end)

RegisterUsableItems('leancup', function(source, item)
	if ValidateItemCount(source, 'leancup', 1) then 
		TriggerClientEvent('md-drugs:client:leancraft', source)
	end
end)

RegisterServerEvent('md-drugs:server:finishcup', function(data)
	if not GetRecipe(source, 'lean','cups', data.item) then return end
end)