--
-- Author: xd
-- Date: 2018-07-03 11:32:56
-- 数据格式 
--[[
	{
		mapInfo = {
			cells = {
				[x*10000+y] = {
					terrain = 101, 	--地形 string, 如果没有就是0, 这个值不可被更怪
					block = 0, 		-- int,是否可走, 0或者空可走,1不可走.
					events = {
						{	

							-- {id = 111,tid =101,type=1,visible = 1}, 		--服务器返回的数据格式
							{tid =101,type=1}, 	--客户端生成的地形数据
						}
					}
					x = 1,			-- int
					y = 1,			-- int网格对应坐标
					sub = 1001 		--int 从属于哪个格子 默认为空
					child = {10001,...} 	-- 他拥有的子节点
					mists = 1 		--是否是迷雾 ,1 是迷雾,0 是已探索
					alpha = 0 		--是否是迷雾边缘半透. 0 是非边缘, 1 是边缘. 如果是迷雾而且 边缘了 那么就显示半透效果
				}
				[10*10000+5] = {x=10,y= 5} -- key是int ,值为10000*x+y
			}
			
			mapId = 	1001		--地图id
			randomSeed =100001 		-- 地图随机数


			events = {
				id = {
					type = 1,	--string ,0表示空格子. 如果这个格子的怪物被击杀后或者材料被拾取后 需要把type置空为0 
					tid = 101,		--string对应类型的id ,这里不用id的原因是 防止和系统默认id冲突
					visible = 1		--1是可见,0是不可见
					--地图事件显示需要参数
					params = {
						--type = 3时
						--血量万分比
						levelHpPercent = 9000,  	
						--type为4时
						finishTime = 100003, --秒级时间戳
						state1 ,0-未占领 1-被他人占领 2-被自己占领
						state2,
						state3,
					}

				}
			}

			--所有的玩家数据
			roles = {
				rid = {   
					pos = {
						moveTime = 32325012232,
						target= 10001, 		-- 所有的坐标存储结构 x*10000+y
						source =20001,
						positionList = {30001,20001},
					}
					userInfo = {
						
					}
				}
			}
			--工会信息
			guildInfo = {
				guildAbility = 1001,
				guildMemberCount = 5,
				guildTaskLevel = 1,
				afterName = 1,
				members = {rid:1,...		}
			}

		}
		energy = 10, 			--当前的精力
		upEnergyTime ,			-- 上一次更新精力的时间戳
		buyEnergyCount,			--购买精力次数
		
		
		buffs = {
			id = {,times}
		}
		
		--装备
		equipInfo = {
	
		}

		--整个地形网格宽高
		width = 30,
		height = 30,
		-- 资源
		resources = {1,1,2,3}		
		--奇侠数据
		partners = {[partnerId] = partnerJson}
		--血量信息
		unitInfo = {
                {   
                	hid = "1",   --如果是主角 就是"1" ,如果是伙伴就是对应伙伴的partnerId
                    --血量万分比
                    hpPercent = 9999,
                    userRid = "rid",	--如果是雇佣兵.那么这个rid 写对应雇佣兵从属玩家的rid,现在默认是玩家自己的rid
                }
        }
		
		--雇佣兵血量信息，teamFlag:1怪物、2真实玩家数据 3机器人 ,后面扩展需要
        employeeInfo=
        {
        	{hid = "101",hpPercent = 1000,teamFlag = 1}
        }

        ability = , --个人战力
		guildAbility = ,--仙盟前10 的战力

		--buff列表
		mapBuffs = {
			[tid] = {tid  = ,count = , expireTime = },
			[tid] = {tid  = ,count = , expireTime = },
		}
		--任务相关
		taskProcess = {conditionType = ,process = }
		taskReward = {[key] = valuer 1 已领取}
		--仙盟任务
		taskGuildProcess = {conditionType = ,process = }
	}

]]


local GuildExploreModel = class("GuildExploreModel", BaseModel)

--方形迷雾map
GuildExploreModel._rectMistMap = nil


function GuildExploreModel:init( d )
	GuildExploreModel.super.init(self,d)
	GuildExploreServer:init()
	self:registerEvent()
	
	self._rectMistMap = {}

	local isopen = FuncGuildExplore.isOnTime()
	self.entranceRed = isopen   ---活动入口红点

	--如果没有地图信息 那么说明是本地测试
	-- dump(d,"11111111111111")
	if not self._data.mapInfo then
		-- self:initOneMap()
		return
	else
		local mapId = self._data.mapInfo.mapId
		local seed = self._data.mapInfo.randomSeed
		local randonMapInfo = FuncGuildExplore.getOneRandomMap(mapId,seed)
		local mapInfo = randonMapInfo.cells
		local cells = self._data.mapInfo.cells

		--如果是显示日志的 那么比较做一下本地数据校验
		if DEBUG_LOGVIEW and self._data.mapInfo.debugInfo then
			--比较下数据
			for k,v in pairs(self._data.mapInfo.debugInfo.mapInfo ) do
				local selfInfo  = mapInfo[tonumber(k)]
				if not selfInfo then
					if k ~= "eventArr" then
						echoError("战斗服数据和本地数据不一样,本地没有这个数据",mapId,seed,k,"请同步服务器配表以及新建工会测试")
					end
					
				else
					if selfInfo.block ~= v.block then
						echoError("战斗服数据和本地数据不一样",mapId,seed,k,"请同步服务器配表以及新建工会测试")
						break
					end
				end
			end

		end



		--删除所有的事件
		for k,v in pairs(mapInfo) do
			v.eventIdList =nil
		end

		--这里需要进行数据转化
		for k,v in pairs(cells) do
			local tempTb =mapInfo[tonumber(k)]
			if not tempTb then
				echoError("服务器有这个数据,但是客户端生成的地图里面没有这个数据",k,"mapId",mapId)
				tempTb = {}
				mapInfo[tonumber(k)] = tempTb
			end
			for ii,vv in pairs(v) do
				tempTb[ii] =vv
			end
		end

		--初始化迷雾 半透区域
		ExplorePosTools:initCountAlphaMistsPoints(mapInfo )
		--重新给mapInfo赋值
		self._data.mapInfo.cells = mapInfo
		self._data.mapInfo.width = randonMapInfo.width
		self._data.mapInfo.height = randonMapInfo.height
	end
	self:initSomeInfo()


