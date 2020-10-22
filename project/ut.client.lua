local function drawtriangle(a, b, c, width)
  local lenab = (b - a).magnitude
  local lenbc = (c - b).magnitude
  local lenca = (a - c).magnitude
  if lenab > lenbc and lenab > lenca then
    a, c = c, a
    b, c = c, b
  elseif lenca > lenab and lenca > lenbc then
    a, b = b, a
    b, c = c, b
  end
  local dot = (a - b):Dot(c - b)
  local split = b + (c - b).unit * dot / (c - b).magnitude
  local xa = width
  local ya = (split - a).magnitude
  local za = (split - b).magnitude
  local xb = width
  local yb = (split - a).magnitude
  local zb = (split - c).magnitude
  local diry = (a - split).unit
  local dirz = (c - split).unit
  local dirx = diry:Cross(dirz).unit
  local posa = split + diry * ya / 2 - dirz * za / 2
  local posb = split + diry * yb / 2 + dirz * zb / 2
  local cf = CFrame.new(posa.x, posa.y, posa.z, dirx.x, diry.x, dirz.x, dirx.y, diry.y, dirz.y, dirx.z, diry.z, dirz.z) * CFrame.new(-width / 2, 0, 0)
  local size = Vector3.new(xa, ya, za)
  dirx = dirx * -1
  dirz = dirz * -1
  local cf1 = CFrame.new(posb.x, posb.y, posb.z, dirx.x, diry.x, dirz.x, dirx.y, diry.y, dirz.y, dirx.z, diry.z, dirz.z) * CFrame.new(width / 2, 0, 0)
  local size1 = Vector3.new(xb, yb, zb)
  return cf, size, cf1, size1
end
local function dotproduct(vecta, vectb)
  local product = 0
  local i = 0
  while i < 3 do
    product = product + vecta[i + 1] * vectb[i + 1]
    i = i + 1
  end
  return product
end
local function crossproduct(vectA, vectB)
  local t = {}
  t[1] = vectA[2] * vectB[3] - vectA[3] * vectB[2]
  t[2] = vectA[1] * vectB[3] - vectA[3] * vectB[1]
  t[3] = vectA[1] * vectB[2] - vectA[2] * vectB[1]
  return t
end
local function convertvector(vector)
  return {vector.X, 0, vector.Z}
end
local function sameside(p, p1, a, b)
  local cp = crossproduct(convertvector(b - a), convertvector(p - a))
  local cp1 = crossproduct(convertvector(b - a), convertvector(p1 - a))
  if dotproduct(cp, cp1) >= 0 then
    return true
  else
    return false
  end
end
local function pointintriangle(p, a, b, c)
  if sameside(p, a, b, c) and sameside(p, b, a, c) and sameside(p, c, a, b) then
    return true
  else
    return false
  end
end
local function isclockwise(vertices)
  local sum = 0
  local i = 0
  while i < #vertices do
    local v = vertices[i + 1]
    local v1 = vertices[(i + 1) % #vertices + 1]
    sum = sum + (v1.X - v.X) * (v1.Z + v.Z)
    i = i + 1
  end
  return sum < 0
end
function _G.createseries(points)
  local pclone = {}
  if isclockwise(points) then
  else
    -- reverse points
  end
  local validtriangle = function(p0, p1, p2)
    for _1 = 1, #pclone do
      local v = pclone[_1]
      if v ~= p0 and v ~= p1 and v ~= p2 and pointintriangle(Vector3.new(v.X, p0.Y, v.Z), p0, p1, p2) then
        return false
      end
    end
    return true
  end
  local triangles = {}
  local resetcount = 0
  local i = 0
  while #pclone > 2 do
    if i > 0 and i % 50 == 0 then
      wait()
    end
    local len = #pclone + 1
    local p = pclone[i % len + 1]
    local p1 = pclone[(i + 1) % len + 1]
    local p2 = pclone[(i + 2) % len + 1]
    if p and p1 and p2 then
      local v = Vector2.new(p1.X - p.X, p1.Z - p.Z)
      local v1 = Vector2.new(p2.X - p.X, p2.Z - p.Z)
      local cross = v.X * v1.Y - v.Y * v1.X
      if cross >= 0 and validtriangle(p, p1, p2) then
        triangles[#triangles + 1] = drawtriangle(p, p1, p2)
        table.remove(i + 1)
      else
        i = i + 1
      end
    else
      resetcount = resetcount + 1
      if resetcount > 100 then
        warn("overload")
        break
      end
      i = 0
    end
  end
  return triangles
end
