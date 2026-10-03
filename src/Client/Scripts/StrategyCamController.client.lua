local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local camera = workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Scriptable

-- Startposition der Kamera (weit oben, schräg nach unten blickend)
local camPos = Vector3.new(0, 100, 50)
local moveSpeed = 60

RunService.RenderStepped:Connect(function(dt)
    local moveDir = Vector3.new(0, 0, 0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir -= Vector3.new(0, 0, 1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir += Vector3.new(0, 0, 1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Vector3.new(1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Vector3.new(1, 0, 0) end
    
    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit * moveSpeed * dt
        camPos += moveDir
    end
    
    -- Kamera schaut immer leicht schräg nach unten (Isometrisch-ähnlich)
    camera.CFrame = CFrame.lookAt(camPos, camPos + Vector3.new(0, -2, -1))
end)