end

function GuildExploreModel:getEntranceRed()
	local openTime = LoginControler:getServerInfo().openTime 
	local isOpenServerTime = UserModel:getCurrentDaysByTimes(openTime)
	local num = FuncGuildExplore.getSettingDataValue( "ExploreSysOpen","num" ) or 2
	if tonumber(isOpenServerTime) >= tonumber(num) then
	else
		self.entranceRed = false
	end

	return self.entranceRed or false
end
function GuildExploreModel:setEntranceRed(isShow)
	self.entranceRed = isShow
	EventControler:dispatchEvent(GuildExploreEvent.GUILDE_EXPLORE_ROKOU_RED_FRESISH)
	
end



function GuildExploreModel:registerEvent()
	EventControler:addEventListener("notify_explore_role_offlineReward", self.upDataofflineReward, self)
	EventControler:addEventListener("notify_explore_task_pushProcess", self.taskListNotify, self)
end
function GuildExploreModel:taskListNotify(event)
	local newData = event.params.params
	-- dump(newData,"任务推送数据 ============")
	local _type = newData.type 
	local conditionType = newData.conditionType
	local process = newData.process
	if _type == FuncGuildExplore.taskType.single then
		self:setTaskProcessByType(conditionType,process)
	elseif _type == FuncGuildExplore.taskType.manyPeople then
		self:setGuildTaskProcessByType(conditionType,process)
	end
	EventControler:dispatchEvent(GuildExploreEvent.GUILD_EXPLORE_TASK_REFRESH)
end
--设置控制器
function GuildExploreModel:setControler( controler )
	self.controler = controler
end


function GuildExploreModel:upDataofflineReward(e)
	local newData = e.params.params
	-- dump(newData,"离线奖励推送数据 ============")
	local data = self._data.offLineReward or  {}
	local offLineReward = newData.offLineReward
	if not data then
		self._data.offLineReward = {}
	end
	table.insert(data,offLineReward[1])
	local data = {offLineReward = {}}
	self:updateData( data )
	-- dump(self._data.offLineReward,"==========当前离线奖励====")
end




--初始化角色信息
function GuildExploreModel:initSomeInfo(  )
	--存储这些常量是为了加快访问速度
	self.recoveryTime =FuncGuildExplore.getSettingDataValue("ExploreRecoveryTime","num")
	self.exploreEnergyLimit =FuncGuildExplore.getSettingDataValue("ExploreEnergyLimit","num")
	self.exploreInitialEnergy =FuncGuildExplore.getSettingDataValue("ExploreInitialEnergy","num")
	self.exploreEnergyUp =FuncGuildExplore.getSettingDataValue("ExploreEnergyUp","num")


	if not self._data.mapInfo.roles then
		self._data.mapInfo.roles = {}
	end
	local rid = UserModel:rid()
	if not self._data.mapInfo.roles[rid]  then
		if not LoginControler:isLogin() then
			self._data.mapInfo.roles[rid] = {
				pos = {
					moveTime = 32325012232,
					target= tostring(10*10000+10), 		-- 所有的坐标存储结构 x*10000+y
					source =tostring(20*10000+20),
					positionList = {"30001","20001"},
				},
				userInfo = UserModel._data,
				--即将要到达的点
				targetPos = {1000,1000},
				energy = 100,		--剩余精力
			}
		end
		
	end


	for k,v in pairs(self._data.mapInfo.roles) do
		v.rid = k
	end

	

	self._data.energy = self._data.energy or 100
	self._data.upEnergyTime = self._data.upEnergyTime or  TimeControler:getServerTime() - 100
	self._data.resources = self._data.resources or {}
	self._data.partnerInfo = self._data.partnerInfo or  {}
	self._data.mapBuffs = self._data.mapBuffs or  {}
	self._data.equipInfo = self._data.equipInfo or {}
	self._data.taskProcess = self._data.taskProcess or {}
	self._data.taskGuildProcess = self._data.taskGuildProcess or {}

	self._data.partners = self._data.partners or {}

	
	--初始化矩形迷雾
	ExploreGridControler:init(self._data.mapInfo.cells)

	--所有主角的初始坐标是可以探开的
	for k,v in pairs(self._data.mapInfo.roles) do
		local targetPos = v.pos.source
		local x,y = FuncGuildExplore.getPosByKey(targetPos)
		ExploreGridControler:updateOneGridMists(x,y,0)
	end
	--发送一个初始化完成的消息 如果此刻正在 战场中 那么需要做数据刷新
	EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPLOREEVENT_INITCOMPLETE)
	

end




