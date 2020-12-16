-- Local Cache
-- Username
-- December 14, 2020



local LocalCache = {}



local reducer = function(state, action)
    if action.type == "combineCache" then
        return TableUtil:returnMergedDeepDictionaries(state, action.cacheChanges)
    end
end

function LocalCache:Start()
    self.Store = Rodux.Store.new(reducer, {}, {
        Rodux.loggerMiddleware,
    })

    ReplicatedCache.UppdateCache:Connect(function(action)
        self.Store:dispatch(action)
    end)
end

function LocalCache:Init()
    Rodux = self.Shared.Rodux
    TableUtil = self.Shared.TableUtil
    ReplicatedCache = self.Services.ReplicatedCache
end


return LocalCache