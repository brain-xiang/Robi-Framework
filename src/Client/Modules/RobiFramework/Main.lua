-- Main
-- Username
-- November 30, 2020


local Main = {}
Main.__index = Main

function Main.createButton(button, Objects, hiarchy)
	--[[
		inputs: 
			button = GuiObject, 
			Objects = dic of Robi classes used to create the button object
				Example = {
					hoverButton = require(hoverButton).new()
				}
			hiarchy = tbl, all robi objects created are stored using a predicatble hiarchial structure, this variable specefies where this object will be stored. more details on hiarchy found in docStrings below(Main:addToHiarchy())
		
		Events:
			This contructor creates and holds all the Event connections of the button. 
			It rewires the events and forwards them to all the  classes used in the objectio.
			All events are stored in:
				self.maid
			and can be cleaned up using: 
				self:Destroy()	
		
		returns: Robi-Object
			injectedProperties: 
				self.name - string name
				self.element - roblox gui element
				self.type - string, object type
				self.hiarchy - tbl, Robi-hiarchy
			
			self injected into each individual object that this object inherited from as a "parent" property.

			All functions in Main are also metatabled to this object
	]]
	local self = setmetatable({unpack(Objects)}, Main)
	self.name = button.Name
	self.element = button
	self.type = "button"
	self.hiarchy = hiarchy

	--injecting parent property into objects
	for i,Object in pairs(Objects) do 
		Object.parent = self
	end

	--Events
	self.activated = button.Activated:Connect(function(...)
		for i,Object in pairs(Objects) do 
			if Object.activated then
				Object.activated(button, ...)
			end
		end
	end)

	self.mouseEnter = button.MouseEnter:Connect(function(...)
		for i,Object in pairs(Objects) do 
			if Object.hoverChanged then
				Object.hoverChanged[true](button, ...)
			end
		end
	end)

	self.mouseLeave = button.MouseLeave:Connect(function(...)
		for i,Object in pairs(Objects) do 
			if Object.hoverChanged then
				Object.hoverChanged[false](button, ...)
			end
		end
	end)

	self.visibleChanged = button:GetPropertyChangedSignal("Visible"):Connect(function()
		for i,Object in pairs(Objects) do 
			if Object.visibleChanged then
				Object.visibleChanged[button.Visible](button)
			end
		end
	end)

	--hiarchy
	local parentStructure = self:mapParentStructure(self.element)
	self:addToHiarchy(self, parentStructure, hiarchy)

	--Maid
	self.maid = Maid.new() -- creating maid object
	self.maid:GiveTask(self.activated)
	self.maid:GiveTask(self.mouseEnter)
	self.maid:GiveTask(self.mouseLeave)
	self.maid:GiveTask(self.visibleChanged)

	return self
end

