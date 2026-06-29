--[[
	DISCORD: s1mpai (Carlos) ROBLOX: affsdh3 (diman725te_v2)

    This module serves as the core of a highly adaptable quest system, perfect for any game of this genre. 
    It handles everything from resetting and assigning daily and weekly quests (configured in the accompanying `QuestData.lua` file) 
    to tracking progress and handing out rewards. The reward system is extremely flexible, allowing for anything from premium 
    cosmetics (like explosions or slaps) to standard consumables.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestData = require(script.QuestData)
local Constants = require(ReplicatedStorage.MainModules.Constants)
local NetworkServer = require(ReplicatedStorage.MainModules.Network).Server
local Settings = require(ReplicatedStorage.MainModules.ProfileStore.ProfileStoreService.Settings)

local QuestService = {}

-- ════════════════════════════════════════════════════════════
-- constants & rewards
-- ════════════════════════════════════════════════════════════

local GiveRewards = {
	Crate = function(playerClass, Type: string)
		playerClass.profile.OtherInfo.Crates[Type] += 1
		NetworkServer.SendInformation(Constants.NETWORK_SIGNALS.CLIENT.CRATE_UPDATED, playerClass.player, Type)
	end,
	Attributes = function(playerClass, Attribute: string, amount: number)
		playerClass.player:SetAttribute(Attribute, playerClass.player:GetAttribute(Attribute) + amount)
	end,
}

local DAILY_QUEST_COUNT = Constants.QUEST_DATA.DAILY_QUEST_COUNT -- how many daily quests to assign
local WEEKLY_QUEST_COUNT = Constants.QUEST_DATA.WEEKLY_QUEST_COUNT -- how many weekly quests to assign
local SECONDS_IN_DAY = Constants.TIME_DATA.SECONDS_IN_DAY

-- ════════════════════════════════════════════════════════════
-- time utilities
-- ════════════════════════════════════════════════════════════

-- returns timestamp for the very start of today (midnight)
local function getStartOfDay(): number
	local now = os.time()
	local date = os.date("*t", now)
	return os.time({year = date.year, month = date.month, day = date.day, hour = 0, min = 0, sec = 0})
end

-- returns timestamp for the start of the current week (monday)
local function getStartOfWeek(): number
	local now = os.time()
	local date = os.date("*t", now)
	local dayOfWeek = date.wday -- 1 = sunday
	local daysSinceMonday = (dayOfWeek - 2) % 7
	local startOfDay = os.time({year = date.year, month = date.month, day = date.day, hour = 0, min = 0, sec = 0})
	return startOfDay - (daysSinceMonday * SECONDS_IN_DAY)
end

local function shouldResetDaily(lastReset: number): boolean
	return getStartOfDay() > lastReset
end

local function shouldResetWeekly(lastReset: number): boolean
	return getStartOfWeek() > lastReset
end

-- ════════════════════════════════════════════════════════════
-- quest generation
-- ════════════════════════════════════════════════════════════

local function selectRandomQuests(questList: {QuestData.QuestTemplate}, count: number): {QuestData.QuestTemplate}
	local pool = table.clone(questList)
	local selected = {}

	-- keep it diverse: try to pick one easy, one medium, and one hard quest if we can
	local easyQuests = QuestData.getQuestsByDifficulty(pool, "Easy")
	local mediumQuests = QuestData.getQuestsByDifficulty(pool, "Medium")
	local hardQuests = QuestData.getQuestsByDifficulty(pool, "Hard")

	local function pickRandom(list: {QuestData.QuestTemplate}): QuestData.QuestTemplate?
		if #list == 0 then return nil end
		local index = math.random(1, #list)
		return list[index]
	end

	local function removeFromPool(quest: QuestData.QuestTemplate)
		for i, q in ipairs(pool) do
			if q.Id == quest.Id then
				table.remove(pool, i)
				break
			end
		end
	end

	-- grab one of each difficulty level first
	if count >= 1 and #easyQuests > 0 then
		local quest = pickRandom(easyQuests)
		if quest then
			table.insert(selected, quest)
			removeFromPool(quest)
		end
	end

	if count >= 2 and #mediumQuests > 0 then
		local quest = pickRandom(mediumQuests)
		if quest then
			table.insert(selected, quest)
			removeFromPool(quest)
		end
	end

	if count >= 3 and #hardQuests > 0 then
		local quest = pickRandom(hardQuests)
		if quest then
			table.insert(selected, quest)
			removeFromPool(quest)
		end
	end

	-- fill up the rest of the slots randomly from whatever is left in the pool
	while #selected < count and #pool > 0 do
		local index = math.random(1, #pool)
		table.insert(selected, pool[index])
		table.remove(pool, index)
	end

	return selected
end

local function createPlayerQuest(template: QuestData.QuestTemplate): QuestData.PlayerQuest
	return {
		QuestId = template.Id,
		Progress = 0,
		Goal = template.Goal,
		Completed = false
	}
end

local function generateDailyQuests(): {[number]: QuestData.PlayerQuest}
	local quests = {}
	local selected = selectRandomQuests(QuestData.DailyQuests, DAILY_QUEST_COUNT)

	for i, template in ipairs(selected) do
		quests[i] = createPlayerQuest(template)
	end

	return quests
end

local function generateWeeklyQuests(): {[number]: QuestData.PlayerQuest}
	local quests = {}
	local selected = selectRandomQuests(QuestData.WeeklyQuests, WEEKLY_QUEST_COUNT)

	for i, template in ipairs(selected) do
		quests[i] = createPlayerQuest(template)
	end

	return quests
end

-- ════════════════════════════════════════════════════════════
-- quest validation & resets
-- ════════════════════════════════════════════════════════════

function QuestService.checkResetQuests(player: Player, profile: typeof(Settings.FirstData)): ()
	local userId = player.UserId
	if not profile then return end;
	
	local questData = profile.OtherInfo.QuestData
	
	-- check and handle daily reset
	if shouldResetDaily(questData.LastDailyReset) then
		questData.Daily = generateDailyQuests()
		questData.LastDailyReset = getStartOfDay()
		
		-- gift a free crate on daily login
		profile.OtherInfo.Crates["Common"] += 1
		NetworkServer.SendInformation(Constants.NETWORK_SIGNALS.CLIENT.CRATE_UPDATED, player, "Common")
		
		print("🔄 Daily quests reset for", player.Name)
	end

	-- check and handle weekly reset
	if shouldResetWeekly(questData.LastWeeklyReset) then
		questData.Weekly = generateWeeklyQuests()
		questData.LastWeeklyReset = getStartOfWeek()
		print("🔄 Weekly quests reset for", player.Name)
	end
end

-- ════════════════════════════════════════════════════════════
-- getters
-- ════════════════════════════════════════════════════════════

function QuestService.getDailyQuests(player: Player, profile: typeof(Settings.FirstData)): {[number]: QuestData.PlayerQuest}
	if not profile then
		return
	end

	return profile.OtherInfo.QuestData.Daily
end

function QuestService.getWeeklyQuests(player: Player, profile: typeof(Settings.FirstData)): {[number]: QuestData.PlayerQuest}
	if not profile then
		return
	end

	return profile.OtherInfo.QuestData.Weekly
end

-- finds a specific quest inside the player's profile data
function QuestService.getQuestInProfile(player: Player, Type: string, questId: string, profile: typeof(Settings.FirstData)): {[number]: QuestData.PlayerQuest}
	if not profile then
		return
	end

	for index, quest in pairs(profile.OtherInfo.QuestData[Type]) do
		if quest.QuestId == questId then
			return profile.OtherInfo.QuestData[Type][index]
		end
	end
	
	return nil
end

-- quick fetch for all active quests
function QuestService.getAllQuests(player: Player, profile: typeof(Settings.FirstData)): {Daily: {[number]: QuestData.PlayerQuest}, Weekly: {[number]: QuestData.PlayerQuest}}
	return {
		Daily = QuestService.getDailyQuests(player, profile),
		Weekly = QuestService.getWeeklyQuests(player, profile),
	}
end

-- ════════════════════════════════════════════════════════════
-- progress tracking
-- ════════════════════════════════════════════════════════════

function QuestService.addProgress(player: Player, questId: QuestData.QuestId, amount: number?, profile: typeof(Settings.FirstData)): (boolean, boolean)
	local userId = player.UserId
	local addAmount = amount or 1

	if not profile then return false end

	-- search through active dailies
	for _, quest in pairs(profile.OtherInfo.QuestData.Daily) do
		if quest.QuestId == questId and not quest.Completed then
			quest.Progress = math.clamp(math.min(quest.Progress + addAmount, quest.Goal), 0, quest.Goal)

			if quest.Progress >= quest.Goal then
				quest.Completed = true
				print("✅", player.Name, "completed quest:", questId)
				NetworkServer.BypassFire(Constants.NETWORK_SIGNALS.SERVER.PLAYER_QUEST_COMPLETED, player, questId)
			end

			return true, quest.Completed
		end
	end

	-- search through active weeklies
	for _, quest in pairs(profile.OtherInfo.QuestData.Weekly) do
		if quest.QuestId == questId and not quest.Completed then
			quest.Progress =  math.clamp(math.min(quest.Progress + addAmount, quest.Goal), 0, quest.Goal)

			if quest.Progress >= quest.Goal then
				quest.Completed = true
				print("✅", player.Name, "completed weekly quest:", questId)
				NetworkServer.BypassFire(Constants.NETWORK_SIGNALS.SERVER.PLAYER_QUEST_COMPLETED, player, questId)
			end

			return true, quest.Completed
		end
	end

	return false
end

-- parses rewards and fires UI notifications
function QuestService.rewardPlayer(questId: QuestData.QuestId, playerClass): ()
	local questData = QuestData.getQuestById(questId)
	local rewardString = `For completing the quest {questData.Name:upper()} [{questData.Icon}], you receive a reward in the form of:\n`
	
	-- loop through rewards config and distribute items/currency
	for RewardName: string, amount: number | string in pairs(questData.Rewards) do
		if RewardName == "Crate" then GiveRewards["Crate"](playerClass, amount) rewardString = rewardString..`\nThe {amount} Crate 📦🎁` continue end;
		GiveRewards["Attributes"](playerClass, RewardName, amount)
		rewardString = rewardString..`\n- {Constants.QUEST_DATA.QUEST_REWARDS[RewardName]} ({amount})`
	end
	
	rewardString = rewardString.."\n\n Complete more quests to get more rewards!"
	playerClass:popUp("TextFrame", {
		ID = questId.."_completed",
		Name = "Quest completed!",
		Description = rewardString,
		Sound = "Pop up quest"
	})
end

--this is the main hook to update progress.
function QuestService.onEvent(player: Player, event: QuestData.QuestEvent, amount: number?, profile: typeof(Settings.FirstData))
	local relatedQuests = QuestData.EventToQuests[event]
	if not relatedQuests then return end

	for _, questId in ipairs(relatedQuests) do
		QuestService.addProgress(player, questId, amount, profile)
	end
end

return QuestService
