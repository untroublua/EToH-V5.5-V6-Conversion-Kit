--[[
Lighting Changer Conversion v5.5 -> v6 
author: untroublua / @signupredirectlol & littleBitsman

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

local tabstr = "	"
local function tab(size: number)
	return string.rep(tabstr, size)
end

local matchTweeninfo = "(TweenInfo = TweenInfo%.new%(.-%))"
local matchConfiguration = "(%s*Configuration%s*=%s*{%s*%a+%s*=%s*.-,?%s*})"
local matchDefaultConfig = "(%s*Configuration%s*=%s*\"Default\")"

local changerFnBase = `Change "%s" %s`
local function makeChangerFn(ty: string, tweeninfostr: string, conf: string, isdef)	
	local tStr = "{\n"

	tStr ..= tab(1) .. tweeninfostr .. ","

	if not isdef then
		tStr ..= tab(1) .. conf
	else
		tStr ..= `\n{tab(1)}UseDefault = "TowerDefault",`
	end

	tStr ..= "\n}"

	return changerFnBase:format(ty, tStr)
end

local baseLines = [[--!strict
local Change = require(game:GetService("ReplicatedStorage").Framework.Kit.Repository.Visual.LightingChanger.TypeDefs)
-- DON'T TOUCH THE LINE ABOVE -- -- DON'T TOUCH THE LINE ABOVE --

return %s]]

local function info(warn, ...)
	if not debug then return end
	if warn then
		warn(...)
	else
		print(...)
	end
end

for _, oldConfig in workspace:GetDescendants() do
	if not oldConfig:IsA("ModuleScript") or oldConfig.Name ~= "LightingConfiguration" then continue end
	info(false, "ℹ️ Converting lighting changer:", oldConfig.Parent)
	local toConvert = oldConfig.Parent

	local oldConfigTable = require(oldConfig) :: { Type:string, Configuration:{ [string]:any } | string, TweenInfo:TweenInfo }
	
	local src = oldConfig.Source
	
	local newsrc = baseLines:format(makeChangerFn(oldConfigTable.Type, src:match(matchTweeninfo), src:match(matchConfiguration), src:match(matchDefaultConfig) ~= nil))

	info(false, newsrc)

	-- replacing sequence
	local newConfig = newConfig:Clone()
	
	local touchConfig = newConfig.TouchConfiguration
	touchConfig:SetAttribute("player", toConvert:FindFirstChild("SupportPlayers") and toConvert.SupportPlayers.Value or false)
	touchConfig:SetAttribute("pushbox", toConvert:FindFirstChild("SupportPushboxes") and toConvert.SupportPushboxes.Value or false)
	touchConfig:SetAttribute("colorSpecific", toConvert:FindFirstChild("ColorSpecific") and toConvert.ColorSpecific.Value or false)

	local LightingScript = Instance.new("ModuleScript")
	LightingScript.Name = "Lighting"
	LightingScript.Source = newsrc

	toConvert:ClearAllChildren()

	LightingScript.Parent = newConfig
	newConfig.Parent = toConvert
end

newConfig:Destroy()

game.ChangeHistoryService:SetWaypoint("v5.5 -> v6 Lighting Changers Conversion")
