--[[
	Author: 张燕广
	Date:2017-08-01
	Description: 锁妖塔网络交互类
]]

local TowerServer = class("ItemServer")

function TowerServer:init( )
    -- PVE 战斗结束
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT,self.onPVEBattleComplete,self)
    EventControler:addEventListener(TowerEvent.TOWEREVENT_BEGIN_USE_ITEM,self.realUseItem,self)
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_TOWER_LEAVE,self.stopBattle,self)
    -- 需要一个临时道具
    self.tempItem = nil
    self.tempItemMonster = "1001"
end


-- 获取锁妖塔地图数据
function TowerServer:getMapData(callBack)
	local params = {
	}
	Server:sendRequest(params,MethodCode.tower_get_map_2601, callBack)
end

-- 翻开格子
function TowerServer:openGrid(xIdx,yIdx,callBack)
	local params = {
		x = xIdx,
		y = yIdx
	}

	Server:sendRequest(params,MethodCode.tower_open_grid_2605, callBack)
end

-- 捡道具
function TowerServer:getItem(xIdx,yIdx,callBack)
	local params = {
		x = xIdx,
		y = yIdx
	}

	Server:sendRequest(params,MethodCode.tower_get_item_2619, callBack)
end

--挑战怪物
function TowerServer:attackMonster(params,callBack)

	Server:sendRequest(params,MethodCode.tower_attackMonster_2625, callBack)
end

--打开宝箱
function TowerServer:getChest(params,callBack)
	Server:sendRequest(params,MethodCode.tower_getBox_2621, callBack)
end

--使用道具
function TowerServer:useItem(params,callBack)

	Server:sendRequest(params,MethodCode.tower_useItem_2615, callBack)
end

--进入下一层
function TowerServer:goNextFloor(params,callBack)
	Server:sendRequest(params,MethodCode.tower_reset_2603, callBack)
end

--购买buff
function TowerServer:buyShopBuff(params,callBack)
	Server:sendRequest(params,MethodCode.tower_finishBattle_2611, callBack)
end

function TowerServer:giveUpItem(params,callBack)

	Server:sendRequest(params,MethodCode.tower_dropGoods_2617,callBack)
end

function TowerServer:chooseNpcEvent(params,callBack)
	
	Server:sendRequest(params,MethodCode.tower_talkNpc_2623,callBack)
end

function TowerServer:onebattle(params,callBack)
	Server:sendRequest(params,MethodCode.tower_finishMonster_2627,callBack)
end

function TowerServer:byPassLocation(params,callBack)
	Server:sendRequest(params,MethodCode.tower_passMonster_2641,callBack)
end

function TowerServer:oneNpcbattle(params,callBack)
	Server:sendRequest(params,MethodCode.tower_finishNpc_2645,callBack)
end
--扫荡
function TowerServer:sweepTower(callBack)
	Server:sendRequest({},MethodCode.tower_openChests_2609,callBack)
end

function TowerServer:resetTower(callBack)
	Server:sendRequest({},MethodCode.tower_resetFloor_2607,callBack)
end

function TowerServer:getSweepBuff(params,callBack)
	Server:sendRequest(params,MethodCode.tower_sweepBuff_2613,callBack)
end

function TowerServer:getFloorReward(params,callBack)
	Server:sendRequest(params,MethodCode.tower_getFloorReward_2629,callBack)
end


function TowerServer:attackNpc(params,callBack)
	Server:sendRequest(params,MethodCode.tower_attackNpc_2643, callBack)
end

function TowerServer:getTowerMainData(params,callBack)
	Server:sendRequest(params,MethodCode.tower_getTowerInfo_2647, callBack)
end

function TowerServer:takeAltar(params,callBack)
	Server:sendRequest(params,MethodCode.tower_takeAltar_2649,callBack)
end	

-- 获取弹商店前的杀怪奖励
function TowerServer:getBeforeShopReward(params,callBack)
	Server:sendRequest(params,MethodCode.tower_getBeforeShopReward_2651,callBack)
