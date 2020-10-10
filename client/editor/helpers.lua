movecursorvertically = function(this, dir)
  if this.linestarts[this.cursory + dir] and this.linestarts[this.cursory + dir + 1] then
    local e = this.linestarts[this.cursory + dir + 1] - 1
    local old = this.cursorx
    this.cursorposition = math.min(this.linestarts[this.cursory + dir] + this.cursorx, e and e or this.writtencode:len())
    this.cursorx = old
  end
end
pushline = function(this, add)
  local oldy = this.cursory
  local lneg = this.cursory - 1 + add
  local lcenter = this.cursory + add
  local lpos = this.cursory + 1 + add
  if not this.linestarts[lneg] or not this.linestarts[lcenter] or not this.linestarts[lpos] then
    return
  end
  local diff = this.cursorposition - this.linestarts[this.cursory]
  local newstr = this.writtencode:sub(1, this.linestarts[lneg] - 1)
  newstr = newstr .. this.writtencode:sub(this.linestarts[lcenter], this.linestarts[lpos] - 1)
  newstr = newstr .. this.writtencode:sub(this.linestarts[lneg], this.linestarts[lcenter] - 1)
  newstr = newstr .. this.writtencode:sub(this.linestarts[lpos], this.writtencode:len())
  this.writtencode = newstr
  this.cursorposition = this.linestarts[oldy + (add == 0 and -1 or 1)] + diff
end
cursorskip = function(this, dir)
  local offset = dir == -1 and 1 or 0
  local e = dir == -1 and 1 or this.writtencode:len()
  local alpha
  local stopatspace
  local stopatnewline
  for i = this.cursorposition - offset, e, dir do
    local char = this.writtencode:sub(i, i)
    if char == ' ' then
      stopatnewline = true
      if stopatspace then
        this.cursorposition = i + offset
        break
      end
    elseif char == '\n' then
      if stopatnewline then
        this.cursorposition = i + offset
        break
      end
      stopatnewline = true
    else
      stopatspace = true
      stopatnewline = true
      if not alpha then
        alpha = this.writtencode:sub(i, i):find '%w' and '%W' or '%w'
      elseif char:find(alpha) then
        this.cursorposition = i + offset
        break
      end
    end
  end
end
insertstring = function(this, str)
  this.writtencode = this.writtencode:sub(1, this.cursorposition - 1) .. str .. this.writtencode:sub(this.cursorposition)
  this.cursorposition = this.cursorposition + str:len()
end
return getfenv(0)
