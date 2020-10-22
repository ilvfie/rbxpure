_G._hasclickablebutton(
  function()
    _G._hastag(
      "clickablebutton",
      function()
        return true
      end
    )
  end
)
_G._hasclickablebutton(
  function()
    print("hello world")
    _G.TextLabel.Size = UDim2.new(0, 200, 0, 200)
    _G.TextLabel.Text = "hello world"
  end
)
_G {clickablebutton = true}
