script.Parent:RemoveDefaultLoadingScreen()
local keys = Enum.KeyCode:GetEnumItems()
local instancedefaults = {}
local callbacks = {}
local cache = {}
local names = {}
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
local mkindex = function(querykey)
  cache[querykey] = {all = {}, changed = {}, callbacks = {}, instances = {}, combos = {}}
end
local ensureindex = function(querykey)
  if not cache[querykey] then
    mkindex(querykey)
  end
end
local writeindex = function(querykey, id, set)
  cache[querykey].all[id] = set
  cache[querykey].changed[id] = set
  if set == nil then
    for comboname in pairs(cache[querykey].combos) do
      cache[comboname].all[id] = set
      cache[comboname].changed[id] = set
    end
  else
    for comboname, comboreq in pairs(cache[querykey].combos) do
      local pass = true
      for _, k in ipairs(comboreq) do
        if set[k] == nil then
          pass = false
          break
        end
      end
      if pass then
        cache[comboname].all[id] = set
        cache[comboname].changed[id] = set
      end
    end
  end
end
local addcombo = function(querykey)
  if string.find(querykey, '_') then
    local t = {}
    for str in string.gmatch(querykey, '([^_]+)') do
      table.insert(t, str)
    end
    for _, v in ipairs(t) do
      ensureindex(v)
      cache[v].combos[querykey] = t
    end
  end
end
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
            __newindex = function(_, querykey, v)
              e[querykey] = v
              ensureindex(querykey)
              if v == nil then
                writeindex(querykey, id, nil)
                local a = cache[querykey].instances
                if a then
                  for _, t in pairs(a) do
                    local a = t[id]
                    if a then
                      t[id] = nil
                      a.instance:Destroy()
                    end
                  end
                end
              else
                writeindex(querykey, id, proxy)
              end
            end,
            __index = e
          }
        )
        for querykey in pairs(e) do
          ensureindex(querykey)
          writeindex(querykey, id, proxy)
        end
      else
        warn('rodec: creation of entities is forbidden while pure')
      end
    end,
    __newindex = function(_, querykey, v)
      if canedit then
        if type(v) == 'function' then
          if not cache[querykey] then
            mkindex(querykey)
            addcombo(querykey)
          end
          table.insert(cache[querykey].callbacks, v)
        elseif v == true then
        elseif v == nil then
          ensureindex(querykey)
          cache[querykey].callbacks = {}
        else
          warn('rodec: cannot assign a value of that type to _G:', querykey)
        end
      else
        warn('rodec: _G assignments are forbidden while pure:', querykey)
      end
    end,
    __index = function(_, querykey)
      if canedit then
        if not cache[querykey] then
          mkindex(querykey)
          addcombo(querykey)
        end
        return cache[querykey].all
      else
        warn('rodec: access to _G is forbidden while pure:', querykey)
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
    for _, t in pairs(cache) do
      for _, f in ipairs(t.callbacks) do
        local functionid = tostring(f)
        for entityid, v in pairs(t.changed) do
          if not t.instances[functionid] then
            t.instances[functionid] = {}
          end
          if not t.instances[functionid][entityid] then
            t.instances[functionid][entityid] = {}
          end
          draw(f(v), t.instances[functionid][entityid])
        end
      end
      t.changed = {}
    end
    for i in pairs(_G) do
      if i:sub(1, 1) == '_' then
        _G[i] = 0
      end
    end
  end
)
----------------------------------------------------------------
do
  local allglobals = {}
  local allfenv = {}
  for _, descendant in pairs(script:GetDescendants()) do
    if descendant.ClassName == 'ModuleScript' then
      local fenv = require(descendant)
      if fenv then
        for i, v in pairs(fenv) do
          if i == 'main' then
            table.insert(callbacks, v)
          end
          if not allglobals[i] then
            allglobals[i] = v
          end
          table.insert(allfenv, fenv)
        end
      end
    end
  end
  for _, fenv in pairs(allfenv) do
    for i, v in pairs(allglobals) do
      if not fenv[i] then
        fenv[i] = v
      end
    end
  end
end
