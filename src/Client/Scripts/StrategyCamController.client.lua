local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- 1. Den physischen Spieler aus dem Spiel nehmen
-- Wir frieren den Charakter ein und teleportieren ihn weit weg, damit er nicht stört
local function DisableCharacter(char)
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        hrp.Anchored = true
        hrp.CFrame = CFrame.new(0, 10000, 0) -- Weit über der Map parken
    end
end
if player.Character then DisableCharacter(player.Character) end
player.CharacterAdded:Connect(DisableCharacter)

-- 2. Kamera-Setup
camera.CameraType = Enum.CameraType.Scriptable

-- Zoom-Grenzen und Parameter
local minZoom = 15
local maxZoom = 120
local targetZoom = 60
local currentZoom = 60

local targetPos = Vector3.new(0, 0, 0)
local currentPos = Vector3.new(0, 0, 0)

-- Funktion zur sicheren Tastenabfrage
local function GetMoveDirection()
    local dir = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then 
        dir += Vector3.new(0, 0, -1) 
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then 
        dir += Vector3.new(0, 0, 1) 
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then 
        dir += Vector3.new(-1, 0, 0) 
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then 
        dir += Vector3.new(1, 0, 0) 
    end
    return dir.Magnitude > 0 and dir.Unit or dir
end

-- Zoom über das Mausrad abfangen
UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        -- Zoom anpassen und innerhalb der Grenzen klemmen
        local zoomStep = 15
        targetZoom = math.clamp(targetZoom - (input.Position.Z * zoomStep), minZoom, maxZoom)
    end
end)

-- 3. Der Core-Loop der Kamera
RunService.RenderStepped:Connect(function(dt)
    -- Immer sicherstellen, dass die Kamera Scriptable bleibt
    if camera.CameraType ~= Enum.CameraType.Scriptable then
        camera.CameraType = Enum.CameraType.Scriptable
    end
    
    -- Smooth Zoom Interpolation (weicher Übergang beim Scrollen)
    currentZoom = currentZoom + (targetZoom - currentZoom) * 10 * dt
    
    -- Dynamische Geschwindigkeit basierend auf dem Zoom
    -- zoomFactor ist 0 (ganz nah) bis 1 (maximal rausgezoomt)
    local zoomFactor = (currentZoom - minZoom) / (maxZoom - minZoom)
    local moveSpeed = 20 + (zoomFactor * 100) -- Langsam am Boden (20), extrem schnell in der Luft (120)
    
    local moveDir = GetMoveDirection()
    if moveDir.Magnitude > 0 then
        targetPos += moveDir * moveSpeed * dt
    end
    
    -- Smooth Position Interpolation (weiches Abbremsen der Bewegung)
    currentPos = currentPos:Lerp(targetPos, 12 * dt)
    
    -- Kamera anwinkeln (ca. -55 Grad nach unten gerichtet)
    local zOffset = currentZoom * 0.7 
    local camWorldPos = currentPos + Vector3.new(0, currentZoom, zOffset)
    
    -- Kamera setzen: Von camWorldPos auf currentPos (Boden) schauen
    camera.CFrame = CFrame.lookAt(camWorldPos, currentPos)
end)

print("Client: 4X Strategy Kamera (Zoom & Dynamic Speed) erfolgreich initialisiert!")