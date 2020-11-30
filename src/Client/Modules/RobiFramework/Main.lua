-- Main
-- Username
-- November 30, 2020


local Main = {}

local Maid

function Main.newButton()
    maid = Maid.new()
	local self = setmetatable({

	}, maid)

	return self

end

function Main:Init()
    Maid = self.Shared.Maid
end

return Main