--更新数据 
function GuildExploreModel:updateData( data )
	if (not self._data)  or (not self._data.mapInfo) then
		return
	end	
	GuildExploreModel.super.updateData(self,data)
	--如果是精力发生变化
	if data.energy or data.upEnergyTime then
		EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPLOREEVENT_ENERGYCHANGED,data.energy or self:getEnergy())
	end

	--资源变化
	if data.resources then
		EventControler:dispatchEvent(GuildExploreEvent.RES_EXCHANGE_REFRESH)
	end

	--离线奖励变化
	if data.offLineReward then
		EventControler:dispatchEvent(GuildExploreEvent.GUILD_EXPLORE_OFF_LINE_REWARD)
	end

	

	--更新地图数据了
	if data.mapInfo then
		if  data.mapInfo.cells then
			EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPOREEVENT_MAPCHANGE,data.mapInfo.cells)
		end
		
		--如果有事件变化
		if data.mapInfo.events then
			EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPLOREEVENT_EVENTCHANGE,data.mapInfo.events)
		end

		--如果有玩家数据变化
		if data.mapInfo.roles  then
			--发送工会1玩家变化消息
			
			--如果有坐标
			self:checkRoleMists(data.mapInfo.roles )
			EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPLOREEVENT_USERDATACHANGE,data.mapInfo.roles)
		end
	end

end
--初始化角色相关迷雾
function GuildExploreModel:checkRoleMists( roles )
	--如果有坐标
	for k,v in pairs(roles) do
		if v.pos and v.pos.positionList then
			--直接让网格管理器更新迷雾信息
			ExploreGridControler:updateMists(v.pos.positionList )
			-- ExplorePosTools:countRadioPoints(v.pos.positionList,self._data.mapInfo.cells )
		end
		if v.pos.source then
			local cellInfo = self._data.mapInfo.cells[tonumber(v.pos.source)]
			if cellInfo then
				cellInfo.mists = 0
			end
			local x,y = FuncGuildExplore.getPosByKey(v.pos.source)
			ExploreGridControler:updateOneGridMists(x,y,0)
		end
	end
end




function GuildExploreModel:deleteData( data )
	GuildExploreModel.super.deleteData(self,data)

		--更新地图数据了
	if data.mapInfo then
		if data.mapInfo.cells then
			EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPOREEVENT_MAPDELETE,data.mapInfo.cells)
		end
		if data.mapInfo.roles then
			EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPLOREEVENT_USERLEAVE,data.mapInfo.roles)
		end
	end

end



--初始化一个地形/
function GuildExploreModel:initOneMap(  )
	
	-- echoError(self.recoveryTime,self.exploreEnergyLimit,self.exploreInitialEnergy,self.exploreEnergyUp,"__dsakd")
	self._rectMistMap = {}
	--先初始化地图
	local mapData = FuncGuildExplore.getOneRandomMap("1")
	local rid = UserModel:rid()

	local pos1 = {
					moveTime = 32325012232,
					target= 40*10000+10, 		-- 所有的坐标存储结构 x*10000+y
					source =20*10000+20,
					positionList = {30001,20001},
				}

	local pos2 = {
					moveTime = 32325012232,
					target= 10*10000+10, 		-- 所有的坐标存储结构 x*10000+y
					source =20*10000+20,
					positionList = {30001,20001},
				}
	mapData.roles = {
		[rid] = {pos = pos1,userInfo = UserModel._data or {avatar = "101",name = "玩家自己"}  },
	}

	for i=1,30 do

		local tempPos = {
					moveTime = 32325012232,
					target= (20+i*4)*10000+10 + i*4, 		
					source =(20+i*3)*10000+10 + i*3,
					positionList = {source,target},
				}


			

		mapData.roles["dev_"..i] = {
			pos = tempPos,
			userInfo = {
				avatar = "101",
				name ="测试玩家"..i,
			}
		}
	end
	mapData.mapId = "1"
	local eventObj = {}
	local eventId = 0

	--初始化所有事件
	for k,v in pairs(mapData.cells) do
		--如果是有事件的
		v.mists = 0
		if v.eventList then
			local eventList = {}
			for i,v in ipairs(v.eventList) do
				eventId = eventId +1
				table.insert(eventList,eventId)
				local eventModel = {
					id = eventId,
					type = v.type,
					tid = v.tid,
					visible = 1,
				}
				eventObj[tostring(eventId)] = eventModel
			end
			v.eventList =eventList
		end
	end
	mapData.events = eventObj
	self._data = {}
	self._data.mapInfo = mapData
	self:initSomeInfo()
	self._data.ability = 100
	self._data.guildAbility = 1000
end


--获取伙伴数据
function GuildExploreModel:getPartnerData()
	return self._data.partners
end


--获取所有的地形数据
function GuildExploreModel:getAllMapData(  )
	if not self._data then
		echoError("__数据还没有初始化")
		-- self:init({})
	end
	return self._data
end


function GuildExploreModel:getMapId(  )
	return self._data.mapInfo.mapId
end


--获取某一格子的数据
function GuildExploreModel:getOneGridData( x,y )
	local key = FuncGuildExplore.getKeyByPos(x,y)
	local data = self._data.mapInfo.cells[key]
	if not data then
		echoWarn("没有这个格子数据:",x,y)
	end
	return data
end



--获得自己的战力
function GuildExploreModel:getMeAbility()
	-- echo("=======获得自己的战力=======",self._data.ability)
	return self._data.ability or 0

end


--获得仙盟前10的战力
function GuildExploreModel:getGuildAbility()
	-- echo("=======获得仙盟前10的战力=======",self._data.mapInfo.guildInfo.guildAbility)
	return self._data.mapInfo.guildInfo.guildAbility or 0
end

