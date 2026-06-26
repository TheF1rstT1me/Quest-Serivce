--[[
    constant quest configurations for QuestService.lua
]]

local QuestData = {}

-- ════════════════════════════════════════════════════════════
-- types
-- ════════════════════════════════════════════════════════════

export type QuestType = "Daily" | "Weekly"
export type QuestId = string
export type QuestTemplate = {
	Id: QuestId,
	Name: string,
	Description: string,
	Icon: string,
	Type: QuestType,
	Goal: number,
	Rewards: {
		Money: number?,
		XP: number?,
		Crate: string?,
		Item: string?,
	},
	Difficulty: "Easy" | "Medium" | "Hard",
}

export type PlayerQuest = {
	QuestId: QuestId,
	Progress: number,
	Goal: number,
	Completed: boolean,
	Claimed: boolean
}

export type PlayerQuestData = {
	Daily: {[number]: PlayerQuest},
	Weekly: {[number]: PlayerQuest},
	LastDailyReset: number,
	LastWeeklyReset: number,
}

-- ════════════════════════════════════════════════════════════
-- quest events (triggers that update progress)
-- ════════════════════════════════════════════════════════════

export type QuestEvent = 
	| "Win"                    -- won a round
	| "Die"                    -- player died
	| "RunDistance"            -- ran X meters
	| "PlayRounds"             -- played a round
	| "SlapPlayer"             -- slapped another player
	| "RaceComplete"           -- finished a race stage
	| "TowerComplete"          -- cleared the entire tower
	| "NearMiss"               -- barely dodged a hazard/monster
	| "PlayMinutes"            -- active play time in minutes
	| "InviteFriend"           -- invited a friend via roblox prompt
	| "Checkpoints"            -- reached a checkpoint

-- ════════════════════════════════════════════════════════════
-- daily quests pool
-- ════════════════════════════════════════════════════════════

