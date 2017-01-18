--
-- CreatorTools
--
-- @author  TyKonKet
-- @date 17/01/2017

CTPanelGui = {}
local CTPanelGui_mt = Class(CTPanelGui, ScreenElement);

function CTPanelGui:new(target, custom_mt)
	if custom_mt == nil then
		custom_mt = CTPanelGui_mt;
	end
	local self = ScreenElement:new(target, custom_mt);
	self.returnScreenName = "";
	return self;
end

function CTPanelGui:onOpen()
	CTPanelGui:superClass().onOpen(self);
	FocusManager:setFocus(self.backButton);
end

function CTPanelGui:onClose()
	CTPanelGui:superClass().onClose(self);
end

function CTPanelGui:onClickBack()
	CTPanelGui:superClass().onClickBack(self);
end

function CTPanelGui:onClickOk()
	CTPanelGui:superClass().onClickOk(self);
	CreatorTools:setWalkingSpeed(self.playerSpeedElement:getState());
	CreatorTools:setHud(not self.hideHudElement:getIsChecked());
	self:onClickBack();
end

function CTPanelGui:setHelpBoxText(text)
	self.ingameMenuHelpBoxText:setText(text);
	self.ingameMenuHelpBox:setVisible(text ~= "");
end

function CTPanelGui:onFocusElement(element)
	if element.toolTip ~= nil then
		self:setHelpBoxText(element.toolTip);
	end
end

function CTPanelGui:onLeaveElement(element)
	self:setHelpBoxText("");
end

function CTPanelGui:onCreatePlayerSpeed(element)
	self.playerSpeedElement = element;
	local speeds = {};
	for i=1, CreatorTools.WALKING_SPEEDs_COUNT, 1 do
		 speeds[i] = "x" .. tostring(CreatorTools.WALKING_SPEEDS[i]);
	end
	element:setTexts(speeds);
end

function CTPanelGui:setSelectedPlayerSpeed(index)
	self.playerSpeedElement:setState(index, false);
end

function CTPanelGui:onCreateHideHud(element)
	self.hideHudElement = element;
end

function CTPanelGui:setHideHud(index)
	local i = 1
	if not index then
		i = 2;
	end
	self.hideHudElement:setState(i, false);
end