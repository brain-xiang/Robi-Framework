-- Class Template
-- Legenderox
-- November 30, 2020



local Class = {}
Class.__index = Class

function Class.new(store)
    local self = setmetatable({}, Class)
    self.parent = nil
  
    self.storeChangedFunctions = {
        [store] = function(newState, oldState) 
            
        end
    }

    self.visibleChanged = {
		[true] = function(button, ...)
			
		end;
		
		[false] = function(button, ...)
			
		end;
	};

	return self
end

return Class