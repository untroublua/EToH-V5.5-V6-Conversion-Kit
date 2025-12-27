--[[
EToH Kit - v6 Migration Script
@author terriac (@TerribleAtCreating), untroublua (@signupredirectlol)
@since 5/10/2025 (MM/DD/YY)
@updated 11/30/2025 (MM/DD/YY)
]]

type Props = { [string]: any }
type ActionReturn = (Props) -> (
	(Instance) -> (Props & { Action: string | {} })
)
type Command = (
	string 
	| "MatchSource"
	| "Rename"
	| "RenameParent"
	| "ConvertTag"
	| "ConvertAttribute"
	| "ConvertFormat"
	| "AddTag"
	| "SetPrimaryPart"
	| "SetProperties"
	| "SetAttributes"
	| "GetConfiguration"
	| "CloneConfiguration"
	| "Wrap"
	| "Move"
	| "MoveLocal"
	| "MoveObjects"
	| "MoveOutside"
	| "Replace"
	| "Delete"
) -> ActionReturn

type targetMap = {
	{ string | (object: Instance) -> (boolean? | Command?) }
}

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")

-- does nothing 😭💔
local function doNothing() end

local performCommand = doNothing

local ActionMetatable = {
	__concat = function(self, other)
		for k, v in other do self[k] = v end
		return self
	end,
	__call = function(self, object)
		if typeof(object) == "Instance" then
			return performCommand(object, self)
		elseif object ~= nil then
			return self .. object
		else
			return performCommand(nil, self)
		end
	end,
	__tostring = function(self)
		return `<action: {self.Action}>`
	end,
}

local Action = function(actionType: string, Props: { [string]:any })
	return setmetatable({Action = actionType}, ActionMetatable)
end :: Command

local function SourceCheck(match: string)
	return function(object: Instance)
		return object:IsA("ModuleScript") and object.Source:match(match) ~= nil
	end
end

local function configCheck(config, configValue)
	local foundValue = config:FindFirstChild(configValue, true)
	if foundValue == nil then return nil end

	return (foundValue:IsA("ValueBase") and not (foundValue:IsA("BoolValue") and foundValue.Value == false))
end

local function COSCheck(object: Instance)
	return (object.Parent and object.Parent:FindFirstChild("ClientObjectScript")) ~= nil
end

-- Returns a function that returns the value passed into this function.
local function Literal<T>(value): () -> T
	return function() return value end	
end

-- Attempts to return a ValueBase set to the value passed into this function.
local function LiteralValue(value:any): ValueBase
	local valueObject
	if typeof(value) == "number" then
		valueObject = Instance.new("NumberValue")
	elseif typeof(value) == "boolean" then
		valueObject = Instance.new("BoolValue")
	elseif typeof(value) == "string" then
		valueObject = Instance.new("StringValue")
	elseif typeof(value) == "Instance" then
		valueObject = Instance.new("ObjectValue")
	end

	if valueObject then
		valueObject.Value = value
		return valueObject
	else
		return Instance.new("ObjectValue")
	end
end

-- Constants
local repr = require(3148021300)
local defaultText = "\"TowerDefault\""
local function indent(size: number)
	return string.rep("		", size)
end

local changerFnBase = `Change "%s" %s`
local function makeChangerFn(ty: string, tweenInfoString: string, configuration: string, isDefault)	
	local tStr = "{\n"

	tStr ..= indent(1) .. tweenInfoString .. ","

	if not isDefault then
		tStr ..= indent(1) .. configuration
	else
		tStr ..= `\n{indent(1)}UseDefault = "TowerDefault",`
	end

	tStr ..= "\n}"

	return changerFnBase:format(ty, tStr)
end

local function wrapUis(object)
	if not (object:FindFirstChildWhichIsA("Folder") and object:FindFirstChildWhichIsA("Folder"):FindFirstChildWhichIsA("GuiBase")) then
		local visualsFolder = Instance.new("Folder") 
		Action "Rename" { Value = "Visuals" } (visualsFolder)
		visualsFolder.Parent = object
		for _, v in object:GetChildren() do
			if v:IsA("SurfaceGui") or v:IsA("BillboardGui") then
				v.Parent = visualsFolder
				v.Adornee = v:FindFirstAncestorWhichIsA("BasePart")
			end
		end
	end
end

local function BoosterConversion(object: Instance, type: string)
	local instant = object:FindFirstChild("Instant")
	local boostLength = object:FindFirstChild("BoostLength")
	local distance = object:FindFirstChild("Distance")

	Action "Delete" (instant)
	Action "Delete" (distance)

	instant = (instant and instant.Value) and 0 or 1

	wrapUis(object)

	local config = Action "ConvertFormat" {
		ConfigurationType = "BoosterConfiguration",
		Attributes = {
			{LiteralValue(type), "", "Type"},
			{LiteralValue(false), "", "HideGUI"},
			{if type == "Speed" then "WalkSpeed" elseif type == "Jump" then "JumpPower" else warn("invalid type"), "", "Power"},
			{"BoostLength", "", "Duration"},
			{if distance and distance.Value == 0 then LiteralValue "Zone"
				elseif distance and distance.Value > 0 then LiteralValue "Pad"
				elseif boostLength then LiteralValue "Default"
				else LiteralValue "Default",
				"", "Mode"},
			{"Distance", "", "PadDistance"},
			{LiteralValue(distance and 0 or instant), "StartTweenConfiguration", "Time"},
			{LiteralValue(distance and 0 or instant), "EndTweenConfiguration", "Time"},

			{LiteralValue(false), "TouchConfiguration", "pushbox"},
		}
	} (object)
	if config:GetAttribute("Duration") > 10^10 then
		config:SetAttribute("Duration", 0)
	end
end

local function BoostRemoverConversion(object, type:string)
	wrapUis(object)

	Action "ConvertFormat" {
		ConfigurationType = "BoostRemoverConfiguration",
		Attributes = {
			{LiteralValue(type), "", "Type"},

			{LiteralValue(false), "TouchConfiguration", "pushbox"},
		}
	} (object)
end

local baseLines = [[--!strict
local Change = require(game:GetService("ReplicatedStorage").Framework.Kit.Repository.Visual.LightingChanger.TypeDefs)
-- DON'T TOUCH THE LINE ABOVE -- -- DON'T TOUCH THE LINE ABOVE --

return %s]]

local bulletVelChangerBaseLines = [[
--!strict
local _C = require(game:GetService("ReplicatedStorage").Framework.Kit.Repository.Interactables.PropertyChanger.TypeDefs)
local script, workspace, Workspace, game, Game, shared, _G, wait, task, spawn, delay, Spawn, Delay, Wait, require, Instance
local Toucher, Tagged, TagFromSequenceVariable, Changer, Character = _C.Toucher, _C.Tagged, _C.TagFromSequenceVariable, _C.Changer, _C.Character
-- DON'T TOUCH THE LINES ABOVE -- -- PLEASE IGNORE THE LINES ABOVE -- -- DON'T TOUCH THE LINES ABOVE -- -- PLEASE IGNORE THE LINES ABOVE --

local Properties: _C.Format = {
	{
		Instance = Toucher():FindChildOfClass("LinearVelocity"),

		-- Delete the following line to disable tweens
		Tween = %s,

		VectorVelocity = function(_E)
			return _E.Changer():Property("CFrame").LookVector
				* _E.Changer():FindChild("PropertyChangerConfiguration"):Property("Speed")
		end,
	},
}

return Properties

]]

local VALID_KILLBRICKS = { "kills", "double", "ouch", "instakills" }

-- Note: Higher is later
local Priorities = {
	SetupStructure = -2, -- Restructuring of certain objects.
	Initialize = -1, -- Setups objects for certain modification actions.
	Regular = 0, -- Every other action, applies to most objects.
	Finalize = 1, -- Slight tweaks made to objects after they are formatted.
	Omittable = 1, -- Miscellaneous actions that aren't prioritized.
	Deprecate = 2, -- Delete residue objects from the previous version.
}

-- Note that custom functions basically act as priority 0, by doing all priorities earlier than and including 0 in the same function.
local actionPriorities = {
	Wrap = Priorities.SetupStructure,

	ConvertFormat = Priorities.Initialize,

	Replace = Priorities.Finalize,

	Rename = Priorities.Omittable,
	RenameParent = Priorities.Omittable,

	Delete = Priorities.Deprecate,
}

