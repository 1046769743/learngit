--
--Author:      zhuguangyuan
--DateTime:    2018-03-09 14:41:40
--Description: 聚灵格子模型,开格子后立即响应
-- 1.聚灵格子id self.gearId
-- 2.聚灵格子数据 self.runeData
-- 剑 回怒 回血


local TowerGearModel = require("game.sys.view.tower.model.TowerGearModel")
TowerGearRuneModel = class("TowerGearRuneModel",TowerGearModel)

function TowerGearRuneModel:ctor( controler,gridModel )
 	TowerGearRuneModel.super.ctor(self,controler,gridModel)
 	self:initData()
end

function TowerGearRuneModel:initData(  )
	local gridInfo = self.grid:getGridInfo()
	-- dump(gridInfo, "聚灵格子数据 ")
	local gearId = gridInfo[FuncTowerMap.GRID_BIT.D4_TYPE_ID]
	self:setGearId(gearId)
end

function TowerGearRuneModel:setGearId(gearId)
	TowerGearRuneModel.super.setGearId(self,gearId)
	self.runeData = FuncTower.getRuneDataByID(gearId)
end

function TowerGearRuneModel:createGearView()
	if self.myView and not tolua.isnull(self.myView) then
		self.myView:removeFromParent()
		self.myView = nil
	end
	self:initView(self.grid.viewCtn,self.grid.pos.x,self.grid.pos.y,self.grid.pos.z,self.grid.isHasSceneAlertMonster)
end

-- 初始化格子视图
function TowerGearRuneModel:initView(ctn,xpos,ypos,zpos,isHasSceneAlertMonster)
	self.gridStatus = self.grid:getGridStatus()
	local girdViewStatus = self.gridStatus
	if self.grid:hasExplored() then
		-- 特殊处理普通障碍物
		if self.grid:hasNormalObstracle() then
			girdViewStatus = self.grid.GRID_STATUS.OBSTRACLE
		end
	end

	if isHasSceneAlertMonster then
		girdViewStatus = self.grid.GRID_STATUS.CAN_NOT_EXPLORE
	end

	-- if self.runeSprite and not tolua.isnull(self.runeSprite) then
	-- 	self.runeSprite:removeFromParent()
	-- 	self.runeSprite = nil
	-- end
	-- 不可探索显示第一张图
	-- 可探索显示第二张图
	local runePng = self.runeData.runeIcon[tonumber(self.gridStatus)]
	echo("_______聚灵格子上的图片_runePng_____________",runePng)
	self.runeSprite = display.newSprite(FuncRes.iconTowerEvent(runePng))
	if self.runeSprite and not tolua.isnull(self.runeSprite) then
		local view = display.newNode()
		local animation = self.controler.ui:createUIArmature("UI_suoyaota_c", "UI_suoyaota_c_huo", view, true, GameVars.emptyFunc) 
		FuncArmature.changeBoneDisplay( animation,"layer2",self.runeSprite)
		animation:visibleBone("layer70", false)
		xpos = xpos + 40
		ypos = ypos - 10
		local size = cc.size(250,250)
		TowerGearRuneModel.super.initView(self,ctn,view,xpos,ypos,zpos,size)
	end
end

-- 每帧刷新
function TowerGearRuneModel:dummyFrame()
	-- 更新zorder
	if self.grid then
		local zorder = self.grid:getEventZOrder()
		self:setZOrder(zorder)
	end

	local gridInfo = self.grid.gridInfo
	local newGearId = tostring(gridInfo[FuncTowerMap.GRID_BIT.D4_TYPE_ID])
	if newGearId and (newGearId ~= tostring(self.gearId)) then
		self:setGearId(newGearId) 
		echo("_________ 聚灵类型发生改变 新货==____________",newGearId)
		self:createGearView()
	end
end

