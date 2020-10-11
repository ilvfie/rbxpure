_G.BUTTON = function(object)
  if not object.label then
    object.label = 'Tick: '
  end
end
_G.list = function(object)
  return {
    ClassName = 'ScreenGui'
  }
end
_G.input = function()
  if _G.idelta.g == 1 then
    local object = _G.BUTTON({})
    _G.list(object)
    for v in _G.list() do
      print('hewwo', v.label)
    end
  end
end
return nil
