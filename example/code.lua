_G.BUTTON = function(object)
  if not object.value then
    object.value = 0
  end
  _G.buttonlist(object)
end
_G.buttonlist = function(object)
  return {
    Parent = game.Players.LocalPlayer.PlayerGui.ScreenGui.ScrollingFrame,
    ClassName = 'TextButton',
    Text = 'Clicks: ' .. object.value,
    TextScaled = true,
    Size = UDim2.new(1, 0, 0, 200),
    MouseButton1Down = function()
      object.value = object.value + 1
    end,
    {
      ClassName = 'UICorner',
      CornerRadius = UDim.new(0, 24)
    }
  }
end
_G.singleton = function(object)
  return {
    ClassName = 'ScreenGui',
    Parent = game.Players.LocalPlayer.PlayerGui,
    {
      BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
      ClassName = 'ScrollingFrame',
      Size = UDim2.new(1, 0, 1, 0),
      {
        ClassName = 'UIListLayout'
      }
    }
  }
end
_G.EMPTY = function()
end
local start = true
_G.input = function()
  if start then
    start = false
    _G.singleton(_G.EMPTY({}))
  end
  if _G.idelta.g == 1 then
    _G.BUTTON({})
  end
end
return nil
