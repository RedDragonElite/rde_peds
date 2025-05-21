ESX = exports["es_extended"]:getSharedObject()
local spawnedPeds = {}

-- Initialize Database
CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `rde_pedmanager` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `model` varchar(50) NOT NULL,
            `x` float NOT NULL,
            `y` float NOT NULL,
            `z` float NOT NULL,
            `heading` float NOT NULL,
            `type` varchar(20) NOT NULL,
            `scenario` varchar(50) DEFAULT NULL,
            `invincible` boolean DEFAULT true,
            `name` varchar(50) DEFAULT NULL,
            `speech` varchar(255) DEFAULT NULL,
            `hostileWhenAttacked` boolean DEFAULT false,
            PRIMARY KEY (`id`)
        )
    ]])

    -- Check if the column exists before adding it
    local result = MySQL.query.await([[
        SHOW COLUMNS FROM rde_pedmanager LIKE 'hostileWhenAttacked';
    ]])

    if not result or #result == 0 then
        MySQL.query([[
            ALTER TABLE rde_pedmanager
            ADD COLUMN hostileWhenAttacked BOOLEAN DEFAULT FALSE;
        ]])
        print('^2[RDE | Peds]^7 Database schema updated successfully')
    else
        print('^2[RDE | Peds]^7 Column hostileWhenAttacked already exists')
    end

    -- Load saved peds
    local savedPeds = MySQL.query.await('SELECT * FROM rde_pedmanager')
    if savedPeds then
        for _, ped in ipairs(savedPeds) do
            spawnedPeds[ped.id] = {
                model = ped.model,
                coords = vector3(ped.x, ped.y, ped.z),
                heading = ped.heading,
                type = ped.type,
                scenario = ped.scenario,
                invincible = ped.invincible,
                name = ped.name,
                speech = ped.speech,
                hostileWhenAttacked = ped.hostileWhenAttacked
            }
        end
        print('^2[RDE | Peds]^7 Loaded ' .. #savedPeds .. ' peds from database')
    end
end)

local function isAdmin(source)
    if not source then return false end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        print('^1[RDE | Peds]^7 Player not found: ' .. source)
        return false
    end

    local playerGroup = xPlayer.getGroup()

    for _, group in ipairs(Config.AdminGroups) do
        if playerGroup == group then
            return true
        end
    end

    return false
end

-- Callbacks
lib.callback.register('rde_peds:checkAdmin', function(source)
    return isAdmin(source)
end)

lib.callback.register('rde_peds:spawnPed', function(source, data)
    if not isAdmin(source) then
        return false, 'Access Denied'
    end

    if not data.coords or not data.model then
        return false, 'Invalid Data'
    end

    local result = MySQL.insert.await('INSERT INTO rde_pedmanager (model, x, y, z, heading, type, scenario, invincible, name, hostileWhenAttacked) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        {
            data.model,
            data.coords.x,
            data.coords.y,
            data.coords.z,
            data.heading,
            data.type,
            data.scenario,
            data.invincible,
            data.name,
            data.hostileWhenAttacked
        })

    if result then
        spawnedPeds[result] = data
        TriggerClientEvent('rde_peds:syncPed', -1, result, data)
        print('^2[RDE | Peds]^7 New ped created by ' .. GetPlayerName(source))
        return result
    end

    return false, 'Database Error'
end)

lib.callback.register('rde_peds:deletePed', function(source, pedId)
    if not isAdmin(source) then
        return false, 'Access Denied'
    end

    if not spawnedPeds[pedId] then
        return false, 'NPC not found'
    end

    local success = MySQL.query.await('DELETE FROM rde_pedmanager WHERE id = ?', {pedId})
    if success then
        spawnedPeds[pedId] = nil
        TriggerClientEvent('rde_peds:deletePed', -1, pedId)
        print('^2[RDE | Peds]^7 Ped ' .. pedId .. ' deleted by ' .. GetPlayerName(source))
        return true
    end
    return false, 'Database Error'
end)

lib.callback.register('rde_peds:deleteAllPeds', function(source)
    if not isAdmin(source) then
        return false, 'Access Denied'
    end

    local success = MySQL.query.await('TRUNCATE TABLE rde_pedmanager')
    if success then
        spawnedPeds = {}
        TriggerClientEvent('rde_peds:deleteAllPeds', -1)
        print('^2[RDE | Peds]^7 All peds deleted by ' .. GetPlayerName(source))
        return true
    end
    return false, 'Database Error'
end)

