-- by littlebitsman

type Conf = {
	Configuration: { [string]: any } | "Default",
	TweenInfo: TweenInfo,
	Type: string
}

local tabstr = "	"
function tab(size: number)
	return string.rep(tabstr, size)
end

local matchTweeninfo = "(TweenInfo = TweenInfo%.new%(.-%))"
local matchConfiguration = "(%s*Configuration%s*=%s*{%s*%a+%s*=%s*.-,?%s*})"
local matchDefaultConfig = "(%s*Configuration%s*=%s*\"Default\")"

local changerFnBase = `Change "%s" %s`
function makeChangerFn(ty: string, tweeninfostr: string, conf: string, isdef)	
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

return function(folder: Instance)
	for _, inst in folder:GetChildren() do 
		local modraw: ModuleScript? = inst:FindFirstChild("LightingConfiguration") 
		if not modraw then continue end
		local mod = require(modraw)
		local src = modraw.Source

		local newsrc = baseLines:format(makeChangerFn(mod.Type, src:match(matchTweeninfo), src:match(matchConfiguration), src:match(matchDefaultConfig) ~= nil))
		local newconf = workspace.LightingChangerConfiguration:Clone()
		newconf.Parent = inst
		newconf.Lighting.Source = newsrc

		if inst:FindFirstChild("ColorSpecific") then
			inst.ColorSpecific:AddTag("REMOVE_AFTER_V6")
		end
		if inst:FindFirstChild("Invisible") then
			inst.Invisible:AddTag("REMOVE_AFTER_V6")
			inst:AddTag("Invisible")
		end
		if inst:FindFirstChild("SupportPlayers") then
			inst.SupportPlayers:AddTag("REMOVE_AFTER_V6")
		end
		if inst:FindFirstChild("SupportPushboxes") then
			inst.SupportPushboxes:AddTag("REMOVE_AFTER_V6")
		end
		modraw:AddTag("REMOVE_AFTER_V6")
	end
end
