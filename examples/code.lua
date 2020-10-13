return function()
  if _G._time == 0 then
    _G.button = function(v)
      return {
        ClassName = 'TextLabel',
        MouseButton1Down = function()
          v.count = v.count + 1
        end
      }
    end
    _G({button = {count = 0}})
  end
end
