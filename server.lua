ESX = nil
ESX = exports["es_extended"]:getSharedObject()

for itemName, propModel in pairs(Config.Props) do
    ESX.RegisterUsableItem(itemName, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        TriggerClientEvent('esx_propplacer:useItem', source, propModel)
    end)
end

RegisterNetEvent("esx_propplacer:placeProp")
AddEventHandler("esx_propplacer:placeProp", function(propModel, coords, heading)
    local xPlayer = ESX.GetPlayerFromId(source)
     TriggerClientEvent("esx_propplacer:syncProp", -1, propModel, coords, heading)
end)
