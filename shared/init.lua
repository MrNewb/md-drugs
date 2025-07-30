Bridge = exports.community_bridge:Bridge()

function locale(message, ...)
    return Bridge.Language.Locale(message, ...)
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
        InitializeSQL()
    end)
else

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

end
