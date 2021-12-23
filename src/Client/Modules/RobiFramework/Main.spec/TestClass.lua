--[[
Class Template - Legenderox
November 30, 2020

Class Description:

]]


local Class = {}
Class.__index = Class

Class.name = "TestClass"

Class.defaultStates = {
    a = 1,
	b = 2,
	mutationCount = 0
}

Class.TYPE_REQUIREMENT = nil -- Required elment type, nil = all*

-------------
-- METHODS --
-------------

function Class:testFunc()
	return true
end

function Class:run()
	--[[
		Method invoked asynchronously (at the same time)
		Fired when :run() is called on object
		Used to run evetns and main functionalities,
		*access to all states, store, classes*
	]]

	self.states.mutated:Connect(function(old, new)
		self.states.mutationCount = 1
	end)
end

function Class.setup(object, p1, p2)
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
	

	self.states.passedPoperties = {p1, p2}

	return self
end

function Class:Init()
    --[[
		Method used for AGF Access 
	]]
end

return Class