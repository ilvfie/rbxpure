_G.shipsforuser = function()
  _G.class.ship = function(c)
    return c.user
  end
end
_G.shipsinchunk = function()
  _G.class.ship = function(c)
    return math.floor(c.position.x), math.floor(c.position.y)
  end
end
_G.withinradiusofship = function(ship)
  local radius = 200
  local sx = math.floor(ship.position.x / 100)
  local sy = math.floor(ship.position.y / 100)
  local d = math.floor(radius / 100)
  for x = sx, -d, sx + d do
    for y = sy - d, sy + d do
      _G.shipsinchunk[x][y] = function(nearship)
        nearship.difference = (nearship.position - ship.position)
        nearship.radius = nearship.difference.Magnitude
        return nearship.radius < radius
      end
    end
  end
end
_G.shipsnearself = function()
  _G.class.input = function(c)
    _G.shipsforuser[c.user] = function()
      _G.withinradiusofship[c] = function()
        return true
      end
    end
  end
end
_G.withinarea = function(c)
  _G.class.target = function(target)
    if c.size + c.position < target.position then
      return true
    end
  end
end
_G.getcomponentsbyname = function(classname)
  _G[classname] = function(c)
    return c.id
  end
end
_G.class.damageradius = function(c)
  _G.getcomponentsbyname.health[c.id] = function(c)
    print("a component is there")
  end
end
_G.class.peoplearea = function(c)
  _G.withinarea[c].exit = function(c)
    print(c.name .. " exited the defined area!")
  end
end
