local ox = exports.ox_lib

local function isInZone()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    for _, loc in pairs(Config.Locations) do 
        if #(coords - loc.coords) <= loc.radius then
            return true
        end
    end
    return false
end

function openExtrasMenu()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        lib.notify({title = 'Mistake', description = 'You need to be in a Vehicle!', type = 'error'})
        return
    end
    
    if not isInZone() then
        lib.notify({title = 'Not available', description = 'You are not in the area to put Extras on', type = 'error'})
        return
    end
    
    local vehicle = GetVehiclePedIsIn(ped, false),

lib.registerMenu({
        id = 'extras_main_menu',
        title = 'Extras & Liverys',
        position = 'top-left',
        options = {
            {label = 'Manage Extras', icon = 'wrench', args = {'extras_sub'}},
            {label = 'Select Liverys', icon = 'palette', args = {'livery_sub'}},
        }
    }, function(selected, scrollIndex, args)
        if args[1] == 'extras_sub' then
            openExtrasSub(vehicle)
        elseif args[1] == 'livery_sub' then
            openLiverySub(vehicle)
        end
    end)

    lib.showMenu('extras_main_menu')
end

local function openExtrasSub(vehicle)
    if not DoesEntityExist(vehicle) then return end

    local options = {}
    for i = 0, 14 do
        if DoesExtraExist(vehicle, i) then
            local isOn = IsVehicleExtraTurnedOn(vehicle, i)
            table.insert(options, {
                label = ('Extra %s - %s'):format(i, isOn and '✅ on' or '❌ off'),
                args = { extraId = i }
            })
        end
    end

    if #options == 0 then
        table.insert(options, { label = 'No Extras available', disabled = true })
    end

    lib.registerMenu({
        id = 'extras_sub_menu',
        title = 'Extras',
        position = 'top-left',
        options = options
    }, function(selected, scrollIndex, args)
        if args.extraId ~= nil then
            local id = args.extraId
            local isOn = IsVehicleExtraTurnedOn(vehicle, id)
            SetVehicleExtra(vehicle, id, isOn and 1 or 0)

            lib.notify({
                title = 'Extras',
                description = 'Extra ' .. id .. (isOn and ' Inactive' or ' Active'),
                type = 'success'
            })

            openExtrasSub(vehicle)
        end
    end)

    lib.showMenu('extras_sub_menu')
end

local function openLiverySub(vehicle)
    if not DoesEntityExist(vehicle) then return end

    local options = {}
    local liveryCount = GetVehicleLiveryCount(vehicle)

    if liveryCount and liveryCount > 0 then
        local current = GetVehicleLivery(vehicle)
        for l = 0, liveryCount - 1 do
            table.insert(options, {
                label = ('Livery %s %s'):format(l, l == current and '✅' or ''),
                args = { liveryId = l, type = 'livery' }
            })
        end
    else
        local modCount = GetNumVehicleMods(vehicle, 48)
        if modCount and modCount > 0 then
            local current = GetVehicleMod(vehicle, 48)
            for l = 0, modCount - 1 do
                table.insert(options, {
                    label = ('Livery %s %s'):format(l, l == current and '✅' or ''),
                    args = { liveryId = l, type = 'mod' }
                })
            end
        end
    end

    if #options == 0 then
        table.insert(options, { label = 'No Liverys available', disabled = true })
    end

    lib.registerMenu({
        id = 'livery_sub_menu',
        title = 'Liverys',
        position = 'top-left',
        options = options
    }, function(selected, scrollIndex, args)
        if args.liveryId ~= nil then
            if args.type == 'mod' then
                SetVehicleMod(vehicle, 48, args.liveryId, false)
            else
                SetVehicleLivery(vehicle, args.liveryId)
            end

            lib.notify({
                title = 'Livery',
                description = 'Livery ' .. args.liveryId .. ' Selected',
                type = 'success'
            })

            openLiverySub(vehicle)
        end
    end)

    lib.showMenu('livery_sub_menu')
end

local function openMainMenu(vehicle)
    lib.registerMenu({
        id = 'vehicle_custom_menu',
        title = 'Vehicle menu',
        position = 'top-left',
        options = {
            { label = 'Extras', args = { action = 'extras' } },
            { label = 'Liverys', args = { action = 'liverys' } }
        }
    }, function(selected, scrollIndex, args)
        if args.action == 'extras' then
            openExtrasSub(vehicle)
        elseif args.action == 'liverys' then
            openLiverySub(vehicle)
        end
    end)

    lib.showMenu('vehicle_custom_menu')
end

RegisterCommand('open_custom_menu', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        openMainMenu(veh)
    else
        lib.notify({
            title = 'Notice',
            description = 'You are not sitting in a vehicle.',
            type = 'error'
        })
    end
end, false)

RegisterKeyMapping('open_custom_menu', 'Open Extra Menu', 'keyboard', 'Y')