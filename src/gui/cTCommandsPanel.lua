--
-- CreatorTools
--
-- @author TyKonKet
-- @date 13/04/2018
CTCommandsPanel = {}

local CTCommandsPanel_mt = Class(CTCommandsPanel, ScreenElement)

function CTCommandsPanel:new(target)
    local self = ScreenElement:new(target, CTCommandsPanel_mt)
    self.returnScreenName = ""
    self.currentPageMappingIndex = 1
    self.currentPageId = 1
    self.commands = {}
    self.seedableFruits = {}
    for i = 1, FruitUtil.NUM_FRUITTYPES do
        local desc = FruitUtil.fruitIndexToDesc[i]
        if desc.allowsSeeding then
            table.insert(self.seedableFruits, {fruitIndex = i, nameI18N = FillUtil.fillTypeIndexToDesc[FruitUtil.fruitTypeToFillType[i]].nameI18N, name = desc.name})
        end
    end
    return self
end

function CTCommandsPanel:onOpen()
    CTCommandsPanel:superClass().onOpen(self)
    FocusManager:setFocus(self.activateButton)
    self:setPageStates()
    self:updatePageStates()
    self.pageSelector:setState(self.currentPageMappingIndex, true)
end

function CTCommandsPanel:onClose()
    CTCommandsPanel:superClass().onClose(self)
end

function CTCommandsPanel:onClickBack()
    CTCommandsPanel:superClass().onClickBack(self)
end

function CTCommandsPanel:onClickActivate()
    self.commands[self.pagingElement:getCurrentPageId()](self)
    CTCommandsPanel:superClass().onClickActivate(self)
end

function CTCommandsPanel:onFocusElement(element)
    if element.toolTip ~= nil then
        self:setHelpBoxText(element.toolTip)
    end
end

function CTCommandsPanel:onLeaveElement(element)
    self:setHelpBoxText("")
end

function CTCommandsPanel:setHelpBoxText(text)
    self.panelHelpBoxText:setText(text)
    self.panelHelpBox:setVisible(text ~= "")
end

function CTCommandsPanel:onClickPageSelection(state)
    self.pagingElement:setPage(state)
end

function CTCommandsPanel:onPageChange(pageId, pageMappingIndex)
    self.currentPageId = pageId
    self.currentPageMappingIndex = pageMappingIndex
    self:updatePageStates()
end

function CTCommandsPanel:updatePageStates()
    for index, state in pairs(self.pageStateBox.elements) do
        state.state = GuiOverlay.STATE_NORMAL
        if index == self.pageSelector:getState() then
            state.state = GuiOverlay.STATE_FOCUSED
        end
    end
end

function CTCommandsPanel:onPageUpdate()
    self:setPageStates()
end

