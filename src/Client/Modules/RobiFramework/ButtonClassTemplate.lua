-- Class Template
-- Legenderox
-- November 30, 2020



local Class = {}
Class.__index = Class


function Class.new()
	--[[
        injectedProperties: (properties cannot be accessed on init)
            self.parent = parent object constructed using this class

        Note: Remove unused functions to save memory
    ]]

	local self = setmetatable({}, Class)
	self.hovered = false
	self.parent = nil

	self.activated = function(button, inputObject, clickCount, ...)
		
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