--获取成员的仙盟信息和 职位
function GuildExploreModel:getMemberAuth( rid )
	local guildInfo = self._data.mapInfo.guildInfo
	if guildInfo then
		return guildInfo.afterName,guildInfo.members[rid] or FuncGuild.MEMBER_RIGHT.PEOPLE
	end
	echoError("服务器没有传工会信息")
	return 1,FuncGuild.MEMBER_RIGHT.PEOPLE
end

--获取仙盟等级
function GuildExploreModel:getGuildLevel()
	local guildInfo = self._data.mapInfo.guildInfo
	if guildInfo then
		return guildInfo.guildTaskLevel
	end
	return 1
end


--获取某一格子的所有事件数据  
function GuildExploreModel:getGridEvent( x,y,withVisible )
	local data = self:getOneGridData(x,y)
	if not data then
		return nil
	end
	local events = data.eventList
	if not events then
		return nil
	end

	for i,v in ipairs(events) do
		local event = self:getEventData( v )
		if event    then
			if withVisible then
				return event
			end
			if event.visible == 1 then
				return event
			end
		end
		return nil
	end
	return nil

end




--获取原始事件数据 
function GuildExploreModel:getSubGridEvent( x,y,withVisible)
	local data = self:getOneGridData(x,y)
	if not data then
		return nil
	end
	if data.sub then
		x,y = FuncGuildExplore.getPosByKey( data.sub )
		return self:getGridEvent(x,y,withVisible )
	end
	return self:getGridEvent(x,y,withVisible )

end

--获取所有的事件数据
function GuildExploreModel:getEventData( eventId ,outCheck)
	local data = self._data.mapInfo.events[tostring(eventId)]
	if not data then
		-- dump(eventId,"___eventId")
		if not outCheck then
			echoError("__没有这个事件id对应的数据:",eventId)
		end
	end
	return data
end

--获取所有的事件数据
function GuildExploreModel:setEventData( eventId ,key,data)
	local eventdata = self._data.mapInfo.events[tostring(eventId)]
	if eventdata then
		if eventdata.params then
			self._data.mapInfo.events[tostring(eventId)].params[key] = data
			-- dump(self._data.mapInfo.events,"444444444444")
		end
	end
end

--获取我方所有玩家数据,根据需要扩展阵营
function GuildExploreModel:getAllSelfUsersDatas(  )
	return self._data.mapInfo.roles
end

--根据rid获取用户数据
function GuildExploreModel:getUserDataByRid( rid )
	return self._data.mapInfo.roles[rid]
end


--获取当前精力
function GuildExploreModel:getEnegry(  )
	--通过当前精力值 + 将要恢复的精力值 算 真实精力
	local disTime =TimeControler:getServerTime()- self._data.upEnergyTime  - 2
	disTime = disTime < 1 and 1 or disTime
	local recoveryTime = self.recoveryTime
	local addTime = math.floor(disTime/ recoveryTime)
	local rt = self._data.energy + addTime
	local maxEnery = self:getMaxEnergy()
	if rt >maxEnery  then
		rt = maxEnery
	elseif rt < 0 then
		rt = 0
	end


	return rt
end


--获取体力恢复到满时候的时间
function GuildExploreModel:getEnegryFullTimeStr(  )
	return TimeControler:getLeftFullRecoverTimeStr( self:getEnegry(),self.recoveryTime,self:getMaxEnergy() ,self._data.upEnergyTime )

end


--改变精力.这个可能是客户端直接修改的.比如本地走了一步 就需要扣一点精力
function GuildExploreModel:changeEnegry(value )
	-- self._data.energy = self._data.energy-value
	local targetValue = self._data.energy +value
	local maxValue= self:getMaxEnergy()
	if targetValue< 0 then
		-- targetValue = 0
	elseif targetValue > maxValue then
		targetValue = maxValue
	end
	self:updateData({energy = targetValue})
end

--获取最大精气值
function GuildExploreModel:getMaxEnergy(  )
	local maxNums = self.exploreEnergyLimit
	local initEnergy = self.exploreInitialEnergy
	--暂定写死5个
	local partenerNums = 5
	if LoginControler:isLogin() then
		partenerNums = PartnerModel:getPartnerNum()
	end
	local addEnergy = partenerNums * self.exploreEnergyUp
	local rt = addEnergy + initEnergy
	if rt > maxNums  then
		rt = maxNums
	end
	return rt
end

--获得资源数据
function GuildExploreModel:getResCount(type,resId)
	if tostring(type) == FuncGuildExplore.guildExploreResType then
		local dataArr = self._data.resources[tostring(type)]
		if dataArr then
			return dataArr[tostring(resId)] or 0
		end
	else
		return  self._data.resources[tostring(type)] or 0
	end
	return  0
end

function GuildExploreModel:setResCount(reward)
	-- resId = tostring(resId)

	local res = string.split(reward, ",")

	if res[1] == FuncGuildExplore.guildExploreResType then
		if tonumber(res[2]) ~= 10 then
			self._data.resources[res[1]][res[2]] = res[3]
		else
			self._data.energy = res[3] or 1
		end
	else
		if res[1] == FuncDataResource.RES_TYPE.ITEM then
			self._data.resources[res[2]] = res[3]
			self:getResStrIdByType(res[1],res[3],res[2])
		else
			self._data.resources[res[1]] = res[2]
			self:getResStrIdByType(res[1],res[2])
		end
		
		
	end


	local data  = {
		resources = {},
	}
	self:updateData( data )


end


