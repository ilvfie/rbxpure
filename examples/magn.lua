local chunk = 100
chunkify = function(n)
  return math.floor(n / chunk)
end
getkeyforpos = function(pos)
  return chunkify(pos.x) .. ',' .. chunkify(pos.y)
end
getkey = function(x, y)
  return x .. ',' .. y
end
magn = function()
  if _G.frame == 0 then
    _G.pos_isred = function(v)
      return {
        ClassName = 'Frame',
        Parent = game.Players.LocalPlayer.PlayerGui.ScreenGui,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, v.pos.x - 10, 0, v.pos.y - 10),
        BackgroundColor3 = v.isred and Color3.new(1, 0, 0) or Color3.new()
      }
    end
    _G.pos_isred_mouseposition = function(v)
      local a = (v.mouseposition - v.pos)
      local magn = a.Magnitude
      local sx = magn
      local sy = 2
      return {
        Visible = v.isred,
        ClassName = 'Frame',
        Parent = game.Players.LocalPlayer.PlayerGui.ScreenGui,
        Size = UDim2.new(0, sx, 0, sy),
        Rotation = math.deg(math.atan2(a.y, a.x)),
        Position = UDim2.new(0, v.pos.x + a.x / 2 - sx / 2, 0, v.pos.y + a.y / 2 - sy / 2),
        BackgroundColor3 = Color3.new(1, 0, 1)
      }
    end
  end
  if _G.mousebutton1 == 1 then
    for _ = 1, 1 do
      local pos = Vector2.new(_G.mousemovementx + math.random(-30, 30), _G.mousemovementy + math.random(-40, 40))
      _G({pos = pos, [getkeyforpos(pos)] = true, isred = false, mouseposition = Vector2.new()})
    end
  end
  local radius = 200
  local cur = Vector2.new(_G.mousemovementx, _G.mousemovementy)
  local d = math.ceil(radius / chunk)
  local sx = chunkify(cur.x)
  local sy = chunkify(cur.y)
  for _, v in pairs(_G.mouseposition) do
    v.mouseposition = cur
  end
  for _, v in pairs(_G.redtag) do
    v.redtag = nil
    v.instance.BackgroundColor3 = Color3.new()
  end
  for x = sx - d, sx + d do
    for y = sy - d, sy + d do
      for _, v in pairs(_G[getkey(x, y)]) do
        if (v.pos - cur).Magnitude < radius then
          v.redtag = true
          v.instance.BackgroundColor3 = Color3.new(1, 0, 0)
        end
      end
    end
  end
end
return getfenv(0)