function Main.createLabel(Label, Objects, hiarchy)
	--[[
		inputs: 
			button = GuiObject, 
			Objects = dic of Robi classes used to create the button object
				Example = {
					hoverButton = require(hoverButton).new()
				}
			hiarchy = tbl, all robi objects created are stored using a predicatble hiarchial structure, this variable specefies where this object will be stored. more details on hiarchy found in docStrings below(Main:addToHiarchy())
		
		Events:
			This contructor creates and holds all the Event connections of the button. 
			It rewires the events and forwards them to all the  classes used in the objectio.
			All events are stored in:
				self.maid
			and can be cleaned up using: 
				self:Destroy()	
		
		returns: Robi-Object
			injectedProperties: 
				self.name - string name
				self.element - roblox gui element
				self.type - string, object type
				self.hiarchy - tbl, Robi-hiarchy
			All injectedProperties are also injected into each individual object thats inherited from.

			All functions in Main are also metatabled to this object
	]]

	local self = setmetatable({unpack(Objects)}, Main)
	self.name = Label.Name
	self.element = Label
	self.type = "label"
	self.hiarchy = hiarchy
	self.stores = {}
	for i,Object in pairs(Objects) do -- filling stores list with stores from inherited classes
		if Object.storeChangedFunctions then
			for store, func in pairs(Object.storeChangedFunctions) do
				if self.stores[store] then
					table.insert( self.stores[store], func )
				else
					self.stores[store] = {func}
				end
			end
		end
	end

	--injecting parent property into objects
	for i,Object in pairs(Objects) do 
		Object.parent = self
	end

	--Maid--
	self.maid = Maid.new() -- creating maid object

	--Events--
	for store, functions in pairs(self.stores) do 
		self.maid:GiveTask(store.changed:connect(function(newState, oldState)
			for i,func in pairs(functions) do
				func(newState, oldState)
			end
		end))
	end
	

	self.visibleChanged = Label:GetPropertyChangedSignal("Visible"):Connect(function()
		for i,Object in pairs(Objects) do 
			if Object.visibleChanged then
				Object.visibleChanged[Label.Visible](Label)
			end
		end
	end)
	self.maid:GiveTask(self.visibleChanged)

	--hiarchy
	print(self.hiarchy)
	local parentStructure = self:mapParentStructure(self.element)
	self:addToHiarchy(self, parentStructure, hiarchy)

	return self
end

function Main:findObject(name, hiarchy)
	--[[
		input: (only name needed), hiarchy = list, if you want to specify start location of search
		returns: first abject fround in this object's hiarchy with matching name
	]]

	hiarchy = hiarchy or self.hiarchy

	for i,v in pairs(hiarchy) do
		if v.name == name then 
			return v
		elseif typeof(v) == "table" then 
			self:findObject(name, v)
		end
	end

	return nil
end

function Main:getAllObjects(hiarchy, list)
	--[[
		input: not needed, hiarchy = list, if you want to specify start location of search
		returns: all abjects of this object's hiarchy put into one large list
	]]

	list = list or {}
	hiarchy = hiarchy or self.hiarchy

	for i,v in pairs(hiarchy) do
		if i == "object" then 
			table.insert(list, v)
		elseif typeof(v) == "table" then 
			self:getAllObjects(v, list)
		end
	end

	return list
end

function Main:addToHiarchy(object, parentStructure, hiarchy)
	--[[
		input: object = Robi gui objects contructed in Main, hiarchy = dictionary where objects are stored for ease of access
		puts robi object into a dictionary of hiarchinal structure based on elements hiarchial position in roblox workspace

		Note: All keys in Robi hiarchies are "strings"
		Hiarchy structure = {
			frame = {
				object = nil, --means this step in hiarchy does not contain Robi object
				button1 = {
					object = {*RobiObject*}
				}
			}
			button2 = {
				object = {*RobiObject*}
			}
		}
	]]

	if #parentStructure < 1 then warn("Overlapping Hiarchyname: ".. "(".. object.element.Name.. ")".. " Hiarychy = ".. hiarchy) return end
	
	local current = hiarchy -- table
	local next = hiarchy[tostring(parentStructure[1])] -- table or nil
	if next then -- if next parent exists in hiarchy, check next table for parent after that again
		table.remove( parentStructure, 1 )
		self:addToHiarchy(object, parentStructure, next)
	else -- if next parent does not exist in hiarchy, make the rest of parentStructure
		for i,element in pairs(parentStructure) do
			current[tostring(parentStructure[i])] = {}
			current = current[tostring(parentStructure[i])]
		end
		current["object"] = object
	end
end

function Main:mapParentStructure(element)
	--[[
		input: gui element, table = nil
		returns: table of an elements parents in descending order up until screenGui, example: {Frame, Button, element}
	]]

	local parents = {}

	repeat
		table.insert( parents, 1, element )
		element = element.Parent
	until element.ClassName == "ScreenGui"

	return parents
end

function Main:Destroy()
	--Cleaning up events
	self.maid.Destroy()
	self = nil
end


function Main:Init()
    Maid = self.Shared.Maid
end

return Main