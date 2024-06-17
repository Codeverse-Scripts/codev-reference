Framework = Config.Framework == "esx" and exports['es_extended']:getSharedObject() or exports['qb-core']:GetCoreObject()

local Charset = {}
local NumberCharset = {}

for i = 65, 90 do
	table.insert(Charset, string.char(i))
end
for i = 97, 122 do
	table.insert(Charset, string.char(i))
end
for i = 48, 57 do
	table.insert(NumberCharset, string.char(i))
end

function GetRandomNumber(length)
	return length > 0 and GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)] or ''
end

function GetRandomLetter(length)
	return length > 0 and GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)] or ''
end

function GeneratePlate()
	math.randomseed(GetGameTimer())

	local plate = string.upper(GetRandomNumber(1) .. GetRandomLetter(3) .. GetRandomLetter(3))

	local isTaken = mysqlQuery(
		'SELECT plate FROM ' .. (Config.Framework == "qb" and "player_vehicles" or "owned_vehicles")
		.. ' WHERE plate = ?', {
			plate
		})[1]

	if isTaken then
		return GeneratePlate()
	end

	return plate:upper()
end

function GenerateRandomCode(src)
	math.randomseed(GetGameTimer())
	local refCode = Config.Prefix..string.upper(GetRandomNumber(2) .. GetRandomLetter(3) .. GetRandomNumber(2) .. GetRandomLetter(2))

	local file = LoadResourceFile(GetCurrentResourceName(), 'database.json')
	local data = json.decode(file)

    for _, code in pairs(data) do
        if code.code == Config.Prefix..refCode then
            GenerateRandomCode(src)
        end
    end

    table.insert(data, {code = refCode, player = getPlayerIdentifier(src), used = false, uses = 0, taken = {}})
	SaveResourceFile(GetCurrentResourceName(), 'database.json', json.encode(data), -1)

    return true
end

function mysqlQuery(query, params)
	if Config.MySQL == "oxmysql" then
		return exports["oxmysql"]:query_async(query, params)
	elseif Config.MySQL == "mysql-async" then
		local p = promise.new()

		exports['mysql-async']:mysql_execute(query, params, function(result)
			p:resolve(result)
		end)

		return Citizen.Await(p)
	elseif Config.MySQL == "ghmattimysql" then
		return exports['ghmattimysql']:executeSync(query, params)
	end
end

function UseCode(scode, src)
    local file = LoadResourceFile(GetCurrentResourceName(), 'database.json')    
	local data = json.decode(file)
    
    for _, code in pairs(data) do
        if code.code == scode then
            code.uses = code.uses + 1

            for _, codee in pairs(data) do
                if codee.player == getPlayerIdentifier(src) then
                    codee.used = true
                    SaveResourceFile(GetCurrentResourceName(), 'database.json', json.encode(data), -1)
                end
            end

            SaveResourceFile(GetCurrentResourceName(), 'database.json', json.encode(data), -1)
            return true
        end
    end

    return false
end

function registerServerCallback(...)
	if Config.Framework == "qb" then
		Framework.Functions.CreateCallback(...)
	else
		Framework.RegisterServerCallback(...)
	end
end

function getPlayerIdentifier(src)
    local identifiers = GetPlayerIdentifiers(src)
    for _, v in pairs(identifiers) do
        if string.find(v, "license") then
            return v
        end
    end
end

function CheckCode(src)
    local file = LoadResourceFile(GetCurrentResourceName(), 'database.json')
	local data = json.decode(file)

    for _, code in pairs(data) do
        if code.player == getPlayerIdentifier(src) then
            if not code.used then
                return true
            else
                return false
            end
        end
    end

    return GenerateRandomCode(src)
end

registerServerCallback("codev-references:useCode", function(player, cb, scode) 
    local file = LoadResourceFile(GetCurrentResourceName(), 'database.json')
	local data = json.decode(file)
    
    for _, code in pairs(data) do
        if code.player == getPlayerIdentifier(player) then
            cb(UseCode(scode, player))
        end
    end

    cb(false)
end)

registerServerCallback("codev-references:getCode", function(player, cb, scode) 
    local file = LoadResourceFile(GetCurrentResourceName(), 'database.json')
	local data = json.decode(file)
    
    for _, code in pairs(data) do
        if code.player == getPlayerIdentifier(player) then
            cb(code.code)
        end
    end

    cb(false)
end)

registerServerCallback("codev-references:getCode", function(player, cb) 
    local file = LoadResourceFile(GetCurrentResourceName(), 'database.json')
	local data = json.decode(file)

    for _, code in pairs(data) do
        if code.player == getPlayerIdentifier(player) then
            cb(code.code)
        end
    end

    cb(false)
end)

registerServerCallback("codev-references:getUses", function(player, cb) 
    local file = LoadResourceFile(GetCurrentResourceName(), 'database.json')
	local data = json.decode(file)

    for _, code in pairs(data) do
        if code.player == getPlayerIdentifier(player) then
            cb(code)
        end
    end

    cb(false)
end)

registerServerCallback("codev-references:getPrize", function(player, cb, index) 
    local file = LoadResourceFile(GetCurrentResourceName(), 'database.json')
	local data = json.decode(file)

    for i, code in pairs(data) do
        if code.player == getPlayerIdentifier(player) then
            if index <= code.uses then
                table.insert(data[i].taken, index)
                cb(Config.Gifts[index])
                givePrize(Config.Gifts[index], player)
                SaveResourceFile(GetCurrentResourceName(), 'database.json', json.encode(data), -1)
            end
        end
    end

    cb(false)
end)

RegisterCommand("testlogin", function(src)
    if CheckCode(src) then
        TriggerClientEvent("codev-references:openUseMenu", src)
    end
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded')
AddEventHandler('QBCore:Server:OnPlayerLoaded', function()
    local src = source

    if CheckCode(src) then
        TriggerClientEvent("codev-references:openUseMenu", src)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    local src = source

    if CheckCode(src) then
        TriggerClientEvent("codev-references:openUseMenu", src)
    end
end)