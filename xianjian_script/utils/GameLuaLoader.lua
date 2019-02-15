GameLuaLoader = GameLuaLoader or {}

local load_paths = {

}
local GAME_SYS_EVENTS = {
	"InitEvent",
	"LogEvent",
	"HeroEvent",
	"UserEvent",
	"UserExtEvent",
	"LoginEvent",
	"TreasureEvent",
	"HomeEvent",
	"ChargeEvent",
	"ItemEvent",
	"OptionsEvent",
	"SystemEvent",
	"TutorialEvent",
	"NotifyEvent",
	"TimeEvent",
	"PvpEvent",
	"PveEvent",
	"GuildEvent",
	"MailEvent",
	"FriendEvent",
	"ChatEvent",
	"CountEvent",
	"ShopEvent",
	"TrialEvent",
	"LotteryEvent",
	"LoadEvent",
	"BattleEvent",
	'ActivityEvent',
	'WorldEvent',
	'QuestEvent',
	'CombineEvent',
	'UIEvent',
	"SettingEvent",
	'TowerEvent',
	'CharEvent',
	'StarlightEvent',
	'VersionEvent' ,
    'NatalEvent',
    'HappySignEvent',
    'EliteEvent',
    'RechargeEvent',
    "PartnerEvent",
    "NewLotteryEvent",
    "NetworkEvent",
    "LineUpEvent",
    "GarmentEvent",
    "PartnerSkinEvent",
    "NewSignEvent",
    "ChallengeEvent",
    "DelegateEvent",
    "TreasureNewEvent",
    "TeamFormationEvent",
    "TitleEvent",
    -- "LoveEvent",
    "ArtifactEvent",
    "WelfareEvent",
    "CarnivalEvent",
    "NewLoveEvent",
    "ActivityFirstRechargeEvent",
    "GuildActivityEvent",
    "GuildBossEvent",
    "ShareBossEvent",
    "WuLingEvent",
    "MissionEvent",
    "WonderlandEvent",
    "CrossPeakEvent",
    "EndlessEvent",
    "BarrageEvent",
    "MemoryEvent",
    "MonthCardEvent",
    "HandbookEvent",
    "BiographyUEvent",
    "EditorEvent",
    "GuildExploreEvent",
    "LuckyGuyEvent",
}
local GAME_SYS_DATAS = {
	"ActionConfig",
	"MusicConfig",
	"ServiceData",
	"ArmatureData",
	"MethodCode",
	"StorageCode",
	"ErrorCode",
	"GameStatic",
	"ClientTagData",
}

local GAME_SYS_MODELS = {
	"BaseModel",
	"UserModel",

	"UserExtModel",
	"AbilityModel",
	"OptionsModel",
	"HomeModel",
	"ItemsModel",
	"GarmentModel",
	"PVPModel",

	"GuildModel",
	"GuildRedPacketModel",
	-- "Treasure",

	-- "TreasuresModel",
	"MailModel",
	"ShopModel",
	"NoRandShopModel",
	"CountModel",
	"WeekCountModel",
	"CdModel",
	-- "SignModel",
	"TrailModel",
	"WorldModel",
	"AudioModel",
	"DailyQuestModel",
	"TargetQuestModel",
	"CharModel",
	"ActTaskModel",
	"ActKaiFuModel",
	"ActConditionModel",
	"FriendModel",
	"ChatModel",
    "ChallengeModel",
    "ChallengePvPModel",
    "HappySignModel",
    "RechargeModel",
    "VipModel",
    "GodFormulaModel",
    "PartnerModel",
    "TeamFormationModel",
    "TeamFormationMultiModel",
    "NewLotteryModel",
    "LineUpModel",
    "PartnerSkinModel",
    "GarmentModel",
    "NewSignModel",
    "DelegateModel",
    "UserHeadModel",
    "TreasureNewModel",
    "TitleModel",
    "TowerMainModel",
    "TowerMapModel",
    "TeamFormationSupplyModel",
    "ArtifactModel",
    "CheckTeamFormationModel",
    "CarnivalTaskConditionModel",
    "CarnivalModel",
    "NewLoveModel",
    "ActivityFirstRechargeModel",
    "GuildActMainModel",
    "GuildBossModel",
    "ShareBossModel",
    "WuLingModel",
    "MissionModel",
    "WonderlandModel",
    "CrossPeakModel",
    "EndlessModel",
    "WelfareModel",
    "RankAndcommentsModel",
    "BarrageModel",
    "EliteMainModel",
    "EliteMapModel",
    "RetrieveModel",
    "MemoryCardModel",
    "QuestAndChatModel",
    "MonthCardModel",
    "RankListModel",
    "HandbookModel",
    "BiographyModel",
    "GuildExploreModel",
    "GuildExploreEventModel",
    "LuckyGuyModel",
    "GameModel",
    "NoticeModel",
}


