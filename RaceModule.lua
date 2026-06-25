--[[
    This module script handles the generation of a completely randomized obstacle course for my game. 
    It procedurally links various sections together, with each part dynamically calculating its attachment point using CFrames. 
    The total number of sections is determined by a specific variable, and I can set individual spawn weights (probabilities) 
    for each part to ensure a unique layout every run. The track fully regenerates itself automatically on demand.
]]

local GeneratorRace = {}

-- folder with level templates
local LevelParts = game:GetService("ServerStorage"):WaitForChild("Maps")

-- gets a random level template based on predefined spawn weights
function GeneratorRace:GetRandomLevel(levelsFolder: Folder)
	local TableOfLevels = {
		"Level1", 
		"Level2", 
		"Level3", 
		"Level4",
		"Level5", 
		"Level6", 
		"Level7", 
		"Level8",
		"Level9", 
		"Level10", 
		"Level11",
		"Level12",
		"Level13",
		"Level14",
		"Level15",
	}

	local TableOfWeights = {
		4,
		4,
		4,
		4,
		4,
		4,
		4,
		0.85,
		4,
		4,
		4,
		4,
		4,
		4,
		4
	}

	local function weightedRandom()
		local totalWeight = 0
		for _, weight in ipairs(TableOfWeights) do
			totalWeight = totalWeight + weight
		end

		local randomValue = math.random(0, totalWeight - 1)
		local cumulativeWeight = 0

		for i, weight in ipairs(TableOfWeights) do
			cumulativeWeight = cumulativeWeight + weight
			if randomValue < cumulativeWeight then
				return i
			end
		end
	end

	-- safety check if storage is empty
	if #levelsFolder:GetChildren() == 0 then
		warn("No levels available!")
		return nil
	end
	
	local index = weightedRandom()
	return levelsFolder:FindFirstChild(TableOfLevels[index])
end

-- aligns a level part to the specified hook point using pivot manipulation
function GeneratorRace:AttachLevel(levelModel, attachPoint: CFrame)
	local newLevel = levelModel:Clone()

	local stagePoint = newLevel:FindFirstChild("StagePoint")
	local stagePoint2 = newLevel:FindFirstChild("StagePoint2")
	if not stagePoint then
		warn("Level missing StagePoint: " .. levelModel.Name)
		return nil
	end

	-- snap the start of the level to the previous exit point
	newLevel.PrimaryPart = stagePoint
	newLevel:PivotTo(attachPoint)
	
	-- switch primary part to exit point for the next block to snap to
	newLevel.PrimaryPart = stagePoint2
	
	return newLevel
end

-- core generation logic
function GeneratorRace:Generate(startPoint: Vector3, countLevelParts: number, parent: Instance?)
	local generatedLevels = {}
	local levels = LevelParts

	-- container folder for easy tracking and cleanup
	local container = Instance.new("Folder")
	container.Name = "GeneratedRace"
	container.Parent = parent or workspace

	-- spawn and position the first starter stage
	local startLevel: Model = self:GetRandomLevel(levels):Clone()
	startLevel.PrimaryPart = startLevel:FindFirstChild("StagePoint")
	startLevel:PivotTo(CFrame.new(startPoint) * startLevel:GetPivot().Rotation)
	startLevel.PrimaryPart = startLevel:FindFirstChild("StagePoint2")
	startLevel.Parent = container
	
	local newPart = startLevel:FindFirstChild("StagePoint"):Clone()
	newPart.Name = "TweenPlaced1"
	newPart.Position = newPart.Position + Vector3.new(0, 25, 0)
	newPart.Parent = startLevel

	startLevel.Name = "Stage_1"
	startLevel:SetAttribute("StageNumber", 1)

	-- loop to chain link all the remaining pieces
	for i = 1, countLevelParts - 1 do
		local levelTemplate = self:GetRandomLevel(levels)
		local newLevel = self:AttachLevel(levelTemplate, CFrame.new(startLevel:FindFirstChild("StagePoint2").Position) * startLevel:GetPivot().Rotation)
		
		if not newLevel then
			continue
		end

		newLevel.Name = "Stage_" .. i + 1
		newLevel.Parent = container

		newLevel:SetAttribute("StageNumber", i + 1)
		startLevel = newLevel
		
		-- add end-of-run markers on the final stage
		if i == countLevelParts - 1 then
			local newPart = startLevel:FindFirstChild("StagePoint2"):Clone()
			newPart.Name = "TweenPlaced2"
			newPart.Position = newPart.Position + Vector3.new(0, 25, 0)
			newPart.Parent = startLevel
		end
	end
	
	-- save metadata to the container
	container:SetAttribute("StartPoint", startPoint)
	container:SetAttribute("StartNameStage", "Stage_1")
	container:SetAttribute("EndNameStage", startLevel.Name)
	
	return countLevelParts
end

-- wipes the existing course out of the workspace
function GeneratorRace:Clear(parent: Instance?)
	local container = (parent or workspace):FindFirstChild("GeneratedRace")
	if container then
		container:Destroy()
	end
end

-- standard wipe and rebuild helper
function GeneratorRace:Regenerate(startPoint: Vector3, countLevelParts: number, parent: Instance?)
	self:Clear(parent)
	return self:Generate(startPoint, countLevelParts, parent)
end

return GeneratorRace