lib.callback.register('rde_peds:updatePedPosition', function(source, pedId, coords, heading)
    if not isAdmin(source) then
        return false, 'Access Denied'
    end

    if not spawnedPeds[pedId] then
        return false, 'NPC not found'
    end

    local success = MySQL.update.await('UPDATE rde_pedmanager SET x = ?, y = ?, z = ?, heading = ? WHERE id = ?',
        {coords.x, coords.y, coords.z, heading, pedId})

    if success then
        spawnedPeds[pedId].coords = coords
        spawnedPeds[pedId].heading = heading
        TriggerClientEvent('rde_peds:updatePedPosition', -1, pedId, coords, heading)
        print('^2[RDE | Peds]^7 Ped ' .. pedId .. ' position updated by ' .. GetPlayerName(source))
        return true
    end
    return false, 'Database Error'
end)

lib.callback.register('rde_peds:updatePedScenario', function(source, pedId, scenario)
    if not isAdmin(source) then
        return false, 'Access Denied'
    end

    if not spawnedPeds[pedId] then
        return false, 'NPC not found'
    end

    local success = MySQL.update.await('UPDATE rde_pedmanager SET scenario = ? WHERE id = ?', {scenario, pedId})
    if success then
        spawnedPeds[pedId].scenario = scenario
        TriggerClientEvent('rde_peds:updatePedScenario', -1, pedId, scenario)
        print('^2[RDE | Peds]^7 Ped ' .. pedId .. ' scenario updated by ' .. GetPlayerName(source))
        return true
    end
    return false, 'Database Error'
end)

lib.callback.register('rde_peds:renamePed', function(source, pedId, name)
    if not isAdmin(source) then
        return false, 'Access Denied'
    end

    if not spawnedPeds[pedId] then
        return false, 'NPC not found'
    end

    local success = MySQL.update.await('UPDATE rde_pedmanager SET name = ? WHERE id = ?', {name, pedId})
    if success then
        spawnedPeds[pedId].name = name
        TriggerClientEvent('rde_peds:renamePed', -1, pedId, name)
        print('^2[RDE | Peds]^7 Ped ' .. pedId .. ' renamed by ' .. GetPlayerName(source))
        return true
    end
    return false, 'Database Error'
end)

lib.callback.register('rde_peds:setPedSpeech', function(source, pedId, speech)
    if not isAdmin(source) then
        return false, 'Access Denied'
    end

    if not spawnedPeds[pedId] then
        return false, 'NPC not found'
    end

    local success = MySQL.update.await('UPDATE rde_pedmanager SET speech = ? WHERE id = ?', {speech, pedId})
    if success then
        spawnedPeds[pedId].speech = speech
        TriggerClientEvent('rde_peds:setPedSpeech', -1, pedId, speech)
        print('^2[RDE | Peds]^7 Ped ' .. pedId .. ' speech set by ' .. GetPlayerName(source))
        return true
    end
    return false, 'Database Error'
end)

lib.callback.register('rde_peds:setPedHostileWhenAttacked', function(source, pedId, hostileWhenAttacked)
    if not isAdmin(source) then
        return false, 'Access Denied'
    end

    if not spawnedPeds[pedId] then
        return false, 'NPC not found'
    end

    local success = MySQL.update.await('UPDATE rde_pedmanager SET hostileWhenAttacked = ? WHERE id = ?', {hostileWhenAttacked, pedId})
    if success then
        spawnedPeds[pedId].hostileWhenAttacked = hostileWhenAttacked
        TriggerClientEvent('rde_peds:setPedHostileWhenAttacked', -1, pedId, hostileWhenAttacked)
        print('^2[RDE | Peds]^7 Ped ' .. pedId .. ' hostile setting updated by ' .. GetPlayerName(source))
        return true
    end
    return false, 'Database Error'
end)

lib.callback.register('rde_peds:getSpawnedPeds', function(source)
    return spawnedPeds
end)

-- Add server-side error handling
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print('^2[RDE | Ped Manager]^7 Resource started successfully')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print('^2[RDE | Peds]^7 Resource stopped')
end)
