--[[
	Author: caocheng
	Date:2017-07-29
	Description: 锁妖塔选择Boss难度界面
]]

local TowerMonsterView = class("TowerMonsterView", UIBase);

-- poisonId为从毒格子进战斗时的毒id
function TowerMonsterView:ctor(winName,monsterID,monsterPos,monsterType,poisonId,progressNum)
    TowerMonsterView.super.ctor(self, winName)
    self.monsterNowType = monsterType
    self.monster = monsterID or "1001"
    self.monsterParam = monsterPos
    self.poisonId = poisonId
    self.bloodProgressNum = progressNum
end

function TowerMonsterView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initView()
	self:updateUI()
end 

function TowerMonsterView:registerEvent()
	TowerMonsterView.super.registerEvent(self);
	self:registClickClose("out")
	self.UI_1.btn_1:setTap(c_func(self.press_btn_close,self))
	EventControler:addEventListener(TowerEvent.TOWEREVENT_ENTER_BATTLE, self.press_btn_close, self)
end

function TowerMonsterView:initData()
	self.curFloorConfigData = FuncTower.getOneFloorData( TowerMainModel:getCurrentFloor() )
	self.monsterData = FuncTower.getMonsterData(self.monster)
	self.hasGotReward = TowerMainModel:isOneOffMonsterRewardHaveGot( self.monster )-- 是否已经领取首通奖励
end

function TowerMonsterView:initView()
	self:initScrollCfg()

	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_046"))
	-- if not self.isShow then
		if self.monsterData.star == FuncTowerMap.MONSTER_STAR_TYPE.STAR then
			self.mc_1:showFrame(1)
			self:createChooseDifficult()
		else
			self.mc_1:showFrame(2)
			self:createBossDifficult()
		end
	-- else
	-- 	self.mc_1:showFrame(2)
	-- 	self:createBossDifficult()
	-- end	
	if self.monsterData.type == FuncTowerMap.MONSTER_TYPE.BOSS then
		self.mc_1.currentView.btn_guize:visible(true)
	else
		self.mc_1.currentView.btn_guize:visible(false)
	end

	-- 怪立绘
	local monsterSpineId = self.monsterData.spineId
	local sourceCfg = FuncTreasure.getSourceDataById(monsterSpineId)
	local spineName = sourceCfg.spine
	local monsterView = ViewSpine.new(spineName,{},spineName):addto(self.mc_1.currentView.ctn_1)
	local npcAnimLabel = sourceCfg.stand
	monsterView:playLabel(npcAnimLabel,true)

	-- 弹出怪详情说明view
	local nd = display.newNode()
	local size = cc.size(150,150)
    nd:setContentSize(size)
    nd:pos(-size.width/2,0)
	nd:addto(self.mc_1.currentView.ctn_1,10)
	nd:setTouchSwallowEnabled(true)
	nd:setTouchedFunc(function()
        WindowControler:showWindow("TowerMonsterDescriptionView",self.monsterData)
	end,nil,true)
	self.mc_1.currentView.txt_name:setString(GameConfig.getLanguage(self.monsterData.name))

	-- 怪属性说明
	if self.monsterData.feature1 and self.monsterData.feature2 then
		echo("_______ 两个属性 ___________")
		self.mc_texing2:showFrame(2)
		local contentView = self.mc_texing2:getCurFrameView()
		contentView.panel_gg.txt_1:setString(GameConfig.getLanguage(self.monsterData.feature1))
		contentView.panel_gg2.txt_1:setString(GameConfig.getLanguage(self.monsterData.feature2))
	elseif self.monsterData.feature1 then
		echo("_______ 一个属性 ___________")

		self.mc_texing2:showFrame(1)
		local contentView = self.mc_texing2:getCurFrameView()
		contentView.panel_gg.txt_1:setString(GameConfig.getLanguage(self.monsterData.feature1))
	else
		echo("_______ 没有属性 ___________")

		self.mc_texing2:visible(false)
	end

	-- if self.monsterData.feature1 then
	-- 	self.panel_gg:visible(true)
	-- 	self.panel_gg.txt_1:setString(GameConfig.getLanguage(self.monsterData.feature1))
	-- else
	-- 	self.panel_gg:visible(false)
	-- end
	-- if self.monsterData.feature2 then
	-- 	self.panel_gg2:visible(true)
	-- 	self.panel_gg2.txt_1:setString(GameConfig.getLanguage(self.monsterData.feature2))
	-- else
	-- 	self.panel_gg2:visible(false)
	-- end

	-- 怪血量
	local monsterHpData = TowerMainModel:getMonsterInfo(self.monster)
	local monsterHpNum = 10000
	if not empty(monsterHpData) and monsterHpData.levelHpPercent then
		monsterHpNum = monsterHpData.levelHpPercent
	end	
	if self.bloodProgressNum then
		monsterHpNum = self.bloodProgressNum
	end
	-- local extInfo = self.gridInfo.ext
	-- if extInfo and extInfo.hpPercentReduce then
	-- 	monsterHpNum = monsterHpNum - extInfo.hpPercentReduce 
	-- end
	local p = monsterHpNum/100
	if p > 1 then
		p = math.floor(p)
	else
		p = string.format("%.2f",p)
	end
	self.panel_hp.txt_1:setString(p.."%")
	self.panel_hp.progress_jindu:setPercent(monsterHpNum/100)

	-- 更新buff列表
	local listParams = self:buildItemScrollParams()
	self.panel_goods.scroll_1:styleFill(listParams)
	self.panel_goods.scroll_1:clearCacheView()
	-- self.panel_goods.scroll_1:keepDragBar()
