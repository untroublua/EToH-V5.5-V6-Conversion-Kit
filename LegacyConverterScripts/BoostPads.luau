--[[
Boost Pads Conversion v5.5 -> v6
author: untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required
]]

local BoostPadTypes = {
	JumpPower = "Jump",
	WalkSpeed = "Speed"
}

local function loadConfig()
	local BoostPadConfiguration = Instance.new("Configuration")
	BoostPadConfiguration.Name = "BoostPadConfiguration"
	BoostPadConfiguration:AddTag("CO_Interactables/BoostPad")
	BoostPadConfiguration:AddTag("v6.0.0")
	BoostPadConfiguration:SetAttribute("Distance", 10)
	BoostPadConfiguration:SetAttribute("Type", "Jump")
	BoostPadConfiguration:SetAttribute("Power", 100)

	local TouchConfiguration = Instance.new("Configuration")
	TouchConfiguration.Name = "TouchConfiguration"
	TouchConfiguration.Parent = BoostPadConfiguration
	TouchConfiguration:SetAttribute("canFlip", false)
	TouchConfiguration:SetAttribute("colorSpecific", false)
	TouchConfiguration:SetAttribute("turret", false)
	TouchConfiguration:SetAttribute("balloon", false)
	TouchConfiguration:SetAttribute("pushbox", true)
	TouchConfiguration:SetAttribute("player", true)
	
	return BoostPadConfiguration
end

local function safeDestroy(parent:Instance, instName:string, type:string)
	pcall(function()
		if type then if not (parent:FindFirstChild(instName) and parent[instName]:IsA(type)) then return end end
		parent[instName]:Destroy()
	end)
end

for _, pad in workspace:GetDescendants() do
	local boostName = pad.Name
	local type = BoostPadTypes[boostName]
	if not type or not pad.Parent:FindFirstChild("Distance") then continue end
	pad = pad.Parent
	local type = BoostPadTypes[boostName]
	local boost = pad:FindFirstChild(boostName) :: NumberValue
	
	local config = loadConfig()
	config:SetAttribute("Type",type)
	config:SetAttribute("Power", boost.Value)
	config:SetAttribute("Distance", pad.Distance.Value == 0 and -pad.Size.Y or pad.Distance.Value)
	config.Parent = pad

	safeDestroy(pad, "ClientObject")
	safeDestroy(pad, "Distance")
	boost:Destroy()
	safeDestroy(pad, "ClientObjectScript")
	pad.Name = `{type} BoostPad`
end

game.ChangeHistoryService:SetWaypoint("v5.5 -> v6 BoostPads Conversion")