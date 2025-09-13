--[[
Teleporters Conversion v5.5 -> v6
author: untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required
]]

local easingStylePattern = "Enum%.EasingStyle%.%a+"
local easingDirPattern = "Enum%.EasingDirection%.%a+"

local function applyAttr(par: Instance, conf: Configuration, valueBaseName: string, attrName: string?)
	-- function made by littleBitsman
	if not attrName then 
		attrName = valueBaseName
	end

	if par:FindFirstChild(valueBaseName) and par:FindFirstChild(valueBaseName):IsA("ValueBase") then
		conf:SetAttribute(attrName, par[valueBaseName].Value)
		par[valueBaseName]:Destroy()
	end
end

local function loadConfig()
	local TeleporterConfiguration = Instance.new("Configuration")
	TeleporterConfiguration.Name = "TeleporterConfiguration"
	TeleporterConfiguration:AddTag("CO_Interactables/Teleporter")
	TeleporterConfiguration:AddTag("v6.0.0")
	TeleporterConfiguration:SetAttribute("Offset", CFrame.new(0, 4, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1))
	TeleporterConfiguration:SetAttribute("DisableCollision", false)
	TeleporterConfiguration:SetAttribute("SeamlessTeleport", false)
	TeleporterConfiguration:SetAttribute("Instant", false)
	TeleporterConfiguration:SetAttribute("KeepVelocity", true)

	local TouchConfiguration = Instance.new("Configuration")
	TouchConfiguration.Name = "TouchConfiguration"
	TouchConfiguration.Parent = TeleporterConfiguration
	TouchConfiguration:SetAttribute("canFlip", false)
	TouchConfiguration:SetAttribute("colorSpecific", false)
	TouchConfiguration:SetAttribute("turret", false)
	TouchConfiguration:SetAttribute("balloon", false)
	TouchConfiguration:SetAttribute("pushbox", true)
	TouchConfiguration:SetAttribute("player", true)

	local TweenConfiguration = Instance.new("Configuration")
	TweenConfiguration.Name = "TweenConfiguration"
	TweenConfiguration.Parent = TeleporterConfiguration
	TweenConfiguration:SetAttribute("Direction", Enum.EasingDirection.Out)
	TweenConfiguration:SetAttribute("Style", Enum.EasingStyle.Linear)
	TweenConfiguration:SetAttribute("Time", 1)
	
	return TeleporterConfiguration
end

local function loadVisuals(parent)
	local UpDirection = Instance.new("ConeHandleAdornment")
	UpDirection.Name = "UpDirection"
	UpDirection.Transparency = 0.25
	UpDirection.Color3 = Color3.fromRGB(255, 255, 255)
	UpDirection.AdornCullingMode = Enum.AdornCullingMode.Never
	UpDirection.CFrame = CFrame.new(0, 0.25, 0, 1, 0, 0, 0, 0, -1, 0, 1, 0)
	UpDirection.SizeRelativeOffset = Vector3.new(0, 1, 0)
	UpDirection.Height = 1
	UpDirection.Parent = parent
	UpDirection.Adornee = parent

	UpDirection:AddTag("OnlyInStudio")
	
	local LookDirection = Instance.new("ConeHandleAdornment")
	LookDirection.Name = "LookDirection"
	LookDirection.Transparency = 0.25
	LookDirection.Color3 = Color3.fromRGB(255, 255, 255)
	LookDirection.AdornCullingMode = Enum.AdornCullingMode.Never
	LookDirection.CFrame = CFrame.new(0, 0, -0.25)
	LookDirection.SizeRelativeOffset = Vector3.new(0, 0, -1)
	LookDirection.Height = 1
	LookDirection.Parent = parent
	LookDirection.Adornee = parent

	LookDirection:AddTag("OnlyInStudio")
end

for _, Destination in workspace:GetDescendants() do
	if not (Destination:IsA("BasePart") and Destination.Name == "Destination" and Destination.Parent:FindFirstChild("ClientObjectScript")) then continue end
	local model = Destination.Parent
	local tpSound = Destination:FindFirstChildWhichIsA("Sound")
	tpSound.Name = "Teleport"
	local coScript = model.ClientObjectScript :: ModuleScript
	local coScriptSrc = coScript.Source
	
	loadVisuals(Destination)
	local config = loadConfig()
	config.Parent = model
	
	if model:FindFirstChild("RemoveButtons") then model.RemoveButtons:Destroy() end
	applyAttr(model,config,"KeepVelocity")
	
	local transitionTime = model:FindFirstChild("TransitionTime")
	if transitionTime and transitionTime.Value > 0 then
		applyAttr(model,config.TweenConfiguration,"TransitionTime","Time")
	else
		transitionTime:Destroy()
		config:SetAttribute("Instant", true)
	end
	
	local easingStyle = loadstring(`return {coScriptSrc:match(easingStylePattern)}`)() :: Enum.EasingStyle
	local easingDir = loadstring(`return {coScriptSrc:match(easingDirPattern)}`)() :: Enum.EasingDirection
	config.TweenConfiguration:SetAttribute("Style", easingStyle)
	config.TweenConfiguration:SetAttribute("Direction", easingDir)

	applyAttr(model,config.TouchConfiguration,"TeleportPlayers", "player")
	applyAttr(model,config.TouchConfiguration,"TeleportPushboxes", "pushbox")
	
	coScript:Destroy()
end

game.ChangeHistoryService:SetWaypoint("v5.5 -> v6 Teleporters Conversion")
