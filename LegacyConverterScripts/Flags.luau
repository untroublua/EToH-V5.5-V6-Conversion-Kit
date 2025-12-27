--[[
Flags / Tags Conversion v5.5 -> v6
author: untroublua / @signupredirectlol

Instructions:
Run the code!
No dependencies required
]]

for _, v in workspace:GetDescendants() do
	-- BAPs
	if v.Name == "ButtonActivatedPlatform" then
		pcall(function()
			v.Name = v.ClassName
			v:AddTag("ButtonActivated")
		end)
	end
	if v:FindFirstChild("ButtonActivated") then
		v.ButtonActivated:Destroy()
		v:AddTag("ButtonActivated")
	end
	if v:FindFirstChild("Invert") then
		v.Invert:Destroy()
		v:AddTag("Invert")
	end
	if v:FindFirstChild("FullHide") then
		v.FullHide:Destroy()
		v:AddTag("FullHide")
	end
	if v:FindFirstChild("IgnoreTransparency") then
		v.IgnoreTransparency:Destroy()
		v:AddTag("IgnoreTransparency")
	end
	if v:FindFirstChild("IgnoreCanCollide") then
		v.IgnoreCanCollide:Destroy()
		v:AddTag("IgnoreCanCollide")
	end
	if v:FindFirstChild("IgnoreAll") then
		v.IgnoreAll:Destroy()
		v:AddTag("IgnoreAll")
	end
	if v:FindFirstChild("ColorOverride") then
		v:SetAttribute("ColorOverride", v.ColorOverride.Value)
		v.ColorOverride:Destroy()
	end
	if v:FindFirstChild("SetTransparency") then
		v:SetAttribute("SetTransparency",v.SetTransparency.Value)
		v.SetTransparency:Destroy()
	end

	-- general
	if v:FindFirstChild("SetCollisionGroup") then
		v.CollisionGroup = v.SetCollisionGroup.Value
		v.SetCollisionGroup:Destroy()
	end
	if v:FindFirstChild("Invisible") then
		v:AddTag("Invisible")
		v.Invisible:Destroy()
	end
end

game.ChangeHistoryService:SetWaypoint("Convert Flags v5.5 -> v6")