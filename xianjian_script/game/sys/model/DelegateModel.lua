--[[
	Author: lichaoye
	Date: 2017-05-26
	挂机-Model

	-- todo 可能需要存一下npc的实例 还需要保存一下npc的位置（逻辑位置1,2,3不是x,y）
	-- 新版本不需要npc了 pangkangning 2018.05.21
]]
local DelegateModel = class("DelegateModel", BaseModel)

DelegateModel.TASK_STATUS = {
	WAIT = 1,
	INHAND = 2,
	FINISH = 3,
}

function DelegateModel:init( data )
	-- dump(data, "看下挂机系统数据====")

	DelegateModel.super.init(self, data)
	self._curTaskId = nil -- 当前选中的任务Id
	self._TaskList = {} -- 任务列表
	self._OrderList = {} -- 存任务的顺序保证不退游戏的情况下NPC出现的位置不会变

	-- 需要判断等级
	if empty(data) then
		self:getData()
	else
		-- 从未请求过会没有数据
		-- DelegateModel.super.init(self, data)
		if not self:checkDataVaild(data) then
			self:getData()
		else
			self._originData = data
			self:manageData()
		end
	end
	-- 监听升级
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, self.getData, self);

    EventControler:addEventListener(DelegateEvent.DELEGATE_FINISH_CHANGE,self.updateRedPoint,self)
end
-- 符合条件获取信息
function DelegateModel:getData()
	if self:isOpen() then
		DelegateServer:getTaskList({callBack = function( data )
			DelegateModel.super.init(self, data)
			self._originData = data
			self:manageData()
			EventControler:dispatchEvent(DelegateEvent.DELEGATE_TASK_UPDATE)
			-- echo("升级了请求一次任务=====")
		end})
	end
end
function DelegateModel:isOpen( )
	local isOpen,lvl = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.DELEGATE)
	return isOpen
end
-- 重新获取任务数据
function DelegateModel:reGetDelegate()
	if self.__isSend then
		-- 请求没有回来的时候，不再请求
		return
	end
	self.__isSend = true
	DelegateServer:getTaskList({callBack = function()
		self.__isSend = false
		self:reFreshTaskList()
	end})
end


-- 刷新任务数据
function DelegateModel:reFreshTaskList()
	local delegates = table.copy(self:data())
	-- dump(delegates,"delegates====")
	--[[
		跟新数据有几种情况
		1.更新了已有的
		2.删除了旧的更新了新的
	]]

	local function findTask( sourceTb, target )
		for k,v in pairs(sourceTb) do
			if tonumber(v.id) == tonumber(target.id) then
				return k
			end
		end

		return nil
	end

	-- 找到被删除的id
	local del = {}
	for i,v in ipairs(self._TaskList) do
		if not findTask(delegates, v) then
			table.insert(del, tostring(v.id))
		end
	end
	
	local delNum = #del
	-- dump(delegates, "delegates")
	-- dump(del, "del")
	-- dump(self._TaskList, "之前")
	for k,v in pairs(delegates) do
		local idx = findTask(self._TaskList, v)
		if idx then -- 更新已有
			self._TaskList[idx] = v
			local data = FuncDelegate.getTask(v.id)
			data.taskData = v
		else -- 新加入的
			if delNum > 0 then
				-- 存放在之前被删除的某个位置 这样做是为了在不重新登录的情况下NPC不会相互交换位置
				local delId = del[delNum]
				if self._curTaskId and tonumber(self._curTaskId) == tonumber(delId) then
					-- 更新选中的id
					self._curTaskId = tostring(v.id)
				end
				local idx = self._OrderList[delId]
				self._OrderList[tostring(v.id)] = idx
				self._OrderList[delId] = nil
				delNum = delNum - 1
				self._TaskList[idx] = v
				local data = FuncDelegate.getTask(v.id)
				data.taskData = v
			end
		end
	end

	-- 重新请求数据后、理论上不会有未派遣并且任务已过期的情况
    for i=#self._TaskList,1,-1 do
		local v = self._TaskList[i]
		for k,m in pairs(del) do
			if tostring(v.id) == tostring(m) then
				table.remove(self._TaskList,i)
				echoWarn("重新请求数据后、理论上不会有未派遣并且任务已过期的情况,除非是GM命令降等级然后修改系统时间")
			end
		end
		-- 重新设置特殊任务
		if v.type == FuncDelegate.Type_Special then
			self._specialTask = v
		end
	end

	-- dump(self._TaskList, "之后")

	EventControler:dispatchEvent(DelegateEvent.DELEGATE_TASK_UPDATE)