function TowerGearRuneModel:onAfterOpenGrid(gearCacheData)
	TowerGearRuneModel.super.onAfterOpenGrid()
	if not gearCacheData then
		return
	end
	
	self.gearCacheData = gearCacheData
	local data = table.deepCopy(gearCacheData)
	-- dump(gearCacheData, "打开机关格子后服务器给的数据")

	if not self.gridInfo then
		self.gridInfo = self.grid:getGridInfo()
	end
	local targetGridId = nil
	self.gearType = self.gridInfo[FuncTowerMap.GRID_BIT.D4_TYPE_ID]

	-- 回血只针对己方
	-- 回怒只针对己方
	-- 掉血 未进过战斗则存在格子中 针对己方(存在unitInfo)和敌方(存在enemyInfo)
	if self.gearType == FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.BLOOD_REGAIN then
		-- 计算气血增量并保存,布阵界面用于展示
	    if data.towerExt and data.towerExt.unitInfo then
	        local newData = data.towerExt.unitInfo
	        local oldData = TowerMainModel:towerExt().unitInfo
	        if newData and table.length(newData)>0 then
	        	local increment = 0
	        	local curHid = nil
	        	local curHp = nil
	        	local new1,old1
	            for kk,vv in pairs(newData) do
            		new1,old1 = 10000,10000
	                if oldData and oldData[kk] then
	                    oldDataItem = json.decode(oldData[kk])
						old1 = tonumber(oldDataItem.hpPercent) 
					end	
                    local newDataItem = json.decode(vv)
                    new1 = tonumber(newDataItem.hpPercent)
                    local newIncrement = new1 - old1 
                    if math.abs(newIncrement) >= math.abs(increment) then
                    	increment = newIncrement
                    	curHid = newDataItem.hid
                    	curHp = new1
                    	if new1 == 0 then
                    		increment = 0
                    	end
                    end
	            end
	            local params = {hid = curHid,bloodIncrement = increment,nowNum = curHp,gearType = self.gearType}
                self:bloodRecoverSucceed( params )
	        else
	        	local params = {hid = curHid,bloodIncrement = 0,nowNum = 10000,gearType = self.gearType}
                self:bloodRecoverSucceed( params )	
	        end
	    end
	    -- 更新翻开格子服务器返回的数据
		TowerMainModel:updateData(self.gearCacheData)
	elseif self.gearType == FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.ANGER_REGAIN then
		-- 怒气 -- 计算怒气增量并保存,挑战怪界面用于展示
		if data.towerExt and data.towerExt.energy then
			local newEnergy = data.towerExt.energy
			local oldEnergy = TowerMainModel:towerExt().energy
			if not oldEnergy then
			    oldEnergy = 0
			end

			-- 最大值限制
			local max = TowerMainModel:getMaxEnergy()
			if newEnergy > max then
				newEnergy = max
			end
			if oldEnergy > max then
				oldEnergy = max
			end

			local increment = newEnergy - oldEnergy 
			-- if increment > 0 then
			    local params = {energyIncrement = increment,nowNum = newEnergy}
			    self:energyRecoverSucceed( params )
			-- else
	  --           -- 如果怒气已满 则提示怒气已满
	  --           local max = TowerMainModel:getMaxEnergy()
	  --           if oldEnergy == max then
	  --           	local params = {energyIncrement = increment,nowNum = newEnergy}
			--     	self:energyRecoverSucceed( params )
	  --           end
			-- end
		end
		-- 更新翻开格子服务器返回的数据
		TowerMainModel:updateData(self.gearCacheData)
	elseif self.gearType == FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.SWORD then 
		self.targetGrid = self:findAffectedGrid(self.gearCacheData)
		if self.targetGrid and self.targetGrid.eventModel then
			local eventModel = self.targetGrid.eventModel
			if eventModel then
				self.targetMonsterId = eventModel:getEventId()
				echo("___________ 目标格子的怪id ___________",self.targetMonsterId)
			end
		end

		if not self.targetGrid then
			echo("___________ 找不到飞剑目标 那么只能砍人了 ___________")
			-- 计算气血增量并保存,布阵界面用于展示
		    if data.towerExt and data.towerExt.unitInfo then
		        local newData = data.towerExt.unitInfo
		        local oldData = TowerMainModel:towerExt().unitInfo
		        if newData and table.length(newData)>0 then
		        	local increment = 0
		        	local curHid = nil
		        	local curHp = nil
		        	local new1,old1
		            for kk,vv in pairs(newData) do
	            		new1,old1 = 10000,10000
		                if oldData and oldData[kk] then
		                    oldDataItem = json.decode(oldData[kk])
							old1 = tonumber(oldDataItem.hpPercent) 
						end	
	                    local newDataItem = json.decode(vv)
	                    new1 = tonumber(newDataItem.hpPercent)
	                    local newIncrement = new1 - old1 
	                    if math.abs(newIncrement) >= math.abs(increment) then
	                    	increment = newIncrement
	                    	curHid = newDataItem.hid
	                    	curHp = new1
	                    	if new1 == 0 then
	                    		increment = 0
	                    	end
	                    end
		            end
		            local function callBack( params )
			            local params = {hid = curHid,bloodIncrement = increment,nowNum = curHp,gearType = self.gearType}
		                self:bloodRecoverSucceed( params )
		            end
		            self:playGearEffectAni(self.controler.charModel.gridModel,c_func(callBack,params))
		        end
		    else
	            local params = {bloodIncrement = 0,nowNum = 0,gearType = self.gearType}
                self:bloodRecoverSucceed( params )
		    end

		    -- 更新翻开格子服务器返回的数据
		    TowerMainModel:updateData(self.gearCacheData)
			return 
		end

		-- 播放聚灵格子效果特效
		-- 播放怪死亡动画
		-- 播放星星动画
		self:playGearEffectAni(self.targetGrid,c_func(self.playDieAnim,self))

		-- 播放恭喜获得奖励
		-- 检查完美通关
		-- 自动打开格子
		-- 必须深度拷贝数据，否则在回调中event就被释放了
		local callBack = function()
			local serverData = table.deepCopy(self.gearCacheData)

			local towerReward = {}
			if self.gearCacheData.rewardGoods then
				local reward = FuncTower.towerItemType..","..self.gearCacheData.rewardGoods .. ",1"
				towerReward = {reward}
			end
			if self.gearCacheData.bossReward then
				TowerMainModel:savePerfactReward( self.gearCacheData.bossReward )
			end

			local currentHaveStar = self.gearCacheData.towerFloor.floorStar
			local totalConfigStarNum = TowerMainModel:getTotalStarNum(TowerMainModel:getCurrentFloor())
			if tonumber(totalConfigStarNum) == tonumber(currentHaveStar) then
				TowerMainModel:handlePerfactGearRuneData( self.gearCacheData )
			end
			
		    -- 更新翻开格子服务器返回的数据
		    TowerMainModel:updateData(self.gearCacheData)
			if self.gearCacheData.monsterReward then
				WindowControler:showWindow("TowerGetRewardView",self.gearCacheData.monsterReward,towerReward,nil,nil,self.gearCacheData.bossReward)
			elseif self.gearCacheData.bossReward then
				EventControler:dispatchEvent(TowerEvent.TOWEREVENT_CHECK_IS_PERFECT,{})
			end
		end
		self.controler.ui:delayCall(c_func(callBack), self.aniDelayTime/GameVars.GAMEFRAMERATE)
	end
