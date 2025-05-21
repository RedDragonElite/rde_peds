local activePeds = {}
local pageSize = 7 -- Number of peds to show per page
local respawnInterval = 60000 -- 1 minute in milliseconds
local pedsLoaded = false -- Flag to prevent double loading

-- Function to spawn a ped
local function spawnPed(pedId, data)
    if activePeds[pedId] then
        print('^3[RDE | Peds]^7 Ped ' .. pedId .. ' already exists, not spawning duplicate')
        return
    end

    -- Debug print to log the model ID being requested
    print('^2[RDE | Peds]^7 Requesting model: ' .. data.model)

    -- Check if the model ID is valid
    if not IsModelValid(data.model) then
        print('^1[RDE | Peds]^7 Error: Invalid model ID: ' .. data.model .. '. Using default model.')
        data.model = 'a_m_y_business_02' -- Fallback to a standard model
    end

    lib.requestModel(data.model)

    local ped = CreatePed(4, data.model, data.coords.x, data.coords.y, data.coords.z - 1.0, data.heading, false, true)
    SetEntityInvincible(ped, data.invincible or false) -- Ensure the ped is not invincible if hostile
    SetBlockingOfNonTemporaryEvents(ped, true)
    
    if data.type == 'guard' then
        local weapon = Config.GuardWeapons[math.random(#Config.GuardWeapons)].value
        GiveWeaponToPed(ped, weapon, 999, false, true)
        SetPedCombatAttributes(ped, 46, true)
        SetPedFleeAttributes(ped, 0, false)
        TaskGuardCurrentPosition(ped, 5.0, 5.0, true)
    else
        FreezeEntityPosition(ped, false) -- Ensure the ped is not frozen
        if data.scenario then
            TaskStartScenarioInPlace(ped, data.scenario, 0, true)
        end
    end

    -- Make the ped react to attacks
    if data.hostileWhenAttacked then
        -- Create a unique relationship group for this ped
        local groupHash = GetHashKey("PED_GROUP_" .. pedId)
        AddRelationshipGroup("PED_GROUP_" .. pedId, groupHash)
        
        -- Set ped combat attributes for hostile behavior
        SetPedCombatAttributes(ped, 0, true) -- Can use cover
        SetPedCombatAttributes(ped, 1, true) -- Can use vehicles
        SetPedCombatAttributes(ped, 2, true) -- Can do drivebys
        SetPedCombatAttributes(ped, 3, true) -- Can leave vehicle
        SetPedCombatAttributes(ped, 5, true) -- Can fight armed peds when not armed
        SetPedCombatAttributes(ped, 46, true) -- Always fight
        SetPedCombatAttributes(ped, 1424, true) -- Can fight players
        SetPedCombatRange(ped, 2) -- Far combat range
        SetPedAsCop(ped, false)
        
        -- Prevent fleeing
        SetPedFleeAttributes(ped, 0, false)
        SetPedConfigFlag(ped, 281, true) -- Allow ped to be targeted
        SetPedConfigFlag(ped, 118, false) -- Do not allow ped to flee
        SetPedConfigFlag(ped, 137, false) -- Do not allow ped to flee
        
        -- Make ped hate players when attacked
        SetRelationshipBetweenGroups(5, groupHash, GetHashKey("PLAYER"))
        SetPedRelationshipGroupHash(ped, groupHash)
        
        print('^2[RDE | Peds]^7 Ped ' .. pedId .. ' set to attack when attacked')
    else
        SetPedCombatAttributes(ped, 0, false) -- Do not allow ped to fight back
        SetPedCombatAttributes(ped, 1, false) -- Do not allow ped to fight back
        SetPedCombatAttributes(ped, 2, false) -- Do not allow ped to fight back
        SetPedCombatAttributes(ped, 46, false) -- Do not allow ped to use cover
        SetPedFleeAttributes(ped, 0, true) -- Allow ped to flee
        SetPedConfigFlag(ped, 281, false) -- Do not allow ped to be targeted
        SetPedConfigFlag(ped, 118, true) -- Allow ped to flee
        SetPedConfigFlag(ped, 137, true) -- Allow ped to flee
    end

    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'interact_ped_' .. pedId,
            label = 'Interact with NPC',
            icon = 'fas fa-comments',
            distance = 2.0,
            onSelect = function()
                if data.speech then
                    lib.notify({
                        title = data.name or 'NPC',
                        description = data.speech,
                        type = 'info'
                    })
                else
                    lib.notify({
                        title = 'NPC Information',
                        description = 'ID: ' .. pedId .. '\nName: ' .. (data.name or 'Unnamed') .. '\nType: ' .. data.type,
                        type = 'info'
                    })
                end
            end
        }
    })

    activePeds[pedId] = {
        handle = ped,
        data = data
    }

    print('^2[RDE | Peds]^7 Ped ' .. pedId .. ' spawned successfully')
