--
-- CreatorTools
--
-- @author  TyKonKet
-- @date 11/01/2017
CreatorTools = {};
CreatorTools.name = "CreatorTools";
CreatorTools.debug = false;
CreatorTools.dir = g_currentModDirectory;
CreatorTools.savegameFile = "creatorTools.xml";
CreatorTools.WALKING_SPEEDS = {};
CreatorTools.WALKING_SPEEDS[1] = 0.5;
CreatorTools.WALKING_SPEEDS[2] = 1;
CreatorTools.WALKING_SPEEDS[3] = 3;
CreatorTools.WALKING_SPEEDS[4] = 8;
CreatorTools.WALKING_SPEEDS[5] = 13;
CreatorTools.WALKING_SPEEDS[6] = 21;
CreatorTools.DEFAULT_WALKING_SPEED = 2;
CreatorTools.WALKING_SPEEDs_COUNT = 6;
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
    parseI18N();
    margeI18N();
    self.backup = {};
    self.target = {};
    self.hideCrosshair = true;
    self.hideHud = true;
    self.showHelpLine = true;
    self.backup.showHelpBox = true;
    self.walkingSpeed = CreatorTools.DEFAULT_WALKING_SPEED;
    self.walkingSpeedFadeEffect = FadeEffect:new({position = {x = 0.5, y = 0.085}, size = 0.038, shadow = true, shadowPosition = {x = 0.0025, y = 0.0035}, statesTime = {0.75, 1, 0.75}});
    self.axisInputWalkingSpeed = VirtualAxis:new("AXIS_CT_WALKING_SPEED", true);
    self.backup.fovy = tonumber(g_gameSettings:getValue("fovy"));
    self.target.fovyIntAlpha = 0;
    self.fovy = self.backup.fovy;
    self.target.fovy = self.fovy;
    self.backup.camy = 0.73;
    self.target.camyIntAlpha = 0;
    self.camy = self.backup.camy;
    self.target.camy = self.camy;
    self.backup.money = -1;
    self.axisInputFovy = VirtualAxis:new("AXIS_CT_FOVY");
    self.axisInputCamy = VirtualAxis:new("AXIS_CT_CAMY");
    self.showButtonsHelp = true;
    self.musclesMode = false;
    g_inGameMenu:onCreateTimeScale(g_inGameMenu.timeScaleElement);
    self.guis = {};
    self.guis["cTPanelGui"] = CTPanelGui:new();
    g_gui:loadGui(self.dir .. "cTPanelGui.xml", "CTPanelGui", self.guis.cTPanelGui);
    loadHelpLine(self.dir .. "helpLine.xml", g_inGameMenu.helpLineCategories, g_inGameMenu.helpLineCategorySelectorElement, self.dir);
end
g_mpLoadingScreen.loadFunction = Utils.prependedFunction(g_mpLoadingScreen.loadFunction, CreatorTools.initialize);

function CreatorTools:load(missionInfo, missionDynamicInfo, loadingScreen)
    self = CreatorTools;
    self:print("load()");
    CreatorToolsExtensions:load();
    g_currentMission.loadMapFinished = Utils.appendedFunction(g_currentMission.loadMapFinished, self.loadMapFinished);
    g_currentMission.onStartMission = Utils.appendedFunction(g_currentMission.onStartMission, self.afterLoad);
    g_currentMission.missionInfo.saveToXML = Utils.appendedFunction(g_currentMission.missionInfo.saveToXML, self.saveSavegame);
    self:setHelpBoxWidth(1.12);
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
    self:print("afterLoad()");
    self.backup.walkingSpeed = g_currentMission.player.walkingSpeed;
    self.backup.MAX_PICKABLE_OBJECT_MASS = Player.MAX_PICKABLE_OBJECT_MASS;
    self:toggleCrosshair();
    self:toggleHud();
    self:setWalkingSpeed(self.walkingSpeed);
    self:setFovy(self.fovy);
    self:setCamy(self.camy);
    self:setMusclesMode(self.musclesMode);
end

function CreatorTools:onStartMission()
    self = CreatorTools;
    self:print("onStartMission()");
    if self.showHelpLine then
        g_gui:showGui("InGameMenu");
        g_inGameMenu.pageSelector:setState(g_inGameMenu.pagingElement:getPageMappingIndex(InGameMenu.PAGE_HELP_LINE), true);
        g_inGameMenu.helpLineCategorySelectorElement:setState(1000, true);
        self.showHelpLine = false;
    end
end
g_mpLoadingScreen.buttonOkPC.onClickCallback = Utils.appendedFunction(g_mpLoadingScreen.buttonOkPC.onClickCallback, CreatorTools.onStartMission);

