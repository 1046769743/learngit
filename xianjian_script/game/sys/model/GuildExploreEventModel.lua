 -- GuildExploreEventModel.lua
 --
-- Author: wk
-- Date: 2018-07-020 



local GuildExploreEventModel = class("GuildExploreEventModel", BaseModel)

function GuildExploreEventModel:init( d )
	GuildExploreEventModel.super.init(self,d)
	--暂定初始化的时候 就获取所有数据

	self.playInviteArr = {}
	-- self.allEventListNotify = {}
	-- EventControler:addEventListener("notify_explore_map_pushEvent", self.eventListNotify, self)
end




--更新数据 
function GuildExploreEventModel:updateData( data )
	GuildExploreEventModel.super.updateData(self,data)

	
end


function GuildExploreEventModel:getEventStr(itemData,isPush)
	-- dump(itemData,"======事件数据结构======")
	local eventID = itemData.tid
	local eventData = FuncGuildExplore.getCfgDatas( "ExploreRecord",eventID )
	local record = eventData.record
	if isPush then
		record = eventData.push
	end
	local funParams =  itemData.funParams
	local name = nil
	-- if funParams then
	-- 	if funParams[1]  then
	-- 		if funParams[1] == UserModel:rid() then
	-- 			name = "您"
	-- 		end
	-- 	end
	-- end
	if eventData.type == FuncGuildExplore.eventType.mine then
		-- local mineID =  itemData.params[2] or 101 --测试 --TODO
		-- local mineData = FuncGuildExplore.getCfgDatas( "ExploreMine",mineID )
		local name1 = name or itemData.params[1]
		local name2 = itemData.params[2] --GameConfig.getLanguage(mineData.name)
		return FuncTranslate._getLanguageWithSwap(record,name1,name2)
	elseif eventData.type == FuncGuildExplore.eventType.build then
		local translateType = {   ---写死来用，没有固定的字段判断
			[101] = {
				[1] = "#tid_Explore_record_202",
				[2] = "#tid_Explore_record_203",
				[3] = "#tid_Explore_record_204",
			},
			[102] = {
				[1] = "#tid_Explore_record_205",
				[2] = "#tid_Explore_record_206",
				[3] = "#tid_Explore_record_207",
			},
		}
		local name1 = name or itemData.params[1]
		local name2 = GameConfig.getLanguage(translateType[tonumber(itemData.tid)][itemData.index or 1])
		return FuncTranslate._getLanguageWithSwap(record,name1,name2)
	elseif eventData.type == FuncGuildExplore.eventType.getRes then
		local name1 = name or itemData.params[1]
		local pames2 = itemData.params[2]
		-- local resData = FuncGuildExplore.getCfgDatas( "ExploreResource",pames2 )
		return FuncTranslate._getLanguageWithSwap(record,name1,pames2)--GameConfig.getLanguage(resData.translateId))
	elseif eventData.type == FuncGuildExplore.eventType.eliteMonster then
		local name1 = name or itemData.params[1]
		local pamse2 = itemData.params[2] or "羞羞的精英怪"
		-- local resData = FuncGuildExplore.getCfgDatas( "ExploreMonster",pamse2 )
		-- local name3 = GameConfig.getLanguage(resData.name)
		return FuncTranslate._getLanguageWithSwap(record,name1,pamse2)
	elseif eventData.type == FuncGuildExplore.eventType.deathMonster then
		local name1 = name or itemData.params[1]
		local pamse2 = itemData.params[2] or "羞羞的精英怪"
		-- local resData = FuncGuildExplore.getCfgDatas( "ExploreMonster",pamse2 )
		-- local name3 = GameConfig.getLanguage(resData.name)
		return FuncTranslate._getLanguageWithSwap(record,name1,pamse2)
	end

end



