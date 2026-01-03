local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Utilities = {}

local ActivePopups = {
    Dropdown = nil,
    Colorpicker = nil,
    Keybind = nil
}

function Utilities:CloseAllPopups(except)
    if ActivePopups.Dropdown and except ~= "Dropdown" then
        ActivePopups.Dropdown:Toggle()
    end
    if ActivePopups.Colorpicker and except ~= "Colorpicker" then
        ActivePopups.Colorpicker:Open()
    end
    if ActivePopups.Keybind and except ~= "Keybind" then
        ActivePopups.Keybind:Open()
    end
end

function Utilities:Tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utilities:MakeDraggable(frame, dragFrame)
    local dragging, dragInput, dragStart, startPos
    dragFrame = dragFrame or frame
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Utilities:Tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
        end
    end)
end

function Utilities:RippleEffect(button)
    button.MouseButton1Click:Connect(function()
        local ripple = Instance.new("Frame")
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.5
        ripple.BorderSizePixel = 0
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.ZIndex = button.ZIndex + 1
        ripple.Parent = button
        local corner = Instance.new("UICorner", ripple)
        corner.CornerRadius = UDim.new(1, 0)
        Utilities:Tween(ripple, {Size = UDim2.new(1.5, 0, 1.5, 0), BackgroundTransparency = 1}, 0.5)
        task.delay(0.5, function() ripple:Destroy() end)
    end)
end

local LayoutOrderCounter = 0
function Utilities:GetOrder()
    LayoutOrderCounter = LayoutOrderCounter + 1
    return LayoutOrderCounter
end

function Library:CreateWindow(config)
    config = config or {}
    config.Name = config.Name or "Lumen"
    config.Icon = config.Icon or "rbxassetid://129947207621414"
    config.Size = config.Size or UDim2.new(0, 681, 0, 480)
    config.Theme = config.Theme or {
        Accent = Color3.fromRGB(117, 139, 211),
        Background = Color3.fromRGB(12, 12, 12),
        SecondaryBackground = Color3.fromRGB(15, 15, 15),
        TertiaryBackground = Color3.fromRGB(22, 22, 22),
        Text = Color3.fromRGB(255, 255, 255),
        SecondaryText = Color3.fromRGB(176, 176, 176)
    }
    
    local Window = {Tabs = {}, CurrentTab = nil, Notifications = {}, Config = config}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Lumen"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "ui"
    MainFrame.BackgroundColor3 = config.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -config.Size.X.Offset/2, 0.5, -config.Size.Y.Offset/2)
    MainFrame.Size = config.Size
    MainFrame.Parent = ScreenGui
    
    Instance.new("UICorner", MainFrame)
    
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness = 2
    MainStroke.Color = Color3.fromRGB(78, 78, 78)
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "tabcontainer"
    TabContainer.BackgroundColor3 = config.Theme.SecondaryBackground
    TabContainer.BorderSizePixel = 0
    TabContainer.Size = UDim2.new(0.12061, 0, 1, 0)
    TabContainer.Parent = MainFrame
    
    Instance.new("UICorner", TabContainer)
    
    local TabSeparator = Instance.new("Frame")
    TabSeparator.Name = "sep"
    TabSeparator.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabSeparator.BorderSizePixel = 0
    TabSeparator.Size = UDim2.new(0, 1, 1, 0)
    TabSeparator.Position = UDim2.new(1, 0, 0, 0)
    TabSeparator.ZIndex = 2
    TabSeparator.Parent = TabContainer
    
    local Icon = Instance.new("ImageLabel")
    Icon.Name = "icon"
    Icon.BackgroundTransparency = 1
    Icon.Image = config.Icon
    Icon.Size = UDim2.new(0, 49, 0, 49)
    Icon.Position = UDim2.new(0.5, -24.5, 0.01875, 0)
    Icon.Parent = TabContainer
    
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "list"
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.Position = UDim2.new(0, 0, 0.15, 0)
    TabList.Size = UDim2.new(1, 0, 0.85, -10)
    TabList.ScrollBarThickness = 2
    TabList.ScrollBarImageColor3 = config.Theme.Accent
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabList.ZIndex = 2
    TabList.Parent = TabContainer
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.Padding = UDim.new(0, 11)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabList
    
    local TabListPadding = Instance.new("UIPadding", TabList)
    TabListPadding.PaddingTop = UDim.new(0, 10)
    
    local TopBar = Instance.new("Frame")
    TopBar.BackgroundColor3 = config.Theme.TertiaryBackground
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(0.87819, 0, 0.09405, 0)
    TopBar.Position = UDim2.new(0.12181, 0, 0, 0)
    TopBar.Parent = MainFrame
    
    Instance.new("UICorner", TopBar)
    
    local TopBarSep = Instance.new("Frame")
    TopBarSep.Name = "sep"
    TopBarSep.BackgroundColor3 = config.Theme.TertiaryBackground
    TopBarSep.BorderSizePixel = 0
    TopBarSep.Size = UDim2.new(1.001, 0, 0.08, 1)
    TopBarSep.Position = UDim2.new(0, -1, 0, 43)
    TopBarSep.ZIndex = 2
    TopBarSep.Parent = TopBar
    
    local SubtabContainer = Instance.new("Frame")
    SubtabContainer.Name = "subtab"
    SubtabContainer.BackgroundTransparency = 1
    SubtabContainer.Position = UDim2.new(0, 14, 0, 14)
    SubtabContainer.Size = UDim2.new(0.714, -30, 0.19, 24)
    SubtabContainer.ZIndex = 2
    SubtabContainer.Parent = TopBar
    
    local SubtabLayout = Instance.new("UIListLayout")
    SubtabLayout.Padding = UDim.new(0, 10)
    SubtabLayout.FillDirection = Enum.FillDirection.Horizontal
    SubtabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SubtabLayout.Parent = SubtabContainer
    
    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "search"
    SearchBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    SearchBox.BorderSizePixel = 0
    SearchBox.Position = UDim2.new(0, 420, 0, 12)
    SearchBox.Size = UDim2.new(0, 166, 0, 26)
    SearchBox.Font = Enum.Font.GothamSemibold
    SearchBox.PlaceholderText = "Search for a feature"
    SearchBox.PlaceholderColor3 = Color3.fromRGB(125, 125, 126)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize = 14
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.ZIndex = 2
    SearchBox.Parent = TopBar
    
    local SearchCorner = Instance.new("UICorner", SearchBox)
    SearchCorner.CornerRadius = UDim.new(0, 5)
    
    local SearchStroke = Instance.new("UIStroke", SearchBox)
    SearchStroke.Color = Color3.fromRGB(25, 25, 25)
    SearchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local SearchPadding = Instance.new("UIPadding", SearchBox)
    SearchPadding.PaddingLeft = UDim.new(0, 8)
    
    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Name = "content"
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Position = UDim2.new(0.14237, 0, 0.12499, 0)
    ContentContainer.Size = UDim2.new(0, 571, 0, 403)
    ContentContainer.ScrollBarThickness = 8
    ContentContainer.ScrollBarImageColor3 = config.Theme.Accent
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentContainer.Parent = MainFrame
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 21)
    ContentLayout.FillDirection = Enum.FillDirection.Horizontal
    ContentLayout.Wraps = true
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = ContentContainer
    
    local ContentPadding = Instance.new("UIPadding", ContentContainer)
    ContentPadding.PaddingTop = UDim.new(0, 5)
    ContentPadding.PaddingLeft = UDim.new(0, 5)
    
    local PopupHolder = Instance.new("Frame")
    PopupHolder.Name = "popups"
    PopupHolder.BackgroundTransparency = 1
    PopupHolder.Size = UDim2.new(1, 0, 1, 0)
    PopupHolder.ZIndex = 100
    PopupHolder.Parent = ScreenGui
    
    Utilities:MakeDraggable(MainFrame, TopBar)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            task.delay(0.05, function()
                if ActivePopups.Dropdown and ActivePopups.Dropdown.DropdownList then
                    local mousePos = UserInputService:GetMouseLocation()
                    local list = ActivePopups.Dropdown.DropdownList
                    local inBounds = mousePos.X >= list.AbsolutePosition.X and 
                                     mousePos.X <= list.AbsolutePosition.X + list.AbsoluteSize.X and
                                     mousePos.Y >= list.AbsolutePosition.Y and 
                                     mousePos.Y <= list.AbsolutePosition.Y + list.AbsoluteSize.Y
                    if not inBounds then
                        ActivePopups.Dropdown:Close()
                    end
                end
                
                if ActivePopups.Colorpicker and ActivePopups.Colorpicker.ColorWindow then
                    local mousePos = UserInputService:GetMouseLocation()
                    local win = ActivePopups.Colorpicker.ColorWindow
                    local inBounds = mousePos.X >= win.AbsolutePosition.X and 
                                     mousePos.X <= win.AbsolutePosition.X + win.AbsoluteSize.X and
                                     mousePos.Y >= win.AbsolutePosition.Y and 
                                     mousePos.Y <= win.AbsolutePosition.Y + win.AbsoluteSize.Y
                    if not inBounds then
                        ActivePopups.Colorpicker:Close()
                    end
                end
                
                if ActivePopups.Keybind and ActivePopups.Keybind.KeybindWindow then
                    local mousePos = UserInputService:GetMouseLocation()
                    local win = ActivePopups.Keybind.KeybindWindow
                    local inBounds = mousePos.X >= win.AbsolutePosition.X and 
                                     mousePos.X <= win.AbsolutePosition.X + win.AbsoluteSize.X and
                                     mousePos.Y >= win.AbsolutePosition.Y and 
                                     mousePos.Y <= win.AbsolutePosition.Y + win.AbsoluteSize.Y
                    if not inBounds then
                        ActivePopups.Keybind:Close()
                    end
                end
            end)
        end
    end)
    
    local UIOpen = true
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            UIOpen = not UIOpen
            Utilities:Tween(MainFrame, {Size = UIOpen and config.Size or UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back)
        end
    end)
    
    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    Window.TabContainer = TabContainer
    Window.TabList = TabList
    Window.TopBar = TopBar
    Window.SubtabContainer = SubtabContainer
    Window.ContentContainer = ContentContainer
    Window.PopupHolder = PopupHolder
    
    return setmetatable(Window, {__index = Library})