QuestData.DailyQuests = {
	-- easy tier
	{
		Id = "daily_play_7",
		Name = "Warm Up",
		Description = "Play 7 rounds in someone game",
		Icon = "🎮",
		Type = "Daily",
		Goal = 7,
		Rewards = {Money = 100, XP = 50, SlapAll = 1, DetonateAll = 1},
		Difficulty = "Easy",
	},
	{
		Id = "daily_run_500",
		Name = "Morning Jog",
		Description = "Run 500 meters total",
		Icon = "🏃",
		Type = "Daily",
		Goal = 500,
		Rewards = {Money = 60, XP = 30, Respawns = 1},
		Difficulty = "Easy",
	},
	{
		Id = "daily_play_10min",
		Name = "Dedicated Player",
		Description = "Play for 10 minutes",
		Icon = "⏰",
		Type = "Daily",
		Goal = 10,
		Rewards = {Money = 50, XP = 25, SkipStages = 1},
		Difficulty = "Easy",
	},
	{
		Id = "daily_die_3",
		Name = "Learning Experience",
		Description = "Die 3 times (it happens bro)",
		Icon = "💀",
		Type = "Daily",
		Goal = 3,
		Rewards = {Money = 30, XP = 15},
		Difficulty = "Easy",
	},

	-- medium tier
	{
		Id = "daily_win_3",
		Name = "Winner Winner",
		Description = "Win 3 rounds in someone game!",
		Icon = "🏆",
		Type = "Daily",
		Goal = 3,
		Rewards = {Money = 150, XP = 75},
		Difficulty = "Medium",
	},
	{
		Id = "daily_slap_3",
		Name = "Bully",
		Description = "Slap 3 players",
		Icon = "👊",
		Type = "Daily",
		Goal = 3,
		Rewards = {Money = 100, XP = 50},
		Difficulty = "Easy",
	},
	{
		Id = "daily_slap_10",
		Name = "Pro Bully",
		Description = "Slap 10 players",
		Icon = "👊",
		Type = "Daily",
		Goal = 10,
		Rewards = {Money = 150, XP = 75},
		Difficulty = "Easy",
	},
	{
		Id = "daily_race_complete",
		Name = "Speed Demon",
		Description = "Complete a race",
		Icon = "🗼",
		Type = "Daily",
		Goal = 1,
		Rewards = {Money = 100, XP = 50},
		Difficulty = "Medium",
	},
	{
		Id = "daily_near_miss_3",
		Name = "Close Call",
		Description = "Don't die 3 times in a row",
		Icon = "😰",
		Type = "Daily",
		Goal = 3,
		Rewards = {Money = 100, XP = 50},
		Difficulty = "Medium",
	},
	{
		Id = "daily_invite_2",
		Name = "Social Friend",
		Description = "Invite 2 friends to the game",
		Icon = "👥",
		Type = "Daily",
		Goal = 2,
		Rewards = {Money = 250, XP = 150, Respawns = 2, SkipStages = 2},
		Difficulty = "Medium",
	},
	
	-- hard tier
	{
		Id = "daily_win_5",
		Name = "Domination",
		Description = "Win 5 rounds in someone game.",
		Icon = "👑",
		Type = "Daily",
		Goal = 5,
		Rewards = {Money = 250, XP = 125, SlapAll = 1, DetonateAll = 1, Crate = "Common"},
		Difficulty = "Hard",
	},
	{
		Id = "daily_tower_complete",
		Name = "Tower Master",
		Description = "Complete the tower once",
		Icon = "🏰",
		Type = "Daily",
		Goal = 1,
		Rewards = {Money = 300, XP = 150, Respawns = 1, DetonateAll = 1, Crate = "Rare"},
		Difficulty = "Hard",
	},
	{
		Id = "daily_run_2000",
		Name = "Marathon",
		Description = "Run 2000 meters total",
		Icon = "🏃‍♂️",
		Type = "Daily",
		Goal = 2000,
		Rewards = {Money = 175, XP = 85, SkipStages = 1},
		Difficulty = "Hard",
	},
} :: {QuestTemplate}

-- ════════════════════════════════════════════════════════════
-- weekly quests pool
-- ════════════════════════════════════════════════════════════

