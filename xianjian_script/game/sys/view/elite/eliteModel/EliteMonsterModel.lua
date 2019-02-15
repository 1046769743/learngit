--
--Author:      zhuguangyuan
--DateTime:    2018-02-05 18:45:17
--Description: 精英关卡怪model
--


local EliteEventModel = require("game.sys.view.elite.eliteModel.EliteEventModel")
EliteMonsterModel = class("EliteMonsterModel",EliteEventModel)

function EliteMonsterModel:ctor( controler,gridModel,raidId)
	EliteMonsterModel.super.ctor(self,controler,gridModel)
	if raidId then
		self:setEventId(raidId)
	end
	self:initData()
end

function EliteMonsterModel:initData()
	-- 怪被绕过后透明度
	self.skipedOpacity = 100
	self.allTempView = nil
end

function EliteMonsterModel:onAfterOpenGrid()
	self:createEventView()
end

function EliteMonsterModel:registerEvent()
	EliteMonsterModel.super.registerEvent(self)
end

-- 每帧刷新
function EliteMonsterModel:dummyFrame()
	self:updateMonsterStatus()
	-- 检查怪绕过状态
	self:checkSkipStatus()
	self:checkAlertStatus()
end

-- 怪事件回应
function EliteMonsterModel:onEventResponse()
	if self.controler and self.controler.charModel:checkGiveItemSkill() then
		echo("主角将要释放道具....")
		return
	end
	dump(self:getEventId(),"当前怪物ID")
	-- 检查怪绕过状态
	self:checkSkipStatus()

	-- 如果与主角重叠了，不再弹出事件窗口
	if self.isOverlapWithChar then
		return
	end

	if not self:isValid() then
		echo("monster事件无效")
		return
	end
	local grid = self.grid

	local toHandleRaidId = WorldModel:getMaxUnLockEliteRaidId()
	if tonumber(self.raidId) > tonumber(toHandleRaidId) then
		local raidData = FuncChapter.getRaidDataByRaidId(toHandleRaidId)
		local monsterName = GameConfig.getLanguage(raidData.name)
		local tips = GameConfig.getLanguageWithSwap("#tid_elite_tips_1002",monsterName)
		WindowControler:showTips(tips)
		return
	end
	WindowControler:showWindow("EliteMonsterView",self.raidId)
end

-- 设置是否作弊模式
function EliteMonsterModel:setCheatStatus(isCheat)
	EliteMonsterModel.super.setCheatStatus(self,isCheat)
	if isCheat then
		if self.monsterAnim then
			self.monsterAnim:setVisible(false)
		end
	end
end

