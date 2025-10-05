--[[
Lighting Changer Conversion v5.5 -> v6 
author: littleBitsman & untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required
]]

local debug = true

local defaultText = "\"TowerDefault\""

local function loadConfig()
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
	
	return newConfig
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

local function safeDestroy(parent:Instance, instName:string, type:string)
	pcall(function()
		if type then if not (parent:FindFirstChild(instName) and parent[instName]:IsA(type)) then return end end
		parent[instName]:Destroy()
	end)
end

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
	local newConfig = loadConfig()
	local touchConfig = newConfig.TouchConfiguration
	applyAttr(touchConfig, toConvert, "SupportPlayers", "player")
	applyAttr(touchConfig, toConvert, "SupportPushboxes", "pushbox")
	applyAttr(touchConfig, toConvert, "ColorSpecific", "colorSpecific")
	newConfig.Parent = toConvert

	safeDestroy(toConvert,"LightingConfiguration")
	local LightingScript = Instance.new("ModuleScript")
	LightingScript.Name = "Lighting"
	LightingScript.Source = newsrc
	LightingScript.Parent = newConfig
end

newConfig:Destroy()

game.ChangeHistoryService:SetWaypoint("v5.5 -> v6 Lighting Changers Conversion")
