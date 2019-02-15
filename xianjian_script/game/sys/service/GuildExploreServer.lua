--
-- Author: xd
-- Date: 2018-07-03 11:34:23
--
--[[
交互协议	

dirtyList = {
	u  ={
		
	}
	d = {
	
	}	
}






玩家运动到某个点

method = explore.moveToPoint
params = {
	moveTime = 32325012232, 	--开始运动事件
	target= 10001, 		-- 所有的坐标存储结构 x*10000+y
	source =20001,		-- 
	positionList = {30001,20001},
}




]]




local GuildExploreServer = {}

function GuildExploreServer:init(  )
	EventControler:addEventListener("notify_explore_map_enterMap", self.oneRoleEnterMap,self)
	EventControler:addEventListener("notify_explore_map_leaveMap", self.oneRoleLeaveMap,self)
	EventControler:addEventListener("notify_explore_map_pushMove", self.oneRoleMove,self)
	EventControler:addEventListener("notify_explore_map_eventChange", self.onEventChange,self)
	EventControler:addEventListener("notify_explore_map_role_pushRelease", self.onExitExplore,self)
	EventControler:addEventListener(SystemEvent.SYSTEMEVENT_ONSERVERERROR , self.onServerError,self)

	self._reconnectCount = 0

	 -- 布阵结束，开始战斗
    EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.onTeamFormationComplete, self)
	    --单人战斗结束，上报结果
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT, 
        self.blockBattleEnd, self);

    self.repeatTimes = 0


end

--收到serverError消息
function GuildExploreServer:onServerError( event )
	local code = event.params
	if code  == ErrorCode.explore_notInOpen then
		--那么退出这个系统
		self:onExitExplore(true)
	end
end

function GuildExploreServer:onEventChange( event )
	local params = event.params.params
	local eventId = params.eventId
	local tb = {
		mapInfo = {
			events = params
		}
	}
	--事件发生变化
	GuildExploreModel:updateData(tb)
end

--一个角色进入
function GuildExploreServer:oneRoleEnterMap( event )
	local rid = event.params.params.rid
	local data = {
		mapInfo = {
			roles = {
				[rid] = event.params.params
			}
		}
	}
	--组装数据
	GuildExploreModel:updateData(data)
end

--一个角色离开
function GuildExploreServer:oneRoleLeaveMap( event )
	local rid = event.params.params.rid
	local data = {
		mapInfo = {
			roles = {
				[rid] = 1
			}
		}
	}
	
	--组装数据
	GuildExploreModel:deleteData(data)
end

--有角色运动 
function GuildExploreServer:oneRoleMove( event )
	local rid = event.params.params.rid
	local data = {
		mapInfo = {
			roles = {
				[rid] = event.params.params
			}
		}

	}

	if event.params.params.speed then
		data.mapInfo.roles[rid].userInfo = {speed =event.params.params.speed }
	end

	--组装数据
	GuildExploreModel:updateData(data)
end



--一个角色运动
function GuildExploreServer:moveToTargetPos( params,callBack )
	if LoginControler:isLogin() then
		if callBack then
			ServerJavaSystem:sendRequest(params, MethodCode.explore_map_move,callBack, nil)
		else
			ServerJavaSystem:sendRequest(params, MethodCode.explore_map_move,callBack)
		end
		
	else
		self:oneRoleMove({params ={params =  {rid=UserModel:rid(),pos =  params}}  })
	end

end

--确认到达
function GuildExploreServer:sureArrive( callBack,needResumeUI )
	if needResumeUI then
		WindowControler:setUIClickable(true)
		echo("___2秒后重新发送确认到达")
	end
	if LoginControler:isLogin() then

		local tempFunc = function (serverInfo  )
			--如果是有error
			if  serverInfo.error then
				--
				if serverInfo.error.code == ErrorCode.explore_isFast then
					echo("____速度太快了 可能是开加速器了")
					self.repeatTimes = self.repeatTimes +1
					
					if self.repeatTimes >= 3 then
						WindowControler:showTips("检测到你正在开加速外挂,请关闭后再继续游戏")
					end
					-- WindowControler:showTips("检测到你正在开加速外挂,请关闭后再继续游戏")

					WindowControler:setUIClickable(false)
					--最多重复5次
					if self.repeatTimes > 5 then
						self.repeatTimes = 0
						return
					end
					WindowControler:globalDelayCall(c_func(self.sureArrive,self,callBack,true), 2)

					return
				end
			else
				self.repeatTimes = 0
			end
			if callBack then
				callBack(serverInfo)
			end
		end

		ServerJavaSystem:sendRequest({}, MethodCode.explore_map_moveConfirm,tempFunc)
	end
