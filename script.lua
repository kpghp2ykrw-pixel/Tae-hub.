-- TAE HUB | All-in-One + Key System
-- Roblox Studio LocalScript
-- Put in StarterPlayer > StarterPlayerScripts
-- Key: Tae
-- Simple client-side key gate, not secure authorization.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("TAEHub")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "TAEHub"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local cyan = Color3.fromRGB(0, 220, 240)
local dark = Color3.fromRGB(20, 20, 27)
local rowColor = Color3.fromRGB(40, 40, 50)
local onColor = Color3.fromRGB(0, 150, 160)

-- KEY SCREEN
local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.fromOffset(280, 190)
keyFrame.Position = UDim2.new(0.5, -140, 0.5, -95)
keyFrame.BackgroundColor3 = dark
keyFrame.BorderSizePixel = 0
keyFrame.Parent = gui

Instance.new("UICorner", keyFrame).CornerRadius =
    UDim.new(0, 12)

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 45)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "TAE HUB"
keyTitle.TextColor3 = cyan
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 23
keyTitle.Parent = keyFrame

local keyInfo = Instance.new("TextLabel")
keyInfo.Size = UDim2.new(1, -20, 0, 25)
keyInfo.Position = UDim2.fromOffset(10, 42)
keyInfo.BackgroundTransparency = 1
keyInfo.Text = "Enter your key to continue"
keyInfo.TextColor3 = Color3.new(1, 1, 1)
keyInfo.Font = Enum.Font.Gotham
keyInfo.TextSize = 12
keyInfo.Parent = keyFrame

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(1, -30, 0, 35)
keyInput.Position = UDim2.fromOffset(15, 75)
keyInput.BackgroundColor3 = rowColor
keyInput.TextColor3 = Color3.new(1, 1, 1)
keyInput.PlaceholderText = "Enter key..."
keyInput.PlaceholderColor3 = Color3.fromRGB(160, 160, 170)
keyInput.Text = ""
keyInput.ClearTextOnFocus = false
keyInput.Font = Enum.Font.Gotham
keyInput.TextSize = 14
keyInput.Parent = keyFrame

Instance.new("UICorner", keyInput).CornerRadius =
    UDim.new(0, 6)

local submitKey = Instance.new("TextButton")
submitKey.Size = UDim2.new(1, -30, 0, 35)
submitKey.Position = UDim2.fromOffset(15, 118)
submitKey.BackgroundColor3 = onColor
submitKey.TextColor3 = Color3.new(1, 1, 1)
submitKey.Text = "UNLOCK"
submitKey.Font = Enum.Font.GothamBold
submitKey.TextSize = 14
submitKey.Parent = keyFrame

Instance.new("UICorner", submitKey).CornerRadius =
    UDim.new(0, 6)

local keyMessage = Instance.new("TextLabel")
keyMessage.Size = UDim2.new(1, -20, 0, 22)
keyMessage.Position = UDim2.fromOffset(10, 157)
keyMessage.BackgroundTransparency = 1
keyMessage.Text = ""
keyMessage.TextColor3 = Color3.fromRGB(255, 80, 80)
keyMessage.Font = Enum.Font.Gotham
keyMessage.TextSize = 12
keyMessage.Parent = keyFrame

-- MAIN HUB
local flying = false
local espOn = false
local noclipOn = false
local walkOn = false
local up, down = false, false
local flySpeed = 50
local walkSpeed = 50
local defaultWalkSpeed = 16

local flyVelocity, flyAttachment, flyConnection
local highlights = {}
local savedCollisions = {}
local savedAutoRotate

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(200, 276)
main.Position = UDim2.new(0.5, -100, 0.5, -138)
main.BackgroundColor3 = dark
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Visible = false
main.Parent = gui

Instance.new("UICorner", main).CornerRadius =
    UDim.new(0, 9)

-- HEADER
local title = Instance.new("TextButton")
title.Size = UDim2.new(1, 0, 0, 32)
title.Text = "TAE HUB    −"
title.TextColor3 = cyan
title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = main

Instance.new("UICorner", title).CornerRadius =
    UDim.new(0, 9)

local minimized = false

local function makeButton(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -12, 0, 28)
    b.Position = UDim2.fromOffset(6, y)
    b.BackgroundColor3 = rowColor
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 13
    b.Font = Enum.Font.Gotham
    b.Text = text
    b.Parent = main

    Instance.new("UICorner", b).CornerRadius =
        UDim.new(0, 6)

    return b
end

local flyButton = makeButton("Fly: OFF", 38)
local upButton = makeButton("UP ▲", 72)
local downButton = makeButton("DOWN ▼", 106)
local espButton = makeButton("ESP: OFF", 140)
local noclipButton = makeButton("Noclip: OFF", 174)
local walkButton = makeButton("WalkSpeed: OFF", 208)
local speedButton = makeButton("Fly Speed: 50", 242)

local buttons = {
    flyButton, upButton, downButton,
    espButton, noclipButton, walkButton, speedButton
}

-- MINIMIZE / RESTORE
title.Activated:Connect(function()
    minimized = not minimized

    for _, b in ipairs(buttons) do
        b.Visible = not minimized
    end

    main.Size = minimized
        and UDim2.fromOffset(200, 32)
        or UDim2.fromOffset(200, 276)

    title.Text = minimized and "TAE HUB    +" or "TAE HUB    −"
end)

local function setButton(button, label, enabled)
    button.Text = label .. ": " .. (enabled and "ON" or "OFF")
    button.BackgroundColor3 = enabled and onColor or rowColor
end

