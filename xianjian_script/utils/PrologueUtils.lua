 --
-- User: ZhangYanGuang
-- Date: 17-02-10
-- 序章工具类
--

PrologueUtils = PrologueUtils or {}

-- 进入序章消息
PrologueUtils.EVENT_ENTER_PROLOGUE = "PrologueUtils.EVENT_ENTER_PROLOGUE"

PrologueUtils.tempMustPrologueFlag = "tempMustPrologueFlag3"

function PrologueUtils:initRes()
	self:initCommonRes()
	self:initData()
	self:registerEvent()
end

function PrologueUtils:initCommonRes()
	GameLuaLoader:loadGameSysFuncs()
    GameLuaLoader:loadGameBattleInit()
end

function PrologueUtils:registerEvent()
	-- PVE 战斗结束
	EventControler:addEventListener(TutorialEvent.TUTORIAL_FINISH_PROLOGUE_BATTLE,self.onBattleClose,self)
	-- 创角界面关闭
	EventControler:addEventListener(LoginEvent.LOGINEVENT_CLOSE_SELECT_ROLE_VIEW,self.onSelectRoleSuccess,self)
	-- 监听序章第一场战斗loading进度
	EventControler:addEventListener(LoadEvent.LOADEVENT_BATTLELOADCOMP, self.onPrologueBattleLoadComp, self)
end

function PrologueUtils:initData()
    -- 如果本地已选角，设置UserMode avatar
    local roleId = LoginControler:getLocalRoleId()
    if roleId ~= nil and roleId ~= "" then
    	UserModel:setAvatar(roleId)
    end

    -- 序章storyID
    self.prologueStoryId = WorldModel.prologueStoryId

    -- 序章第一节RaidID
    self.firstBattleId = "10001"
    -- 第二个战斗剧情ID(第1个是男 第2个是女)
    self.afterBattlePlotId = {100003,100002}

    self._isInPrologue = false;
end

--[[
	获取战斗后剧情ID
]]
function PrologueUtils:getAfterBattlePlotId()
	return self.afterBattlePlotId[UserModel:sex()]
end

-- 执行序章逻辑
function PrologueUtils:doPrologueLogic()
	self:initRes()
	self:setIsInPrologue(true)

	TutorialManager:checkToOpenTurorial()
	
	-- 没有通关第一场战斗
	if self:showFirstBattle() then
		echo("\n\n-----------------序章开始第一场战斗-----------------")
		-- 如果战斗已经预加载
		if self.hasLoadFirstBattle then
			-- 恢复战斗
			BattleControler:resumePrologueBattle()
		else
			-- isPreLoading 设置为true，战斗加载时不会隐藏掉非战斗UI
			-- 开始战斗
			self:enterPrologueGame(self.firstBattleId,true)
		end
	else
		echo("选角逻辑.......")
		-- 说明选角没有完成(选角完成时序章结束的标记)
		local callBack = function()
			WindowControler:showSelectRoleView()		
		end

		local loginLoadingView = WindowControler:getWindow("LoginLoadingView")
		if loginLoadingView then
			callBack()
			loginLoadingView:doCharMoveDisappearAnim()
		else
			callBack()
		end
	end
end

-- 序章第一场战斗资源加载完成
function PrologueUtils:onPrologueBattleLoadComp()
	echo("LoginLoadingView:onPrologueBattleLoadComp")
	echo("序章第一场战斗加载完成")

	local callBack = function()
		-- 恢复战斗
		BattleControler:resumePrologueBattle()
	end

	local loginLoadingView = WindowControler:getWindow("LoginLoadingView")
	if loginLoadingView then
		loginLoadingView:doCharMoveDisappearAnim(callBack)
	else
		callBack()
	end
end

function PrologueUtils:isFirstRaidId(raidId)
	return  self:showPrologue() and raidId and self.firstBattleId == tostring(raidId)
end

-- 选角完成
function PrologueUtils:onSelectRoleSuccess()
	echo("序章选角完成")
	-- 播放第二个战后剧情
	self:playAfterBattleAnim2()
end

