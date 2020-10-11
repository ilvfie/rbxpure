script.Parent:RemoveDefaultLoadingScreen()
local istate = {}
local idelta = {}
local classfunctions = {}
local reactivefunctions = {}
local changes = {}
local inputcallbacks = {}
local proxy = {}
local canedit = false
local recurse
local keys = Enum.KeyCode:GetEnumItems()
local names = {}
_G.istate = istate
_G.idelta = idelta
----------------------------------------------------------------
for _, v in pairs(keys) do
  local l = v.Name:lower()
  names[v.Name] = l
  istate[l] = 0
  idelta[l] = 0
end
----------------------------------------------------------------
recurse = function(t, proxy)
  setmetatable(
    t,
    {
      __newindex = function(t, i, v)
        if type(v) == 'function' then
          if i == 'input' then
            table.insert(inputcallbacks, v)
          elseif string.upper(i) == i then
            classfunctions[i] = classfunctions[i] or {}
            table.insert(classfunctions[i], v)
            if not proxy[i] then
              proxy[i] = function(object)
                object.id = tostring(math.random())
                for _, v in pairs(classfunctions[i]) do
                  v(object)
                end
                return object
              end
            end
          else
            reactivefunctions[i] = reactivefunctions[i] or {}
            table.insert(reactivefunctions[i], v)
          end
        else
          if canedit then
            if type(v) == 'table' then
              warn('rbxpure: cannot directly add a table:', i)
            else
              proxy[i] = v
            end
          else
            warn('rbxpure: can not edit in this scope:', i)
          end
        end
      end,
      __index = function(_, i)
        proxy[i] = proxy[i] or {}
        if type(proxy[i]) == 'table' then
          return function(toinsert)
            if not toinsert then
              local key, value
              return function()
                key, value = next(proxy[i], key)
                return value
              end
            end
            if type(toinsert) == 'table' then
              if not proxy[i][toinsert.id] then
                if not changes[i] then
                  changes[i] = {}
                end
                changes[i][toinsert.id] = true
                proxy[i][toinsert.id] = toinsert
              end
            elseif type(toinsert) == 'string' then
              if proxy[i][toinsert] ~= nil then
                if not changes[i] then
                  changes[i] = {}
                end
                changes[i][toinsert.id] = true
                proxy[i][toinsert] = nil
              end
            else
              warn('rbxpure: could not')
            end
          end
        else
          return proxy[i]
        end
      end
    }
  )
end
----------------------------------------------------------------
game:GetService('ContextActionService'):BindActionAtPriority(
  'input',
  function(_, is, io)
    if io.UserInputType == Enum.UserInputType.Keyboard then
      local n = names[io.KeyCode.Name]
      if is == Enum.UserInputState.Begin then
        idelta[n] = 1
        istate[n] = 1
      else
        idelta[n] = -1
        istate[n] = 0
      end
    elseif io.UserInputType == Enum.UserInputType.MouseMovement then
      istate.mousex = io.Position.X
      istate.mousey = io.Position.Y
      idelta.mousex = io.Delta.X
      idelta.mousey = io.Delta.Y
    elseif io.UserInputType == Enum.UserInputType.MouseWheel then
      if is == Enum.UserInputState.Change then
        idelta.mousewheel = io.Position.Z
      end
    elseif io.UserInputType == Enum.UserInputType.MouseButton1 then
      local n = 'mousebutton1'
      if is == Enum.UserInputState.Begin then
        idelta[n] = 1
        istate[n] = 1
      elseif is == Enum.UserInputState.End then
        idelta[n] = -1
        istate[n] = 0
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
local drawrecurse
drawrecurse = function(schema)
  local classname = schema.ClassName
  if classname then
    schema.ClassName = nil
    local parent = schema.Parent
    schema.Parent = nil
    local instance = Instance.new(classname)
    for i, v in pairs(schema) do
      if type(i) == 'string' then
        if typeof(instance[i]) == 'RBXScriptSignal' then
          instance[i]:Connect(v)
        else
          instance[i] = v
        end
      end
    end
    instance.Parent = parent
    for _, v in ipairs(schema) do
      local instance1 = drawrecurse(v)
      if instance1 then
        instance1.Parent = instance
      end
    end
    return instance
  end
end
game:GetService('RunService'):BindToRenderStep(
  'main',
  Enum.RenderPriority.Input.Value - 1,
  function()
    canedit = true
    for _, v in pairs(inputcallbacks) do
      v()
    end
    canedit = false
    for i in pairs(idelta) do
      idelta[i] = 0
    end
    for i, v in pairs(changes) do
      for i1 in pairs(v) do
        if reactivefunctions[i] then
          for _, v in pairs(reactivefunctions[i]) do
            local schema = v(proxy[i][i1])
            if schema then
              drawrecurse(schema)
            else
              warn('rbxpure: no schema')
            end
          end
        end
      end
    end
    changes = {}
  end
)
----------------------------------------------------------------
do
  recurse(_G, proxy)
  for _, descendant in pairs(script:GetDescendants()) do
    if descendant.ClassName == 'ModuleScript' then
      require(descendant)
    end
  end
end
