-- Class Template
-- Username
-- November 30, 2020



local Class = {}
Class.__index = Class


function Class.new()

	local self = setmetatable({

	}, Class)

	return self

end


return Class