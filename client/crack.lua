RegisterNetEvent("md-drugs:client:makecrackone", function(data)
	if not VerifyPlayerHasItem('bakingsoda') then return end
	if not ReturnMinigameSuccess() then TriggerServerEvent("md-drugs:server:failcrackone", data.data) return end
    if not BeginProgressBar(locale("Crack.cookcrack"), 4000, 'uncuff') then return end
    TriggerServerEvent("md-drugs:server:makecrackone", data.data)       
end)

RegisterNetEvent("md-drugs:client:bagcrack", function(data)
	if not VerifyPlayerHasItem('empty_weed_bag') then return end
	if not BeginProgressBar(locale("Crack.bagcrack"), 4000, 'uncuff') then return end
	TriggerServerEvent("md-drugs:server:bagcrack", data.data)
end)