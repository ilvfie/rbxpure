_G(
  function()
    if _G.deltatime == 0 then
      _G({button = {}})
    end
    for v in #_G('button') do
      if not v.button.count then
        v.button.count = 0
      end
      if not v.button.osci then
        v.button.osci = 0
      end
    end
    for v in _G('button') do
      v.button.osci = v.button.osci + _G.dtime
    end
    return function()
      _G({})
      for v in #_G('button') do
        _G(
          {
            ClassName = 'TextLabel',
            MouseButton1Down = function()
              v.count = v.count + 1
            end
          }
        )
      end
    end
  end
)
return nil
