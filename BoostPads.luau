--[[
Boost Pads Conversion v5.5 -> v6
author: untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required
]]

local config = game.ServerStorage.BoostPadConfiguration
for _, v in workspace:GetDescendants() do
    if v.Name ~= "Distance" then continue end
    local pad = v.Parent
    local type = pad.Name:split(" ")[1] 
    local config = config:Clone() 
    local boost = pad:FindFirstChild("JumpPower") or pad:FindFirstChild("WalkSpeed")
    config:SetAttribute("Type",type)
    config:SetAttribute("Power", boost.Value)
    config:SetAttribute("Distance", pad.Distance.Value == 0 and -pad.Size.Y or pad.Distance.Value)
    config.Parent = pad
    
    pad.ClientObject:Destroy()
    pad.Distance:Destroy()
    boost:Destroy()
    pad.ClientObjectScript:Destroy()
    pad.Parent = workspace.TowerKit.ClientSidedObjects
    pad.Name = `{type} BoostPad`
end

game.ChangeHistoryService:SetWaypoint("v5.5 -> v6 BoostPads Conversion")