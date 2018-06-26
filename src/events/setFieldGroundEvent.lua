--
-- CreatorTools
--
-- @author TyKonKet
-- @date 26/06/2018

SetFieldGroundEvent = {}
SetFieldGroundEvent_mt = Class(SetFieldGroundEvent, Event)

InitEventClass(SetFieldGroundEvent, "SetFieldGroundEvent")

function SetFieldGroundEvent:emptyNew()
    local self = Event:new(SetFieldGroundEvent_mt)
    return self
end

function SetFieldGroundEvent:new(field, ground, angle, fertilizerState, ploughingState, buyField)
    local self = SetFieldGroundEvent:emptyNew()
    self.field = field
    self.ground = ground
    self.angle = angle
    self.fertilizerState = fertilizerState
    self.ploughingState = ploughingState
    self.buyField = buyField
    return self
end

function SetFieldGroundEvent:writeStream(streamId, connection)
    streamWriteString(streamId, tostring(self.field))
    streamWriteString(streamId, tostring(self.ground))
    streamWriteString(streamId, tostring(self.angle))
    streamWriteString(streamId, tostring(self.fertilizerState))
    streamWriteString(streamId, tostring(self.ploughingState))
    streamWriteString(streamId, tostring(self.buyField))
end

function SetFieldGroundEvent:readStream(streamId, connection)
    self.field = streamReadString(streamId)
    self.ground = streamReadString(streamId)
    self.angle = streamReadString(streamId)
    self.fertilizerState = streamReadString(streamId)
    self.ploughingState = streamReadString(streamId)
    self.buyField = streamReadString(streamId)
    self:run(connection)
end

function SetFieldGroundEvent:run(connection)
    print(("gsSetFieldGround %s %s %s %s %s %s"):format(self.field, self.ground, self.angle, self.fertilizerState, self.ploughingState, self.buyField))
    print(g_currentMission:consoleCommandSetFieldGround(self.field, self.ground, self.angle, self.fertilizerState, self.ploughingState, self.buyField))
end

function SetFieldGroundEvent.send(field, ground, angle, fertilizerState, ploughingState, buyField)
    g_client:getServerConnection():sendEvent(SetFieldGroundEvent:new(field, ground, angle, fertilizerState, ploughingState, buyField))
end
