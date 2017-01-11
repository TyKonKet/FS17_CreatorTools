--
-- CreatorTools script
--
--
-- @author  TyKonKet
-- @date 11/01/2017

CreatorTools = {};
CreatorTools.name = "CreatorTools";
CreatorTools.debug = true;

function CreatorTools:print(txt)
    if CreatorTools.debug then
        print("[" .. self.name .. "] -> " .. txt);
    end
end

function CreatorTools:loadMap(name)    
    if self.debug then
        --addConsoleCommand("AAACreatorToolseTestCommand", "", "TestCommand", self);
    end
end

function CreatorTools:deleteMap()
end

function CreatorTools:keyEvent(unicode, sym, modifier, isDown)
end

function CreatorTools:mouseEvent(posX, posY, isDown, isUp, button)
end

function CreatorTools:update(dt)
end

function CreatorTools:draw()
end

addModEventListener(CreatorTools)