local GAME_SYS_FUNCS = {
	"FuncDataSetting",	
	"FuncRes",
	"GameConfig",
	"FuncArmature",
	"FuncCommUI",
	"FuncChar",
	"FuncTranslate",
	"FuncTreasure",
	"FuncDataResource",
	"FuncItem",
	"FuncCommon",
	"FuncPvp",
	"FuncChapter",
	"FuncGuild",
	"FuncMail",
	"FuncShop",
	"FuncTrail",
	"FuncHome",
    "FuncLamp",
	"FuncAccountUtil",
	"FuncPlot",
	"FuncAnimPlot",
	"FuncCount",
	"FuncChat",
	"FuncLoading",
	"FuncMatch",
	"FuncSetting",
	"FuncBattleBase",
	"FuncGuide",
	"FuncWorshipevent",
    "FuncChallenge",
    "FuncHappySign",
    "FuncTeamFormation",
    "FuncNewLottery",
    "FuncBuild",
    "FuncLineUp",
    "FuncGarment",
    "FuncNewSign",
    "FuncDelegate",
    "FuncUserHead",
    "FuncTreasureNew",
    "FuncTitle",
    "FuncTower",
    "FuncTowerMap",
    "FuncArtifact",
    "FuncWelfare",
    "FuncShareBoss",
    "FuncNewLove",
    "FuncLoadingNew",
    "FuncGuildActivity",
    "FuncGuildBoss",
    "FuncWuLing",
    "FuncMission",
    "FuncWonderland",
    "FuncCrosspeak",
    "FuncRankAndcomments",
    "FuncEndless",
    "FuncBarrage",
    "FuncElite",
    "FuncEliteMap",
    "FuncMemoryCard",
    "FuncQuestAndChat",
    "FuncMonthCard",
    "FuncPartnerSkinShow",
    "FuncHandbook",
    "FuncActivityList",
    "FuncBiography",
    "FuncGuildExplore",
    "FuncLuckyGuy",
    "FuncGame",
    "FuncTravelShop",
    "FuncUITool",
}

local GAME_SYS_SERVERS = {
	"ServerBasic",
	"Server",
	"ServerRealTime",
	"ServerJavaSystem",
    "ServerOther",
	"HttpServer",
	"WebHttpServer",
	"CharServer",
	"BattleServer",
	"ItemServer",
	"UserServer",
	"OptionsServer",
	"FriendServer",
	"ChatServer",
    "LampServer",
	"CdServer",
	"PVPServer",
	"TreasureServer",
	"HomeServer",
	"GuildServer",
	"MailServer",
	"ShopServer",
	"RankServer",
	-- "SignServer",
	"LotteryServer",
	"TrialServer",
	"ActivityServer",
	"WorldServer",
	"QuestServer",
	"GarmentServer",
	"CombineServer",
	"TutorServer",
    "HappySignServer",
    "FirstRechargeServer",
    "RechargeServer",
    "VipServer",
    "GodServer",
    "PartnerServer",
    "TeamFormationServer",
    "NewLotteryServer",
    "LineUpServer",
    "PracticeServer",
    "NewSignServer",
    "PartnerSkinServer",
    "DelegateServer",
    "TreasureNewServer",
    "TitleServer",
    "TowerServer",
    "ArtifactServer",
    -- "LoveServer",
    "ShareBossServer",
    "CarnivalServer",
    "NewLoveServer",
    "GuildActivityServer",
    "GuildBossServer",
    "WuLingServer",
    "MissionServer",
    "WonderlandServer",
    "CommonServer",
    "CrossPeakServer",
    "RankAndcommentsServer",
    "EndlessServer",
    "BarrageServer",
    "MemoryServer",
    "CardMonthServer",
    "HandbookServer",
    "BiographyServer",
    "GuildExploreServer",
    "LuckyGuyServer",
}