local objectConfig = game:FindFirstChild("KitConverterConfiguration",true) :: Configuration?
local configuration = objectConfig and objectConfig:GetAttributes() or {}
local cache = {}
cache.queueWarn = {}

----------		Conversions			----------

-- This giant table is used to determine what to do with each object.
local targetMap: targetMap = {
	-- Flip part
	{"CanFlip.Parent", function(object)
		object:SetAttribute("FlipCooldown", 0)
	end},
	{"CanFlip", Action "ConvertTag"},

	-- Value tags
	{"Invisible", Action "ConvertTag"},
	{"ButtonActivated", Action "ConvertTag"},
	{"Invert", Action "ConvertTag"},
	{"FullHide", Action "ConvertTag"},
	{"IgnoreTransparency", Action "ConvertTag"},
	{"IgnoreCanCollide", Action "ConvertTag"},
	{"IgnoreAll", Action "ConvertTag"},
	{"IsBox", Action "ConvertTag"},
	{"ButtonActivatedPlatform",
		Action "AddTag" { Value = "ButtonActivated" }
	},
	{"SetTransparency", Action "ConvertAttribute"},
	{"ColorOverride", Action "ConvertAttribute"},
	{"SetCollisionGroup", function(object)
		if not (object.Parent and object.Parent:IsA("BasePart")) then return end
		object.Parent.CollisionGroup = object.Value
		Action "Delete" (object)
	end},

	{"ReturnKey", function (object)
		if not cache.ReturnKeyWarned then
			cache.ReturnKeyWarned = true
			-- Unfortunately, you can't leave in the indents while writing multi-line warnings...
			table.insert(cache.queueWarn,[[ReturnKey values, while supported in Kit V6, will not be converted due to an ambiguity issue.
To convert them, select all of the ReturnKey values.Locate and press the "Select Parent(s)" button, and add a "ReturnKey" tag to the now selected parts.
You will then have to move the ReturnKey parts into their targeted key groups.]])
		end
		table.insert(cache.queueWarn, `ReturnKey value found at path: {object:GetFullName()}`)
	end},

	-- Keys and key doors

	{"KeyHitbox", function(object)
		Action "AddTag" { Value = "Invisible" } (object)
		Action "Rename" { Value = "Hitbox" } (object)
	end},

	{"KeyID", function(object)
		local id = object.Value
		if not cache.KeyGroups then cache.KeyGroups = {} end
		local keyGroup = cache.KeyGroups[id]
		if not keyGroup then
			keyGroup = Instance.new("Folder")
			Action "Rename" { Value = (configuration.KeyGroupFormat or "%s"):format(id) } (keyGroup)
			Action "CloneConfiguration" {Value = "KeyGroupConfiguration"} (keyGroup)

			keyGroup.Parent = object.Parent.Parent
			cache.KeyGroups[id] = keyGroup
		end

		local model = object.Parent
		model.Parent = keyGroup

		if object:FindFirstChild("Door") then
			Action "Rename" { Value = "Door" } (model)
			Action "CloneConfiguration" {Value = "DoorConfiguration"} (model)
			local doorParts = Instance.new("Folder")
			Action "Rename" { Value = "DoorParts" } (doorParts)
			doorParts.Parent = model

			for _, part in model:GetChildren() do
				if part:IsA("BasePart") and part.Name ~= "Hitbox" and part.Name ~= "KeyHitbox" then part.Parent = doorParts end
			end
			Action "Delete" (object.Door)
		else
			Action "CloneConfiguration" {Value = "KeyConfiguration"} (model)
			Action "CloneConfiguration" {Value = "KeyTimer"} (model)
		end

		Action "Delete" (object)
	end},

	-- Morphers
	{
		function(object)
			return object:IsA("ModuleScript") and object.Name == "ClientObjectScript" and object:FindFirstChild("DurationGui")
		end,
		function(object)
			local model = object.Parent	
			local DurationGui = object.DurationGui
			local Press = object.Press :: Sound
			local Tick = object.Tick :: Sound
			local morph = model.Morph

			Action "Delete" (object)

			Action "CloneConfiguration" {Value = "MorpherConfiguration"} (model)

			Action "Replace" { Value = "Parent.Parent.MorpherConfiguration.DurationGui" } (DurationGui)

			for _, c in model:GetChildren() do
				if not c:FindFirstChild("NewMorph") then continue end

				local btnConf = Action "ConvertFormat" {
					ConfigurationType = "MorpherButtonConfiguration",
					Attributes = {
						{"MorphDuration", "", "Timer"},
						{"MorphSpeed", "MoveTweenConfiguration", "Time"},
						{"ReturnSpeed", "ReturnTweenConfiguration", "Time"},
						{"SupportBalloons", "TouchConfiguration", "balloon"},
						{"SupportPlayers", "TouchConfiguration", "player"},
						{"SupportPushboxes", "TouchConfiguration", "pushbox"},
						{"SupportTurrets", "TouchConfiguration", "turret"}
					}
				} (c)

				btnConf:SetAttribute("CarryObjects",false)
				Press:Clone().Parent = btnConf
				Tick:Clone().Parent = btnConf

				c.Parent = model
			end
			Action "Delete" (Press)
			Action "Delete" (Tick)
		end,
	},

	-- Kill bricks
	{function(object) return object:IsA("BoolValue") and table.find(VALID_KILLBRICKS, object.Name) end, function(object)
		Action "ConvertFormat" {
			ConfigurationType = "DamageBrickConfiguration",
			Attributes = {
				{LiteralValue(object.Name), "", "Type"},
				{LiteralValue(), "", "Damage"}
			}
		} (object.Parent)
		Action "Delete" (object)
	end},
	{function(object) return object:IsA("Folder") and object.Name:gsub(" ","") == "KillBricks" end, function(object)
		Action "MoveObjects" {
			Class = "BasePart",
			TargetFolder = "*KillBricks"
		} (object)
		Action "Delete" (object)
	end},

	-- Distance anchoring --> Distance culling
	{"DefaultDistance.Parent.Parent",
		function(object)
			Action "MoveObjects" {
				Class = "Model",
				TargetFolder = "*DistanceCulling"
			} (object)
			Action "Delete" (object)
		end,
	},

	-- Boosters
	{"WalkSpeed.Parent", function(object)
		BoosterConversion(object, "Speed")
	end},
	{"JumpPower.Parent", function(object)
		BoosterConversion(object, "Jump")
	end},

	-- Boost Removers
	{SourceCheck "h.SpeedBoost:Destroy()", function(object)
		object = object.Parent

		BoostRemoverConversion(object, "Speed")
	end},
	{SourceCheck "h.JumpBoost:Destroy()", function(object)
		object = object.Parent

		BoostRemoverConversion(object, "Jump")
	end},

	{SourceCheck "particleAtt", function(object)
		Action "ConvertFormat" {
			ConfigurationType = "BouncePadConfiguration",
			Attributes = {
				{"Power", "", "Power"},
				{"SupportPlayers", "TouchConfiguration", "player"},
				{"SupportPushboxes", "TouchConfiguration", "pushbox"}
			}
		} (object.Parent)
	end},
	{"*.ClientObjectScript.Boing",
		Action "Rename" { Value = "BounceSound" }
	},
	{"JumpPad", Action "Rename" {Value = "BouncePad"}},

	-- Transportation client objects
	{SourceCheck "table%.insert%(destinations, tp%)", function(object)
		local model = object.Parent
		local instant = model:FindFirstChild("TransitionTime")
		Action "Delete" (instant)
		instant = instant and (instant.Value == 0)
		local dir = (Action "MatchSource" {Value = "Enum%.EasingDirection%.(%a+)"} (object)) or "Out"
		local style = (Action "MatchSource" {Value = "Enum%.EasingStyle%.(%a+)"} (object)) or "Linear"
		Action "ConvertFormat" {
			ConfigurationType = "TeleporterConfiguration",
			Attributes = {
				{LiteralValue(instant), "", "Instant"},
				{"KeepVelocity", "", "KeepVelocity"},
				{"TeleportPlayers", "TouchConfiguration", "player"},
				{"TeleportPushboxes", "TouchConfiguration", "pushbox"},
				{LiteralValue(), "TweenConfiguration", "Direction", Literal(Enum.EasingDirection[dir])},
				{LiteralValue(), "TweenConfiguration", "Style", Literal(Enum.EasingStyle[style])},
				{"TransitionTime", "TweenConfiguration", "Time"}
			},
		} (model)

		for _, v in model:GetChildren() do
			if v.Name ~= "Destination" then continue end

			v.TeleportSound.Name = "Teleport"
			local lookDir = Action "CloneConfiguration" { Value = "LookDirection" } (v)
			lookDir.Adornee = lookDir.Parent
			local upDir = Action "CloneConfiguration" { Value = "UpDirection" } (v)
			upDir.Adornee = upDir.Parent
		end
	end},
	{"RemoveButtons", Action "Delete"},

	-- Reformatting client objects
	{"Pressed", Action "Delete"},
	{"ButtonPart.Parent", function(object)
		local useTimerText = (configCheck(object,"TimerText") == true and string.len(object:FindFirstChild("TimerText",true).Value) > 0)
		local config = Action "ConvertFormat" {
			ConfigurationType = "CO_Interactables/Button",
			Attributes = {
				"HideGUI",
				"Timer",

				{"ButtonPressOffset", "", "PressOffset", function(y) return CFrame.new(0, -y, 0) end},
				{object:FindFirstChild("DecimalPlaces",true) or 1, "", "TimerDecimalPlaces"},
				{useTimerText and LiteralValue(object.Configurations.TimerText.Value:gsub("`","{T}")) or LiteralValue "{T}", "",
					"TimerText"},

				{"ColorSpecific", "TouchConfiguration", "colorSpecific"},
				{"SupportBalloons", "TouchConfiguration", "balloon"},
				{"SupportPlayers", "TouchConfiguration", "player"},
				{"SupportPushboxes", "TouchConfiguration", "pushbox"},
				{"SupportTurrets", "TouchConfiguration", "turret"},
			}
		} (object:FindFirstChild("Configurations") or object)
		config.Parent = object
		Action "Delete" (object:FindFirstChild("DefaultColor", true))
		Action "Delete" (object:FindFirstChild("Configurations"))

		local text = object:FindFirstChild("TimerLabel",true)
		if text then text.Parent = config end
	end},
	{"ButtonDeactivator", function(object)
		Action "ConvertFormat" {
			ConfigurationType = "CO_Interactables/ButtonDeactivator",
			Attributes = {
				"ColorSpecific",
				{"SupportPlayers", "TouchConfiguration", "player"},
				{"SupportPushboxes", "TouchConfiguration", "pushbox"},
			}
		} (object)
	end},
	{SourceCheck "changeFunction", function(object)
		Action "MoveObjects" {
			Class = "Model",
			TargetFolder = "*Buttons"
		} (object)
		Action "MoveObjects" {
			Class = "BasePart",
			TargetFolder = "*Buttons"
		} (object)

		Action "Delete" (object)
	end},
	{function(object) return object.Name == "ButtonPlatforms" and object:IsA("Folder") end, function(object)
		Action "MoveObjects" {
			Class = "BasePart",
			TargetFolder = "*ButtonPlatforms"
		} (object)
		Action "Delete" (object)
	end},

	{"Bullet", function(object)
		local model = object.Parent
		local turret = model.Turret
		local coScript = turret.ClientObjectScript

		Action "Wrap" {
			Class = "BasePart",
			Wrapper = "Model",
			WrapperName = "Bullet"
		} (object)
		Action "SetPrimaryPart" (object)
		Action "AddTag" { Value = "SkipObjectLoad" } (object.Parent)

		local lifetime = tonumber(Action "MatchSource" { Value = "game%.Debris:AddItem%(bullet,(%d+)%)" } (coScript))
		local config = Action "ConvertFormat" {
			ConfigurationType = "TurretConfiguration",
			Attributes = {
				"Damage",
				"Speed",
				{LiteralValue(lifetime), "", "MaxLifetime"},
				{"Delay", "", "FireRate"},
				{"Distance", "", "Range"},
				{LiteralValue(not (configCheck(model,"IgnorePlayers") or configCheck(model,"IgnoreParts"))), "", "DestroyOnTouch"},
			},
			Properties = {
				{"Turret.FrontSurface", "_copyBackSurface"}
			}
		} (model) :: Configuration
		config:SetAttribute("FireRate", 1 / config:GetAttribute("FireRate"))

		Action "Delete" (coScript)
		Action "Delete" (turret:FindFirstChild("IgnoreBullets"))
		Action "Delete" (model:FindFirstChild("IgnoreParts"))
		Action "Delete" (model:FindFirstChild("IgnorePlayers"))
	end},

	{SourceCheck "script.Parent.TextureSpeed", Action "Delete"},
	{SourceCheck "script%.Parent%.CFrame%.LookVector %* script%.Parent%.Speed%.Value", function(object)
		Action "ConvertFormat" {
			ConfigurationType = "ConveyorConfiguration",
			Transfer = {"Parent.Visual"},
			Properties = {
				{"FrontSurface", "_copyBackSurface"},
				{"Visual.Adornee", "_obj"}
			},
			Attributes = {"Speed"}
		} (object.Parent)
	end},
	{"MaxForce.Parent",
		Action "ConvertFormat" {
			ConfigurationType = "ElevatorConfiguration",
			Transfer = {"Parent.Visual"},
			Properties = {
				{"TopSurface", "_copyBottomSurface"},
				{"Visual.Adornee", "_obj"}
			},
			Attributes = {"Speed", "MaxForce"}
		}
	},

	{"PushboxSpawnButton", Action "ConvertFormat" {
		ConfigurationType = "PushboxSpawnConfiguration",
		Attributes = {
			"Cooldown",
			"DontSpawnFirst",
			{"ButtonSupportBalloons", "TouchConfiguration", "balloon"},
			{"ButtonColorSpecific", "TouchConfiguration", "colorSpecific"},
			{"ButtonSupportPlayers", "TouchConfiguration", "player"},
			{"ButtonSupportPushboxes", "TouchConfiguration", "pushbox"},
			{"ButtonSupportTurrets", "TouchConfiguration", "turret"}
		}
	}},
	{"PushboxSpawnButton.Pushbox",
		function(object)
			local pushboxModel = if object:IsA("Model") then object else Action "Wrap" {
				Class = "BasePart",
				Wrapper = "Model",
				WrapperName = "Pushbox"
			} (object)
			Action "AddTag" { Value = "SkipObjectLoad" } (pushboxModel)
			object.Anchored = false
		end,
	},

	{SourceCheck "if t.Color == script.Parent.Color then t:Destroy() end", function(object)
		Action "ConvertFormat" {
			ConfigurationType = "PushboxDestroyerConfiguration",
			Attributes = {
				"ColorSpecific"
			}
		} (object.Parent)
	end},

	{"FadeTime.Parent", function(object)
		local config = Action "ConvertFormat" {
			ConfigurationType = "VanisherConfiguration",
			Attributes = {
				"RespawnTime",

				{"FadeTime", "TweenConfiguration", "Time"},
				{"SupportBalloons", "TouchConfiguration", "balloon"},
				{"SupportPlayers", "TouchConfiguration", "player"},
				{"SupportPushboxes", "TouchConfiguration", "pushbox"},
				{"SupportTurrets", "TouchConfiguration", "turret"},
			}
		} (object)
		
		Action "Rename" { Value = "VanisherSelectionBox" } (object:FindFirstChildOfClass("SelectionBox"))

		if configuration.GroupVanishers then
			Action "Rename" { Value = "Vanisher" } (object)

			config.Parent = Action "Wrap" {
				Class = "BasePart",
				Wrapper = "Model",
				WrapperName = "VanisherGroup"
			} (object)
		end
	end},
	{"SitCooldown.Parent",
		Action "ConvertFormat" {
			ConfigurationType = "SeatConfiguration",
			Transfer = {"Parent.Visual"},
			Properties = {
				{"Visual.Adornee", "_obj"}
			},
			Attributes = {
				{"SitCooldown", "", "Cooldown"},
			}
		}
	},
	{SourceCheck "humanoid.Sit = true", function(object)
		Action "ConvertFormat" {
			ConfigurationType = "TripPartConfiguration",
			Transfer = {"Parent.Visual"},
			Properties = {
				{"Visual.Adornee", "_obj"}
			},
			Attributes = {
				{LiteralValue(0), "", "Cooldown"},
			}
		} (object.Parent)
	end},

	{"ToggleTime.Parent",
		function(object)
			local Ding = object.ClientObjectScript.Ding:Clone()
			Ding.Name = "DingSound"

			local config = Action "ConvertFormat" {
				ConfigurationType = "BeatBlockConfiguration",
				Attributes = {
					{LiteralValue(.95), "", "IndicatorScaleMultiplier"},
					"Indicator",
					{LiteralValue(tonumber(object.OffTransparency.Value)), "", "OffTransparency"},
					{LiteralValue(tonumber(object.OnTransparency.Value)), "", "OnTransparency"},
					{LiteralValue(tonumber(object.ToggleTime.Value)), "", "Interval"},
					{LiteralValue(tonumber(object.ChangeFrame.Value)), "", "IndicatorInterval"},
				}
			} (object)

			Action "Delete" (object.ToggleTime)
			Action "Delete" (object.ChangeFrame)
			Action "Delete" (object.OffTransparency)
			Action "Delete" (object.OnTransparency)
			Action "Delete" (config.DingSound)
			Ding.Parent = config
		end,
	},
	{"Beat Blocks.*x",
		Action "Rename" {
			Value = "BeatBlockGroup"
		}
	},

	-- Advanced Interactables

	--> Lighting Changers
	{"LightingConfiguration.Parent",
		function(object)
			local scrcontainer = object:FindFirstChild("LightingConfiguration")
			local src = scrcontainer.Source

			local matchTweeninfo = Action "MatchSource" {Value = "(TweenInfo = TweenInfo%.new%(.-%))"} (scrcontainer)
				or "TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)"
			local matchConfiguration = Action "MatchSource" {Value = "(%s*Configuration%s*=%s*{%s*%a+%s*=%s*.-,?%s*})"} (scrcontainer)
			local matchDefaultConfig = Action "MatchSource" {Value = "(%s*Configuration%s*=%s*\"Default\")"} (scrcontainer)

			local oldConfigTable = require(scrcontainer) :: { Type:string, Configuration: { [string]:any } | string, TweenInfo:TweenInfo }

			local newsrc = baseLines:format(
				makeChangerFn(
					oldConfigTable.Type,
					matchTweeninfo,
					matchConfiguration,
					matchDefaultConfig ~= nil
				)
			)

			Action "Delete" (scrcontainer)

			Action "ConvertFormat" {
				ConfigurationType = "LightingChangerConfiguration",
				Attributes = {
					{"ColorSpecific", "TouchConfiguration", "colorSpecific"},
					{"SupportPlayers", "TouchConfiguration", "player"},
					{"SupportPushboxes", "TouchConfiguration", "pushbox"},
				}
			} (object)

			object.LightingChangerConfiguration.Lighting.Source = newsrc
		end,
	},
	{SourceCheck "changeLighting:Fire%(config%)", function(object)
		Action "MoveObjects" {
			Class = "BasePart",
			TargetFolder = "*LightingChangers"
		} (object.Parent)
		Action "Delete" (object.Parent)
	end},

	--> Bullet Velocity Changers (it actually wasnt that bad after all)
	{SourceCheck "script%.Parent%.ChangeTime%.Value", function(object)
		local velChanger = object.Parent

		local dir = (Action "MatchSource" {Value = "Enum%.EasingDirection%.(%a+)"} (object)) or "Out"
		local style = (Action "MatchSource" {Value = "Enum%.EasingStyle%.(%a+)"} (object)) or "Linear"
		local time = velChanger:FindFirstChild("ChangeTime") and velChanger.ChangeTime.Value or 0
		local tweenInfoStr = `TweenInfo.new({time}, Enum.EasingStyle.{style}, Enum.EasingDirection.{dir})`

		local config = Action "ConvertFormat" {
			ConfigurationType = "PropertyChangerConfiguration",
			Properties = {
				{"FrontSurface", "_copyBackSurface"},
			},
			Attributes = {
				"Speed",
				{"ColorSpecific", "TouchConfiguration", "colorSpecific"}
			}
		} (velChanger)

		local LookDirection = Instance.new("ConeHandleAdornment")
		LookDirection.Name = "LookDirection"
		LookDirection.Transparency = 0.25
		LookDirection.Color3 = Color3.fromRGB(255, 255, 255)
		LookDirection.AdornCullingMode = Enum.AdornCullingMode.Never
		LookDirection.CFrame = CFrame.new(0, 0, -0.25)
		LookDirection.SizeRelativeOffset = Vector3.new(0, 0, -1)
		LookDirection.Height = 1
		LookDirection.Adornee = velChanger
		LookDirection.Parent = velChanger

		--print(config,config.Parent)
		local propScript = config:FindFirstChildWhichIsA("ModuleScript")
		propScript.Source = bulletVelChangerBaseLines:format(tweenInfoStr)

		Action "Delete" (velChanger:FindFirstChild("ChangeTime"))
		Action "Delete" (object)
	end},

	--> Dialog
	{"__DIALOG__.Parent.Parent", function(object)
		Action "MoveObjects" {
			Class = "BasePart",
			TargetFolder = "*Dialog System.Parts"
		} (object)
		Action "Delete" (object)
	end},

	--> Music Zone Editors
	{SourceCheck "snd%.PlaybackSpeed", Action "Delete"}, -- del coscript
	{"ZoneName.Parent.Parent",
		function(object)
			local ZoneConfigurations = object.Configurations :: Folder

			local MZEConfig = Action "ConvertFormat" {
				ConfigurationType = "MusicZoneEditorConfiguration",
				Attributes = {
					"ZoneName",
					"OneTimeUse",
					"Cooldown",

					{"ColorSpecific", "TouchConfiguration", "colorSpecific"},
					{"SupportPlayers", "TouchConfiguration", "player"},
					{"SupportPushboxes", "TouchConfiguration", "pushbox"},
				}
			} (ZoneConfigurations)
			MZEConfig.Parent = object
			Action "Delete" (ZoneConfigurations)

			local zoneConfig = repr({
				ZoneDisabled = false,
				ZonePriority = configCheck(ZoneConfigurations, "Priority") and ZoneConfigurations.Priority.Value,
				SoundConfiguration = {
					PlaybackSpeed = configCheck(ZoneConfigurations, "Speed") and ZoneConfigurations.Speed.Value,
					Volume = configCheck(ZoneConfigurations, "Volume") and ZoneConfigurations.Volume.Value,
					TimePosition = configCheck(ZoneConfigurations, "ChangeTimePosition") and ZoneConfigurations.ChangeTimePosition.TimePosition
				}
			}, { pretty = true })

			local MZESrc = string.format("return %s", zoneConfig)
			MZEConfig.ZoneConfiguration.Source = MZESrc
		end,
	},

	-- Physics Objects
	{
		function(object) 
			return object:IsA("CylindricalConstraint")
		end, 
		function(object)
			local hinge = Instance.new("HingeConstraint")
			hinge.Parent = object.Parent
			hinge.Attachment0, hinge.Attachment1 = object.Attachment0, object.Attachment1
			hinge.ActuatorType = Enum.ActuatorType.Motor
			hinge.MotorMaxTorque = object.MotorMaxTorque
			hinge.AngularVelocity = object.AngularVelocity
			hinge.LimitsEnabled = false

			Action "SetPrimaryPart" (object.Attachment1.Parent)

			if configuration.DistanceCullAll then 
				Action "Move" { Value = "*DistanceCulling" } (object.Parent.Parent)
			end

			Action "Delete" (object)
		end
	},

	{
		function(object) 
			return object:IsA("BallSocketConstraint")
		end, 
		function(object:BallSocketConstraint|HingeConstraint)
			Action "SetPrimaryPart" (object.Attachment1.Parent)
			if not configuration.DistanceCullAll then return end
			Action "Move" { Value = "*DistanceCulling" } (object.Parent.Parent)
		end
	},
	{
		function(object) 
			return object:IsA("HingeConstraint")
		end, 
		function(object:BallSocketConstraint|HingeConstraint)
			Action "SetPrimaryPart" (object.Attachment0.Parent)
			if not configuration.DistanceCullAll then return end
			Action "Move" { Value = "*DistanceCulling" } (object.Parent.Parent)
		end
	},

	{"BodyPosition.Parent.Parent", function(object)
		local BodyPos = object:FindFirstChildWhichIsA("BodyPosition",true)
		local End = object:FindFirstChild("End") :: BasePart
		local Platform = object:FindFirstChild("Platform") :: BasePart

		Action "Delete" (End:FindFirstChild("ClientObjectScript"))
		Action "Delete" (Platform:FindFirstChild("ClientObjectScript"))

		local totalMass = 0
		for _, obj in Platform:GetConnectedParts(true) do
			if obj:IsA("BasePart") then
				totalMass += obj.Mass
			end
		end
		Action "ConvertFormat" {
			ConfigurationType = "FallingPlatformConfiguration",
			Attributes = {
				{LiteralValue(totalMass), "", "BaseMass"},
				{LiteralValue(false), "", "ActivateConnectedParts"}
			}
		} (object)

		local AlignPosition = Instance.new("AlignPosition")
		AlignPosition.MaxAxesForce = Vector3.new(0, 1000, 0)
		AlignPosition.MaxVelocity = 2000
		AlignPosition.Responsiveness = 15
		AlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
		AlignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		AlignPosition.Position = Vector3.new(21.5, 11, 125.5)
		AlignPosition.Parent = BodyPos.Parent

		if configuration.BetterFallingPlatforms then
			local FallingPlatformBeam = Action "CloneConfiguration" { Value = "FallingPlatformBeam" } (Platform)

			FallingPlatformBeam.Attachment0 = Platform.Attachment0
			FallingPlatformBeam.Attachment1 = End.Attachment1
		end

		Action "Delete" (BodyPos)
	end},

	{SourceCheck "InvisiblePositions", function(object)
		local model = object.Parent
		local Platform = model.Platform
		Platform.AlignOrientation.Mode = "OneAttachment"
		Platform.AlignOrientation.Attachment1 = nil
		Platform.AlignPosition.Mode = "OneAttachment"
		Platform.AlignPosition.Attachment1 = nil

		Action "SetPrimaryPart" (Platform)

		local InvisiblePositions = model:FindFirstChild("InvisiblePositions")
		Action "Delete" (InvisiblePositions)
		local Delay = model:FindFirstChild("Delay")
		Action "Delete" (Delay)

		Action "ConvertFormat" { ConfigurationType = "MovingPlatformConfiguration" } (model)

		local Positions = model.Positions :: Model
		for _, v in Positions:GetChildren() do
			v.Name = v.Name:sub(2)
			if InvisiblePositions and InvisiblePositions.Value then
				v:AddTag("Invisible")
			end
			Action "ConvertFormat" { 
				ConfigurationType = "PositionConfiguration",
				Attributes = {
					{LiteralValue(Delay and Delay.Value or 5), "", "MoveDelay"}
				}
			} (v)
		end
	end},

	--> Shoving Platforms
	{"OutDelay", function(object)
		local model = object.Parent
		local Distance = model.Distance :: NumberValue
		local InSpeed = model.InSpeed :: NumberValue
		local OutSpeed = model.OutSpeed :: NumberValue
		local InDelay = model.InDelay :: NumberValue
		local OutDelay = model.OutDelay :: NumberValue

		local PC = model:FindFirstChildWhichIsA("PrismaticConstraint", true)
		local Platform = PC.Attachment1.Parent
		local initPos = PC.Attachment0.Parent

		initPos.Transparency = 0.5
		initPos.Position = Platform.Position

		Platform:FindFirstChildWhichIsA("Attachment").Name = "Attachment"
		initPos:FindFirstChildWhichIsA("Attachment").Name = "Attachment"

		local newPosInst = Platform:Clone()
		newPosInst.Parent = Platform.Parent
		newPosInst.Position += PC.Attachment0.Axis * Distance.Value
		newPosInst.Size = Vector3.one
		newPosInst.Transparency = 0.5
		newPosInst.Anchored = true
		newPosInst.CanCollide = false
		newPosInst:AddTag("Invisible")


		Platform.Name = "Platform"
		initPos.Name = "1"
		newPosInst.Name = "2"

		local initPosConfig = Action "CloneConfiguration" { Value = "PositionConfiguration" } (initPos)
		local endPosConfig = Action "CloneConfiguration" { Value = "PositionConfiguration" } (newPosInst)

		local Positions = Action "Wrap" {
			Class = "BasePart",
			Wrapper = "Model",
			WrapperName = "Positions"
		} (initPos)
		newPosInst.Parent = Positions

		Action "ConvertFormat" {
			ConfigurationType = "MovingPlatformConfiguration",
			Attributes = {
				{LiteralValue(true), "", "Tween"},
				{"InDelay", "Parent.Positions.1.PositionConfiguration", "MoveDelay"},
				{"OutDelay", "Parent.Positions.2.PositionConfiguration", "MoveDelay"},

				{LiteralValue(Distance.Value / InSpeed.Value), "Parent.Positions.1.PositionConfiguration.TweenConfiguration", "Time"},
				{LiteralValue(Distance.Value / OutSpeed.Value), "Parent.Positions.2.PositionConfiguration.TweenConfiguration", "Time"},
				{LiteralValue(), "Parent.Positions.1.PositionConfiguration.TweenConfiguration", "Style", Literal(Enum.EasingStyle.Linear)},
				{LiteralValue(), "Parent.Positions.2.PositionConfiguration.TweenConfiguration", "Style", Literal(Enum.EasingStyle.Linear)},
			}
		} (model)

		-- load align constraints
		local AlignPosition = Instance.new("AlignPosition")
		AlignPosition.MaxForce = 99999997952
		AlignPosition.Responsiveness = 1000
		AlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
		AlignPosition.Parent = Platform
		local AlignOrientation = Instance.new("AlignOrientation")
		AlignPosition.Responsiveness = 1000
		AlignOrientation.MaxTorque = 99999997952
		AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		AlignOrientation.Parent = Platform

		Action "Delete" (Distance)
		Action "Delete" (InSpeed)
		Action "Delete" (OutSpeed)
		Action "Delete" (PC.Parent.ClientObjectScript)
	end},

	{"BodyVelocity.Parent.Parent", function(object)
		if not configuration.DistanceCullAll then return end
		Action "Move" { Value = "*DistanceCulling" } (object)
	end},

	{function(object)
		return object:FindFirstChildWhichIsA("VectorForce") and not object:FindFirstChildWhichIsA("NoCollisionConstraint")
	end, Action "SetPrimaryPart" },
	{
		function(object)
			return object:FindFirstChildWhichIsA("VectorForce") and object:FindFirstChildWhichIsA("NoCollisionConstraint")
		end,
		function(object)
			local model = object.Parent
			for _, v:BasePart in model:GetChildren() do
				if v:FindFirstChildWhichIsA("PrismaticConstraint") and v:FindFirstChild("ClientObjectScript") then
					Action "Rename" { Value = "Anchor" } (v)

					Action "Delete" (v:FindFirstChild("ClientObjectScript"))

					local AnchorAttachment = v.Attachment0 :: Attachment
					Action "Rename" { Value = "AnchorAttachment" } (AnchorAttachment)

					local BeamAttachment1 = AnchorAttachment:Clone()
					BeamAttachment1.Parent = v
					Action "Rename" { Value = "BeamAttachment1" } (BeamAttachment1)
				elseif v:FindFirstChildWhichIsA("WeldConstraint") then
					Action "Rename" { Value = "X" } (v)

					local BeamAttachment0 = Instance.new("Attachment")
					Action "Rename" { Value = "BeamAttachment0" } (BeamAttachment0)
					BeamAttachment0.CFrame = CFrame.identity
					BeamAttachment0.Parent = v

					local TrampolineBeam = Instance.new("Beam")
					Action "Rename" { Value = "TrampolineBeam" } (TrampolineBeam)
					TrampolineBeam.FaceCamera = true
					TrampolineBeam.LightInfluence = 1
					TrampolineBeam.Segments = 25
					TrampolineBeam.Width1 = 0.5
					TrampolineBeam.Width0 = 0.5
					TrampolineBeam.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, 0.9), NumberSequenceKeypoint.new(0.9, 0.9), NumberSequenceKeypoint.new(1, 1)})
					TrampolineBeam.LightEmission = 1
					TrampolineBeam.Color = ColorSequence.new(Color3.fromRGB(91, 93, 105))

					TrampolineBeam.Attachment0 = BeamAttachment0
					TrampolineBeam.Parent = v
				end
			end

			Action "CloneConfiguration" {Value = "PushingPlatformTrampolineConfiguration"} (model)
		end,
	},

	--> Sound Player
	{SourceCheck "part%.Name == \"SoundPlayer\"", Action "Delete"},
	{"SoundPlayer", function(object)
		for _, v in object.Configurations:GetChildren() do
			v.Parent = object
		end
		Action "Delete" (object.Configurations)

		local emitConf = Action "ConvertFormat" {
			ConfigurationType = "EmitterConfiguration",
			Attributes = {
				{"ColorSpecific", "TouchConfiguration", "colorSpecific"},
				{"SupportPlayers", "TouchConfiguration", "player"},
				{"SupportPushboxes", "TouchConfiguration", "pushbox"},
				{"SupportTurrets", "TouchConfiguration", "turret"},
				{"SupportBalloons", "TouchConfiguration", "balloon"},
				{"GlobalEmission", "", "GlobalSound"},
				{LiteralValue(configCheck(object, "OneTimeUse") and 1 or 0), "", "Uses"},
				"Cooldown",
			}
		} (object)

		Action "Delete" (object:FindFirstChild("OneTimeUse"))

		local sound = object:FindFirstChildWhichIsA("Sound")
		local soundConfig = Instance.new("Configuration")
		Action "Rename" { Value = "EmitConfiguration" } (soundConfig)
		soundConfig:SetAttribute("EmitDelay", 0)
		soundConfig.Parent = sound
	end},

	-- Mountables

	--> Balloons
	{SourceCheck "bdelay", function(object)
		local dispenser = object.Parent
		Action "Rename" { Value = "Dispenser" } (dispenser)
		local model = Action "Wrap" {
			Class = "BasePart",
			Wrapper = "Model",
			WrapperName = "BalloonDispenser"
		} (dispenser)

		local conf = Action "ConvertFormat" {
			ConfigurationType = "BalloonConfiguration",
			Attributes = {
				"MaxHeight",
				{"Force", "", "Speed"},
				{"WaitTime", "", "Timer"},
				{LiteralValue(not configCheck(dispenser,"CannotDismount")), "", "AllowJumpDismount"},
			}
		} (dispenser)

		conf.Parent = model

		local Sounds = Instance.new("Folder")
		Sounds.Parent = model
		Action "Rename" { Value = "Sounds" } (Sounds)
		for _, v in object:GetChildren() do if v:IsA("Sound") then v.Parent = Sounds end end
		Action "CloneConfiguration" { Value = "TimerTick" } (Sounds)

		Action "Delete" (dispenser:FindFirstChild("CannotDismount"))

		-- create balloon
		local BalloonModel = Action "CloneConfiguration" { Value = "BalloonModel" } (dispenser.Parent) :: Model
		local AlignOrientation = BalloonModel:FindFirstChildWhichIsA("AlignOrientation",true)
		AlignOrientation.Attachment0 = AlignOrientation.Parent.BalloonAttachment

		-- create ropebar
		local RopeBar = Action "CloneConfiguration" { Value = "RopeBar" } (model)
		for _, v in RopeBar:GetChildren() do Action "Delete" (v) end
		local BarAttachment = Instance.new("Attachment")
		Action "Rename" { Value = "BarAttachment" } (BarAttachment)
		BarAttachment.Parent = RopeBar
		local RopeConstraint = Instance.new("RopeConstraint")
		RopeConstraint.Visible = true
		RopeConstraint.Color = BrickColor.new("Smoky grey") 
		RopeConstraint.Length = 1
		RopeConstraint.Parent = RopeBar
		local AlignOrientation = Instance.new("AlignOrientation")
		AlignOrientation.MaxTorque = 99999997952
		AlignOrientation.AlignType = Enum.AlignType.PrimaryAxisParallel
		AlignOrientation.Responsiveness = 20
		AlignOrientation.Parent = RopeBar
		local ZeroLengthConstraint = Instance.new("WeldConstraint")
		Action "Rename" { Value = "ZeroLengthConstraint" } (ZeroLengthConstraint)
		ZeroLengthConstraint.Enabled = false
		ZeroLengthConstraint.Parent = RopeBar
		RopeConstraint.Attachment0 = BarAttachment
		AlignOrientation.Attachment0 = BarAttachment
		ZeroLengthConstraint.Part0 = RopeBar

		BalloonModel:PivotTo(dispenser:GetPivot() + Vector3.new(0,3,0))
		RopeBar.Position = BalloonModel:GetPivot().Position + Vector3.new(0,2,0)
	end},

	{function(object) return object.Name == "Start" and object:IsA("Attachment") and COSCheck(object) end, function(object)
		local zipline = object.Parent
		local coScript = zipline.ClientObjectScript :: ModuleScript

		zipline.Name = "MountPart"

		Action "Wrap" {
			Class = "BasePart",
			Wrapper = "Model",
			WrapperName = "Zipline"
		} (zipline)
		local ziplineModel = zipline.Parent

		local config = Action "ConvertFormat" {
			ConfigurationType = "ZiplineConfiguration",
			Attributes = {
				{"PropelVelocity", "", "Speed"},
				{LiteralValue(not configCheck(zipline, "CannotDismount")), "", "AllowJumpDismount"},
				{LiteralValue(Action "MatchSource" { Value = "Rope%.Length%s*=%s*(%d+%.?%d*)" } (coScript) ), "", "RopeLength"} -- credit: littleBitsman for pattern
			}
		} (zipline)
		config.Parent = ziplineModel

		local endPos do
			local h = Instance.new("Attachment",zipline)
			h.Position = Vector3.new(0,0,-zipline.PC.UpperLimit)
			endPos = h.WorldCFrame
			Action "Delete" (h)
		end

		-- load sounds
		local Sounds = Instance.new("Folder")
		Sounds.Name = "Sounds"
		Sounds.Parent = ziplineModel
		Action "CloneConfiguration" { Value = "Grab" } (Sounds)
		Action "CloneConfiguration" { Value = "Jump" } (Sounds)
		Action "CloneConfiguration" { Value = "Move" } (Sounds)

		-- load guide effects
		Action "CloneConfiguration" { Value = "GuideEffects" } (ziplineModel) 

		-- load points
		local Points = Action "CloneConfiguration" { Value = "Points" } (ziplineModel)
		Points["1"].CFrame = endPos

		local rideModel = Action "CloneConfiguration" { Value = "RideModel" } (ziplineModel)
		rideModel:PivotTo(CFrame.new(zipline.Position + Vector3.new(0, 1.5 * zipline.Size.Y, 0)))

		for _, v in zipline:GetChildren() do Action "Delete" (v) end
	end},

	{SourceCheck "local savedLinearVelocity = root.AssemblyLinearVelocity", function(object)
		local model = object.Parent
		local swing = model.Swing
		local Top = model.Top
		local RopeLength = model:FindFirstChild("RopeLength")
		local KeepVelocity = model:FindFirstChild("KeepVelocity")

		Action "ConvertFormat" {
			ConfigurationType = "VineConfiguration",
			Attributes = {
				"AllowJumpDismount",
				"RespawnTime",
			}
		} (model)

		if not KeepVelocity.Value then
			--table.insert(queueWarn,"Add PropChanger to " .. swing.Name)
			local config = Action "ConvertFormat" {
				ConfigurationType = "PropertyChangerConfiguration",
				Attributes = {
					{LiteralValue(0), "", "Cooldown"},

					{LiteralValue(false), "TouchConfiguration", "pushbox"},
					{LiteralValue(false), "TouchConfiguration", "turret"},
					{LiteralValue(true), "TouchConfiguration", "player"},
				}
			} (swing)
			config.Properties.Source = [[--!strict
local _C = require(game:GetService("ReplicatedStorage").Framework.Kit.Repository.Interactables.PropertyChanger.TypeDefs)
local script, workspace, Workspace, game, Game, shared, _G, wait, task, spawn, delay, Spawn, Delay, Wait, require, Instance
local Toucher, Tagged, TagFromSequenceVariable, Changer, Character = _C.Toucher, _C.Tagged, _C.TagFromSequenceVariable, _C.Changer, _C.Character
-- DON'T TOUCH THE LINES ABOVE -- -- PLEASE IGNORE THE LINES ABOVE -- -- DON'T TOUCH THE LINES ABOVE -- -- PLEASE IGNORE THE LINES ABOVE --

local Properties: _C.Format = {
	{	
		Instance = Character():FindChild("HumanoidRootPart"),
		AssemblyLinearVelocity = function(_E)
			return _E.Changer():Property("Transparency") == 1 and _E.Instance():Property("AssemblyLinearVelocity") or Vector3.zero
		end
	},
}

return Properties
]]
		end

		Action "Delete" (KeepVelocity)
		Action "Delete" (RopeLength)

		Top.Name = "AttachmentPart"
		Action "CloneConfiguration" { Value = "VineAttachment" } (Top)

		swing:FindFirstChildWhichIsA("ParticleEmitter").Name = "RespawnParticle"
		swing.Name = "VinePart"

		local soundsFolder = Instance.new("Folder")
		soundsFolder.Name = "Sounds"

		object.Grab:Clone().Parent = soundsFolder
		object.Jump:Clone().Parent = soundsFolder

		soundsFolder.Parent = model
		-- load ropebar
		local RopeBar = Action "CloneConfiguration" { Value = "RopeBar" } (model)
		for _, v in RopeBar:GetChildren() do Action "Delete" (v) end
		local BarAttachment = Instance.new("Attachment")
		BarAttachment.Name = "BarAttachment"
		BarAttachment.CFrame = CFrame.new(0, 0, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1)
		BarAttachment.Parent = RopeBar
		local AlignOrientation = Instance.new("AlignOrientation")
		AlignOrientation.MaxTorque = 99999997952
		AlignOrientation.AlignType = Enum.AlignType.PrimaryAxisParallel
		AlignOrientation.Responsiveness = 20
		AlignOrientation.Parent = RopeBar
		AlignOrientation.Attachment0 = BarAttachment

		-- load constraint
		local constraintType = Action "MatchSource" { Value = "local Rope = Instance%.new%(\"(%a+)\"%)" } (object) :: string
		local Rope = Instance.new(constraintType or "RopeConstraint") :: RopeConstraint | RodConstraint
		Rope.Name = "VineConstraint"
		Rope.Length = RopeLength and RopeLength.Value or 12
		Rope.Visible = true
		Rope.Color = swing.BrickColor
		Rope.Parent = model

		RopeBar.Position = Top.Position + Vector3.new(0,2,0)
	end},

	-- Dismounters

	--> Vine Dismounters
	{SourceCheck "noJumpSignal" ,
		function(object)
			Action "Delete" (object.Parent:FindFirstChild("NoJump"))
			Action "ConvertFormat" {
				ConfigurationType = "DismounterConfiguration",
				Attributes = {
					{LiteralValue(false), "", "DismountAttachers"},
					{LiteralValue(false), "", "DismountBalloons"},
					{LiteralValue(false), "", "DismountSeats"},
					{LiteralValue(false), "", "DismountSwings"},
					{LiteralValue(false), "", "DismountZiplines"},
					{LiteralValue(true), "", "DismountVines"},

					{LiteralValue(false), "TouchConfiguration", "balloon"},
					{LiteralValue(false), "TouchConfiguration", "pushbox"},
				}
			} (object.Parent)
		end
	},

	--> Balloon Destroyers
	{"BalloonDestroyer", 
		Action "ConvertFormat" {
			ConfigurationType = "DismounterConfiguration",
			Attributes = {
				{LiteralValue(false), "", "DismountAttachers"},
				{LiteralValue(true), "", "DismountBalloons"},
				{LiteralValue(false), "", "DismountSeats"},
				{LiteralValue(false), "", "DismountSwings"},
				{LiteralValue(false), "", "DismountZiplines"},
				{LiteralValue(false), "", "DismountVines"},

				{LiteralValue(false), "TouchConfiguration", "player"},
				{LiteralValue(false), "TouchConfiguration", "pushbox"},
			}
		}
	},

	-- Miscellaneous renames
	{"Beginner Spinning Weld Platform",
		Action "Rename" {
			Value = "Spinning Weld Platform"
		},
	},
	{"VectorForce",
		Action "RenameParent" {
			Value = "Base"
		}
	},

	-- Misc. Deletes

	{"ClientObject", Action "Delete"},
	{"ClientObjectScript", if configuration.CleanupCOS then Action "Delete" else doNothing},

	{
		function(object)
			return object:IsA("NoCollisionConstraint")
		end,
		Action "Delete"
	},
}