function CreatorTools:loadSavegame()
    self:print("loadSavegame()");
    if g_server ~= nil then
        local filePath = string.format("%ssavegame%d/%s", getUserProfileAppPath(), g_careerScreen.currentSavegame.savegameIndex, self.savegameFile);
        if fileExists(filePath) then
            local xml = loadXMLFile("creatorToolsSavegameXML", filePath, "creatorTools");
            self.hideHud = not Utils.getNoNil(getXMLBool(xml, "creatorTools.hud#hide"), self.hideHud);
            self.hideCrosshair = not Utils.getNoNil(getXMLBool(xml, "creatorTools.hud.crosshair#hide"), self.hideCrosshair);
            self.backup.showHelpBox = Utils.getNoNil(getXMLBool(xml, "creatorTools.hud.helpbox#show"), self.backup.showHelpBox);
            self.walkingSpeed = Utils.getNoNil(getXMLInt(xml, "creatorTools.player#walkingSpeed"), self.walkingSpeed);
            self.fovy = Utils.getNoNil(getXMLFloat(xml, "creatorTools.player.camera#fovy"), self.backup.fovy);
            self.camy = Utils.getNoNil(getXMLFloat(xml, "creatorTools.player.camera#y"), self.backup.camy);
            self.backup.money = Utils.getNoNil(getXMLInt(xml, "creatorTools.backup#money"), self.backup.money);
            self.showButtonsHelp = Utils.getNoNil(getXMLBool(xml, "creatorTools#showButtonsHelp"), self.showButtonsHelp);
            self.musclesMode = Utils.getNoNil(getXMLBool(xml, "creatorTools.player#musclesMode"), self.musclesMode);
            self.showHelpLine = Utils.getNoNil(getXMLBool(xml, "creatorTools.helpLine#show"), self.showHelpLine);
            delete(xml);
        end
    end
end

function CreatorTools:saveSavegame()
    self = CreatorTools;
    self:print("saveSavegame()");
    if g_server ~= nil then
        local filePath = string.format("%ssavegame%d/%s", getUserProfileAppPath(), g_careerScreen.currentSavegame.savegameIndex, self.savegameFile);
        local xml = createXMLFile("creatorToolsSavegameXML", filePath, "creatorTools");
        setXMLBool(xml, "creatorTools.hud#hide", self.hideHud);
        setXMLBool(xml, "creatorTools.hud.crosshair#hide", self.hideCrosshair);
        setXMLBool(xml, "creatorTools.hud.helpbox#show", self.backup.showHelpBox);
        setXMLInt(xml, "creatorTools.player#walkingSpeed", self.walkingSpeed);
        setXMLFloat(xml, "creatorTools.player.camera#fovy", self.fovy);
        setXMLFloat(xml, "creatorTools.player.camera#y", self.camy);
        setXMLInt(xml, "creatorTools.backup#money", self.backup.money);
        setXMLBool(xml, "creatorTools#showButtonsHelp", self.showButtonsHelp);
        setXMLBool(xml, "creatorTools.player#musclesMode", self.musclesMode);
        setXMLBool(xml, "creatorTools.helpLine#show", self.showHelpLine);
        saveXMLFile(xml);
        delete(xml);
    end
end

function CreatorTools:deleteMap()
    self:print("deleteMap()");
end

function CreatorTools:keyEvent(unicode, sym, modifier, isDown)
end

function CreatorTools:mouseEvent(posX, posY, isDown, isUp, button)
end

function CreatorTools:update(dt)
    self.walkingSpeedFadeEffect:update(dt);
    self.target.camyIntAlpha = self.target.camyIntAlpha + dt / 300;
    if self.target.camyIntAlpha > 1 then
        self.target.camyIntAlpha = 1;
    end
    g_currentMission.player.camY = Utils.lerp(g_currentMission.player.camY, self.target.camy, self.target.camyIntAlpha);
    self.target.fovyIntAlpha = self.target.fovyIntAlpha + dt / 300;
    if self.target.fovyIntAlpha > 1 then
        self.target.fovyIntAlpha = 1;
    end
    setFovy(g_currentMission.player.cameraNode, Utils.lerp(getFovy(g_currentMission.player.cameraNode), self.target.fovy, self.target.fovyIntAlpha));
    self:checkInputs(dt);
    self:drawHelpButtons();
end

function CreatorTools:draw()
    self.walkingSpeedFadeEffect:draw();
end

