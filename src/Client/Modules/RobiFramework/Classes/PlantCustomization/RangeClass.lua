--[[
Class Template - Legenderox
November 30, 2020

Class Description:

]]

--------------------
-- ROBI VARAIBLES --
--------------------

local Class = {}
Class.__index = Class

Class.name = "RangeClass"

Class.defaultStates = {
--  params = {type="range", min=0, max=5, step=1, nodes = 10, default=0}
    value = 0, -- current value
    config = {}, -- plant config 
}

Class.TYPE_REQUIREMENT = nil -- Required elment type, nil = all*

--------------
-- VARIABLES--
--------------

---------------
-- FUNCTIONS --
---------------
function Class:getVal(step)
    return self.states.params.min + self.states.params.step * step
end

function Class:valueLabelFocusLost(enterPressed)
    --[[
        fired when valueLabel text box lost focus, uppdates the values/step accordingly
    ]]
    local valueLabel = self.element.value
    local dragger = self.element.slider.dragger
    local num = tonumber(valueLabel.Text)
    if num then 
        local newVal = math.clamp(num, self.states.params.min, self.states.params.max) - self.states.params.min
        local newStep = math.round(newVal/self.states.params.step) -- rounding off to nearest step
        self.states.step = newStep
        self.states.value = self:getVal(newStep)
        valueLabel.Text = self.states.value
        local gap = self.element.slider.AbsoluteSize.X / (self.states.steps)
        self.element.slider.dragger.Position = UDim2.new(0, gap*newStep, dragger.Position.Y.Scale, 0)
    else
        valueLabel.Text = self.states.value
    end
end

function Class:uppdateNodeTexts(nodes)
    --[[
        input: nodes: array = of node label instnaces
        uppdates the node texts to match represented value
    ]]
end

-------------
-- METHODS --
-------------

function Class:run()
	--[[
		Method invoked asynchronously (at the same time)
		Fired when :run() is called on object
		Used to run evetns and main functionalities,
		*access to all states, store, classes*
	]]

    -- setting up value after receiving params
    self.states.value = self.states.config[self.states.name] or self.states.params.default
    self.states.step = math.round((self.states.value - self.states.params.min) / self.states.params.step) 
    self.element.slider.dragger.ImageColor3 = Color3.fromRGB(230, 187, 227)
    self.element.slider.ImageColor3 = Color3.fromRGB(248, 204, 245)

    -- step changes by slider    
    self.maid:GiveTask(self.states:GetPropertyChangedSignal("step"):Connect(function(old, new)
        self.states.value = self:getVal(new)
    end))

    -- uppdating value label
    local valueLabel = self.element.value
    valueLabel.Text = self.states.value
    self.maid:GiveTask(self.states:GetPropertyChangedSignal("value"):Connect(function(old, new)
        valueLabel.Text = new
    end))

    -- registering text entered into TextBox
    self.maid:GiveTask(valueLabel.FocusLost:Connect(function(...)
        self:valueLabelFocusLost(...)
    end))

    -- waiting for nodes to be created
    -- local nodesFrame = self.element.steps
    -- repeat task.wait() until nodesFrame:FindFirstChild("0") or self.destroyed
    
end

function Class.setup(object, config)
	--[[
		input: object: tbl = robi object the class is created in, ... = arguments passed

		Method invoked one-by-one synchronously
		Fired when robi object is created
		Used to setup states and object, 
		*Only access to local states and local class*

		returns: self
	]]
	local metaTable = { -- custom metatable allows access "Class" and entire Robi Object
		__index = function(self, i)
			if Class[i] then return Class[i] end -- CHECK CLASS FIRST
			if object[i] then return object[i] end
			return
		end
	}
	local self = setmetatable({}, metaTable)
	if self.TYPE_REQUIREMENT and not element:IsA(self.TYPE_REQUIREMENT) then error(element.Name.. "(Element) does not match this class's TYPE_REQUIREMENT") end
    
    self.states.config = config

	return self
end

function Class:Init()
    --[[
		Method used for AGF Access 
	]]
	
end

return Class