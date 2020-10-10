formatlua = function(str)
  local a = str:gsub(' ', '')
  return a
end
parselua = function(str)
  local l = lexlua(str)
  while true do
    local n = l.next()
    if not n then
      break
    end
  end
end
lexlua = function(str)
  local pos = 1
  local line = 1
  local col = 0
  local peekedtoken
  local function nextcharacter()
    local ch = string.sub(str, pos, pos)
    pos = pos + 1
    if ch == '\n' then
      line = line + 1
      col = 0
    else
      col = col + 1
    end
    return ch
  end
  local function peek()
    return string.sub(str, pos, pos)
  end
  local function croak(msg)
    warn(msg .. ' (' .. line .. ':' .. col .. ')')
  end
  local function readwhile(predicate)
    local str1 = ''
    while peek() and predicate(peek()) do
      str1 = str1 .. nextcharacter()
    end
    return str1
  end
  local function charisany(ch, characters)
    for _, v in pairs(characters) do
      if ch == v then
        return true
      end
    end
  end
  local function iskeyword(x)
    return charisany(
      x,
      {
        'if',
        'then',
        'else',
        'true',
        'false'
      }
    )
  end
  local function isidstart(ch)
    return string.find(ch, '[A-Za-z]')
  end
  local function isdigit(ch)
    return charisany(
      ch,
      {
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9'
      }
    )
  end
  local function isid(ch)
    return isidstart(ch) or isdigit(ch)
  end
  local function readident()
    local id = readwhile(isid)
    return {type = iskeyword(id) and 'kw' or 'var', value = id}
  end
  local function readnumber()
    local hasdot = false
    local number =
      readwhile(
      function(ch)
        if ch == '.' then
          if hasdot then
            return false
          end
          hasdot = true
          return true
        end
        return isdigit(ch)
      end
    )
    return {type = 'num', value = tonumber(number)}
  end
  local function isopchar(ch)
    return charisany(
      ch,
      {
        '+',
        '-',
        '*',
        '/',
        '%',
        '=',
        '<',
        '>'
      }
    )
  end
  local function ispunc(ch)
    return charisany(
      ch,
      {
        ',',
        ';',
        '(',
        ')',
        '{',
        '}',
        '[',
        ']',
        ']'
      }
    )
  end
  local function iswhitespace(ch)
    return charisany(ch, {'\t', '\n', ' '})
  end
  local function skipcomment()
    readwhile(
      function(ch)
        return ch ~= '\n'
      end
    )
    nextcharacter()
  end
  local function readescaped(e)
    local escaped = false
    local astr = ''
    nextcharacter()
    while peek() do
      local ch = nextcharacter()
      if escaped then
        astr = astr .. ch
        escaped = false
      elseif ch == '\\' then
        escaped = true
      elseif ch == e then
        break
      else
        astr = astr .. ch
      end
    end
    return astr
  end
  local function readstring()
    return {type = 'str', value = readescaped '"'}
  end
  local function readnext()
    readwhile(iswhitespace)
    local ch = peek()
    if ch == '#' then
      skipcomment()
      return readnext()
    end
    if ch == '"' then
      return readstring()
    end
    if isdigit(ch) then
      return readnumber()
    end
    if isidstart(ch) then
      return readident()
    end
    if ispunc(ch) then
      return {type = 'punc', value = nextcharacter()}
    end
    if isopchar(ch) then
      return {type = 'op', value = readwhile(isopchar)}
    end
    croak('cannot handle character: "' .. ch .. '"')
  end
  return {
    peek = function()
      if not peekedtoken then
        peekedtoken = readnext()
      end
      return peekedtoken
    end,
    next = function()
      local token = peekedtoken
      peekedtoken = nil
      return token or readnext()
    end
  }
end
return getfenv(0)
