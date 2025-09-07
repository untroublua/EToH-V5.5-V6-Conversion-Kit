-- by littlebitsman
-- BEWARE: THIS MAY MISS SOME PROPERTIES ON PARTS, ETC. CHECK YOUR CLIENT OBJECTS AND BACKUP BEFORE USING.

local cos = workspace.CoTUD.ClientSidedObjects

type Zipline = typeof(cos.ZiplinesOld.ZiplineA)

function getEndPos(zipline: Zipline)
	local h = Instance.new("Attachment",zipline)
	h.Position = Vector3.new(0,0,-zipline.PC.UpperLimit)
	local cf = h.WorldCFrame
	h:Destroy()
	return cf
end

local basepart_copyprops = {"Size", "CFrame", "Color", "Shape", "Transparency", "CanCollide", "Material"}

return function()
	local newfolder = cos.Ziplines
	for _, zip: Zipline in cos.ZiplinesOld:GetChildren() do
		local new = workspace.Zipline:Clone()
		
		new.Points["1"].CFrame = getEndPos(zip)
		
		local conf = new.ZiplineConfiguration
		conf:SetAttribute("AllowJumpDismount", not zip.CannotDismount.Value)
		if zip.PropelVelocity.Value ~= 0 then
			conf:SetAttribute("Speed", zip.PropelVelocity.Value)
		end
		
		for _, prop in basepart_copyprops do
			new.MountPart[prop] = zip[prop]
		end
		
		new.RideModel:PivotTo(CFrame.new(new.MountPart.Position + Vector3.new(0, 1.5 * zip.Size.Y, 0)))
		new.RideModel.RopeBar.Color = zip.Color
		
		new.Parent = newfolder
	end
	
	cos.ZiplinesOld.Parent = game.ServerStorage
end