local GAME_BATTLE_TOOLS = {
	"RandomControl",
	"TimeUtils",
	"GameStatistics",
	"BattleRandomControl",

}

local GAME_BATTLE_DATAS = {
	"Formula",
	"ConstValues",
	"FrameDatas",
	"EnemyLocation",
}

local GAME_BATTLE_CONTROLERS = {
	"LayerManager",
	"GameSortControler",
	"RefreshEnemyControler",
	"CameraControler",
	"BattleCheckControler",
	"GameControler",
	"GameControlerEx",
	"MiniGameControler",
	"GameBackupControler",
	"KeyControler",
	"ScreenControler",
	"MapControler",
	"GameResControler",
	"StatisticsControler",
	"LogicalControler",
	"LogicalControlerHandle",
	"LogicalControlerEx",
	"MiniLogicalControler",
	"ViewPerformControler",
	"EnergyControler",
	"FormationControler",
	"ArtifactControler",
	"TriggerSkillControler",
	"verifyControler",
	"CrossPeakControler",
}

local GAME_BATTLE_MODELS = {
	"ModelBasic",
	"ModelMoveBasic",
	"ModelHitBasic",
	"ModelFrameBasic",
	"ModelCreatureBasic",
	"ModelAutoFight",
	"ModelEffectBasic",
	"ModelEffectNum",
	"ModelActionExpand",
	"ModelEffectEnergy",
	"ModelShade",
	"ModelHero",
	"ModelMissle",
	"ModelPiece",
	"ModelPhantom",
	"ModelEnemy",
	"ModelBullet",
	"ModelTrialHero", 
	"ModelElement",
	"ModelArtifact",
	"ModelLattice",
}
--test
local GAME_BATTLE_OBJECTS = {
	"ObjectCommon",
	"ObjectBuff",
	"ObjectSkill",
	"ObjectSpecialSkill",
	"ObjectAttack",
	"ObjectHero",
	"ObjectLevel",
	"MiniObjectLevel",
	"ObjectTreasure",
	"EnemyInfo",
	"HeroAttrInfo",
	"ObjectRefresh",
	"ObjectFilterAi",
	"ObjectHpAi",
	"ObjectArtifact",
	"ObjectArtifactTreasure",
	"ObjectArtifactSkill"
}

local GAME_BATTLE_SKILLS = {
	"SkillAiBasic",
	"SkillBaseFunc",
}


local GAME_BATTLE_VIEWS = {
	"ViewBasic",
	"ViewHealthBar",
	"ViewTalkBubble",
	"ViewArmature",
	"ViewSpine",
	"ViewBuff",
}

local GAME_BATTLE_EXPANDS = {
	"MissleAppearType",
	"AttackChooseType",
	"AttackUseType",
	"SkillChooseExpand",
}

--加载更新完之后需要require的内容
function GameLuaLoader:loadGameStartupNeeded()
	--最先加载logsControler
	LogsControler = require("game.sys.controler.LogsControler")
	require("game.sys.GameVars")
	require("app.scenes.init")
end

--加载更新完之后需要require的内容
function GameLuaLoader:loadFirstNeeded()
	require("game.sys.AppInformation")
	self:loadGameSysEvents()
	require('game.sys.view.init')
	self:loadTutorials()
	require('game.sys.controler.init')
	self:loadGameSysDatas()
	self:loadFirstNeededFuncs()
	self:loadGameSysModels()
	self:loadAnimModels()
	self:loadGameSysServers()
	require("game.battle.view.ViewSpine")
	require("game.battle.tools.RandomControl")
	require("game.battle.view.ViewArmature")

	AudioModel = require('game.sys.model.AudioModel')
end



function GameLuaLoader:loadTutorials()
	require("game.sys.view.tutorial.TutorialLayer")
	require("game.sys.view.tutorial.TutorialManager")