--事件跳转到对应的界面
function GuildExploreEventModel:eventJumpToView(itemData)
	local eventData = FuncGuildExplore.getCfgDatas( "ExploreRecord",itemData.tid)
	-- dump(itemData,"事件跳转到对应的界面 ======")
	-- dump(eventData,"=====eventModel  data 事件======")
	if eventData.type == FuncGuildExplore.eventType.mine then
		-- echo("=======跳转到采矿界面=========")
		-- GuildExploreEventModel:showMineUI(itemData,false)
		local eventModel = GuildExploreModel:getEventData( itemData.funParams[2])
		-- dump(eventModel,"========采矿  ===  地图事件=======")
		if eventModel then
			self:showControler(eventModel)
		end
	elseif eventData.type == FuncGuildExplore.eventType.build then
		local eventModel = GuildExploreModel:getEventData( itemData.funParams[2])
		-- dump(eventModel,"========建筑  ===  地图事件=======")
		if eventModel then
			self:showControler(eventModel)
		end

	elseif eventData.type == FuncGuildExplore.eventType.getRes then
	elseif eventData.type == FuncGuildExplore.eventType.eliteMonster then
		local eventModel = GuildExploreModel:getEventData( itemData.funParams[2])
		-- dump(eventModel,"========精英怪  ===  地图事件=======")
		self:showControler(eventModel)
	end
end


function GuildExploreEventModel:showControler(eventModel)
	local pos = eventModel.pos
	local x,y = FuncGuildExplore.getPosByKey( pos )
	local controler = GuildExploreModel.controler
	if controler  then
		controler.mapControler:setFollowToTargetByGrid( x,y,true)
	end
end


function GuildExploreEventModel:showResInfoView(mineID,_ctn)
	local scene = WindowControler:getCurrScene()
    currentUi = WindowsTools:createWindow("GuildExploreResTipsView",mineID)
    currentUi:addto(scene,100)

    local box = _ctn:getContainerBox()
    local cx = box.x + box.width/2
    local cy = box.y + box.height/2
    local turnPos = _ctn:convertToWorldSpaceAR(cc.p(cx,cy))
    currentUi:pos(turnPos.x - 100,turnPos.y)
    currentUi:registClickClose(nil,nil,true,true)
    currentUi:startShow(_ctn)
end


--获得显奖励数据结构
function GuildExploreEventModel:getShowRewardUIData(rewardData)
	local newreward = {}
	if rewardData then
		for k,v in pairs(rewardData) do
			local resType = k
			local num = v
			local res = FuncGuildExplore.getResStrIdByType(resType)
			local rew = res..","..num
			table.insert(newreward,rew)
		end
		return newreward
	end
	return nil
end



--插入事件列表数据
function GuildExploreEventModel:setEventListData(eventModel)

	local data  = {
		maxIndex = #self.eventListData + 1,
		eventList = {
				eid = eventModel.id,
				tid = eventModel.eventListId or eventModel.tid,
				ctime = TimeControler:getServerTime() + 1300,
				params = {UserModel:name( ),eventModel.tid},
				functionParam = nil,
				serveTime = TimeControler:getServerTime(),

			},

	}
	table.insert(self.eventListData,data)
end





--显示矿脉
function GuildExploreEventModel:showMineUI(eventModel,isJump,cellFunc)

	-- echo("========eventModel.tid=====矿脉====",eventModel.tid)

	local function callBack(event)
		if event.result then
			-- dump(event.result,"=======获取==矿脉数据 ======",eventModel.tid)
			local data = event.result.data
			local allData = {
				isJump = isJump or false,
				mineData = data, --self.mineAllData[tonumber(eventModel.tid)],
				eventModel = eventModel,
			}
			if not cellFunc then
				WindowControler:showWindow("GuildExploreMiningView",allData);
			else
				cellFunc(allData)
			end
		end
	end

	local pamses = {
		eventId = eventModel.id,
	}
	-- echo("=========获取矿脉协议==========")
	GuildExploreServer:getMineDataById(pamses,callBack)
end




--获得数据显示建筑界面
function GuildExploreEventModel:showBuildUI(eventModel,cellFunc)


	local function callBack(event)
		if event.result then
			-- dump(event.result,"=======获取==建筑数据 ======")
			local allData = event.result.data
			allData.eventModel = eventModel
			if not cellFunc  then
				WindowControler:showWindow("GuildExploreBuildMainView",allData)
			else
				if cellFunc then
					cellFunc(allData)
				end
			end
		end
	end
	local pamses = {
		eventId = eventModel.id,
	}

	GuildExploreServer:getBuildingData(pamses,callBack)
end