end

function Library:CreateTab(config)
    config = config or {}
    config.Name = config.Name or "Tab"
    config.Icon = config.Icon or "rbxassetid://82741456353014"
    
    local Tab = {Name = config.Name, Icon = config.Icon, Subtabs = {}, Sections = {}, Active = false, Window = self}
    
    local TabButton = Instance.new("Frame")
    TabButton.BackgroundTransparency = 1
    TabButton.Size = UDim2.new(0, 47, 0, 47)
    TabButton.LayoutOrder = #self.Tabs + 1
    TabButton.Parent = self.TabList
    
    local TabButtonCorner = Instance.new("UICorner", TabButton)
    TabButtonCorner.CornerRadius = UDim.new(0, 999)
    
    local TabButtonGradient = Instance.new("UIGradient", TabButton)
    TabButtonGradient.Enabled = false
    TabButtonGradient.Rotation = 90
    TabButtonGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(117, 139, 211)),
        ColorSequenceKeypoint.new(0.324, Color3.fromRGB(105, 124, 189)),
        ColorSequenceKeypoint.new(0.600, Color3.fromRGB(89, 106, 160)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 58, 85))
    }
    
    local TabIcon = Instance.new("ImageButton")
    TabIcon.Name = "button"
    TabIcon.BackgroundTransparency = 1
    TabIcon.Size = UDim2.new(0, 21, 0, 21)
    TabIcon.Position = UDim2.new(0.5, -10.5, 0.5, -10.5)
    TabIcon.Image = config.Icon
    TabIcon.ImageColor3 = Color3.fromRGB(111, 111, 111)
    TabIcon.AutoButtonColor = false
    TabIcon.ZIndex = 2
    TabIcon.Parent = TabButton
    
    local TabContent = Instance.new("Frame")
    TabContent.Name = config.Name
    TabContent.BackgroundTransparency = 1
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.Visible = false
    TabContent.Parent = self.ContentContainer
    
    local TabContentLayout = Instance.new("UIListLayout")
    TabContentLayout.Padding = UDim.new(0, 21)
    TabContentLayout.FillDirection = Enum.FillDirection.Horizontal
    TabContentLayout.Wraps = true
    TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabContentLayout.Parent = TabContent
    
    TabIcon.MouseEnter:Connect(function()
        if not Tab.Active then
            Utilities:Tween(TabIcon, {ImageColor3 = Color3.fromRGB(160, 160, 160)}, 0.2)
            Utilities:Tween(TabButton, {BackgroundTransparency = 0.7}, 0.2)
        end
    end)
    
    TabIcon.MouseLeave:Connect(function()
        if not Tab.Active then
            Utilities:Tween(TabIcon, {ImageColor3 = Color3.fromRGB(111, 111, 111)}, 0.2)
            Utilities:Tween(TabButton, {BackgroundTransparency = 1}, 0.2)
        end
    end)
    
    TabIcon.MouseButton1Down:Connect(function()
        if not Tab.Active then
            Utilities:Tween(TabButton, {BackgroundTransparency = 0.5}, 0.1)
            Utilities:Tween(TabIcon, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0.5, -9, 0.5, -9)}, 0.1)
        end
    end)
    
    TabIcon.MouseButton1Up:Connect(function()
        Utilities:Tween(TabIcon, {Size = UDim2.new(0, 21, 0, 21), Position = UDim2.new(0.5, -10.5, 0.5, -10.5)}, 0.1)
    end)
    
    Utilities:RippleEffect(TabIcon)
    TabIcon.MouseButton1Click:Connect(function()
        Utilities:CloseAllPopups()
        self:SelectTab(Tab)
    end)
    
    Tab.Button = TabButton
    Tab.ButtonGradient = TabButtonGradient
    Tab.IconButton = TabIcon
    Tab.Content = TabContent
    Tab.Window = self
    
    table.insert(self.Tabs, Tab)
    
    if #self.Tabs == 1 then
        self:SelectTab(Tab)
    end
    
    return setmetatable(Tab, {__index = Library})
end

function Library:SelectTab(tab)
    for _, t in pairs(self.Tabs) do
        if t.Active then
            t.Active = false
            t.ButtonGradient.Enabled = false
            Utilities:Tween(t.Button, {BackgroundTransparency = 1}, 0.25)
            Utilities:Tween(t.IconButton, {ImageColor3 = Color3.fromRGB(111, 111, 111)}, 0.25)
            t.Content.Visible = false
        end
    end
    
    tab.Active = true
    tab.ButtonGradient.Enabled = true
    Utilities:Tween(tab.Button, {BackgroundTransparency = 0}, 0.25)
    Utilities:Tween(tab.IconButton, {ImageColor3 = Color3.fromRGB(0, 0, 0)}, 0.25)
    tab.Content.Visible = true
    
    for _, child in pairs(self.SubtabContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    if #tab.Subtabs > 0 then
        for _, subtab in pairs(tab.Subtabs) do
            self:CreateSubtabButton(tab, subtab)
        end
    end
    
    self.CurrentTab = tab
end

function Library:CreateSubtab(config)
    config = config or {}
    config.Name = config.Name or "Subtab"
    
    local Subtab = {Name = config.Name, Sections = {}, Active = false, Tab = self}
    
    local SubtabContent = Instance.new("Frame")
    SubtabContent.Name = config.Name
    SubtabContent.BackgroundTransparency = 1
    SubtabContent.Size = UDim2.new(1, 0, 1, 0)
    SubtabContent.Visible = false
    SubtabContent.Parent = self.Content
    
    local SubtabContentLayout = Instance.new("UIListLayout")
    SubtabContentLayout.Padding = UDim.new(0, 21)
    SubtabContentLayout.FillDirection = Enum.FillDirection.Horizontal
    SubtabContentLayout.Wraps = true
    SubtabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SubtabContentLayout.Parent = SubtabContent
    
    Subtab.Content = SubtabContent
    Subtab.LayoutOrder = #self.Subtabs + 1
    
    table.insert(self.Subtabs, Subtab)
    
    if #self.Subtabs == 1 then
        Subtab.Active = true
        SubtabContent.Visible = true
    end
    
    if self.Active then
        self.Window:CreateSubtabButton(self, Subtab)
    end
    
    return setmetatable(Subtab, {__index = Library})
end

function Library:CreateSubtabButton(tab, subtab)
    local SubtabButton = Instance.new("Frame")
    SubtabButton.Name = "subtab_" .. subtab.Name
    SubtabButton.BackgroundColor3 = subtab.Active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(10, 10, 10)
    SubtabButton.BorderSizePixel = 0
    SubtabButton.Size = UDim2.new(0, 0, 0, 24)
    SubtabButton.LayoutOrder = subtab.LayoutOrder or 1
    SubtabButton.ClipsDescendants = true
    SubtabButton.BackgroundTransparency = 1
    SubtabButton.Parent = self.SubtabContainer
    
    local SubtabCorner = Instance.new("UICorner", SubtabButton)
    SubtabCorner.CornerRadius = UDim.new(0, 5)
    
    local SubtabGradient = Instance.new("UIGradient", SubtabButton)
    SubtabGradient.Enabled = subtab.Active
    SubtabGradient.Rotation = 90
    SubtabGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(117, 139, 211)),
        ColorSequenceKeypoint.new(0.324, Color3.fromRGB(105, 124, 189)),
        ColorSequenceKeypoint.new(0.600, Color3.fromRGB(89, 106, 160)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 58, 85))
    }
    
    local SubtabLabel = Instance.new("TextLabel")
    SubtabLabel.BackgroundTransparency = 1
    SubtabLabel.Size = UDim2.new(1, 0, 1, 0)
    SubtabLabel.Font = Enum.Font.GothamSemibold
    SubtabLabel.Text = subtab.Name
    SubtabLabel.TextColor3 = subtab.Active and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(111, 111, 111)
    SubtabLabel.TextSize = 14
    SubtabLabel.TextTransparency = 1
    SubtabLabel.Parent = SubtabButton
    
    local SubtabClick = Instance.new("TextButton")
    SubtabClick.BackgroundTransparency = 1
    SubtabClick.Size = UDim2.new(1, 0, 1, 0)
    SubtabClick.Text = ""
    SubtabClick.Parent = SubtabButton
    
    -- Animate subtab button appearance
    task.spawn(function()
        task.wait(0.05 * (subtab.LayoutOrder or 1))
        
        Utilities:Tween(SubtabButton, {
            Size = UDim2.new(0, 80, 0, 24),
            BackgroundTransparency = 0
        }, 0.4, Enum.EasingStyle.Back)
        
        task.wait(0.1)
        Utilities:Tween(SubtabLabel, {TextTransparency = 0}, 0.3)
    end)
    
    -- Hover animations
    local hovering = false
    SubtabButton.MouseEnter:Connect(function()
        if not subtab.Active and not hovering then
            hovering = true
            Utilities:Tween(SubtabButton, {
                Size = UDim2.new(0, 85, 0, 26),
                BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            }, 0.15)
            Utilities:Tween(SubtabLabel, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.15)
        end
    end)
    
    SubtabButton.MouseLeave:Connect(function()
        if not subtab.Active and hovering then
            hovering = false
            Utilities:Tween(SubtabButton, {
                Size = UDim2.new(0, 80, 0, 24),
                BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            }, 0.15)
            Utilities:Tween(SubtabLabel, {TextColor3 = Color3.fromRGB(111, 111, 111)}, 0.15)
        end
    end)
    
    Utilities:RippleEffect(SubtabClick)
    SubtabClick.MouseButton1Click:Connect(function()
        -- Prevent double click during animation
        if tab.Switching then return end
        if subtab.Active then return end
        
        tab.Switching = true
        
        -- Find current active subtab and animate out
        for _, st in pairs(tab.Subtabs) do
            if st.Active then
                st.Active = false
                
                -- Fade out content
                if st.Content then
                    for _, section in pairs(st.Content:GetChildren()) do
                        if section:IsA("Frame") then
                            Utilities:Tween(section, {BackgroundTransparency = 1}, 0.15)
                        end
                    end
                    
                    task.delay(0.15, function()
                        st.Content.Visible = false
                    end)
                end
            end
        end
        
        -- Update button visuals immediately without recreating
        for _, child in pairs(self.SubtabContainer:GetChildren()) do
            if child:IsA("Frame") and child.Name:find("subtab_") then
                local isActive = child.Name == "subtab_" .. subtab.Name
                local gradient = child:FindFirstChildOfClass("UIGradient")
                local label = child:FindFirstChildOfClass("TextLabel")
                
                if gradient then
                    gradient.Enabled = isActive
                end
                
                Utilities:Tween(child, {
                    BackgroundColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(10, 10, 10),
                    Size = UDim2.new(0, 80, 0, 24)
                }, 0.25, Enum.EasingStyle.Quad)
                
                if label then
                    Utilities:Tween(label, {
                        TextColor3 = isActive and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(111, 111, 111)
                    }, 0.25)
                end
            end
        end
        
        -- Activate new subtab
        subtab.Active = true
        
        task.delay(0.15, function()
            subtab.Content.Visible = true
            
            -- Animate content in
            for i, section in pairs(subtab.Content:GetChildren()) do
                if section:IsA("Frame") then
                    section.BackgroundTransparency = 1
                    
                    task.spawn(function()
                        task.wait(0.03 * i)
                        Utilities:Tween(section, {BackgroundTransparency = 0}, 0.25, Enum.EasingStyle.Quad)
                    end)
                end
            end
            
            task.delay(0.3, function()
                tab.Switching = false
            end)
        end)
    end)
