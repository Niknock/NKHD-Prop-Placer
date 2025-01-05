ESX = nil
ESX = exports["es_extended"]:getSharedObject()

local currentPreview = nil
local isPlacing = false
local rotation = 0.0
local placementDistance = 2.0 
local holdingBox = false
local itemName2 = ""

function playAnimation(dict, anim, freeze)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end

    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, -8.0, -1, freeze and 49 or 0, 0, false, false, false)
end

RegisterNetEvent("esx_propplacer:startPlacement")
AddEventHandler("esx_propplacer:startPlacement", function(propModel, itemName)
    itemName2 = itemName
    if not propModel then
        return
    end

    if isPlacing then
        ESX.ShowNotification(Config.NotAlreadyPlacing)
        return
    end

    isPlacing = true
    showInstructions() 

    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Wait(100)
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local targetCoords = playerCoords + forward * placementDistance

    currentPreview = CreateObject(propModel, targetCoords.x, targetCoords.y, targetCoords.z, false, false, false)
    SetEntityAlpha(currentPreview, 100, false) 
    SetEntityCollision(currentPreview, false, false)
    FreezeEntityPosition(currentPreview, true)
end)

CreateThread(function()
    while true do
        Wait(0)

        if isPlacing and currentPreview then
            local camCoords = GetGameplayCamCoord()
            local camRot = GetGameplayCamRot(2)
            local forward = RotationToDirection(camRot)

            if IsControlPressed(0, 241) then
                placementDistance = math.min(10.0, placementDistance + 0.1)
            elseif IsControlPressed(0, 242) then 
                placementDistance = math.max(1.0, placementDistance - 0.1)
            end

            local targetCoords = camCoords + forward * placementDistance
            local _, groundZ = GetGroundZFor_3dCoord(targetCoords.x, targetCoords.y, targetCoords.z, true)
            SetEntityCoords(currentPreview, targetCoords.x, targetCoords.y, groundZ, false, false, false, true)

            if IsControlPressed(0, 175) then 
                rotation = rotation + 1.0
            elseif IsControlPressed(0, 174) then
                rotation = rotation - 1.0
            end
            SetEntityHeading(currentPreview, rotation)

            if IsControlJustPressed(0, 191) then 
                isPlacing = false
                playAnimation("amb@world_human_gardener_plant@male@base", "base", true)
                Wait(1500)
            
                local finalCoords = GetEntityCoords(currentPreview)
                local finalHeading = GetEntityHeading(currentPreview)
                local propModel = GetEntityModel(currentPreview)
                DeleteEntity(currentPreview)
                currentPreview = nil
            
                TriggerServerEvent("esx_propplacer:placeProp", propModel, finalCoords, finalHeading)
                ClearPedTasks(PlayerPedId())
                itemName2 = ""
                hideInstructions()
            end
            
            if IsControlJustPressed(0, 194) then 
                isPlacing = false
                DeleteEntity(currentPreview)
                currentPreview = nil
                TriggerServerEvent("esx_propplacer:returnItemCancel", itemName2)
                ESX.ShowNotification(Config.NotCancel)
                itemName2 = ""
                hideInstructions()
            end            
        end
    end
end)

function RotationToDirection(rotation)
    local radZ = math.rad(rotation.z)
    local radX = math.rad(rotation.x)
    local cosX = math.cos(radX)

    return vector3(
        -math.sin(radZ) * cosX,
        math.cos(radZ) * cosX,
        math.sin(radX)
    )
end

local placedProps = {} 

RegisterNetEvent("esx_propplacer:syncProp")
AddEventHandler("esx_propplacer:syncProp", function(propModel, coords, heading)
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Wait(100)
    end

    local prop = CreateObject(propModel, coords.x, coords.y, coords.z, true, true, false)
    SetEntityHeading(prop, heading)
    PlaceObjectOnGroundProperly(prop)
    FreezeEntityPosition(prop, true)

    table.insert(placedProps, prop)

    exports.ox_target:addLocalEntity(prop, {
        {
            name = "remove_prop",
            label = Config.Remove,
            icon = "fas fa-trash",
            onSelect = function(data)
                removeProp(data.entity)
            end
        }
    })
end)

function removeProp(prop)
    if DoesEntityExist(prop) then
        local playerPed = PlayerPedId()

        playAnimation("amb@world_human_gardener_plant@male@exit", "exit", true)
        Wait(1500) 

        local propModel = GetEntityModel(prop)
        DeleteEntity(prop)

        for i, placedProp in ipairs(placedProps) do
            if placedProp == prop then
                table.remove(placedProps, i)
                break
            end
        end

        exports.ox_target:removeEntity(prop)

        TriggerServerEvent("esx_propplacer:returnItem", propModel)
        ClearPedTasks(playerPed)
    end
end

function showInstructions()
    SendNUIMessage({
        action = "show"
    })
end

function hideInstructions()
    SendNUIMessage({
        action = "hide"
    })
end
