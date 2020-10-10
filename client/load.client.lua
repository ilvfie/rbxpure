game:GetService 'StarterGui':SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
game.Workspace.CurrentCamera.CameraType = 'Scriptable'
wait()
local newglobals = {}
local allfenv = {}
for _, v in pairs(script.Parent:GetDescendants()) do
  if v.ClassName == 'ModuleScript' then
    local fenv = require(v)
    for i, v in pairs(fenv) do
      if not newglobals[i] then
        newglobals[i] = v
      end
    end
    table.insert(allfenv, fenv)
  end
end
for _, fe in pairs(allfenv) do
  for i, v in pairs(newglobals) do
    if not fe[i] then
      fe[i] = v
    end
  end
end