end

-- Function to get ped management options
local function getPedManagementOptions(pedId)
    return {
        {
            title = 'Set Position',
            description = 'Move NPC to your position',
            icon = 'location-dot',
            onSelect = function()
                local coords = GetEntityCoords(PlayerPedId())
                local heading = GetEntityHeading(PlayerPedId())
                lib.callback('rde_peds:updatePedPosition', false, function(success)
                    if success then
                        lib.notify({title = 'Success', description = 'Position updated', type = 'success'})
                    end
                end, pedId, coords, heading)
            end
        },
        {
            title = 'Change Scenario',
            description = 'Change NPC scenario',
            icon = 'person-walking',
            onSelect = function()
                local input = lib.inputDialog('Change Scenario', {
                    {
                        type = 'select',
                        label = 'New Scenario',
                        options = Config.Scenarios
                    }
                })
                if input then
                    lib.callback('rde_peds:updatePedScenario', false, function(success)
                        if success then
                            lib.notify({title = 'Success', description = 'Scenario updated', type = 'success'})
                        end
                    end, pedId, input[1])
                end
            end
        },
        {
            title = 'Rename NPC',
            description = 'Rename this NPC',
            icon = 'edit',
            onSelect = function()
                local input = lib.inputDialog('Rename NPC', {
                    {
                        type = 'input',
                        label = 'New Name',
                        required = true
                    }
                })
                if input then
                    lib.callback('rde_peds:renamePed', false, function(success)
                        if success then
                            lib.notify({title = 'Success', description = 'NPC renamed', type = 'success'})
                            showPedListMenu(currentPage) -- Refresh the list
                        end
                    end, pedId, input[1])
                end
            end
        },
        {
            title = 'Set Speech',
            description = 'Set what the NPC says',
            icon = 'comment',
            onSelect = function()
                local input = lib.inputDialog('Set Speech', {
                    {
                        type = 'input',
                        label = 'Speech',
                        required = true
                    }
                })
                if input then
                    lib.callback('rde_peds:setPedSpeech', false, function(success)
                        if success then
                            lib.notify({title = 'Success', description = 'NPC speech set', type = 'success'})
                        end
                    end, pedId, input[1])
                end
            end
        },
        {
            title = 'Set Hostile When Attacked',
            description = 'Set if the NPC becomes hostile when attacked',
            icon = 'exclamation-triangle',
            onSelect = function()
                local input = lib.inputDialog('Set Hostile When Attacked', {
                    {
                        type = 'checkbox',
                        label = 'Hostile When Attacked',
                        default = activePeds[pedId].data.hostileWhenAttacked or false
                    }
                })
                if input then
                    lib.callback('rde_peds:setPedHostileWhenAttacked', false, function(success)
                        if success then
                            lib.notify({title = 'Success', description = 'NPC hostile setting updated', type = 'success'})
                        end
                    end, pedId, input[1])
                end
            end
        },
        {
            title = 'Delete NPC',
            description = 'Remove this NPC',
            icon = 'trash',
            onSelect = function()
                lib.callback('rde_peds:deletePed', false, function(success)
                    if success then
                        lib.notify({title = 'Success', description = 'NPC deleted', type = 'success'})
                        showPedListMenu(currentPage) -- Refresh the list
                    end
                end, pedId)
            end
        }
    }
