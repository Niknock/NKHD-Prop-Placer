ESX = nil
ESX = exports["es_extended"]:getSharedObject()

for itemName, propModel in pairs(Config.Props) do
    ESX.RegisterUsableItem(itemName, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer.getInventoryItem(itemName).count > 0 then
            TriggerClientEvent("esx_propplacer:startPlacement", source, propModel, itemName)
            xPlayer.removeInventoryItem(itemName, 1)
        else
        end
    end)
end

RegisterNetEvent("esx_propplacer:placeProp")
AddEventHandler("esx_propplacer:placeProp", function(propModel, coords, heading)
    TriggerClientEvent("esx_propplacer:syncProp", -1, propModel, coords, heading)
end)

RegisterNetEvent("esx_propplacer:returnItem")
AddEventHandler("esx_propplacer:returnItem", function(propModel)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not propModel then
        return
    end

    for itemName, modelName in pairs(Config.Props) do
        if GetHashKey(modelName) == propModel then
            xPlayer.addInventoryItem(itemName, 1)
            return
        end
    end
end)

RegisterNetEvent("esx_propplacer:returnItemCancel")
AddEventHandler("esx_propplacer:returnItemCancel", function(itemName2)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(itemName2, 1)
end)
