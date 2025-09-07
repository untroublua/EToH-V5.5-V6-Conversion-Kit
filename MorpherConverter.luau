-- by littlebitsman
-- BEWARE: THIS MAY MISS SOME PROPERTIES ON PARTS, ETC. CHECK YOUR CLIENT OBJECTS AND BACKUP BEFORE USING.

local CO = workspace.CoTUD.ClientSidedObjects

local funny = {
	SupportBalloons = "balloon",
	SupportPlayers = "player",
	SupportPushboxes = "pushbox",
	SupportTurrets = "turret"
}

function applyAttr(par: Instance, conf: Configuration, valueBaseName: string, attrName: string?)
	if not attrName then 
		attrName = valueBaseName
	end
	
	if par:FindFirstChild(valueBaseName) and par:FindFirstChild(valueBaseName):IsA("ValueBase") then
		conf:SetAttribute(attrName, par[valueBaseName].Value)
		par[valueBaseName]:AddTag("REMOVE_AFTER_V6")
	end
end

return function()
	for _, inst in CO.Morphers:GetChildren() do
		local conf = workspace.MorpherConfiguration:Clone()
		conf.Parent = inst
		
		local cos = inst:FindFirstChild("ClientObjectScript")
		if cos then
			if cos:FindFirstChild("DurationGui") then
				cos:FindFirstChild("DurationGui"):FindFirstChildWhichIsA("TextLabel").Name = "TimerLabel"
				conf.DurationGui:Destroy()
				cos.DurationGui.Parent = conf
			end
			cos:AddTag("REMOVE_AFTER_V6")
		end
		
		for _, c in inst:GetChildren() do
			if c.Name == "Button" then
				local btnConf = workspace.MorpherButtonConfiguration:Clone()
				btnConf.Parent = c
				
				applyAttr(c, btnConf, "MorphDuration", "Timer")
				if btnConf:GetAttribute("Timer") < 0 then
					btnConf:SetAttribute("Timer", 0)
				end
				
				applyAttr(c, btnConf.MoveTweenConfiguration, "MorphSpeed", "Time")
				applyAttr(c, btnConf.ReturnTweenConfiguration, "ReturnSpeed", "Time")
				
				for k, v in funny do
					applyAttr(c, btnConf.TouchConfiguration, k, v)
				end
			end
		end
	end
end
