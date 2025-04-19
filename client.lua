local activePeds = {}
local pageSize = 7 -- Number of peds to show per page

local function spawnPed(pedId, data)
    if activePeds[pedId] then return end

    -- Debug print to log the model ID being requested
    print('^2[RDE | Peds]^7 Requesting model: ' .. data.model)

    -- Check if the model ID is valid
    if not IsModelValid(data.model) then
        print('^1[RDE | Peds]^7 Error: Invalid model ID: ' .. data.model .. '. Using default model.')
        data.model = 'a_m_y_business_02' -- Fallback to a standard model
    end

    lib.requestModel(data.model)

    local ped = CreatePed(4, data.model, data.coords.x, data.coords.y, data.coords.z - 1.0, data.heading, false, true)
    SetEntityInvincible(ped, data.invincible or true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    if data.type == 'guard' then
        local weapon = Config.GuardWeapons[math.random(#Config.GuardWeapons)].value
        GiveWeaponToPed(ped, weapon, 999, false, true)
        SetPedCombatAttributes(ped, 46, true)
        SetPedFleeAttributes(ped, 0, false)
        TaskGuardCurrentPosition(ped, 5.0, 5.0, true)
    else
        FreezeEntityPosition(ped, true)
        if data.scenario then
            TaskStartScenarioInPlace(ped, data.scenario, 0, true)
        end
    end

    -- Make the ped react to attacks
    SetPedCombatAttributes(ped, 1, true) -- Allow ped to fight back
    SetPedCombatAttributes(ped, 46, true) -- Allow ped to use cover

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
                {label = 'Scenario', value = ped.data.scenario or 'None'}
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
                            default = true
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
                            name = input[5]
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

AddEventHandler('playerSpawned', function()
    loadAllPeds()
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        loadAllPeds()
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
    lib.callback('rde_peds:getSpawnedPeds', false, function(peds)
        if not peds then
            print('^1[RDE | Peds]^7 Error: No peds retrieved from the database.')
            return
        end

        for pedId, data in pairs(peds) do
            print('^2[RDE | Peds]^7 Loading ped ' .. pedId .. ' from database.')
            spawnPed(pedId, data)
        end
    end)
end