end

function TowerMonsterView:initScrollCfg()
	-- 章信息及节列表滚动条
	local mcItemBuff = self.panel_goods.mc_buff
	mcItemBuff:setVisible(false)

	local createTempBuffItemViewFunc = function(itemData)
		local mcItemView = UIBaseDef:cloneOneView(mcItemBuff)
		if itemData.type == 1 then
			mcItemView:showFrame(1)
			local itemId = itemData.id
			local tempBuffUI = mcItemView:getCurFrameView().panel_1
			local tempText = TowerMainModel:getMonsterBuffDesByItemId(itemId)
			tempBuffUI.txt_1:setString(tempText)

			local teamBuffData = FuncTower.getGoodsData(itemId)
			local spritePath = FuncRes.iconTowerEvent(teamBuffData.img)
			local buffSp = display.newSprite(spritePath)
			buffSp:setScale(0.4)
			tempBuffUI.ctn_1:addChild(buffSp)
		else
			mcItemView:showFrame(2)
			local key = itemData.key
			local tempText = FuncBattleBase.getAttributeName(key).." -"
			-- 属性万分比
			if itemData.mode == 2 then
				tempText = tempText..(itemData.value/100).."%"
			end
			local tempBuffUI = mcItemView:getCurFrameView()
			tempBuffUI.txt_1:setString(tempText)
		end

		return mcItemView
	end

	local createDeBuffItemViewFunc = function(itemData)
		local mcItemView = UIBaseDef:cloneOneView(mcItemBuff)
		mcItemView:showFrame(2)

		return mcItemView
	end

	-- 临时buff
	self.buffItemView = {
		data = nil,
        createFunc = createTempBuffItemViewFunc,
        itemRect = {x=0,y=-47,width = 303,height = 31},
        perNums = 2,
        offsetX = 10,
        offsetY = 18,
        widthGap = -130,
        heightGap = 5,
        perFrame = 1,
	}
end

