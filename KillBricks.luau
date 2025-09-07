--[[
Killbrick Conversion v5.5 -> v6 
author: @staraldev & untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required
]]

local VALID_DAMAGEBRICKS = { "kills", "double", "ouch", "instakills" }

for _, v in workspace:GetDescendants() do
	local type = table.find(VALID_DAMAGEBRICKS, v.Name)
	if not v:IsA("BoolValue") or not type then continue end
	
	local DamageBrickConfiguration = Instance.new("Configuration")
	DamageBrickConfiguration.Name = "DamageBrickConfiguration"
	DamageBrickConfiguration:SetAttribute("Cooldown", 0)
	DamageBrickConfiguration:SetAttribute("Type", VALID_DAMAGEBRICKS[type])
	
	DamageBrickConfiguration.Parent = v.Parent
	
	v:Destroy()
end 

game.ChangeHistoryService:SetWaypoint("v5.5 -> v6 Killbricks Conversion")