end

-- 寻找目标格子
function TowerGearRuneModel:findAffectedGrid(gearCacheData)
	local data = gearCacheData -- table.deepCopy(gearCacheData)
	local targetGrid 


	-- -- 怪物血量削减量
	-- local reduceNum = nil
	-- if data.towerFloor and data.towerFloor.cells then
	-- 	for gridId,v in pairs(data.towerFloor.cells) do
	-- 		local x,y = TowerMapModel:gridIdToPos(gridId)
	-- 		if TowerMapModel:isValidGrid(x,y) then
	-- 			local  oldHp,newHp=0,0
	-- 			local oldGridInfo = TowerMapModel:getGridInfo(tostring(x),tostring(y)) 
	-- 			-- dump(oldGridInfo, "老数据")

	-- 			if oldGridInfo and oldGridInfo.ext then
	-- 				local oldData = oldGridInfo.ext
	-- 				if oldData.hpPercentReduce then
	-- 					oldHp = oldData.hpPercentReduce
	-- 				end
	-- 			end

	-- 			if v.ext then
	-- 				local newData = json.decode(v.ext)
	-- 				-- dump(newData, "新数据")
	-- 				if newData.hpPercentReduce then
	-- 					newHp = tonumber(newData.hpPercentReduce) 
	-- 					local reduceNum = newHp - oldHp
	-- 					echo("________ 新血量减去老血量 reduceNum __________",reduceNum)
	-- 					if reduceNum > 0 then
	-- 						targetGrid = self.controler:findGridModel(x,y)
	-- 						break
	-- 					end
	-- 				else
	-- 					if tostring(oldGridInfo.status) == FuncTowerMap.GRID_BIT_STATUS.EXPLORED 
	-- 						and (oldHp > 0) 
	-- 					then
	-- 						targetGrid = self.controler:findGridModel(x,y)
	-- 					end
	-- 				end
	-- 			else
	-- 				if tostring(oldGridInfo.status) == FuncTowerMap.GRID_BIT_STATUS.EXPLORED 
	-- 					and tostring(v.status) == FuncTowerMap.GRID_BIT_STATUS.CLEAR 
	-- 					and (oldHp > 0) 
	-- 					then
	-- 					targetGrid = self.controler:findGridModel(x,y)
	-- 				else
	-- 					local justKillMonsters = data.towerFloor.killMonsters
	-- 					if justKillMonsters and table.length(justKillMonsters)>0 then
	-- 						for kkk,vvv in pairs(justKillMonsters) do
	-- 							local justKillMonsterId = kkk
	-- 							if tostring(justKillMonsterId) == tostring(oldGridInfo[FuncTowerMap.GRID_BIT.TYPE_ID]) then
	-- 								targetGrid = self.controler:findGridModel(x,y)
	-- 							end
	-- 						end
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end


	-- 怪物血量削减量
	-- 解决提示错误问题
	local reduceNum = nil
	if data.towerFloor and data.towerFloor.cells then
		for gridId,v in pairs(data.towerFloor.cells) do
			local x,y = TowerMapModel:gridIdToPos(gridId)
			if TowerMapModel:isValidGrid(x,y) then
				-- if v.ext then
				-- 	local newData = json.decode(v.ext)
				-- 	-- dump(newData, "新数据")
				-- 	if newData.hpPercentReduce then
				-- 		targetGrid = self.controler:findGridModel(x,y)
				-- 	end
				-- else
					local oldGridInfo = TowerMapModel:getGridInfo(tostring(x),tostring(y)) 
					if tostring(oldGridInfo.status) == FuncTowerMap.GRID_BIT_STATUS.EXPLORED 
						and tostring(oldGridInfo[FuncTowerMap.GRID_BIT.TYPE]) == FuncTowerMap.GRID_BIT_TYPE.MONSTER
					then
						if tostring(v.status) == FuncTowerMap.GRID_BIT_STATUS.CLEAR then
							targetGrid = self.controler:findGridModel(x,y)
							break
						elseif v.ext then
							local newData = json.decode(v.ext)
							-- dump(newData, "新数据")
							if newData.hpPercentReduce or newData.shopId then
								targetGrid = self.controler:findGridModel(x,y)
								break
							end
						end
					end
				-- end
			end
		end
	end
	return targetGrid
