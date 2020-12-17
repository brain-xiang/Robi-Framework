-- Test Controller
-- Username
-- December 4, 2020



local TestController = {}

local player = game.Players.LocalPlayer
local Gui = player.PlayerGui:WaitForChild("ScreenGui")
local Button1 = Gui.Frame.Button1
local Button2 = Gui.Frame.Button2
local Button3 = Gui.Frame.Button2.Button3
local Button4 = Gui.Button4
local clickCountLabel = Gui.LinkedLabel

local LabelTextReducer = function(state, action)
    state = state or {}

    if action.type == "UppdateLabel" then
        local newState = TableUtil.Copy(state)

        newState[action.labelName] = action.labelText

        return newState
    end
    return state
end

local reducer = function(state, action)
    return{
        LabelTexts = LabelTextReducer(state.LabelTexts, action),
    }
end

function TestController:Start()
    self.store = Rodux.Store.new(reducer, {}, {
        Rodux.loggerMiddleware,
    })

    self.objects = {}
    Button1 = Robi.createButton(Button1, {TestButton = RobiClasses.TestButton.new()}, self.objects)
    Button2 = Robi.createButton(Button2, {TestButton = RobiClasses.TestButton.new()}, self.objects)
    Button3 = Robi.createButton(Button3, {TestButton = RobiClasses.TestButton.new()}, self.objects)
    Button4 = Robi.createButton(Button4, {TestButton = RobiClasses.ColorChangerButton.new()}, self.objects)
    clickCountLabel = Robi.createLabel(clickCountLabel, {
        TestLabel = RobiClasses.TestLabel.new(self.store)
    }, self.objects)

end

function TestController:Init()
    Rodux = self.Shared.Rodux
    Robi = self.Modules.RobiFramework.Main
    RobiClasses = self.Modules.RobiFramework.Classes
    TableUtil = self.Shared.TableUtil
end


return TestController