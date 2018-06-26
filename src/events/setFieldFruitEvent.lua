--
-- CreatorTools
--
-- @author TyKonKet
-- @date 26/06/2018

SetFieldFruitEvent = {}
SetFieldFruitEvent_mt = Class(SetFieldFruitEvent, Event)

InitEventClass(SetFieldFruitEvent, "SetFieldFruitEvent")

function SetFieldFruitEvent:emptyNew()
    local self = Event:new(SetFieldFruitEvent_mt)
    return self
end

function SetFieldFruitEvent:new(field, fruit, growthState, fertilizerState, ploughingState, buyField)
    local self = SetFieldFruitEvent:emptyNew()
    self.field = field
    self.fruit = fruit
    self.growthState = growthState
    self.fertilizerState = fertilizerState
    self.ploughingState = ploughingState
    self.buyField = buyField
    return self
end

function SetFieldFruitEvent:writeStream(streamId, connection)
    streamWriteString(streamId, tostring(self.field))
    streamWriteString(streamId, tostring(self.fruit))
    streamWriteString(streamId, tostring(self.growthState))
    streamWriteString(streamId, tostring(self.fertilizerState))
    streamWriteString(streamId, tostring(self.ploughingState))
    streamWriteString(streamId, tostring(self.buyField))
end

function SetFieldFruitEvent:readStream(streamId, connection)
    self.field = streamReadString(streamId)
    self.fruit = streamReadString(streamId)
    self.growthState = streamReadString(streamId)
    self.fertilizerState = streamReadString(streamId)
    self.ploughingState = streamReadString(streamId)
    self.buyField = streamReadString(streamId)
    self:run(connection)
end

function SetFieldFruitEvent:run(connection)
    print(("gsSetFieldFruit %s %s %s %s %s %s"):format(self.field, self.fruit, self.growthState, self.fertilizerState, self.ploughingState, self.buyField))
    print(g_currentMission:consoleCommandSetFieldFruit(self.field, self.fruit, self.growthState, self.fertilizerState, self.ploughingState, self.buyField))
end

function SetFieldFruitEvent.send(field, fruit, growthState, fertilizerState, ploughingState, buyField)
    g_client:getServerConnection():sendEvent(SetFieldFruitEvent:new(field, fruit, growthState, fertilizerState, ploughingState, buyField))
end