end

function Library:CreateSection(config)
    config = config or {}
    config.Name = config.Name or "Section"
    config.Icon = config.Icon or "rbxassetid://18821845145"
    
    local Section = {Name = config.Name, Elements = {}, ElementOrder = 0}
    
    local parent = self.Content or self.Window.ContentContainer
    
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = "section"
    SectionFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    SectionFrame.BorderSizePixel = 0
    SectionFrame.Size = UDim2.new(0.46585, 0, 0, 0)
    SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
    SectionFrame.ZIndex = 4
    SectionFrame.LayoutOrder = Utilities:GetOrder()
    SectionFrame.Parent = parent
    
    local SectionCorner = Instance.new("UICorner", SectionFrame)
    SectionCorner.CornerRadius = UDim.new(0, 3)
    
    local SectionStroke = Instance.new("UIStroke", SectionFrame)
    SectionStroke.Color = Color3.fromRGB(25, 25, 25)
    SectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local SectionPadding = Instance.new("UIPadding", SectionFrame)
    SectionPadding.PaddingBottom = UDim.new(0, 12)
    
    local SectionTop = Instance.new("Frame")
    SectionTop.Name = "top"
    SectionTop.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    SectionTop.BorderSizePixel = 0
    SectionTop.Size = UDim2.new(1, 0, 0, 30)
    SectionTop.Parent = SectionFrame
    
    local SectionTopCorner = Instance.new("UICorner", SectionTop)
    SectionTopCorner.CornerRadius = UDim.new(0, 3)
    
    local SectionIcon = Instance.new("ImageLabel")
    SectionIcon.Name = "icon"
    SectionIcon.BackgroundTransparency = 1
    SectionIcon.Image = config.Icon
    SectionIcon.Size = UDim2.new(0, 14, 0, 14)
    SectionIcon.Position = UDim2.new(0, 13, 0.5, 0)
    SectionIcon.AnchorPoint = Vector2.new(0, 0.5)
    SectionIcon.Parent = SectionTop
    
    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Name = "title"
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Position = UDim2.new(0, 33, 0, 0)
    SectionTitle.Size = UDim2.new(1, -33, 1, 0)
    SectionTitle.Font = Enum.Font.GothamSemibold
    SectionTitle.Text = config.Name
    SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SectionTitle.TextSize = 14
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.ZIndex = 4
    SectionTitle.Parent = SectionTop
    
    local Container = Instance.new("Frame")
    Container.Name = "CONTAINER"
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 10, 0, 38)
    Container.Size = UDim2.new(1, -20, 0, 0)
    Container.AutomaticSize = Enum.AutomaticSize.Y
    Container.Parent = SectionFrame
    
    local ContainerLayout = Instance.new("UIListLayout")
    ContainerLayout.Padding = UDim.new(0, 7)
    ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContainerLayout.Parent = Container
    
    Section.Frame = SectionFrame
    Section.Container = Container
    Section.Window = self.Window or self
    
    if self.Sections then
        table.insert(self.Sections, Section)
    end
    
    return setmetatable(Section, {__index = Library})
end