end	
-- 雇佣兵
function TowerServer:employMercenary(params,callBack)
	Server:sendRequest(params,MethodCode.tower_employMercenary_2653,callBack)
end	
-- 劫财劫色劫魔石
function TowerServer:robSomething(params,callBack)
	Server:sendRequest(params,MethodCode.tower_robSomething_2655,callBack)
end	
-- 获取五灵buff
function TowerServer:getWulingSoul(params,callBack)
	Server:sendRequest(params,MethodCode.tower_getWulingSoul_2657,callBack)
end	

-- 三测添加
-- 开始搜刮
function TowerServer:startCollection(params,callBack)
	-- callBack()
	Server:sendRequest(params,MethodCode.tower_start_collection_2659,callBack)
end	
-- 搜刮加速
function TowerServer:collectionAccelerate(params,callBack)
	-- callBack()
	Server:sendRequest(params,MethodCode.tower_collection_accelerate_2661,callBack)
end	
-- 处理搜刮事件
function TowerServer:handleCollectionEvents(params,callBack)
	-- callBack()
	Server:sendRequest(params,MethodCode.tower_handle_collection_event_2663,callBack)
end	
-- 领取搜刮奖励
function TowerServer:receiveCollectionRewards(params,callBack)
	-- callBack()
	Server:sendRequest(params,MethodCode.tower_receive_collection_rewards_2665,callBack)
end


-- 改变聚灵格子属性
function TowerServer:changeRuneTempleType(params,callBack)
	Server:sendRequest(params,MethodCode.tower_change_rune_property_2667,callBack)
end	

-- 通过机关门
function TowerServer:passDoorEvent(params,callBack)
	Server:sendRequest(params,MethodCode.tower_pass_door_2669,callBack)
end	







-- 收到战斗结束后发送战报
function TowerServer:onPVEBattleComplete(data )
	local battleResult = data.params
	self._battleResult = battleResult
	local params = {
		battleResultClient = battleResult
	}
	-- echo("----锁妖塔战斗结算-----")
	-- dump(battleResult,"---battleResult----")
	if BattleControler:checkIsTower() then
		if BattleControler:checkIsTowerNpc() then
			TowerServer:oneNpcbattle(params,c_func(self.onPVEReportBattlResultCallBack,self))
		else
		    TowerServer:onebattle(params,c_func(self.onPVEReportBattlResultCallBack,self))
		end
	end
end
function TowerServer:onPVEReportBattlResultCallBack(event)
	-- echo("锁妖塔战斗服务器返回----、这里还有好多数据未做处理")
	-- dump(event.result,"-----result------")	
	if event then
		if event.error then
	    	local rewardData = {}
			rewardData.result = Fight.result_lose
		    BattleControler:showReward(rewardData)
		elseif event.result then
			local beforeBattleStarNum = TowerMainModel:getCurOwnStarNum()
			local afterBattleStarNum = event.result.data.towerExt.star
			local starAddNum = 0
			if beforeBattleStarNum and afterBattleStarNum then
				starAddNum = afterBattleStarNum - beforeBattleStarNum
			end
			if starAddNum <=0 then
				starAddNum = 0
			end
			TowerMainModel:updateData(event.result.data,true)
			-- dump(event.result.data, "锁妖塔战斗结束 服务器返回的数据")

			local lasetMonter = TowerMainModel:getLastBattleMonster()
			-- dump(lasetMonter, "进战斗前保存的数据 怪")
			local params = {
	        	rt = self._battleResult.rt,
	        	monster = lasetMonter.monsterId,
	    	} 
	    	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_ENTER_BATTLE_KK,params)
	    	local rewardData = {}
			local serverData = event.result
			rewardData.reward = serverData.data.monsterReward
			if serverData.data.bossReward then
				TowerMainModel:savePerfactReward( serverData.data.bossReward )
			end

			local currentHaveStar = event.result.data.towerFloor.floorStar
			local totalConfigStarNum = TowerMainModel:getTotalStarNum(TowerMainModel:getCurrentFloor())
			if tonumber(totalConfigStarNum) == tonumber(currentHaveStar) then
				TowerMainModel:handlePerfactGearRuneData( serverData.data )
			end

			if tostring(self._battleResult.rt) == tostring(Fight.result_win) then
				if lasetMonter and lasetMonter.eventId then
					local npcEventData = FuncTower.getNpcEvent(lasetMonter.eventId)
					if npcEventData.type == FuncTowerMap.NPC_EVENT_TYPE.ROB_TREASURE
						or npcEventData.type == FuncTowerMap.NPC_EVENT_TYPE.ROB_WOMAN
						or npcEventData.type == FuncTowerMap.NPC_EVENT_TYPE.ROB_STONE
					then
						echo("______________ 打败了抢劫者 ___________________")
						local params = {
							reward = serverData.data.reward,
							npcId = lasetMonter.npcId,
							eventId = lasetMonter.eventId,
							x = lasetMonter.x,
							y = lasetMonter.y,
						}
						TowerMainModel:saveBeatBadGuyData( params ) 
						rewardData.reward = {}
					end
				end
			end
			rewardData.result = self._battleResult.rt
			rewardData.star = self._battleResult.star
			rewardData.currStar = starAddNum  -- 本场战斗获得的锁妖塔葫芦数量

			-- 添加锁妖塔获得的星星数currStar
		    BattleControler:showReward(rewardData)
	    end	
	end	