end

--开始连接java服务器
function GuildExploreServer:startGetServerInfo(  )
	
	self._state = 1

	self:showLoadingView()

	local tempFunc = function ( serverInfo )
		if not serverInfo.result then
			self:hideLoadingView()
			if callBack then
				callBack(serverInfo)
			end
			return
		end

		ServerJavaSystem:startConnect( serverInfo.result.data, c_func(self.repeatLogin,self) )
	end

	Server:sendRequest({}, MethodCode.explore_enterMap_7601, tempFunc)
end





function GuildExploreServer:onGetServerInfo( serverInfo )
	if not serverInfo.result then
		--如果是有错误的  那么重置状态
		self._state = 0
		self:hideLoadingView()
		if callBack then
			callBack(serverInfo)
		end
		return
	end

	--如果是队列中
	if serverInfo.result.data.result ~= 2 then
		echo("_当前服务器状态:",serverInfo.result.data.result,"0.5秒后重新连接")
		self._reconnectCount = self._reconnectCount +1
		--最多重连10次
		if self._reconnectCount == 10 then
			
			self:hideLoadingView()
			self._reconnectCount = 0
			if callBack then
				callBack({error = {code = 999724,messgae = "战场连接失败"}})
			end
			return
		end
		WindowControler:globalDelayCall(c_func(self.repeatLogin,self,false), 0.5)
		return
	end
	--开始获取战场数据
	self:requestExploreData()

end

--关闭loading
function GuildExploreServer:hideLoadingView( onlyHide )
	--如果不是在loading中的 那么直接返回
	if not self._hasLoading  then
		return
	end
	self._hasLoading = false
	local loadingView  = WindowControler:getWindow("CompNewLoading")
	if loadingView then
		loadingView:finishLoading(5)
	end

	local tempFunc = function (  )
		self:handleCloseServer()
	end

	if not onlyHide then
		WindowControler:globalDelayCall(tempFunc, 0.03)
	end
	

end

--显示loading
function GuildExploreServer:showLoadingView(  )

	if WindowControler:checkHasWindow("CompNewLoading") then
		return
	end
	if BattleControler:isInBattle() then
		return
	end


	--如果已经在 探索场景了 那么不执行
	if WindowControler:checkHasWindow("GuildExploreMainView") then
		return
	end
	self._hasLoading = true
	--先弹loading
	local initTweenPercentInfo = {percent = 10,frame=30}
	local actionFuncs = {percent=80, frame = 20, action = nil}
	local processActions = {actionFuncs}

	local loadView = WindowControler:showTopWindow("CompNewLoading", "101", initTweenPercentInfo, processActions)
end

--每次登入前就插入这个操作
function GuildExploreServer:repeatLogin( serverInfo )
	if serverInfo and (not serverInfo.result)  then
		self:hideLoadingView()
		return
	end
	ServerJavaSystem:clearByMethodId( MethodCode.explore_login )
	ServerJavaSystem:clearByMethodId( MethodCode.explore_map_move )
	ServerJavaSystem:sendRequest({}, MethodCode.explore_login, c_func(self.onGetServerInfo,self),nil,nil,nil,1 )
end


--请求战场数据
function GuildExploreServer:requestExploreData( callBack )

	ServerJavaSystem:clearByMethodId( MethodCode.explore_login_loginClient)
	local tempFunc = function ( result )
		--合并地图数据
		if result.result then
			GuildExploreModel:init(result.result.data)
			--判断当前是否在战场里面 
			--如果是战斗中的 return
			if BattleControler:isInBattle() then
				return
			end

			--如果已经存在了 那么不执行
			if WindowControler:checkHasWindow("GuildExploreMainView") then
				-- 只有主城window 层级 大于 探索的window的时候 才需要pop
				if WindowControler:getWindowOrder("WorldMainView") < WindowControler:getWindowOrder("GuildExploreMainView")  then
					return
				end
				echo("主城window > 探索层级")
			end


			
			WindowControler:showWindow("GuildExploreMainView")
		else
			self:hideLoadingView()
		end
	end

	
	--这个需要插入操作
	ServerJavaSystem:sendRequest({}, MethodCode.explore_login_loginClient, tempFunc,nil,nil,nil,1)
