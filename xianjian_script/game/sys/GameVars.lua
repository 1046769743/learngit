	


--绝大部分全局定义的变量都写在这里
GameVars=GameVars or {}

--默认使用的ttf字体名称
-- Android平台ttf字体必须带.ttf扩展名
GameVars.fontName = "FZHuaLi-M14S.ttf"
-- GameVars.systemFontName = "Arial"
GameVars.systemFontName = "FZHuaLi-M14S.ttf"

--屏幕适配分辨率最大宽度（超过该宽度后左右留黑边）
GameVars.maxScreenWidth = 1400
-- 屏幕适配分辨率最大高度（超过该高度后上下留黑边）
GameVars.maxScreenHeight = 768

--设计分辨率宽度（屏幕宽度超过该值后右移scene._root）
GameVars.gameResWidth = 1136 
--设计分辨率高度（屏幕高度超过该值后上移scene._root）
GameVars.gameResHeight = 640

--定义 1136宽度的设备 和960设备的分辨率
GameVars.widthDistance =  0

GameVars.GAMEFRAMERATE = 30 			--游戏帧率
GameVars.ARMATURERATE = 30 				--动画播放帧率

GameVars.halfResWidth = GameVars.gameResWidth /2 	--设计分辨率半宽 
GameVars.halfResHeight = GameVars.gameResHeight /2 	--设计分辨率半高

--UI背景偏移
GameVars.UIbgOffsetX = 0
GameVars.UIbgOffsetY = -GameVars.gameResHeight/2 + GameVars.maxScreenHeight/2

--游戏的相对显示区域大小, 一定是在  960-1136  , 640 - 768 的范围内
GameVars.width =0;
GameVars.height =0;


--设备尺寸放缩后的大小  如无特殊情况 禁止访问
GameVars.scaleWidth =0; 
GameVars.scaleHeight =0;

--场景偏移  如无特殊情况 禁止访问
GameVars.sceneOffsetX = 0;
GameVars.sceneOffsetY = 0;

--ui适配偏移
GameVars.UIOffsetX = 0 
GameVars.UIOffsetY = 0
-- 算上toolbar的 uioffset 主要是
GameVars.fullUIOffsetX = 0

--游戏相对中心 GameVars.width/2  GameVars.height/2 
GameVars.cx = 0;
GameVars.cy = 0;

GameVars.maxMapWidth = 2680
--背景图片的宽度
GameVars.bgSpriteWidth = GameVars.gameResWidth

--背景缩放系数
GameVars.bgSpriteScale =1 

--暂定toolbar的宽度为 暂定设置为40像素就可以在windows上测试 .
-- 0表示不进行左右动态适配 
GameVars.toolBarWidth = 0 
--游戏全屏宽度 针对iphonex的刘海. 默认是和 GameVars.width相等.
GameVars.fullWidth = 0 
GameVars.toolBarWay = 0  		--刘海位置 1 是右边-1是左边 0表示没有刘海

