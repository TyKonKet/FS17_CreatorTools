--
-- CreatorTools
--
-- @author TyKonKet
-- @date 17/01/2017
CTPanelGui = {}
local CTPanelGui_mt = Class(CTPanelGui, ScreenElement)

function CTPanelGui:new(target, custom_mt)
    if custom_mt == nil then
        custom_mt = CTPanelGui_mt
    end
    local self = ScreenElement:new(target, custom_mt)
    self.returnScreenName = ""
    return self
end

function CTPanelGui:onOpen()
    CTPanelGui:superClass().onOpen(self)
    FocusManager:setFocus(self.backButton)
    self.hideHudElement:setIsChecked(not CreatorTools.hideHud)
    self.playerSpeedElement:setState(CreatorTools.walkingSpeed, false)
    self.creativeMoneyElement:setDisabled(not g_currentMission.isMasterUser and g_server == nil)
    self.creativeMoneyElement:setIsChecked(CreatorTools.backup.money ~= -1)
    self.showButtonsHelpElement:setIsChecked(CreatorTools.showButtonsHelp)
    self.musclesModeElement:setIsChecked(CreatorTools.musclesMode)
    self.showRealClockElement:setIsChecked(CreatorTools.showRealClock)
    self.showGoldNuggetsElement:setIsChecked(GoldNuggets.enabled)
    self.showScreenShotsModeElement:setIsChecked(CreatorTools.screenShotsMode)
    self.disableMouseWheelElement:setIsChecked(CreatorTools.disableMouseWheel)
    self.crosshairStateElement:setState(CreatorTools.crosshairState, false)
    self.disableCameraCollisionsElement:setIsChecked(not CreatorTools.disableCameraCollisions)
end

function CTPanelGui:onClose()
    CTPanelGui:superClass().onClose(self)
end

function CTPanelGui:onClickBack()
    CTPanelGui:superClass().onClickBack(self)
end

function CTPanelGui:onClickOk()
    CTPanelGui:superClass().onClickOk(self)
    CreatorTools:setHud(not self.hideHudElement:getIsChecked())
    CreatorTools:setWalkingSpeed(self.playerSpeedElement:getState())
    CreatorTools:setCreativeMoney(self.creativeMoneyElement:getIsChecked())
    CreatorTools.showButtonsHelp = self.showButtonsHelpElement:getIsChecked()
    CreatorTools:setMusclesMode(self.musclesModeElement:getIsChecked())
    CreatorTools.showRealClock = self.showRealClockElement:getIsChecked()
    if GoldNuggets.activateNuggetHotspots ~= nil then
        GoldNuggets:activateNuggetHotspots(true, self.showGoldNuggetsElement:getIsChecked())
    end
    CreatorTools:setScreenShotsMode(self.showScreenShotsModeElement:getIsChecked())
    CreatorTools.disableMouseWheel = self.disableMouseWheelElement:getIsChecked()
    CreatorTools:setCrosshairState(self.crosshairStateElement:getState())
    CreatorTools.disableCameraCollisions = not self.disableCameraCollisionsElement:getIsChecked()
    self:onClickBack()
end

function CTPanelGui:setHelpBoxText(text)
    self.ingameMenuHelpBoxText:setText(text)
    self.ingameMenuHelpBox:setVisible(text ~= "")
end

function CTPanelGui:onFocusElement(element)
    if element.toolTip ~= nil then
        self:setHelpBoxText(element.toolTip)
    end
end

function CTPanelGui:onLeaveElement(element)
    self:setHelpBoxText("")
end

function CTPanelGui:onCreateHideHud(element)
    self.hideHudElement = element
end

function CTPanelGui:onCreatePlayerSpeed(element)
    self.playerSpeedElement = element
    local speeds = {}
    for i = 1, CreatorTools.WALKING_SPEEDS_COUNT, 1 do
        speeds[i] = "x" .. tostring(CreatorTools.WALKING_SPEEDS[i])
    end
    element:setTexts(speeds)
end

function CTPanelGui:onCreateCreativeMoney(element)
    self.creativeMoneyElement = element
end

function CTPanelGui:onCreateShowButtonsHelp(element)
    self.showButtonsHelpElement = element
end

function CTPanelGui:onCreateMusclesMode(element)
    self.musclesModeElement = element
end

function CTPanelGui:onCreateShowRealClock(element)
    self.showRealClockElement = element
end

function CTPanelGui:onCreateShowGoldNuggets(element)
    self.showGoldNuggetsElement = element
end

function CTPanelGui:onCreateScreenShotsMode(element)
    self.showScreenShotsModeElement = element
end

function CTPanelGui:onCreateDisableMouseWheel(element)
    self.disableMouseWheelElement = element
end

function CTPanelGui:onCreateCrosshairState(element)
    self.crosshairStateElement = element
    element:setTexts({g_i18n:getText("ui_auto"), g_i18n:getText("ui_on"), g_i18n:getText("ui_off")})
end

function CTPanelGui:onCreateDisableCameraCollisions(element)
    self.disableCameraCollisionsElement = element
end