end

-- 检查数据有效性
function DelegateModel:checkDataVaild( data )
	-- 需要加上持续时间 这个refreshTime是任务出现的时间
	local lastTime = FuncDataSetting.getDataByConstantName("DelegateTaskRefresh")
	local count = 0
	for k,v in pairs(data) do
		-- 有过期的重新请求
		if tonumber(v.refreshTime) + tonumber(lastTime) < TimeControler:getServerTime() then
			return false
		end
		if v.type ~= FuncDelegate.Type_Special then
			count = count + 1
		end
	end
	-- 检查任务数是否一致
	local openData = FuncDelegate.getDelegateOpenById(count)
	if openData and openData.delegateOpenCondition[1].v <= UserModel:level() then
		return false
	end
	return true
end

-- 组织数据
function DelegateModel:manageData()
	self._TaskList = {} --这个方式会造成NPC丢失
	self._OrderList = {}
	for k,v in pairs(self._originData) do
		-- v._DBDATA = FuncDelegate.getTask(v.id)
		table.insert(self._TaskList, v)
		if v.type == FuncDelegate.Type_Special then
			self._specialTask = v
		end
	end

	table.sort(self._TaskList, function( a, b )
		return tonumber(a.id) < tonumber(b.id)
	end)
	--这里其实拿了任务刷新的时间、并不对
	local shortTime = FuncDataSetting.getDataByConstantName("DelegateTaskRefresh") 
	for k,v in pairs(self._TaskList) do
		self._OrderList[tostring(v.id)] = k
		if  v.finishTime > 0 then
			local t = DelegateModel:getCurFinishTime(tostring(v.id)) - TimeControler:getServerTime()
			if t > 0 and t < shortTime then
				shortTime = t
			end
		end
	end
	-- -- 创建CD时间
	-- echo ("获取最短刷新的时间===:",shortTime)
	TimeControler:removeOneCd(DelegateEvent.DELEGATE_FINISH_CHANGE)
	TimeControler:startOneCd(DelegateEvent.DELEGATE_FINISH_CHANGE,shortTime ) --发送一条任务完成通知、用于主城红点显示
	self:updateRedPoint()
end
-- 获取特殊任务
function DelegateModel:getSpecialTask()
	return self._specialTask
end

-- 是否显示红点
function DelegateModel:isShowRedPoint()
	local isOpen,lvl = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.DELEGATE)
	
	if isOpen then
		for i,v in ipairs(self._TaskList) do
			-- 已经完成
			if tonumber(v.finishTime) ~= 0 and tonumber(v.finishTime) <= TimeControler:getServerTime() then
				-- 不能领取了，则不显示红点
				if self:chkIsMax() then
					return false
				end
				return true
			end
		end
	end

	return false
end
-- 更新主城红点
function DelegateModel:updateRedPoint(  )
	local isShow = self:isShowRedPoint()
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT, {redPointType = HomeModel.REDPOINT.DOWNBTN.WORLD, isShow = isShow})
end

-- 获取当前的刷新时间
function DelegateModel:getCurRefreshTime(id)
	id = id or self._curTaskId
	local taskData = self._TaskList[self._OrderList[id]] -- 服务器数据
	if not taskData then
		return tonumber(TimeControler:getServerTime()) + tonumber(lastTime)
	end
	-- 需要加上持续时间 这个refreshTime是任务出现的时间
	local lastTime = FuncDataSetting.getDataByConstantName("DelegateTaskRefresh")
	return tonumber(taskData.refreshTime) + tonumber(lastTime)
end

-- 获取当前的结束时间
function DelegateModel:getCurFinishTime(id)
	id = id or self._curTaskId
	local taskData = self._TaskList[self._OrderList[id]] -- 服务器数据
	return tonumber(taskData.finishTime)
end

