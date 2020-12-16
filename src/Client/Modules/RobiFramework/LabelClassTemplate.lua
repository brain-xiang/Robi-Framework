-- Class Template
-- Legenderox
-- November 30, 2020



local Class = {}
Class.__index = Class

function Class.new(store)
	local self = setmetatable({}, Class)
    self.store = store

    self.changed = function(Label, newState, oldState)
        
    end

	return self
end

return Class