-- 播放第二个战后剧情(战斗后紧跟的剧情动画是第一个战后剧情)
function PrologueUtils:playAfterBattleAnim2()
	local callBack = function()
		echo("第2个战后剧情回调")
	    -- 进入主城
		self:goHomeMainView()
    end
    echo("播放第2个战后剧情")
    local plotId = self:getAfterBattlePlotId()
    local dialog = AnimDialogControl:showPlotDialog(plotId, c_func(callBack),nil,nil,nil,true)
end

-- 展示剧情对话
function PrologueUtils:showPlotDialog(plotId, callBack)
	PlotDialogControl:showPlotDialog(plotId, callBack)
    PlotDialogControl:setSkipButtonVisbale(true);
end

function PrologueUtils:showFirstBattle()
	-- return tonumber(PrologueUtils:getValue("prologueFirstBattle",0)) == 0
	local value = LS:prv():get("prologueFirstBattle",0)
	return value == 0
end

-- 战斗结算关闭后逻辑
function PrologueUtils:onBattleClose()
	if not self:showPrologue() then
		return
	end

	local curBattleRaidId = self:getBattleRaidId()

    echo("序章战斗完成,curBattleRaidId=",curBattleRaidId,self.firstBattleId)
    -- 第一场战斗结束且战后剧情播放完毕(如果有)
	if curBattleRaidId == self.firstBattleId then
		-- 保存战斗进度
		-- self:setValue("prologueFirstBattle",1)
		LS:prv():set("prologueFirstBattle",1)

		-- 开启引导
		EventControler:dispatchEvent(TutorialEvent.TUTORIALEVENT_PROLOGUE_TRIGGER)
		-- 自动开始选角逻辑
		WindowControler:showSelectRoleView()
	else
		echoTag("tag_prologue",8,"疑似序章战斗配置错误")
	end
end

--[[
	进入主城
]]
function PrologueUtils:goHomeMainView()
	self:setIsInPrologue(false)
	-- 进入主城
	LoginControler:enterGameHomeView()
	self:saveWhiteFilterFiles()
	self:savePrologueLoadingStatus()
end


-- 进入创角界面
function PrologueUtils:showSelectRoleView()
	WindowControler:showWindow("SelectRoleView",LoginControler.SELECT_ROLE_TYPE.GUILD)
end

--是否在序章中
function PrologueUtils:isInPrologue()
	return self._isInPrologue;
end

function PrologueUtils:setIsInPrologue(isInPrologue)
	self._isInPrologue = isInPrologue;
end

function PrologueUtils:setValue(key,value)
	LS:pub():set(key,value)
end

function PrologueUtils:getValue(key,defaultValue)
	local value = LS:pub():get(key,defaultValue)
	return value
end

function PrologueUtils:setBattleRaidId(raidId)
	-- self.curBattleRaidId = raidId
	self:setValue("battleRaidId",raidId)
end

function PrologueUtils:getBattleRaidId()
	-- return self.curBattleRaidId
	local battleRaidId = self:getValue("battleRaidId")
	if battleRaidId == nil or battleRaidId == "" then
		return nil
	end

	return battleRaidId
end

function PrologueUtils:showPrologueMainView()
	local ui = WindowControler:showWindow("WorldMainView");
	return ui
end

function PrologueUtils:checkSkipPrologue()
	return DEBUG_SKIP_PROLOGURE
end

-- 是否进入序章
function PrologueUtils:showPrologue()
	if DEBUG_SKIP_PROLOGURE then
		return false
	end

	if self:isInPrologue() then
		return true
	else
		return false
	end
end

-- 序章每一场战斗开始的时候需要调用该方法(战斗代码调用)
function PrologueUtils:setPrologueBattleRaidId(raidId)
	echo("setPrologueBattleRaidId raidId=",raidId)
	self:setBattleRaidId(raidId)
end

-- 开始序章战斗
function PrologueUtils:enterPrologueGame(raidId,isPreLoading)
	echo("enterPrologueGame raidId=",raidId)
	BattleControler:startBattleFormWorld(raidId,isPreLoading)
end

-- 废弃方法
-- 重置序章
function PrologueUtils:resetPrologue(skipUploadServer)
	if true then
		WindowControler:showTips("不支持重置序章")
		return
	end
