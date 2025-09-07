--[[
Ziplines Conversion v5.5 -> v6
author: @littleBitsman & untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required

CAUTION: NOT TESTED WELL MAY HAVE ISSUES (make sure you have a backup of your cos!)
]]

local function configCheck(config, configValue)
	local foundValue = config:FindFirstChild(configValue)
	if foundValue == nil then return false end

	return (foundValue:IsA("ValueBase") and not (foundValue:IsA("BoolValue") and foundValue.Value == false))
end

local function loadConfig(parent)
	local ZiplineConfiguration = Instance.new("Configuration")
	ZiplineConfiguration.Name = "ZiplineConfiguration"
	ZiplineConfiguration:GetAttribute("GuideColor", Color3.new(1, 1, 0))
	ZiplineConfiguration:GetAttribute("RopeLength", 5)
	ZiplineConfiguration:GetAttribute("AllowEndDismount", true)
	ZiplineConfiguration:GetAttribute("SegmentWidth", 0.25)
	ZiplineConfiguration:GetAttribute("AllowJumpDismount", true)
	ZiplineConfiguration:GetAttribute("Loop", false)
	ZiplineConfiguration:GetAttribute("Segments", 20)
	ZiplineConfiguration:GetAttribute("SegmentShape", Enum.PartType.Cylinder)
	ZiplineConfiguration:GetAttribute("Speed", 50)
	ZiplineConfiguration:GetAttribute("AllowUserControl", false)
	ZiplineConfiguration:GetAttribute("KeepMomentum", false)
	ZiplineConfiguration:GetAttribute("HandleAnimation", true)
	ZiplineConfiguration:AddTag("CO_Mountables/Zipline")
	ZiplineConfiguration:AddTag("v6.0.1")

	local TouchConfiguration = Instance.new("Configuration")
	TouchConfiguration.Name = "TouchConfiguration"
	TouchConfiguration.Parent = ZiplineConfiguration
	TouchConfiguration:SetAttribute("canFlip", false)
	TouchConfiguration:SetAttribute("colorSpecific", false)
	TouchConfiguration:SetAttribute("turret", false)
	TouchConfiguration:SetAttribute("balloon", false)
	TouchConfiguration:SetAttribute("pushbox", false)
	TouchConfiguration:SetAttribute("player", true)

	ZiplineConfiguration.Parent = parent

	return ZiplineConfiguration
end

local function loadGuideEffects(parent)
	local GuideEffects = Instance.new("Folder")
	GuideEffects.Name = "GuideEffects"

	local ParticleEmitter = Instance.new("ParticleEmitter")
	ParticleEmitter.LightInfluence = 1
	ParticleEmitter.Lifetime = NumberRange.new(0.5, 0.5)
	ParticleEmitter.SpreadAngle = Vector2.new(-360, 360)
	ParticleEmitter.Transparency = NumberSequence.new(0.25, 1)
	ParticleEmitter.LightEmission = 1
	ParticleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
	ParticleEmitter.VelocitySpread = -360
	ParticleEmitter.Speed = NumberRange.new(2, 2)
	ParticleEmitter.Size = NumberSequence.new(0.5, 0)
	ParticleEmitter.Enabled = false
	ParticleEmitter.ZOffset = 1
	ParticleEmitter.Rate = 75
	ParticleEmitter.Texture = "rbxassetid://6479341134"
	ParticleEmitter.RotSpeed = NumberRange.new(-360, 360)
	ParticleEmitter.Rotation = NumberRange.new(-360, 360)
	ParticleEmitter.Parent = GuideEffects
	
	GuideEffects.Parent = parent
end

local function loadSounds(parent)
	local Sounds = Instance.new("Folder")
	Sounds.Name = "Sounds"

	local Grab = Instance.new("Sound")
	Grab.Name = "Grab"
	Grab.Volume = 0.25
	Grab.SoundId = "rbxassetid://260411131"
	Grab.Parent = Sounds

	local Jump = Instance.new("Sound")
	Jump.Name = "Jump"
	Jump.Volume = 1
	Jump.SoundId = "rbxassetid://7218305705"
	Jump.Parent = Sounds

	local Move = Instance.new("Sound")
	Move.Name = "Move"
	Move.RollOffMode = Enum.RollOffMode.InverseTapered
	Move.Volume = 0.1
	Move.Looped = true
	Move.SoundId = "rbxassetid://6568052103"
	Move.Parent = Sounds
	
	Sounds.Parent = parent
end

local function loadPoints(parent)
	local Points = Instance.new("Folder")
	Points.Name = "Points"

	local Part = Instance.new("Part")
	Part.Name = "1"
	Part.BottomSurface = Enum.SurfaceType.Smooth
	Part.CanCollide = false
	Part.Transparency = 0.9
	Part.TopSurface = Enum.SurfaceType.Smooth
	Part.Color = Color3.fromRGB(255, 255, 0)
	Part.Material = Enum.Material.Neon
	Part.Size = Vector3.new(2, 2, 2)
	Part.Anchored = true
	Part.Shape = Enum.PartType.Ball
	Part.Parent = Points
	
	Points.Parent = parent
	return Part