end

function TowerServer:realUseItem(event)
	local params = {}
	params.goodsId = event.params.itemId
	params.goodsTime = event.params.goodsTime
	self.tempItem = event.params.itemId
	
	if not empty(event.params.monsterId) then
		self.tempItemMonster = event.params.monsterId
	end
	if not empty(event.params.gridPos) then
		params.x = event.params.gridPos.x
		params.y = event.params.gridPos.y
	end	

	if not empty(event.params.partnerId) then
		params.partnerId= event.params.partnerId
	end

	self:useItem(params,c_func(self.usedItemEffect,self))
end

function TowerServer:usedItemEffect(event)
	if event.error then 
		local errorInfo= event.error
		if tonumber(errorInfo.code) == 261501 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_item_001"))
	    end
		if tonumber(errorInfo.code) == 261503 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_item_002"))
	    end

	    EventControler:dispatchEvent(TowerEvent.TOWEREVENT_USE_ITEM_FAIL,{itemId = self.tempItem})
	else
		local serverData = event.result.data
		dump(serverData, "检查是否有完美通关的数据")
		if serverData.bossReward then
			local data = table.deepCopy(serverData.bossReward)
			TowerMainModel:savePerfactReward( data )
		end

		local tempItemData = FuncTower.getGoodsData(self.tempItem)
		
		-- 2017-12-26 在ItemModel中根据自己的逻辑选择更新数据的时机
		-- 使用道具成功，道具的各model监听此消息处理逻辑
		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_USE_ITEM_SUCCESS,{itemId = self.tempItem,serverData=serverData})
	end
end

function TowerServer:stopBattle(event)
	if event.params then
		local params = {}
		params.battleResultClient = event.params
		-- 2017.12.14 pangkangning 用 battleResultClient.isPauseOut这个字段
		-- params.isQuitBattle = 1

		if BattleControler:checkIsTower() then
			if BattleControler:checkIsTowerNpc() then
				TowerServer:oneNpcbattle(params,c_func(self.restoreBattleBefore,self))
			else
			    TowerServer:onebattle(params,c_func(self.restoreBattleBefore,self))
			end
		end

		-- TowerServer:onebattle(params,c_func(self.restoreBattleBefore,self))
 	else
		echoError("返回值battleParams不正确")
	end
end

function TowerServer:restoreBattleBefore(event)
	if event.error then

	else	
		-- TowerMainModel:updateData(event.result.data)
	end	
end

TowerServer:init()

return TowerServer

