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

Class.name = "SliderClass"

Class.defaultStates = {
    name = nil, -- name of the property the slider changes
    params = {type="range", min=0, max=5, step=1, nodes = 10, default=0}, -- NOTE NODES CANNOT BE MORE THAN 10
    steps = 0, -- total amount of steps, excluding 0
    step = nil, -- current step
    holding = false, -- is mouse holding dragger
}

Class.TYPE_REQUIREMENT = nil -- Required elment type, nil = all*

--------------
-- VARIABLES--
--------------
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local audioFolder = ReplicatedStorage:WaitForChild("Audio")

---------------
-- FUNCTIONS --
---------------


function Class:getClosestStep(x)
    --[[
        input: x: int = mouse x position
        returns: step: int = step which has step UI closest to position x, pos: int = x position of this step *on slider* (local position not global)
    ]]

    local gap = self.element.slider.AbsoluteSize.X / (self.states.steps)
    local step = math.round(x/gap)
    local pos = step*gap

    return step, pos
end

function Class:createNodes()
    --[[
        fills the element.steps frame with nodes corresponding to steps in params
    ]]

    local stepsFrame = self.element.steps
    local template = stepsFrame.template
    
    local params = self.states.params
    local steps = self.states.steps
    if params.nodes > 14 then 
        warn("params.nodes cannot be more than 14! (due to size restriction) -> ", self.states.name, " -> ", params)
        params.nodes = 14
    elseif params.nodes > steps then
        params.nodes = steps
    end
    local stepsPerNode = steps / params.nodes

    stepsFrame.UIListLayout.Padding = UDim.new( (1-( (steps/stepsPerNode+1) *template.size.X.Scale )) / (steps/stepsPerNode), 0)

    -- creating node Labels
    local labelIndex = 1
    for i = 0, steps, stepsPerNode do
        local clone = template:Clone()
        clone.Parent = stepsFrame
        clone.Visible = true
        clone.Name = i
        if self.states.params.stepLabels then
            clone.Text = self.states.params.stepLabels[labelIndex]
        else
            clone.Text = math.round((self.states.params.min + self.states.params.step * i)*100)/100
        end
        labelIndex += 1
    end
end

function Class:draggerButtonDown()
    if self.states.holding then return end
    audioFolder["14_CDP_Slider Final Click-MP3"]:Play()
    local dragger = self.element.slider.dragger
    self.states.holding = true
    self.draggingConnection = RunService.Heartbeat:Connect(function()
        local minPos = 0
        local maxPos = self.element.slider.AbsoluteSize.X
        local positionOnSlider = math.clamp(mouse.X - self.element.slider.AbsolutePosition.X, minPos, maxPos)
        dragger.Position = UDim2.new(0, positionOnSlider, dragger.Position.Y.Scale, 0)
        local closestStep, pos = self:getClosestStep(dragger.Position.X.Offset)
        self.states.step = closestStep
    end)
end

function Class:draggerButtonUp()
    if not self.states.holding then return end
    audioFolder["14_CDP_Slider Final Click-MP3"]:Play()
    local dragger = self.element.slider.dragger
    self.states.holding = false
    self.draggingConnection:Disconnect()
    
    local closestStep, pos = self:getClosestStep(dragger.Position.X.Offset)
    dragger.Position = UDim2.new(0, pos, dragger.Position.Y.Scale, 0)
    self.states.step = closestStep
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

    -- setting property name
    self.element.nameLabel.Text = self.states.params.displayName

    -- slide dragger conenctions
    local dragger = self.element.slider.dragger
    local draggerDownConnection = dragger.MouseButton1Down:Connect(function()
        self:draggerButtonDown()
    end)
    -- local draggerUpConnection = dragger.MouseButton1Up:Connect(function()
    --     self:draggerButtonUp()
    -- end)
    -- local mouseUpConnection = mouse.Button1Up:Connect(function()
    --     self:draggerButtonUp()
    -- end)
    local mouseUpConnection = UserInputService.InputEnded:Connect(function(input, processed)
        -- print(input.UserInputType)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        self:draggerButtonUp()
    end)
    self.maid:GiveTask(draggerDownConnection)
    --self.maid:GiveTask(draggerUpConnection)
    self.maid:GiveTask(mouseUpConnection)

    -- setting dragger location on run
    repeat task.wait() until self.states.step
    local gap = self.element.slider.AbsoluteSize.X / (self.states.steps)
    dragger.Position = UDim2.new(0, gap*(self.states.step), dragger.Position.Y.Scale, 0)

    -- uppdating dragger location on screen resize
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        gap = self.element.slider.AbsoluteSize.X / (self.states.steps)
        dragger.Position = UDim2.new(0, gap*(self.states.step), dragger.Position.Y.Scale, 0)
    end)

    -- randomize button connection
    local randomizeButton = self.element.randomize
    local randomizeConnection = randomizeButton.MouseButton1Down:Connect(function()
        audioFolder["15_CDP_Random Value-MP3"]:Play()
        if self.states.steps == 0 then return end
        local step
        repeat
            step = math.random(0, self.states.steps)
        until self.states.step ~= step
        self.states.step = step
        
        local gap = self.element.slider.AbsoluteSize.X / (self.states.steps)
        self.element.slider.dragger.Position = UDim2.new(0, gap*step, dragger.Position.Y.Scale, 0)
    end)

    self.maid:GiveTask(randomizeConnection)

    -- setting up step markers
    self:createNodes()

end

function Class.setup(object, params, name)
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
	
    self.states.params = params or self.states.params
    self.states.steps = (self.states.params.max - self.states.params.min) / self.states.params.step
    self.states.name = name or "*empty*"

	return self
end

function Class:Init()
    --[[
		Method used for AGF Access 
	]]
end

return Class