function CreatorTools:checkInputs(dt)
    -- check all inputs
    if InputBinding.hasEvent(InputBinding.CT_HUD_TOGGLE, true) then
        self:toggleHud();
        self:toggleCrosshair();
    end
    if InputBinding.hasEvent(InputBinding.CT_OPEN_PANEL, true) then
        if self.guis.cTPanelGui.isOpen then
            self.guis.cTPanelGui:onClickBack();
        else
            g_gui:showGui("CTPanelGui");
        end
    end
    if g_currentMission.controlledVehicle == nil then
        -- check only onfoot inputs
        if InputBinding.hasEvent(InputBinding.CT_FOVY_DEFAULT, true) or InputBinding.hasEvent(InputBinding.CT_FOVY_DEFAULT_2, true) then
            self:setFovy(self.backup.fovy);
        end
        local fovyAxis = self.axisInputFovy:getVirtualAxis(dt);
        if fovyAxis ~= nil then
            self:addFovy(fovyAxis * 0.5);
        end
        if InputBinding.hasEvent(InputBinding.CT_FOVY_UP, true) then
            self:addFovy(1 * 1.5);
        end
        if InputBinding.hasEvent(InputBinding.CT_FOVY_DOWN, true) then
            self:addFovy(-1 * 1.5);
        end
        if InputBinding.hasEvent(InputBinding.CT_CAMY_DEFAULT, true) or InputBinding.hasEvent(InputBinding.CT_CAMY_DEFAULT_2, true) then
            self:setCamy(self.backup.camy);
        end
        local camyAxis = self.axisInputCamy:getVirtualAxis(dt);
        if camyAxis ~= nil then
            self:addCamy(camyAxis * 0.25);
        end
        if InputBinding.hasEvent(InputBinding.CT_CAMY_UP, true) and not g_gui:getIsGuiVisible() then
            self:addCamy(1 * 0.75);
        end
        if InputBinding.hasEvent(InputBinding.CT_CAMY_DOWN, true) and not g_gui:getIsGuiVisible() then
            self:addCamy(-1 * 0.75);
        end
        if InputBinding.hasEvent(InputBinding.CT_WALKING_SPEED_DEFAULT, true) then
            self:setWalkingSpeed(self.DEFAULT_WALKING_SPEED);
        end
        local walkingSpeedAxis = self.axisInputWalkingSpeed:getVirtualAxis(dt);
        if walkingSpeedAxis ~= nil then
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

function CreatorTools:drawHelpButtons()
    -- show all button helps
    if self.hideHud then
        g_currentMission:addHelpButtonText(g_i18n:getText("CT_SHOW_HUD_HELP"), InputBinding.CT_HUD_TOGGLE, nil, GS_PRIO_HIGH);
    else
        g_currentMission:addHelpButtonText(g_i18n:getText("CT_HIDE_HUD_HELP"), InputBinding.CT_HUD_TOGGLE, nil, GS_PRIO_HIGH);
    end
    if g_currentMission.controlledVehicle == nil then
        -- show only onfoot button helps
        g_currentMission:addHelpButtonText(g_i18n:getText("input_CT_OPEN_PANEL"), InputBinding.CT_OPEN_PANEL, nil, GS_PRIO_NORMAL);
        --g_currentMission:addHelpButtonText(g_i18n:getText("AXIS_CT_FOVY_HELP"), InputBinding.AXIS_CT_FOVY, nil, GS_PRIO_LOW);
        --g_currentMission:addHelpButtonText(g_i18n:getText("input_CT_FOVY_DEFAULT"), InputBinding.CT_FOVY_DEFAULT, nil, GS_PRIO_LOW);
        --g_currentMission:addHelpButtonText(g_i18n:getText("AXIS_CT_CAMY_HELP"), InputBinding.AXIS_CT_CAMY, nil, GS_PRIO_LOW);
        --g_currentMission:addHelpButtonText(g_i18n:getText("input_CT_CAMY_DEFAULT"), InputBinding.CT_CAMY_DEFAULT, nil, GS_PRIO_LOW);
        --g_currentMission:addHelpButtonText(g_i18n:getText("AXIS_CT_WALKING_SPEED_HELP"), InputBinding.AXIS_CT_WALKING_SPEED, nil, GS_PRIO_LOW);
        --g_currentMission:addHelpButtonText(g_i18n:getText("input_CT_WALKING_SPEED_DEFAULT"), InputBinding.CT_WALKING_SPEED_DEFAULT, nil, GS_PRIO_LOW);
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
    g_currentMission.player.pickedUpObjectOverlay:setIsVisible(not self.hideCrosshair);
    return "hideCrosshair = " .. tostring(self.hideCrosshair);
end