--根据资源类型获取资源ID
function GuildExploreModel:getResStrIdByType(resType,num,itemId)

	resType = tostring(resType)
	if resType  == FuncDataResource.RES_TYPE.COIN then
		local coin = UserModel:getCoin()
		local data = {finance = {coin  = coin + num} }
		UserModel:updateData(data)
		return true
	elseif resType  == FuncDataResource.RES_TYPE.DIAMOND then
		local current = UserModel:giftGold()
		local data = {giftGold = current + num}
		UserModel:updateData(data)
		return true
	elseif resType  == FuncDataResource.RES_TYPE.WOOD then
		local wood =  GuildModel:getWoodCount()
		GuildModel:setWoodCount(wood + num)
		EventControler:dispatchEvent(GuildEvent.REFRESH_GUILD_WOOD_EVENT)
		return true
	elseif resType  == FuncDataResource.RES_TYPE.GUILD_STONE then
		local data = {stone = GuildModel:getOwnGuildStoneNum() + num}
		GuildModel:updateGuildResource(data)
		EventControler:dispatchEvent(GuildEvent.REFRESH_GUILD_RESOURCE_EVENT)
		return true
	elseif resType  == FuncDataResource.RES_TYPE.GUILD_JADE then
		local data = {jade = GuildModel:getOwnGuildJadeNum() + num}
		GuildModel:updateGuildResource(data)
		EventControler:dispatchEvent(GuildEvent.REFRESH_GUILD_RESOURCE_EVENT)
		return true
	elseif resType  == FuncDataResource.RES_TYPE.ITEM then
		-- echo("======itemId======",itemId,num)
		local data = {[itemId] =  {itemId = itemId,num = ItemsModel:getItemNumById(itemId) + num}}
		ItemsModel:updateData(data)
	end

	return false
end



---是否有奖励变化
function GuildExploreModel:isResCountChange(reward)
	local newReward = {}
	local isChange = false
	local index = 1
	for k,v in pairs(reward) do
		local res = string.split(v, ",")
		if res[1] == FuncGuildExplore.guildExploreResType then
			local count = self._data.resources[tostring(res[1])][res[2]] or 0
			if tonumber(res[3]) ~= count then
				local num = 0
				if tonumber(res[2]) ~= 10 then
					newReward[index] = res[1]..","..res[2]..","..(res[3]-count)
					num = res[3]-count
				else
					newReward[index] = res[1]..","..res[2]..","..(res[3]- self._data.energy)
					num = res[3]- self._data.energy
				end
				if num ~= 0 then
					isChange = true
					index =  index + 1
				end
			end
		else
			if #res == 2 then
				newReward[index] = res[1]..","..res[2]
				isChange = true
				index =  index + 1
			elseif #res == 3 then
				newReward[index] = res[1]..","..res[2]..","..res[3]
				isChange = true
				index =  index + 1
			end
		end
	end
	if isChange then
		return true,newReward
	end
	return false
end


--判断伙伴是否上阵状态
function GuildExploreModel:getpartnerIsHas(partnerId)

	local data = self:getUnitInfoDataByPartnerId(partnerId)
	if not data then
		return true
	else
		if data.dispatch and data.dispatch ~= "" then
			return false
		end
	end
	return true
end

--buff数据
function GuildExploreModel:getbuffList()
	local data = self._data.mapBuffs
	if data and table.length(data) == 0 then
		return false,{}
	end
	local newArr = {}
	for k,v in pairs(data) do
		if v.count then
			if v.count ~= 0 then
				table.insert(newArr,v)
			end
		end
	end
	return true,newArr
end

function GuildExploreModel:setBuffList(data)
	if not self._data.mapBuffs  then
		self._data.mapBuffs = {}
	end
	for k,v in pairs(data) do
		if v.count ~= 0 then
			self._data.mapBuffs[v.tid] = v
		else
			if self._data.mapBuffs[v.tid] then
				self._data.mapBuffs[v.tid] = nil
			end
		end
	end
	EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPLOREEVENT_HIPP_BUFF_CHANGE,data)
end

function GuildExploreModel:removeBuffList()
end


--获得所有map上的事件
function GuildExploreModel:getAlleventsData(_type)
	local newEventsList = {}
	local eventsList =  self._data.mapInfo.events
	if not _type  then
		_type = FuncGuildExplore.gridTypeMap.mine --build
	end
	for k,v in pairs(eventsList) do
		if v.type == _type  then
			table.insert(newEventsList,v)
		end
	end
	return newEventsList
end

--设置派遣数据
function GuildExploreModel:setMapSendData()
	local unitInfo = self._data.unitInfo
	for k,v in pairs(unitInfo) do
		if v.dispatch and v.dispatch ~= "" then
			self._data.unitInfo[k] = ""
		end
	end
end

--获取派遣记录
function GuildExploreModel:getMapSendFinishRewardRed()
	local dispatch = {}
	local arr = {}
	local unitInfo = self._data.unitInfo
	for k,v in pairs(unitInfo) do
		if v.dispatch and v.dispatch ~= "" then
			if not dispatch[v.dispatch] then
				dispatch[v.dispatch] = v.dispatch
			end
		end
	end
	for k,v in pairs(dispatch) do
		local eventModel = self:getEventData( v )
		table.insert(arr,eventModel)
	end
	-- dump(arr,"地图上派遣的事件")
	for k,v in pairs(arr) do
		if v.type == FuncGuildExplore.gridTypeMap.mine then
			local params = v.params
			local finishTime = params.finishTime
			if finishTime then
				local serverTime =  TimeControler:getServerTime() 
				if serverTime >= finishTime then
					return true
				end
			end
		end
	end
	return false
end





--根据伙伴ID获得伙伴详情
function GuildExploreModel:getUnitInfoDataByPartnerId(partnerId)
	if self._data.unitInfo then
		local data = self._data.unitInfo[tostring(partnerId)]
		return data
	end
	return nil