end

function GameLuaLoader:loadAnimModels()
	--self:_loadOnePath("game.sys.animModel.", GAME_SYS_ANIMMODEL)
	require("game.sys.animModel.AnimModelBasic")
	require("game.sys.animModel.AnimModelBody")
	require("game.sys.animModel.AnimModelEffect")
	require("game.sys.animModel.AnimModelTransfer")
	require("game.sys.animModel.AnimModelNPC")
	require("game.sys.animModel.AnimModelMission")
	require("game.sys.animModel.AnimModelBox")
	require("game.sys.animModel.AnimModelBiographyNPC")
end



function GameLuaLoader:loadFirstNeededFuncs()
	local funcs = {
		"FuncCommUI",
		"FuncArmature",
		"FuncTranslate",
		"FuncDataSetting",
		"FuncCommon",
		"FuncDataResource",
		"GameConfig",
		"FuncSetting", 
		"FuncLoading",
		"FuncRes",
		"FuncChar",
		"FuncItem",
		"FuncTreasure",
		"FuncShop",
		"FuncCount",
		"FuncChat",
		"FuncMatch",
		"FuncTrail",
		"FuncAccountUtil",
		"FuncChapter",
		"FuncBattleBase",
        "FuncPartner",
        "FuncPartnerSkin",
        "FuncPartnerEquipAwake",
        "FuncQuest",
        "FuncTreasureNew",
        "FuncTitle",
        "FuncCarnival",
        "FuncLoadingNew",
        "FuncActivity",
	}
	for _, func in ipairs(funcs) do
		require('game.sys.func.'..func)
		local t = _G[func]
		if t and t.init then
			t.init()
			EventControler:dispatchEvent(InitEvent.INITEVENT_FUNC_INIT, {funcname=func})
		end
	end
end

function GameLuaLoader:loadGameSysEvents()
	local events = GAME_SYS_EVENTS
	for _,event in ipairs(events) do
		_G[event] = require('game.sys.event.'..event)
	end
end

function GameLuaLoader:loadGameSysDatas()
	local datas = GAME_SYS_DATAS
	for _, datakey in ipairs(datas) do
		_G[datakey] = require('game.sys.data.'..datakey)
	end
end

function GameLuaLoader:loadGameSysServers()
	for _, serverkey in ipairs(GAME_SYS_SERVERS) do
		_G[serverkey] = require("game.sys.service."..serverkey)
	end
end

function GameLuaLoader:loadGameSysModels()
	for _,modelkey in ipairs(GAME_SYS_MODELS) do
		_G[modelkey] = require("game.sys.model."..modelkey)
	end
end

function GameLuaLoader:loadGameSysFuncs()
	for _,funckey in ipairs(GAME_SYS_FUNCS) do
		local loadPath = "game.sys.func."..funckey
		if not package.loaded[loadPath] then
			require(loadPath)
			local t = _G[funckey]
			if t and t.init then
				t.init()
				if not DEBUG_SERVICES then
					EventControler:dispatchEvent(InitEvent.INITEVENT_FUNC_INIT, {funcname=funckey})
				end
				
			end
		end
	end
end



function GameLuaLoader:loadGameBattleTools()

end

function GameLuaLoader:loadGameBattleDatas()
	
end

function GameLuaLoader:loadGameBattleControlers()
	
end

function GameLuaLoader:loadGameBattleModels()
	
end

function GameLuaLoader:loadGameBattleObjects()
	
end

function GameLuaLoader:loadGameBattleViews()
	
end

function GameLuaLoader:loadGameBattleExpands()
	
end

function GameLuaLoader:loadGameBattleInit()
	

	self:_loadOnePath("game.battle.tools.", GAME_BATTLE_TOOLS)
	self:_loadOnePath("game.battle.data.", GAME_BATTLE_DATAS)
	self:_loadOnePath("game.battle.controler.", GAME_BATTLE_CONTROLERS)
	self:_loadOnePath("game.battle.model.", GAME_BATTLE_MODELS)
	self:_loadOnePath("game.battle.object.", GAME_BATTLE_OBJECTS)
	self:_loadOnePath("game.battle.skillAi.", GAME_BATTLE_SKILLS)
	self:_loadOnePath("game.battle.view.", GAME_BATTLE_VIEWS)
	self:_loadOnePath("game.battle.expand.", GAME_BATTLE_EXPANDS)

	if DEBUG_SERVICES then
	else
		
		self:loadAnimModels()
	end

