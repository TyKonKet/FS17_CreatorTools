--
-- CreatorTools
--
-- @author TyKonKet
-- @date 25/06/2018
GoldNuggets = {}
GoldNuggets.enabled = false

function CollectableGoldNuggets:new(name)
    setmetatable(GoldNuggets, CollectableGoldNuggets_mt)
    GoldNuggets.activateNuggetHotspots = CollectableGoldNuggets.activateNuggetHotspots
    GoldNuggets.deleteGoldNugget = CollectableGoldNuggets.deleteGoldNugget
    GoldNuggets.triggerCallback = CollectableGoldNuggets.triggerCallback
    GoldNuggets.me = name
    local num = getNumOfChildren(GoldNuggets.me)
    GoldNuggets.goldNuggets = {}
    for i = 0, num - 1 do
        local goldNuggetId = getChildAt(GoldNuggets.me, i)
        local goldNuggetTriggerId = getChildAt(goldNuggetId, 0)
        addTrigger(goldNuggetTriggerId, "triggerCallback", GoldNuggets)

        local width, height = getNormalizedScreenValues(10, 10)
        local goldNuggetHotspot = g_currentMission.ingameMap:createMapHotspot("goldNuggetHotspot", "", nil, getNormalizedUVs({8, 776, 240, 240}), {0.65, 0.5, 0.0, 1}, 0, 0, width, height, false, false, false, goldNuggetId, true, MapHotspot.CATEGORY_COLLECTABLE)
        goldNuggetHotspot.enabled = false

        local goldNugget = {goldNuggetTriggerId = goldNuggetTriggerId, goldNuggetId = goldNuggetId, goldNuggetHotspot = goldNuggetHotspot}
        table.insert(GoldNuggets.goldNuggets, goldNugget)
    end
    return GoldNuggets
end

function CollectableGoldNuggets:activateNuggetHotspots(new, enabled)
    if new then
        GoldNuggets.enabled = enabled
        for i, goldNugget in ipairs(self.goldNuggets) do
            if getVisibility(goldNugget.goldNuggetId) then
                goldNugget.goldNuggetHotspot.enabled = enabled
            end
        end
    end
end
