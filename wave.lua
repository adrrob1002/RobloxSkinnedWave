local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local WaveParts = CollectionService:GetTagged("Wave")

local Camera = workspace.CurrentCamera

local UVposition = Vector3.new()

local Waves = {
	{
		["Steepness"] = 0.5,
		["Wavelength"] = 100,
		["Direction"] = Vector3.new(1, 1)
	},
	{
		["Steepness"] = 0.25,
		["Wavelength"] = 75,
		["Direction"] = Vector3.new(1, 0)
	},
	{
		["Steepness"] = 1,
		["Wavelength"] = 10,
		["Direction"] = Vector3.new(1, -1)
	}
}

local function GerstnerWave(properties, p)
	local s = properties.Steepness
	local w = properties.Wavelength
	local d = properties.Direction.Unit
	local k = 2 * math.pi / w
	local c = math.sqrt(9.8 / k)
	local f = k * (d:Dot(Vector3.new(p.X, p.Z)) - (c * tick()))
	local a = s / k
	
	return Vector3.new(
		p.X + d.X * (a * math.cos(f)),
		a * math.sin(f),
		p.Z + d.Y * (a * math.cos(f))
	)
end

local function vert(bone)
	local p = bone.WorldPosition
	
	RunService:BindToRenderStep(bone.Name, Enum.RenderPriority.Last.Value, function()
		local a = (bone.WorldPosition - Camera.CFrame.Position).Unit
		local b = Camera.CFrame.LookVector
		if math.acos(a:Dot(b)) > math.pi * 0.5 then return end
		
		local result = Vector3.new()
		for _, v in ipairs(Waves) do
			result += GerstnerWave(v, p)
		end
		bone.WorldPosition = result
	end)
end

local function checkIfUnderwater(point)
	local result = Vector3.new()
	for _,v in ipairs(Waves) do
		result += GerstnerWave(v, point)
	end
	return result.Y > point.Y 
end

local function startWave()
	RunService:BindToRenderStep("AuxUpdate", Enum.RenderPriority.Last.Value, function()
		UVposition += Vector3.new(0.1, 0.1)
		workspace.Wave.Texture.OffsetStudsU = UVposition.X
		workspace.Wave.Texture.OffsetStudsV = UVposition.Y
		
		if checkIfUnderwater(Camera.CFrame.Position) then
			print("underwater camera")
		end
	end)
	
	for _,v in pairs(WaveParts) do
		for _,v2 in pairs(v:GetChildren()) do
			if v2:IsA("Bone") then
				vert(v2)
			end
		end
	end
end

startWave()
