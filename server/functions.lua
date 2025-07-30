local QBCore = exports['qb-core']:GetCoreObject()
local notify = Config.Notify       -- qb or ox
local inventory = Config.Inventory -- qb or ox
------------------------------------------ logging stuff
local logs = false
local logapi = GetConvar("fivemerrLogs", "")
local endpoint = 'https://api.fivemerr.com/v1/logs'
local headers = {
    ['Authorization'] = logapi,
    ['Content-Type'] = 'application/json',
}

CreateThread(function()
    if logs then
        print '^2 Logs Enabled for md-drugs'
        if logapi == 'insert string here' then
            print '^1 homie you gotta set your api on line 4'
        else
            print '^2 API Key Looks Good, Dont Trust Me Though, Im Not Smart'
        end
    else
        print '^1 logs disabled for md-drugs'
    end
end)

function Log(message, type)
    if logs == false then return end
    local buffer = {
        level = "info",
        message = message,
        resource = GetCurrentResourceName(),
        metadata = {
            drugs = type,
            playerid = source
        }
    }
    SetTimeout(500, function()
        PerformHttpRequest(endpoint, function(status, _, _, response)
            if status ~= 200 then
                if type(response) == 'string' then
                    response = json.decode(response) or response
                end
            end
        end, 'POST', json.encode(buffer), headers)
        buffer = nil
    end)
end