function CTCommandsPanel:setPageStates()
    for i = #self.pageStateBox.elements, 1, -1 do
        self.pageStateBox.elements[i]:delete()
    end
    local texts = self.pagingElement:getPageTitles()
    for _, _ in pairs(texts) do
        self.pageStateElement:clone(self.pageStateBox)
    end
    self.pageSelector:setTexts(texts)
    self.pageStateBox:invalidateLayout()
    self.pageSelector:setDisabled(#texts == 1)
end

function CTCommandsPanel:onCreatePageSetFieldFruit(element)
    CTCommandsPanel.PAGE_SET_FIELD_FRUIT = self.pagingElement:getPageIdByElement(element)
    self.commands[CTCommandsPanel.PAGE_SET_FIELD_FRUIT] = self.SetFieldFruit
end

function CTCommandsPanel:onOpenSetFieldFruitField(element)
    local fields = {}
    for i, v in ipairs(g_currentMission.fieldDefinitionBase.fieldDefs) do
        fields[i] = v.fieldNumber
    end
    self.setFieldFruitField:setTexts(fields)
end

function CTCommandsPanel:onOpenSetFieldFruitFruit(element)
    local fruits = {}
    for i, v in ipairs(self.seedableFruits) do
        fruits[i] = v.nameI18N
    end
    self.setFieldFruitFruit:setTexts(fruits)
end

function CTCommandsPanel:onOpenSetFieldFruitGrowthState(element)
    local growthStates = {}
    for i = 1, 5 do
        growthStates[i] = g_i18n:getText(string.format("ui_CT_growthStates%s", i))
    end
    self.setFieldFruitGrowthState:setTexts(growthStates)
end

function CTCommandsPanel:onOpenSetFieldFruitFertilizerState(element)
    local fertilizerStates = {}
    fertilizerStates[1] = "0%"
    fertilizerStates[2] = "30%"
    fertilizerStates[3] = "60%"
    fertilizerStates[4] = "90%"
    self.setFieldFruitFertilizerState:setTexts(fertilizerStates)
end

function CTCommandsPanel:SetFieldFruit()
    local field = self.setFieldFruitField:getState()
    local fruit = self.seedableFruits[self.setFieldFruitFruit:getState()].name
    local growthState = self.setFieldFruitGrowthState:getState()
    local fertilizerState = self.setFieldFruitFertilizerState:getState() - 1
    local ploughingState = self.setFieldFruitPloughingState:getIsChecked() and 1 or 0
    local buyField = self.setFieldFruitBuyField:getIsChecked()
    if g_currentMission.isMasterUser or g_currentMission:getIsServer() then
        SetFieldFruitEvent.send(field, fruit, growthState, fertilizerState, ploughingState, buyField)
    end
end

function CTCommandsPanel:onCreatePageSetFieldGround(element)
    CTCommandsPanel.PAGE_SET_FIELD_GROUND = self.pagingElement:getPageIdByElement(element)
    self.commands[CTCommandsPanel.PAGE_SET_FIELD_GROUND] = self.SetFieldGround
end

function CTCommandsPanel:onOpenSetFieldGroundField(element)
    local fields = {}
    for i, v in ipairs(g_currentMission.fieldDefinitionBase.fieldDefs) do
        fields[i] = v.fieldNumber
    end
    self.setFieldGroundField:setTexts(fields)
end

function CTCommandsPanel:onOpenSetFieldGroundGround(element)
    local grounds = {}
    local groundStates = {"cultivator", "plough", "sowing", "sowing_width"}
    for i, v in ipairs(groundStates) do
        grounds[i] = g_i18n:getText(string.format("ui_CT_setFieldGroundStates_%s", v))
    end
    self.setFieldGroundGround:setTexts(grounds)
end

function CTCommandsPanel:onOpenSetFieldGroundAngle(element)
    local angles = {}
    for i = 1, g_currentMission.terrainDetailAngleMaxValue + 1 do
        angles[i] = tostring(i - 1)
    end
    self.setFieldGroudAngle:setTexts(angles)
end

function CTCommandsPanel:onOpenSetFieldGroundFertilizerState(element)
    local fertilizerStates = {}
    fertilizerStates[1] = "0%"
    fertilizerStates[2] = "30%"
    fertilizerStates[3] = "60%"
    fertilizerStates[4] = "90%"
    self.setFieldGroundFertilizerState:setTexts(fertilizerStates)
end

function CTCommandsPanel:SetFieldGround()
    local field = self.setFieldGroundField:getState()
    local groundStates = {"cultivator", "plough", "sowing", "sowing_width"}
    local ground = groundStates[self.setFieldGroundGround:getState()]
    local angle = self.setFieldGroudAngle:getState() - 1
    local fertilizerState = self.setFieldGroundFertilizerState:getState() - 1
    local ploughingState = self.setFieldGroundPloughingState:getIsChecked() and 1 or 0
    local buyField = self.setFieldGroundBuyField:getIsChecked()
    if g_currentMission.isMasterUser or g_currentMission:getIsServer() then
        SetFieldGroundEvent.send(field, ground, angle, fertilizerState, ploughingState, buyField)
    end
end
