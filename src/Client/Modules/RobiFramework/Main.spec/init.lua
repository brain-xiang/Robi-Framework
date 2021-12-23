return function()
    Robi = require(script.Parent.Main)
    describe("create", function()

        it("should create", function()
            expect(function()
                local object1 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass)})
                local object2 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass), require(script.TestClass2)})
                expect(object1).never.to.equal(nil)
                expect(object1.states).never.to.equal(nil)
                expect(object1.classes).never.to.equal(nil)
                expect(object1.maid).never.to.equal(nil)
                expect(object1.states.destroyed).never.to.equal(nil)
                expect(object1.element).never.to.equal(nil)
            end).never.to.throw()
        end)

        it("created object should have combined states of classes", function()
            expect(function()
                local object1 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass), require(script.TestClass2)})

                local class1 = object1.classes.TestClass
                local class2 = object1.classes.TestClass2
                for i,v in pairs(class1.defaultStates) do
                    expect(object1.states[i]).to.equal(v)
                end
                for i,v in pairs(class2.defaultStates) do
                    expect(object1.states[i]).to.equal(v)
                end
            end).never.to.throw()
        end)

        it("Shortcut 1", function()
            expect(function()
                Robi.create(Instance.new("ImageButton"), require(script.TestClass))
            end).never.to.throw()
        end)

        it("Shortcut 2", function()
            expect(function()
                Robi.create(Instance.new("ImageButton"), {
                    require(script.TestClass),
                    require(script.TestClass2),
                })
            end).never.to.throw()
        end)

        it("Should parse properties to the classes", function()
            local store = {
                object1 = Robi.create({Instance.new("ImageButton")}, {
                    [require(script.TestClass)] = {"Properties", "Passed"},
                }),
            }

            expect(store.object1.states.passedPoperties[1]).to.equal("Properties")
            expect(store.object1.states.passedPoperties[2]).to.equal("Passed")
        end)

        it("should not allow 2 classes of same name in same object", function()
            expect(function()
                Robi.create({Instance.new("ImageButton")}, {require(script.TestClass), require(script.TestClass)})
            end).to.throw()
        end)

        it("constructing using the same class multiple times should not inteffere", function()
            local store = {
                object1 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass)}),
                object2 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass)})
            }
            Robi:run(store)
            wait() -- waiting for run to complete
            
            store.object1.states.a = 5 
            expect(store.object1.states.mutationCount).to.equal(1)
        end)
    end)

    describe("createGroup", function()
        it("Should return a group(table) of identical objects made from diffrent elements", function()
            local store = {
                group = Robi.createGroup({Instance.new("ImageButton"), Instance.new("ImageLabel")}, {require(script.TestClass)})
            }
            Robi:run(store)
            wait() -- waiting for run to complete

            expect(store.group.ImageButton.states.a).to.equal(store.group.ImageLabel.states.a)
            expect(store.group.ImageButton.element).never.to.equal(store.group.ImageLabel.element)
        end)
    end)

    describe("classes", function()
        it("Classes should be accessable through object.classes", function()
            object1 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass)})
            
            expect(object1.classes.TestClass).never.to.equal(nil)
        end)
        
        it("Classes should have inherited the *class* methods and properties", function()
            object1 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass)})

            expect(object1.classes.TestClass.name).to.equal("TestClass")
            expect(function()
                expect(object1.classes.TestClass:testFunc()).to.equal(true)
            end).never.to.throw()
        end)

        it("Classes should have access to object core properties (states, element, etc.) in setup()", function()
            object1 = Robi.create({Instance.new("ImageButton")}, {
                require(script.TestClass),
                require(script.TestClass2),
            })
            
            local obj = object1.classes.TestClass
            expect(obj.states).never.to.equal(nil)
            expect(obj.element).never.to.equal(nil)
            expect(obj.maid).never.to.equal(nil)
            expect(obj.states).to.equal(object1.classes.TestClass2.states)
        end)

        it("Classes should have access to store after being run()", function()
            local store = {
                object1 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass)}),
                object2 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass)})
            }
            Robi:run(store)
            wait() -- waiting for run to complete

            expect(store.object1.classes.TestClass.store).never.to.equal(nil)
            expect(store.object1.classes.TestClass.store.object2).never.to.equal(nil)
        end)

        it("Classes should have access to other classes (in same or other objects)", function()
            local store = {
                object1 = Robi.create({Instance.new("ImageButton")}, {
                    require(script.TestClass),
                    require(script.TestClass2)
                }),
                object2 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass)})
            }
            Robi:run(store)
            wait() -- waiting for run to complete

            local obj = store.object1.classes.TestClass
            expect(obj.classes.TestClass2).never.to.equal(nil)
            expect(obj.store.object2.classes.TestClass).never.to.equal(nil)
        end)
    end)

    describe("States", function()
        it("state changes should be visible in class code", function()
            local store = {
                object1 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass)})
            }
            Robi:run(store)
            wait() -- waiting for run to complete

            store.object1.states.a = 5 
            expect(store.object1.states.mutationCount).to.equal(1)
        end)
        it("modify and detect state change within same object", function()
            local store ={
                object1 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass), require(script.TestClass2)})
            }
            Robi:run(store)
            wait() -- waiting for run to complete

            store.object1.states.c = 5 
            expect(store.object1.states.mutationCount).to.equal(1)
        end)
        it("modify and detect state changes with other objects", function()
            local store = {
                object1 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass)}),
                object2 = Robi.create({Instance.new("ImageButton")}, {require(script.TestClass2)})
            }
            Robi:run(store)
            wait() -- waiting for run to complete

            expect(store.object1.states.mutationCount).to.equal(1)
            expect(store.object1.states.a).to.equal("Changed by Object2")
        end)
    end)
end