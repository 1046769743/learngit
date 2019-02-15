--服务器相关数据
local ServiceData = ServiceData or {}

-- VMS 配置
ServiceData.platformCfg = {
	-- dev平台
	dev = {
		platform = "dev",											--平台名称
		vms_url = "http://10.2.24.171:8100/index.php",				--VMS 地址
		upgrade_path = "ios_cn_0511"								--升级序列
	},  

	-- sanbox平台
	-- android_cn_0710
	-- ios_cn_0511
	sandbox = {
		platform = "sandbox",											
		vms_url = "https://vms-sandbox-xianpro.playcrab.com/index.php",
		upgrade_path = "ios_cn_0511"
	},
	-- xptest平台
	xptest = {
		platform = "xptest",											
		vms_url = "https://sh-vms-1000108700.gamebean.net/index.php",
		upgrade_path = "ios_cn_0511"
	},
    -- 外网正式平台
	product = {
		platform = "product",											
		vms_url = "https://vms-product-xianpro.playcrab.com/index.php",
		upgrade_path = "ios_cn_0511"
	},
	online = {
		platform = "online",											
		vms_url = "https://vms-online-xianpro.playcrab.com/index.php",
		upgrade_path = "ios_cn_0511"
	},
	ztest = {
		platform = "ztest",											
		vms_url = "https://cs-vms-1000108700.gamebean.net/index.php",
		upgrade_path = "ios_cn_0511"
	},
	tencloud = {
		platform = "tencloud",											
		vms_url = "https://cs1-vms-1000108700.gamebean.net/index.php",
		upgrade_path = "ios_cn_0511"
	},
}

