script.Parent:RemoveDefaultLoadingScreen()
local keys = Enum.KeyCode:GetEnumItems()
local instancedefaults = {}
local purecallbacks = {}
local changedcache = {}
local callbacks = {}
local passes = {}
local names = {}
local cache = {}
local canedit = false
local draw
for _, v in pairs(keys) do
  local lower = v.Name:lower()
  names[v.Name] = lower
  _G[lower] = 0
  _G['_' .. lower] = 0
  _G._time = 0
  _G.frame = -1
  _G.time = 0
  _G._mousemovementx = 0
  _G._mousemovementy = 0
  _G.mousemovementx = 0
  _G.mousemovementy = 0
  _G.mousebutton1 = 0
  _G._mousebutton1 = 0
end
----------------------------------------------------------------
setmetatable(
  _G,
  {
    __call = function(_, e)
      if canedit then
        local id = tostring(math.random())
        local proxy = {}
        setmetatable(
          proxy,
          {
            __newindex = function(_, i, v)
              if v then
                e[i] = v
                if not cache[i] then
                  cache[i] = {}
                end
                cache[i][id] = proxy
                if not changedcache[i] then
                  changedcache[i] = {}
                end
                changedcache[i][id] = proxy
              else
                e[i] = nil
                cache[i][id] = nil
                changedcache[i][id] = nil
                for _, t in pairs(passes) do
                  local a = t[id]
                  if a then
                    t[id] = nil
                    a.instance:Destroy()
                  end
                end
              end
            end,
            __index = e
          }
        )
        for i in pairs(e) do
          if not cache[i] then
            cache[i] = {}
          end
          cache[i][id] = proxy
          if not changedcache[i] then
            changedcache[i] = {}
          end
          changedcache[i][id] = proxy
        end
      else
        warn('rbxpure: creation of entities is forbidden while pure')
      end
    end,
    __newindex = function(_, i, v)
      if canedit then
        if type(v) == 'function' then
          if not purecallbacks[i] then
            purecallbacks[i] = {}
          end
          table.insert(purecallbacks[i], v)
        elseif v == true then
        elseif v == nil then
          purecallbacks[i] = {}
        else
          warn('rbxpure: cannot assign a value of that type to _G:', i)
        end
      else
        warn('rbxpure: _G assignments are forbidden while pure:', i)
      end
    end,
    __index = function(_, i)
      if canedit then
        if not cache[i] then
          cache[i] = {}
        end
        return cache[i]
      else
        warn('rbxpure: access to _G is forbidden while pure:', i)
      end
    end
  }
)
----------------------------------------------------------------
game:GetService('ContextActionService'):BindActionAtPriority(
  'input',
  function(_, is, io)
    if io.UserInputType == Enum.UserInputType.Keyboard then
      local n = names[io.KeyCode.Name]
      if is == Enum.UserInputState.Begin then
        _G[n] = 1
        _G['_' .. n] = 1
      else
        _G[n] = 0
        _G['_' .. n] = -1
      end
    elseif io.UserInputType == Enum.UserInputType.MouseMovement then
      _G.mousemovementx = io.Position.X
      _G.mousemovementy = io.Position.Y
      _G._mousemovementx = io.Delta.X
      _G._mousemovementy = io.Delta.Y
    elseif io.UserInputType == Enum.UserInputType.MouseWheel then
      if is == Enum.UserInputState.Change then
        _G._mousewheel = io.Position.Z
      end
    elseif io.UserInputType == Enum.UserInputType.MouseButton1 then
      local n = 'mousebutton1'
      if is == Enum.UserInputState.Begin then
        _G[n] = 1
        _G['_' .. n] = 1
      elseif is == Enum.UserInputState.End then
        _G[n] = 0
        _G['_' .. n] = -1
      end
    end
    return Enum.ContextActionResult.Pass
  end,
  true,
  9e9,
  unpack(keys),
  unpack(Enum.UserInputType:GetEnumItems())
)
----------------------------------------------------------------
draw = function(schema, pass)
  local classname = schema.ClassName
  if classname then
    local parent = schema.Parent
    schema.ClassName = nil
    schema.Parent = nil
    if pass.instance then
      if pass.instance.ClassName == classname then
        for instancekey, instancevalue in pairs(pass) do
          if instancekey ~= 'instance' then
            if typeof(instancevalue) == 'RBXScriptConnection' then
              instancevalue:Disconnect()
              pass[instancekey] = nil
            else
              if not schema[instancekey] then
                if type(instancevalue) == 'table' then
                  instancevalue.instance:Destroy()
                else
                  pass.instance[instancekey] = instancedefaults[classname][instancekey]
                end
                pass[instancekey] = nil
              end
            end
          end
        end
      else
        pass.instance:Destroy()
        pass.instance = Instance.new(classname)
      end
    else
      pass.instance = Instance.new(classname)
    end
    for i, v in pairs(schema) do
      if type(i) == 'string' then
        if typeof(pass.instance[i]) == 'RBXScriptSignal' then
          pass[i] =
            pass.instance[i]:Connect(
            function()
              canedit = true
              v()
              canedit = false
            end
          )
        else
          if not pass[i] then
            if not instancedefaults[classname] then
              instancedefaults[classname] = {}
            end
            instancedefaults[classname][i] = pass.instance[i]
          end
          pass[i] = v
          pass.instance[i] = v
        end
      else
        if not pass[i] then
          pass[i] = {}
        end
        draw(v, pass[i]).Parent = pass.instance
      end
    end
    pass.instance.Parent = parent
    return pass.instance
  end
end
game:GetService('RunService'):BindToRenderStep(
  'main',
  Enum.RenderPriority.Input.Value - 1,
  function(deltatime)
    _G.time = tick()
    _G._time = deltatime
    _G.frame = _G.frame + 1
    canedit = true
    for _, v in ipairs(callbacks) do
      v()
    end
    canedit = false
    for cacheid, t in pairs(changedcache) do
      if purecallbacks[cacheid] then
        for _, f in ipairs(purecallbacks[cacheid]) do
          local functionid = tostring(f)
          for entityid, v in pairs(t) do
            if not passes[functionid] then
              passes[functionid] = {}
            end
            if not passes[functionid][entityid] then
              passes[functionid][entityid] = {}
            end
            draw(f(v), passes[functionid][entityid])
          end
        end
      end
    end
    changedcache = {}
    for i in pairs(_G) do
      if i:sub(1, 1) == '_' then
        _G[i] = 0
      end
    end
  end
)
----------------------------------------------------------------
do
  for _, descendant in pairs(script:GetDescendants()) do
    if descendant.ClassName == 'ModuleScript' then
      local f = require(descendant)
      if f then
        table.insert(callbacks, f)
      end
    end
  end
end