function CreatorTools:toggleHud()
    self.hideHud = not self.hideHud;
    g_currentMission:setAllowsHudDisplay(not self.hideHud);
    self.guis.cTPanelGui:setHideHud(self.hideHud);
    return "hideHud = " .. tostring(self.hideHud);
end

function CreatorTools:setHud(hide)
    if (hide and not self.hideHud) or (not hide and self.hideHud) then
        self:toggleHud();
    end
end

function CreatorTools:setWalkingSpeed(speed)
    local ws = self.WALKING_SPEEDS[speed];
    if ws == nil then
        return "Speed out of range";
    end
    self.walkingSpeed = speed;
    g_currentMission.player.walkingSpeed = self.backup.walkingSpeed * ws;
    self.guis.cTPanelGui:setSelectedPlayerSpeed(self.walkingSpeed);
    self.walkingSpeedFadeEffect:play(string.format("x%s", ws));
    return ("walkingSpeed = %s(%s), player.walkingSpeed = %s"):format(speed, ws, g_currentMission.player.walkingSpeed);
end

function CreatorTools:setFovy(fovy)
    self.fovy = math.max(math.min(fovy, 120), 0.1);
    self.target.fovy = self.fovy;
    self.target.fovyIntAlpha = 0;
end

function CreatorTools:addFovy(fovy)
    self.fovy = math.max(math.min(self.fovy + fovy, 120), 0.1);
    self.target.fovy = self.fovy;
    self.target.fovyIntAlpha = 0;
end

function CreatorTools:setCamy(camy)
    self.camy = math.max(camy, -self.backup.camy * 3);
    self.target.camy = self.camy;
    self.target.camyIntAlpha = 0;
end

function CreatorTools:addCamy(camy)
    self.camy = math.max(camy + self.camy, -self.backup.camy * 3);
    self.target.camy = self.camy;
    self.target.camyIntAlpha = 0;
end

function CreatorTools:changeDirt(vehicle)
    if vehicle.CreatorTools == nil then
        vehicle.CreatorTools = {};
    end
    if vehicle.CreatorTools.dirt == nil or vehicle.CreatorTools.dirt == CreatorTools.DIRT_STEPS_COUNT then
        vehicle.CreatorTools.dirt = 0;
    end
    if vehicle.setDirtAmount ~= nil then
        vehicle.CreatorTools.dirt = vehicle.CreatorTools.dirt + 1;
        vehicle:setDirtAmount(CreatorTools.DIRT_STEPS[vehicle.CreatorTools.dirt], true);
    end
end

function CreatorTools:toggleCreativeMoney()
    if g_client ~= nil then
        if self.backup.money ~= -1 then
            self:addSharedMoney(-(g_currentMission.missionStats.money - self.backup.money));
            self.backup.money = -1;
        else
            self.backup.money = g_currentMission.missionStats.money;
            self:addSharedMoney(1000000000);
        end
    end
end

function CreatorTools:setCreativeMoney(cm)
    if (cm and self.backup.money == -1) or (not cm and self.backup.money ~= -1) then
        self:toggleCreativeMoney();
    end
end

function CreatorTools:addSharedMoney(money)
    if g_client ~= nil then
        if g_server ~= nil then
            g_currentMission:addSharedMoney(money, "other");
        else
            g_client:getServerConnection():sendEvent(CheatMoneyEvent:new(money));
        end
    end
end

function CreatorTools:setHelpBoxWidth(multiplier)
    g_currentMission.helpBoxContentOverlay.width = g_currentMission.helpBoxContentOverlay.width * multiplier;
    g_currentMission.helpBoxHeaderBgOverlay.width = g_currentMission.helpBoxHeaderBgOverlay.width * multiplier;
    g_currentMission.helpBoxTriggerOverlay.width = g_currentMission.helpBoxTriggerOverlay.width * multiplier;
    g_currentMission.helpBoxSeparatorOverlay.width = g_currentMission.helpBoxSeparatorOverlay.width * multiplier;
    g_currentMission.helpBoxTextPos2X = g_currentMission.helpBoxTextPos2X * multiplier;
end

function CreatorTools:setMusclesMode(enabled)
    self.musclesMode = enabled;
    if enabled then
        self.backup.MAX_PICKABLE_OBJECT_MASS = Player.MAX_PICKABLE_OBJECT_MASS;
        Player.MAX_PICKABLE_OBJECT_MASS = self.backup.MAX_PICKABLE_OBJECT_MASS * 1000;
    else
        Player.MAX_PICKABLE_OBJECT_MASS = self.backup.MAX_PICKABLE_OBJECT_MASS;
    end
end

addModEventListener(CreatorTools)
