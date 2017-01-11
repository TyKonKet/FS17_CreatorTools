--
-- CreatorTools script
--
--
-- @author  TyKonKet
-- @date 11/01/2017

CreatorTools = {};
CreatorTools.name = "CreatorTools";
CreatorTools.debug = true;

function CreatorTools:print(txt)
    if CreatorTools.debug then
        print("[" .. self.name .. "] -> " .. txt);
    end
end

function CreatorTools:loadMap(name)    
    if self.debug then
        addConsoleCommand("AAACreatorToolseTestCommand", "", "TestCommand", self);
    end
    CreatorToolsExtensions:load();
end

function CreatorTools:deleteMap()
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