end


--发送将要运动到某个点的消息
function GuildExploreServer:willGotoTargetPos( curX,curY,targetX,targetY )
	-- 默认延迟一帧模拟发送回调
	local tempFunc = function (  )
		local data = {
			roles =  {
				[UserModel:rid()] = {
					targetPos = {x =targetX,y = targetY },
				}
			}
		}
		GuildExploreModel:updateData( data )
	end

	WindowControler:globalDelayCall(tempFunc, 0.1)

end

--购买精力
function GuildExploreServer:buyEnergy(callBack  )
	--暂时直接判定购买成功 等待服务器接入
	-- GuildExploreModel:changeEnegry(100)
	-- if callBack then
	-- 	callBack()
	-- end
	--
	local tempfunc = function ( serverInfo )
		if not serverInfo.result then
			if callBack then
				callBack(serverInfo)
			end
			
			return
		end	
		GuildExploreModel:updateData(serverInfo.result.data)
		if callBack then
			callBack(serverInfo)
		end

	end

	ServerJavaSystem:sendRequest({}, MethodCode.explore_buy_energy , tempfunc )


end


--发送达到某个点的消息
function GuildExploreServer:sendArrivePos( targetX,targetY )
	local tempFunc = function (  )
		local data = {
			users_1 =  {
				[UserModel:rid()] = {
					targetPos = {x =targetX,y = targetY },
				}
			}
		}
	end

	WindowControler:globalDelayCall(tempFunc, 0.1)
end


---------------------------1111111111---------------矿脉---------------111111111-------------------------------------------------

--获取矿脉数据
function GuildExploreServer:getMineDataById(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_get_data_mine_info,callBack)

end

--矿脉占领协议  --- 派遣奇侠
function GuildExploreServer:occupationMineServer(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_mine_occupy, callBack )
end

--邀请挑战矿脉
function GuildExploreServer:invitationChallengMine(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_mine_invite, callBack )
end


--撤离矿脉
function GuildExploreServer:leaveToMine(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_mine_leave , callBack )
end


--矿脉开始战斗
function GuildExploreServer:startMineBallte(event)

	dump(event,"矿脉开始战斗=======")
	local function callBack(params)
		if params.result then
			echo("=======矿脉开始战斗========")
			local serverData = params.result.data.battleInfo
			self:startBattle(serverData)
		else
			EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPLORE_MINE_SERVE_ERROR_REFRESHUI,FuncGuildExplore.lineupType.mining)
			EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
		end
	end


	local params = {
		eventId = event.id,
		formation = event.formation,
		index = event.index,
	}
	ServerJavaSystem:sendRequest(params, MethodCode.explore_mine_battleStart , callBack )
end

--矿脉战斗结束
function GuildExploreServer:mineBallteEnd(params)
	local function callBack(event)
		if event.result then
			-- dump(event.result,"====矿脉战斗结束返回====")
			local data = event.result.data
			if  data.result == 0 then
			    GuildExploreServer:BattleControlerShowReward(data)
			    GuildExploreModel:refreshAllPlayerData(data)
			else
				BattleControler:onExitBattle()
			end
		else
			BattleControler:onExitBattle()
		end
	end
	
	local eventModel = GuildExploreEventModel:getMonsterEventModel()
	local params = {
		eventId = eventModel.id,
		index = eventModel.index,
		battleInfo = {battleParams = params}
	}
	ServerJavaSystem:sendRequest(params, MethodCode.explore_mine_battleFinish , callBack )
end


-------------------------------222222222-----------矿脉-------------2222222---------------------------------------------------


---------------------------1111111---------------建筑--------------------1111111--------------------------------------------

--获取建筑信息
function GuildExploreServer:getBuildingData(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_get_city_info , callBack )
end


--建筑占领协议  --- 派遣奇侠
function GuildExploreServer:occupationCityServer(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_city_occupy, callBack )
end


--邀请挑战矿脉
function GuildExploreServer:invitationChallengCity(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_city_invite, callBack )
end


--撤离建筑
function GuildExploreServer:leaveToCity(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_city_leave , callBack )
end