--初始化scene及UI root偏移、缩放等因子值
GameVars.initUIFactor = function()
	local glview = cc.Director:getInstance():getOpenGLView()
	echo("=============================initUIOffsetFactor=============================\n");
	--scene的root缩放因子
	
	local wid,hei

	--这里先对符合尺寸的 屏幕不缩放
	--windwos 和 mac 可以支持1400* 768缩放. 这样是为了测试适配
	if display.width <= GameVars.maxScreenWidth and display.width >= GameVars.gameResWidth 
		and display.height <= GameVars.maxScreenHeight and display.height >= GameVars.gameResHeight
		and (device.platform == "windows" or device.platform == "mac"  )
		 then
		wid = display.width 
		hei = display.height
	 	GameVars.rootScale =  1.0;
	 	-- GameVars.toolBarWidth = 0;
	 else
	 	local scaleW = display.width / GameVars.gameResWidth;
		local scaleH = display.height / GameVars.gameResHeight;
		
		local scaleMW =  display.width / GameVars.maxScreenWidth
		local scaleMH =  display.height / GameVars.maxScreenHeight

		--对4种比率排序 然后根据宽高计算应该分部在哪个比例空间
		local ratioArr = {scaleW,scaleH,scaleMW,scaleMH}

		table.sort( ratioArr, table.descSort )

		--遍历每一种比率  计算那种比率合适
		for i,v in ipairs(ratioArr) do
			 wid = display.width / v
			 hei = display.height / v

			--只要到达分部边界  那么就 采用这个缩放率
			if wid >= GameVars.gameResWidth and hei >= GameVars.gameResHeight then
				GameVars.rootScale = v
				break
			end
		end
	end

	--这里需要取整
	wid = math.round(wid)
	hei = math.round(hei)

	GameVars.scaleWidth = wid
	GameVars.scaleHeight = hei
	
	echo("GameVars.rootScale:",GameVars.rootScale)
	echo("display.width:%d,height:%d",display.width,display.height)

	--这个地方修改display.width  和 display.heigt  这个为
	-- display.width = wid
	-- display.height = hei

	--scene的x,y方向偏移值
	GameVars.sceneOffsetX = 0;
	GameVars.sceneOffsetY = 0;

	if wid > GameVars.maxScreenWidth then
		GameVars.width = GameVars.maxScreenWidth
		GameVars.sceneOffsetX = (wid - GameVars.maxScreenWidth) / 2;
	else
		GameVars.width = wid
	end
	if GameVars.width >= GameVars.toolBarWidth *2 + GameVars.gameResWidth then
		GameVars.fullWidth = GameVars.width
		-- GameVars.width = GameVars.width - GameVars.toolBarWidth *2
	else
		GameVars.toolBarWidth = 0
		GameVars.fullWidth = GameVars.width
	end

	if hei > GameVars.maxScreenHeight then
		GameVars.sceneOffsetY = (hei - GameVars.maxScreenHeight) / 2;
		GameVars.height = GameVars.maxScreenHeight
	else
		GameVars.height = hei
	end

	--scene的root的x,y方向偏移值
	GameVars.UIOffsetX = 0;
	if GameVars.width - GameVars.gameResWidth > 0 then
		GameVars.UIOffsetX = (wid - GameVars.gameResWidth) / 2 - GameVars.sceneOffsetX;
	else
		GameVars.UIOffsetX = 0;
	end

	if GameVars.height - GameVars.gameResHeight > 0 then
		GameVars.UIOffsetY = (hei - GameVars.gameResHeight) / 2 - GameVars.sceneOffsetY ;
	else
		GameVars.UIOffsetY = 0;
	end
 
	GameVars.bgSpriteScale = GameVars.fullWidth / GameVars.bgSpriteWidth
	if GameVars.bgSpriteScale <1 then
		GameVars.bgSpriteScale =1
	end

	glview:setDesignResolutionSize(GameVars.scaleWidth, GameVars.scaleHeight, cc.ResolutionPolicy.NO_BORDER)
	echo("##(GameVars.sceneOffsetX,GameVars.sceneOffsetY)",GameVars.sceneOffsetX,GameVars.sceneOffsetY);
	echo("##(GameVars.UIOffsetX,GameVars.UIOffsetY)",GameVars.UIOffsetX,GameVars.UIOffsetY);
end

--初始化scene宽高数据
GameVars.initSceneData = function()
	--初始化游戏场景逻辑宽高数据
	-- GameVars.width = display.width;
	-- if GameVars.width > GameVars.maxScreenWidth then
	-- 	GameVars.width = GameVars.maxScreenWidth;
	-- end

	-- GameVars.height = display.height;
	-- if GameVars.height > GameVars.maxScreenHeight then
	-- 	GameVars.height = GameVars.maxScreenHeight;
	-- end

	GameVars.cx = GameVars.width / 2;
	GameVars.cy = GameVars.height / 2;

	echo("(GameVars.width,GameVars.height)=",GameVars.width,GameVars.height);

end

