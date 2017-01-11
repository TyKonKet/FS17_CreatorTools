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
    self.hideCrosshair = false;
    self.hideHud = false;
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
    self:toggleCrosshair();
    self:toggleHud();
end

function CreatorTools:loadSavegame()
    self:print("loadSavegame()");
    local filePath = string.format("%ssavegame%d/%s", getUserProfileAppPath(), g_careerScreen.currentSavegame.savegameIndex, self.savegameFile);
    if fileExists(filePath) then
        local xml = loadXMLFile("creatorToolsSavegameXML", filePath, "creatorTools");
        self.hideHud = not Utils.getNoNil(getXMLBool(xml, "creatorTools.hud#hide"), false);
        self.hideCrosshair = not Utils.getNoNil(getXMLBool(xml, "creatorTools.hud.crosshair#hide"), false);
    end
end

function CreatorTools:saveSavegame()
    self = CreatorTools;
    self:print("saveSavegame()");
    local filePath = string.format("%ssavegame%d/%s", getUserProfileAppPath(), g_careerScreen.currentSavegame.savegameIndex, self.savegameFile);
    local xml = createXMLFile("creatorToolsSavegameXML", filePath, "creatorTools");
    setXMLBool(xml, "creatorTools.hud#hide", self.hideHud);
    setXMLBool(xml, "creatorTools.hud.crosshair#hide", self.hideCrosshair);
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
    self:checkInputs();
    self:drawHelpButtons();
end

function CreatorTools:draw()
end

function CreatorTools:checkInputs()
     if InputBinding.hasEvent(InputBinding.CT_TOGGLE_HUD, true) then
        self:toggleHud();
        self:toggleCrosshair();
    end
end

function CreatorTools:drawHelpButtons()
    -- show all button helps
    g_currentMission:addHelpButtonText(g_i18n:getText("input_CT_TOGGLE_HUD"), InputBinding.CT_TOGGLE_HUD);   
    if g_currentMission.currentVehicle == nil then
        -- show only onfoot button helps
        
    else
        -- show only vehicle button helps

    end
end

function CreatorTools:TestCommand()
    --return self:toggleHud() .. " " .. self:toggleCrosshair();
end

function CreatorTools:toggleCrosshair()
    self.hideCrosshair = not self.hideCrosshair;
    if self.hideCrosshair then
        -- save old values
        self.oldPickedUpObjectWidth = g_currentMission.player.pickedUpObjectWidth;
        self.oldPickedUpObjectHeight = g_currentMission.player.pickedUpObjectHeight;
        -- set new values
        g_currentMission.player.pickedUpObjectWidth = 0;
        g_currentMission.player.pickedUpObjectHeight = 0;
    else
        -- restore old values
        g_currentMission.player.pickedUpObjectWidth = self.oldPickedUpObjectWidth;
        g_currentMission.player.pickedUpObjectHeight = self.oldPickedUpObjectHeight;
    end
    return "hideCrosshair = " .. tostring(self.hideCrosshair);
end

function CreatorTools:toggleHud()
    self.hideHud = not self.hideHud;
    g_currentMission:setAllowsHudDisplay(not self.hideHud);
    return "hideHud = " .. tostring(self.hideHud);
end

addModEventListener(CreatorTools)