-- 创建怪view
function EliteMonsterModel:createEventView()
	local monsterId = self.monsterId 
	if not monsterId then
		return 
	end
	
	local sourceData = FuncTreasure.getSourceDataById(monsterId)
    local spine = FuncRes.getSpineViewBySourceId(monsterId,sex,true,sourceData) 
	local sizeOfSpine = spine:getBoundingBox()
	dump(sizeOfSpine, "立绘大小")

	local viewCtn = self.grid.viewCtn
	local x = self.grid.pos.x
	local y = self.grid.pos.y
	local z = 0

	local gridZOrder = self.grid:getZOrder()
	-- 创建怪动画，在格子的上层，怪的下层
	self.monsterAnim = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_yigejingshi", 
								viewCtn, true, GameVars.emptyFunc);
	self.monsterAnim:pos(x+1,y-3)
	self.monsterAnim:scale(0.9)
	self.monsterAnim:zorder(gridZOrder)
	self.monsterAnim:startPlay(true)
	-- 格子也创建了这个红色的格子动画,为了防止重叠动画对玩家造成误解,隐藏掉格子的动画
	self.grid:showAlertedView(false)

	-- 设置第几章第几节
	local panel_down = UIBaseDef:createPublicComponent( "UI_elite_layer","panel_down")
	panel_down:visible(true)
	self.chapterAndSection = panel_down.txt_xy 
	local section = FuncChapter.getSectionByRaidId(self.raidId)
	local storyId = FuncChapter.getStoryIdByRaidId(self.raidId)
	local chapter = FuncChapter.getChapterByStoryId(storyId)
	-- self.chapterAndSection:setString(chapter.."-"..section)

	local raidData = FuncChapter.getRaidDataByRaidId(self.raidId)
	local monsterName = GameConfig.getLanguage(raidData.name)
	local sectionStr = Tool:transformNumToChineseWord(raidData.section)
	local sectionDisplayName = GameConfig.getLanguageWithSwap("tid_elite_tips_1009",sectionStr)
	self.chapterAndSection:setString(sectionDisplayName..monsterName)
	self.chapterAndSection:anchor(0.5,0.5)
	self.chapterAndSection:setPositionY(self.chapterAndSection:getPositionY()-2)

	panel_down:pos(10,-16)
	-- 设置头顶的葫芦
	local panel_up = UIBaseDef:createPublicComponent( "UI_elite_layer","panel_up")
	panel_up:visible(true)
	self.huluMC = panel_up.mc_1
	local raidScore = WorldModel:getBattleStarByRaidId( self.raidId )
    self.huluMC:setVisible(true)
    if raidScore == WorldModel.stageScore.SCORE_ONE_STAR then
        self.huluMC:showFrame(1)
    elseif raidScore == WorldModel.stageScore.SCORE_TWO_STAR then
        self.huluMC:showFrame(2)
    elseif raidScore == WorldModel.stageScore.SCORE_THREE_STAR then
        self.huluMC:showFrame(3)
    elseif raidScore == WorldModel.stageScore.SCORE_LOCK then
        self.huluMC:showFrame(4)
    end
	panel_up:anchor(0.5,0.5)
	panel_up:scale(0.75)
	local height = self.controler.charSize.height
	-- if sizeOfSpine.height < height then
	-- 	height = sizeOfSpine.height
	-- end
	panel_up:pos(0,height*self.starScale)
	panel_down:setScale(self.starScale) 
	panel_up:setScale(self.starScale) 
	spine:addChild(panel_down)
	spine:addChild(panel_up)
	self.panel_up = panel_up

	-- 警戒怪不显示葫芦 显示警戒号
	-- 没打过的怪不显示葫芦 
	if self:isAlertMonster() then
		self.panel_up:setVisible(false)
	else
		local toHandleRaidId = WorldModel:getMaxUnLockEliteRaidId()
		if tonumber(self.raidId) > tonumber(toHandleRaidId) then
			self.panel_up:setVisible(false)
		else
			self.panel_up:setVisible(true)
		end
	end

	self:initView(viewCtn,spine,x,y,z,cc.size(self.controler.charSize.width,height)) --,self.controler.charSize
	self:setViewScale(self.monsterScale)

	local zorder = gridZOrder + 1
	self:setZOrder(zorder)

	-- 如果是警戒怪，在怪身上加点击事件(因玩家反馈警戒怪锁定时不知道要点击警戒怪脚底下) 
	-- by ZhangYanguang 2018.09.20 
	if self:isAlertMonster() then
		local nd = display.newNode()

		--[[
		-- 测试代码
		local color = color or cc.c4b(255,0,0,120)
	  	local layer = cc.LayerColor:create(color)
	    nd:addChild(layer)
	    nd:setTouchEnabled(true)
	    nd:setTouchSwallowEnabled(true)
	    layer:setContentSize(cc.size(self.mySize.width,self.mySize.height) )
	    ]]
	    nd:setContentSize(self.mySize)
	    nd:pos(-self.mySize.width / 2,0)
		
		-- nd:setContentSize(cc.size(figure,figure) )
		nd:addto(self.myView,1)
		nd:setTouchedFunc(c_func(self.onClickMonsterView,self),nil,true)
	end
end