--显示事件列表
function GuildExploreEventModel:showMapEventUI(isShowWind,callFunc)
	local function callBack(event)
		if event.result then
			-- dump(event.result,"=======获取==事件数据列表======")
			local allData = event.result.data
			if isShowWind then
				WindowControler:showWindow("GuildExploreEventView",allData)
			end
			if callFunc then
				callFunc(allData)
			end
		else

		end
	end

	local params = {
		startIndex = 1,
		endIndex = 15
	}
	GuildExploreServer:getMapEventList(params,callBack)
end

--显示探索的排行榜数据
function GuildExploreEventModel:showRankUI()
	local function callBack(event)
		if event.result then
			-- dump(event.result,"=======获取==排行榜数据列表======")
			local allData = event.result
			allData.type = FuncGuildExplore.rankType.resRank
			WindowControler:showWindow("GuildExploreRankView",allData)
		else

		end
	end
	

	local params = {
		startRank = 1,
		endRank = 10,
		type = FuncGuildExplore.rankType.resRank,
	}

	GuildExploreServer:getguildExploreRankData(params,callBack)

end


--跳转成功返回
function GuildExploreEventModel:challengSuccessful(eventModel,_type)
	--本地测试返回数据
	local eventId = eventModel.id
	local monsterId = eventModel.tid
	local newRewardArr = FuncGuildExplore.getMonsterReward(monsterId)
	WindowControler:showWindow("RewardSmallBgView", newRewardArr);
	WindowControler:showTips("挑战成功")--GameConfig.getLanguage("#tid_guild_004"))
	for k,v in pairs(newRewardArr) do
		local res = string.split(v, ",")
		if tonumber(res[1]) == FuncGuildExplore.guildExploreResType then
			GuildExploreModel:setResCount(tonumber(res[2]),res[3])
		end
	end
	local count = 0
	local num = 0--FuncGuildExplore.getFuncData("ExploreMonster",monsterId,"triggerNum")
	if _type == FuncGuildExplore.gridTypeMap.enemy then
		if self.littleMonster[eventId] then
			local challengCount = self.littleMonster[eventId].challengCount
			self.littleMonster[eventId].challengCount = challengCount  + 1
		else
			self.littleMonster[eventId] = {}
			self.littleMonster[eventId] = {
				challengCount = 1,
				monsterId = monsterId,
			}
		end

		num = FuncGuildExplore.chellengOrdinaryMonsterCount
		count =  self.littleMonster[eventModel.id].challengCount
		-- dump(self.eliteMonster,"========普通怪数据======")
	elseif _type == FuncGuildExplore.gridTypeMap.elite then
		if self.eliteMonster[eventId] then
			local challengCount = self.eliteMonster[eventId].challengCount
			self.eliteMonster[eventId].challengCount = challengCount  + 1
		else
			self.eliteMonster[eventId] = {}
			self.eliteMonster[eventId] = {
				challengCount = 1,
				monsterId = monsterId,
			}
		end
		-- dump(self.eliteMonster,"========精英怪数据======")
		count =  self.eliteMonster[eventModel.id].challengCount
		num = FuncGuildExplore.chellengEliteMonsterCount
	end

	
	if  count >= num then
		local key =  FuncGuildExplore.getKeyByPos(eventModel.x,eventModel.y )

		local tempData = {
			mapInfo = {
				cells = {
						[key] = {eventList = 1}
					},
				events = {
					[eventModel.id] = 1
				}
			}
		}
		-- echo("======删除地图上的事件=========")
		GuildExploreModel:deleteData( tempData )
	end


	GuildExploreModel:removeBuffList()
	EventControler:dispatchEvent(GuildExploreEvent.RES_EXCHANGE_REFRESH)

end

--邀请挑战怪物
function GuildExploreEventModel:invitationChallengMonster(eventModel)
	
end




---设置邀请精英怪的CD
function GuildExploreEventModel:setitationChallengMonsterCD(_type,time)
	if not self.itationChallengMonsterCD then
		self.itationChallengMonsterCD = {}
	end
	self.itationChallengMonsterCD[_type] = time
end


function GuildExploreEventModel:getitationChallengMonsterCD(_type)
	if self.itationChallengMonsterCD then
		return self.itationChallengMonsterCD[_type] or 0
	else
		return 0
	end
