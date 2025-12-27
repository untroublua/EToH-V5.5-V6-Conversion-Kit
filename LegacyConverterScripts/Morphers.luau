--[[
Morphers Conversion v5.5 -> v6 
author: littleBitsman & untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required
]]

local touchOptions = {
	SupportBalloons = "balloon",
	SupportPlayers = "player",
	SupportPushboxes = "pushbox",
	SupportTurrets = "turret"
}

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

local function configCheck(config, configValue)
	local foundValue = config:FindFirstChild(configValue)
	if foundValue == nil then return false end

	return (foundValue:IsA("ValueBase") and not (foundValue:IsA("BoolValue") and foundValue.Value == false))
end

local function loadConfig(main, parent)
	if main then
		local MorpherConfiguration = Instance.new("Configuration")
		MorpherConfiguration.Name = "MorpherConfiguration"
		MorpherConfiguration:AddTag("CO_Interactables/Morpher")
		MorpherConfiguration:AddTag("v6.0.0")
		
		MorpherConfiguration.Parent = parent
		return MorpherConfiguration
	else
		local MorpherButtonConfiguration = Instance.new("Configuration")
		MorpherButtonConfiguration.Name = "MorpherButtonConfiguration"
		MorpherButtonConfiguration:SetAttribute("Timer", 0)
		MorpherButtonConfiguration:SetAttribute("TimerDecimalPlaces", 0)
		MorpherButtonConfiguration:SetAttribute("CarryObjects", true)
		MorpherButtonConfiguration:SetAttribute("TimerText", "{T}")

		local TouchConfiguration = Instance.new("Configuration")
		TouchConfiguration.Name = "TouchConfiguration"
		TouchConfiguration.Parent = MorpherButtonConfiguration
		TouchConfiguration:SetAttribute("canFlip", false)
		TouchConfiguration:SetAttribute("colorSpecific", false)
		TouchConfiguration:SetAttribute("turret", false)
		TouchConfiguration:SetAttribute("balloon", false)
		TouchConfiguration:SetAttribute("pushbox", true)
		TouchConfiguration:SetAttribute("player", true)

		local MoveTweenConfiguration = Instance.new("Configuration")
		MoveTweenConfiguration.Name = "MoveTweenConfiguration"
		MoveTweenConfiguration.Parent = MorpherButtonConfiguration
		MoveTweenConfiguration:SetAttribute("Direction", Enum.EasingDirection.Out)
		MoveTweenConfiguration:SetAttribute("Style", Enum.EasingStyle.Quad)
		MoveTweenConfiguration:SetAttribute("Time", 1)

		local ReturnTweenConfiguration = Instance.new("Configuration")
		ReturnTweenConfiguration.Name = "ReturnTweenConfiguration"
		ReturnTweenConfiguration.Parent = MorpherButtonConfiguration
		ReturnTweenConfiguration:SetAttribute("Direction", Enum.EasingDirection.Out)
		ReturnTweenConfiguration:SetAttribute("Style", Enum.EasingStyle.Quad)
		ReturnTweenConfiguration:SetAttribute("Time", 1)
		
		MorpherButtonConfiguration.Parent = parent
		return MorpherButtonConfiguration
	end
end

for _, coScript in workspace:GetDescendants() do
	if not (coScript:IsA("ModuleScript") and coScript.Name == "ClientObjectScript" and coScript:FindFirstChild("DurationGui")) then continue end
	
	local model = coScript.Parent
	local DurationGui = coScript.DurationGui
	local Press = coScript.Press :: Sound
	local Tick = coScript.Tick :: Sound
	local morph = model.Morph
	
	local MorpherGroup = Instance.new("Folder")
	MorpherGroup.Name = "Morpher Group"
	MorpherGroup.Parent = model.Parent
	game.Selection:Set({MorpherGroup})
	
	local conf = loadConfig(true, MorpherGroup)
	conf.Parent = MorpherGroup
	
	morph.Parent = MorpherGroup
	
	if coScript:FindFirstChild("DurationGui") then
		DurationGui:FindFirstChildWhichIsA("TextLabel").Name = "TimerLabel"
		DurationGui.Parent = conf
	end

	for _, c in model:GetChildren() do
		if not c:FindFirstChild("NewMorph",true) then continue end
		
		local btnConf = loadConfig(false, c)
		
		Press:Clone().Parent = btnConf
		Tick:Clone().Parent = btnConf

		applyAttr(c, btnConf, "MorphDuration", "Timer")
		if btnConf:GetAttribute("Timer") < 0 then
			btnConf:SetAttribute("Timer", 0)
		end

		applyAttr(c, btnConf.MoveTweenConfiguration, "MorphSpeed", "Time")
		applyAttr(c, btnConf.ReturnTweenConfiguration, "ReturnSpeed", "Time")

		for old, new in touchOptions do
			applyAttr(c, btnConf.TouchConfiguration, old, new)
		end
		
		c.Parent = MorpherGroup
	end
end

game.ChangeHistoryService:SetWaypoint("v5.5 -> v6 Morpher Conversion")