function Library:CreateToggle(config)
    config = config or {}
    config.Name = config.Name or "Toggle"
    config.Default = config.Default or false
    config.Callback = config.Callback or function() end
    
    self.ElementOrder = (self.ElementOrder or 0) + 1
    
    local Toggle = {Value = config.Default, Callback = config.Callback, Title = config.Name, Section = self}
    
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "toggle"
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Size = UDim2.new(1, 0, 0, 22)
    ToggleFrame.LayoutOrder = self.ElementOrder
    ToggleFrame.Parent = self.Container
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "toggleb"
    ToggleButton.BackgroundColor3 = config.Default and Color3.fromRGB(117, 139, 211) or Color3.fromRGB(22, 22, 22)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Position = UDim2.new(0, 0, 0.5, 0)
    ToggleButton.AnchorPoint = Vector2.new(0, 0.5)
    ToggleButton.Size = UDim2.new(0, 33, 0, 18)
    ToggleButton.AutoButtonColor = false
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    local ToggleCorner = Instance.new("UICorner", ToggleButton)
    ToggleCorner.CornerRadius = UDim.new(0, 999)
    
    local ToggleGradient = Instance.new("UIGradient", ToggleButton)
    ToggleGradient.Rotation = 90
    ToggleGradient.Enabled = config.Default
    ToggleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(117, 139, 211)),
        ColorSequenceKeypoint.new(0.324, Color3.fromRGB(105, 124, 189)),
        ColorSequenceKeypoint.new(0.600, Color3.fromRGB(89, 106, 160)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 58, 85))
    }
    
    local ToggleBall = Instance.new("Frame")
    ToggleBall.Name = "ball"
    ToggleBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBall.BorderSizePixel = 0
    ToggleBall.Size = UDim2.new(0, 12, 0, 12)
    ToggleBall.Position = config.Default and UDim2.new(0, 18, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    ToggleBall.AnchorPoint = Vector2.new(0, 0.5)
    ToggleBall.Parent = ToggleButton
    
    local ToggleBallCorner = Instance.new("UICorner", ToggleBall)
    ToggleBallCorner.CornerRadius = UDim.new(0, 999)
    
    local ToggleTitle = Instance.new("TextLabel")
    ToggleTitle.Name = "title"
    ToggleTitle.BackgroundTransparency = 1
    ToggleTitle.Position = UDim2.new(0, 43, 0, 0)
    ToggleTitle.Size = UDim2.new(1, -100, 1, 0)
    ToggleTitle.Font = Enum.Font.GothamSemibold
    ToggleTitle.Text = config.Name
    ToggleTitle.TextColor3 = Color3.fromRGB(246, 246, 246)
    ToggleTitle.TextSize = 14
    ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    ToggleTitle.Parent = ToggleFrame
    
    local AccessoryList = Instance.new("Frame")
    AccessoryList.Name = "list"
    AccessoryList.BackgroundTransparency = 1
    AccessoryList.Position = UDim2.new(1, 0, 0.5, 0)
    AccessoryList.AnchorPoint = Vector2.new(1, 0.5)
    AccessoryList.Size = UDim2.new(0, 0, 0, 22)
    AccessoryList.AutomaticSize = Enum.AutomaticSize.X
    AccessoryList.Parent = ToggleFrame
    
    local AccessoryLayout = Instance.new("UIListLayout")
    AccessoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    AccessoryLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    AccessoryLayout.FillDirection = Enum.FillDirection.Horizontal
    AccessoryLayout.Padding = UDim.new(0, 7)
    AccessoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
    AccessoryLayout.Parent = AccessoryList
    
    function Toggle:Set(value)
        self.Value = value
        Utilities:Tween(ToggleBall, {Position = value and UDim2.new(0, 18, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, 0.2)
        Utilities:Tween(ToggleButton, {BackgroundColor3 = value and Color3.fromRGB(117, 139, 211) or Color3.fromRGB(22, 22, 22)}, 0.2)
        ToggleGradient.Enabled = value
        task.spawn(self.Callback, value)
    end
    
    function Toggle:CreateColorpicker(cpconfig)
        cpconfig = cpconfig or {}
        cpconfig.Name = cpconfig.Name or "Color"
        cpconfig.Default = cpconfig.Default or Color3.fromRGB(255, 0, 0)
        cpconfig.Callback = cpconfig.Callback or function() end
        
        local Colorpicker = {Value = cpconfig.Default, Callback = cpconfig.Callback, Title = cpconfig.Name, ColorWindow = nil, IsOpen = false}
        
        local ColorButton = Instance.new("TextButton")
        ColorButton.Name = "colorpicker"
        ColorButton.BackgroundColor3 = cpconfig.Default
        ColorButton.BorderSizePixel = 0
        ColorButton.Size = UDim2.new(0, 18, 0, 18)
        ColorButton.Text = ""
        ColorButton.AutoButtonColor = false
        ColorButton.LayoutOrder = 2
        ColorButton.ZIndex = 4
        ColorButton.Parent = AccessoryList
        
        local ColorButtonCorner = Instance.new("UICorner", ColorButton)
        ColorButtonCorner.CornerRadius = UDim.new(0, 4)
        
        local ColorButtonStroke = Instance.new("UIStroke", ColorButton)
        ColorButtonStroke.Color = Color3.fromRGB(40, 40, 40)
        ColorButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        
        function Colorpicker:Set(color)
            self.Value = color
            ColorButton.BackgroundColor3 = color
            task.spawn(self.Callback, color)
        end
        
        function Colorpicker:UpdatePosition()
            if not self.ColorWindow then return end
            local buttonPos = ColorButton.AbsolutePosition
            local buttonSize = ColorButton.AbsoluteSize
            self.ColorWindow.Position = UDim2.new(0, buttonPos.X - 180, 0, buttonPos.Y + buttonSize.Y + 5)
        end
        
        function Colorpicker:Close()
            if not self.IsOpen then return end
            self.IsOpen = false
            ActivePopups.Colorpicker = nil
            
            if self.ColorWindow then
                Utilities:Tween(self.ColorWindow, {Size = UDim2.new(0, 200, 0, 0)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                task.delay(0.2, function()
                    if self.ColorWindow then
                        self.ColorWindow:Destroy()
                        self.ColorWindow = nil
                    end
                end)
            end
        end
        
        function Colorpicker:Open()
            if self.IsOpen then
                self:Close()
                return
            end
            
            Utilities:CloseAllPopups("Colorpicker")
            self.IsOpen = true
            ActivePopups.Colorpicker = self
            
            local ScreenGui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Lumen")
            if not ScreenGui then return end
            
            local PopupHolder = ScreenGui:FindFirstChild("popups")
            if not PopupHolder then return end
            
            local buttonPos = ColorButton.AbsolutePosition
            local buttonSize = ColorButton.AbsoluteSize
            
            local ColorWindow = Instance.new("Frame")
            ColorWindow.Name = "coloredit"
            ColorWindow.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            ColorWindow.BorderSizePixel = 0
            ColorWindow.Size = UDim2.new(0, 200, 0, 0)
            ColorWindow.Position = UDim2.new(0, buttonPos.X - 180, 0, buttonPos.Y + buttonSize.Y + 5)
            ColorWindow.ClipsDescendants = true
            ColorWindow.ZIndex = 100
            ColorWindow.Parent = PopupHolder
            
            self.ColorWindow = ColorWindow
            
            Instance.new("UICorner", ColorWindow)
            
            local ColorWindowStroke = Instance.new("UIStroke", ColorWindow)
            ColorWindowStroke.Thickness = 2
            ColorWindowStroke.Color = Color3.fromRGB(78, 78, 78)
            
            local TopBar = Instance.new("Frame")
            TopBar.Name = "top"
            TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            TopBar.Size = UDim2.new(1, 0, 0, 28)
            TopBar.ZIndex = 100
            TopBar.Parent = ColorWindow
            Instance.new("UICorner", TopBar)
            
            local TopBarTitle = Instance.new("TextLabel")
            TopBarTitle.BackgroundTransparency = 1
            TopBarTitle.Position = UDim2.new(0, 10, 0, 0)
            TopBarTitle.Size = UDim2.new(0.7, 0, 1, 0)
            TopBarTitle.Font = Enum.Font.GothamSemibold
            TopBarTitle.Text = cpconfig.Name
            TopBarTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            TopBarTitle.TextSize = 12
            TopBarTitle.TextXAlignment = Enum.TextXAlignment.Left
            TopBarTitle.ZIndex = 100
            TopBarTitle.Parent = TopBar
            
            local CloseButton = Instance.new("ImageButton")
            CloseButton.BackgroundTransparency = 1
            CloseButton.Position = UDim2.new(1, -25, 0.5, 0)
            CloseButton.AnchorPoint = Vector2.new(0, 0.5)
            CloseButton.Size = UDim2.new(0, 16, 0, 16)
            CloseButton.Image = "rbxassetid://10137832201"
            CloseButton.ImageColor3 = Color3.fromRGB(111, 111, 111)
            CloseButton.ZIndex = 100
            CloseButton.Parent = TopBar
            
            CloseButton.MouseButton1Click:Connect(function()
                self:Close()
            end)
            
            local h, s, v = self.Value:ToHSV()
            local hue, sat, val = h, s, v
            
            local ColorPalette = Instance.new("TextButton")
            ColorPalette.Name = "palette"
            ColorPalette.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            ColorPalette.Position = UDim2.new(0, 10, 0, 38)
            ColorPalette.Size = UDim2.new(1, -20, 0, 120)
            ColorPalette.Text = ""
            ColorPalette.AutoButtonColor = false
            ColorPalette.ZIndex = 100
            ColorPalette.Parent = ColorWindow
            Instance.new("UICorner", ColorPalette).CornerRadius = UDim.new(0, 4)
            
            local WhiteGradient = Instance.new("Frame")
            WhiteGradient.Size = UDim2.new(1, 0, 1, 0)
            WhiteGradient.ZIndex = 101
            WhiteGradient.BorderSizePixel = 0
            WhiteGradient.Parent = ColorPalette
            Instance.new("UICorner", WhiteGradient).CornerRadius = UDim.new(0, 4)
            local wg = Instance.new("UIGradient", WhiteGradient)
            wg.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}
            
            local BlackGradient = Instance.new("Frame")
            BlackGradient.Size = UDim2.new(1, 0, 1, 0)
            BlackGradient.BackgroundColor3 = Color3.new(0, 0, 0)
            BlackGradient.ZIndex = 102
            BlackGradient.BorderSizePixel = 0
            BlackGradient.Parent = ColorPalette
            Instance.new("UICorner", BlackGradient).CornerRadius = UDim.new(0, 4)
            local bg = Instance.new("UIGradient", BlackGradient)
            bg.Rotation = 270
            bg.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}
            
            local ColorSelector = Instance.new("Frame")
            ColorSelector.Size = UDim2.new(0, 12, 0, 12)
            ColorSelector.Position = UDim2.new(sat, 0, 1 - val, 0)
            ColorSelector.AnchorPoint = Vector2.new(0.5, 0.5)
            ColorSelector.BackgroundColor3 = Color3.new(1, 1, 1)
            ColorSelector.ZIndex = 105
            ColorSelector.BorderSizePixel = 0
            ColorSelector.Parent = ColorPalette
            Instance.new("UICorner", ColorSelector).CornerRadius = UDim.new(1, 0)
            Instance.new("UIStroke", ColorSelector).Color = Color3.new(1, 1, 1)
            
            local HueBar = Instance.new("TextButton")
            HueBar.Position = UDim2.new(0, 10, 0, 168)
            HueBar.Size = UDim2.new(1, -20, 0, 16)
            HueBar.Text = ""
            HueBar.AutoButtonColor = false
            HueBar.ZIndex = 100
            HueBar.BorderSizePixel = 0
            HueBar.Parent = ColorWindow
            Instance.new("UICorner", HueBar).CornerRadius = UDim.new(0, 6)
            
            local HueGradient = Instance.new("UIGradient", HueBar)
            HueGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            }
            
            local HueSelector = Instance.new("Frame")
            HueSelector.Size = UDim2.new(0, 12, 0, 12)
            HueSelector.Position = UDim2.new(hue, 0, 0.5, 0)
            HueSelector.AnchorPoint = Vector2.new(0.5, 0.5)
            HueSelector.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            HueSelector.ZIndex = 105
            HueSelector.BorderSizePixel = 0
            HueSelector.Parent = HueBar
            Instance.new("UICorner", HueSelector).CornerRadius = UDim.new(1, 0)
            Instance.new("UIStroke", HueSelector).Color = Color3.new(1, 1, 1)
            
            Utilities:Tween(ColorWindow, {Size = UDim2.new(0, 200, 0, 200)}, 0.25, Enum.EasingStyle.Back)
            
            local colorDragging = false
            local hueDragging = false
            
            local function updateColor()
                Colorpicker:Set(Color3.fromHSV(hue, sat, val))
            end
            
            ColorPalette.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    colorDragging = true
                end
            end)
            
            ColorPalette.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    colorDragging = false
                end
            end)
            
            HueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    hueDragging = true
                end
            end)
            
            HueBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    hueDragging = false
                end
            end)
            
            local conn
            conn = UserInputService.InputChanged:Connect(function(input)
                if not self.ColorWindow then conn:Disconnect() return end
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if colorDragging then
                        local rel = (Vector2.new(input.Position.X, input.Position.Y) - ColorPalette.AbsolutePosition) / ColorPalette.AbsoluteSize
                        sat = math.clamp(rel.X, 0, 1)
                        val = 1 - math.clamp(rel.Y, 0, 1)
                        ColorSelector.Position = UDim2.new(sat, 0, 1 - val, 0)
                        updateColor()
                    elseif hueDragging then
                        local rel = (input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X
                        hue = math.clamp(rel, 0, 1)
                        HueSelector.Position = UDim2.new(hue, 0, 0.5, 0)
                        HueSelector.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        ColorPalette.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        updateColor()
                    end
                end
            end)
            
            local posConn
            posConn = RunService.RenderStepped:Connect(function()
                if not self.ColorWindow or not self.IsOpen then 
                    if posConn then posConn:Disconnect() end
                    return 
                end
                self:UpdatePosition()
            end)
        end
        
        ColorButton.MouseButton1Click:Connect(function()
            Colorpicker:Open()
        end)
        
        Colorpicker.Button = ColorButton
        return Colorpicker
    end

    function Toggle:CreateKeybind(kbconfig)
        kbconfig = kbconfig or {}
        kbconfig.Default = kbconfig.Default or Enum.KeyCode.Unknown
        kbconfig.Mode = kbconfig.Mode or "Toggle"
        kbconfig.Callback = kbconfig.Callback or function() end
        
        local Keybind = {Key = kbconfig.Default, Mode = kbconfig.Mode, Callback = kbconfig.Callback, Binding = false, KeybindWindow = nil, IsOpen = false}
        
        local SettingButton = Instance.new("ImageButton")
        SettingButton.Name = "setting"
        SettingButton.BackgroundTransparency = 1
        SettingButton.Size = UDim2.new(0, 18, 0, 18)
        SettingButton.Image = "rbxassetid://128797200442698"
        SettingButton.LayoutOrder = 1
        SettingButton.ZIndex = 4
        SettingButton.Parent = AccessoryList
        
        function Keybind:Set(key)
            self.Key = key
        end
        
        function Keybind:UpdatePosition()
            if not self.KeybindWindow then return end
            local buttonPos = SettingButton.AbsolutePosition
            local buttonSize = SettingButton.AbsoluteSize
            self.KeybindWindow.Position = UDim2.new(0, buttonPos.X - 160, 0, buttonPos.Y + buttonSize.Y + 5)
        end
        
        function Keybind:Close()
            if not self.IsOpen then return end
            self.IsOpen = false
            ActivePopups.Keybind = nil
            
            if self.KeybindWindow then
                Utilities:Tween(self.KeybindWindow, {Size = UDim2.new(0, 180, 0, 0)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                task.delay(0.2, function()
                    if self.KeybindWindow then
                        self.KeybindWindow:Destroy()
                        self.KeybindWindow = nil
                    end
                end)
            end
        end
        
        function Keybind:Open()
            if self.IsOpen then
                self:Close()
                return
            end
            
            Utilities:CloseAllPopups("Keybind")
            self.IsOpen = true
            ActivePopups.Keybind = self
            
            local ScreenGui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Lumen")
            if not ScreenGui then return end
            
            local PopupHolder = ScreenGui:FindFirstChild("popups")
            if not PopupHolder then return end
            
            local buttonPos = SettingButton.AbsolutePosition
            local buttonSize = SettingButton.AbsoluteSize
            
            local KeybindWindow = Instance.new("Frame")
            KeybindWindow.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            KeybindWindow.Size = UDim2.new(0, 180, 0, 0)
            KeybindWindow.Position = UDim2.new(0, buttonPos.X - 160, 0, buttonPos.Y + buttonSize.Y + 5)
            KeybindWindow.ClipsDescendants = true
            KeybindWindow.ZIndex = 100
            KeybindWindow.Parent = PopupHolder
            
            self.KeybindWindow = KeybindWindow
            
            Instance.new("UICorner", KeybindWindow)
            local kbStroke = Instance.new("UIStroke", KeybindWindow)
            kbStroke.Thickness = 2
            kbStroke.Color = Color3.fromRGB(78, 78, 78)
            
            local TopBar = Instance.new("Frame")
            TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            TopBar.Size = UDim2.new(1, 0, 0, 28)
            TopBar.ZIndex = 100
            TopBar.Parent = KeybindWindow
            Instance.new("UICorner", TopBar)
            
            local TopTitle = Instance.new("TextLabel")
            TopTitle.BackgroundTransparency = 1
            TopTitle.Position = UDim2.new(0, 10, 0, 0)
            TopTitle.Size = UDim2.new(0.7, 0, 1, 0)
            TopTitle.Font = Enum.Font.GothamSemibold
            TopTitle.Text = "Keybind"
            TopTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            TopTitle.TextSize = 12
            TopTitle.TextXAlignment = Enum.TextXAlignment.Left
            TopTitle.ZIndex = 100
            TopTitle.Parent = TopBar
            
            local CloseBtn = Instance.new("ImageButton")
            CloseBtn.BackgroundTransparency = 1
            CloseBtn.Position = UDim2.new(1, -25, 0.5, 0)
            CloseBtn.AnchorPoint = Vector2.new(0, 0.5)
            CloseBtn.Size = UDim2.new(0, 16, 0, 16)
            CloseBtn.Image = "rbxassetid://10137832201"
            CloseBtn.ImageColor3 = Color3.fromRGB(111, 111, 111)
            CloseBtn.ZIndex = 100
            CloseBtn.Parent = TopBar
            
            CloseBtn.MouseButton1Click:Connect(function()
                self:Close()
            end)
            
            local KeyButton = Instance.new("TextButton")
            KeyButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            KeyButton.Position = UDim2.new(0.05, 0, 0, 38)
            KeyButton.Size = UDim2.new(0.9, 0, 0, 28)
            KeyButton.Font = Enum.Font.GothamSemibold
            KeyButton.Text = self.Key == Enum.KeyCode.Unknown and "None" or self.Key.Name
            KeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            KeyButton.TextSize = 14
            KeyButton.AutoButtonColor = false
            KeyButton.ZIndex = 100
            KeyButton.Parent = KeybindWindow
            Instance.new("UICorner", KeyButton)
            
            KeyButton.MouseButton1Click:Connect(function()
                KeyButton.Text = "..."
                self.Binding = true
            end)
            
            local HoldBtn = Instance.new("TextButton")
            HoldBtn.BackgroundColor3 = self.Mode == "Hold" and Color3.fromRGB(117, 139, 211) or Color3.fromRGB(22, 22, 22)
            HoldBtn.Position = UDim2.new(0.05, 0, 0, 76)
            HoldBtn.Size = UDim2.new(0.43, 0, 0, 28)
            HoldBtn.Font = Enum.Font.GothamSemibold
            HoldBtn.Text = "Hold"
            HoldBtn.TextColor3 = self.Mode == "Hold" and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
            HoldBtn.TextSize = 14
            HoldBtn.AutoButtonColor = false
            HoldBtn.ZIndex = 100
            HoldBtn.Parent = KeybindWindow
            Instance.new("UICorner", HoldBtn)
            
            local HoldGradient = Instance.new("UIGradient", HoldBtn)
            HoldGradient.Enabled = self.Mode == "Hold"
            HoldGradient.Rotation = 90
            HoldGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(117, 139, 211)),
                ColorSequenceKeypoint.new(0.324, Color3.fromRGB(105, 124, 189)),
                ColorSequenceKeypoint.new(0.600, Color3.fromRGB(89, 106, 160)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 58, 85))
            }
            
            local ToggleModeBtn = Instance.new("TextButton")
            ToggleModeBtn.BackgroundColor3 = self.Mode == "Toggle" and Color3.fromRGB(117, 139, 211) or Color3.fromRGB(22, 22, 22)
            ToggleModeBtn.Position = UDim2.new(0.52, 0, 0, 76)
            ToggleModeBtn.Size = UDim2.new(0.43, 0, 0, 28)
            ToggleModeBtn.Font = Enum.Font.GothamSemibold
            ToggleModeBtn.Text = "Toggle"
            ToggleModeBtn.TextColor3 = self.Mode == "Toggle" and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
            ToggleModeBtn.TextSize = 14
            ToggleModeBtn.AutoButtonColor = false
            ToggleModeBtn.ZIndex = 100
            ToggleModeBtn.Parent = KeybindWindow
            Instance.new("UICorner", ToggleModeBtn)
            
            local ToggleGradient = Instance.new("UIGradient", ToggleModeBtn)
            ToggleGradient.Enabled = self.Mode == "Toggle"
            ToggleGradient.Rotation = 90
            ToggleGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(117, 139, 211)),
                ColorSequenceKeypoint.new(0.324, Color3.fromRGB(105, 124, 189)),
                ColorSequenceKeypoint.new(0.600, Color3.fromRGB(89, 106, 160)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 58, 85))
            }
            
            HoldBtn.MouseButton1Click:Connect(function()
                self.Mode = "Hold"
                Utilities:Tween(HoldBtn, {BackgroundColor3 = Color3.fromRGB(117, 139, 211)}, 0.2)
                Utilities:Tween(HoldBtn, {TextColor3 = Color3.fromRGB(0, 0, 0)}, 0.2)
                HoldGradient.Enabled = true
                Utilities:Tween(ToggleModeBtn, {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}, 0.2)
                Utilities:Tween(ToggleModeBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
                ToggleGradient.Enabled = false
            end)
            
            ToggleModeBtn.MouseButton1Click:Connect(function()
                self.Mode = "Toggle"
                Utilities:Tween(ToggleModeBtn, {BackgroundColor3 = Color3.fromRGB(117, 139, 211)}, 0.2)
                Utilities:Tween(ToggleModeBtn, {TextColor3 = Color3.fromRGB(0, 0, 0)}, 0.2)
                ToggleGradient.Enabled = true
                Utilities:Tween(HoldBtn, {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}, 0.2)
                Utilities:Tween(HoldBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
                HoldGradient.Enabled = false
            end)
            
            Utilities:Tween(KeybindWindow, {Size = UDim2.new(0, 180, 0, 115)}, 0.25, Enum.EasingStyle.Back)
            
            local bindConn
            bindConn = UserInputService.InputBegan:Connect(function(input, gpe)
                if not self.KeybindWindow then bindConn:Disconnect() return end
                if self.Binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    self.Key = input.KeyCode
                    KeyButton.Text = input.KeyCode.Name
                    self.Binding = false
                end
            end)
            
            local posConn
            posConn = RunService.RenderStepped:Connect(function()
                if not self.KeybindWindow or not self.IsOpen then 
                    if posConn then posConn:Disconnect() end
                    return 
                end
                self:UpdatePosition()
            end)
        end
        
        SettingButton.MouseButton1Click:Connect(function()
            Keybind:Open()
        end)
        
        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == Keybind.Key and Keybind.Key ~= Enum.KeyCode.Unknown then
                if Keybind.Mode == "Toggle" then
                    Toggle:Set(not Toggle.Value)
                elseif Keybind.Mode == "Hold" then
                    Toggle:Set(true)
                end
                task.spawn(Keybind.Callback, true)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Keybind.Key and Keybind.Key ~= Enum.KeyCode.Unknown then
                if Keybind.Mode == "Hold" then
                    Toggle:Set(false)
                end
                task.spawn(Keybind.Callback, false)
            end
        end)
        
        Keybind.Button = SettingButton
        return Keybind
    end

    Utilities:RippleEffect(ToggleButton)
    ToggleButton.MouseButton1Click:Connect(function()
        Toggle:Set(not Toggle.Value)
    end)
    
    Toggle.Frame = ToggleFrame
    Toggle.AccessoryList = AccessoryList
    table.insert(self.Elements or {}, Toggle)
    return Toggle
end

function Library:CreateSlider(config)
    config = config or {}
    config.Name = config.Name or "Slider"
    config.Min = config.Min or 0
    config.Max = config.Max or 100
    config.Default = config.Default or 50
    config.Increment = config.Increment or 1
    config.Suffix = config.Suffix or ""
    config.Callback = config.Callback or function() end
    
    self.ElementOrder = (self.ElementOrder or 0) + 1
    
    local Slider = {Value = config.Default, Min = config.Min, Max = config.Max, Increment = config.Increment, Callback = config.Callback, Title = config.Name}
    
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "slider"
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Size = UDim2.new(1, 0, 0, 32)
    SliderFrame.ZIndex = 4
    SliderFrame.LayoutOrder = self.ElementOrder
    SliderFrame.Parent = self.Container
    
    local SliderTitle = Instance.new("TextLabel")
    SliderTitle.BackgroundTransparency = 1
    SliderTitle.Size = UDim2.new(0.5, 0, 0, 15)
    SliderTitle.Font = Enum.Font.GothamSemibold
    SliderTitle.Text = config.Name
    SliderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderTitle.TextSize = 14
    SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    SliderTitle.ZIndex = 4
    SliderTitle.Parent = SliderFrame
    
    local SliderAmount = Instance.new("TextLabel")
    SliderAmount.BackgroundTransparency = 1
    SliderAmount.Position = UDim2.new(0.5, 0, 0, 0)
    SliderAmount.Size = UDim2.new(0.5, 0, 0, 15)
    SliderAmount.Font = Enum.Font.GothamSemibold
    SliderAmount.Text = tostring(config.Default) .. config.Suffix
    SliderAmount.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderAmount.TextSize = 14
    SliderAmount.TextXAlignment = Enum.TextXAlignment.Right
    SliderAmount.ZIndex = 4
    SliderAmount.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    SliderBar.BorderSizePixel = 0
    SliderBar.Position = UDim2.new(0, 0, 0, 20)
    SliderBar.Size = UDim2.new(1, 0, 0, 10)
    SliderBar.ZIndex = 5
    SliderBar.Parent = SliderFrame
    
    Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(0, 999)
    
    local SliderFill = Instance.new("Frame")
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Size = UDim2.new((config.Default - config.Min) / (config.Max - config.Min), 0, 1, 0)
    SliderFill.ZIndex = 5
    SliderFill.Parent = SliderBar
    
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 999)
    
    local SliderFillGradient = Instance.new("UIGradient", SliderFill)
    SliderFillGradient.Rotation = 90
    SliderFillGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(117, 139, 211)),
        ColorSequenceKeypoint.new(0.324, Color3.fromRGB(105, 124, 189)),
        ColorSequenceKeypoint.new(0.600, Color3.fromRGB(89, 106, 160)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 58, 85))
    }
    
    function Slider:Set(value)
        value = math.clamp(value, self.Min, self.Max)
        value = math.floor(value / self.Increment + 0.5) * self.Increment
        self.Value = value
        local percent = (value - self.Min) / (self.Max - self.Min)
        Utilities:Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
        SliderAmount.Text = tostring(value) .. config.Suffix
        task.spawn(self.Callback, value)
    end
    
    local dragging = false
    
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local percent = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            Slider:Set(config.Min + (config.Max - config.Min) * percent)
        end
    end)
    
    SliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            Slider:Set(config.Min + (config.Max - config.Min) * percent)
        end
    end)
    
    Slider.Frame = SliderFrame
    table.insert(self.Elements or {}, Slider)
    return Slider