end

-- Global variable to keep track of current page
local currentPage = 1

-- Function to show the ped list menu with pagination
local function showPedListMenu(page)
    currentPage = page

    -- Convert activePeds to an array for easier pagination
    local pedArray = {}
    for pedId, ped in pairs(activePeds) do
        table.insert(pedArray, {
            id = pedId,
            ped = ped
        })
    end

    -- Sort the array by ped ID for consistent ordering
    table.sort(pedArray, function(a, b) return a.id < b.id end)

    -- Calculate pagination info
    local totalPeds = #pedArray
    local totalPages = math.ceil(totalPeds / pageSize)
    if totalPages == 0 then totalPages = 1 end

    -- Ensure current page is within bounds
    if currentPage > totalPages then currentPage = totalPages end
    if currentPage < 1 then currentPage = 1 end

    -- Calculate start and end index for the current page
    local startIndex = (currentPage - 1) * pageSize + 1
    local endIndex = math.min(startIndex + pageSize - 1, totalPeds)

    -- Create options for the current page
    local options = {}

    -- Add pagination info and controls
    table.insert(options, {
        title = 'Page ' .. currentPage .. ' of ' .. totalPages,
        description = 'Showing ' .. (#pedArray > 0 and (startIndex .. '-' .. endIndex) or '0') .. ' of ' .. totalPeds .. ' NPCs',
        disabled = true
    })

    -- Add navigation buttons
    local navigationOptions = {
        icon = 'arrow-left',
        title = 'Previous Page',
        disabled = currentPage <= 1,
        onSelect = function()
            showPedListMenu(currentPage - 1)
        end
    }
    table.insert(options, navigationOptions)

    navigationOptions = {
        icon = 'arrow-right',
        title = 'Next Page',
        disabled = currentPage >= totalPages,
        onSelect = function()
            showPedListMenu(currentPage + 1)
        end
    }
    table.insert(options, navigationOptions)

    -- Add NPC entries for the current page
    for i = startIndex, endIndex do
        local pedEntry = pedArray[i]
        local pedId = pedEntry.id
        local ped = pedEntry.ped

        table.insert(options, {
            title = 'NPC #' .. pedId .. ' - ' .. (ped.data.name or 'Unnamed'),
            description = 'Model: ' .. ped.data.model,
            metadata = {
                {label = 'Type', value = ped.data.type},
                {label = 'Scenario', value = ped.data.scenario or 'None'},
                {label = 'Hostile When Attacked', value = ped.data.hostileWhenAttacked and 'Yes' or 'No'}
            },
            onSelect = function()
                lib.registerContext({
                    id = 'manage_ped_' .. pedId,
                    title = 'Manage NPC #' .. pedId,
                    menu = 'ped_list_menu',
                    options = getPedManagementOptions(pedId)
                })
                lib.showContext('manage_ped_' .. pedId)
            end
        })
    end

    -- Add back button
    table.insert(options, {
        title = 'Back to Main Menu',
        icon = 'arrow-left',
        onSelect = function()
            lib.showContext('ped_admin_menu')
        end
    })

    lib.registerContext({
        id = 'ped_list_menu',
        title = 'NPC List',
        menu = 'ped_admin_menu',
        options = options
    })

    lib.showContext('ped_list_menu')
end

-- Function to open the admin menu
local function openAdminMenu()
    lib.registerContext({
        id = 'ped_admin_menu',
        title = 'NPC Manager',
        options = {
            {
                title = 'Create New NPC',
                description = 'Spawn a new NPC at your position',
                icon = 'plus',
                onSelect = function()
                    local coords = GetEntityCoords(PlayerPedId())
                    local heading = GetEntityHeading(PlayerPedId())

                    local input = lib.inputDialog('Create NPC', {
                        {
                            type = 'select',
                            label = 'Ped Model',
                            options = Config.PedModels,
                            required = true
                        },
                        {
                            type = 'select',
                            label = 'Type',
                            options = {
                                {label = 'Static', value = 'static'},
                                {label = 'Guard', value = 'guard'}
                            },
                            required = true
                        },
                        {
                            type = 'select',
                            label = 'Scenario',
                            options = Config.Scenarios,
                            required = false
                        },
                        {
                            type = 'checkbox',
                            label = 'Invincible',
                            default = false
                        },
                        {
                            type = 'checkbox',
                            label = 'Hostile When Attacked',
                            default = false
                        },
                        {
                            type = 'input',
                            label = 'Name',
                            required = true
                        }
                    })

                    if input then
                        local data = {
                            model = input[1],
                            coords = coords,
                            heading = heading,
                            type = input[2],
                            scenario = input[3],
                            invincible = input[4],
                            hostileWhenAttacked = input[5],
                            name = input[6]
                        }

                        lib.callback('rde_peds:spawnPed', false, function(pedId, error)
                            if pedId then
                                lib.notify({
                                    title = 'Success',
                                    description = 'NPC created successfully',
                                    type = 'success'
                                })
                            else
                                lib.notify({
                                    title = 'Error',
                                    description = error or 'Unknown error',
                                    type = 'error'
                                })
                            end
                        end, data)
                    end
                end
            },
            {
                title = 'Manage NPCs',
                description = 'Manage existing NPCs',
                icon = 'list',
                onSelect = function()
                    showPedListMenu(1) -- Start at page 1
                end
            },
            {
                title = 'Delete All NPCs',
                description = 'Remove all spawned NPCs',
                icon = 'trash',
                onSelect = function()
                    lib.registerContext({
                        id = 'confirm_delete_all_peds',
                        title = 'Confirm Delete All NPCs',
                        options = {
                            {
                                title = 'Yes',
                                description = 'Confirm deletion of all NPCs',
                                icon = 'check',
                                onSelect = function()
                                    lib.callback('rde_peds:deleteAllPeds', false, function(success)
                                        if success then
                                            lib.notify({title = 'Success',
                                                description = 'All NPCs deleted',
                                                type = 'success'
                                            })
                                        end
                                    end)
                                end
                            },
                            {
                                title = 'No',
                                description = 'Cancel deletion of all NPCs',
                                icon = 'times',
                                onSelect = function()
                                    lib.showContext('ped_admin_menu')
                                end
                            }
                        }
                    })
                    lib.showContext('confirm_delete_all_peds')
                end
            }
        }
    })
    lib.showContext('ped_admin_menu')
end

RegisterCommand('pedadmin', function()
    lib.callback('rde_peds:checkAdmin', false, function(isAdmin)
        if isAdmin then
            openAdminMenu()
        else
            lib.notify({
                title = 'Error',
                description = 'Access Denied',
                type = 'error'
            })
        end
    end)
end)

lib.addKeybind({
    name = 'openPedMenu',
    description = 'Open NPC Manager',
    defaultKey = 'F6',
    onReleased = function()
        lib.callback('rde_peds:checkAdmin', false, function(isAdmin)
            if isAdmin then
                openAdminMenu()
            end
        end)
    end
})

RegisterNetEvent('rde_peds:syncPed', function(pedId, data)
    print('^2[RDE | Peds]^7 Received syncPed event for ped ' .. pedId)
    spawnPed(pedId, data)
end)

RegisterNetEvent('rde_peds:deletePed', function(pedId)
    if not activePeds[pedId] then return end

    exports.ox_target:removeLocalEntity(activePeds[pedId].handle)
    DeleteEntity(activePeds[pedId].handle)
    activePeds[pedId] = nil

    print('^2[RDE | Peds]^7 Ped ' .. pedId .. ' deleted successfully')
end)

RegisterNetEvent('rde_peds:deleteAllPeds', function()
    for pedId, ped in pairs(activePeds) do
        exports.ox_target:removeLocalEntity(ped.handle)
        DeleteEntity(ped.handle)
    end
    activePeds = {}
    pedsLoaded = false  -- Reset the flag when all peds are deleted

    print('^2[RDE | Peds]^7 All peds deleted successfully')
end)

RegisterNetEvent('rde_peds:updatePedPosition', function(pedId, coords, heading)
    if not activePeds[pedId] then return end

    SetEntityCoords(activePeds[pedId].handle, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(activePeds[pedId].handle, heading)

    print('^2[RDE | Peds]^7 Ped ' .. pedId .. ' position updated successfully')
end)

RegisterNetEvent('rde_peds:updatePedScenario', function(pedId, scenario)
    if not activePeds[pedId] then return end

    ClearPedTasks(activePeds[pedId].handle)
    TaskStartScenarioInPlace(activePeds[pedId].handle, scenario, 0, true)

    print('^2[RDE | Peds]^7 Ped ' .. pedId .. ' scenario updated successfully')
end)

RegisterNetEvent('rde_peds:renamePed', function(pedId, name)
    if not activePeds[pedId] then return end

    activePeds[pedId].data.name = name

    print('^2[RDE | Peds]^7 Ped ' .. pedId .. ' renamed successfully')
end)

RegisterNetEvent('rde_peds:setPedSpeech', function(pedId, speech)
    if not activePeds[pedId] then return end

    activePeds[pedId].data.speech = speech

    print('^2[RDE | Peds]^7 Ped ' .. pedId .. ' speech set successfully')
end)

RegisterNetEvent('rde_peds:setPedHostileWhenAttacked', function(pedId, hostileWhenAttacked)
    if not activePeds[pedId] then return end

    activePeds[pedId].data.hostileWhenAttacked = hostileWhenAttacked

    -- Update the ped's combat attributes based on the new setting
    local ped = activePeds[pedId].handle
    
    if hostileWhenAttacked then
        -- Create a unique relationship group for this ped
        local groupHash = GetHashKey("PED_GROUP_" .. pedId)
        AddRelationshipGroup("PED_GROUP_" .. pedId, groupHash)
        
        -- Set ped combat attributes for hostile behavior
        SetPedCombatAttributes(ped, 0, true) -- Can use cover
        SetPedCombatAttributes(ped, 1, true) -- Can use vehicles
        SetPedCombatAttributes(ped, 2, true) -- Can do drivebys
        SetPedCombatAttributes(ped, 3, true) -- Can leave vehicle
        SetPedCombatAttributes(ped, 5, true) -- Can fight armed peds when not armed
        SetPedCombatAttributes(ped, 46, true) -- Always fight
        SetPedCombatAttributes(ped, 1424, true) -- Can fight players
        SetPedCombatRange(ped, 2) -- Far combat range
        SetPedAsCop(ped, false)
        
        -- Prevent fleeing
        SetPedFleeAttributes(ped, 0, false)
        SetPedConfigFlag(ped, 281, true) -- Allow ped to be targeted
        SetPedConfigFlag(ped, 118, false) -- Do not allow ped to flee
        SetPedConfigFlag(ped, 137, false) -- Do not allow ped to flee
        
        -- Make ped hate players when attacked
        SetRelationshipBetweenGroups(5, groupHash, GetHashKey("PLAYER"))
        SetPedRelationshipGroupHash(ped, groupHash)
    else
        SetPedCombatAttributes(ped, 0, false) -- Do not allow ped to fight back
        SetPedCombatAttributes(ped, 1, false) -- Do not allow ped to fight back
        SetPedCombatAttributes(ped, 2, false) -- Do not allow ped to fight back
        SetPedCombatAttributes(ped, 46, false) -- Do not allow ped to use cover
        SetPedFleeAttributes(ped, 0, true) -- Allow ped to flee
        SetPedConfigFlag(ped, 281, false) -- Do not allow ped to be targeted
        SetPedConfigFlag(ped, 118, true) -- Allow ped to flee
        SetPedConfigFlag(ped, 137, true) -- Allow ped to flee
    end

    print('^2[RDE | Peds]^7 Ped ' .. pedId .. ' hostile setting updated successfully')
end)

AddEventHandler('playerSpawned', function()
    Wait(2000) -- Wait a bit to ensure server sync
    if not pedsLoaded then
        loadAllPeds()
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(2000) -- Wait a bit to ensure server sync
        if not pedsLoaded then
            loadAllPeds()
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for pedId, ped in pairs(activePeds) do
            exports.ox_target:removeLocalEntity(ped.handle)
            DeleteEntity(ped.handle)
        end
    end
end)

function loadAllPeds()
    -- Prevent loading more than once
    if pedsLoaded then
        print('^3[RDE | Peds]^7 Peds already loaded, skipping duplicate load')
        return
    end

    -- Clear any existing peds first to prevent duplicates
    for pedId, ped in pairs(activePeds) do
        if DoesEntityExist(ped.handle) then
            exports.ox_target:removeLocalEntity(ped.handle)
            DeleteEntity(ped.handle)
        end
    end
    activePeds = {}

    -- Now load fresh from the database
    lib.callback('rde_peds:getSpawnedPeds', false, function(peds)
        if not peds then
            print('^1[RDE | Peds]^7 Error: No peds retrieved from the database.')
            return
        end

        for pedId, data in pairs(peds) do
            print('^2[RDE | Peds]^7 Loading ped ' .. pedId .. ' from database.')
            spawnPed(pedId, data)
        end
        
        pedsLoaded = true
        print('^2[RDE | Peds]^7 All peds loaded successfully')
    end)
end

-- Function to make peds respond to attacks
local function checkForAttacks()
    for pedId, pedData in pairs(activePeds) do
        local ped = pedData.handle
        
        if pedData.data.hostileWhenAttacked and DoesEntityExist(ped) and not IsEntityDead(ped) then
            -- Check if the ped was hit recently
            if HasEntityBeenDamagedByAnyPed(ped) then
                -- Find who hit the ped
                local players = GetActivePlayers()
                for _, player in ipairs(players) do
                    local playerPed = GetPlayerPed(player)
                    if HasEntityBeenDamagedByEntity(ped, playerPed, 1) then
                        -- Clear the damage flag so we don't trigger multiple times
                        ClearEntityLastDamageEntity(ped)
                        
                        -- Create a unique relationship group for this ped if not already done
                        local groupHash = GetHashKey("PED_GROUP_" .. pedId)
                        AddRelationshipGroup("PED_GROUP_" .. pedId, groupHash)
                        
                        -- Set relationship to hate the player
                        SetRelationshipBetweenGroups(5, groupHash, GetHashKey("PLAYER"))
                        SetPedRelationshipGroupHash(ped, groupHash)
                        
                        -- Make the ped attack the player
                        TaskCombatPed(ped, playerPed, 0, 16)
                        SetPedKeepTask(ped, true)
                        SetPedCombatMovement(ped, 3) -- Active combat movement
                        
                        print('^2[RDE | Peds]^7 Ped ' .. pedId .. ' is now attacking player who damaged it')
                    end
                end
            end
        end
    end
end

-- Coroutine to check for attacks and respawn dead peds
Citizen.CreateThread(function()
    while true do
        -- Check for attacks every 500ms
        checkForAttacks()
        Citizen.Wait(500)
    end
end)

-- Separate thread for respawning to avoid overloading the check thread
Citizen.CreateThread(function()
    while true do
        for pedId, pedData in pairs(activePeds) do
            if pedData.data.hostileWhenAttacked and DoesEntityExist(pedData.handle) and IsEntityDead(pedData.handle) then
                print('^2[RDE | Peds]^7 Ped ' .. pedId .. ' is dead. Respawning...')
                -- Remove the ped from activePeds before respawning
                local pedData = activePeds[pedId].data
                exports.ox_target:removeLocalEntity(activePeds[pedId].handle)
                DeleteEntity(activePeds[pedId].handle)
                activePeds[pedId] = nil
                
                -- Wait a moment before respawning
                Citizen.Wait(2000)
                spawnPed(pedId, pedData)
            end
        end
        Citizen.Wait(respawnInterval)
    end
end)