--[[
Dismounters Conversion v5.5 -> v6
author: untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required
]]

local function loadConfig()
	local DismounterConfiguration = Instance.new("Configuration")
	DismounterConfiguration.Name = "DismounterConfiguration"
	DismounterConfiguration:AddTag("CO_Interactables/Dismounter")
	DismounterConfiguration:AddTag("v6.0.1")
	DismounterConfiguration:SetAttribute("DismountSeats", false)
	DismounterConfiguration:SetAttribute("MountColorSpecific", false)
	DismounterConfiguration:SetAttribute("DismountSwings", false)
	DismounterConfiguration:SetAttribute("DismountBalloons", false)
	DismounterConfiguration:SetAttribute("DismountZiplines", false)
	DismounterConfiguration:SetAttribute("DismountAttachers", false)
	DismounterConfiguration:SetAttribute("ForceDismountPlayer", false)
	DismounterConfiguration:SetAttribute("Cooldown", 0)
	DismounterConfiguration:SetAttribute("DismountVines", false)
	
	local TouchConfiguration = Instance.new("Configuration")
	TouchConfiguration.Name = "TouchConfiguration"
	TouchConfiguration.Parent = DismounterConfiguration
	TouchConfiguration:SetAttribute("canFlip", false)
	TouchConfiguration:SetAttribute("colorSpecific", false)
	TouchConfiguration:SetAttribute("turret", false)
	TouchConfiguration:SetAttribute("balloon", false)
	TouchConfiguration:SetAttribute("pushbox", false)
	TouchConfiguration:SetAttribute("player", false)
	
	return DismounterConfiguration
end

local function safeDestroy(parent:Instance, instName:string)
	pcall(function()
		parent[instName]:Destroy()
	end)
end

for _, v in workspace:GetDescendants() do
	if v:IsA("ModuleScript") and v.Source:match("noJumpSignal") then 
		local vineDismounter = v.Parent :: BasePart
		
		local config = loadConfig()
		config.Parent = vineDismounter
		config:SetAttribute("DismountVines", true)
		
		config.TouchConfiguration:SetAttribute("player", true)
		
		safeDestroy(vineDismounter,"ClientObject")
		safeDestroy(vineDismounter,"NoJump")
		safeDestroy(vineDismounter,"ClientObjectScript")
	elseif v.Name == "BalloonDestroyer" then
		local config = loadConfig()
		config.Parent = v
		config:SetAttribute("DismountBalloons", true)
		
		config.TouchConfiguration:SetAttribute("balloons", true)
		
		safeDestroy(v,"ClientObject")
	end
end

game.ChangeHistoryService:SetWaypoint("v5.5 -> v6 Dismounters Conversion")