end

function GameLuaLoader:_loadOnePath(requirePathStr, files)
	local loadPath = requirePathStr
	for _,v in ipairs(files) do
		require(loadPath..v)
	end
end

--进入游戏之后的loaded path
function GameLuaLoader:getAllLoadedPaths()
	local clearPaths = {
		"game.sys.GameVars",
	}
	for _, datakey in ipairs(GAME_SYS_DATAS) do
		table.insert(clearPaths, string.format("game.sys.data.%s", datakey))
	end

	for _, eventkey in ipairs(GAME_SYS_EVENTS) do
		table.insert(clearPaths, string.format('game.sys.event.%s', eventkey))
	end
	
	for _, funckey in ipairs(GAME_SYS_FUNCS) do
		table.insert(clearPaths, string.format("game.sys.func.%s", funckey))
	end

	for _, serverkey in ipairs(GAME_SYS_SERVERS) do
		table.insert(clearPaths, string.format('game.sys.service.%s', serverkey))
	end

	for _, modelkey in ipairs(GAME_SYS_MODELS) do
		table.insert(clearPaths, string.format("game.sys.model.%s", modelkey))
	end
end

function GameLuaLoader:clearModules(onlyClearLua)
	-- if true then
	-- 	self:clearLuaStack()
	-- 	return
	-- end
	-- onlyClearLua = false
	local scene = WindowControler:getScene()
	scene:stopAllActions()
	--清除所有的计时器
	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	scheduler.unscheduleAll()
	
	self._isGameDestory = true
	WindowControler:clearAllWindow()
	
	
	scene:setBgRootVisible(true)

	if scene.addSceneBg then
		-- scene:addSceneBg()
	end
	local childArr = scene:getChildren()
	for i=#childArr,2,-1 do
		local child = childArr[i]
		if scene.isSceneBgRoot and scene:isSceneBgRoot(child) then
			-- 不删除背景层
			-- TODO 2017-12-13 暂时屏蔽该功能
			-- child:removeFromParent(true)
		else
			child:removeFromParent(true)
		end
	end
	Server:handleClose()
	ServerRealTime:handleClose()
	ServerJavaSystem:handleClose()
	--为了避免重启游戏时卡死 ,这里一定要分帧处理. 先销毁ccnode,  在销毁纹理,在销毁spine
	local action1 = function (  )
		

		EventControler:clearAllEvent()
		FightEvent:clearAllEvent()
		
		FuncCommUI:clearCacheTempLabel (  )

		ViewArmature:clearArmatureCache()
		ViewSpine:clearSpineCache()
		TimeControler:destroyData()
	end


	local action2 = function (  )
		cc.Director:getInstance():purgeCachedData();
		cc.SpriteFrameCache:getInstance():removeSpriteFrames();
	end

	--移除未使用的spriteFrame
	local action3 = function (  )
		pc.PCSkeletonDataCache:getInstance():clearAllCache()
	end

	--清除未使用的纹理
	local action4 = function (  )
		if onlyClearLua then
			AppHelper:releaseResAndRestart(1)
		else
			cc.Director:getInstance():getTextureCache():removeUnusedTextures()
			cc.Director:getInstance():getTextureCache():removeAllTextures()
			AppHelper:releaseResAndRestart(0)

		end
		
	end
	local actionEmpty = function (  )
		
	end

	local actionArr = {action1,action2,action3,action4	}

	if onlyClearLua then
		actionArr = {action1,actionEmpty,action4}
	end
	for i,v in ipairs(actionArr) do
		WindowControler:globalDelayCall(v, 0.05 * i )
	end

end


function GameLuaLoader:clearModulesAndReloading()
	EventControler:clearAllEvent()
	FightEvent:clearAllEvent()
	local scene = WindowControler:getScene()
	scene:showLoading()
end

--判断
function GameLuaLoader:isGameDestory(  )
	return self._isGameDestory
end