-- 获取当前选中的任务ID
function DelegateModel:getCurTaskId()
	return self._curTaskId
end


-- 获取当前选中任务内容
function DelegateModel:getCurTask(id)
	local id = tostring(id or self._curTaskId)
	local taskData = table.copy(FuncDelegate.getTask(id))
	-- taskData.taskData = table.copy(self._TaskList[self._OrderList[self._curTaskId]])
	return taskData
end
-- 获取任务派遣中的伙伴
function DelegateModel:getWorkingPartner(id)
	local id = tostring(id or self._curTaskId)
	local taskData = self._TaskList[self._OrderList[id]] -- 服务器数据
	local result = {}
	for k,v in pairs(taskData.partners) do
		local data = PartnerModel:getPartnerDataById(k)
		data.power = tonumber(PartnerModel:getPartnerAbility(k))
		table.insert(result, data)
	end

	-- 排序
	table.sort(result, function( a, b )
		return self:partSortFunc( a, b )
	end)

	return result
end
--[[ 
	获取当前任务状态
	1 等待领取阶段
	2 执行任务阶段
	3 任务已完成
]]
function DelegateModel:getCurTaskStatus(id)
	local id = tostring(id or self._curTaskId)
	local taskData = self._TaskList[self._OrderList[id]] -- 服务器数据
	if tonumber(taskData.finishTime) == 0 then -- 尚未开始
		-- 暂时没判断是否过期
		return DelegateModel.TASK_STATUS.WAIT
	else
		if tonumber(taskData.finishTime) > TimeControler:getServerTime() then -- 未完成
			return DelegateModel.TASK_STATUS.INHAND
		else
			return DelegateModel.TASK_STATUS.FINISH
		end
	end
end

-- 设置当前选中的任务
function DelegateModel:setCurTaskId(id)
	self._curTaskId = tostring(id)
end

-- 获取某任务是否免费加速
function DelegateModel:isFreeSpeedUp()
	if UserModel:vip() >= FuncDelegate.getSpeedUpVip() then
		local count = CountModel:getCountByType(FuncCount.COUNT_TYPE.COUNT_TYPE_DELEGATE_TASK_VIP_SPEEDUP_TIMES)
		return count < FuncDelegate.getSpeedUpNum() -- 已使用次数小于规定次数表示可以免费
	else
		return false
	end
end
-- 是否可以加速
function DelegateModel:canSpeedUp()
	local count = CountModel:getCountByType(FuncCount.COUNT_TYPE.COUNT_TYPE_DELEGATE_TASK_SPEEDUP_TIMES)
	return count < tonumber(FuncDataSetting.getDataByConstantName("DelegateFreeSpeedMax"))
end
-- 是否有刷新次数
function DelegateModel:canRefresh()
	return self:refreshCount() < tonumber(FuncDataSetting.getDataByConstantName("DelegateRefreshMax"))
end
-- 获取刷新次数
function DelegateModel:refreshCount()
	local count = CountModel:getCountByType(FuncCount.COUNT_TYPE.COUNT_TYPE_DELEGATE_TASK_VIP_SPEEDUP_TIMES)
	return count
end
-- 获取特殊委托刷新次数
function DelegateModel:refreshSpecilaCount()
	local count = CountModel:getCountByType(FuncCount.COUNT_TYPE.COUNT_TYPE_DELEGATE_SPECIAL_TASK_REFRESH_TIMES)
	return count
end
-- 检查伙伴是否在其他任务中
function DelegateModel:isPartnerInTask(pId)
	for i,v in ipairs(self._TaskList) do
		-- 任务进行中
		if self:getCurTaskStatus(v.id) ~= DelegateModel.TASK_STATUS.WAIT then
			local partners = v.partners
			for k,v1 in pairs(partners) do
				-- 任务进行中
				if tonumber(pId) == tonumber(k) then
					return true
				end
			end
		end
	end

	return false
end

