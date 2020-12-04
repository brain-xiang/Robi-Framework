-- Main
-- Username
-- November 30, 2020


local Main = {}

local Maid

function Main.createButton(button, Objects)
	--[[
		button = GuiObject, Objects = dic of Robi Objects
		returns: GuiObject containing, maid, parsedObjects functions and connects all the objects together 
	]]
	local self = setmetatable(Objects, Main)

	--Events--
	self.activated = button.Activated:Connect(function(...)
		for i,Object in pairs(self) do 
			Object.activated(button, ...)
		end
	end)

	self.mouseEnter = button.MouseEnter:Connect(function(...)
		for i,Object in pairs(self) do 
			Object.hoverChanged[true](button, ...)
		end
	end)

	self.mouseLeave = button.MouseLeave:Connect(function(...)
		for i,Object in pairs(self) do 
			Object.hoverChanged[false](button, ...)
		end
	end)

	self.visibleChanged = button.GetPropertyChangedSignal("Visible"):Connect(function()
		for i,Object in pairs(self) do 
			Object.visibleChanged[button.Visible](button)
		end
	end)

	--Maid--
	self.maid = Maid.new() -- creating maid object
	maid:GiveTask(self.activated)
	maid:GiveTask(self.mouseEnter)
	maid:GiveTask(self.mouseLeave)
	maid:GiveTask(self.visibleChanged)

	return self
end

function self:Destroy()
	--Cleaning up events
	self.maid:Destroy()
	return nil
end


function Main:Init()
    Maid = self.Shared.Maid
end

return Main