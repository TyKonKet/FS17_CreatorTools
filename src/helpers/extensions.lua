--
-- CreatorTools
--
-- @author  TyKonKet
-- @date 11/01/2017

CreatorToolsExtensions = {};

function CreatorToolsExtensions:load()
    g_currentMission.setAllowsHudDisplay = CreatorToolsExtensions.setAllowsHudDisplay;
    if g_currentMission.backup == nil then
        g_currentMission.backup = {};
    end
end

function CreatorToolsExtensions:setAllowsHudDisplay(v)
    g_currentMission.showHudEnv = v;
    g_currentMission.showWeatherForecast = v;
    g_currentMission.renderTime = v;
    g_currentMission.showVehicleInfo = v;
    if v then
        g_gameSettings:setValue("showHelpMenu", CreatorTools.backup.showHelpBox);
    else
        CreatorTools.backup.showHelpBox = g_gameSettings:getValue("showHelpMenu");
        g_gameSettings:setValue("showHelpMenu", false);
    end  
    g_currentMission.showHudMissionBase = v;
    g_currentMission.showHudMissionBaseOriginal = v;
    g_currentMission.showVehicleSchema = v;
end

-- real extension methods
InputBinding.getKeyNamesOfDigitalAction = function (actionIndex)
	local actionData = InputBinding.actions[actionIndex];
	if actionData.keys1 then
		return InputBinding.getKeyNames(actionData.keys1);
	elseif actionData.keys2 then
		return InputBinding.getKeyNames(actionData.keys2);
	else
		return "";
	end
end

 function Utils.getTimeScaleIndex(timeScale)
    if 15360 <= timeScale then
		return 13;
	elseif 7680 <= timeScale then
		return 12;
    elseif 3840 <= timeScale then
		return 11;
    elseif 1920 <= timeScale then
		return 10;
    elseif 960 <= timeScale then
		return 9;
    elseif 480 <= timeScale then
		return 8;
    elseif 240 <= timeScale then
		return 7;
    elseif 120 <= timeScale then
		return 6;
	elseif 60 <= timeScale then
		return 5;
	elseif 30 <= timeScale then
		return 4;
	elseif 15 <= timeScale then
		return 3;
	elseif 5 <= timeScale then
		return 2;
	end
	return 1;
end

function Utils.getTimeScaleFromIndex(timeScaleIndex)
    if 13 <= timeScaleIndex then
		return 15360;
	elseif 12 <= timeScaleIndex then
		return 7680;
    elseif 11 <= timeScaleIndex then
		return 3840;
    elseif 10 <= timeScaleIndex then
		return 1920;
    elseif 9 <= timeScaleIndex then
		return 960;
    elseif 8 <= timeScaleIndex then
		return 480;
    elseif 7 <= timeScaleIndex then
		return 240;
    elseif 6<= timeScaleIndex then
		return 120;
	elseif 5 <= timeScaleIndex then
		return 60;
	elseif 4 <= timeScaleIndex then
		return 30;
	elseif 3 <= timeScaleIndex then
		return 15;
	elseif 2 <= timeScaleIndex then
		return 5;
	end
	return 1;
end

function Utils.getNumTimeScales()
		return 13;
end

function Utils.getTimeScaleString(timeScaleIndex)
	if timeScaleIndex == 1 then
		return g_i18n:getText("ui_realTime");
	else
		return string.format("%dx", Utils.getTimeScaleFromIndex(timeScaleIndex));
	end
end

function InputBinding.getKeysNamesOfDigitalAction(actionIndex)
	local actionData = InputBinding.actions[actionIndex];
	local k1 = nil;
	local k2 = nil;
	if actionData.keys1 then
		k1 = InputBinding.getKeyNames(actionData.keys1);
	end
	if actionData.keys2 then
		k2 = InputBinding.getKeyNames(actionData.keys2);
	end
	if k1 ~= nil and k2 ~= nil then
		return string.format("%s and %s", k1, k2);
	end
	if k1 ~= nil then
		return k1;
	end
	if k2 ~= nil then
		return k2;
	end
	return "";
end