if not DEBUG_SERVICES  then
	GameVars.initUIFactor();
	GameVars.initSceneData ();

	GameVars.grayColor = cc.c3b(1,31,49)
	--通用背景半透颜色
	GameVars.bgAlphaColor = cc.c4b(0,0,0,120)

end


--星级需要的魂石数量
GameVars.starNeedSoul = {
	10,20,50,100,150,210
}

-- start:一 end:龥
GameVars.CHINESE_UTF32_RANGE = {19968, 40869}

--注册一个空函数 什么也不做
GameVars.emptyFunc= function (  )
end

--注册一个空table
GameVars.emptyTable = {}

GameVars.emptyPoint = {x=0,y=0}




GameVars.poolSystem = {
	trail1 = "201",	
	trail2 = "202",	
	trail3 = "203",
	zhangyi = "0",		--行侠仗义
	gve = "1",			--gve
	crossPeak = "301", --巅峰竞技场

}


--每天固定时间发 TimeEvent.TIMEEVENT_STATIC_CLOCK_REACH_EVENT 消息，demo全局搜 TIMEEVENT_STATIC_CLOCK_REACH_EVENT
--必须是 XX:XX:XX
-- GameVars.fireEventTime = {"04:00:00", "03:55:10", 
-- 	"18:00:00", "22:05:00", "18:58:10",  "15:11:30"};
--测试不充分，注释掉
GameVars.fireEventTime = {};

--战斗标签 每场战斗一定会有这个标签 用来给分系统区分 同时用来 区别战斗胜利失败界面
GameVars.battleLabels = {
	
	worldPve = "1", 			--传统pve 六界刷关卡寻仙
	worldGve1 = "101",			--传统gve 六界刷关卡寻仙(废弃,但是代码中未删除)
	worldGve2 = "102",			--传统gve 六界刷关卡寻仙(废弃,但是代码中未删除)
	pvp = "2",					--传统竞技场

	trailPve = "3" ,			--试炼pve   山神
	trailPve2 = "4" ,			--试炼pve   火神
	trailPve3 = "5" ,			--试炼pve	盗宝者

	trailGve1 = "201" , 	--山神试炼gve(废弃,但是代码中未删除)
	trailGve2 = "202" , 	--火神试炼gve(废弃,但是代码中未删除)
	trailGve3 = "203" , 	--盗宝者试炼gve(废弃,但是代码中未删除)
	kindGve = "901",		--行侠仗义(废弃,但是代码中未删除)

	towerPve = "6", 		--爬塔pve
	towerBossPve = "7", 	-- 爬塔boss  pve   
	towerNpc = "8",  		--爬塔npc

	lovePve = "11",			--情缘pve

	shareBossPve = "12",		--共享副本

	missionMonkeyPve = "13",		--轶事夺宝
	missionBattlePve = "14",		--比武切磋
	missionIcePve = "18", 	-- 轶事冰封玩法
	missionBombPve = "19",	-- 轶事爆炸玩法

	guildGve = "15",			--仙盟gve

	crossPeakPvp = "16",	--巅峰竞技场(废弃,但是代码中未删除)
	wonderLandPve = "17",	--须臾幻境pve
	guildBossPve = "21",	--仙盟boss
	endlessPve = "20",--无底深渊

	crossPeakPve = "22",	--巅峰竞技场(机器人)
	crossPeakPvp2 = "23",	--巅峰竞技场(新版)

	ringTaskPve = "24",		--跑环pve

	guildBossGve = "25", 	-- 共闯秘境Gve

	biographyPve = "30", -- 奇侠传记

	miniBattle = "999", -- 简易战斗的Id，自定义id，后端不会用，也没有网络请求
	exploreMonster = "26" ,	--仙盟探索 小怪
	exploreElite = "27" ,	--仙盟探索 精英怪
	exploreMine = "28",		--仙盟探索 矿洞
	exploreBuild = "29",	--仙盟探索建筑
}