end

-- 播放剑 插怪的动画
function TowerGearRuneModel:playGearEffectAni(gridModel,callBack)
	local gameMiddleLayer = self.controler.map:getGameMiddleLayer()
	local curFloorData = FuncTower.getOneFloorData( TowerMainModel:getCurrentFloor() )
	if curFloorData.scene and tonumber(curFloorData.scene) == 1 then
		animation = self.controler.ui:createUIArmature("UI_suoyaota_c", "UI_suoyaota_c_jianhongse", gameMiddleLayer, false, GameVars.emptyFunc) 
	else
		animation = self.controler.ui:createUIArmature("UI_suoyaota_c", "UI_suoyaota_c_jianluoxia", gameMiddleLayer, false, GameVars.emptyFunc) 
	end
	animation:pos(gridModel.pos.x+1,gridModel.pos.y-3)
	animation:zorder(gridModel.zorder+3)

	if callBack then
		self.aniDelayTime = animation:getAnimation():getRawDuration()/2
		self.controler.ui:delayCall(callBack, self.aniDelayTime/GameVars.GAMEFRAMERATE)
	end
end

-- 播放怪死亡动画
function TowerGearRuneModel:playDieAnim()
	if not self.targetGrid then
		return 
	end
	local isSword = (self.gearType == FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.SWORD)
	local isMonsterDie = false
	local data = self.gearCacheData
	if data.towerFloor and data.towerFloor.killMonsters then
		for monsterId,killNum in pairs(data.towerFloor.killMonsters) do
			if tostring(monsterId) == tostring(self.targetMonsterId) then
				isMonsterDie = true
				self.aniDelayTime = self.aniDelayTime + 26
			end
		end
	end

	if (not isSword) or (not isMonsterDie) then
		echo("______ isSword,isMonsterDie ________", isSword,isMonsterDie )
		return 
	end
	local grid = self.targetGrid
	if grid then
		-- 播放死怪动画
		echo("________ 怪死亡 播放怪死亡动画 __________")
		local monsterModel = grid:getEventModel()
		if monsterModel and monsterModel.playDieAnim then
			monsterModel:playDieAnim()
			-- 提示怪死亡
			local monsterData = FuncTower.getMonsterData(self.targetMonsterId)
			local monsterName = GameConfig.getLanguage(monsterData.name)
			tips = GameConfig.getLanguageWithSwap("#tid_tower_ui_095",monsterName)
			WindowControler:showTips(tips,2)

			-- 播放加星动画
			echo("________ 怪死亡 如果是星级怪 播放飞星星动画 __________")
			local monsterData = FuncTower.getMonsterData(self.targetMonsterId)
			local addStar = 0  
			-- 用剑杀死的星级怪 默认三星
			if tonumber(monsterData.star) == FuncTowerMap.MONSTER_STAR_TYPE.STAR then
				addStar = 3
			end
			if addStar == 3 then
				EventControler:dispatchEvent(TowerEvent.TOWEREVENT_ITEM_KILL_MONSTER,{targetGrid=grid,addStar=addStar})
			end
		else
			echoWarn("剑格子 monsterModel=",monsterModel,grid,grid.xIdx,grid.yIdx)
		end
	end
