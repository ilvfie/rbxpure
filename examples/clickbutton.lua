clickbutton = function()
  if _G.frame == 0 then
    _G.singleton = function(v)
      return {
        ClassName = 'ScreenGui',
        Parent = game.Players.LocalPlayer.PlayerGui,
        {
          ClassName = 'Folder',
          {
            ClassName = 'UIListLayout'
          }
        }
      }
    end
    _G.count = function(v)
      return (v.count >= 5 and v.count <= 10) and
        {
          ClassName = 'TextButton',
          Parent = game.Players.LocalPlayer.PlayerGui.ScreenGui.Folder,
          Size = UDim2.new(0.4, 0, 0.4, 0),
          TextScaled = true,
          Text = 'BIGGO: ' .. v.count,
          MouseButton1Down = function()
            v.count = v.count + 1
          end
        } or
        {
          ClassName = 'TextButton',
          Parent = game.Players.LocalPlayer.PlayerGui.ScreenGui.Folder,
          BackgroundColor3 = Color3.new(v.count / 100, 0, 0),
          Size = UDim2.new(0.2, 0, 0.2, 0),
          TextScaled = true,
          Text = 'Count: ' .. v.count,
          MouseButton1Down = function()
            v.count = v.count + 1
            if v.count > 20 then
              for _, e in pairs(_G.count) do
                e.count = nil
              end
            end
          end,
          {
            ClassName = 'UICorner',
            CornerRadius = UDim.new(0, 50)
          }
        }
    end
    _G({singleton = true})
  end
  if _G.frame == 1 then
    _G({count = 0})
    _G({count = 2})
    _G({count = 6})
    _G({count = 3})
  end
end
return getfenv(0)