QuestData.WeeklyQuests = {
	-- easy tier
	{
		Id = "weekly_play_20",
		Name = "Regular Player",
		Description = "Play 20 rounds this week in someone game",
		Icon = "📅",
		Type = "Weekly",
		Goal = 20,
		Rewards = {Money = 300, XP = 150, Crate = "Common"},
		Difficulty = "Easy",
	},
	{
		Id = "weekly_run_5000",
		Name = "Long Distance",
		Description = "Run 5000 meters total",
		Icon = "🏃",
		Type = "Weekly",
		Goal = 5000,
		Rewards = {Money = 350, XP = 175, Crate = "Common"},
		Difficulty = "Easy",
	},
	{
		Id = "weekly_play_60min",
		Name = "Loyal Player",
		Description = "Play for 60 minutes total",
		Icon = "⏰",
		Type = "Weekly",
		Goal = 60,
		Rewards = {Money = 300, XP = 150, Crate = "Common"},
		Difficulty = "Easy",
	},

	-- medium tier
	{
		Id = "weekly_win_race_10",
		Name = "Weekly Champion",
		Description = "Win 10 Race rounds!",
		Icon = "🏆",
		Type = "Weekly",
		Goal = 10,
		Rewards = {Money = 750, XP = 375, Crate = "Rare"},
		Difficulty = "Medium",
	},
	{
		Id = "weekly_slap_50",
		Name = "Ultimate Bully",
		Description = "Slap 50 players",
		Icon = "👊",
		Type = "Weekly",
		Goal = 50,
		Rewards = {Money = 500, XP = 250},
		Difficulty = "Hard",
	},
	{
		Id = "weekly_slap_15",
		Name = "Super Bully",
		Description = "Slap 15 players",
		Icon = "👊",
		Type = "Weekly",
		Goal = 15,
		Rewards = {Money = 250, XP = 100},
		Difficulty = "Medium",
	},
	{
		Id = "weekly_check_point_100",
		Name = "Tower Enthusiast",
		Description = "Reach 100 checkpoints total",
		Icon = "🗼",
		Type = "Weekly",
		Goal = 100,
		Rewards = {Money = 350, XP = 150, DetonateAll = 3, SlapAll = 3, Crate = "Common"},
		Difficulty = "Medium",
	},
	{
		Id = "weekly_invite_3",
		Name = "Social Butterfly",
		Description = "Invite 3 friends to the game",
		Icon = "👥",
		Type = "Weekly",
		Goal = 3,
		Rewards = {Money = 300, XP = 100, SkipStages = 3, SlapAll = 3},
		Difficulty = "Medium",
	},

	-- hard tier
	{
		Id = "weekly_win_race_15",
		Name = "Unstoppable",
		Description = "Win 15 Race rounds",
		Icon = "👑",
		Type = "Weekly",
		Goal = 15,
		Rewards = {Money = 1500, XP = 750, Crate = "Legendary"},
		Difficulty = "Hard",
	},
	{
		Id = "weekly_tower_5",
		Name = "Tower God",
		Description = "Complete the tower 5 times",
		Icon = "🏰",
		Type = "Weekly",
		Goal = 5,
		Rewards = {Money = 1200, XP = 1000, Crate = "Legendary"},
		Difficulty = "Hard",
	},
	{
		Id = "weekly_run_25000",
		Name = "Ultra Marathon",
		Description = "Run 25000 meters total",
		Icon = "🏃‍♂️",
		Type = "Weekly",
		Goal = 25000,
		Rewards = {Money = 800, XP = 500, Crate = "Rare"},
		Difficulty = "Hard"
	},
} :: {QuestTemplate}

-- ════════════════════════════════════════════════════════════
-- event-to-quest mapping
-- ════════════════════════════════════════════════════════════

-- maps gameplay triggers directly to any quests that should track them
QuestData.EventToQuests = {
	Win = {"daily_win_3", "daily_win_5"},
	Die = {"daily_die_3"},
	RunDistance = {"daily_run_500", "daily_run_2000", "weekly_run_5000", "weekly_run_25000"},
	PlayRounds = {"daily_play_7", "weekly_play_20"},
	SlapPlayer = {"daily_slap_3", "daily_slap_10", "weekly_slap_15", "weekly_slap_50"},
	RaceComplete = {"daily_race_complete", "weekly_win_race_10", "weekly_win_race_15"},
	TowerComplete = {"daily_tower_complete", "weekly_tower_5"},
	NearMiss = {"daily_near_miss_3"},
	PlayMinutes = {"daily_play_10min", "weekly_play_60min"},
	Checkpoints = {"weekly_check_point_100"},
	InviteFriend = {"daily_invite_2", "weekly_invite_3"},
} :: {[QuestEvent]: {QuestId}}

-- ════════════════════════════════════════════════════════════
-- helper functions
-- ════════════════════════════════════════════════════════════

-- searches both daily and weekly lists to find a quest by its unique id
function QuestData.getQuestById(questId: QuestId): QuestTemplate?
	for _, quest in ipairs(QuestData.DailyQuests) do
		if quest.Id == questId then
			return quest
		end
	end
	for _, quest in ipairs(QuestData.WeeklyQuests) do
		if quest.Id == questId then
			return quest
		end
	end
	return nil
end

-- filters a given array of quests by their difficulty level
function QuestData.getQuestsByDifficulty(quests: {QuestTemplate}, difficulty: string): {QuestTemplate}
	local result = {}
	for _, quest in ipairs(quests) do
		if quest.Difficulty == difficulty then
			table.insert(result, quest)
		end
	end
	return result
end

return QuestData
