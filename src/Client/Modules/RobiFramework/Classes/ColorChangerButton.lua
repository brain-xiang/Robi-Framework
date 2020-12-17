-- Class Template
-- Legenderox
-- November 30, 2020



local Class = {}
Class.__index = Class


function Class.new()
	local self = setmetatable({}, Class)
	self.hovered = false

	self.activated = function(button, inputObject, clickCount, ...)
        objects = self.parent:getAllObjects()
        for i,object in pairs(objects) do
            object.element.BackgroundColor3 = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
        end
	end;

	return self
end


return Class