--
-- CreatorTools script
--
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
        g_gameSettings:setValue("showHelpMenu", g_currentMission.backup.showHelpMenu);
    else
        g_currentMission.backup.showHelpMenu = g_gameSettings:getValue("showHelpMenu");
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