# tutorial
* put rbxpure.client.lua in a client directory (ex. PlayerScripts)
* put rbxpure.server.lua in a server directory (ex. ServerScriptService)
* make ModuleScripts as needed under the same directory that rbxpure.client.lua is parented to
* ModuleScripts must return `getfenv(0)`
* this is the most user friendly way to get running, but if desired you could modify it to work as a more traditional module
* you can see how the API works in practice by looking at *example*
# api (wip)
```lua
-- this code will draw buttons according to input
rbxpure.BUTTON = function(object)
    if not object.label then
        object.label = "Tick: " .. tick()
    end
end
rbxpure.objectlist = function(object)
    return {
        ClassName = 'ScreenGui'
    }
end
rbxpure.input = function()
    if rbxpure.idelta.g == 1 then -- if g was just pressed
        local object = rbxpure.BUTTON() -- create a new clicky button
        rbxpure.objectlist(object)
    end
end
```