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

end
