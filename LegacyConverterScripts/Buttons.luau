--[[
Buttons Conversion v5.5 -> v6 
author: untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required
]]

local touchOptions = {
	SupportBalloons = "balloon",
	SupportPlayers = "player",
	SupportPushboxes = "pushbox",
	SupportTurrets = "turret",
	ColorSpecific = "colorSpecific"
}

local function loadConfig(type:string)
	if type == "Button" then
		local buttonConfig = Instance.new("Configuration")
		buttonConfig.Name = "ButtonConfiguration"
		buttonConfig:AddTag("CO_Interactables/Button")
		buttonConfig:AddTag("v6.0.2")
		buttonConfig:SetAttribute("HideGUI", false)
		buttonConfig:SetAttribute("PadDistance", 2)
		buttonConfig:SetAttribute("PadMode", false)
		buttonConfig:SetAttribute("PressedMaterial", Enum.Material.Neon)
		buttonConfig:SetAttribute("PressOffset", CFrame.new(0, -0.75, 0))
		buttonConfig:SetAttribute("Timer", 0)
		buttonConfig:SetAttribute("TimerDecimalPlaces", 0)
		buttonConfig:SetAttribute("TimerText", "{T}")

		local touchConfig = Instance.new("Configuration")
		touchConfig.Parent = buttonConfig
		touchConfig.Name = "TouchConfiguration"
		touchConfig:SetAttribute("canFlip",false)
		touchConfig:SetAttribute("player", false)
		touchConfig:SetAttribute("pushbox", false)
		touchConfig:SetAttribute("colorSpecific", false)
		touchConfig:SetAttribute("balloon", false)
		touchConfig:SetAttribute("turret", false)

		local tweenConfig = Instance.new("Configuration")
		tweenConfig.Parent = buttonConfig
		tweenConfig.Name = "TweenConfiguration"
		tweenConfig:SetAttribute("Direction", Enum.EasingDirection.Out)
		tweenConfig:SetAttribute("Style", Enum.EasingStyle.Linear)
		tweenConfig:SetAttribute("Time", 1)

		return buttonConfig
	elseif type == "ButtonDeactivator" then
		local buttonConfig = Instance.new("Configuration")
		buttonConfig:AddTag("CO_Interactables/ButtonDeactivator")
		buttonConfig:AddTag("v6.0.0")
		buttonConfig:SetAttribute("ColorSpecific", v:FindFirstChild("ColorSpecific") and v.ColorSpecific.Value or false)
		buttonConfig.Name = "ButtonConfiguration"
		
		local touchConfig = Instance.new("Configuration")
		touchConfig.Parent = buttonConfig
		touchConfig.Name = "TouchConfiguration"
		touchConfig:SetAttribute("canFlip",false)
		touchConfig:SetAttribute("player", false)
		touchConfig:SetAttribute("pushbox", false)
		touchConfig:SetAttribute("colorSpecific", false)
		touchConfig:SetAttribute("balloon", false)
		touchConfig:SetAttribute("turret", false)

		return buttonConfig
	end
end

local function applyAttr(par: Instance, conf: Configuration, valueBaseName: string, attrName: string?)
	if not attrName then 
		attrName = valueBaseName
	end

	if par:FindFirstChild(valueBaseName) and par:FindFirstChild(valueBaseName):IsA("ValueBase") then
		conf:SetAttribute(attrName, par[valueBaseName].Value)
		par[valueBaseName]:Destroy()
	end
end

local function safeDestroy(parent:Instance, instName:string, type:string?)
	pcall(function()
		if type then if not (parent:FindFirstChild(instName) and parent[instName]:IsA(type)) then return end end
		parent[instName]:Destroy()
	end)
end

for _, v in workspace:GetDescendants() do
	if v.Name == "ButtonPart" and v.Parent:FindFirstChild("Configurations") then
		v = v.Parent
		
		local oldConfig = v.Configurations
		
		local buttonConfig = loadConfig("Button")
		local touchConfig = buttonConfig.TouchConfiguration
		local tweenConfig = buttonConfig.TweenConfiguration

		buttonConfig:SetAttribute("Timer",oldConfig.Timer.Value) 
		buttonConfig:SetAttribute("HideGUI",oldConfig.HideGUI.Value)
		buttonConfig:SetAttribute("TimerDecimalPlaces",oldConfig.Timer.DecimalPlaces.Value)
		buttonConfig:SetAttribute("PressOffset",CFrame.new(0,oldConfig.ButtonPressOffset.Value,0))
		
		local oldTimerText = oldConfig:FindFirstChild("TimerText") and oldConfig.TimerText.Value ~= "" :: TextLabel
		local timerText = oldTimerText and string.gsub(oldTimerText.Value, "`", "{T}")
		if timerText then buttonConfig:SetAttribute("TimerText", timerText) end

		for old, new in touchOptions do
			applyAttr(c, touchConfig, old, new)
		end

		--TODO: check the script for easing + time for button tween

		buttonConfig.Parent = v 
		oldConfig:Destroy() 
		v.Pressed:Destroy()
		v.TimerLabel:ClearAllChildren()
		v.TimerLabel.Parent = buttonConfig
	elseif v.Name == "ButtonDeactivator" then		
		local buttonConfig = loadConfig("ButtonDeactivator")
		local touchConfig = buttonConfig.TouchConfiguration

		for old, new in touchOptions do
			applyAttr(c, touchConfig, old, new)
		end
		
		buttonConfig.Parent = v

		safeDestroy(v, "ColorSpecific")
		safeDestroy(v, "SupportPlayers")
		safeDestroy(v, "SupportPushboxes")
	end
end

game.ChangeHistoryService:SetWaypoint("v5.5 -> v6 Buttons Conversion")