-- 伙伴排序规则
function DelegateModel:partSortFunc( a, b )
	-- 按照伙伴的规则来一遍 品质 星级 等级 战力 id
	-- if tonumber(a.quality) == tonumber(b.quality) then
	-- 	-- 星级
	-- 	if tonumber(a.star) == tonumber(b.star) then
	-- 		-- 等级
	-- 		if tonumber(a.level) == tonumber(b.level) then
	-- 			-- 战力
	-- 			if tonumber(a.power) == tonumber(b.power) then
	-- 				-- id
	-- 				return tonumber(a.id) < tonumber(b.id)
	-- 			end
				return tonumber(a.power) > tonumber(b.power)
	-- 		end
	-- 		return tonumber(a.level) > tonumber(b.level)
	-- 	end
	-- 	return tonumber(a.star) > tonumber(b.star)
	-- end
	-- return tonumber(a.quality) > tonumber(b.quality)
end

-- 获取符合条件得伙伴列表
function DelegateModel:getAllPartners(taskId)
	local taskId = taskId or self._curTaskId
	-- 当前任务内容
	local taskData = FuncDelegate.getTask(taskId)
	-- 原始数据
	local originData = table.copy(PartnerModel:getAllPartner())
	local result = {}
	-- 获取伙伴可被派出次数
	-- local sendTimes = tonumber(FuncDataSetting.getDataByConstantName("DelegatePartnerSendNum"))
	-- pangkangning 2017.10.10 策划需求说没有派出次数限制，所以现在就写999次
	local sendTimes = 999
	-- 当前系统时间
	local serverTime = tonumber(TimeControler:getServerTime())

	for k,v in pairs(originData) do
		-- todo检查是否派出并加标志
		if self:isPartnerInTask(v.id) then
			v.sendOut = 1
		else
			v.sendOut = 0
		end
		-- todo检查被派次数并加标志
		local count
		local eTime = tonumber(v.expireTime) or 0
		if eTime < serverTime then -- 过期
			count = 0
		else
			count = tonumber(v.count)
		end
		if count < sendTimes and v.sendOut == 0 then -- 次数没超没被派遣
			v.canGo = 1
		else
			v.canGo = 0
		end
		-- 不满足派遣条件
		if not self:checkPartnerCanGo(v, taskId) then
			v.canGo = -1
		end
		v.recommend = 0

		-- 如果是特殊任务，推荐伙伴也需要设置
		if taskData.taskType == FuncDelegate.Type_Special then
			v.recommend = 0
			for k,m in pairs(taskData.specialAppointPartner) do
				if tostring(v.id) == tostring(m) then
					v.recommend = 1
					break
				end
			end
		end

		-- 算一下战力
		v.power = tonumber(PartnerModel:getPartnerAbility(v.id))
		table.insert(result, v)
	end
 
	local sortFunc = function (a, b)
		-- 是否可以派出
		if a.canGo == b.canGo then
			-- 是否被推荐
			if a.recommend == b.recommend then
				-- 是否已被派出
				if a.sendOut == b.sendOut then
					return self:partSortFunc(a, b)
				end
				return a.sendOut < b.sendOut
			end
			return a.recommend > b.recommend
		end
		return a.canGo > b.canGo
	end
	table.sort(result, sortFunc)

	return result
end

-- 判断某伙伴是否满足某任务上阵条件
function DelegateModel:checkPartnerCanGo( partner, taskId )
	-- local taskId = taskId or self._curTaskId
	-- -- 上阵条件
	-- local condition = FuncDelegate.readTask(taskId, "condition")
	-- if condition then
	-- 	condition = string.split(condition[1], ",")
	-- 	-- 1 等级 2 星级 3 品阶
	-- 	local trans = {"level", "star", "quality"}
	-- 	return partner[trans[tonumber(condition[1])]] >= tonumber(condition[2])
	-- end

	return true
end

-- 获取任务列表
function DelegateModel:getAllTask( )
	return self._TaskList or {}
end
-- 获取是否刷新提示
function DelegateModel:getNormalTip(  )
	return self._normalTip
end
function DelegateModel:setNormalTip( b )
	self._normalTip = b
end
function DelegateModel:getSpecialTip(  )
	return self._speciallTip
end
function DelegateModel:setSpecialTip( b )
	self._speciallTip = b
end

-- 任务是否达到最大可完成任务
function DelegateModel:chkIsMax( )
    local curr = CountModel:getDelegateCont()
    local max = FuncDataSetting.getNormalTaskNum()
    return curr >= max
end
return DelegateModel
