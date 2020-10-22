local all = {}
local callbacks = {}
local changed = {}
local function registerindex(index)
  if not all[index] then
    all[index] = {}
    callbacks[index] = {}
  end
end
local function createentity(real)
  real._tags = {}
  local proxy = {}
  local id = tostring(math.random())
  setmetatable(
    proxy,
    {
      __call = function()
      end,
      __newindex = function(_, querykey, v)
        if v ~= real[querykey] then
          real[querykey] = v
          changed[id] = proxy
          if v == true then
            registerindex(querykey)
            all[querykey][id] = proxy
            real._tags[querykey] = {}
          elseif v == nil then
            if all[querykey] then
              all[querykey][id] = nil
              if real._tags[querykey] then
                for _, v in pairs(real._tags[querykey]) do
                  v.instance:Destroy()
                end
              end
              real._tags[querykey] = nil
            end
          end
        end
      end,
      __index = real
    }
  )
  changed[id] = proxy
  for querykey, v in pairs(real) do
    if v == true then
      registerindex(querykey)
      all[querykey][id] = proxy
      real._tags[querykey] = {}
    end
  end
end
setmetatable(
  _G,
  {
    __call = function(_, a, b)
      if b then
        registerindex(a)
        table.insert(callbacks[a], b)
      else
        createentity(a)
      end
    end,
    __newindex = function(_, querykey, v)
      -- change
    end,
    __index = function(_, querykey)
      registerindex(querykey)
      return all[querykey]
    end
  }
)
local instancedefaults, draw = {}
function draw(schema, pass)
  local classname = schema.ClassName
  if classname then
    local parent = schema.Parent
    schema.ClassName = nil
    schema.Parent = nil
    if pass.instance then
      if pass.instance.ClassName == classname then
        for instancekey, instancevalue in pairs(pass) do
          if instancekey ~= "instance" then
            if typeof(instancevalue) == "RBXScriptConnection" then
              instancevalue:Disconnect()
              pass[instancekey] = nil
            else
              if not schema[instancekey] then
                if type(instancevalue) == "table" then
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
      if type(i) == "string" then
        if typeof(pass.instance[i]) == "RBXScriptSignal" then
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
_G {step = true, frame = 0}
local function merge(t1, t2)
  for k, v in pairs(t2) do
    if (type(v) == "table") and (type(t1[k] or false) == "table") then
      merge(t1[k], t2[k])
    else
      t1[k] = v
    end
  end
  return t1
end
game:GetService("RunService"):BindToRenderStep(
  "main",
  Enum.RenderPriority.Input.Value - 1,
  function(deltatime)
    _G._Time = (rawget(_G, "_Time") == nil) and 0 or deltatime
    for _, v in pairs(_G.step) do
      v.frame = v.frame + 1
    end
    for _, entity in pairs(changed) do
    end
    changed = {}
  end
)
local keys = Enum.KeyCode:GetEnumItems()
local userinputtypes = Enum.UserInputType:GetEnumItems()
for _, v in pairs(keys) do
  _G[v.Name] = 0
end
for _, v in pairs(userinputtypes) do
  _G[v.Name] = 0
end
_G.MouseMovement = Vector3.new()
_G._MouseMovement = Vector3.new()
_G.MouseWheel = Vector3.new()
game:GetService("ContextActionService"):BindActionAtPriority(
  "input",
  function(_, is, io)
    if io.UserInputType == Enum.UserInputType.Keyboard then
      if is == Enum.UserInputState.Begin then
        _G[io.KeyCode.Name] = 1
        _G["_" .. io.KeyCode.Name] = 1
      else
        _G[io.KeyCode.Name] = 0
        _G["_" .. io.KeyCode.Name] = -1
      end
    elseif io.UserInputType == Enum.UserInputType.MouseMovement then
      _G.MouseMovement = io.Position
      _G._MouseMovement = io.Delta
    elseif io.UserInputType == Enum.UserInputType.MouseWheel then
      if is == Enum.UserInputState.Change then
        _G.MouseWheel = io.Position
      end
    elseif io.UserInputType == Enum.UserInputType.MouseButton1 then
      if is == Enum.UserInputState.Begin then
        _G.MouseButton1 = 1
        _G._MouseButton1 = 1
      elseif is == Enum.UserInputState.End then
        _G.MouseButton1 = 0
        _G._MouseButton1 = -1
      end
    end
    return Enum.ContextActionResult.Pass
  end,
  true,
  9e9,
  unpack(keys),
  unpack(userinputtypes)
)
