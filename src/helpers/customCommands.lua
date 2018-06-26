--
-- CreatorTools
--
-- @author TyKonKet
-- @date 18/04/2018

CreatorToolsCustomCommands = {}

function CreatorToolsCustomCommands:registerCommands()
    if not g_currentMission.missionDynamicInfo.isMultiplayer then
        addConsoleCommand("ctReloadVehicle", "Reloads a whole vehicle", "consoleCommandReloadVehicle", g_currentMission)
    end
    addConsoleCommand("ctChangeLanguage", "Changes the game language", "consoleCommandChangeLanguage")
    addConsoleCommand("ctReloadCurrentGui", "Reloads the gui", "consoleCommandReloadCurrentGui")
    addConsoleCommand("ctSetDebugRenderingMode", "Changes the rendering mode", "consoleCommandSetDebugRenderingMode")
    addConsoleCommand("ctShowVehicleDistance", "Shows the distance between vehicle and cam", "consoleCommandShowVehicleDistance", g_currentMission)
    addConsoleCommand("ctSuspendApp", "Suspends the game", "consoleCommandSuspendApp")
    addConsoleCommand("ctVerifyI18N", "Checks the I18N", "consoleCommandVerifyAll", g_i18n)
    addConsoleCommand("ctActivateCameraPath", "Activate camera path", "consoleActivateCameraPath", g_currentMission)
    if g_currentMission.husbandries["chicken"] ~= nil then
        addConsoleCommand("ctSpawnPickupObjects", "Spawn pickup objects", "consoleCommandSpawnPickupObjects", g_currentMission.husbandries["chicken"])
    end
    if g_currentMission:getIsServer() then
        addConsoleCommand("ctAddBale", "Adds a bale", "consoleCommandAddBale", g_currentMission)
        addConsoleCommand("ctBuyAllFields", "Buys all fields", "consoleCommandBuyAllFields", g_currentMission)
        addConsoleCommand("ctBuyField", "Buys a field", "consoleCommandBuyField", g_currentMission)
        addConsoleCommand("ctCheatMoney", "Add a lot of money", "consoleCommandCheatMoney", g_currentMission)
        addConsoleCommand("ctCheatSilo", "Add silo amount", "consoleCommandCheatSilo", g_currentMission)
        addConsoleCommand("ctDeleteAllVehicles", "Deletes all vehicles", "consoleCommandDeleteAllVehicles", g_currentMission)
        addConsoleCommand("ctExportStoreItems", "Exports storeItem data", "consoleCommandExportStoreItems", g_currentMission)
        addConsoleCommand("ctFillVehicle", "Fills the vehicle with given filltype", "consoleCommandFillVehicle", g_currentMission)
        addConsoleCommand("ctFillVehicleTimmiej93", "Fills the vehicle with given filltype", "consoleCommandFillVehicleTimmiej93", g_currentMission)
        addConsoleCommand("ctSetAnimals", "Sets the amount of given animals", "consoleCommandSetAnimals", g_currentMission)
        addConsoleCommand("ctSetDirtScale", "Sets a given dirt scale", "consoleCommandSetDirtScale", g_currentMission)
        addConsoleCommand("ctSetFuel", "Sets the vehicle fuel level", "consoleCommandSetFuel", g_currentMission)
        addConsoleCommand("ctSetOperatingTime", "Sets the vehicle operating time", "consoleCommandSetOperatingTime", g_currentMission)
        addConsoleCommand("ctShowTipCollisions", "Shows the collisions for tipping on the ground", "consoleCommandShowTipCollisions", g_currentMission)
        addConsoleCommand("ctStartBrandSale", "Starts a brand sale", "consoleStartBrandSale", g_currentMission)
        addConsoleCommand("ctStartGreatDemand", "Starts a great demand", "consoleStartGreatDemand", g_currentMission)
        addConsoleCommand("ctStartVehicleSale", "Starts a vehicle sale", "consoleStartVehicleSale", g_currentMission)
        addConsoleCommand("ctTakeVehicleScreenshotsFromInside", "Takes several screenshots of the selected vehicle from inside", "consoleCommandTakeScreenshotsFromInside", g_currentMission)
        addConsoleCommand("ctTakeVehicleScreenshotsFromOutside", "Takes several screenshots of the selected vehicle from outside", "consoleCommandTakeScreenshotsFromOutside", g_currentMission)
        addConsoleCommand("ctTeleport", "Teleports to given field or x/z-position", "consoleCommandTeleport", g_currentMission)
        addConsoleCommand("ctUpdateTipCollisions", "Updates the collisions for tipping on the ground around the current camera", "consoleCommandUpdateTipCollisions", g_currentMission)
    end
end