end



--上阵奇侠
function GuildExploreModel:getPantnerIsbattle(eventID)
	local unitInfo = self._data.unitInfo
	local pantnerList = {}
	local isBattle = false
	if unitInfo then
		for k,v in pairs(unitInfo) do
			if v.dispatch == eventID then
				isBattle = true
				local pantnerData = self._data.unitInfo[tostring(k)] 
				table.insert(pantnerList,pantnerData)
			end
		end
		if isBattle then
			return true,pantnerList
		end
	end

	return false,pantnerList
end

function GuildExploreModel:setPartnerInfoData(eventID,pantnerList)
	self._data.partnerInfo[eventID] = {}
	self._data.partnerInfo[eventID] = pantnerList
end




--根据伙伴ID设置伙伴详情
function GuildExploreModel:setUnitInfoDataByPartnerId(partnerId,data)
	if self._data.unitInfo then
		self._data.unitInfo[tostring(partnerId)] = data
	else
		self._data.unitInfo = {}
		self._data.unitInfo[tostring(partnerId)] = data
	end
end


--获取奇侠数据
function GuildExploreModel:getPartnersById(partnerId)
	if self._data.unitInfo then
		return self._data.unitInfo[tostring(partnerId)]
	end
	return nil
end

--刷新玩家数据
function GuildExploreModel:refreshAllPlayerData(result)
	if result then
		local buff = result.buff
		local unitInfo = result.unitInfo
		if buff then
			self:setBuffList(buff)
		end

		if unitInfo then
			for k,v in pairs(unitInfo) do
				self:setUnitInfoDataByPartnerId(k,v)
			end
		end
	end
end

--计算上阵伙伴的战力
function GuildExploreModel:getPartnersAbility(partnerList)
	local sumAbility = 0
	if partnerList then
		for k,v in pairs(partnerList) do
			if v ==  UserModel:avatar() then
				sumAbility = sumAbility + UserModel:getcharSumAbility()
			else	
				echo("======奇侠ID==v=======",v)
				local data = self:getPartnersById(v)
				if data then
					sumAbility = sumAbility + data.ability
				end
			end
		end
	end
	return sumAbility
end

--获取自己的网格坐标
function GuildExploreModel:getSelfGridPos(  )
	local roles = self._data.mapInfo.roles
	for i,v in pairs(roles) do
		if i == UserModel:rid() then
			return v.pos.target
		end
	end
	return {x=0,y=0}
end


---奖励类型的转化rewardData = {41,1,20;1,50;3,200}
function GuildExploreModel:rewardTypeConversion(rewardData)

	local ischange,getRewardData = self:isResCountChange(rewardData)

	if not ischange then
		getRewardData = rewardData
	end
	for k,v in pairs(rewardData) do
		self:setResCount(v)
	end
	-- rewardData = GuildExploreEventModel:getShowRewardUIData(getRewardData)
	return getRewardData,ischange
end


----删除事件
function GuildExploreModel:byEventModelDeleteData(eventModel)
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
	GuildExploreModel:deleteData( tempData )
end


--获取离线奖励数据
function GuildExploreModel:getoffLineReward()
	local data = self._data.offLineReward
	if not data  then
		return false
	end
	if data and table.length(data) == 0 then
		return false
	end

	local time = TimeControler:getServerTime()
	local newData = {}
	for k,v in pairs(data) do
		-- if v.type == 3  then
		-- 	table.insert(newData,v)
		-- else
			if v.expireTime > time then
				table.insert(newData,v)
			end
		-- end
	end
	if #newData == 0 then
		return false
	end

	return  true,newData
end

--设置离线奖励数据
function GuildExploreModel:setoffLineReward(id)
	local data = self._data.offLineReward
	for k,v in pairs(data) do
		if v.id == id then
			data[k] = nil
		end
	end

	local data = {offLineReward = {}}
	self:updateData( data )

end



--根据GM获得资源
function GuildExploreModel:getResGM(_type)
	local function callBack(event)
		if event.result then
			if event.result.data then
				local resource = event.result.data.resource
				
					for k,v in pairs(resource) do
						local res = string.split(v, ",")
						if res[1] == FuncGuildExplore.guildExploreResType then
							if tonumber(res[2]) ~= 10 then
								GuildExploreModel:setResCount(v)
							else
								self._data.energy = res[3] or 1
							end
						end
					end
				local data  = {
					energy = self._data.energy,
					resources = {},
				}
				self:updateData( data )
			end
		end
	end



	local params = {
		type = _type,
		count = 1500,
	}

	GuildExploreServer:getGMRes(params,callBack)
end

function GuildExploreModel:checkActivityBuyEnergy(  )
	-- body
	local activeMonthCardArr = FuncGuildExplore.getSettingDataValue("ExploreBuyEnergyMonthCard", "arr")

	if activeMonthCardArr then
		for i,v in ipairs(activeMonthCardArr) do
			--先判断是否满足月卡激活条件
			if ( MonthCardModel:checkCardIsActivity(v) )then

				return true
			end
		end
	end
	return false
end


--获取剩余能购买精力次数
function GuildExploreModel:getLeftBuyEnergyCount( )
	local count = self._data.buyEnergyCount or 0
	if self:checkActivityBuyEnergy() then
		local maxCount = FuncGuildExplore.getSettingDataValue("ExploreEnergyBuyNum","num")
		local left = maxCount-count
		if left < 0 then
			left = 0
		end
		return left
	end
	return  0

end

function GuildExploreModel:getBuyEnergyCount(  )
	return self._data.buyEnergyCount or 0
end