end

-- 回怒成功
function TowerGearRuneModel:energyRecoverSucceed( params )
	if TowerConfig.SHOW_TOWER_DATA then
		dump(params, "==== 回怒成功params")
	end
	local nowNum = params.nowNum
	local maxNum = TowerMainModel:getMaxEnergy()
	if nowNum > maxNum then
		nowNum = maxNum
	end
	local tips = GameConfig.getLanguageWithSwap("#tid_tower_ui_078",params.energyIncrement,nowNum.."/"..maxNum)
	echo("_________tips__________",tips)
	WindowControler:showTips(tips)
	self.controler.charModel:playRecoveryEnergyAni()
end

-- 回血成功
function TowerGearRuneModel:bloodRecoverSucceed( params )
	if TowerConfig.SHOW_TOWER_DATA then
		dump(params, "==== 回血成功params")
	end
	local targetPartnerName
	if params.hid then
		targetPartnerName = FuncPartner.getPartnerName(params.hid)
	end

	local tips = nil
	if params.bloodIncrement < 0 then
		tips = GameConfig.getLanguageWithSwap("#tid_tower_ui_076",targetPartnerName,(math.abs(params.bloodIncrement)/100).."%",(params.nowNum/100).."%")
	elseif params.bloodIncrement > 0 then
		tips = GameConfig.getLanguageWithSwap("#tid_tower_ui_077",targetPartnerName,(params.bloodIncrement/100).."%",(params.nowNum/100).."%")
	else  
		if params.gearType == FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.BLOOD_REGAIN then
			if params.nowNum > 0 then
				tips = GameConfig.getLanguageWithSwap("#tid_tower_ui_101")
			else
				tips = GameConfig.getLanguageWithSwap("#tid_tower_ui_100")
			end
		else
			tips = GameConfig.getLanguage("#tid_tower_ui_099")
		end
	end
	echo("_________tips__________",tips)
	WindowControler:showTips(tips)
	if params.gearType == FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.BLOOD_REGAIN and params.nowNum >0 then 
		self.controler.charModel:playRecoveryBloodAni()
	end
end

function TowerGearRuneModel:registerEvent()
	TowerMonsterModel.super.registerEvent(self)
	-- 底层数据变更完毕 
	EventControler:addEventListener(TowerEvent.TOWEREVENT_TOWER_DATA_UPDATE,self.checkRecoverBloodAndEnergy,self)
end

function TowerGearRuneModel:checkRecoverBloodAndEnergy()
	-- body
end

function TowerGearRuneModel:deleteMe()
	if self.runeSprite then
		self.runeSprite:removeFromParent()
	end
	TowerGearRuneModel.super.deleteMe(self)
end


return TowerGearRuneModel
