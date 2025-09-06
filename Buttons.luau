--[[
Buttons Conversion v5.5 -> v6 
author: untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required
]]

game.ChangeHistoryService:SetWaypoint("v5.5 -> v6 Buttons Conversion")

for _, v in workspace:GetDescendants() do
	if v:IsA("TextLabel") and v.Name == "TimerLabel" and v.Parent:IsA("Model") then
		v = v.Parent
		
		local oldConfig = v.Configurations
		
		local buttonConfig = Instance.new("Configuration")
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
		buttonConfig.Name = "ButtonConfiguration"
		
		buttonConfig:SetAttribute("Timer",oldConfig.Timer.Value) 
		buttonConfig:SetAttribute("HideGUI",oldConfig.HideGUI.Value)
		buttonConfig:SetAttribute("TimerDecimalPlaces",oldConfig.Timer.DecimalPlaces.Value)
		buttonConfig:SetAttribute("PressOffset",CFrame.new(0,oldConfig.ButtonPressOffset.Value,0))
		
		local oldTimerText = oldConfig:FindFirstChild("TimerText") and oldConfig.TimerText.Value ~= "" :: TextLabel
		local timerText = oldTimerText and string.gsub(oldTimerText.Value, "`", "{T}")
		if timerText then buttonConfig:SetAttribute("TimerText", timerText) end
		
		local touchConfig = Instance.new("Configuration")
		touchConfig.Parent = buttonConfig
		touchConfig.Name = "TouchConfiguration"
		touchConfig:SetAttribute("canFlip",false)
		touchConfig:SetAttribute("player", false)
		touchConfig:SetAttribute("pushbox", false)
		touchConfig:SetAttribute("colorSpecific", false)
		touchConfig:SetAttribute("balloon", false)
		touchConfig:SetAttribute("turret", false)
		
		touchConfig:SetAttribute("player", oldConfig:FindFirstChild("SupportPlayers") and oldConfig.SupportPlayers.Value or false)
		touchConfig:SetAttribute("pushbox", oldConfig:FindFirstChild("SupportPushboxes") and oldConfig.SupportPushboxes.Value or false)
		touchConfig:SetAttribute("colorSpecific", oldConfig:FindFirstChild("ColorSpecific") and oldConfig.ColorSpecific.Value or false)
		touchConfig:SetAttribute("balloon", oldConfig:FindFirstChild("SupportBalloons") and oldConfig.SupportBalloons.Value or false)
		touchConfig:SetAttribute("turret", oldConfig:FindFirstChild("SupportTurrets") and oldConfig.SupportTurrets.Value or false)
		
		local tweenConfig = Instance.new("Configuration")
		tweenConfig.Parent = buttonConfig
		tweenConfig.Name = "TweenConfiguration"
		tweenConfig:SetAttribute("Direction", Enum.EasingDirection.Out)
		tweenConfig:SetAttribute("Style", Enum.EasingStyle.Linear)
		tweenConfig:SetAttribute("Time", 1)

		buttonConfig.Parent = v 
		oldConfig:Destroy() 
		v.Pressed:Destroy()
		v.TimerLabel:ClearAllChildren()
		v.TimerLabel.Parent = buttonConfig
	elseif v.Name == "ButtonDeactivator" then		
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
		
		touchConfig:SetAttribute("player", v:FindFirstChild("SupportPlayers") and v.SupportPlayers.Value or false)
		touchConfig:SetAttribute("pushbox", v:FindFirstChild("SupportPushboxes") and v.SupportPushboxes.Value or false)
		
		v:ClearAllChildren()
		
		buttonConfig.Parent = v
	end
end