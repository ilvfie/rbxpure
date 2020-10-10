modcharacters = {
  ['`'] = '~',
  ['1'] = '!',
  ['2'] = '@',
  ['3'] = '#',
  ['4'] = '$',
  ['5'] = '%',
  ['6'] = '^',
  ['7'] = '&',
  ['8'] = '*',
  ['9'] = '(',
  ['0'] = ')',
  ['-'] = '_',
  ['='] = '+',
  ['['] = '{',
  [']'] = '}',
  ['\\'] = '|',
  [';'] = ':',
  ["'"] = '"',
  [','] = '<',
  ['.'] = '>',
  ['/'] = '?'
}
keycodes = {
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
  'space',
  'backquote',
  'one',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
  'nine',
  'zero',
  'minus',
  'equals',
  'leftbracket',
  'rightbracket',
  'backslash',
  'semicolon',
  'quote',
  'comma',
  'period',
  'slash'
}
template =
  [[local screengui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
local scrollingframe = Instance.new("ScrollingFrame", screengui)
scrollingframe.Size = UDim2.new(1, 0, 1, 36)
scrollingframe.Position = UDim2.new(0, 0, 0, -36)
scrollingframe.CanvasSize = UDim2.new(0, 0, 10, 0)
scrollingframe.BackgroundColor3 = Color3.new(0.12, 0.12, 0.12)
scrollingframe.ScrollingEnabled = false
scrollingframe.ScrollBarThickness = 0
local linenumbers = Instance.new("TextLabel", scrollingframe)
linenumbers.Font = "Code"
linenumbers.TextYAlignment = "Top"
linenumbers.TextXAlignment = "Center"
linenumbers.BackgroundTransparency = 1
linenumbers.TextColor3 = Color3.new(0.5, 0.5, 0.5)
linenumbers.TextStrokeTransparency = 0.8
linenumbers.TextStrokeColor3 = Color3.new(1, 1, 1)
local lineindicator = Instance.new("Frame", scrollingframe)
lineindicator.BorderMode = Enum.BorderMode.Inset
lineindicator.BackgroundColor3 = Color3.new(0.12, 0.12, 0.12)
lineindicator.BorderColor3 = Color3.new(0.15, 0.15, 0.15)]]
keystrings = {}
return getfenv(0)
