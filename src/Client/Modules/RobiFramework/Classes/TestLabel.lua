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
            local Label = self.parent.element
            local oldText = oldState.LabelTexts[Label.Name] or 0
            local newText = newState.LabelTexts[Label.Name]

            if oldText ~= newText then
                Class:uppdateLabelText(Label, newText)
            end
        end
    }

	return self
end

function Class:uppdateLabelText(Label, newText)
    Label.Text = newText
end

return Class