--建筑开始战斗
function GuildExploreServer:startCityBallte(params)
	local function callBack(event)
		if event.result then
			echo("=======建筑开始战斗========")
			local serverData = event.result.data.battleInfo
			self:startBattle(serverData)
		else
			EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPLORE_CITY_SERVE_ERROR_REFRESHUI,FuncGuildExplore.lineupType.building)
			EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
		end
	end
	-- dump(params,"参数 ======")
	local params = {
		eventId = params.id,
		formation = params.formation,
		index = params.index,
		group = params.group,
	}
	ServerJavaSystem:sendRequest(params, MethodCode.explore_city_battleStart , callBack )
end

--建筑战斗结束
function GuildExploreServer:cityBallteEnd(params)
	local function callBack(event)
		if event.result then
			dump(event.result,"====矿脉战斗结束返回====")
			local data = event.result.data
			if  data.result == 0 then
			    GuildExploreServer:BattleControlerShowReward(data)
			    GuildExploreModel:refreshAllPlayerData(data)
			else
				BattleControler:onExitBattle()
			end
		else
			BattleControler:onExitBattle()
		end
	end
	local eventModel = GuildExploreEventModel:getMonsterEventModel()
	local params = {
		eventId = eventModel.id,
		index = eventModel.index,
		group = eventModel.group,
		battleInfo = {battleParams = params},
	}
	ServerJavaSystem:sendRequest(params, MethodCode.explore_city_battleFinish , callBack )
end





--------------------------2222222----------------建筑---------------------222222222-------------------------------------------



---------------------------11111111111---------------资源----------1111111111------------------------------------------------------
--拾取资源
function GuildExploreServer:sendPickupResources(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_get_res_pickup , callBack )
end
-------------------------------22222222222-----------资源--------222222222222--------------------------------------------------------





--------------------------------111111111----------普通怪------------------1111111111----------------------------------------------
--挑战普通怪
function GuildExploreServer:challengOrdinaryMonster(params,callBack)

	local function callBack( event )
		if event.result then
			-- dump(event.result,"======普通怪 ---- 开始战斗=====")
			local serverData = event.result.data.battleInfo
			self:startBattle(serverData)
		end
	end



	local params = {
		eventId = params.id,
		formation = params.formation,
	}

	ServerJavaSystem:sendRequest(params, MethodCode.explore_challeng_monster_battleStart , callBack )
end



--普通怪战斗结束
function GuildExploreServer:OrdinaryMonsterBallteEnd(params)
	local eventModel = GuildExploreEventModel:getMonsterEventModel()
	local function callBack(event)
		if event.result then
			-- dump(event.result,"====怪物战斗结束返回====")
			local data = event.result.data
		    -- GuildExploreModel:byEventModelDeleteData(eventModel)
		    GuildExploreServer:BattleControlerShowReward( data )
		    GuildExploreModel:refreshAllPlayerData(data)
		    local levelHpPercent = data.levelHpPercent
		    if levelHpPercent then
		    	GuildExploreModel:setEventData( data.eventId ,"levelHpPercent",levelHpPercent)
		    end
		else
			BattleControler:onExitBattle()
		end
	end
	-- dump(eventModel,"222222222222222222222")
	
	local params = {
		eventId = eventModel.id,
		battleParams =  params,
	}
	ServerJavaSystem:sendRequest(params, MethodCode.explore_monster_battleFinish , callBack )
end



---------------------------------22222222---------普通怪-------------22222222---------------------------------------------------



--------------------------------111111111----------精英怪------------------1111111111----------------------------------------------


--获得精英怪的信息
function GuildExploreServer:getServeEliteMonsterData(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_get_eliteMonster_info , callBack )
end

--精英怪邀请
function GuildExploreServer:eliteMonsterInvitation(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_get_eliteMonster_invite , callBack )
end

--领取精英怪奖励
function GuildExploreServer:getEliteMonsterReward(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_get_eliteMonster_reward , callBack )
end



--挑战精英怪
function GuildExploreServer:challengEliteMonster(params,callBack)

	local function callBack( event )
		if event.result then
			-- dump(event.result,"======精英怪 ---- 开始战斗=====")
			local serverData = event.result.data.battleInfo
			self:startBattle(serverData)
		end
	end



	local params = {
		eventId = params.id,
		formation = params.formation,
	}

	ServerJavaSystem:sendRequest(params, MethodCode.explore_challeng_eliteMonster_fightStart , callBack )
