-- Test Class
-- Legenderox
-- November 30, 2020



local Class = {}
Class.__index = Class

TweenService = game:GetService("TweenService")

function Class.new()
	local self = setmetatable({}, Class)
	self.hovered = false
	local Store = self.Controllers.TestController.store

	self.activated = function(button, inputObject, clickCount, ...)
		Store:dispatch(Class:uppdateLabelTextToClickCount(clickCount))
	end;
	
	self.hoverChanged = {
		[true] = function(button, ...)
            self.hovered = true
            tweenInfo = TweenInfo.new(0.1)
            TweenService:Create(button, tweenInfo, {Size = button.Size + UDim2.new(0,10,0,10)}):Play()
		end;
		
		[false] = function(button, ...)
            self.hovered = false
            tweenInfo = TweenInfo.new(0.1)
            TweenService:Create(button, tweenInfo, {Size = button.Size - UDim2.new(0,10,0,10)}):Play()
		end;
	};

	return self
end

function Class:uppdateLabelTextToClickCount(clickCount)
	return {
		type = "UppdateLabel",
		labelName = "LinkedLabel",
		labelText = ("clickCount: ".. tostring(clickCount)),
	}
end


return Class