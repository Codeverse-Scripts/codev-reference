function givePrize(prize, player)
    if prize.type == "item" then
        local item = prize.item
        local count = prize.amount or 1

        if Config.Framework == "qb" then
            local xPlayer = Framework.Functions.GetPlayer(player)

            xPlayer.Functions.AddItem(item, count)
        else
            local xPlayer = Framework.GetPlayerFromId(player)

            xPlayer.addInventoryItem(item, count)
        end
    elseif prize.type == "money" then
        local count = prize.amount or 1

        if Config.Framework == "qb" then
            local xPlayer = Framework.Functions.GetPlayer(player)

            xPlayer.Functions.AddMoney("bank", count, "Reference Prize")
        else
            local xPlayer = Framework.GetPlayerFromId(player)

            xPlayer.removeAccountMoney("bank", count)
        end
    elseif prize.type == "vehicle" then
        local plate = GeneratePlate()

        if Config.Framework == "qb" then
            local xPlayer = Framework.Functions.GetPlayer(player)
    
            mysqlQuery(
                'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                {
                    xPlayer.PlayerData.license,
                    xPlayer.PlayerData.citizenid,
                    proprizeduct.name,
                    GetHashKey(prize.name),
                    '{}',
                    plate,
                    'pillboxgarage',
                    1
                })
        else
            local xPlayer = Framework.GetPlayerFromId(player)
    
            mysqlQuery('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {
                xPlayer.identifier,
                plate,
                '{"plate":"' .. plate .. '","model":"' .. GetHashKey(prize.name) .. '"' .. '}'
            })
        end
    end
end