---------------------------------------------------- inventory catcher
local invname = ''
CreateThread(function()
    if GetResourceState('ps-inventory') == 'started' then
        invname = 'ps-inventory'
    elseif GetResourceState('qb-inventory') == 'started' then
        invname = 'qb-inventory'
    else
        invname = 'inventory'
    end
end)
------------------------------------ Player Stuff functions
function getPlayer(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    return Player
end

function GetCoords(source)
    local ped = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(ped)
    return playerCoords
end

function dist(source, coords)
    local playerPed = GetPlayerPed(source)
    local pcoords = GetEntityCoords(playerPed)
    local dist = #(pcoords - coords)
    return dist
end

function CheckDist(source, coords)
    local playerPed = GetPlayerPed(source)
    local pcoords = GetEntityCoords(playerPed)
    local ok
    if #(pcoords - coords) < 4.0 then
        return ok
    else
        DropPlayer(source,
            'md-drugs: You Were A Total Of ' .. #(pcoords - coords) .. ' Too Far Away To Trigger This Event')
        return false
    end
end

function getRep(source, type)
    local src = source
    local identifier = GetPlayerFrameworkIdentifier(src)
    local sql = MySQL.query.await('SELECT * FROM drugrep WHERE cid = ?', { identifier })
    if not sql[1] then
        local table = json.encode({
            coke = GetPlayerFrameworkMetadata(src, "coke") or 0,
            lsd = GetPlayerFrameworkMetadata(src, "lsd") or 0,
            heroin = GetPlayerFrameworkMetadata(src, "heroin") or 0,
            dealerrep = GetPlayerFrameworkMetadata(src, "dealerrep") or 0,
            cornerselling = {
                price = QBConfig.SellLevel[1].price,
                rep = 0,
                label = QBConfig.SellLevel[1].label,
                level = 1
            }
        })
        MySQL.insert('INSERT INTO drugrep SET cid = ?, drugrep = ?, name = ?',
            { identifier, table, GetPlayerFrameworkName(source) })
        Wait(1000)
        return json.decode(table)
    else
        local reps = json.decode(sql[1].drugrep)
        local rep = ''
        if reps.coke == nil then rep = reps[1] else rep = reps end
        if type == 'coke' then
            return rep.coke
        elseif type == 'heroin' then
            return rep.heroin
        elseif type == 'lsd' then
            return rep.lsd
        elseif type == 'dealerrep' then
            return rep.dealerrep
        elseif type == 'cornerselling' then
            return rep.cornerselling
        else
            print('^1 Error: No Valid Drug Rep Option Chosen')
        end
        return false
    end
end

function GetAllRep(source)
    local src = source
    local identifier = GetPlayerFrameworkIdentifier(src)
    local sql = MySQL.query.await('SELECT * FROM drugrep WHERE cid = ?', { identifier })
    if not sql[1] then
        local table = json.encode({
            coke = GetPlayerFrameworkMetadata(src, "coke") or 0,
            lsd = GetPlayerFrameworkMetadata(src, "lsd") or 0,
            heroin = GetPlayerFrameworkMetadata(src, "heroin") or 0,
            dealerrep = GetPlayerFrameworkMetadata(src, "dealerrep") or 0,
            cornerselling = {
                price = QBConfig.SellLevel[1].price,
                rep = 0,
                label = QBConfig.SellLevel[1].label,
                level = 1
            }
        })
        MySQL.insert('INSERT INTO drugrep SET cid = ?, drugrep = ?, name = ?',
            { identifier, table, GetPlayerFrameworkName(source) })
        Wait(1000)
        return json.decode(table)
    else
        local rep = json.decode(sql[1].drugrep)
        if rep.coke == nil then return rep[1] end
        return rep
    end
end

function AddRep(source, type, amount)
    if not amount then amount = 1 end
    local src = source
    local identifier = GetPlayerFrameworkIdentifier(src)
    local sql = MySQL.query.await('SELECT * FROM drugrep WHERE cid = ?', { identifier })
    local reps = json.decode(sql[1].drugrep)
    local update
    local rep = ''
    if reps.coke == nil then rep = reps[1] else rep = reps end
    if type == 'cornerselling' then
        for k, v in pairs(QBConfig.SellLevel) do
            if rep.cornerselling.level == k then
                if rep.cornerselling.rep + amount >= v.maxrep then
                    update = json.encode({ coke = rep.coke, heroin = rep.heroin, lsd = rep.lsd, dealerrep = rep
                    .dealerrep, cornerselling = { label = v.label, price = v.price, rep = rep.cornerselling.rep + amount, level = k + 1 } })
                else
                    update = json.encode({ coke = rep.coke, heroin = rep.heroin, lsd = rep.lsd, dealerrep = rep
                    .dealerrep, cornerselling = { label = v.label, price = v.price, rep = rep.cornerselling.rep + amount, level = k } })
                end
            end
        end
    elseif type == 'coke' then
        update = json.encode({ coke = rep.coke + amount, heroin = rep.heroin, lsd = rep.lsd, dealerrep = rep.dealerrep, cornerselling =
        rep.cornerselling })
    elseif type == 'heroin' then
        update = json.encode({ coke = rep.coke, heroin = rep.heroin + amount, lsd = rep.lsd, dealerrep = rep.dealerrep, cornerselling =
        rep.cornerselling })
    elseif type == 'lsd' then
        update = json.encode({ coke = rep.coke, heroin = rep.heroin, lsd = rep.lsd + amount, dealerrep = rep.dealerrep, cornerselling =
        rep.cornerselling })
    elseif type == 'dealerrep' then
        update = json.encode({ coke = rep.coke, heroin = rep.heroin, lsd = rep.lsd, dealerrep = rep.dealerrep + amount, cornerselling =
        rep.cornerselling })
    end
    if update == '' then return false end
    MySQL.update('UPDATE drugrep SET drugrep = ? WHERE cid = ?', { update, identifier })
    return true
end

lib.addCommand('addCornerSellingTOREP', {
    help = 'RUN THIS ONCE AND DELETE',
    restricted = 'group.admin'
}, function(source, args, raw)
    local sql = MySQL.query.await('SELECT * FROM drugrep', {})
    for k, v in pairs(sql) do
        local new = {}
        local old = json.decode(v.drugrep)
        local get = old[1] or old
        table.insert(new, {
            coke = get.coke,
            lsd = get.lsd,
            heroin = get.heroin,
            dealerrep = get.dealerrep,
            cornerselling = {
                price = QBConfig.SellLevel[1].price,
                rep = 0,
                label = QBConfig.SellLevel[1].label,
                level = 1
            }
        })
        local news = json.encode(new)
        MySQL.query.await('UPDATE drugrep SET drugrep = ? WHERE cid = ?', { news, v.cid })
    end
end)

function sortTab(tbl, type)
    table.sort(tbl, function(a, b)
        return a[type] < b[type]
    end)
end

function GetPoliceOnline()
    local players = Bridge.Framework.GetPlayersByJob('police')
    return #players or 0
end

lib.callback.register('md-drugs:server:GetCoppers', function(source, cb, args)
    local amount = 0
    local allPdPlayers = Bridge.Framework.GetPlayersByJob('police')
    for k, v in pairs(allPdPlayers) do
        if Bridge.Framework.GetPlayerDuty(v) then
            amount = amount + 1
        end
    end
    return amount
end)

lib.callback.register('md-drugs:server:GetRep', function(source, cb, args)
    local src = source
    local rep = GetAllRep(src)
    return rep
end)