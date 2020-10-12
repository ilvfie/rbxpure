script.Parent:RemoveDefaultLoadingScreen()
local istate = {}
local idelta = {}
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