--获取仙盟探索布阵 奇侠以及雇佣兵等信息
function GuildExploreModel:getGuildExploreTeamFormation(_needDump)
	local tempTeamInfo = {}

    if self._data.employeeInfo then
        for k,v in pairs(self._data.employeeInfo) do
            tempTeamInfo[tostring(v.id)] = v  
        end
    end

    if _needDump then
    	-- dump(self._data.unitInfo, "\n\nself._data.unitInfo=====")
    end

    if self._data.unitInfo then
        for k,v in pairs(self._data.unitInfo) do
            tempTeamInfo[tostring(v.id)] = v  
        end       
    end

    -- 将已经被禁用的奇侠记录下来
    local banPartners = {}
    -- if self._data.banPartners and table.length(self._data.banPartners) then
    --     banPartners = self._data.banPartners
    -- end
    return tempTeamInfo, banPartners 
end



function GuildExploreModel:getequipInfoLevelArr(_type)
    local equipInfo = self._data.equipInfo
    if equipInfo then
        if  equipInfo[tostring(_type)] then
        	return equipInfo[tostring(_type)]
        end
    end
    --默认给数据测试
    local levelArr = {
        level1 = 0,
        level2 = 0,
        level3 = 0,
        tid = _type,
    }
    return levelArr
end

--设置装备升级数据
function GuildExploreModel:setEquipInfoLevel(_type,index)
	-- dump(self._data.equipInfo,"22222222222222222")
	if self._data.equipInfo then
		if self._data.equipInfo[tostring(_type)] then
			local level = self._data.equipInfo[tostring(_type)]["level"..index]
			if level then
				self._data.equipInfo[tostring(_type)]["level"..index] = level + 1
			end
		else
			self._data.equipInfo[tostring(_type)] = {
				level1 = 0,
				level2 = 0,
				level3 = 0,
				tid = _type,
			}
			local level = self._data.equipInfo[tostring(_type)]["level"..index]
			self._data.equipInfo[tostring(_type)]["level"..index] = level + 1
		end
	else
		self._data.equipInfo[tostring(_type)] = {
			level1 = 0,
			level2 = 0,
			level3 = 0,
			tid = _type,
		}
		local level = self._data.equipInfo[tostring(_type)]["level"..index]
		self._data.equipInfo[tostring(_type)]["level"..index] = level + 1
	end
	-- dump(self._data.equipInfo,"33333333333333333")
end

--判断装备红点是否可以显示
function GuildExploreModel:getEquipRed(_type,index)
	local redArr = {} 
	local levelArr = self._data.equipInfo[tostring(_type)]
	if not levelArr then
		levelArr = {
			level1 = 0,
			level2 = 0,
			level3 = 0,
		}
	end
	local level1 = levelArr.level1 or 0
	local level2 = levelArr.level2 or 0
	local level3 = levelArr.level3 or 0
	local allData = FuncGuildExplore.getCfgDatas( "ExploreEquipment",_type )
	local maxLevel = FuncGuildExplore.equipMaxLevel
	

	if allData[tostring(level1 + 1)]  then
		local  costA = allData[tostring(level1 + 1)].costA
		redArr[1] = self:getItemCountIsOk(costA)
	end

	if allData[tostring(level2 + 1)]  then
		local  costB = allData[tostring(level2 + 1)].costB
		redArr[2] = false-- self:getItemCountIsOk(costB)
	end
	if allData[tostring(level3 + 1)]  then
		local  costC = allData[tostring(level3 + 1)].costC
		redArr[3] =  false--self:getItemCountIsOk(costC)
	end

	if index then
		if redArr[tonumber(index)] then
			return true
		end
	else
		for k,v in pairs(redArr) do
			if v then
				return true
			end
		end
	end
	return false
end


function GuildExploreModel:getItemCountIsOk( cost )
	if cost then
		for k,v in pairs(cost) do
			local res = string.split(v, ",")
			local res_type = res[1]
			local resId = res[2]
			local num = 0
			local haveNum = 0

			-- dump(self._data.resources,"资源 ========= ")
			if res_type == FuncGuildExplore.guildExploreResType then
				num = res[3]
				haveNum = GuildExploreModel:getResCount(res_type,resId)
			else
				needNum,haveNum = UserModel:getResInfo( v )
				if #res == 2 then
					num = res[2]
				else
					num = res[3]
				end
			end
			if tonumber(haveNum) < tonumber(num) then
				return false
			end
		end
	else
		return false
	end
	return true
end

--单人
function GuildExploreModel:getTaskProcessByType(conditionType)
	-- dump(self._data.taskProcess,"任务类型数据===========")
	if self._data.taskProcess then
		local num = self._data.taskProcess[tostring(conditionType)]
		if num then
			return num
		end
	end
	return 0
end




--单人任务数据
function GuildExploreModel:setTaskProcessByType(conditionType,num)
	if self._data.taskProcess then
		self._data.taskProcess[tostring(conditionType)] = num
	else
		self._data.taskProcess =  {}
		self._data.taskProcess[tostring(conditionType)] = num
	end
end


--多人
function GuildExploreModel:getGuildTaskProcessByType(conditionType)
	-- dump(self._data.taskGuildProcess,"Guild任务类型数据===========")
	if self._data.taskGuildProcess then
		local num = self._data.taskGuildProcess[tostring(conditionType)]
		if num then
			return num
		end
	end
	return 0
end

--多人任务数据
function GuildExploreModel:setGuildTaskProcessByType(conditionType,num)
	if self._data.taskGuildProcess then
		self._data.taskGuildProcess[tostring(conditionType)] = num
	else
		self._data.taskGuildProcess =  {}
		self._data.taskGuildProcess[tostring(conditionType)] = num
	end