function EliteMonsterModel:onClickMonsterView( )
	self:onEventResponse()
end

-- 是否与主角重叠在一个格子上
function EliteMonsterModel:isOverlapChar()
	return self.isOverlapWithChar
end

-- 设置事件ID
function EliteMonsterModel:setEventId(eventId)
	EliteMonsterModel.super.setEventId(self,eventId)
	self.raidId = eventId
	local monsterStr = FuncChapter.getRaidAttrByKey(self.raidId,"eliteMoster")
	local spineArr = string.split(monsterStr[1],",")
	self.monsterId = spineArr[1]
	if spineArr[2] then
		self.monsterScale = 0.8 * spineArr[2]
		self.starScale = 1/spineArr[2]
	else
		self.monsterScale = 0.8
		self.starScale = 1
	end

	local toHandleRaidId = WorldModel:getMaxUnLockEliteRaidId()
	if tonumber(self.raidId) == tonumber(toHandleRaidId) then
		if self.controler and self.controler.charModel then
			self.controler.charModel:setIsCharLock(self:isAlertMonster())
		end
	end
end

-- 1正常怪物,2沉睡,3警戒状态
function EliteMonsterModel:updateMonsterStatus()
	local status = self.gridInfo[FuncTowerMap.GRID_BIT.TYPE_PARAM]
	self.monsterStatus = tonumber(status)
	self:checkSleepAnim()
end

-- 播放怪死亡动画
function EliteMonsterModel:playDieAnim(callBack)
	local anim = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_guaiwuxiaoshi", 
		self.viewCtn, false, GameVars.emptyFunc);
	anim:pos(self.pos.x,self.pos.y)

	local zorder = self.grid:getZOrder() + 1
	anim:zorder(zorder)

	local animCallBack = function()
		anim:setVisible(false)
		if callBack then
			callBack()
		end
	end

	anim:registerFrameEventCallFunc(26,1,animCallBack)
	anim:startPlay(false,true)
end

-- 检查是否播放沉睡动画
function EliteMonsterModel:checkSleepAnim()
	if not self.grid:hasExplored() then
		return
	end

	if tonumber(self.monsterStatus) == FuncTowerMap.MONSTER_STATUS.SLEEP 
		or tonumber(self.monsterStatus) == FuncTowerMap.MONSTER_STATUS.SKIPED then
		if self.isOverlapWithChar then
			self:playSleepAnim(false)
		else
			self:playSleepAnim(true)
		end
	end
end

function EliteMonsterModel:isSleepMonster()
	return tonumber(self.monsterStatus) == FuncTowerMap.MONSTER_STATUS.SLEEP
		or tonumber(self.monsterStatus) == FuncTowerMap.MONSTER_STATUS.SKIPED
end

-- 播放沉睡动画
function EliteMonsterModel:playSleepAnim(visible)
	if not self.myView then
		return
	end

	if not self.sleeAnim then
		local anim = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_zzz", 
		self.viewCtn, false, GameVars.emptyFunc);
		anim:pos(self.pos.x+40,self.pos.y+self.mySize.height - 50)

		local zorder = self.grid:getZOrder() + 1
		anim:zorder(zorder)

		self.sleeAnim = anim
		self.sleeAnim:startPlay(true)
	end

	self.sleeAnim:setVisible(visible)
end

-- 是否是警戒怪
-- 精英关卡的怪都是锁定怪,通关后复盘再翻开则不是警戒怪
function EliteMonsterModel:isAlertMonster()
	if not self.raidId then
		return false 
	end
	if WorldModel:isPassRaid(self.raidId) then
		return false
	else
		local toHandleRaidId = WorldModel:getMaxUnLockEliteRaidId()
		if tonumber(self.raidId) > tonumber(toHandleRaidId) then
			return false
		end

		return true
	end
end