GameVars.sysLabelToTreaNatal = {
	homeScene = "1",		-- 主城
    towerPve = "5", 		--爬塔pve
	worldPve = "2", 		--传统pve 六界刷关卡寻仙
	worldGve1 = "4",		--传统gve 六界刷关卡寻仙
	--worldGve2 = "worldGve2",	--传统gve 六界刷关卡寻仙
	pvp = "3",			--传统竞技场
	
	trailPve = "6" ,		--试炼pve
	trailPve2 = "7" ,		--试炼pve
	trailPve3 = "8" ,		--试炼pve

	trailGve1 = "6" , 		--山神试炼gve
	trailGve2 = "7" , 		--火神试炼gve
	trailGve3 = "8" , 		--雷神试炼gve
	kindGve = "kindGve",	--行侠仗义    
}

GameVars.voiceModeDic = {
	--这个类别不会停止其他应用的声音,相反,它允许你的音频播放于其他应用的声音之 上,比如 iPod。
	--你的应用的主 UI 线程会工作正常。调用 AVAPlayer 的 prepareToPlay 和 play 方法都将返回 YES。
	AVAudioSessionCategoryAmbient = "AVAudioSessionCategoryAmbient";

	--这个非常像 AVAudioSessionCategoryAmbient 类别,除了会停止其他程序的音频回放,比如 iPod 程序。
	--当设备被设置为静音模式,你的音频回放将会停止。
	AVAudioSessionCategorySoloAmbient = "AVAudioSessionCategorySoloAmbient";

	--这个类别会禁止其他应用的音频回放(比如 iPod 应用的音频回放)。你可以使用 AVAudioPlayer 
	--的 prepareToPlay 和 play 方法,在你的应用中播放声音。主 UI 界面会照常工作。
	--这时,即使屏幕被锁定或者设备为静音模式,音频回放都会继续。
	AVAudioSessionCategoryPlayback = "AVAudioSessionCategoryPlayback";

	--这会停止其他应用的声音(比如 iPod)并让你的应用也不能初始化音频回放(比如 AVAudioPlayer)。
	--在这种模式下,你只能进行录音。使用这个类别,调用 AVAudioPlayer 的 prepareToPlay 会返回 YES,
	--但是调用 play 方法将返回 NO。主 UI 界面会照常工作。这时, 即使你的设备屏幕被用户锁定了,应用的录音仍会继续。
	AVAudioSessionCategoryRecord = "AVAudioSessionCategoryRecord";

	--这个类别允许你的应用中同时进行声音的播放和录制。当你的声音录制或播放开始后, 
	--其他应用的声音播放将会停止。主 UI 界面会照常工作。这时,即使屏幕被锁定或者设备为 
	--静音模式,音频回放和录制都会继续。
	AVAudioSessionCategoryPlayAndRecord = "AVAudioSessionCategoryPlayAndRecord";
	
	--这个类别用于应用中进行音频处理的情形,而不是音频回放或录制。
	--设置了这种模式, 你在应用中就不能播放和录制任何声音。调用 AVAPlayer 的 prepareToPlay 和 play 方法
	--都将 返回 NO。其他应用的音频回放,比如 iPod,也会在此模式下停止。
	AVAudioSessionCategoryAudioProcessing = "AVAudioSessionCategoryAudioProcessing";
}

--默认的avatar
GameVars.defaultAvatar = "101" 		--默认的avatar id

GameVars.openLevelTid = "#tid1902" -- (等级#1开启)


GameVars.configTextureType=".png"

GameVars.clickNumberTimes = 0    ---点击弹出显示logview  和发送报错到平台次数

-- 点击优先级
GameVars.clickPriorityMap = {
	guide =  5 ,	 -- 新手引导优先级是 5 小于等于5的优先级都必须在可点区域内
	overGuide =  10, --高于新手引导的优先级 ,暂时设置高些  是为了做一些预备
}

-- 各平台耗时警告阈值配置(秒)
GameVars.costTimeCfg = {
	windows = 0.5,
	mac = 0.3,
	android = 0.4,
	ios = 0.3,
}
