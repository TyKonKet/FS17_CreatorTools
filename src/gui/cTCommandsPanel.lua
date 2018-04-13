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
    for i = 1, FruitUtil.NUM_FRUITTYPES do
        fruits[i] = FillUtil.fillTypeIndexToDesc[FruitUtil.fruitTypeToFillType[i]].nameI18N
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
    fertilizerStates[1] = "30%"
    fertilizerStates[2] = "60%"
    fertilizerStates[3] = "90%"
    self.setFieldFruitFertilizerState:setTexts(fertilizerStates)
end

function CTCommandsPanel:SetFieldFruit()
    local field = self.setFieldFruitField:getState()
    local fruit = FruitUtil.fruitIndexToDesc[self.setFieldFruitFruit:getState()].name
    local growthState = self.setFieldFruitGrowthState:getState()
    local fertilizerState = self.setFieldFruitFertilizerState:getState()
    local ploughingState = 0
    if self.setFieldFruitPloughingState:getIsChecked() then
        ploughingState = 1
    end
    local buyField = self.setFieldFruitBuyField:getIsChecked()
    print(("gsSetFieldFruit %s %s %s %s %s %s"):format(field, fruit, growthState, fertilizerState, ploughingState, buyField))
    g_currentMission:consoleCommandSetFieldFruit(field, fruit, growthState, fertilizerState, ploughingState, buyField)
end

function CTCommandsPanel:onCreatePageSetFieldGround(element)
    CTCommandsPanel.PAGE_SET_FIELD_GROUND = self.pagingElement:getPageIdByElement(element)
    self.commands[CTCommandsPanel.PAGE_SET_FIELD_GROUND] = self.SetFieldGround
end

function CTCommandsPanel:SetFieldGround()
    print("CTCommandsPanel:SetFieldGround()")
end
