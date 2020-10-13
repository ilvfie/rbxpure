script.Parent:RemoveDefaultLoadingScreen()
local keys = Enum.KeyCode:GetEnumItems()
local names = {}
local inputcallbacks = {}
local purecallbacks = {}
local regularcache = {}
local changedcache = {}
local canedit = false
----------------------------------------------------------------
for _, v in pairs(keys) do
  local l = v.Name:lower()
  names[v.Name] = l
  _G[l] = 0
  _G['_' .. l] = 0
end
----------------------------------------------------------------
local drawrecurse
drawrecurse = function(schema)
  local classname = schema.ClassName
  if classname then
    local parent = schema.Parent
    schema.ClassName = nil
    schema.Parent = nil
    local instance = Instance.new(classname)
    for i, v in pairs(schema) do
      if type(i) == 'string' then
        if typeof(instance[i]) == 'RBXScriptSignal' then
          instance[i]:Connect(
            function()
              canedit = true
              v()
              canedit = false
            end
          )
        else
          instance[i] = v
        end
      end
    end
    instance.Parent = parent
    for _, v in ipairs(schema) do
      drawrecurse(v).Parent = instance
    end
    return instance
  end
end
----------------------------------------------------------------
local markentity = function(entity)
  for i in pairs(entity) do
    if not changedcache[i] then
      changedcache[i] = {}
    end
    changedcache[i][entity.id] = entity
  end
end
setmetatable(
  _G,
  {
    __call = function(_, ...)
      local args = {...}
      if type(args[1]) == 'table' then
        if canedit then
          -- add an entity
          local entity = args[1]
          entity.id = tostring(math.random())
          for i in pairs(entity) do
            if not regularcache[i] then
              regularcache[i] = {}
            end
            regularcache[i][entity.id] = entity
          end
          local proxy = {}
          setmetatable(
            proxy,
            {
              __newindex = function(_, i, v)
                entity[i] = v
                if not regularcache[i] then
                  regularcache[i] = {}
                end
                regularcache[i][entity.id] = v == nil and nil or entity
                markentity(entity)
              end,
              __index = function(_, i)
                return entity[i]
              end
            }
          )
          markentity(entity)
        else
          -- add a render object
        end
      elseif type(args[1]) == 'function' then
        table.insert(inputcallbacks, args[1])
        table.insert(purecallbacks, args[2])
      else
        -- query
        local t = newproxy(true)
        local a = regularcache
        local b = changedcache
        for _, v in ipairs(args) do
          a = a[v]
          b = b[v]
          if not a or not b then
            a = {}
            b = {}
            break
          end
        end
        local key, value
        local mt = getmetatable(t)
        mt.__call = function()
          key, value = next(a, key)
          return value
        end
        mt.__len = function()
          return function()
            key, value = next(b, key)
            return value
          end
        end
        return t
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
local start = true
game:GetService('RunService'):BindToRenderStep(
  'main',
  Enum.RenderPriority.Input.Value - 1,
  function(deltatime)
    _G.time = tick()
    if start then
      start = false
      _G._time = 0
    else
      _G._time = deltatime
    end
    canedit = true
    for _, v in ipairs(inputcallbacks) do
      v()
    end
    canedit = false
    for _, v in ipairs(purecallbacks) do
      v()
    end
    changedcache = {}
  end
)
----------------------------------------------------------------
do
  for _, descendant in pairs(script:GetDescendants()) do
    if descendant.ClassName == 'ModuleScript' then
      require(descendant)
    end
  end
end
