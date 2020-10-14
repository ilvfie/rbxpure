local TS = require(game:GetService('ReplicatedStorage'):WaitForChild('rbxts_include'):WaitForChild('RuntimeLib'))
local exports = {}
local Shapes
local ReplicatedStorage = TS.import(TS.getModule('services')).ReplicatedStorage
local Base = TS.import(game:GetService('ReplicatedStorage'), 'TS', 'flux', 'base').Base
Shapes = Shapes or {}
do
  local _0 = Shapes
  local module = require(ReplicatedStorage:WaitForChild('ModuleScript'))
  local function drawTriangle(a, b, c, d)
    return module(a, b, c, d)
  end
  local function dotProduct(vectA, vectB)
    local product = 0
    do
      local i = 0
      while i < 3 do
        product = product + vectA[i + 1] * vectB[i + 1]
        i = i + 1
      end
    end
    return product
  end
  local function crossProduct(vectA, vectB)
    local t = {}
    t[1] = vectA[2] * vectB[3] - vectA[3] * vectB[2]
    t[2] = vectA[1] * vectB[3] - vectA[3] * vectB[1]
    t[3] = vectA[1] * vectB[2] - vectA[2] * vectB[1]
    return t
  end
  local function convertVector(vector)
    return {vector.X, 0, vector.Z}
  end
  local function sameSide(p, p1, a, b)
    local cp = crossProduct(convertVector((b - (a))), convertVector((p - (a))))
    local cp1 = crossProduct(convertVector((b - (a))), convertVector((p1 - (a))))
    if dotProduct(cp, cp1) >= 0 then
      return true
    else
      return false
    end
  end
  local function pointInTriangle(p, a, b, c)
    if sameSide(p, a, b, c) and sameSide(p, b, a, c) and sameSide(p, c, a, b) then
      return true
    else
      return false
    end
  end
  local function isClockwise(vertices)
    local sum = 0
    do
      local i = 0
      while i < #vertices do
        local v = vertices[i + 1]
        local v1 = vertices[(i + 1) % #vertices + 1]
        sum = sum + ((v1.X - v.X) * (v1.Z + v.Z))
        i = i + 1
      end
    end
    return sum < 0
  end
  local function createSeries(points, properties, parent)
    if not isClockwise(points) then
      points = TS.array_reverse(points)
    end
    local model =
      Base.i(
      'Model',
      {
        Parent = parent,
        Name = 'Series'
      }
    )
    local seriesPointsClone = TS.array_slice(points)
    local validTriangle = function(p0, p1, p2)
      for _1 = 1, #seriesPointsClone do
        local v = seriesPointsClone[_1]
        if v ~= p0 and v ~= p1 and v ~= p2 and pointInTriangle(Vector3.new(v.X, p0.Y, v.Z), p0, p1, p2) then
          return false
        end
      end
      return true
    end
    local triangles = {}
    local resetCount = 0
    local i = 0
    while #seriesPointsClone > 2 do
      if i > 0 and i % 50 == 0 then
        wait()
      end
      local len = #seriesPointsClone + 1
      local p = seriesPointsClone[i % len + 1]
      local p1 = seriesPointsClone[(i + 1) % len + 1]
      local p2 = seriesPointsClone[(i + 2) % len + 1]
      if p and p1 and p2 then
        local v = Vector2.new(p1.X - p.X, p1.Z - p.Z)
        local v1 = Vector2.new(p2.X - p.X, p2.Z - p.Z)
        local cross = v.X * v1.Y - v.Y * v1.X
        if cross >= 0 and validTriangle(p, p1, p2) then
          triangles[#triangles + 1] = {p, p1, p2}
          TS.array_splice(seriesPointsClone, i + 1, 1)
        else
          i = i + 1
        end
      else
        resetCount = resetCount + 1
        if resetCount > 100 then
          warn('SHAPE OVERLOAD')
          break
        end
        i = 0
      end
    end
    local h = 0.5
    for _1 = 1, #triangles do
      local v = triangles[_1]
      local a = v[1]
      local b = v[2]
      local c = v[3]
      local _2 = drawTriangle(Vector3.new(a.X, properties.height, a.Z), Vector3.new(b.X, properties.height, b.Z), Vector3.new(c.X, properties.height, c.Z), h)
      for _3 = 1, #_2 do
        local v = _2[_3]
        v.Parent = model
        v.Color = properties.topColor
        v.Material = properties.topMaterial
        v.Name = 'Top'
        Base.removePartOutlines(v)
      end
      local _4 = drawTriangle(Vector3.new(a.X, properties.height - h, a.Z), Vector3.new(b.X, properties.height - h, b.Z), Vector3.new(c.X, properties.height - h, c.Z), properties.height - h)
      for _5 = 1, #_4 do
        local v = _4[_5]
        v.Parent = model
        v.Color = properties.bottomColor
        v.Material = properties.bottomMaterial
      end
    end
    return model
  end
  _0.createSeries = createSeries
end
exports.Shapes = Shapes
return exports
