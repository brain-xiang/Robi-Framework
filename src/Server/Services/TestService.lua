-- Test Service
-- Username
-- December 14, 2020



local TestService = {Client = {}}


function TestService:Start()
    -- LocalCache Tests
    -- ReplicatedCache.cache = {
    --     a = 1, 
    --     b = 2, 
    --     c = 3
    -- }
    -- wait(5)
    -- ReplicatedCache:replicateCache()
    -- wait(5)
    -- ReplicatedCache.cache.a = 20
    -- ReplicatedCache:replicateCache()
end


function TestService:Init()
	ReplicatedCache = self.Services.ReplicatedCache
end


return TestService