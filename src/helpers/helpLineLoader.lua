--
-- CreatorTools
--
-- @author TyKonKet
-- @date 14/02/2017
function loadHelpLine(xml, helpLineCategories, helpLineCategorySelectorElement, modDirectory)
    xml = loadXMLFile("customHelpLineViewContentXML", xml);
    local categoriesIndex = 0;
    while true do
        local categoryQuery = string.format("helpLines.helpLineCategory(%d)", categoriesIndex);
        if not hasXMLProperty(xml, categoryQuery) then
            break;
        end
        local category = {
            title = getXMLString(xml, string.format("%s#title", categoryQuery)),
            helpLines = {}
        };
        helpLineCategorySelectorElement:addText(g_i18n:getText(category.title));
        local helpLinesIndex = 0;
        while true do
            local helpLineQuery = string.format("%s.helpLine(%d)", categoryQuery, helpLinesIndex);
            if not hasXMLProperty(xml, helpLineQuery) then
                break;
            end
            local helpLine = {
                title = getXMLString(xml, string.format("%s#title", helpLineQuery)),
                items = {}
            };
            local itemsIndex = 0;
            while true do
                local itemQuery = string.format("%s.item(%d)", helpLineQuery, itemsIndex);
                if not hasXMLProperty(xml, itemQuery) then
                    break;
                end
                local itemType = getXMLString(xml, string.format("%s#type", itemQuery));
                local itemValue = getXMLString(xml, string.format("%s#value", itemQuery));
                if itemType == "image" then
                    itemValue = modDirectory .. itemValue;
                end
                if (itemType == "text" or itemType == "image") and itemValue ~= nil then
                    table.insert(helpLine.items, {
                        type = itemType,
                        value = itemValue,
                        heightScale = Utils.getNoNil(getXMLFloat(xml, string.format("%s#heightScale", itemQuery)), 1)
                    });
                end
                itemsIndex = itemsIndex + 1;
            end
            table.insert(category.helpLines, helpLine);
            helpLinesIndex = helpLinesIndex + 1;
        end
        table.insert(helpLineCategories, category);
        categoriesIndex = categoriesIndex + 1;
    end
    delete(xml);
end