-- 动态构建滚动配置
function TowerMonsterView:buildItemScrollParams()
	local listParams = {}
	local listData = {}

	-- 本次战斗附加属性
	local tempBuffListData = TowerMainModel:getCurrentBuffTemps() or {}

	local tempBuffData = {}
	if tempBuffListData then
		for k,v in pairs(tempBuffListData) do
			local data = {}
			data.id = k
			-- 构造类型
			data.type = 1
			tempBuffData[#tempBuffData+1] = data
		end
	end

	local debuffData = {}
	if self.poisonId then
		local poisionData = FuncTower.getMapBuffData(self.poisonId)
		debuffData = poisionData.attr
	end

	if debuffData and #debuffData > 0 then
		for i=1,#debuffData do
			-- 构造类型
			debuffData[i].type = 2
		end
	end

	listData = array.merge(tempBuffData,debuffData)
	-- dump(listData,"listData-----------")
	self.buffItemView.data = listData
	listParams[#listParams+1] = self.buffItemView

	return listParams
end


function TowerMonsterView:updateUI()
	
end


function TowerMonsterView:setEnergyNum(mcView,num)
	local valueTable = number.split(num)
    local len = table.length(valueTable)
    --不能高于2
    if len > 2 then 
        return
    end 
    mcView:showFrame(len);

    local offsetx = 0
    for k, v in ipairs(valueTable) do
        local mcs = mcView:getCurFrameView()
        local childMc = mcs["mc_" .. tostring(k)]
        childMc:showFrame(v + 1)
    end
end

-- 创建星级怪难度栏
function TowerMonsterView:createChooseDifficult()
	self.mc_1.currentView.panel_1:visible(false)
	--[[
	-- 更新怒气值
	local curEnergy = TowerMainModel:getCurEnergy()
    local maxEnergy = TowerMainModel:getMaxEnergy()
    self:setEnergyNum(self.mc_1.currentView.panel_bao.panel_nuqizhi.mc_1,curEnergy)
    self:setEnergyNum(self.mc_1.currentView.panel_bao.panel_nuqizhi.mc_2,maxEnergy)
    if curEnergy < 10 then
    	if not self.offsetX then
    		self.offsetX = self.mc_1.currentView.panel_bao.panel_nuqizhi:getPositionX()
    	end
    	self.mc_1.currentView.panel_bao.panel_nuqizhi:setPositionX(self.offsetX - 30)
    end
    ]]
    -- 2018.08.13 怒气值移到布阵中
    self.mc_1.currentView.panel_bao:setVisible(false)

	-- -- 弹出怪属性说明view
	-- self.mc_1.currentView.btn_guize:setTap(function()
 --        WindowControler:showWindow("TowerMonsterDescriptionView",self.monsterData)
	-- end)
	-- self.mc_1.currentView.txt_name:setString(GameConfig.getLanguage(self.monsterData.name))
	-- 首通奖励 三测加回
	-- self.mc_1.currentView.panel_jiangli.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_086"))
	local tempShowRewardNum = 0
	-- 根据怪物类型获取相应奖励str
	local rewardStr = self.curFloorConfigData.monsterStarReward[tonumber(self.monsterData.type)]
	-- 区分简单普通困难等级奖励
	local mainRewardArr = string.split(rewardStr,",")
	for k,rewardId in ipairs(mainRewardArr) do
    	local monsterReward = FuncItem.getRewardArrayByCfgData({FuncDataResource.RES_TYPE.REWARD..","..rewardId})
		local rewardUI = self.mc_1.currentView.panel_jiangli["UI_"..k]
		local rewardArr = string.split(monsterReward[1],",")
		local rewardType = rewardArr[1];
		local rewardNum = rewardArr[table.length(rewardArr)];
		local rewardId = rewardArr[table.length(rewardArr) - 1];
		rewardUI:setResItemData({reward = monsterReward[1]})
		FuncCommUI.regesitShowResView(rewardUI,
        	rewardType,rewardNum,rewardId,monsterReward[1],true,true)
		rewardUI:showResItemNum(true)
		tempShowRewardNum = tempShowRewardNum +1

		local yinzhang = self.mc_1.currentView.panel_jiangli["panel_"..k]
		if k <= tonumber(self.hasGotReward or 0) then
			yinzhang:visible(true)
		else
			yinzhang:visible(false)
		end
	end
	if tempShowRewardNum <= 3 then
		local tempRewardNum = tempShowRewardNum +1
		for i =tempRewardNum,3 do
		 	local rewardUI = self.mc_1.currentView.panel_jiangli["UI_"..i]
		 	rewardUI:visible(false)

		 	local yinzhang = self.mc_1.currentView.panel_jiangli["panel_"..i]
		 	yinzhang:visible(false)
		end 
	end

	if tonumber(self.monsterNowType) == FuncTowerMap.MONSTER_STATUS.NORMAL then
		self.mc_1.currentView.btn_1:visible(false)
	elseif (tonumber(self.monsterNowType) == FuncTowerMap.MONSTER_STATUS.SLEEP) 
		or (tonumber(self.monsterNowType) == FuncTowerMap.MONSTER_STATUS.SKIPED) then
		self.mc_1.currentView.btn_1:setTap(c_func(self.bypassMonster,self))
	elseif tonumber(self.monsterNowType) == FuncTowerMap.MONSTER_STATUS.ALERT then
		self.mc_1.currentView.btn_1:visible(false)
	end

	-- 三测新需求 
	-- 显示相关联的其他被击杀怪对本怪产生的影响
	local killList = TowerMainModel:getKillMonsters()
	for _killedMonsterId,_killedNum in pairs(killList) do
		local killedMonsterData = FuncTower.getMonsterData(_killedMonsterId)
		if killedMonsterData.killMonsterId then
			for i,_monsterId in pairs(killedMonsterData.killMonsterId) do
				if _monsterId == self.monster then
					self.reduceValue = killedMonsterData.reduce 
				end
			end	
		end
	end

	local recommendPower = table.deepCopy(self.monsterData.power)
	-- 跟层有关的怪难度修正系数
	for i,v in pairs(recommendPower) do
		recommendPower[i] = recommendPower[i]*(self.curFloorConfigData.powerRevise or 100)/100
	end
	local panelDifficult = self.mc_1.currentView.panel_1
	for i =1,3 do
      	local nowView = UIBaseDef:cloneOneView(panelDifficult)
      	nowView.mc_1:showFrame(i)
      	nowView:setPositionY(-230-105*(i-1))
      	nowView:visible(true)
      	self.mc_1.currentView:addChild(nowView)
      	nowView.txt_power:setString(recommendPower[i])
      	nowView.txt_power2:visible(false)
      	if (tonumber(self.monsterNowType) == FuncTowerMap.MONSTER_STATUS.SLEEP) 
      		or (tonumber(self.monsterNowType) == FuncTowerMap.MONSTER_STATUS.SKIPED) then
      		nowView.mc_2:showFrame(2)
      	end
      	nowView.mc_2.currentView.btn_1:setTap(c_func(self.enterTeamFormation,self,i))
      	-- 如果曾经打过这个怪,则只能选择曾经打的难度
      	local lastStar = TowerMapModel:getLastBattleStar(self.monsterParam.x,self.monsterParam.y)
      	echo("______lastStar_________",lastStar)
      	if lastStar then
      		if lastStar == i then
      			nowView.panel_suo:visible(false)
      		else
      			nowView.panel_suo:visible(true)
      			nowView.panel_suo:setTouchEnabled(false)
      			nowView.mc_2.currentView.btn_1:visible(false)
      		end	
      	else
      		nowView.panel_suo:visible(false)
      	end

      	if self.reduceValue then
      		nowView.txt_power2:visible(true)
			local powerNum = tonumber(recommendPower[i])*(100-self.reduceValue)/100
			powerNum = math.floor(powerNum)
			nowView.txt_power:setString(powerNum)
			nowView.txt_power2:visible(true)
			nowView.txt_power2:setString("(-"..tostring(self.reduceValue).."%)")
			-- 削减txt 偏移
			local basePosX = nowView.txt_power:getPositionX()
			local offsetx = FuncCommUI.getStringWidth(tostring(powerNum), nowView.txt_power:getFontSize(),nowView.txt_power:getFont() )
      		nowView.txt_power2:setPositionX(basePosX+offsetx)

			local ctn = self.mc_1.currentView.ctn_xueruo
			local weakenView =self:createUIArmature("UI_suoyaota","UI_suoyaota_xueruodonghua",ctn,true, GameVars.emptyFunc)
			weakenView:pos(30,-40)
      	end
	end
end

function TowerMonsterView:createBossDifficult()
	self.mc_1.currentView.btn_1:setTap(c_func(self.enterTeamFormation,self,0))
	--[[
	-- 更新怒气值
	local curEnergy = TowerMainModel:getCurEnergy()
    local maxEnergy = TowerMainModel:getMaxEnergy()
    self:setEnergyNum(self.mc_1.currentView.panel_bao.panel_nuqizhi.mc_1,curEnergy)
    self:setEnergyNum(self.mc_1.currentView.panel_bao.panel_nuqizhi.mc_2,maxEnergy)
    if curEnergy < 10 then
    	if not self.offsetX then
    		self.offsetX = self.mc_1.currentView.panel_bao.panel_nuqizhi:getPositionX()
    	end
    	self.mc_1.currentView.panel_bao.panel_nuqizhi:setPositionX(self.offsetX - 30)
    end
	]]
	-- 2018.08.13 怒气值移到布阵界面
	self.mc_1.currentView.panel_bao:setVisible(false)

	-- 野怪显示击杀奖励
	local tempShowRewardNum = 0
	local rewardId = self.curFloorConfigData.monsterReward[tonumber(self.monsterData.type)]
    local monsterReward = FuncItem.getRewardArrayByCfgData({FuncDataResource.RES_TYPE.REWARD..","..rewardId})
	for k,v in pairs(monsterReward) do
		local rewardUI = self.mc_1.currentView.panel_jiangli["UI_"..k]
		local rewardArr = string.split(v,",")
		local rewardType = rewardArr[1];
		local rewardNum = rewardArr[table.length(rewardArr)];
		local rewardId = rewardArr[table.length(rewardArr) - 1];
		rewardUI:setResItemData({reward = v})
		FuncCommUI.regesitShowResView(rewardUI,
        	rewardType,rewardNum,rewardId,v,true,true)
		rewardUI:showResItemNum(true)
		tempShowRewardNum = tempShowRewardNum +1

		local yinzhang = self.mc_1.currentView.panel_jiangli["panel_"..k]
		if self.hasGotReward then
			yinzhang:visible(true)
		else
			yinzhang:visible(false)
		end
	end
	if tempShowRewardNum <= 3 then
		local tempRewardNum = tempShowRewardNum +1
		for i =tempRewardNum,3 do
		 	local rewardUI = self.mc_1.currentView.panel_jiangli["UI_"..i]
		 	rewardUI:visible(false)
		 	local yinzhang = self.mc_1.currentView.panel_jiangli["panel_"..i]
		 	yinzhang:visible(false)
		end 
	end

	-- 显示默认战力
	local recommendPower = table.deepCopy(self.monsterData.power)
	recommendPower[1] = recommendPower[1]*(self.curFloorConfigData.powerRevise or 100)/100
	self.mc_1.currentView.ctn_xueruo:visible(false)
	self.mc_1.currentView.txt_power:setString(recommendPower[1])
	self.mc_1.currentView.txt_power2:visible(false)
	-- 显示相关联的其他被击杀怪对本怪产生的影响
	local killList = TowerMainModel:getKillMonsters()
	for _killedMonsterId,_killedNum in pairs(killList) do
		local killedMonsterData = FuncTower.getMonsterData(_killedMonsterId)
		if killedMonsterData.killMonsterId then
			for i,_monsterId in pairs(killedMonsterData.killMonsterId) do
				if _monsterId == self.monster then
					self.mc_1.currentView.ctn_xueruo:visible(true)
					local powerNum = tonumber(recommendPower[1])*(100-killedMonsterData.reduce)/100
					powerNum = math.floor(powerNum)
					self.mc_1.currentView.txt_power:setString(powerNum)
					self.mc_1.currentView.txt_power2:visible(true)
					self.mc_1.currentView.txt_power2:setString("(-"..tostring(killedMonsterData.reduce).."%)")
					local nowView = self.mc_1.currentView
					local basePosX = nowView.txt_power:getPositionX()
					local offsetx = FuncCommUI.getStringWidth(tostring(powerNum), nowView.txt_power:getFontSize(),nowView.txt_power:getFont() )
		      		nowView.txt_power2:setPositionX(basePosX+offsetx)

					local weakenView =self:createUIArmature("UI_suoyaota","UI_suoyaota_xueruodonghua",self.mc_1.currentView.ctn_xueruo,true, GameVars.emptyFunc)
					weakenView:pos(30,-40)
					return
				end
			end	
		end
	end
end

function TowerMonsterView:deleteMe()
	TowerMonsterView.super.deleteMe(self);
end

function TowerMonsterView:bypassMonster()
	local params ={
		x = self.monsterParam.x,
		y = self.monsterParam.y,
	}
	TowerServer:byPassLocation(params,c_func(self.bypassMonsterEffect,self))
end

function TowerMonsterView:bypassMonsterEffect(event)
	if event.error then
		WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_047"))
	else
		local passMonsterData ={
			monsterId=self.monster,
			x = self.monsterParam.x,
			y = self.monsterParam.y,
		}
		TowerMainModel:updateData(event.result.data)
		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_SKIP_MONSTER,passMonsterData)
		self:startHide()
	end	
end

function TowerMonsterView:enterTeamFormation(startType)
	echo("_________________")
	local mission = self.monsterData.level
	-- 2017.08.16 pangkangning 表格字段修改
	-- for k,v in pairs(self.MonsterData.difficulty) do
	-- 	if tonumber(k) == tonumber(startType) then
	-- 		mission = v
	-- 	end
	-- end

	-- local realStartType = 0
	-- if tonumber(startType) == 1 then
	-- 	realStartType = 1
	-- elseif tonumber(startType) == 2 then
	-- 	realStartType = 5 
	-- elseif tonumber(startType) == 3 then
	-- 	realStartType = 7
	-- else
	-- 	realStartType = 0	
	-- end
	local params = {
		x = self.monsterParam.x or 1,
		y = self.monsterParam.y or 1,
		star = startType,
		missionId = mission,
		monsterId = self.monster,
	}

	params[FuncTeamFormation.formation.pve_tower] = {
		raidId = mission,
  	} 

	WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.pve_tower,params);
end

function TowerMonsterView:backAttack()

end

function TowerMonsterView:press_btn_close()
	self:startHide()
end

return TowerMonsterView;
