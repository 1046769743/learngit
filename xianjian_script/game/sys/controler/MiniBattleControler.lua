--[[
	Author: lcy
	Date: 2018.4.11
	精简战斗控制器（为了处理不进战斗可以调用战斗内各种内容）因为会替换BattleControler所以不能同时共存
	注意，使用完后一定要销毁
]]

local MiniBattleControler = class("MiniBattleControler", BattleControler)

local Instance = nil -- 保证不会同时创建两个最终丢失对真正BattleControler的控制
MiniBattleControler._battleRoot = nil

function MiniBattleControler.getInstance()
	if not Instance then
		Instance = MiniBattleControler.new()
	end

	return Instance
end

function MiniBattleControler:ctor( ... )
	-- body
end

-- 显示
function MiniBattleControler:showMiniBattle(showId)
	local root = WindowControler:getCurrScene():getBattleRoot()
	if not root then
		echoError("MiniBattleControler 没有传入root")
		return
	end

	-- 持有原BattleControler
	self.__originBattleControler = BattleControler

	-- 替换全局变量
	BattleControler = self

	self._battleRoot = root

	-- battleInfo是否也应该在这里处理
	local battleInfo = self:createBattleInfo(showId)
	self:startBattleInfo(battleInfo)
end

-- 使用完后一定要销毁
function MiniBattleControler:deleteMe()
	-- 换回全局变量
	BattleControler = self.__originBattleControler

	-- 做其他的销毁内容

end

-- 在这里初始化一些其他东西
function MiniBattleControler:init(...)
	self.battleLabel = GameVars.battleLabels.miniBattle
end

-- 重写开始游戏（要不要提前处理一下资源加载？）
function MiniBattleControler:startBattleInfo(battleInfo)
	self:setCampData(Fight.gameMode_pve, battleInfo)
end

function MiniBattleControler:setCampData(mode, battleInfo)
	if not battleInfo.restartIdx then
		battleInfo.restartIdx = 0
	end

	if not battleInfo.gameMode then
		battleInfo.gameMode = mode
	end
	self.__gameMode = battleInfo.gameMode
	self._battleInfo = battleInfo

	self._battleInfo.userRid = "MiniBattle"
	
	BattleRandomControl.setOneRandomYinzi(battleInfo.randomSeed,10)

	-- 创建gameControler控制器（root是最终显示战斗场景用的容器）
	-- local scene = WindowControler:getCurrScene()
	-- local battleRoot = scene:getBattleRoot()
	-- scene:showBattleRoot()

	self:createGameControler(self._battleRoot)

	self:setBattleLabel(battleInfo)

	self:setLevelId(battleInfo.levelId)

	self:onEnterBattle()

	self:checkTeam(mode,battleInfo)

	-- 是否销毁的同时加载资源呢
	local onClearCompelet = function (  )
        -- echo(TimeControler:getTempTime()- taa1,"____销毁ui纹理耗时------")
        self.gameControler:checkLoadTexture()
    end

    WindowControler:onEnterBattle(onClearCompelet)
	-- self.gameControler:checkLoadTexture()
end

function MiniBattleControler:createGameControler(root)
	-- 这里是否需要一个miniGameControler？
	self.gameControler = MiniGameControler.new(root)
	self.gameControler.gameMode = self.__gameMode

	--初始化统计（需要初始化，StatisticsControler涉及到了伤害的逻辑和伤害显示->不太好）
	StatisticsControler:init(self.gameControler)
end

function MiniBattleControler:createBattleInfo(showId)
	local battleInfo = {}
	battleInfo.battleUsers = { }
	local defaultHero = table.copy(ObjectCommon:getServerData())
	for i = 1, #defaultHero do
		defaultHero[i]._id = "MiniBattle"
	    table.insert(battleInfo.battleUsers, defaultHero[i])
	end
	battleInfo.levelId =  showId or "t10101"
	battleInfo.showId = showId or "t10101"
	battleInfo.userRid = "MiniBattle"
	-- 需要?
	battleInfo.isDebug = true 

	-- 随机种子应该固定？
	battleInfo.randomSeed = 100
	battleInfo.battleLabel = GameVars.battleLabels.miniBattle

	return battleInfo
end

function MiniBattleControler:checkTeam(mode, battleInfo)
	-- 关卡
	local levelObj = MiniObjectLevel.new( self.__levelHid,mode,battleInfo )
	levelObj.randomSeed = battleInfo.randomSeed

	--计算掉落
	if battleInfo.inBattleDrop then 
	    levelObj.dropArr = self:checkBattleDrop(battleInfo.inBattleDrop)
	end

	-- 因为levelObj 加密不了,所有直接赋值过去
	self.gameControler:initGameData(levelObj)
end

function MiniBattleControler:setLevelId(hid)
	self.__levelHid = hid

	self:setLoadingId(hid,1)
end

-- 销毁
function MiniBattleControler:exitMiniBattle()
	if self.gameControler then
	    self.gameControler:deleteMe()
	    self.gameControler = nil
	end

	self:deleteMe()

	self._battleRoot = nil
end

-- override
function MiniBattleControler:onExitBattle()
	ViewSpine:disableCtor(false)

	self.__resControler = nil
	self:resetTeamCamp()
	
	if not self.gameControler then
        return
    end

    collectgarbage("collect")

    WindowControler:clearUnusedTexture( true )

    local function onLoadingEndFunc()
    	self:exitMiniBattle()
    	--ui复原
    	WindowControler:onResumeComplete()

    	local scene = WindowControler:getCurrScene()
    	scene:showRoot()    	
    end
    local processActions = WindowControler:onExitBattle()
    if #processActions ==0 then
        onLoadingEndFunc()
    else
    	local gameType = FuncLoadingNew.getGameTypeByBattleLabel(self:getBattleLabel(), self._battleInfo.levelId)
	    local loadingNumber = NewLoadingControler:getLoadingNumberByTypeAndLevelId(gameType, self._battleInfo.withStory, self._battleInfo.levelId)
	    WindowControler:showTopWindow("CompNewLoading", loadingNumber, {percent=10,frame =10}, processActions, onLoadingEndFunc, true)
    end
end

---------- 重写覆盖BattleControler 方法 以和battle断开关系 ----------
function MiniBattleControler:isInBattle()
	return false
end
function MiniBattleControler:isInMiniBattle()
	return true
end
---------- 重写覆盖BattleControler 方法 以和battle断开关系 ----------

return MiniBattleControler