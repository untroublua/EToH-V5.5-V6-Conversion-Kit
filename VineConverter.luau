-- by littlebitsman
-- BEWARE: THIS MAY MISS SOME PROPERTIES ON PARTS, ETC. CHECK YOUR CLIENT OBJECTS AND BACKUP BEFORE USING.

function applyAttr(par: Instance, conf: Configuration, valueBaseName: string, attrName: string?)
	if not attrName then 
		attrName = valueBaseName
	end

	if par:FindFirstChild(valueBaseName) and par:FindFirstChild(valueBaseName):IsA("ValueBase") then
		conf:SetAttribute(attrName, par[valueBaseName].Value)
		par[valueBaseName]:AddTag("REMOVE_AFTER_V6")
	end
end

local basepartproperties = {"Color", "Material", "Transparency", "CFrame", "Size", "Shape"}

return function()
	for _, oldswing in workspace.CoTUD.ClientSidedObjects.Swings:GetChildren() do
		local newVine = workspace.Vine:Clone()
		applyAttr(oldswing, newVine.VineConfiguration, "AllowJumpDismount")
		applyAttr(oldswing, newVine.VineConfiguration, "KeepVelocity", "KeepMomentum")
		applyAttr(oldswing, newVine.VineConfiguration, "RespawnTime")
		
		--newVine.VinePart.Size = Vector3.new(oldswing.Swing.Size.X, 0.5, 0.5)
		--newVine.AttachmentPart.CFrame = oldswing.Top.CFrame
		--newVine.VinePart.CFrame = oldswing.Swing.CFrame
		newVine.VineConstraint.Length = oldswing.RopeLength.Value
		for _, prop in basepartproperties do
			newVine.AttachmentPart[prop] = oldswing.Top[prop]
		end
		for _, prop in basepartproperties do
			newVine.VinePart[prop] = oldswing.Swing[prop]
		end
		newVine.RopeBar.Color = newVine.AttachmentPart.Color
		newVine.RopeBar.CFrame = newVine.AttachmentPart.CFrame * CFrame.new(0, 2, 0)
		
		for _, c: Instance in oldswing.Top:GetChildren() do
			if not c:IsA("SpecialMesh") and not c:IsA("ParticleEmitter") then
				c:Clone().Parent = newVine.AttachmentPart
			end
		end
		for _, c: Instance in oldswing.Swing:GetChildren() do
			if not c:IsA("SpecialMesh") and not c:IsA("ParticleEmitter") then
				c:Clone().Parent = newVine.VinePart
			end
		end
		
		newVine.Parent = workspace.CoTUD.ClientSidedObjects.Vines
	end
	local a = workspace.CoTUD.ClientSidedObjects.Swings
	a.Parent = game.ServerStorage
	a.Name = "Swings/Vines (OLD)"
end
