rbxpure.texteditor = function(object)
  local cursorx = -1
  local cursory = 0
  local wasnewline
  for i = 1, object.cursorposition do
    if wasnewline then
      wasnewline = false
      cursorx = 0
      cursory = cursory + 1
    else
      cursorx = cursorx + 1
    end
    if object.writtencode:sub(i, i) == '\n' then
      wasnewline = true
    end
  end
  local linenumberpadding = object.textsize * 2
  return {
    ClassName = 'ScreenGui',
    Parent = game.Players.LocalPlayer:WaitForChild('PlayerGui'),
    {
      ClassName = 'ScrollingFrame',
      Size = UDim2.new(1, 0, 1, 36),
      Position = UDim2.new(0, 0, 0, -36),
      BackgroundColor3 = Color3.new(0.1199999999, 0.1199999999, 0.1199999999),
      ScrollingEnabled = false,
      ScrollBarThickness = 0,
      CanvasPosition = Vector2.new(0, object.scrollposition),
      {
        -- line numbers
        ClassName = 'TextLabel',
        Font = 'Code',
        TextYAlignment = 'Top',
        TextXAlignment = 'Center',
        BackgroundTransparency = 1,
        TextColor3 = Color3.new(0.5, 0.5, 0.5),
        TextStrokeTransparency = 0.8,
        TextStrokeColor3 = Color3.new(1, 1, 1)
      },
      {
        -- line indicator
        ClassName = 'Frame',
        BorderMode = Enum.BorderMode.Inset,
        BackgroundColor3 = Color3.new(0.1199999999, 0.1199999999, 0.1199999999),
        BorderColor3 = Color3.new(0.15, 0.15, 0.15),
        Position = UDim2.new(0, linenumberpadding, 0, object.textsize * cursory)
      },
      {
        -- cursor
        Visible = object.cursorvisible,
        Position = UDim2.new(0, linenumberpadding + object.textsize / 2 * object.cursorx, 0, object.textsize * cursory)
      }
    }
  }
end
return getfenv(0)