end


--获得所有任务数据
function GuildExploreModel:getAllTaskData( )
	local singeData,manyPeopleData  = FuncGuildExplore.getQuestData()
	local level =  self:getGuildLevel()

	local newSingeArr  = {}
	for k,v in pairs(singeData) do
		if v.guildCondition == level then
			table.insert(newSingeArr,v)
		end
	end

	local newManyPeopleArr  = {}
	for k,v in pairs(manyPeopleData) do
		if v.guildCondition == level then
			table.insert(newManyPeopleArr,v)
		end
	end

	return newSingeArr,newManyPeopleArr
end
 


--获取显示任务的数据
function GuildExploreModel:getShowTaskData()
	local newSingeArr,newManyPeopleArr = self:getAllTaskData( )
	local newSingeData = {}
	local newManyPeopleData = {}
	local singeData = nil
	local manyPeopleData = nil



	for k,v in pairs(newSingeArr) do
		-- if v.priority ~= 0 then
			local isFinish = self:isGetTaskIsFinish(v,FuncGuildExplore.taskType.single)
			if isFinish then
				local isget = self:isGetTaskRewardData(v.id)
				if not isget then
					singeData = v
					break
				end
			end
		-- end
	end

	for k,v in pairs(newManyPeopleArr) do
		-- if v.priority ~= 0 then
			local isFinish = self:isGetTaskIsFinish(v,FuncGuildExplore.taskType.manyPeople)
			if isFinish then
				local isget = self:isGetTaskRewardData(v.id)
				if not isget then
					manyPeopleData = v
					break
				end
			end
		-- end
	end





	local taskSData = nil
	for k,v in pairs(newSingeArr) do
		if v.priority ~= 0 then
			if v.predecessors == "0" then
				taskSData = v
				break
			end
		end
	end

	local function getSingleTaskID(_sData)
		-- dump(_sData,"111111111111")
		if _sData then
			local taskID = _sData.id
			local isFinish = self:isGetTaskIsFinish(_sData,FuncGuildExplore.taskType.single)
			if isFinish then
				local isget = self:isGetTaskRewardData(taskID)
				if isget then
					local postTaskId = _sData.postTask
					if postTaskId ~= "0" then
					-- echo("=======postTaskId=========",postTaskId)
						local data = FuncGuildExplore.getFuncData( "ExploreQuest",postTaskId)
						getSingleTaskID(data)
					end
				else
					singeData = _sData
				end
			else
				singeData = _sData
			end
		end
	end
	if not singeData and  taskSData then
		getSingleTaskID(taskSData)
	end




	local taskMData = nil
	for k,v in pairs(newManyPeopleArr) do
		if v.priority ~= 0 then
			if v.predecessors == "0" then
				taskMData = v
				break
			end
		end
	end

	local function getManyPeopleTaskID(_mData)
		if _mData then
			local taskID = _mData.id
			local isFinish = self:isGetTaskIsFinish(_mData,FuncGuildExplore.taskType.manyPeople)
			if isFinish then
				local isget = self:isGetTaskRewardData(taskID)
				if isget then
					local postTaskId = _mData.postTask
					if postTaskId ~= "0" then
						local data = FuncGuildExplore.getFuncData( "ExploreQuest",postTaskId)
						getManyPeopleTaskID(data)
					end
				else
					manyPeopleData = _mData
				end
			else
				manyPeopleData = _mData
			end
		end
	end
	if not manyPeopleData and taskMData then
		getManyPeopleTaskID(taskMData)
	end





	return singeData,manyPeopleData

end


---是否完成任务奖励
function GuildExploreModel:isGetTaskIsFinish(taskData,_type)
	local conditionType = taskData.conditionType
	local process = 0
	if _type == FuncGuildExplore.taskType.single then
		process = self:getTaskProcessByType(conditionType) --类型数量
	elseif _type == FuncGuildExplore.taskType.manyPeople then
		process = self:getGuildTaskProcessByType(conditionType) --类型数量
	end
	local condition = taskData.condition
	if process >= condition then
		return true,process
	end
	return false,process
end


---是否领取任务奖励
function GuildExploreModel:isGetTaskRewardData(taskId)
	local taskReward  = self._data.taskReward
	-- dump(taskReward,"是否领取任务奖励 =====")
	-- echo("=====taskId========",taskId)
	if taskReward then
		if taskReward[tostring(taskId)] then
			if taskReward[tostring(taskId)] == 1 then
				return true
			end
		end
	end
	return false
end

function GuildExploreModel:setGetTaskRewardData(taskId)
	if self._data.taskReward then
		self._data.taskReward[tostring(taskId)] = 1 
	else
		self._data.taskReward = {}
		self._data.taskReward[tostring(taskId)] = 1
	end
	-- dump(self._data.taskReward,"任务领取奖励类型数据==setGetTaskRewardData====")
end


--获取buff开启状态 返回一个数组 {true,true,true} 对应3个位置是否开启
function GuildExploreModel:getBuffOpenState(  )
	local openStr = OptionsModel:getOneOption(OptionsModel.optionsMap.vexplore) 
	local openArr ={false,false,false}
	local openNums 
	if  openStr  then
		local tempArr = string.split(openStr, ",")
		for i,v in ipairs(tempArr) do
			if v == "1" then
				openArr[i] = true
			end
		end
	end
	return  openArr
end

function GuildExploreModel:setPartnerIsHas(pantnerData)
	for k,v in pairs(pantnerData) do
		self._data.unitInfo[tostring(v)].dispatch = ""
	end
end



return GuildExploreModel