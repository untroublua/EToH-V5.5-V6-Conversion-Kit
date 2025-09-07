--[[
Lighting Changer Conversion v5.5 -> v6 
author: untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required
]]

local debug = true

local defaultText = "\"TowerDefault\""

local newConfig = Instance.new("Configuration")
newConfig.Name = "LightingChangerConfiguration"
newConfig:AddTag("CO_Visual/LightingChanger")
newConfig:AddTag("v6.0.0")
newConfig:SetAttribute("ChangeOnLoad", false)

local touchConfig = Instance.new("Configuration")
touchConfig.Parent = newConfig
touchConfig.Name = "TouchConfiguration"
touchConfig:SetAttribute("canFlip",false)
touchConfig:SetAttribute("player", false)
touchConfig:SetAttribute("pushbox", false)
touchConfig:SetAttribute("colorSpecific", false)
touchConfig:SetAttribute("balloon", false)
touchConfig:SetAttribute("turret", false)

local function info(warn, ...)
	if not debug then return end
	if warn then
		warn(...)
	else
		print(...)
	end
end

local Types = {
	Color3 = function(obj:Color3)
		return `Color3.fromRGB({math.floor(obj.R * 255)}, {math.floor(obj.B * 255)}, {math.floor(obj.G * 255)})`
	end,
	TweenInfo = function(obj:TweenInfo)
		return `TweenInfo.new({obj.Time}, {obj.EasingStyle}, {obj.EasingDirection})`
	end,
} :: { [string]: (obj:any) -> (string) }

local function toStringInst(obj:any)
	local ret
	local fromTable = Types[typeof(obj)]
	if fromTable then
		ret = fromTable(obj)
	else
		ret = tostring(obj)
	end

	return ret
end

for _, oldConfig in workspace:GetDescendants() do
	if not oldConfig:IsA("ModuleScript") or oldConfig.Name ~= "LightingConfiguration" then continue end
	info(false, "ℹ️ Converting lighting changer:", oldConfig.Parent)
	local toConvert = oldConfig.Parent
	
	local oldConfigTable = require(oldConfig) :: { Type:string, Configuration:{ [string]:any } | string, TweenInfo:TweenInfo }

	local lightingType = oldConfigTable.Type
	local tweenInf = toStringInst(oldConfigTable.TweenInfo)
	local configTable = oldConfigTable.Configuration

	local configTableStr
	if configTable ~= "Default" then
		configTableStr = ""
		for i,v in pairs(configTable) do
			configTableStr = configTableStr .. "\t\t" .. i .. " = " .. toStringInst(v) .. "," .. (next(configTable, i) == nil and "" or "\n")
		end
	else
		configTableStr = defaultText
	end
	info(false, configTableStr)

	local newLightingScript = string.format(
[[--!strict
local Change = require(game:GetService("ReplicatedStorage").Framework.Kit.Repository.Visual.LightingChanger.TypeDefs)
-- DON'T TOUCH THE LINE ABOVE -- -- DON'T TOUCH THE LINE ABOVE --

return Change "%s" {
	TweenInfo = %s,
	%s = %s%s
	%s
}]], 
		lightingType,
		tweenInf,
		(configTableStr == defaultText and "UseDefault" or "Configuration"),
		(configTableStr == defaultText and "" or "{\n"),
		configTableStr,
		(configTableStr == defaultText and " " or " }")
	)

	info(false, newLightingScript)

	do
		toConvert:ClearAllChildren()
		
		-- replacing sequence
		local newConfig = newConfig:Clone()
		newConfig.Parent = toConvert

		local touchConfig = newConfig.TouchConfiguration
		touchConfig:SetAttribute("player", toConvert:FindFirstChild("SupportPlayers") and toConvert.SupportPlayers.Value or false)
		touchConfig:SetAttribute("pushbox", toConvert:FindFirstChild("SupportPushboxes") and toConvert.SupportPushboxes.Value or false)
		touchConfig:SetAttribute("colorSpecific", toConvert:FindFirstChild("ColorSpecific") and toConvert.ColorSpecific.Value or false)

		local LightingScript = Instance.new("ModuleScript")
		LightingScript.Name = "Lighting"
		LightingScript.Parent = newConfig
		LightingScript.Source = newLightingScript
	end
end

newConfig:Destroy()

game.ChangeHistoryService:SetWaypoint("v5.5 -> v6 Lighting Changers Conversion")