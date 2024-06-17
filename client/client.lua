Framework = Config.Framework == "esx" and exports['es_extended']:getSharedObject() or exports['qb-core']:GetCoreObject()

function triggerServerCallback(...)
	if Config.Framework == "esx" then
		Framework.TriggerServerCallback(...)
	else
		Framework.Functions.TriggerCallback(...)
	end
end

RegisterNUICallback("useCode", function(code, cb)
    triggerServerCallback("codev-references:useCode", function(status) 
        cb(status)
    end, code)
end)

RegisterNUICallback("getCode", function(_, cb)
    triggerServerCallback("codev-references:getCode", function(status) 
        cb(status)
    end)
end)

RegisterNUICallback("getPrize", function(index, cb)
    triggerServerCallback("codev-references:getPrize", function(status) 
        cb(status)
    end, index)
end)

RegisterNUICallback("getGifts", function(_, cb)
    triggerServerCallback("codev-references:getUses", function(scb) 
        local takens = {}
        for _, taken in ipairs(scb.taken) do table.insert(takens, taken) end
        cb({uses = scb.uses, prizes = Config.Gifts, taken = takens})
    end)
end)

RegisterNetEvent("codev-references:openUseMenu", function()
    SendNUIMessage({action = "openUseMenu"})
    SetNuiFocus(1, 1)
end)

RegisterNUICallback("close", function(code, cb)
    SetNuiFocus(0, 0)
end)

RegisterCommand("referencemenu", function()
    triggerServerCallback("codev-references:getCode", function(cb)
        SendNUIMessage({
            action = "openCodeMenu",
            code = cb
        })
        SetNuiFocus(1, 1)
    end)
end, false)