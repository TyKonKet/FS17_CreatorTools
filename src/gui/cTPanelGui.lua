CTPanelGui = {}
local CTPanelGui_mt = Class(CTPanelGui, ScreenElement);

function CTPanelGui:new(target, custom_mt)
	if custom_mt == nil then
		custom_mt = CTPanelGui_mt;
	end
	local self = ScreenElement:new(target, custom_mt)
	return self;
end
