-- Replicated Cache
-- Legenderox
-- December 14, 2020



local ReplicatedCache = {}

local UPPDATE_LOCAL_CACHE_EVENT = "UppdateCache"

ReplicatedCache.cache = {}
ReplicatedCache.replicatedCache = {}

local TableUtil;

function ReplicatedCache:replicateCache()
    --[[
        Fires Uppdate local cache event with cacheChanges in a table if there has been a change in the cache.
    ]]

    local cacheChanges = TableUtil:returnDictionaryWithoutDuplicates(self.cache, self.replicatedCache)

    print(cacheChanges)
    if cacheChanges ~= {} then
        self:FireAllClients(UPPDATE_LOCAL_CACHE_EVENT, {type = "combineCache", cacheChanges = cacheChanges})
        self.replicatedCache = TableUtil.Copy(self.cache)
    end
end

function ReplicatedCache:Init()
    TableUtil = self.Shared.TableUtil
    self:RegisterClientEvent(UPPDATE_LOCAL_CACHE_EVENT)
end

return ReplicatedCache