end

--[[
	检查是否显示序章loading
	1.因调用该接口时还未登录区服，所以只能根据选择的区服ID，根据本地保存数据判断
	2.更换设备后登录区服(已经走过序章的)，依然会展示一次序章loading
]]
function PrologueUtils:checkShowPrologueLoading()
	local secId = LoginControler:getServerId()
	local loadingStatus = self:getValue(secId,"0")
	return loadingStatus == "0"
end

--[[
	保存序章loading状态
]]
function PrologueUtils:savePrologueLoadingStatus()
	local secId = LoginControler:getServerId()
	self:setValue(secId,"1")
end

--[[
	是否展示序章衔接特效
]]
function PrologueUtils:showPrologueJoinAnim()
	if IS_CLOSE_TURORIAL then
		return false
	end

	-- 写死第一关
	-- if tonumber(UserExtModel:getMainStageId()) > 0 then
	if TutorialManager.getInstance():isFinishFirstStep() then
		return false
	end

	return true
end

--[[
	获取序章衔接进度
]]
function PrologueUtils:getPrologueJoinStage()
	if not PrologueUtils:showPrologueJoinAnim() then
		return 0
	end

	echo("UserExtModel:getMainStageId()===",UserExtModel:getMainStageId())

	-- 战斗完成，整个衔接完成，返回2
	if UserExtModel:getMainStageId() == "10101" then
		return 2
	-- 起名完成，返回1
	-- elseif UserModel:isNameInited() then
	-- 	return 1
	else
		return 0
	end

	-- return 0
end

--保存白名单文件
function PrologueUtils:saveWhiteFilterFiles(  )
	if not DEBUG_CREATE_WHILTE_LIST then
		return
	end

	--这里加一个判断 把序章需要的纹理全部保存到本地某个目录
	if device.platform ~= "windows" and device.platform ~= "mac" then
		return
	end
	local logPath = "../Assets/filter"
	if device.platform == "mac" then
		logPath = "../../../../../svn/Assets/filter"
	end
	if not cc.FileUtils:getInstance():isDirectoryExist(logPath) then 
		cc.FileUtils:getInstance():createDirectory(logPath)
	end
	local targetFileName = logPath.."/whitelist_ignore_androids.txt"
	local targetFile = io.open(targetFileName,"w")

    if targetFile == nil then
        return
    end

    --这里要强制缓存所有的worldMap 否则会出现适配问题
    local arr = TextureControler.textureNameArr
    -- 男女头像
    table.insert(arr, "icon/head/face_10001.png")
    table.insert(arr, "icon/head/face_10002.png")
    -- 男女法宝资源
    table.insert(arr, "anim/spine/*treasure_a1*")
    table.insert(arr, "anim/spine/*treasure_b1*")
    --主角男女素颜法宝和特效
    table.insert(arr, "anim/spine/*treasure*404*")
    -- 六界资源
    table.insert(arr, "world/worldMap_*")
    table.insert(arr, "world/mapTextureConfig*")
    table.insert(arr, "anim/spine/world_*")
    -- 剧情战斗
    table.insert(arr, "anim/spine/plot_10000_*")
    table.insert(arr, "anim/spine/plot_10001_*")
    table.insert(arr, "anim/spine/plot_10002_*")
    -- 通用资源
    table.insert(arr, "ui/UI_login_select_way.png")
    table.insert(arr, "ui/UI_login_select_way.plist")
    table.insert(arr, "ui/UI_comp_tc2.png")
    table.insert(arr, "ui/UI_comp_tc2.plist")
    -- UI_comp_tc2用到的公用图片
    table.insert(arr, "globalPngs/global_bg_tcbiaoti.png")

    -- Shaders
    table.insert(arr,"Shaders/*.*")
    
    -- TODO文件夹临时解决方案
    table.insert(arr, "viewConfig/*.*")
    table.insert(arr, "viewConfig/spineEvent/*.*")

    local str = table.concat(TextureControler.textureNameArr,"\n")

    targetFile:write(str.."\n")
    targetFile:close()
end