end

function Library:CreateDropdown(config)
    config = config or {}
    config.Name = config.Name or "Dropdown"
    config.Options = config.Options or {"Option 1", "Option 2"}
    config.Default = config.Default or config.Options[1]
    config.Multi = config.Multi or false
    config.Callback = config.Callback or function() end
    
    self.ElementOrder = (self.ElementOrder or 0) + 1
    
    local Dropdown = {Value = config.Multi and {config.Default} or config.Default, Options = config.Options, Multi = config.Multi, Callback = config.Callback, Title = config.Name, Open = false, DropdownList = nil}
    
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = "dropdown"
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.Size = UDim2.new(1, 0, 0, 42)
    DropdownFrame.ZIndex = 4
    DropdownFrame.LayoutOrder = self.ElementOrder
    DropdownFrame.Parent = self.Container
    
    local DropdownTitle = Instance.new("TextLabel")
    DropdownTitle.BackgroundTransparency = 1
    DropdownTitle.Size = UDim2.new(1, 0, 0, 15)
    DropdownTitle.Font = Enum.Font.GothamSemibold
    DropdownTitle.Text = config.Name
    DropdownTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownTitle.TextSize = 14
    DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
    DropdownTitle.ZIndex = 4
    DropdownTitle.Parent = DropdownFrame
    
    local DropdownBg = Instance.new("TextButton")
    DropdownBg.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    DropdownBg.BorderSizePixel = 0
    DropdownBg.Position = UDim2.new(0, 0, 0, 18)
    DropdownBg.Size = UDim2.new(1, 0, 0, 21)
    DropdownBg.AutoButtonColor = false
    DropdownBg.Text = ""
    DropdownBg.ZIndex = 4
    DropdownBg.Parent = DropdownFrame
    
    Instance.new("UICorner", DropdownBg).CornerRadius = UDim.new(0, 3)
    
    local DropdownSelected = Instance.new("TextLabel")
    DropdownSelected.BackgroundTransparency = 1
    DropdownSelected.Position = UDim2.new(0, 6, 0, 0)
    DropdownSelected.Size = UDim2.new(1, -30, 1, 0)
    DropdownSelected.Font = Enum.Font.GothamSemibold
    DropdownSelected.Text = config.Default
    DropdownSelected.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownSelected.TextSize = 14
    DropdownSelected.TextXAlignment = Enum.TextXAlignment.Left
    DropdownSelected.TextTruncate = Enum.TextTruncate.AtEnd
    DropdownSelected.ZIndex = 4
    DropdownSelected.Parent = DropdownBg
    
    local DropdownArrow = Instance.new("ImageLabel")
    DropdownArrow.BackgroundTransparency = 1
    DropdownArrow.Position = UDim2.new(1, -16, 0.5, 0)
    DropdownArrow.AnchorPoint = Vector2.new(0, 0.5)
    DropdownArrow.Size = UDim2.new(0, 10, 0, 10)
    DropdownArrow.Image = "rbxassetid://86523506890491"
    DropdownArrow.ZIndex = 4
    DropdownArrow.Parent = DropdownBg
    
    function Dropdown:CreateOption(option, container)
        local OptionButton = Instance.new("TextButton")
        OptionButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        OptionButton.BackgroundTransparency = 1
        OptionButton.Size = UDim2.new(1, 0, 0, 24)
        OptionButton.Font = Enum.Font.GothamSemibold
        OptionButton.Text = "  " .. option
        OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionButton.TextTransparency = 0.4
        OptionButton.TextSize = 14
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.AutoButtonColor = false
        OptionButton.ZIndex = 60
        OptionButton.Parent = container
        
        Instance.new("UICorner", OptionButton).CornerRadius = UDim.new(0, 4)
        
        OptionButton.MouseEnter:Connect(function()
            Utilities:Tween(OptionButton, {BackgroundTransparency = 0.7}, 0.1)
        end)
        
        OptionButton.MouseLeave:Connect(function()
            Utilities:Tween(OptionButton, {BackgroundTransparency = 1}, 0.1)
        end)
        
        OptionButton.MouseButton1Click:Connect(function()
            if self.Multi then
                if table.find(self.Value, option) then
                    table.remove(self.Value, table.find(self.Value, option))
                    OptionButton.TextTransparency = 0.4
                else
                    table.insert(self.Value, option)
                    OptionButton.TextTransparency = 0
                end
                DropdownSelected.Text = table.concat(self.Value, ", ")
            else
                self.Value = option
                DropdownSelected.Text = option
                self:Toggle()
                for _, btn in pairs(container:GetChildren()) do
                    if btn:IsA("TextButton") then btn.TextTransparency = 0.4 end
                end
                OptionButton.TextTransparency = 0
            end
            task.spawn(self.Callback, self.Value)
        end)
    end
    
    function Dropdown:Refresh(options)
        self.Options = options
        if self.DropdownList then
            local container = self.DropdownList:FindFirstChild("scroll")
            if container then
                for _, child in pairs(container:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for _, option in pairs(options) do
                    self:CreateOption(option, container)
                end
            end
        end
    end
    
    function Dropdown:Set(value)
        self.Value = value
        DropdownSelected.Text = type(value) == "table" and table.concat(value, ", ") or value
        task.spawn(self.Callback, value)
    end
    
    function Dropdown:Close()
        if not self.Open then return end
        self.Open = false
        ActivePopups.Dropdown = nil
        
        if self.DropdownList then
            Utilities:Tween(self.DropdownList, {Size = UDim2.new(0, self.DropdownList.Size.X.Offset, 0, 0)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            Utilities:Tween(DropdownArrow, {Rotation = 0}, 0.2)
            task.delay(0.2, function()
                if self.DropdownList then
                    self.DropdownList:Destroy()
                    self.DropdownList = nil
                end
            end)
        end
    end
    
    function Dropdown:Toggle()
        if self.Open then
            self:Close()
            return
        end
        
        Utilities:CloseAllPopups("Dropdown")
        self.Open = true
        ActivePopups.Dropdown = self
        
        local ScreenGui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Lumen")
        if not ScreenGui then return end
        
        local PopupHolder = ScreenGui:FindFirstChild("popups")
        if not PopupHolder then return end
        
        local buttonPos = DropdownBg.AbsolutePosition
        local buttonSize = DropdownBg.AbsoluteSize
        
        local DropdownList = Instance.new("Frame")
        DropdownList.Name = "dropdownlist"
        DropdownList.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        DropdownList.BorderSizePixel = 0
        DropdownList.Position = UDim2.new(0, buttonPos.X, 0, buttonPos.Y + buttonSize.Y + 5)
        DropdownList.Size = UDim2.new(0, buttonSize.X, 0, 0)
        DropdownList.ClipsDescendants = true
        DropdownList.ZIndex = 55
        DropdownList.Parent = PopupHolder
        
        self.DropdownList = DropdownList
        
        Instance.new("UICorner", DropdownList).CornerRadius = UDim.new(0, 5)
        Instance.new("UIStroke", DropdownList).Color = Color3.fromRGB(35, 35, 35)
        
        local OptionsScroll = Instance.new("ScrollingFrame")
        OptionsScroll.Name = "scroll"
        OptionsScroll.BackgroundTransparency = 1
        OptionsScroll.Size = UDim2.new(1, -10, 1, -10)
        OptionsScroll.Position = UDim2.new(0, 5, 0, 5)
        OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        OptionsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        OptionsScroll.ScrollBarThickness = 3
        OptionsScroll.ScrollBarImageColor3 = Color3.fromRGB(117, 139, 211)
        OptionsScroll.ZIndex = 60
        OptionsScroll.Parent = DropdownList
        
        local OptionsLayout = Instance.new("UIListLayout", OptionsScroll)
        OptionsLayout.Padding = UDim.new(0, 4)
        
        for _, option in pairs(self.Options) do
            self:CreateOption(option, OptionsScroll)
        end
        
        local height = math.min(#self.Options * 28 + 10, 150)
        Utilities:Tween(DropdownList, {Size = UDim2.new(0, buttonSize.X, 0, height)}, 0.2, Enum.EasingStyle.Back)
        Utilities:Tween(DropdownArrow, {Rotation = 180}, 0.2)
        
        local posConn
        posConn = RunService.RenderStepped:Connect(function()
            if not self.DropdownList or not self.Open then 
                if posConn then posConn:Disconnect() end
                return 
            end
            local newPos = DropdownBg.AbsolutePosition
            local newSize = DropdownBg.AbsoluteSize
            self.DropdownList.Position = UDim2.new(0, newPos.X, 0, newPos.Y + newSize.Y + 5)
        end)
    end
    
    DropdownBg.MouseButton1Click:Connect(function()
        Dropdown:Toggle()
    end)
    
    Dropdown.Frame = DropdownFrame
    table.insert(self.Elements or {}, Dropdown)
    return Dropdown
end

function Library:CreateTextbox(config)
    config = config or {}
    config.Name = config.Name or "Textbox"
    config.Default = config.Default or ""
    config.Placeholder = config.Placeholder or "Enter text..."
    config.Icon = config.Icon or "rbxassetid://88238578565569"
    config.Callback = config.Callback or function() end
    
    self.ElementOrder = (self.ElementOrder or 0) + 1
    
    local Textbox = {Value = config.Default, Callback = config.Callback, Title = config.Name}
    
    local TextboxFrame = Instance.new("Frame")
    TextboxFrame.Name = "Textbox"
    TextboxFrame.BackgroundTransparency = 1
    TextboxFrame.Size = UDim2.new(1, 0, 0, 42)
    TextboxFrame.ZIndex = 4
    TextboxFrame.LayoutOrder = self.ElementOrder
    TextboxFrame.Parent = self.Container
    
    local TextboxTitle = Instance.new("TextLabel")
    TextboxTitle.BackgroundTransparency = 1
    TextboxTitle.Size = UDim2.new(1, 0, 0, 15)
    TextboxTitle.Font = Enum.Font.GothamSemibold
    TextboxTitle.Text = config.Name
    TextboxTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextboxTitle.TextSize = 14
    TextboxTitle.TextXAlignment = Enum.TextXAlignment.Left
    TextboxTitle.ZIndex = 4
    TextboxTitle.Parent = TextboxFrame
    
    local TextboxContainer = Instance.new("Frame")
    TextboxContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    TextboxContainer.BorderSizePixel = 0
    TextboxContainer.Position = UDim2.new(0, 0, 0, 18)
    TextboxContainer.Size = UDim2.new(1, 0, 0, 21)
    TextboxContainer.ZIndex = 4
    TextboxContainer.Parent = TextboxFrame
    
    Instance.new("UICorner", TextboxContainer).CornerRadius = UDim.new(0, 3)
    
    local TextboxIcon = Instance.new("ImageLabel")
    TextboxIcon.BackgroundTransparency = 1
    TextboxIcon.Position = UDim2.new(1, -18, 0.5, 0)
    TextboxIcon.AnchorPoint = Vector2.new(0, 0.5)
    TextboxIcon.Size = UDim2.new(0, 12, 0, 12)
    TextboxIcon.Image = config.Icon
    TextboxIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
    TextboxIcon.ZIndex = 4
    TextboxIcon.Parent = TextboxContainer
    
    local TextboxInput = Instance.new("TextBox")
    TextboxInput.BackgroundTransparency = 1
    TextboxInput.Position = UDim2.new(0, 6, 0, 0)
    TextboxInput.Size = UDim2.new(1, -30, 1, 0)
    TextboxInput.Font = Enum.Font.GothamSemibold
    TextboxInput.PlaceholderText = config.Placeholder
    TextboxInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    TextboxInput.Text = config.Default
    TextboxInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextboxInput.TextSize = 14
    TextboxInput.TextXAlignment = Enum.TextXAlignment.Left
    TextboxInput.ZIndex = 4
    TextboxInput.ClearTextOnFocus = false
    TextboxInput.Parent = TextboxContainer
    
    function Textbox:Set(value)
        self.Value = value
        TextboxInput.Text = value
        task.spawn(self.Callback, value)
    end
    
    TextboxInput.FocusLost:Connect(function()
        Textbox:Set(TextboxInput.Text)
    end)
    
    Textbox.Frame = TextboxFrame
    table.insert(self.Elements or {}, Textbox)
    return Textbox
end

function Library:CreateButton(config)
    config = config or {}
    config.Name = config.Name or "Button"
    config.Callback = config.Callback or function() end
    
    self.ElementOrder = (self.ElementOrder or 0) + 1
    
    local Button = {Callback = config.Callback, Title = config.Name}
    
    local ButtonFrame = Instance.new("TextButton")
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Size = UDim2.new(1, 0, 0, 28)
    ButtonFrame.Font = Enum.Font.GothamSemibold
    ButtonFrame.Text = config.Name
    ButtonFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
    ButtonFrame.TextSize = 15
    ButtonFrame.AutoButtonColor = false
    ButtonFrame.ZIndex = 4
    ButtonFrame.LayoutOrder = self.ElementOrder
    ButtonFrame.Parent = self.Container
    
    Instance.new("UICorner", ButtonFrame)
    
    Utilities:RippleEffect(ButtonFrame)
    
    ButtonFrame.MouseEnter:Connect(function()
        Utilities:Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}, 0.2)
    end)
    
    ButtonFrame.MouseLeave:Connect(function()
        Utilities:Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}, 0.2)
    end)
    
    ButtonFrame.MouseButton1Click:Connect(function()
        task.spawn(config.Callback)
    end)
    
    Button.Frame = ButtonFrame
    table.insert(self.Elements or {}, Button)
    return Button
