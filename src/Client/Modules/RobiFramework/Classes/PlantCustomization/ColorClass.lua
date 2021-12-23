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
--  params = {type="range", min=0, max=1, step=0.01, nodes = 10, default={r=255, g=200, b=255}}
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
function Class:getHue(val)
    --[[
        input: val: tbl = {R:Int, G:Int, B:Int}
        turns value into hue
    ]]

    local h,s,l = ColorUtils.rgb2hsv(val.r, val.g, val.b)
    return h
end

function Class:getVal(step)
    local hue = self.states.params.min + self.states.params.step * step
    local r,g,b = ColorUtils.hsv2rgb(hue, self.states.config.saturation, self.states.params.value)
    return {r = r, g = g, b = b}
end

function Class:valueLabelFocusLost(enterPressed)
    --[[
        fired when valueLabel text box lost focus, uppdates the values/step accordingly
    ]]
    local valueLabel = self.element.value
    local dragger = self.element.slider.dragger
    local success, color = pcall(function()
        return Color3.fromHex(valueLabel.Text)
    end)
    if success then 
        print(color, " COLOR")
        local hue,s,v = color:ToHSV()
        print(hue, " HUE")
        local newVal = math.clamp(hue, self.states.params.min, self.states.params.max) - self.states.params.min
        local newStep = math.round(newVal/self.states.params.step) -- rounding off to nearest step
        self.states.step = newStep
        self.states.value = self:getVal(newStep)
        valueLabel.Text = ColorUtils.rgbToHex(self.states.value)
        local gap = self.element.slider.AbsoluteSize.X / (self.states.steps)
        self.element.slider.dragger.Position = UDim2.new(0, gap*newStep, dragger.Position.Y.Scale, 0)
    else
        valueLabel.Text = ColorUtils.rgbToHex(self.states.value)
    end
end

function Class:createGradient()
    --[[
        creates UIGradient for the slider background, using config.saturation
    ]]

    local saturation = self.states.config.saturation
    -- checking if config has saturation
    
    if not saturation then print("CONFIG: ", self.states.config) error("Tried crating colorClass without saturation in config, parameter: ".. self.states.name) end

    local UIGradient = Instance.new("UIGradient")
    UIGradient.Parent = self.element.slider
    local colorSequenceKeypoints = {}
    for i = 0, 6 do
        table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new((i/6), Color3.fromHSV((i/6), saturation, 1)))
    end
    UIGradient.Color = ColorSequence.new(colorSequenceKeypoints)
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
    -- print(self.states.config)
    self.states.value = self.states.config[self.states.name] or self.states.params.default
    -- print(self.states.value, " RGB")
    -- print(self:getHue(self.states.value), " HSV")
    self.states.step = math.round((self:getHue(self.states.value) - self.states.params.min) / self.states.params.step) 
    
    -- step changes by slider    
    self.maid:GiveTask(self.states:GetPropertyChangedSignal("step"):Connect(function(old, new)
        self.states.value = self:getVal(new)
    end))

    -- uppdating value label
    local valueLabel = self.element.value
    valueLabel.Text = ColorUtils.rgbToHex(self.states.value)
    self.element.slider.dragger.ImageColor3 = Color3.fromRGB(self.states.value.r, self.states.value.g, self.states.value.b)
    self.maid:GiveTask(self.states.mutated:Connect(function(old, new)
        valueLabel.Text = ColorUtils.rgbToHex(new.value)
        self.element.slider.dragger.ImageColor3 = Color3.fromRGB(new.value.r, new.value.g, new.value.b)
    end))

    -- registering text entered into TextBox
    self.maid:GiveTask(valueLabel.FocusLost:Connect(function(...)
        self:valueLabelFocusLost(...)
    end))

    self:createGradient()

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
    
    -- print(config, " SETUP")
    self.states.config = config
    -- print(self.states.config, " after SETUP")
	return self
end

function Class:Init()
    --[[
		Method used for AGF Access 
	]]
	ColorUtils = self.Shared.ColorUtils
    TableUtil =self.Shared.TableUtil
end

return Class