function CreatorToolsCustomCommands:removeCommands()
    removeConsoleCommand("ctAddBale")
    removeConsoleCommand("ctSpawnPickupObjects")
    removeConsoleCommand("ctActivateCameraPath")
    removeConsoleCommand("ctBuyAllFields")
    removeConsoleCommand("ctBuyField")
    removeConsoleCommand("ctChangeLanguage")
    removeConsoleCommand("ctCheatMoney")
    removeConsoleCommand("ctCheatSilo")
    removeConsoleCommand("ctDeleteAllVehicles")
    removeConsoleCommand("ctExportStoreItems")
    removeConsoleCommand("ctFillVehicle")
    removeConsoleCommand("ctFillVehicleTimmiej93")
    removeConsoleCommand("ctReloadCurrentGui")
    removeConsoleCommand("ctReloadVehicle")
    removeConsoleCommand("ctSetAnimals")
    removeConsoleCommand("ctSetDebugRenderingMode")
    removeConsoleCommand("ctSetDirtScale")
    removeConsoleCommand("ctSetFuel")
    removeConsoleCommand("ctSetOperatingTime")
    removeConsoleCommand("ctShowTipCollisions")
    removeConsoleCommand("ctShowVehicleDistance")
    removeConsoleCommand("ctStartBrandSale")
    removeConsoleCommand("ctStartGreatDemand")
    removeConsoleCommand("ctStartVehicleSale")
    removeConsoleCommand("ctSuspendApp")
    removeConsoleCommand("ctTakeVehicleScreenshotsFromInside")
    removeConsoleCommand("ctTakeVehicleScreenshotsFromOutside")
    removeConsoleCommand("ctTeleport")
    removeConsoleCommand("ctUpdateTipCollisions")
    removeConsoleCommand("ctVerifyI18N")
end

function FSBaseMission:consoleCommandSetAnimals(type, amount)
    local usage = "ctSetAnimals type(cow | pig | sheep) amount"
    local husbandry = self.husbandries[type]
    if type == nil or type == "" or husbandry == nil then
        return "Invalid type. " .. usage
    end
    amount = tonumber(amount)
    if amount == nil then
        return "Invalid amount. " .. usage
    end
    local oldAmount = husbandry.numAnimals[0]
    local difAmount = amount - oldAmount
    if difAmount > 0 then
        husbandry:addAnimals(difAmount, 0)
    else
        husbandry:removeAnimals(math.abs(difAmount), 0)
    end
    return string.format("Setted %s from %s to %s(%s)", type, oldAmount, amount, difAmount)
end

-- Function by Timmiej93
function FSBaseMission:consoleCommandFillVehicleTimmiej93(filltype, amount, force)
    local vehicle = self.controlledVehicle
    local fillImps = {}
    if (vehicle == nil) then
        return "You need to be in a fillable vehicle for this command to work!"
    else
        if (vehicle.fillUnits == nil) then
            for _, implement in pairs(vehicle.attachedImplements) do
                if implement.object ~= nil then
                    if (implement.object.fillUnits ~= nil) then
                        table.insert(fillImps, implement.object)
                    end
                end
            end
            if (#fillImps <= 0) then
                return "You need to be in a fillable vehicle for this command to work!"
            end
        end
    end
    local filltype = FillUtil.fillTypeNameToDesc[filltype]
    if filltype == nil or filltype == "" then
        local text = 'Invalid filltype "' .. tostring(filltype) .. '"\n'
        text = text .. "Usage: ctFillVehicleTimmiej93 filltypeName amount\n"
        text = text .. "\t\tWith filltypeName being any of the following:\n"
        for FTN, table in pairs(FillUtil.fillTypeNameToDesc) do
            text = text .. "\t\t\t\t- Filltype: " .. FTN .. " :: Idx: " .. table.index .. "\n"
        end
        return text
    else
        filltype = filltype.index
    end
    amount = tonumber(amount)
    if amount == nil then
        return 'Invalid amount: "' .. tostring(amount) .. '"'
    end
    if (force ~= nil) then
        if (not (force == "false" or force == "true")) then
            print("Force is of unknown type, ignoring")
            force = nil
        else
            force = (force == "true" and true or false)
        end
    end
    if (vehicle.setFillLevel ~= nil) then
        local yesno = (vehicle:allowFillType(filltype, false) and "yes" or "no")
        print("Accepted by vehicle: " .. yesno)
        vehicle:setFillLevel(amount, filltype, force)
    end
    for _, implement in pairs(fillImps) do
        if (implement.setFillLevel ~= nil) then
            local yesno = (implement:allowFillType(filltype, false) and "yes" or "no")
            print("Accepted by implement: " .. yesno)
            implement:setFillLevel(amount, filltype, force)
        end
    end
    return "Done"
end
