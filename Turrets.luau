--[[
Turrets Conversion v5.5 -> v6
author: untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required

CAUTION: THIS SCRIPT IS NOT TESTED THOROUGHLY
]]

local function loadConfig()
	local TurretConfiguration = Instance.new("Configuration")
	TurretConfiguration.Name = "TurretConfiguration"

	TurretConfiguration:AddTag("CO_Interactables/Turret")
	TurretConfiguration:AddTag("v6.0.1")
	TurretConfiguration:SetAttribute("DestroyOnTouch", true)
	TurretConfiguration:SetAttribute("MaxLifetime", 5)
	TurretConfiguration:SetAttribute("FireRate", 1)
	TurretConfiguration:SetAttribute("Speed", 50)
	TurretConfiguration:SetAttribute("ActivatorCooldown", 1)
	TurretConfiguration:SetAttribute("Range", 50)
	TurretConfiguration:SetAttribute("Damage", 5)

	return TurretConfiguration
end

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

local function safeDestroy(parent:Instance, instName:string)
	pcall(function()
		parent[instName]:Destroy()
	end)
end

for _, bullet in workspace:GetDescendants() do
	if not (bullet:IsA("BasePart") and bullet.Name == "Bullet" and bullet.Parent and bullet.Parent:FindFirstChildWhichIsA("ModuleScript",true) and bullet.Parent:FindFirstChildWhichIsA("ModuleScript",true).Source:match("presetBullet")) then continue end

	local model = bullet.Parent 
	local coScript = model:FindFirstChildWhichIsA("ModuleScript",true)

	local turret = coScript.Parent
	turret.Name = "Turret"

	local config = loadConfig()
	config.Parent = model

	applyAttr(model, config, "Damage")
	applyAttr(model, config, "Delay","FireRate")
	config:SetAttribute("Speed", model.Speed.Value)
	config:SetAttribute("FireRate", 1 / config:GetAttribute("FireRate"))
	config:SetAttribute("MaxLifetime", model.Distance.Value / model.Speed.Value)
	model.Speed:Destroy()
	model.Distance:Destroy()

	local Activators = Instance.new("Folder")
	Activators.Name = "Activators"
	Activators.Parent = model

	local bulletModel = Instance.new("Model")
	bulletModel.Name = "Bullet"
	bullet.Parent = bulletModel
	bulletModel.PrimaryPart = bullet
	bulletModel.Parent = model
	bulletModel:AddTag("SkipObjectLoad")

	config:SetAttribute("DestroyOnTouch", not ((model:FindFirstChild("IgnoreParts") and model.IgnoreParts.Value) or (model:FindFirstChild("IgnorePlayers") and model.IgnorePlayers.Value) or (bullet:FindFirstChild("IgnoreBullets") and bullet.IgnoreBullets.Value)))

	safeDestroy(model,"ClientObject")
	safeDestroy(model, "IgnorePlayers")
	safeDestroy(model, "IgnoreParts")
	safeDestroy(turret, "IgnoreBullets")
	coScript:Destroy()
end

game.ChangeHistoryService:SetWaypoint("v5.5 -> v6 Turrets Conversion")
