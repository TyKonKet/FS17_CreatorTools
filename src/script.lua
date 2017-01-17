--
-- CreatorTools script
--
--
-- @author  TyKonKet
-- @date 11/01/2017

CreatorTools = {};
CreatorTools.name = "CreatorTools";
CreatorTools.debug = true;
CreatorTools.savegameFile = "creatorTools.xml";
CreatorTools.WALKING_SPEEDS = {};
CreatorTools.WALKING_SPEEDS[1] = 0.5;
CreatorTools.WALKING_SPEEDS[2] = 1;
CreatorTools.WALKING_SPEEDS[3] = 3;
CreatorTools.WALKING_SPEEDS[4] = 8;
CreatorTools.WALKING_SPEEDS[5] = 13;
CreatorTools.WALKING_SPEEDS[6] = 21;
CreatorTools.DEFAULT_WALKING_SPEED = 2;
CreatorTools.DIRT_STEPS = {};
CreatorTools.DIRT_STEPS[1] = 0;
CreatorTools.DIRT_STEPS[2] = 0.25;
CreatorTools.DIRT_STEPS[3] = 0.5;
CreatorTools.DIRT_STEPS[4] = 0.75;
CreatorTools.DIRT_STEPS[5] = 1;
CreatorTools.DIRT_STEPS_COUNT = 5;

function CreatorTools:print(txt1, txt2, txt3, txt4, txt5, txt6, txt7, txt8, txt9)
    if self.debug then
        local args = {txt1, txt2, txt3, txt4, txt5, txt6, txt7, txt8, txt9};
        for i, v in ipairs(args) do
            if v then
                print("[" .. self.name .. "] -> " .. tostring(v));
            end
        end
    end
end

function CreatorTools:initialize(missionInfo, missionDynamicInfo, loadingScreen)
    self = CreatorTools;
    self:print("initialize()");
    self.backup = {};
    self.hideCrosshair = false;
    self.hideHud = false;
    self.walkingSpeed = 0;
    self.axisInputWalkingSpeed = VirtualAxis:new("AXIS_CT_WALKING_SPEED", true);
    self.backup.fovy = tonumber(g_gameSettings:getValue("fovy"));
    self.backup.camy = 0.73;
    self.axisInputFovy = VirtualAxis:new("AXIS_CT_FOVY");
    self.axisInputCamy = VirtualAxis:new("AXIS_CT_CAMY");
end
g_mpLoadingScreen.loadFunction = Utils.prependedFunction(g_mpLoadingScreen.loadFunction, CreatorTools.initialize);

function CreatorTools:load(missionInfo, missionDynamicInfo, loadingScreen)
    self = CreatorTools;
    self:print("load()");
    CreatorToolsExtensions:load();
    g_currentMission.loadMapFinished = Utils.appendedFunction(g_currentMission.loadMapFinished, self.loadMapFinished);
    g_currentMission.onStartMission = Utils.appendedFunction(g_currentMission.onStartMission, self.afterLoad);
    g_currentMission.missionInfo.saveToXML = Utils.appendedFunction(g_currentMission.missionInfo.saveToXML, self.saveSavegame);
end
g_mpLoadingScreen.loadFunction = Utils.appendedFunction(g_mpLoadingScreen.loadFunction, CreatorTools.load);

function CreatorTools:loadMap(name)
    self:print(("loadMap(name:%s)"):format(name));
    if self.debug then
        addConsoleCommand("AAACreatorToolseTestCommand", "", "TestCommand", self);
    end
    self:loadSavegame();
end

function CreatorTools:loadMapFinished()
    self = CreatorTools;
    self:print("loadMapFinished()");
end

function CreatorTools:afterLoad()
    self = CreatorTools;
    self:print("afterLoad");
    self.backup.walkingSpeed = g_currentMission.player.walkingSpeed;
    self.backup.pickedUpObjectWidth = g_currentMission.player.pickedUpObjectWidth;
    self.backup.pickedUpObjectHeight = g_currentMission.player.pickedUpObjectHeight;
    self:toggleCrosshair();
    self:toggleHud();
    self:setWalkingSpeed(self.walkingSpeed);
    self:setFovy(self.fovy);
    self:setCamy(self.camy);
end

