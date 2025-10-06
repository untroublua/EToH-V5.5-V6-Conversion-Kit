-- Custom EToH V6 converter by @TerribleAtCreating
-- NOTICE: This has no compatibility with CUSTOM CLIENT OBJECTS or MODIFIED CLIENT OBJECTS! (CCOs / ECOs)
-- You will have to manually convert them to the new format.

-- To use this, paste it into your command bar. If anything doesn't work, no changes will be made.
-- Alternatively, paste the following into the command bar:
-- loadstring(game:FindFirstChild("KitConverter", true).Source)()

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local CollectionService = game:GetService("CollectionService")

-- Identify the folder with the tower you want to convert.
-- Check if the folder exists and has the necessary components.
local originalTower = workspace:FindFirstChild("OriginalTower")
if not originalTower then
	warn("OriginalTower folder does not exist in workspace.")
	return
elseif not originalTower:FindFirstChild("Obby") then
	warn("Tower does not have an Obby folder.")
	return
elseif not originalTower:FindFirstChild("ClientSidedObjects") then
	warn("Tower does not have a ClientSidedObjects folder.")
	return
elseif not originalTower:FindFirstChild("Frame") then
	warn("Tower does not have a recognizable OriginalTower.Frame.")
	return
elseif not originalTower:FindFirstChild("SpawnLocation") then
	warn("Tower does not have a recognizable OriginalTower.SpawnLocation.")
	return
end

local function Action(actionType: string)
	return setmetatable({Action = actionType}, {__call = function(self, other)
		for k, v in other do self[k] = v end
		return self
	end})
end

-- Note: Higher is later
local Priorities = {
	Format = -1,
	Regular = 0
}
local actionPriorities = {
	ConvertFormat = Priorities.Format
}

local targetTower = workspace.TowerKit
-- This giant table is used to determine what to do with each object.
local targetMap = {
	ClientObject = Action "Delete",

	-- Flip part
	CanFlip = Action "ConvertTag",

	-- Button and button tags
	ButtonActivated = Action "ConvertTag",
	Invert = Action "ConvertTag",
	FullHide = Action "ConvertTag",
	ButtonActivatedPlatform = Action "AddTag" {
		Value = "ButtonActivated"
	},

	-- Distance anchoring --> Distance culling
	DistanceAnchoringObjects = Action "MoveObjects" {
		TargetClass = "Model",
		TargetFolder = "*DistanceCulling"
	},
	
	-- Reformatting client objects
	Elevator = Action "ConvertFormat" {
		ConfigurationType = "ElevatorConfiguration",
		Transfer = {"Parent.Visual"},
		Properties = {
			{"TopSurface", "_copyBottomSurface"},
			{"Visual.Adornee", "_obj"}
		},
		Attributes = {"Speed", "MaxForce"}
	},
	PushboxSpawnButton = Action "ConvertFormat" {
		ConfigurationType = "PushboxSpawnConfiguration",
		Transfer = {"Parent.Visual"},
		Attributes = {
			"Cooldown",
			"DontSpawnFirst",
			{"ButtonSupportBalloons", "TouchConfiguration", "balloon"},
			{"ButtonColorSpecific", "TouchConfiguration", "colorSpecific"},
			{"ButtonSupportPlayers", "TouchConfiguration", "player"},
			{"ButtonSupportPushboxes", "TouchConfiguration", "pushbox"},
			{"ButtonSupportTurrets", "TouchConfiguration", "turret"},
		}
	},
	["PushboxSpawnButton.Pushbox"] = Action "Wrap" {
		TargetClass = "BasePart",
		Wrapper = "Model",
		WrapperName = "Pushbox"
	},
	
	["Beat Blocks.*"] = Action "ConvertFormat" {
		ConfigurationType = "BeatBlockConfiguration",
		Attributes = {
			"Indicator",
			"ChangeFrame",
			"OffTransparency",
			"OnTransparency",
			{"ToggleTime", "", "Interval"}
		}
	},
	["Beat Blocks.*x"] = Action "Rename" {
		Value = "BeatBlockGroup"
	},
	["Beat Blocks.*.ClientObjectScript.Ding"] = Action "Replace" {
		Target = "Parent.Parent.BeatBlockConfiguration.DingSound"
	},

	-- Miscellaneous renames
	["Beginner Spinning Weld Platform"] = Action "Rename" {
		Value = "Spinning Weld Platform"
	},
	["VectorForce"] = Action "RenameParent" {
		Value = "Base"
	}
}

local function evaluatePath(root: Instance, path: string)
	if not path or path == "" then return root end
	local currentTarget = root
	for _, folder in path:split(".") do
		local isWild = false
		if folder:sub(1, 1) == "*" then
			isWild = true
			folder = folder:sub(2)
		end
		
		if folder == "Parent" then
			currentTarget = currentTarget.Parent
		else
			currentTarget = currentTarget:FindFirstChild(folder, isWild)
		end
		if not currentTarget then break end
	end
	
	return currentTarget
