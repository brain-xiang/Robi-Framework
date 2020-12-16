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
	
	self.hoverChanged = {
		[true] = function(button, ...)
			self.hovered = true
		end;
		
		[false] = function(button, ...)
			self.hovered = false
		end;
	};
	
	self.visibleChanged = {
		[true] = function(button, ...)
			
		end;
		
		[false] = function(button, ...)
			
		end;
	};

	return self
end


return Class