-- 判断怪是否被绕过
function EliteMonsterModel:checkSkipStatus(event)
	-- if self.monsterStatus == FuncTowerMap.MONSTER_STATUS.SKIPED then
	if self:isSleepMonster() then
		local charModel = self.controler.charModel
		local charGrid = charModel:getGridModel()

		if self.myView and charGrid then
			-- 主角走到了怪的身上
			if charGrid.xIdx == self.grid.xIdx and charGrid.yIdx == self.grid.yIdx then
				self.myView:opacity(self.skipedOpacity)
				self.isOverlapWithChar = true
			else
				self.myView:opacity(255)
				self.isOverlapWithChar = false
			end
		end
	end
end

-- 检查怪是否被偷状态
function EliteMonsterModel:checkStealedStatus()
	if self.controler.isSelectTargetEvent and self.isPreStealed then
		self:updateStealedAnim()
	else
		if self.steadAnim then
			self.steadAnim:setVisible(false)
		end
	end
end

-- 检查警戒怪状态
function EliteMonsterModel:checkAlertStatus()
	self.grid:showAlertedView(false)
	if self:isAlertMonster() then
		self:playAlertAnim(true)
	else
		self:playAlertAnim(false)
	end
end

-- 更新警戒动画
function EliteMonsterModel:playAlertAnim(visible)
	if not self.myView then
		return
	end

	if not  visible and not self.alertAnim then
		return
	end

	if not self.alertAnim then
		self.alertAnim = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_gantaohao", 
			self.viewCtn, true, GameVars.emptyFunc);
		local zorder = self.grid:getZOrder()
		self.alertAnim:zorder(zorder+10)
		self.alertAnim:pos(self.pos.x+30,self.pos.y+self.mySize.height*7/10)
		self.alertAnim:startPlay(true)
	end

	if self.alertAnim then
		self.alertAnim:setVisible(visible)
	end
	-- self.alertAnim:setVisible(true)
end

-- 更新被偷动画
function EliteMonsterModel:updateStealedAnim()
	if not self.steadAnim then
		self.steadAnim = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_jihuo", 
			self.viewCtn, true, GameVars.emptyFunc);
		local zorder = self.grid:getZOrder()
		self.steadAnim:zorder(zorder)
		self.steadAnim:pos(self.pos.x,self.pos.y)

		self.steadAnim:startPlay(true)
	end

	self.steadAnim:setVisible(true)
end

-- 设置准备被偷
function EliteMonsterModel:setPreStealed(preStealed)
	self.isPreStealed = preStealed
end

-- 获取怪的类型
function EliteMonsterModel:getMonsterType()
	return 1 --self.monsterType
end

-- 获取怪的星，1表示野怪 2表示星怪
function EliteMonsterModel:getMonsterStar()
	return 1 --self.monsterStar
end

-- 是否是星怪
function EliteMonsterModel:isStarMonster()
	-- local monsterData = FuncTower.getMonsterData(self.eventId)
	-- return monsterData.star == FuncTowerMap.MONSTER_STAR_TYPE.STAR
	return false
end

-- 获取怪状态
function EliteMonsterModel:getMonsterStatus()
	return self.monsterStatus
end

function EliteMonsterModel:deleteMyView()
	self.allTempView = nil
	if self.monsterAnim then
		self.monsterAnim:removeFromParent()
		self.monsterAnim = nil
	end
	EliteMonsterModel.super.deleteMyView(self)
end

function EliteMonsterModel:deleteMe()
	if self.monsterAnim then
		self.monsterAnim:removeFromParent()
	end

	if self.sleeAnim then
		self.sleeAnim:removeFromParent()
	end

	if self.alertAnim then
		self.alertAnim:removeFromParent()
	end

	EliteMonsterModel.super.deleteMe(self)
end

-- 获取上次挑战该怪的选择的星级难度
function EliteMonsterModel:getLastStar()
	local extInfo = self.gridInfo.ext
	local star = 0
	if extInfo then
		star = extInfo.star
	end

	return star
end

return EliteMonsterModel
