# Installation
Run this in the command bar.
```lua
local h = game:GetService("HttpService") local e = h.HttpEnabled h.HttpEnabled = true loadstring(h:GetAsync("https://raw.githubusercontent.com/ilvfie/rbxpure/master/install.lua"))(e)
```
# Example
At a small scale the API may look a bit convoluted or underwhelming, but this is the nature of the library.

This code will draw buttons according to input.
```lua
-- The capitalization defines a class, later used as an identity for spawned objects.
-- The function is called when registered objects change in state.
rbxpure.BUTTON = function(object)
    if not object.label then
        object.label = "Tick: " .. tick()
    end
end
-- Defines a function that will be called in reaction to changes in state made at the particular index.
-- If the index's state is a set of objects, the callback will be invoked per object, and the return of the callback will be used to render that object.
rbxpure.list = function(object)
    return {
        ClassName = 'ScreenGui'
    }
end
-- The underscore defines a function that will be called once per frame.
rbxpure._input = function()
    if rbxpure.idelta.g == 1 then -- G press event.
        local object = rbxpure.BUTTON() -- Creates a button class.
        rbxpure.list(object) -- Invoking a field like this is similar to table.insert.
    end
end
```