-- FLY
local function stopFly()
    flying = false
    up, down = false, false

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end

    if flyAttachment then
        flyAttachment:Destroy()
        flyAttachment = nil
    end

    local character = player.Character
    local humanoid = character and
        character:FindFirstChildOfClass("Humanoid")

    if humanoid and savedAutoRotate ~= nil then
        humanoid.AutoRotate = savedAutoRotate
    end

    savedAutoRotate = nil
    setButton(flyButton, "Fly", false)
end

local function startFly()
    local character = player.Character
    local root = character and
        character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and
        character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then return end

    stopFly()
    flying = true
    savedAutoRotate = humanoid.AutoRotate
    humanoid.AutoRotate = false

    flyAttachment = Instance.new("Attachment")
    flyAttachment.Parent = root

    flyVelocity = Instance.new("LinearVelocity")
    flyVelocity.Attachment0 = flyAttachment
    flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVelocity.MaxForce = 100000
    flyVelocity.VectorVelocity = Vector3.zero
    flyVelocity.Parent = root

    setButton(flyButton, "Fly", true)

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not root.Parent then
            stopFly()
            return
        end

        local vertical = (up and 1 or 0) - (down and 1 or 0)

        flyVelocity.VectorVelocity =
            humanoid.MoveDirection * flySpeed
            + Vector3.new(0, vertical * flySpeed, 0)
    end)
end

flyButton.Activated:Connect(function()
    if flying then
        stopFly()
    else
        startFly()
    end
end)

-- HOLD UP / DOWN
local function startVertical(direction)
    if not flying then return end
    up = direction == "up"
    down = direction == "down"
end

local function endVertical(direction)
    if direction == "up" then up = false end
    if direction == "down" then down = false end
end

local function connectHold(button, direction)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            startVertical(direction)
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            endVertical(direction)
        end
    end)
end

connectHold(upButton, "up")
connectHold(downButton, "down")

-- FLY SPEED
speedButton.Activated:Connect(function()
    flySpeed += 25
    if flySpeed > 150 then flySpeed = 25 end
    speedButton.Text = "Fly Speed: " .. flySpeed
end)

-- WALKSPEED
local function applyWalkSpeed()
    local character = player.Character
    local humanoid = character and
        character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.WalkSpeed =
            walkOn and walkSpeed or defaultWalkSpeed
    end
end

walkButton.Activated:Connect(function()
    walkOn = not walkOn
    setButton(walkButton, "WalkSpeed", walkOn)
    applyWalkSpeed()
end)

-- NOCLIP
local function setNoclip(enabled)
    noclipOn = enabled

    if not enabled then
        for part, oldValue in pairs(savedCollisions) do
            if part and part.Parent then
                part.CanCollide = oldValue
            end
        end
        table.clear(savedCollisions)
    end

    setButton(noclipButton, "Noclip", enabled)
end

noclipButton.Activated:Connect(function()
    setNoclip(not noclipOn)
end)

-- RAINBOW ESP
local function clearESP()
    for p, highlight in pairs(highlights) do
        highlight:Destroy()
        highlights[p] = nil
    end
end

espButton.Activated:Connect(function()
    espOn = not espOn
    setButton(espButton, "ESP", espOn)

    if not espOn then
        clearESP()
    end
end)

RunService.RenderStepped:Connect(function()
    if noclipOn then
        local character = player.Character

        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if savedCollisions[part] == nil then
                        savedCollisions[part] = part.CanCollide
                    end
                    part.CanCollide = false
                end
            end
        end
    end

    local hue = (os.clock() * 0.35) % 1
    local rainbow = Color3.fromHSV(hue, 1, 1)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local character = p.Character

            if espOn and character then
                local h = highlights[p]

                if not h or h.Adornee ~= character then
                    if h then h:Destroy() end

                    h = Instance.new("Highlight")
                    h.Adornee = character
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.FillTransparency = 0.85
                    h.OutlineTransparency = 0
                    h.Parent = gui
                    highlights[p] = h
                end

                h.OutlineColor = rainbow
                h.FillColor = Color3.fromHSV(
                    (hue + 0.12) % 1, 0.75, 1
                )
            elseif highlights[p] then
                highlights[p]:Destroy()
                highlights[p] = nil
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if highlights[p] then
        highlights[p]:Destroy()
        highlights[p] = nil
    end
end)

-- KEYBOARD CONTROLS
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.F then
        if flying then stopFly() else startFly() end
    elseif flying and input.KeyCode == Enum.KeyCode.Space then
        up = true
    elseif flying and input.KeyCode == Enum.KeyCode.LeftControl then
        down = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then up = false end
    if input.KeyCode == Enum.KeyCode.LeftControl then down = false end
end)

-- DRAG WINDOW
local dragging = false
local dragStart, startPosition

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- RESPAWN
player.CharacterAdded:Connect(function(character)
    stopFly()
    table.clear(savedCollisions)

    local humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed =
        walkOn and walkSpeed or defaultWalkSpeed
end)

-- CLEANUP
gui.Destroying:Connect(function()
    stopFly()
    setNoclip(false)
    clearESP()
end)

-- KEY VALIDATION
local function checkKey()
    if keyInput.Text == "Tae" then
        keyMessage.TextColor3 = Color3.fromRGB(80, 255, 120)
        keyMessage.Text = "Key accepted!"

        keyFrame.Visible = false
        main.Visible = true
    else
        keyMessage.TextColor3 = Color3.fromRGB(255, 80, 80)
        keyMessage.Text = "Incorrect key. Try again."
        keyInput.Text = ""
    end
end

submitKey.Activated:Connect(checkKey)

keyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        checkKey()
    end
end)