local function evaluatePath(root: Instance, path: string)
	if not path or path == "" or typeof(path) == "Instance" then return root end
	local target = root
	for _, folder in path:split(".") do
		local isWild = false
		if folder:sub(1, 1) == "*" then
			isWild = true
			folder = folder:sub(2)
		end

		if folder == "Parent" then
			target = target.Parent
		else
			target = target:FindFirstChild(folder, isWild)
		end
		if not target then break end
	end

	return target
end
local function truncatePath(path: string)
	local split = path:split(".")
	return table.remove(split, #split), table.concat(split, ".")
end

-- Identify the folder with the tower you want to convert.
-- Check if the folder exists and has the necessary components.

local originalTower: Folder, targetTower: Folder
do
	for _, v in workspace:GetDescendants() do
		if v:IsA("Folder") and v.Name == "ClientSidedObjects" then
			if not v:GetAttribute("KitVersion") then
				originalTower = v.Parent
			elseif v:GetAttribute("KitVersion") then
				targetTower = v.Parent
			end
		end

		if originalTower and targetTower then break end
	end
end

assert(originalTower, "The original tower does not exist in workspace. Make sure you haven't added any attributes to the original tower's ClientSidedObjects")
assert(originalTower:FindFirstChild("Obby"), "Tower does not have an Obby folder.")
assert(originalTower:FindFirstChild("Frame"), "Tower does not have a recognizable OriginalTower.Frame.")
assert(originalTower:FindFirstChildWhichIsA("SpawnLocation"), "Tower does not have a recognizable OriginalTower.SpawnLocation.")

----------		Command Actions			----------
function performCommand(object: Instance, command: {})
	if not object then return end
	local action = command.Action

	-- Check actions
	if action == "MatchSource" then
		local source = object.Source
		return source:match(command.Value)

		-- Modify actions
	elseif action == "Rename" then
		object.Name = command.Value
	elseif action == "RenameParent" then
		object.Parent.Name = command.Value

	elseif action == "ConvertTag" then
		if object:IsA("ValueBase") then
			if not object.Parent then return end
			object.Parent:AddTag(object.Name)
			
			Action "Delete" (object)
		end
	elseif action == "ConvertAttribute" then
		if object:IsA("ValueBase") then
			if not object.Parent then return end
			object.Parent:SetAttribute(object.Name, object.Value)
			
			Action "Delete" (object)
		end

	elseif action == "AddTag" then
		object:AddTag(command.Value)

	elseif action == "SetPrimaryPart" then
		object:FindFirstAncestorOfClass("Model").PrimaryPart = object

	-- Reconcilation actions
	elseif action == "SetProperties" then
		for _, property in command.Properties or {} do
			local targetProperty, objectPath = truncatePath(property[1])
			local targetObject = evaluatePath(object, objectPath)
			if typeof(property[2]) == "string" and property[2] == "_obj" then
				property[2] = object
			elseif typeof(property[2]) == "string" and property[2]:sub(1, 5) == "_copy" then
				property[2] = targetObject[property[2]:sub(6)]
			end
			if targetObject then
				targetObject[targetProperty] = property[2]
			end
		end
	elseif action == "SetAttributes" then
		for _, attribute in command.Attributes or {} do
			if typeof(attribute) ~= "table" then attribute = {attribute} end
			local name = attribute[1]
			local value = if typeof(name) == "Instance" then name else object:FindFirstChild(name)
			if value then
				local targetInstance = evaluatePath(command.Value, attribute[2])
				if targetInstance then
					targetInstance:SetAttribute(
						attribute[3] or name,
						if attribute[4] then attribute[4](value.Value) else value.Value
					)
				end
				Action "Delete" (value)
			end
		end

	-- Structure actions
	elseif action == "GetConfiguration" then
		if not cache.Configurations then cache.Configurations = {} end
		local configCache = cache.Configurations
		if not configCache[command.Value] then
			configCache[command.Value] = targetTower:FindFirstChild(command.Value, true) or CollectionService:GetTagged(command.Value)[1]
		end
		return configCache[command.Value]
	elseif action == "CloneConfiguration" then
		local config = Action "GetConfiguration" {Value = command.Value} ():Clone()
		if object then
			config.Parent = object
		end
		return config
	elseif action == "ConvertFormat" then
		local template = Action "GetConfiguration" {Value = command.ConfigurationType} ()
		local config = template:Clone()
		config.Parent = object

		for _, transfer in command.Transfer or {} do
			if typeof(transfer) ~= "table" then transfer = {transfer} end
			local source = evaluatePath(template, transfer[1])
			if source then
				source:Clone().Parent = evaluatePath(object, transfer[2])
			end
		end
		
		Action "SetProperties" {Properties = command.Properties} (object)
		Action "SetAttributes" {Value = config, Attributes = command.Attributes} (object)
		Action "Delete" (object:FindFirstChild("ClientObjectScript"))
		return config
	elseif action == "Wrap" then
		if not object:IsA(command.Class) then return end
		local wrapper = Instance.new(command.Wrapper)
		wrapper.Parent = object.Parent
		object.Parent = wrapper
		Action "Rename" { Value = command.WrapperName } (wrapper)
		return wrapper

	-- Hierarchy actions
	elseif action == "Move" then
		local target = evaluatePath(targetTower, command.Value)
		if target then
			object.Parent = target
			if command.Name then Action "Rename" { Value = command.Name } (object) end
		end
	elseif action == "MoveLocal" then
		local target = evaluatePath(object, command.Value)
		if target then
			object.Parent = target
			if command.Name then Action "Rename" { Value = command.Name } (object) end
		end
	elseif action == "MoveObjects" then
		local path = command.TargetFolder
		local target = evaluatePath(targetTower, path)
		if target then
			for _, subObject in object:GetChildren() do
				if 
					not command.Class
					or subObject:IsA(command.Class)
					or (not command.DeepDisabled and subObject:FindFirstChildWhichIsA(command.Class))
				then
					subObject.Parent = target
				end
			end
		end
	elseif action == "MoveOutside" then
		for _, subObject in object:GetChildren() do
			if not command.Class or subObject:IsA(command.Class) then
				subObject.Parent = object.Parent
			end
		end
	elseif action == "Replace" then
		local original = evaluatePath(object, command.Value)
		Action "Delete" (original)
		local name, newTarget = truncatePath(command.Value)
		Action "Move" {Value = newTarget, Name = name} (object)


	elseif action == "Delete" then
		if not object then return end
		object.Parent = nil

	end
end

-------------------------------------------------------------------------------------------------------------------------------------
-- MAIN	

local RECORDING_NAME = "V6KitConverter"

-- Used to record the changes to allow for an undo/redo.
local start = os.clock()
local recording
local function startRecording()
	recording = ChangeHistoryService:TryBeginRecording(RECORDING_NAME, "Eternal Towers of Hell: V5.5 -> V6 Converter")
	warn("Started recording", recording)

	if not recording then
		warn("[⚠️ UNOFFICIAL V6 UPDATE KIT ⚠️]: Tower was not converted: Changes recording was not started. Please try again.")
		error("Recording not started")
	end
	return recording
end
recording = startRecording()
print(recording)

local success, err = xpcall(function()
	-- Iterate through all of the parts in the tower and convert them to the new format.
	-- The targetMap is used to determine what to do with each part.
	local commandQueue = {}
	local priorityPointers = {}
	local maxPriority = -math.huge
	local allObjects = originalTower:GetDescendants()

	local conversionClock = os.clock()

	-- Queue exhaust prevention (limits framerate to 60FPS)
	local function bufferSleep()
		if os.clock() - conversionClock >= 1 / 60 then
			task.wait()
			conversionClock = os.clock()
		end
	end

	print("[ℹ️ UNOFFICIAL V6 UPDATE KIT ℹ️]: Initializing...")
	for _, object: Instance in allObjects do
		local originalObject = object
		for i, command in targetMap do
			object = originalObject
			local conditionMet = true
			local filter = command[1]

			if typeof(filter) == "string" then
				local ancestry = 0
				while filter:sub(-#(".Parent")) == ".Parent" do
					ancestry += 1
					filter = filter:sub(1, -1 - #(".Parent"))
				end

				local reformatted = filter:gsub("%.", "%%."):gsub("*", "[^%%.]-") .. "$"
				conditionMet = object:GetFullName():match(reformatted)

				for _ = 1, ancestry do object = object.Parent end
			elseif typeof(filter) == "function" then
				conditionMet = filter(object)
			end

			if conditionMet then
				local priority = typeof(command[2]) == "table" and actionPriorities[command[2].Action] or 0
				maxPriority = math.max(priority, maxPriority)
				for i = priority, maxPriority do
					if not priorityPointers[i] then
						priorityPointers[i] = 0
					end
					priorityPointers[i] += 1
				end
				table.insert(commandQueue, priorityPointers[priority], {object, command[2]})
			end
		end

		bufferSleep()
	end

	for i = 1, #commandQueue do
		local command = commandQueue[i]
		bufferSleep()
		if not configuration.SilentConversion then
			print(`ℹ️ Updating {command[1]:GetFullName()}`)
		end
		command[2](command[1])
	end

	-- Move the top level components to the new tower.
	--table.insert(cache.queueWarn,originalTower)
	print(originalTower:GetChildren())
	Action "Delete" (originalTower.ClientSidedObjects:FindFirstChild("Move"))

	local originalSpawn = originalTower:FindFirstChild("SpawnLocation")
	local existingSpawn = targetTower:FindFirstChildWhichIsA("SpawnLocation")
	originalSpawn.Parent = targetTower
	Action "Rename" { Value = "Spawn" } (originalSpawn)
	Action "Delete" (existingSpawn)
	local originalMusicFolder = originalTower:FindFirstChild("BackgroundMusicZones",true)
	if originalMusicFolder then
		originalMusicFolder = originalMusicFolder.Parent
		local existingMusicFolder = ServerScriptService:FindFirstChild("Music")
		originalMusicFolder.Parent = ServerScriptService
		Action "Delete" (existingMusicFolder)
	end
	for _, obbyObject in originalTower.Obby:GetChildren() do
		obbyObject.Parent = targetTower.Obby
	end
	for _, clientObject in originalTower.ClientSidedObjects:GetChildren() do
		clientObject.Parent = targetTower.ClientSidedObjects
	end
	-- Move the Frame parts to the new tower.
	for _, frameFolder in targetTower.Frame:GetChildren() do
		Action "Delete" (frameFolder)
	end
	for _, framePart in originalTower.Frame:GetChildren() do
		if framePart.Name:match("^Floor%d+$") then
			if not targetTower.Frame:FindFirstChild(framePart.Name) then
				local folder = Instance.new("Folder")
				Action "Rename" { Value = framePart.Name } (folder)
				folder.Parent = targetTower.Frame
			end
			framePart.Parent = targetTower.Frame:FindFirstChild(framePart.Name)
		else
			framePart.Parent = targetTower.Frame
		end
	end

	-- Cleanup the old tower.
	Action "Delete" (originalTower)
end, function(err)
	warn("\n\n\t<--- Traceback --->\n" .. debug.traceback())
	return tostring(err)
end)

-- Do not remove this code below. It's used to record the changes to allow for an undo/redo.

local recordingConnection
recordingConnection = ChangeHistoryService.OnRecordingFinished:Connect(function(name, _, _, op, settingsTable)
	local msg = settingsTable.msg :: string
	if name ~= RECORDING_NAME or not msg then return end

	if op == Enum.FinishRecordingOperation.Cancel then
		warn(msg)
	elseif op == Enum.FinishRecordingOperation.Commit then
		print(msg)
	end

	recordingConnection:Disconnect()
end)

ChangeHistoryService:FinishRecording(
	recording,
	success and Enum.FinishRecordingOperation.Commit or Enum.FinishRecordingOperation.Cancel,
	{
		msg = (success 
			and `[ℹ️ UNOFFICIAL V6 UPDATE KIT ℹ️]: Tower was successfully converted to v6.1.1!` 
			or `[⚠️ UNOFFICIAL V6 UPDATE KIT ⚠️]: Tower was not converted: Converter encountered an error. Please contact a developer about this issue.`)
			.. ` Time elapsed: {("%.3f"):format(os.clock() - start)} seconds.`
	}
)

for i = 1, #cache.queueWarn do warn(cache.queueWarn[i]) end

-- Cleanup the script.
if success then Action "Delete" (game:FindFirstChild("KIT-MIGRATE-v6", true)) else error(err) end

return nil