--[[
Elevator Conversion v5.5 -> v6
author: untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required
]]

for _, v in workspace:GetDescendants() do
    if not v:FindFirstChild("MaxForce") then continue end
    
    local config = Instance.new("Configuration")
    config:SetAttribute("ContinuousUpdates", false)
    config:SetAttribute("HitboxMode", "StaticWholeBody")
    config:SetAttribute("Vector", "UpVector")
    
    config.Name = "ElevatorConfiguration"
    config.Parent = v
    
    config:AddTag("CO_Physics/Elevator")
    config:AddTag("v6.0.0")
    
    local touchConfig = Instance.new("Configuration")
    touchConfig.Name = "TouchConfiguration"
    touchConfig:SetAttribute("balloon",false)
    touchConfig:SetAttribute("canFlip",false)
    touchConfig:SetAttribute("colorSpecific",false)
    touchConfig:SetAttribute("turret",false)
    touchConfig:SetAttribute("player", not v:FindFirstChild("IgnorePlayers"))
    touchConfig:SetAttribute("pushbox", not v:FindFirstChild("IgnoreBoxes"))
    touchConfig.Parent = config
    
    config:SetAttribute("MaxForce", v.MaxForce.Value)
    v.MaxForce:Destroy()
    
    config:SetAttribute("Speed", v.Speed.Value)
    v.Speed:Destroy()
    
    v.ClientObjectScript:Destroy()
    for _, v in v:GetChildren() do
        if v:IsA("ValueBase") then v:Destroy() end
    end
end
game.ChangeHistoryService:SetWaypoint("Elevator Conversion v5.5 -> v6")