-- 切换服务器平台(集群，在打包系统platform的概念为集群），修改该配置

ServiceData.curPlatform = "dev"

-- 服务器返回如下错误码，需要同步玩家数据
ServiceData.syncDataErrorCodeArr = {   
	10013,     --user_level_not_enough
	10014,	   --user_coin_not_enough
	10015,	   --user_mp_not_enough
	10016,	   --user_sp_not_enough
	10017,	   --user_sp_not_enough
	10019	   --user_gold_not_enough
}


ServiceData.SIGN_SALT = "MaybeYouHaveGotThisSignWithWireSharkOrIDA" --"MaybeYouHaveGotThisSignWithWireSharkOrIDA"

ServiceData.MESSAGE_ERROR = "error" 			--网络错误
ServiceData.MESSAGE_RESPONSE = "response" 		--接收到消息
ServiceData.MESSAGE_CLOSE = "close" 			--网络关闭
ServiceData.MESSAGE_NOTIFY = "notify" 			--通知 		--目前应该用不上

ServiceData.overTimeSecond = 10 				--超时时间 

ServiceData.overBackGroundTime = 3600			--切后台超时时间1小时后同步用户数据

ServiceData.initMethdoCode = "init" 		--初始化code

ServiceData.nodeServerName = "game" 		--nodeserVerName


ServiceData.serverTypeMap = {
	gameServer = 1, 		--正常游戏服
	realTimeServer = 2,		--长连接服
	javaSystem = 3,		--长连接系统相关服 所有的系统都走这个
}

--配置 model 和server数据库对应关系
--[[
	model  对应的model对象
	keys 里面不填写参数表示不需要服务器数据,只做初始化
		填写参数表示对应的是userData里面对应的模块数据
		第一个参数 还会作用到Server模块服务器返回时通知到底层对应的Model updateData.
		后面的参数就会按需作为Model:init时候 需要输入的参数传递,如果需要嵌套几层属性 用点连接
		比如 伙伴技能 还需要partenerSkill属性userExt.partnerSkill  应该尽量避免这种写法,非常不规范
		原则上一个Model 对应一个数据

	noSeverMap  是否不需要在server里面map映射 默认和空是需要的

]]

function ServiceData:getModelToServerMap(  )
	local obj = {
		{model = UserModel ,keys = {	},	}, 		--主模块
		{model = UserExtModel ,keys = {"userExt"	},	},	--user扩展模块
		{model = AbilityModel ,keys = {"abilityNew"	},	},	--user扩展模块
		{model = OptionsModel, keys = {"options"}},			-- options设置模块
		{model = HomeModel ,keys = {	},	},	--home 主城扩展模块
		{model = FriendModel ,keys = {"userExt"	},noSeverMap = true	},	--好友扩展模块
		{model = CountModel ,keys = {"counts"	},	},		--计数
		{model = ItemsModel ,keys = {"items"	},	},		--道具模块
		{model = MonthCardModel,keys = {"monthCards"},},      --月卡
		{model = GarmentModel ,keys = {"garments"	},	},		--时装模块
		{model = UserHeadModel ,keys = {"frames"	},	},		--头像模块
		{model = PartnerSkinModel ,keys = {"skins"	},	},		--伙伴皮肤模块
		{model = CdModel ,keys = {"cds"	},	},		--cd模块
		{model = WuLingModel ,keys = {"fivesouls"},},   --五灵法阵
		{model = CarnivalTaskConditionModel ,keys = {"actConditions"	},	}, -- 嘉年华任务条件
		{model = CarnivalModel ,keys = {"actTasks"	},	},		-- 嘉年华任务
		{model = ChatModel ,keys = {	},	},		--聊天
		{model = PVPModel ,keys = {"pvpExt"	},	},		--pvp
		{model = MemoryCardModel,keys = {"memorys"},}, -- 情景卡
		{model = WorldModel ,keys = {"chapters"	},	},		--六界 章节
		{model = NoRandShopModel ,keys = {"noRandShops"	},	},		--不需要服务器返回数据的model
		{model = ShopModel ,keys = {"shops"	},	},		--商城
		{model = MailModel ,keys = {	},	},		--邮件
		{model = TrailModel ,keys = {"trials"	},	},		--试炼
		{model = PartnerModel ,keys = {"partners","userExt.partnerSkill" },	},		--伙伴
		{model = TreasureNewModel ,keys = {"treasures"	},	},		--法宝
		{model = DailyQuestModel ,keys = {"everydayQuest" },	},		--每日任务
		{model = HappySignModel ,keys = {"happySign" },	},		--欢乐签到
		{model = ActivityFirstRechargeModel ,keys = { },	},		--首充
		{model = GodFormulaModel ,keys = {"formula" },	},		--神明上阵
		{model = RechargeModel ,keys = {"buyProductTimes" },	},		--充值
		{model = VipModel ,keys = { },	},		--vip模块
		{model = LineUpModel ,keys = { },	},		--查看阵容
		{model = NewLotteryModel ,keys = {"lotteryQueues","lotteryExt","lotteryCommonPools","lotteryGoldPools"},},		--三皇台
		{model = DelegateModel ,keys = {"delegates" },	},		--挂机
		{model = TeamFormationModel ,keys = {"formations" },	},		--阵容
		{model = TeamFormationMultiModel ,keys = { },	},		--多人布阵
		{model = TitleModel ,keys = {"titles","privileges" },	},		--称号
		{model = ArtifactModel ,keys = {"cimeliaGroups" },	},		--神器
		{model = TowerMainModel ,keys = { },	},						--爬塔
		{model = ShareBossModel ,keys = { },	},		--共享副本
		{model = NewLoveModel ,keys = { },	},	-- 新情缘系统
		{model = GuildModel ,keys = {	},	},				--仙盟
		{model = GuildActMainModel ,keys = {	},	},		--仙盟GVE活动
		{model = GuildBossModel ,keys = {},	},				--仙盟副本
		{model = MissionModel,keys = {"missionExt"},}, --六界轶事
		{model = WonderlandModel,keys = {"wonderFloors"},}, --须臾仙境
		{model = CrossPeakModel,keys = {"crossPeak"}},-- 巅峰竞技场
		{model = CharModel ,keys = { },	},		--主角
		{model = EndlessModel, keys = {"endlessFloors"}, },    --无底深渊
		{model = RankAndcommentsModel ,keys = { },	},		--评论
		{model = TargetQuestModel ,keys = {"mainlineQuests" },	},		--主线任务
		{model = BarrageModel ,keys = { },	},		--气泡弹幕  --可以不要
		{model = EliteMainModel ,keys = { },	},						--精英探索
		-- {model = ActConditionModel ,keys = {"actConditions"},	},
		-- {model = ActTaskModel ,keys = {"actTasks"},	},
		{model = ActKaiFuModel ,keys = {"saleRewardInfo"},	},
		{model = WelfareModel ,keys = { },	},		--福利模块
		{model = RetrieveModel ,keys = {"retrieveList"},	},		--资源找回模块
		{model = WeekCountModel ,keys = {"weekCounts"},	},   --周记录次数
		{model = HandbookModel ,keys = {"handbooks"},	},		-- 名册系统
		{model = ChallengeModel ,keys = {},	},		-- 历练
		{model = ChallengePvPModel ,keys = {},	},		-- 仙途
		{model = BiographyModel, keys = {"biography"},},	-- 奇侠传记
		
		{model = GuildExploreModel,keys = {},} ,		--仙盟探索model
		{model = GuildExploreEventModel,keys = {},} ,		--仙盟探索事件model
		{model = LuckyGuyModel ,keys = {},	},		-- 幸运转盘

	}	
	return obj
end


return ServiceData