end

function Library:Notify(config)
    config = config or {}
    config.Title = config.Title or "Notification"
    config.Message = config.Message or "Message"
    config.Duration = config.Duration or 3
    config.Icon = config.Icon or "rbxassetid://129947207621414"
    
    local NotifContainer = self.ScreenGui:FindFirstChild("notifications")
    if not NotifContainer then
        NotifContainer = Instance.new("Frame")
        NotifContainer.Name = "notifications"
        NotifContainer.BackgroundTransparency = 1
        NotifContainer.Position = UDim2.new(0, 15, 0, 55)
        NotifContainer.Size = UDim2.new(0, 220, 1, -55)
        NotifContainer.Parent = self.ScreenGui
        
        local NotifLayout = Instance.new("UIListLayout", NotifContainer)
        NotifLayout.Padding = UDim.new(0, 8)
        NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    end
    
    local Notification = Instance.new("Frame")
    Notification.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Notification.BorderSizePixel = 0
    Notification.Size = UDim2.new(1, 0, 0, 0)
    Notification.ClipsDescendants = true
    Notification.Parent = NotifContainer
    
    Instance.new("UICorner", Notification).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", Notification).Color = Color3.fromRGB(25, 25, 25)
    
    local NotifIcon = Instance.new("ImageLabel")
    NotifIcon.BackgroundTransparency = 1
    NotifIcon.Position = UDim2.new(0, 8, 0.5, 0)
    NotifIcon.AnchorPoint = Vector2.new(0, 0.5)
    NotifIcon.Size = UDim2.new(0, 18, 0, 18)
    NotifIcon.Image = config.Icon
    NotifIcon.ImageTransparency = 1
    NotifIcon.Parent = Notification
    
    local NotifLabel = Instance.new("TextLabel")
    NotifLabel.BackgroundTransparency = 1
    NotifLabel.Position = UDim2.new(0, 32, 0, 0)
    NotifLabel.Size = UDim2.new(1, -40, 1, 0)
    NotifLabel.Font = Enum.Font.GothamSemibold
    NotifLabel.Text = config.Message
    NotifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifLabel.TextSize = 11
    NotifLabel.TextXAlignment = Enum.TextXAlignment.Left
    NotifLabel.TextWrapped = true
    NotifLabel.TextTransparency = 1
    NotifLabel.Parent = Notification
    
    local ProgressBar = Instance.new("Frame")
    ProgressBar.BackgroundColor3 = Color3.fromRGB(117, 139, 211)
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Position = UDim2.new(0, 0, 1, -2)
    ProgressBar.Size = UDim2.new(1, 0, 0, 2)
    ProgressBar.Parent = Notification
    
    local ProgressGradient = Instance.new("UIGradient", ProgressBar)
    ProgressGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(117, 139, 211)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(89, 106, 160))
    }
    
    Utilities:Tween(Notification, {Size = UDim2.new(1, 0, 0, 38)}, 0.3, Enum.EasingStyle.Back)
    Utilities:Tween(NotifIcon, {ImageTransparency = 0}, 0.3)
    Utilities:Tween(NotifLabel, {TextTransparency = 0}, 0.3)
    
    task.delay(0.3, function()
        Utilities:Tween(ProgressBar, {Size = UDim2.new(0, 0, 0, 2)}, config.Duration, Enum.EasingStyle.Linear)
    end)
    
    task.delay(config.Duration + 0.3, function()
        Utilities:Tween(NotifIcon, {ImageTransparency = 1}, 0.2)
        Utilities:Tween(NotifLabel, {TextTransparency = 1}, 0.2)
        Utilities:Tween(Notification, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.35)
        Notification:Destroy()
    end)
