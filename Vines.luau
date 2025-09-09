--[[
Vines Conversion v5.5 -> v6 
author: untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required
]]

local function configCheck(config, configValue)
	local foundValue = config:FindFirstChild(configValue)
	if foundValue == nil then return false end

	return (foundValue:IsA("ValueBase") and not (foundValue:IsA("BoolValue") and foundValue.Value == false))
end

local function loadVinePartChildren(parent)
	local RespawnParticle = Instance.new("ParticleEmitter")
	RespawnParticle.Name = "RespawnParticle"
	RespawnParticle.LightInfluence = 1
	RespawnParticle.Lifetime = NumberRange.new(0.5, 0.5)
	RespawnParticle.SpreadAngle = Vector2.new(360, 360)
	RespawnParticle.Transparency = NumberSequence.new(0.5, 1)
	RespawnParticle.LightEmission = 0.5
	RespawnParticle.VelocitySpread = 360
	RespawnParticle.Speed = NumberRange.new(0, 0)
	RespawnParticle.Size = NumberSequence.new(0, 1)
	RespawnParticle.Enabled = false
	RespawnParticle.ZOffset = 0.5
	RespawnParticle.Rate = 50
	RespawnParticle.Texture = "rbxassetid://298984512"
	RespawnParticle.RotSpeed = NumberRange.new(-100, 100)
	
	RespawnParticle.Parent = parent
end

local function loadAttachmentPartChildren(parent)
	local VineAttachment = Instance.new("Attachment")
	VineAttachment.Name = "VineAttachment"
	VineAttachment.Position = Vector3.zero
	VineAttachment.Orientation = Vector3.new(0, 0, 90)
	
	VineAttachment.Parent = parent
end

local function loadRopeBar(parent)
	local RopeBar = Instance.new("Part")
	RopeBar.Name = "RopeBar"
	RopeBar.Position = parent.AttachmentPart.Position + Vector3.new(0, 1.5 * parent.AttachmentPart.Size.Y, 0)
	RopeBar.BottomSurface = Enum.SurfaceType.Smooth
	RopeBar.CanCollide = false
	RopeBar.TopSurface = Enum.SurfaceType.Smooth
	RopeBar.Color = Color3.fromRGB(91, 93, 105)
	RopeBar.Size = Vector3.new(4, 0.4, 0.4)
	RopeBar.Orientation = Vector3.zero
	RopeBar.Anchored = true
	RopeBar.CustomPhysicalProperties = PhysicalProperties.new(50, 0.3, 0.5)
	
	RopeBar.Parent = parent
	
	local BarAttachment = Instance.new("Attachment")
	BarAttachment.Name = "BarAttachment"
	BarAttachment.Position = Vector3.zero
	BarAttachment.Orientation = Vector3.new(0, 0, 90)
	
	BarAttachment.Parent = RopeBar
	
	local AlignOrientation = Instance.new("AlignOrientation")
	AlignOrientation.MaxTorque = 99999997952
	AlignOrientation.AlignType = Enum.AlignType.Parallel
	AlignOrientation.Responsiveness = 20
	AlignOrientation.Attachment0 = BarAttachment
	
	AlignOrientation.Parent = RopeBar
	
	BarAttachment.Parent = RopeBar
end

local function loadVineConstraint(parent)
	local VineConstraint = Instance.new("RopeConstraint")
	VineConstraint.Name = "VineConstraint"
	VineConstraint.Visible = true
	VineConstraint.Color = BrickColor.new("Smoky grey")
	VineConstraint.Enabled = false
	VineConstraint.Length = 12
	
	VineConstraint.Parent = parent
	return VineConstraint
end

local function loadConfig(parent)
	local VineConfiguration = Instance.new("Configuration")
	VineConfiguration.Name = "VineConfiguration"
	VineConfiguration:SetAttribute("AllowJumpDismount", true)
	VineConfiguration:SetAttribute("RespawnTime", 1)
	VineConfiguration:SetAttribute("KeepMomentum", true)
	VineConfiguration:SetAttribute("HandleAnimation", true)
	VineConfiguration:AddTag("CO_Mountables/Vine")
	VineConfiguration:AddTag("v6.0.1")

	local TouchConfiguration = Instance.new("Configuration")
	TouchConfiguration.Name = "TouchConfiguration"
	TouchConfiguration.Parent = VineConfiguration
	TouchConfiguration:SetAttribute("canFlip", false)
	TouchConfiguration:SetAttribute("colorSpecific", false)
	TouchConfiguration:SetAttribute("turret", false)
	TouchConfiguration:SetAttribute("balloon", false)
	TouchConfiguration:SetAttribute("pushbox", true)
	TouchConfiguration:SetAttribute("player", true)

	local TweenConfiguration = Instance.new("Configuration")
	TweenConfiguration.Name = "TweenConfiguration"
	TweenConfiguration.Parent = VineConfiguration
	TweenConfiguration:SetAttribute("Direction", Enum.EasingDirection.Out)
	TweenConfiguration:SetAttribute("Style", Enum.EasingStyle.Linear)
	TweenConfiguration:SetAttribute("Time", 0.5)
	
	VineConfiguration.Parent = parent
	
	return VineConfiguration
end

local function safeDestroy(parent:Instance, instName:string, type:string)
	pcall(function()
		if type then if not (parent:FindFirstChild(instName) and parent[instName]:IsA(type)) then return end end
		parent[instName]:Destroy()
	end)
end

for _, v in workspace:GetDescendants() do
	if v.Name ~= "RopeLength" then continue end
	v = v.Parent
	
	local VinePart = v.Swing :: BasePart
	VinePart.Name = "VinePart"
	local AttachmentPart = v.Top :: BasePart
	AttachmentPart.Name = "AttachmentPart"
	local SoundsFolder = Instance.new("Folder")
	SoundsFolder.Name = "Sounds"
	for _, v in v.ClientObjectScript:GetChildren() do
		if v:IsA("Sound") then v.Parent = SoundsFolder end
	end
	SoundsFolder.Parent = v
	
	v.ClientObjectScript:Destroy()
	local config = loadConfig(v)
	local vineConstraint = loadVineConstraint(v)
	loadRopeBar(v)
	
	loadAttachmentPartChildren(AttachmentPart)
	
	if VinePart:FindFirstChildWhichIsA("SpecialMesh") then 
		VinePart.Shape = Enum.PartType.Cylinder
		VinePart:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
	end
	
	loadVinePartChildren(VinePart)
	
	config:SetAttribute("AllowJumpDismount", configCheck(v,"AllowJumpDismount"))
	config:SetAttribute("RespawnTime", (configCheck(v,"RespawnTime") and v.RespawnTime.Value) or 1)
	config:SetAttribute("KeepMomentum", configCheck(v,"KeepVelocity"))
	
	vineConstraint.Length = (configCheck(v,"RopeLength") and v.RopeLength.Value) or 12
	
	safeDestroy(v,"AllowJumpDismount")
	safeDestroy(v,"ClientObject")
	safeDestroy(v,"KeepVelocity")
	safeDestroy(v,"RespawnTime")
	safeDestroy(v,"RopeLength")
	safeDestroy(v,"ClientObjectScript")
	
	v.Name = "Vine"
end

game.ChangeHistoryService:SetWaypoint("v5.5 -> v6 Vines Conversion")