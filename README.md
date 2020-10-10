WORK IN PROGRESS

# Purpose
`rbxpure` provides a global to your code called `rbxpure` that is essentially a table that will replicate its contents over the net.
It does this in the backend as efficiently and quickly as can be done with roblox API.
What makes `rbxpure` powerful is that it allows this to happen without the user having to put much explicit effort.
You can essentially just modify the table and expect everything to go swell, as long as the module is stable.

# Installation
Run this in the command bar.
```lua
game:GetService("HttpService").HttpEnabled = true loadstring(game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/ilvfie/rbxpure/master/install.lua"))()
```
# Example
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
        local object = rbxpure.BUTTON({}) -- Creates a button class.
        rbxpure.list(object) -- Invoking a field like this is similar to table.insert.
    end
end
```
I really recommend checking out the *example* folder for a more in depth example, as it shows why everything is set up the way it is.