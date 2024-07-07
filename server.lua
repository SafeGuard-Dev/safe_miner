local ESX = exports["es_extended"]:getSharedObject()

function updatePlayerLevel(playerId, newLevel, newExp)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    MySQL.Async.execute('UPDATE users SET miner_level = @level, miner_exp = @exp WHERE identifier = @identifier', {
        ['@level'] = newLevel,
        ['@exp'] = newExp,
        ['@identifier'] = xPlayer.identifier
    })
end

RegisterServerEvent('mineiro:getPlayerLevel')
AddEventHandler('mineiro:getPlayerLevel', function()
    local playerId = source
    local level, exp = getPlayerLevel(playerId)
    TriggerClientEvent('mineiro:setPlayerLevel', playerId, level, exp)
end)

function updatePlayerLevel(playerId, newLevel, newExp)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    MySQL.Async.execute('UPDATE users SET miner_level = @level, miner_exp = @exp WHERE identifier = @identifier', {
        ['@level'] = newLevel,
        ['@exp'] = newExp,
        ['@identifier'] = xPlayer.identifier
    })
end

ESX.RegisterServerCallback('mineiro:checkTool', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem(Config.RequiredTool)
    cb(item.count > 0)
end)

RegisterServerEvent('mineiro:rewardPlayer')
AddEventHandler('mineiro:rewardPlayer', function()
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local currentLevel, currentExp = getPlayerLevel(playerId)
    
    local rewardMoney = math.floor(Config.BaseMoney * (1 + (currentLevel * Config.LevelMultiplier)))
    local rewardExp = math.floor(Config.BaseExperience * (1 + (currentLevel * Config.LevelMultiplier)))
    
    xPlayer.addMoney(rewardMoney)
    
    local item = getRandomItem()
    local itemCount = 1 + currentLevel
    xPlayer.addInventoryItem(item.name, itemCount)
    
    local newExp = currentExp + rewardExp
    local newLevel = currentLevel
    
    if newExp >= Config.ExpPerLevel and currentLevel < Config.MaxLevel then
        newLevel = currentLevel + 1
        newExp = newExp - Config.ExpPerLevel
        TriggerClientEvent('esx:showNotification', playerId, 'Parabéns! Você subiu para o nível ' .. newLevel)
    end

    updatePlayerLevel(playerId, newLevel, newExp)

    TriggerClientEvent('mineiro:setPlayerLevel', playerId, newLevel, newExp)
    TriggerClientEvent('esx:showNotification', playerId, 'Você ganhou $' .. rewardMoney .. ', ' .. rewardExp .. ' de experiência e ' .. itemCount .. ' ' .. item.label .. '(s).')
end)

function getRandomItem()
    local chance = math.random(100)
    local sum = 0
    for _, item in ipairs(Config.MiningItems) do
        sum = sum + item.chance
        if chance <= sum then
            return item
        end
    end
    return Config.MiningItems[1]
end

function getPlayerLevel(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local result = MySQL.Sync.fetchAll('SELECT miner_level, miner_exp FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    })
    
    if result[1] then
        return result[1].miner_level, result[1].miner_exp
    else
        return 1, 0
    end
end

RegisterServerEvent('venderMinerios')
AddEventHandler('venderMinerios', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer then
        local stoneQuantity = xPlayer.getInventoryItem('stone').count
        local ironQuantity = xPlayer.getInventoryItem('iron').count
        local goldQuantity = xPlayer.getInventoryItem('gold').count

        local totalMoney = stoneQuantity * Config.StonePrice + ironQuantity * Config.IronPrice + goldQuantity * Config.GoldPrice

        xPlayer.removeInventoryItem('stone', stoneQuantity)
        xPlayer.removeInventoryItem('iron', ironQuantity)
        xPlayer.removeInventoryItem('gold', goldQuantity)
        xPlayer.addMoney(totalMoney)

        TriggerClientEvent('esx:showNotification', _source, 'Você vendeu minérios por $' .. totalMoney)
    end
end)


function lib.versionCheck(repository)
    local resource = GetInvokingResource() or GetCurrentResourceName()

    local currentVersion = GetResourceMetadata(resource, 'version', 0)

    if currentVersion then
        currentVersion = currentVersion:match('%d+%.%d+%.%d+')
    end

    if not currentVersion then return print(("^1Unable to determine current resource version for '%s' ^0"):format(resource)) end

    SetTimeout(1000, function()
        PerformHttpRequest(('https://api.github.com/repos/%s/releases/latest'):format(repository), function(status, response)
            if status ~= 200 then return end

            response = json.decode(response)
            if response.prerelease then return end

            local latestVersion = response.tag_name:match('%d+%.%d+%.%d+')
            if not latestVersion or latestVersion == currentVersion then return end

            local cv = { string.strsplit('.', currentVersion) }
            local lv = { string.strsplit('.', latestVersion) }

            for i = 1, #cv do
                local current, minimum = tonumber(cv[i]), tonumber(lv[i])

                if current ~= minimum then
                    if current < minimum then
                        return print(('^3An update is available for %s (current version: %s)\r\n%s^0'):format(resource, currentVersion, response.html_url))
                    else break end
                end
            end
        end, 'GET')
    end)
end

lib.versionCheck('SafeGuard-Dev/safe_miner')