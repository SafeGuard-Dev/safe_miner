local ESX = exports["es_extended"]:getSharedObject()
local isWorking = false
local currentLevel = 0
local currentExp = 0
local nearMiningSpot = false
local miningProp = nil
local miningSound = nil
local uiShown = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    TriggerServerEvent('mineiro:getPlayerLevel')
end)

RegisterNetEvent('mineiro:setPlayerLevel')
AddEventHandler('mineiro:setPlayerLevel', function(level, exp)
    currentLevel = level
    currentExp = exp
    if nearMiningSpot then
        updateUI()
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local wasNearMiningSpot = nearMiningSpot
        nearMiningSpot = false

        for _, location in ipairs(Config.MiningLocations) do
            local distance = #(playerCoords - vector3(location.x, location.y, location.z))
            if distance <= Config.MiningRadius then
                nearMiningSpot = true
                break
            end
        end

        if nearMiningSpot ~= wasNearMiningSpot then
            if nearMiningSpot then
                showUI()
            else
                hideUI()
            end
        end
    end
end)

function startMining()
    if isWorking or not nearMiningSpot then return end
    
    ESX.TriggerServerCallback('mineiro:checkTool', function(hasTool)
        if hasTool then
            isWorking = true
            ESX.ShowNotification('Você começou a minerar.')
            
            local playerPed = PlayerPedId()
            
            RequestAnimDict("melee@large_wpn@streamed_core")
            while not HasAnimDictLoaded("melee@large_wpn@streamed_core") do
                Citizen.Wait(100)
            end
            
            local propName = "prop_tool_pickaxe"
            local propHash = GetHashKey(propName)
            RequestModel(propHash)
            while not HasModelLoaded(propHash) do
                Citizen.Wait(100)
            end
            miningProp = CreateObject(propHash, 0.0, 0.0, 0.0, true, true, true)
            AttachEntityToEntity(miningProp, playerPed, GetPedBoneIndex(playerPed, 57005), 0.18, -0.02, -0.02, 350.0, 100.00, 140.0, true, true, false, true, 1, true)
            
            Citizen.CreateThread(function()
                while isWorking do
                    if not isWorking then break end
                    playMiningSound()
                    if not IsEntityPlayingAnim(playerPed, "melee@large_wpn@streamed_core", "ground_attack_on_spot", 3) then
                        TaskPlayAnim(playerPed, "melee@large_wpn@streamed_core", "ground_attack_on_spot", 8.0, -8.0, -1, 1, 0, false, false, false)
                    end
                    Citizen.Wait(0)
                    if not isWorking then break end
                    TriggerServerEvent('mineiro:rewardPlayer')
                    Citizen.Wait(Config.MiningTime)
                end
            end)

            SendNUIMessage({
                type = 'showCancelButton'
            })
        else
            ESX.ShowNotification('Você precisa de uma ' .. Config.RequiredTool .. ' para minerar.')
        end
    end)
end

function stopMining()
    if not isWorking then return end
    isWorking = false
    
    local playerPed = PlayerPedId()
    
    ClearPedTasks(playerPed)
    
    StopAnimTask(playerPed, "melee@large_wpn@streamed_core", "ground_attack_on_spot", 1.0)
    
    if miningProp then
        DetachEntity(miningProp, true, true)
        DeleteObject(miningProp)
        miningProp = nil
    end
    
    stopMiningSound()
    
    SetPedCanPlayAmbientAnims(playerPed, true)
    
    ESX.ShowNotification('Você parou de minerar.')

    SendNUIMessage({
        type = 'hideCancelButton'
    })
end

function updateUI()
    if not uiShown then return end
    SendNUIMessage({
        type = 'update',
        level = currentLevel,
        exp = currentExp,
        maxExp = Config.ExpPerLevel
    })
end

function showUI()
    uiShown = true
    SendNUIMessage({
        type = 'show'
    })
    updateUI()
end

function hideUI()
    uiShown = false
    SendNUIMessage({
        type = 'hide'
    })
end

function playMiningSound()
    if not miningSound then
        miningSound = GetSoundId()
        PlaySoundFromEntity(miningSound, "Drill_Static", PlayerPedId(), "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
    end
end

function stopMiningSound()
    if miningSound then
        StopSound(miningSound)
        ReleaseSoundId(miningSound)
        miningSound = nil
    end
end

RegisterCommand('minerar', function()
    if isWorking then
        stopMining()
    else
        startMining()
    end
end, false)

RegisterNUICallback('cancelMining', function(data, cb)
    stopMining()
    cb('ok')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, location in ipairs(Config.MiningLocations) do
            local distance = #(playerCoords - vector3(location.x, location.y, location.z))
            if distance <= 20.0 then
                DrawMarker(1, location.x, location.y, location.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 68, 255, 200, false, true, 2, false, nil, nil, false)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 73) then 
            stopMining()
        end
    end
end)

-- Cria o blip de venda de minérios
Citizen.CreateThread(function()
    local sellBlip = AddBlipForCoord(Config.SellLocation.x, Config.SellLocation.y, Config.SellLocation.z)
    SetBlipSprite(sellBlip, 478) 
    SetBlipDisplay(sellBlip, 4)
    SetBlipScale(sellBlip, 1.0)
    SetBlipColour(sellBlip, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.SellBlipName)
    EndTextCommandSetBlipName(sellBlip)

    function IsNearSellLocation()
        local sellLocation = Config.SellLocation
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - vector3(sellLocation.x, sellLocation.y, sellLocation.z))
        return distance <= 3.0
    end
    while true do
        Citizen.Wait(0)
        if IsNearSellLocation() then
            DrawText3Ds(Config.SellLocation.x, Config.SellLocation.y, Config.SellLocation.z + 0.5, '[E] Vender Minérios')
            if IsControlJustReleased(0, Config.SellKeybind) then
                TriggerServerEvent('venderMinerios')
            end
        end
    end
end)

function DrawText3Ds(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z + 0.5)

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()

        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(_x, _y)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        DrawMarker(29, Config.SellLocation.x, Config.SellLocation.y, Config.SellLocation.z + 0.5, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.0, 0, 68, 255, 200, false, true, 2, false, nil, nil, false)
    end
end)
