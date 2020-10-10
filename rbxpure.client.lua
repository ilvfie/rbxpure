rbxpure = {}
local callbacks = {}
local changes = {}
local recurse
recurse = function(t, proxy)
  setmetatable(
    t,
    {
      __newindex = function(t, i, v)
        if type(v) == 'table' then
          if getmetatable(v) then
            warn('cannot add a metatable to global')
          elseif i:sub(1, 1) == '#' then
            -- linked object (subject to class)
            changes[i] = true
            local empty = {}
            proxy[i] = v
            rawset(t, i, empty)
            recurse(empty, proxy[i])
          else
            -- object
            local empty = {}
            proxy[i] = v
            rawset(t, i, empty)
            recurse(empty, proxy[i])
          end
        else
          -- regular field
          changes[t.id] = true
          proxy[i] = v
        end
      end,
      __index = function(_, i)
        return proxy[i]
      end
    }
  )
end
recurse(rbxpure, {})
game:GetService('RunService'):BindToRenderStep(
  'render',
  Enum.RenderPriority.Input.Value - 2,
  function()
    for i, v in pairs(changes) do
      for _, f in pairs(callbacks[i]) do
        f(v)
      end
    end
  end
)
local keys = Enum.KeyCode:GetEnumItems()
local names = {}
for _, v in pairs(keys) do
  local l = v.Name:lower()
  names[v.Name] = l
  rbxpure.istate[l] = 0
  rbxpure.idelta[l] = 0
end
game:GetService('RunService'):BindToRenderStep(
  'clear',
  Enum.RenderPriority.Last.Value,
  function()
    for i, _ in pairs(rbxpure.idelta) do
      rbxpure.idelta[i] = 0
    end
  end
)
game:GetService('ContextActionService'):BindActionAtPriority(
  'input',
  function(_, is, io)
    if io.UserInputType == Enum.UserInputType.Keyboard then
      local n = names[io.KeyCode.Name]
      if is == Enum.UserInputState.Begin then
        rbxpure.idelta[n] = 1
        rbxpure.istate[n] = 1
      else
        rbxpure.idelta[n] = -1
        rbxpure.istate[n] = 0
      end
    elseif io.UserInputType == Enum.UserInputType.MouseMovement then
      rbxpure.istate.mousex = io.Position.X
      rbxpure.istate.mousey = io.Position.Y
      rbxpure.idelta.mousex = io.Delta.X
      rbxpure.idelta.mousey = io.Delta.Y
    elseif io.UserInputType == Enum.UserInputType.MouseWheel then
      if is == Enum.UserInputState.Change then
        rbxpure.idelta.mousewheel = io.Position.Z
      end
    elseif io.UserInputType == Enum.UserInputType.MouseButton1 then
      local n = 'mousebutton1'
      if is == Enum.UserInputState.Begin then
        rbxpure.idelta[n] = 1
        rbxpure.istate[n] = 1
      elseif is == Enum.UserInputState.End then
        rbxpure.idelta[n] = -1
        rbxpure.istate[n] = 0
      end
    end
    return Enum.ContextActionResult.Pass
  end,
  true,
  9e9,
  unpack(keys),
  unpack(Enum.UserInputType:GetEnumItems())
)
do
  local allglobals = {}
  local allenvironments = {}
  for _, descendant in pairs(script.Parent:GetDescendants()) do
    if descendant.ClassName == 'ModuleScript' then
      local fenv = require(descendant)
      for i, v in pairs(fenv) do
        if not allglobals[i] then
          allglobals[i] = v
        end
      end
      table.insert(allenvironments, fenv)
    end
  end
  for _, fenv in pairs(allenvironments) do
    for i, v in pairs(allglobals) do
      if not fenv[i] then
        fenv[i] = v
      end
    end
  end
end