function CreatorTools:loadSavegame()
    self:print("loadSavegame()");
    local filePath = string.format("%ssavegame%d/%s", getUserProfileAppPath(), g_careerScreen.currentSavegame.savegameIndex, self.savegameFile);
    if fileExists(filePath) then
        local xml = loadXMLFile("creatorToolsSavegameXML", filePath, "creatorTools");
        self.hideHud = not Utils.getNoNil(getXMLBool(xml, "creatorTools.hud#hide"), self.hideHud);
        self.hideCrosshair = not Utils.getNoNil(getXMLBool(xml, "creatorTools.hud.crosshair#hide"), self.hideCrosshair);
        self.walkingSpeed = Utils.getNoNil(getXMLInt(xml, "creatorTools.player#walkingSpeed"), self.walkingSpeed);
        self.fovy = Utils.getNoNil(getXMLFloat(xml, "creatorTools.player.camera#fovy"), self.backup.fovy);
        self.camy = Utils.getNoNil(getXMLFloat(xml, "creatorTools.player.camera#y"), self.backup.camy);
        delete(xml);
    end
end

function CreatorTools:saveSavegame()
    self = CreatorTools;
    self:print("saveSavegame()");
    local filePath = string.format("%ssavegame%d/%s", getUserProfileAppPath(), g_careerScreen.currentSavegame.savegameIndex, self.savegameFile);
    local xml = createXMLFile("creatorToolsSavegameXML", filePath, "creatorTools");
    setXMLBool(xml, "creatorTools.hud#hide", self.hideHud);
    setXMLBool(xml, "creatorTools.hud.crosshair#hide", self.hideCrosshair);
    setXMLInt(xml, "creatorTools.player#walkingSpeed", self.walkingSpeed);
    setXMLFloat(xml, "creatorTools.player.camera#fovy", self.fovy);
    setXMLFloat(xml, "creatorTools.player.camera#y", self.camy);
    saveXMLFile(xml);
    delete(xml);
end

function CreatorTools:deleteMap()
    self:print("deleteMap()");
end

function CreatorTools:keyEvent(unicode, sym, modifier, isDown)
end

function CreatorTools:mouseEvent(posX, posY, isDown, isUp, button)
end

function CreatorTools:update(dt)
    self:checkInputs(dt);
    self:drawHelpButtons(dt);
end

function CreatorTools:draw()
end

function CreatorTools:checkInputs(dt)
    -- check all inputs
    if InputBinding.hasEvent(InputBinding.CT_HUD_TOGGLE, true) then
        self:toggleHud();
        self:toggleCrosshair();
    end
    if g_currentMission.controlledVehicle == nil then
        -- check only onfoot inputs
        if InputBinding.hasEvent(InputBinding.CT_FOVY_DEFAULT, true) then
            self:setFovy(self.backup.fovy);
        end
        local fovyAxis = self.axisInputFovy:getVirtualAxis(dt);
        if fovyAxis ~= nil then
            self:addFovy(fovyAxis * 0.375);
        end
        if InputBinding.hasEvent(InputBinding.CT_CAMY_DEFAULT, true) then
            self:setCamy(self.backup.camy);
        end
        local camyAxis = self.axisInputCamy:getVirtualAxis(dt);
        if camyAxis ~= nil then
            self:addCamy(camyAxis * 0.075);
        end
        if InputBinding.hasEvent(InputBinding.CT_WALKING_SPEED_DEFAULT, true) then
            self:setWalkingSpeed(self.DEFAULT_WALKING_SPEED);
        end
        local walkingSpeedAxis = self.axisInputWalkingSpeed:getVirtualAxis(dt);
        if walkingSpeedAxis ~= nil then
            self:print(walkingSpeedAxis);
            local wp = self.walkingSpeed + walkingSpeedAxis;
            if self.WALKING_SPEEDS[wp] ~= nil then
                self:setWalkingSpeed(wp);
            end
        end
    else
        -- check only onvehicle inputs
        if InputBinding.hasEvent(InputBinding.CT_CHANGE_DIRT, true) then
             self:changeDirt(g_currentMission.controlledVehicle);
        end
    end
end

