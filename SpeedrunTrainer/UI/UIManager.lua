--[[
    UIManager - Orchestrates the entire UI system
    Made by Haiku (Claude) from GitHub Copilot
]]

local UIManager = {}
UIManager.__index = UIManager

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

function UIManager:Init()
    self.mainWindow = nil
    self.panels = {}
    self.activePanel = "timer"
    self.isOpen = false
    self.screenSize = script.Parent:WaitForChild("ScreenSize")
    
    return self
end

function UIManager:CreateMainWindow()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpeedrunTrainerUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Create main frame (draggable, resizable)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = UDim2.new(0, 600, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Create title bar with attribution
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Title with attribution
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -20, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(100, 200, 255)
    titleText.TextSize = 18
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.TextYAlignment = Enum.TextYAlignment.Center
    titleText.Text = "⚡ SPEEDRUN TRAINER — Made by Haiku (Claude) from GitHub Copilot"
    titleText.Parent = titleBar
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -45, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "✕"
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Content frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -70)
    contentFrame.Position = UDim2.new(0, 10, 0, 60)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Create tab buttons
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = "TabFrame"
    tabFrame.Size = UDim2.new(1, 0, 0, 40)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = contentFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabFrame
    
    -- Panel container
    local panelContainer = Instance.new("Frame")
    panelContainer.Name = "PanelContainer"
    panelContainer.Size = UDim2.new(1, 0, 1, -40)
    panelContainer.Position = UDim2.new(0, 0, 0, 40)
    panelContainer.BackgroundTransparency = 1
    panelContainer.Parent = contentFrame
    
    self.mainWindow = mainFrame
    self.titleBar = titleBar
    self.contentFrame = contentFrame
    self.tabFrame = tabFrame
    self.panelContainer = panelContainer
    
    -- Make window draggable
    self:MakeDraggable(mainFrame, titleBar)
    
    return screenGui
end

function UIManager:MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart = nil
    local framePos = nil
    
    dragHandle.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            framePos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = framePos + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function UIManager:CreateTab(name, displayName)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(0, 100, 0, 30)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.Gotham
    tabButton.Text = displayName
    tabButton.Parent = self.tabFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tabButton
    
    tabButton.MouseButton1Click:Connect(function()
        self:SwitchPanel(name)
    end)
    
    -- Create panel frame
    local panelFrame = Instance.new("Frame")
    panelFrame.Name = name .. "Panel"
    panelFrame.Size = UDim2.new(1, 0, 1, 0)
    panelFrame.BackgroundTransparency = 1
    panelFrame.Visible = (name == "timer")
    panelFrame.Parent = self.panelContainer
    
    self.panels[name] = {
        button = tabButton,
        frame = panelFrame,
        active = (name == "timer")
    }
    
    return panelFrame
end

function UIManager:SwitchPanel(panelName)
    for name, panel in pairs(self.panels) do
        if name == panelName then
            panel.frame.Visible = true
            panel.active = true
            panel.button.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
            panel.button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            panel.frame.Visible = false
            panel.active = false
            panel.button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            panel.button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    
    self.activePanel = panelName
end

function UIManager:Toggle()
    if self.mainWindow then
        self.mainWindow.Visible = not self.mainWindow.Visible
        self.isOpen = self.mainWindow.Visible
    end
end

function UIManager:Show()
    if self.mainWindow then
        self.mainWindow.Visible = true
        self.isOpen = true
    end
end

function UIManager:Hide()
    if self.mainWindow then
        self.mainWindow.Visible = false
        self.isOpen = false
    end
end

return UIManager