end
local function truncatePath(path: string)
	local split = path:split(".")
	return table.remove(split, #split), table.concat(split, ".")
end

local function performCommand(object: Instance, command: {})
	local action = command.Action

	if action == "Rename" then
		object.Name = command.Value
	elseif action == "RenameParent" then
		object.Parent.Name = command.Value
		
	elseif action == "ConvertTag" then
		if object:IsA("BoolValue") then
			CollectionService:AddTag(object.Parent, object.Name)
			object.Parent = nil
		end
		
	elseif action == "AddTag" then
		CollectionService:AddTag(object, command.Value)
		
	elseif action == "SetProperties" then
		for _, property in command.Properties or {} do
			local targetProperty, objectPath = truncatePath(property[1])
			local targetObject = evaluatePath(object, objectPath)
			if typeof(property[2]) == "string" and property[2] == "_obj" then property[2] = object
			elseif typeof(property[2]) == "string" and property[2]:sub(1, 5) == "_copy" then property[2] = targetObject[property[2]:sub(6)] end
			if targetObject then
				targetObject[targetProperty] = property[2]
			end
		end
	elseif action == "SetAttributes" then
		for _, attribute in command.Attributes or {} do
			if typeof(attribute) ~= "table" then attribute = {attribute} end
			local name = attribute[1]
			local value = object:FindFirstChild(name)
			if value then
				local targetInstance = evaluatePath(command.Target, attribute[2])
				if targetInstance then targetInstance:SetAttribute(attribute[3] or name, value.Value) end
				value.Parent = nil
			end
		end
		
	elseif action == "ConvertFormat" then
		local template = targetTower:FindFirstChild(command.ConfigurationType, true)
		local config = template:Clone()
		config.Parent = object
		
		for _, transfer in command.Transfer or {} do
			if typeof(transfer) ~= "table" then transfer = {transfer} end
			local source = evaluatePath(template, transfer[1])
			if source then
				source:Clone().Parent = evaluatePath(object, transfer[2])
			end
		end
		performCommand(object, Action "SetProperties" {Properties = command.Properties})
		performCommand(object, Action "SetAttributes" {Target = config, Atrributes = command.Properties})
	elseif action == "Wrap" then
		if not object:IsA(command.TargetClass) then return end
		local wrapper = Instance.new(command.Wrapper)
		wrapper.Name = command.WrapperName
		wrapper.Parent = object.Parent
		object.Parent = wrapper
		
	elseif action == "Move" then
		local target = evaluatePath(object, command.Target)
		if target then
			object.Parent = target
			if command.Name then object.Name = command.Name end
		end
	elseif action == "Replace" then
		local original = evaluatePath(object, command.Target)
		if original then original.Parent = nil end
		local name, newTarget = truncatePath(command.Target)
		performCommand(object, Action "Move" {Target = newTarget, Name = name})
	elseif action == "MoveObjects" then
		local path = command.TargetFolder
		local currentTarget = evaluatePath(targetTower, path)
		if currentTarget then
			for _, subObject in object:GetChildren() do
				if not command.TargetClass or subObject:IsA(command.TargetClass) then
					subObject.Parent = currentTarget
				end
			end
		end
		
	elseif action == "Delete" then
		object.Parent = nil
	end
end

-- Do not remove this. It's used to record the changes to allow for an undo/redo.
local start = os.clock()
local recording = ChangeHistoryService:TryBeginRecording("KitConverter", "Eternal Towers of Hell - Custom V6 Converter")
if not recording then
	warn("Changes recording was not started. Operation aborted.")
	return
end
local success, message = pcall(function()
	-- Iterate through all of the parts in the tower and convert them to the new format.
	-- The targetMap is used to determine what to do with each part.
	local commandQueue = {}
	local priorityPointers = {}
	local maxPriority = -math.huge
	for _, object: Instance in originalTower:GetDescendants() do
		for target, command in targetMap do
			local ancestry = 0
			while target:sub(-#(".Parent")) == ".Parent" do
				ancestry += 1
				target = target:sub(1, -1 - #(".Parent"))
			end
			
			local reformatted = target:gsub("%.", "%%."):gsub("*", "[^%%.]-") .. "$"
			if object:GetFullName():match(reformatted) then
				for _ = 1, ancestry do object = object.Parent end
				local priority = actionPriorities[command.Action] or 0
				if not priorityPointers[priority] then
					priorityPointers[priority] = 0
					maxPriority = math.max(priority, maxPriority)
				end
				for i = priority, maxPriority do priorityPointers[i] += 1 end
				table.insert(commandQueue, priorityPointers[priority], {object, command})
			end
		end
	end
	
	for _, command in commandQueue do
		performCommand(unpack(command))
	end
	
	-- Move the top level components to the new tower.
	originalTower.ClientSidedObjects.Move.Parent = nil
	
	originalTower.SpawnLocation.Parent = targetTower
	targetTower.Spawn.Parent = nil
	targetTower.SpawnLocation.Name = "Spawn"
	for _, obbyObject in originalTower.Obby:GetChildren() do
		obbyObject.Parent = workspace.TowerKit.Obby
	end
	for _, clientObject in originalTower.ClientSidedObjects:GetChildren() do
		clientObject.Parent = workspace.TowerKit.ClientSidedObjects
	end
	-- Move the Frame parts to the new tower.
	for _, frameFolder in targetTower.Frame:GetChildren() do
		frameFolder.Parent = nil
	end
	for _, framePart in originalTower.Frame:GetChildren() do
		if framePart.Name:match("^Floor%d+$") then
			if not targetTower.Frame:FindFirstChild(framePart.Name) then
				local folder = Instance.new("Folder")
				folder.Name = framePart.Name
				folder.Parent = targetTower.Frame
			end
			framePart.Parent = targetTower.Frame:FindFirstChild(framePart.Name)
		else
			framePart.Parent = targetTower.Frame
		end
	end
	
	-- Cleanup the old tower.
	originalTower.Parent = nil
end)

-- Do not remove this. It's used to record the changes to allow for an undo/redo.
ChangeHistoryService:FinishRecording(recording,
	if success
		then Enum.FinishRecordingOperation.Commit
		else Enum.FinishRecordingOperation.Cancel
)
if success then
	print(`Tower was successfully converted to V6! Time elapsed: {("%.3f"):format(os.clock() - start)} seconds.`)
else
	warn(`Tower was not converted. Converter encountered an error: {message}`)
end