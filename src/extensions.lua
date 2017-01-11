--
-- CreatorTools script
--
--
-- @author  TyKonKet
-- @date 11/01/2017

CreatorToolsExtensions = {};

function CreatorToolsExtensions:load()
    g_currentMission.setAllowsGuiDisplay = CreatorToolsExtensions.setAllowsGuiDisplay;
end

function CreatorToolsExtensions:setAllowsGuiDisplay(v)
    g_currentMission.showHudEnv = v;
    g_currentMission.showWeatherForecast = v;
    g_currentMission.renderTime = v;
    g_currentMission.showVehicleInfo = v;
    g_currentMission.showHelpMenu = v;
    g_currentMission.showHudMissionBase = v;
    g_currentMission.showHudMissionBaseOriginal = v;
    g_currentMission.showVehicleSchema = v;

end

-- real extension methods