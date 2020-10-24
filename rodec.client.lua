local containers = {}
local containersbytag = {}
setmetatable(
  _G,
  {
    __newindex = function(_, i, v)
      if i:sub(1, 1) == "_" then
        rawset(
          _G,
          i,
          function(...)
            local ret = v(...)
          end
        )
      else
        rawset(_G, i, v)
      end
    end,
    __index = function(_, i, v)
    end,
    __call = function(_, container)
      if container.id then
        local ocontainer = containers[container.id]
        for i, v in pairs(container) do
          if ocontainer[i] ~= v then
            ocontainer[i] = v
            if v == true then
              containersbytag[i][ocontainer.id] = ocontainer
            elseif v == false then
              containersbytag[i][ocontainer.id] = nil
            end
          end
        end
      else
        container.id = tostring(math.random())
        containers[container.id] = container
        for i, v in pairs(container) do
          if v == true then
            containersbytag[i][container.id] = container
          end
        end
      end
    end
  }
)
function _G._hastag(index)
  return containersbytag[index]
end
