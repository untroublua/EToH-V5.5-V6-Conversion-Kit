--[[
Conveyors Conversion v5.5 -> v6
author: untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required
]]

local function loadConfig()
	local ConveyorConfiguration = Instance.new("Configuration")
	ConveyorConfiguration.Name = "ConveyorConfiguration"
	ConveyorConfiguration:AddTag("CO_Physics/Conveyor")
	ConveyorConfiguration:AddTag("v6.0.0")
	ConveyorConfiguration:SetAttribute("Speed", 10)
	
	return ConveyorConfiguration
end

local function loadVisual()
	local Visual = Instance.new("ConeHandleAdornment")
	Visual.Name = "Visual"
	Visual.Transparency = 0.5
	Visual.Color3 = Color3.fromRGB(255, 255, 100)
	Visual.AlwaysOnTop = true
	Visual.SizeRelativeOffset = Vector3.new(0, 0, -1)
	Visual.Height = 1

	Visual.Adornee = workspace.TowerKit.ClientSidedObjects.Conveyor
	
	return Visual
end

for _, v in workspace:GetDescendants() do
	if not (v.Name == "ClientObjectScript" and v.Parent:IsA("Beam")) then continue end
	
	local Beam = v.Parent
	local Attachment0 = Beam.Parent
	local conveyor = Attachment0:FindFirstAncestorWhichIsA("BasePart")
	local Attachment1 do 
		for _, v in conveyor:GetChildren() do
			if v == Beam.Attachment1 then
				Attachment1 = v
			end
		end
	end
	
	local config = loadConfig()
	config.Parent = conveyor
	config:SetAttribute("Speed", conveyor:FindFirstChild("Speed") and conveyor.Speed.Value or 40)
	
	local visual = loadVisual()
	visual.Parent = conveyor
	visual.Adornee = conveyor
	
	conveyor.FrontSurface = conveyor.TopSurface
	pcall(function()
		conveyor.ClientObject:Destroy()
	end)
	conveyor.Speed:Destroy()
	v:Destroy()
	conveyor.ClientObjectScript:Destroy()
end

game.ChangeHistoryService:SetWaypoint("v5.5 -> v6 Conveyors Conversion")