end

local function getEndPos(zipline: Zipline)
	local h = Instance.new("Attachment",zipline)
	h.Position = Vector3.new(0,0,-zipline.PC.UpperLimit)
	local cf = h.WorldCFrame
	h:Destroy()
	return cf
end

local function loadRideModel(parent)
	local RideModel = Instance.new("Model")
	RideModel.Name = "RideModel"
	RideModel.WorldPivot = CFrame.new(-367, 635.0875244140625, 709)

	local RopeGuide = Instance.new("Part")
	RopeGuide.Name = "RopeGuide"
	RopeGuide.CFrame = CFrame.new(-367, 635.5, 709)
	RopeGuide.BottomSurface = Enum.SurfaceType.Smooth
	RopeGuide.CanCollide = false
	RopeGuide.TopSurface = Enum.SurfaceType.Smooth
	RopeGuide.Color = Color3.fromRGB(255, 255, 0)
	RopeGuide.Material = Enum.Material.Neon
	RopeGuide.Size = Vector3.new(0.75, 0.75, 0.75)
	RopeGuide.Anchored = true
	RopeGuide.CustomPhysicalProperties = PhysicalProperties.new(50, 0.3, 0.5)
	RopeGuide.Shape = Enum.PartType.Ball
	RopeGuide.Parent = RideModel

	local GuideAttachment = Instance.new("Attachment")
	GuideAttachment.Name = "GuideAttachment"
	GuideAttachment.CFrame = CFrame.identity
	GuideAttachment.Parent = RopeGuide

	local RopeBar = Instance.new("Part")
	RopeBar.Name = "RopeBar"
	RopeBar.CFrame = CFrame.new(-367, 634.5, 709)
	RopeBar.BottomSurface = Enum.SurfaceType.Smooth
	RopeBar.CanCollide = false
	RopeBar.TopSurface = Enum.SurfaceType.Smooth
	RopeBar.Color = Color3.fromRGB(91, 93, 105)
	RopeBar.Size = Vector3.new(4, 0.4, 0.4)
	RopeBar.Anchored = true
	RopeBar.CustomPhysicalProperties = PhysicalProperties.new(50, 0.3, 0.5)
	RopeBar.Parent = RideModel

	local BarAttachment = Instance.new("Attachment")
	BarAttachment.Name = "BarAttachment"
	BarAttachment.CFrame = CFrame.identity
	BarAttachment.Parent = RopeBar

	local RopeConstraint = Instance.new("RopeConstraint")
	RopeConstraint.Visible = true
	RopeConstraint.Color = BrickColor.new("Smoky grey")
	RopeConstraint.Length = 1
	RopeConstraint.Parent = RopeBar

	local AlignOrientation = Instance.new("AlignOrientation")
	AlignOrientation.MaxTorque = math.huge
	AlignOrientation.AlignType = Enum.AlignType.Parallel
	AlignOrientation.Responsiveness = 200
	AlignOrientation.Parent = RopeBar

	RopeConstraint.Attachment0 = BarAttachment
	RopeConstraint.Attachment1 = GuideAttachment

	AlignOrientation.Attachment0 = BarAttachment
	AlignOrientation.Attachment1 = GuideAttachment
	
	RideModel.Parent = parent
	return RideModel
end

for _, End in game.Selection:Get() --[[workspace:GetDescendants()]] do
	if not (End.Name == "End" and End:IsA("Attachment")) then continue end
	
	local zipline = End.Parent :: BasePart
	zipline.Name = "MountPart"
	
	local ziplineModel = Instance.new("Model")
	ziplineModel.Name = "Zipline"
	ziplineModel.Parent = zipline.Parent
	zipline.Parent = ziplineModel
	
	local code = zipline.ClientObjectScript.Source :: string
	local RopeLength = tonumber(code:match("Rope%.Length%s*=%s*(%d+%.?%d*)")) -- thanks littlebitchman for giving me patterns 
	
	local config = loadConfig(ziplineModel)
	config:SetAttribute("RopeLength", RopeLength)
	config:SetAttribute("Speed", configCheck(zipline,"PropelVelocity") and zipline.PropelVelocity.Value or 0)
	config:SetAttribute("AllowJumpDismount", not configCheck(zipline, "CannotDismount"))
	
	local point = loadPoints(ziplineModel)
	point.CFrame = getEndPos(zipline)
	
	local rideModel = loadRideModel(ziplineModel)
	rideModel:PivotTo(CFrame.new(zipline.Position + Vector3.new(0, 1.5 * zipline.Size.Y, 0)))
	
	loadSounds(ziplineModel)
	loadGuideEffects(ziplineModel)
	
	zipline:ClearAllChildren()
	
end

game.ChangeHistoryService:SetWaypoint("Convert Ziplines v5.5 -> v6")