end



---仙盟探索事件任务是否完成
function GuildExploreEventModel:isGuildExploreQuestFinish(taskId)
		
	local questData = FuncGuildExplore.getFuncData( "ExploreQuest",taskId)
	local condition = questData.condition
	local num = condition[2]
	local notFilishNum = 0
	if questData.conditionType == FuncGuildExplore.fileTaskType then
		local cost = 0 --消耗的精力
		notFilishNum = cost
		if cost >= num then
			return true
		end
	elseif  questData.conditionType == FuncGuildExplore.getRes then
		local getResNum = 0 --拾取资源数量
		killEliteBoss = getResNum
		if getResNum >= num then
			return true
		end
	elseif  questData.conditionType == FuncGuildExplore.occupationMineCount then
		local getMineNum = 0 --占领矿脉数量
		killEliteBoss = getMineNum
		if getMineNum >= num then
			return true
		end

	elseif  questData.conditionType == FuncGuildExplore.occupationMineTime then
		local getMineTime = 0 --占领矿脉时长
		killEliteBoss = getMineTime
		if getMineTime >= num then
			return true
		end
	elseif  questData.conditionType == FuncGuildExplore.killMonster then
		local killBossNum = 0 --击杀怪物数量
		killEliteBoss = killBossNum
		if killBossNum >= num then
			return true
		end
	elseif  questData.conditionType == FuncGuildExplore.eliteMonster then
		local challengElite = 0 --挑战精英怪
		killEliteBoss = challengElite
		if challengElite >= num then
			return true
		end

	elseif  questData.conditionType == FuncGuildExplore.drinkingHippocrene then
		local drinkingHippocrene = 0 --饮用灵泉
		killEliteBoss = drinkingHippocrene
		if drinkingHippocrene >= num then
			return true
		end
	elseif  questData.conditionType == FuncGuildExplore.equipmentIntensify then
		local strengtheningEquipment = 0 --强化任意装备X次
		killEliteBoss = strengtheningEquipment
		if strengtheningEquipment >= num then
			return true
		end

	elseif  questData.conditionType == FuncGuildExplore.killEliteMonsterCount then
		local killEliteBoss = 0 --击杀精英怪次数
		notFilishNum = killEliteBoss
		if killEliteBoss >= num then
			return true
		end
	end


	return false,notFilishNum

end

--设置可挑战的怪物数据
function GuildExploreEventModel:setMonsterEventModel(eventModel)
	self.challengMonsterData = eventModel
end

--取可挑战的怪物数据
function GuildExploreEventModel:getMonsterEventModel()
	return self.challengMonsterData
end

--设置怪物击杀后可以领取的奖励
function GuildExploreEventModel:setMonsterGetReward(eventModel)
	self.monsterGetReward = eventModel
end

--获取击杀怪物后可以领取的奖励
function GuildExploreEventModel:getMonsterGetReward()
	return self.monsterGetReward or {}
end


--邀请次数
function GuildExploreEventModel:setInviteNumber(eventId)
	self.playInviteArr[tonumber(eventId)] = true
end

--获取邀请次数
function GuildExploreEventModel:getInviteNumber(eventId)
	return self.playInviteArr[tonumber(eventId)] or false 
end



--建筑数据保存
function GuildExploreEventModel:setcityData(data)
	self.setcityAllData = data
end

--建筑数据获取
function GuildExploreEventModel:getcityData()
	return  self.setcityAllData
end



--设置界面下标
function GuildExploreEventModel:setBuildPosGroup(index)
	self.group_index = index
end

function GuildExploreEventModel:getBuildPosGroup()
	return  self.group_index
end

--已派遣数据返回
function GuildExploreEventModel:showGuildExploreCheckDispatchView(callFunc)
	local function callBack(event)
		if event.result then
			-- dump(event.result,"======已派遣数据返回=======")
			local data = event.result.data.occupyList
			if not callFunc then
				WindowControler:showWindow("GuildExploreCheckDispatchView",data or {});
			else
				if callFunc then
					callFunc(data)
				end
			end
		end
	end

	local params = {}
	GuildExploreServer:getOccupyRecord(params,callBack)
end






return GuildExploreEventModel