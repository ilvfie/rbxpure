rbxpure.FOOS = function(object)
end
rbxpure.TEXTEDITOR = function(object)
  for i, v in pairs(
    {
      textsize = 38,
      cursorblink = 0.53,
      cursorx = 0,
      cursory = 0,
      copy = '',
      copiedline = false,
      savetohistory = true,
      visible = true,
      writtencode = template,
      cursorposition = 1,
      cursoranchor = 1,
      scrollposition = 0,
      cursorvisible = true
    }
  ) do
    if not object[i] then
      object[i] = v
    end
  end
  object.list(object)
  rbxpure.texteditor(object.id)
  rbxpure.texteditor(object)
end
rbxpure.TEXTEDITOR = function(object)
end
rbxpure.action = function()
  if rbxpure.idelta.minus == 1 then
    local object = rbxpure.TEXTEDITOR({})
    object.foo(rbxpure.FOO({}))
  end
end
return getfenv(0)