end



--精英怪战斗结束
function GuildExploreServer:eliteMonsterBallteEnd(params)
	local eventModel = GuildExploreEventModel:getMonsterEventModel()
	local function callBack(event)
		if event.result then
			-- dump(event.result,"====精英怪物战斗结束返回====")
			local result = event.result.data.result
			local reward =   event.result.data.reward
			if reward then
				reward = GuildExploreModel:rewardTypeConversion(reward)
			else
				reward = {}
			end
			local rewardData = {
		    	reward = reward,
		        result = self._result,
		    }


		    --删除地图上的事件
		    -- GuildExploreModel:byEventModelDeleteData(eventModel)

		    BattleControler:showReward(rewardData)
		    GuildExploreModel:refreshAllPlayerData(event.result.data)
		else
			BattleControler:onExitBattle()

		end
	end
	
	
	local params = {
		eventId = eventModel.id,
		battleParams =  params,
	}
	ServerJavaSystem:sendRequest(params, MethodCode.explore_challeng_eliteMonster_fightFinish , callBack )
end



---------------------------------22222222---------精英怪-------------22222222---------------------------------------------------





---------------------------------1111111111---------灵泉-------------111111111---------------------------------------------------


--拾取灵泉
function GuildExploreServer:sendPickupSpring(params,callBack)

	ServerJavaSystem:sendRequest(params, MethodCode.explore_get_buff_pickup , callBack )
end

---------------------------------22222222---------灵泉-------------22222222---------------------------------------------------



--挑战怪物
function GuildExploreServer:onTeamFormationComplete(event)
	echo("======进入战斗=======")
	-- dump(event.params,"======进入战斗=======")
	local params = event.params
    local sysId = params.systemId

		
    if sysId == FuncTeamFormation.formation.guildExplorePve then
    	local eventModel = params.params[sysId].eventModel
	    local formation = params.formation
	    local index = eventModel.index
	    local _type = eventModel.type
	    local eventId = eventModel.id
	    local group = eventModel.group
	    local  params1 = {
			id = eventId,
			formation = formation,
			index = index,
			group = group,
		}
    	if _type == FuncGuildExplore.gridTypeMap.enemy then  --   发送普通怪的挑战
	   		self:challengOrdinaryMonster(params1)
	    elseif _type == FuncGuildExplore.gridTypeMap.mine then --矿脉的布阵结束
	    	self:startMineBallte(params1)
	    elseif _type == FuncGuildExplore.gridTypeMap.build then --建筑的布阵结束
	    	self:startCityBallte(params1)
	    end
	elseif sysId == FuncTeamFormation.formation.guildExploreElite then
	    local eventModel = params.params[sysId].eventModel
	    local formation = params.formation
	    local index = eventModel.index
	    local _type = eventModel.type
	    local eventId = eventModel.id
	    local group = eventModel.group
	    local  params1 = {
			id = eventId,
			formation = formation,
			index = index,
			group = group,
		}

		if _type == FuncGuildExplore.gridTypeMap.elite then  --发送精英怪的挑战
	    	self:challengEliteMonster(params1)
	    end
	end
end


--获取地图事件的数据
function GuildExploreServer:getMapEventList(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_map_record , callBack )
end

--获取排行榜数据
function GuildExploreServer:getguildExploreRankData(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_get_map_rank , callBack )
end



--获取任务列表数据
function GuildExploreServer:getTaskListData(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_get_task_info , callBack )
end

---领取任务奖励
function GuildExploreServer:getTaskReward(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_get_task_reward , callBack )
end

---获取装备数据
function GuildExploreServer:getEquipmentData(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_get_equip_info , callBack )
end

---提升装备数据
function GuildExploreServer:ascensionEquipmentData(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_equip_upgrade , callBack )
end

--领取离线奖励
function GuildExploreServer:getOfflineReward(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_role_getOfflineReward , callBack )
end

--获得已派遣
function GuildExploreServer:getOccupyRecord(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.explore_map_occupyRecord , callBack )
end