function CreatorTools:drawHelpButtons(dt)
    -- show all button helps
    if self.hideHud then
        g_currentMission:addHelpButtonText(g_i18n:getText("CT_SHOW_HUD_HELP"), InputBinding.CT_HUD_TOGGLE, nil, GS_PRIO_HIGH);
    else
        g_currentMission:addHelpButtonText(g_i18n:getText("CT_HIDE_HUD_HELP"), InputBinding.CT_HUD_TOGGLE, nil, GS_PRIO_HIGH);
    end
    if g_currentMission.controlledVehicle == nil then
        -- show only onfoot button helps
        g_currentMission:addHelpButtonText(g_i18n:getText("AXIS_CT_FOVY_HELP"), InputBinding.AXIS_CT_FOVY, nil, GS_PRIO_NORMAL);
        g_currentMission:addHelpButtonText(g_i18n:getText("input_CT_FOVY_DEFAULT"), InputBinding.CT_FOVY_DEFAULT, nil,  GS_PRIO_LOW);
        g_currentMission:addHelpButtonText(g_i18n:getText("AXIS_CT_CAMY_HELP"), InputBinding.AXIS_CT_CAMY, nil, GS_PRIO_NORMAL);
        g_currentMission:addHelpButtonText(g_i18n:getText("input_CT_CAMY_DEFAULT"), InputBinding.CT_CAMY_DEFAULT, nil,  GS_PRIO_LOW);
        --g_currentMission:addExtraPrintText(g_i18n:getText("CT_WALKING_SPEED_HELP"):format(InputBinding.getKeyNamesOfDigitalAction(InputBinding.CT_WALKING_SPEED_DOWN), InputBinding.getKeyNamesOfDigitalAction(InputBinding.CT_WALKING_SPEED_DEFAULT), InputBinding.getKeyNamesOfDigitalAction(InputBinding.CT_WALKING_SPEED_UP)));
        g_currentMission:addHelpButtonText(g_i18n:getText("AXIS_CT_WALKING_SPEED_HELP"), InputBinding.AXIS_CT_WALKING_SPEED, nil, GS_PRIO_NORMAL);
        g_currentMission:addHelpButtonText(g_i18n:getText("input_CT_WALKING_SPEED_DEFAULT"), InputBinding.CT_WALKING_SPEED_DEFAULT, nil,  GS_PRIO_LOW);
    else
        -- show only vehicle button helps
        g_currentMission:addHelpButtonText(g_i18n:getText("input_CT_CHANGE_DIRT"), InputBinding.CT_CHANGE_DIRT, nil, GS_PRIO_HIGH);     
    end
end

function CreatorTools:TestCommand(args)
    --return self:setWalkingSpeed(math.floor(tonumber(args)));
end

function CreatorTools:toggleCrosshair()
    self.hideCrosshair = not self.hideCrosshair;
    if self.hideCrosshair then
        -- save old values
        self.backup.pickedUpObjectWidth = g_currentMission.player.pickedUpObjectWidth;
        self.backup.pickedUpObjectHeight = g_currentMission.player.pickedUpObjectHeight;
        -- set new values
        g_currentMission.player.pickedUpObjectWidth = 0;
        g_currentMission.player.pickedUpObjectHeight = 0;
    else
        -- restore old values
        g_currentMission.player.pickedUpObjectWidth = self.backup.pickedUpObjectWidth;
        g_currentMission.player.pickedUpObjectHeight = self.backup.pickedUpObjectHeight;
    end
    return "hideCrosshair = " .. tostring(self.hideCrosshair);
end

function CreatorTools:toggleHud()
    self.hideHud = not self.hideHud;
    g_currentMission:setAllowsHudDisplay(not self.hideHud);
    return "hideHud = " .. tostring(self.hideHud);
end

function CreatorTools:setWalkingSpeed(speed)
    local ws = self.WALKING_SPEEDS[speed];
    if ws == nil then
        return "speed out of range";
    end
    self.walkingSpeed = speed;
    g_currentMission.player.walkingSpeed = self.backup.walkingSpeed * ws;
    return ("walkingSpeed = %s(%s), player.walkingSpeed = %s"):format(speed, ws, g_currentMission.player.walkingSpeed);
end

function CreatorTools:setFovy(fovy)
    self.fovy = math.max(math.min(fovy, 120), 0.1);
    setFovy(g_currentMission.player.cameraNode, self.fovy);
end

function CreatorTools:addFovy(fovy)
    self.fovy =  math.max(math.min(self.fovy + fovy, 120), 0.1);
    setFovy(g_currentMission.player.cameraNode, self.fovy);
end

function CreatorTools:setCamy(camy)
    self.camy = math.max(camy, -self.backup.camy * 3);
    g_currentMission.player.camY = camy;
end

function CreatorTools:addCamy(camy)
    self.camy = math.max(camy + self.camy, -self.backup.camy * 3);
    g_currentMission.player.camY = self.camy;
end

function CreatorTools:changeDirt(vehicle)
    if vehicle.CreatorTools == nil then
        vehicle.CreatorTools = {};
    end
    if vehicle.CreatorTools.dirt == nil or vehicle.CreatorTools.dirt == CreatorTools.DIRT_STEPS_COUNT then
        vehicle.CreatorTools.dirt = 0;
    end
    if vehicle.setDirtAmount ~= nil then
        vehicle.CreatorTools.dirt =  vehicle.CreatorTools.dirt + 1;
        vehicle:setDirtAmount(CreatorTools.DIRT_STEPS[vehicle.CreatorTools.dirt], true);
    end
end

addModEventListener(CreatorTools)