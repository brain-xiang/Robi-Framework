-- Class Template
-- Legenderox
-- November 30, 2020



local Class = {}
Class.__index = Class

function Class.new(Store)
	local self = setmetatable({}, Class)
    self.store = Store

    self.changed = function(Label, newState, oldState)
        local oldText = oldState.LabelTexts[Label.Name] or 0
        local newText = newState.LabelTexts[Label.Name]

        if oldText ~= newText then
            Class:uppdateLabelText(Label, newText)
        end
    end

	return self
end

function Class:uppdateLabelText(Label, newText)
    Label.Text = newText
end

return Class