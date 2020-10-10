rbxpure.enormal = function()
  for _, object in pairs(rbxpure.texteditor) do
    if rbxpure.idelta.backquote == 1 then
      object.visible = not object.visible
    end
    if object.visible then
      object.scrollposition = object.scrollposition - rbxpure.idelta.mousewheel * object.textsize * 4
      if rbxpure.idelta.mousebutton1 == 1 then
        local i = math.min(#object.linestarts, math.floor((rbxpure.istate.mousey - object.text.AbsolutePosition.Y) / object.textsize))
        object.cursorposition = math.min(object.linestarts[i] + math.floor((rbxpure.istate.mousex - object.text.AbsolutePosition.X) / (object.textsize / 2)), object.linestarts[i + 1] and object.linestarts[i + 1] - 1 or string.len(object.writtencode))
      end
      if rbxpure.istate.leftcontrol == 1 then
        if rbxpure.idelta.equals == 1 then
          object.textsize = object.textsize + 6
        end
        if rbxpure.idelta.minus == 1 then
          object.textsize = object.textsize - 6
        end
        if rbxpure.idelta.c == 1 then
          object.copy = string.sub(object.writtencode, object.linestarts[object.cursory], object.linestarts[object.cursory + 1] - 1)
          object.copiedline = true
        end
      end
    end
  end
end
rbxpure.erepeat = function()
  for _, object in pairs(rbxpure.texteditor) do
    local repeatdefault = {
      left = function()
        object.cursorposition = object.cursorposition - 1
      end,
      right = function()
        object.cursorposition = object.cursorposition + 1
      end,
      up = function()
        movecursorvertically(object, -1)
      end,
      down = function()
        movecursorvertically(object, 1)
      end,
      ['return'] = function()
        insertstring(object, '\n\n')
      end,
      backspace = function()
        object.writtencode = object.writtencode:sub(1, object.cursorposition - 2) .. object.writtencode:sub(object.cursorposition)
        object.cursorposition = object.cursorposition - 1
      end,
      tab = function()
        insertstring(object, '    ')
      end
    }
    local repeatalt = {
      up = function()
        pushline(object, 0)
      end,
      down = function()
        pushline(object, 1)
      end
    }
    local repeatcontrol = {
      left = function()
        cursorskip(object, -1)
      end,
      right = function()
        cursorskip(object, 1)
      end,
      x = function()
        local newstr = object.writtencode:sub(1, object.linestarts[object.cursory] - 1)
        newstr = newstr .. object.writtencode:sub(object.linestarts[object.cursory + 1], object.writtencode:len())
        object.copy = object.writtencode:sub(object.linestarts[object.cursory], object.linestarts[object.cursory + 1] - 1)
        object.copiedline = true
        object.writtencode = newstr
        object.cursorposition = object.linestarts[object.cursory]
      end,
      v = function()
        if object.copiedline then
          local newstr = object.writtencode:sub(1, object.linestarts[object.cursory] - 1)
          newstr = newstr .. object.copy
          newstr = newstr .. object.writtencode:sub(object.linestarts[object.cursory])
          object.writtencode = newstr
          object.cursorposition = object.cursorposition + object.copy:len()
        else
          insertstring(object, object.copy)
        end
      end,
      z = function()
        local latest = object.history[#object.history]
        if latest then
          table.remove(object.history, #object.history)
          object.savetohistory = false
          object.writtencode = latest
          object.savetohistory = true
        end
      end
    }
    local function apply(i, v)
      if rbxpure.idelta[i] == 1 then
        v()
        repeatfunction = v
        repeatkey = i
        object.timer = 0.53
      end
    end
    object.timer = object.timer - rbxpure.idelta.time
    if repeatfunction and object.timer < 0 then
      object.timer = 0.031
      repeatfunction()
    end
    if repeatkey and rbxpure.idelta[repeatkey] == -1 then
      repeatfunction = nil
      repeatkey = nil
    end
    if rbxpure.istate.leftalt == 1 then
      for i, v in pairs(repeatalt) do
        apply(i, v)
      end
    elseif rbxpure.istate.leftcontrol == 1 then
      for i, v in pairs(repeatcontrol) do
        apply(i, v)
      end
    else
      for _, v in pairs(keycodes) do
        local str = keystrings[v]
        apply(
          v,
          function()
            insertstring(rbxpure.istate.leftshift == 1 and (modcharacters[str] or str:upper()) or str)
          end
        )
      end
      for i, v in pairs(repeatdefault) do
        apply(i, v)
      end
    end
  end
end
return getfenv(0)
