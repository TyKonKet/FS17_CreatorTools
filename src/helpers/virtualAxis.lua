--
-- CreatorTools
--
-- @author TyKonKet
-- @date 16/01/2017
VirtualAxis = {};
VirtualAxis_mt = Class(VirtualAxis);

function VirtualAxis:new(axis, onlyEvent, onlyIntegers)
    local self = {};
    setmetatable(self, VirtualAxis_mt);
    if type(axis) == "number" then
        self.axis = axis;
    else
        self.axis = InputBinding[axis];
    end
    self.changeMultiplier = 1;
    self.changeCurrentDelay = 0;
    self.changeDelay = 250;
    self.eventReset = true;
    self.onlyIntegers = onlyIntegers
    self.onlyEvent = onlyEvent;
    return self;
end

function VirtualAxis.getVirtualAxis(self, dt)
    if self.onlyIntegers then
        local inputW = InputBinding.getDigitalInputAxis(self.axis);
        if InputBinding.isAxisZero(inputW) then
            inputW = InputBinding.getAnalogInputAxis(self.axis);
        end
        if inputW ~= 0 then
            self.changeCurrentDelay = self.changeCurrentDelay - dt * self.changeMultiplier;
            self.changeMultiplier = math.min(self.changeMultiplier + dt * 0.03, 10);
            if self.changeCurrentDelay <= 0 then
                if inputW > g_analogStickVTolerance then
                    self.changeCurrentDelay = self.changeDelay;
                    return 1;
                elseif inputW < -g_analogStickVTolerance then
                    self.changeCurrentDelay = self.changeDelay;
                    return -1;
                end
            end
        else
            self.changeMultiplier = 1;
            self.changeCurrentDelay = 0;
        end
    elseif self.onlyEvent then
        local inputW = InputBinding.getDigitalInputAxis(self.axis);
        if InputBinding.isAxisZero(inputW) then
            inputW = InputBinding.getAnalogInputAxis(self.axis);
        end
        if inputW ~= 0 then
            if self.eventReset then
                if inputW > g_analogStickVTolerance then
                    self.eventReset = false;
                    return 1;
                elseif inputW < -g_analogStickVTolerance then
                    self.eventReset = false;
                    return -1;
                end
            end
        else
            self.eventReset = true;
        end
    else
        local inputW = InputBinding.getDigitalInputAxis(self.axis);
        if InputBinding.isAxisZero(inputW) then
            inputW = InputBinding.getAnalogInputAxis(self.axis);
            if inputW ~= 0 then
                self.changeCurrentDelay = self.changeCurrentDelay - dt * 10;
                if self.changeCurrentDelay <= 0 then
                    if inputW > (g_analogStickVTolerance / 2) or inputW < -(g_analogStickVTolerance / 2) then
                        self.changeCurrentDelay = self.changeDelay;
                        return inputW;
                    end
                end
            else
                self.changeMultiplier = 1;
                self.changeCurrentDelay = 0;
            end
        else
            if inputW ~= 0 then
                self.changeCurrentDelay = self.changeCurrentDelay - dt * self.changeMultiplier;
                self.changeMultiplier = math.min(self.changeMultiplier + dt * 0.03, 10);
                if self.changeCurrentDelay <= 0 then
                    if inputW > g_analogStickVTolerance then
                        self.changeCurrentDelay = self.changeDelay;
                        return 1;
                    elseif inputW < -g_analogStickVTolerance then
                        self.changeCurrentDelay = self.changeDelay;
                        return -1;
                    end
                end
            else
                self.changeMultiplier = 1;
                self.changeCurrentDelay = 0;
            end
        end
    end
    return nil;
end