end

function Library:CreateWatermark(config)
    config = config or {}
    config.Text = config.Text or "Lumen"
    config.Icon = config.Icon or "rbxassetid://112661755352143"
    
    local Watermark = {BaseText = config.Text}
    
    local WatermarkFrame = Instance.new("Frame")
    WatermarkFrame.Name = "watermark"
    WatermarkFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    WatermarkFrame.BorderSizePixel = 0
    WatermarkFrame.Size = UDim2.new(0, 0, 0, 35)
    WatermarkFrame.AutomaticSize = Enum.AutomaticSize.X
    WatermarkFrame.Position = UDim2.new(0, 15, 0, 15)
    WatermarkFrame.Parent = self.ScreenGui
    
    Instance.new("UICorner", WatermarkFrame)
    
    local WatermarkStroke = Instance.new("UIStroke", WatermarkFrame)
    WatermarkStroke.Thickness = 2
    WatermarkStroke.Color = Color3.fromRGB(53, 53, 53)
    
    local WatermarkPadding = Instance.new("UIPadding", WatermarkFrame)
    WatermarkPadding.PaddingLeft = UDim.new(0, 12)
    WatermarkPadding.PaddingRight = UDim.new(0, 12)
    
    local WatermarkLayout = Instance.new("UIListLayout", WatermarkFrame)
    WatermarkLayout.FillDirection = Enum.FillDirection.Horizontal
    WatermarkLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    WatermarkLayout.Padding = UDim.new(0, 8)
    
    local WatermarkIcon = Instance.new("ImageLabel")
    WatermarkIcon.BackgroundTransparency = 1
    WatermarkIcon.Size = UDim2.new(0, 20, 0, 20)
    WatermarkIcon.Image = config.Icon
    WatermarkIcon.Parent = WatermarkFrame
    
    local WatermarkText = Instance.new("TextLabel")
    WatermarkText.BackgroundTransparency = 1
    WatermarkText.Size = UDim2.new(0, 0, 1, 0)
    WatermarkText.AutomaticSize = Enum.AutomaticSize.X
    WatermarkText.Font = Enum.Font.GothamSemibold
    WatermarkText.Text = config.Text
    WatermarkText.TextColor3 = Color3.fromRGB(255, 255, 255)
    WatermarkText.TextSize = 14
    WatermarkText.Parent = WatermarkFrame
    
    function Watermark:Change(text)
        self.BaseText = text
    end
    
    local lastFps = 0
    RunService.RenderStepped:Connect(function(dt)
        lastFps = math.floor(1 / dt)
        WatermarkText.Text = Watermark.BaseText .. " | " .. lastFps .. " FPS | " .. os.date("%H:%M:%S")
    end)
    
    Watermark.Frame = WatermarkFrame
    return Watermark
end

return Library
