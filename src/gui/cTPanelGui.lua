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
	self:onClickBack();
end

function CTPanelGui:setHelpBoxText (text)
	self.ingameMenuHelpBoxText:setText(text);
	self.ingameMenuHelpBox:setVisible(text ~= "");
end
