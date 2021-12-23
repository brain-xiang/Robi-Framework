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

Class.name = "ClassTemplate"

Class.defaultStates = {
    growing = false, -- currently growing
}

Class.TYPE_REQUIREMENT = nil -- Required elment type, nil = all*

--------------
-- VARIABLES--
--------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local audioFolder = ReplicatedStorage:WaitForChild("Audio")

---------------
-- FUNCTIONS --
---------------

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

    -- when growbutton clicked
    self.maid:GiveTask(self.element.MouseButton1Down:Connect(function()
        if self.states.growing then return end
        if PlantController.opening or not PlantController.slotIndex then return end -- Customization UI opening or not open
        self.states.growing = true
        self.element.Text = "Growing"
        self.element.BackgroundColor3 = Color3.fromRGB(161, 161, 161)

		-- playing sound
		local plantType = PlantController.plantData.type
		local audio = audioFolder.GrowSounds:FindFirstChild(plantType)
		if not audio then print("plant: ", spawner) error("Could not find audio for *plant in GrowSounds") end
		audio:Play()

        local newConfig = {}
        for name,obj in pairs(self.store.sliders) do
            newConfig[name] = typeof(obj.states.value) == "table" and obj.states.value:GetProperties() or obj.states.value
        end
        BotanicalService:uppdatePlantData(PlantController.slotIndex, newConfig)

        self.states.growing = false
        self.element.Text = "Grow"
        self.element.BackgroundColor3 = Color3.fromRGB(255, 170, 255)
    end))

end

function Class.setup(object, ...)
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
	

	return self
end

function Class:Init()
    --[[
		Method used for AGF Access 
	]]
	BotanicalService = self.Services.BotanicalService
    PlantController = self.Controllers.PlantController
end

return Class