--开始进入战斗界面
function GuildExploreServer:startBattle(serverData)
	if serverData then
		-- dump(serverData.battleParams,"开始进入战斗界面 ======= 数据结构 ======")
		self.guildExplore_ServerData = serverData
		EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
		local battleInfo = BattleControler:turnServerDataToBattleInfo( serverData )
		BattleControler:startBattleInfo( battleInfo)
	end
end

--单人战斗结束，上报战斗结果
function GuildExploreServer:blockBattleEnd(data)
	-- local battleParams = self.guildExplore_ServerData.battleParams

	-- local _type = battleParams.eventType ---战斗的类型
	local params = data.params
	self._result = params.rt
	-- dump(battleParams,"战斗结束数据====battleParams=====")
	-- dump(params,"战斗结束数据====data.params=====")
	
	local _type = params.battleLabel

	--战斗结果 和服务器保持一直 
	if _type == GameVars.battleLabels.exploreMine then   ---矿脉战斗结束
		self:mineBallteEnd(params)
	elseif _type == GameVars.battleLabels.exploreBuild then ---建筑战斗结束
		self:cityBallteEnd(params)
	elseif _type == GameVars.battleLabels.exploreMonster then  ---普通怪战斗结束
		self:OrdinaryMonsterBallteEnd(params)
	elseif _type == GameVars.battleLabels.exploreElite  then  ---精英怪战斗结束
		self:eliteMonsterBallteEnd(params)
	end

end

--退出战场  手动调用
function GuildExploreServer:onExitExplore(justExit )
	--标记状态 表示退出探索场景
	self._state = 0

	local tempFunc = function (  )
		self:handleCloseServer()
		--强行关闭仙盟主界面 
		local window = WindowControler:getWindow("GuildExploreMainView")
		if window then
			-- window:startHide()
			--一键回主城
			WindowControler:goBackToHomeView()
		end
	end

	--如果是主角当前正在运动的 那么停止运动
	if (not justExit)  and (GuildExploreModel.controler and GuildExploreModel.controler.selfPlayer and GuildExploreModel.controler.selfPlayer.moveType ~=0 ) then
		local playerInstance = GuildExploreModel.controler.selfPlayer

		local params = playerInstance:turnMoveInfoToServer(playerInstance.gridPos.x,playerInstance.gridPos.y,playerInstance.gridPos.x,playerInstance.gridPos.y,{playerInstance.gridPos}  )

		echo("先停止当前运动 在退出 ")

		self:moveToTargetPos( params ,tempFunc)
	else
		tempFunc()

	end


	
end

function GuildExploreServer:handleCloseServer(  )
	ServerJavaSystem:handleClose()
	GuildExploreModel:setControler(nil)
end



function GuildExploreServer:getGMRes(params,callBack)
	ServerJavaSystem:sendRequest(params, MethodCode.GM_GET_RES , callBack )
end



function GuildExploreServer:BattleControlerShowReward( result )
	local reward =   result.reward or {}
	local buff = result.buffs
	if buff then
		GuildExploreModel:setBuffList(buff)
	end
	reward = GuildExploreModel:rewardTypeConversion(reward)
	local rewardData = {
    	reward = reward,
        result = self._result,
    }
	BattleControler:showReward(rewardData)


end

--判断是否在探索中
function GuildExploreServer:checkIsInExplore(  )
	return self._state == 1
end

--心跳包
function GuildExploreServer:explore_heartbeat(callBack)
	ServerJavaSystem:sendRequest({}, MethodCode.explore_heartbeat , callBack )
end


--设置开启某个系统
function GuildExploreServer:checkSetExploreOption( resId )

	local index = FuncGuildExplore.getCfgDatasByKey( "ExploreRes",resId ,"systemOpening")
	if not index then
		return
	end
	local oldStr = OptionsModel:getOneOption( OptionsModel.optionsMap.vexplore ) or "0,0,0"
	local tempArr = string.split(oldStr,",")
	--如果已经开启了 那么直接返回
	if tempArr[tonumber(index)] == "1" then
		return
	end
	tempArr[tonumber(index)] = "1"
	local newStr = table.concat(tempArr,",")
	local params = {
		key = OptionsModel.optionsMap.vexplore,
		value = newStr
	}

	local callback = function (  )
		EventControler:dispatchEvent(GuildExploreEvent.GUILD_EXPLORE_BUFFOPEN)
	end

	OptionsServer:setOptions( params,callback )


end


return GuildExploreServer