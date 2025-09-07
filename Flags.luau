--[[
Flags / Tags Conversion v5.5 -> v6
author: untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required
]]

game.ChangeHistoryService:SetWaypoint("Convert Flags v5.5 -> v6")
for _, v in workspace:GetDescendants() do
	-- BAPs
	if v.Name == "ButtonActivatedPlatform" then
		pcall(function()
			v.Name = v.ClassName
			v:AddTag("ButtonActivated")
		end)
	end
	if v:FindFirstChild("ButtonActivated") then
		pcall(function()
			v.ButtonActivated:Destroy()
			v:AddTag("ButtonActivated")
		end)
	end
	if v:FindFirstChild("Invert") then
		pcall(function()
			v.Invert:Destroy()
			v:AddTag("Invert")
		end)
	end
	if v:FindFirstChild("FullHide") then
		pcall(function()
			v.FullHide:Destroy()
			v:AddTag("FullHide")
		end)
	end
	if v:FindFirstChild("IgnoreTransparency") then
		pcall(function()
			v.IgnoreTransparency:Destroy()
			v:AddTag("IgnoreTransparency")
		end)
	end
	if v:FindFirstChild("IgnoreCanCollide") then
		pcall(function()
			v.IgnoreCanCollide:Destroy()
			v:AddTag("IgnoreCanCollide")
		end)
	end
	if v:FindFirstChild("IgnoreAll") then
		pcall(function()
			v.IgnoreAll:Destroy()
			v:AddTag("IgnoreAll")
		end)
	end
	if v:FindFirstChild("ColorOverride") then
		pcall(function()
			v:SetAttribute("ColorOverride", v.ColorOverride.Value)
			v.ColorOverride:Destroy()
		end)
	end
	if v:FindFirstChild("SetTransparency") then
		pcall(function()
			v:SetAttribute("SetTransparency",v.SetTransparency.Value)
			v.SetTransparency:Destroy()
		end)
	end

	-- general
	if v:FindFirstChild("SetCollisionGroup") then
		pcall(function()
			v.CollisionGroup = v.SetCollisionGroup.Value
			v.SetCollisionGroup:Destroy()
		end)

	end
	if v:FindFirstChild("Invisible") then
		pcall(function()
			v:AddTag("Invisible")
			v.Invisible:Destroy()
		end)
	end
end