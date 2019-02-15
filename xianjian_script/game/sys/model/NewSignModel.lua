--[[
	Author: lichaoye
	Date: 2017-05-10
	签到-Model
]]
local NewSignModel = class("NewSignModel", BaseModel)


function NewSignModel:init( data )
	NewSignModel.super.init(self, data)
	-- 凌晨4点强行弹窗（先注释掉）
	-- self:initCdRefresh()

end

-- 初始化刷新事件
function NewSignModel:initCdRefresh()
	-- 处理四点刷新的事
	local curTime = TimeControler:getServerTime()
	local dates = os.date("*t", curTime)
	-- 每天几点几分刷新
	local targetH = FuncCount.getHour(FuncCount.COUNT_TYPE.COUNT_TYPE_SIGN_RECEIVE_RETIO)
	local targetM = FuncCount.getMinute(FuncCount.COUNT_TYPE.COUNT_TYPE_SIGN_RECEIVE_RETIO) or 0
	targetH = tonumber(targetH)
	targetM = tonumber(targetM)

	local leftTime = 0
	local oneDay = 24 * 60 * 60
	-- 当天对应时间的时间戳
	local todayTargetStamp = os.time({year=dates.year, month=dates.month, day=dates.day, hour=targetH, min = targetM})

	if curTime >= todayTargetStamp then -- 过点了
		leftTime = oneDay - (curTime - todayTargetStamp)
	else -- 没到时间
		leftTime = todayTargetStamp - curTime
	end

	TimeControler:startOneCd(QuestEvent.QUEST_CHECK_SP_EVENT, leftTime)
end

function NewSignModel:getYearMonthDay()
    local serverTime = TimeControler:getServerTime()
    --todo 读表3
    -- 每天几点几分刷新
    local targetH = FuncCount.getHour(FuncCount.COUNT_TYPE.COUNT_TYPE_SIGN_RECEIVE_RETIO)
    local targetM = FuncCount.getMinute(FuncCount.COUNT_TYPE.COUNT_TYPE_SIGN_RECEIVE_RETIO) or 0
    targetH = tonumber(targetH)
    targetM = tonumber(targetM)

    local timestampOffset = -targetH * 60 * 60 - targetM * 60 -- 减targetH小时
    local relativeTime = serverTime + (timestampOffset or 0)
    --几月
    local dates = os.date("*t", serverTime)
    local month = dates.month
    local year = dates.year
    local day = dates.day
    return year, month, day
end

-- 累计签到次数
function NewSignModel:totalSignCount()
    return UserExtModel:totalSignDays() or 0
end

-- 当前奖励领取情况
function NewSignModel:nowTotalReceiveDetail()
	local receiveDetails = UserExtModel:totalSignDaysReceiveDetail() or {}
	-- 未初始化过取表中前3个
	if empty(receiveDetails) then
		receiveDetails = {}
		for i=1,3 do
			local tmp = FuncNewSign.getTotalByIdx(i)
			receiveDetails[tmp.day] = 0
		end
	end

	local result = {}
	-- 转换格式 get 领取情况 0未领 1 普通奖励 2 vip双倍奖励
	for day,get in pairs(receiveDetails) do
		table.insert(result, {
			data = FuncNewSign.getTotalByDay( day ),
			isGet = tonumber(get)
		})
	end

	table.sort(result, function(a,b)
		return tonumber(a.data.index) < tonumber(b.data.index)
	end)

	return result
end

-- 今日签到奖励
function NewSignModel:getTodayReward()
	local year, month, day = self:getYearMonthDay()

	return FuncNewSign.getMonthValue(year, month, day, "reward")
end

-- 今日是否签到
function NewSignModel:isTodaySigned()
	local count = CountModel:getCountByType(FuncCount.COUNT_TYPE.COUNT_TYPE_SIGN_RECEIVE_RETIO)
    if count == nil then 
        count = 0
    end

    return count > 0
end

-- 当月签到次数
-- function NewSignModel:monthSignCount()
--     local count = CountModel:getCountByType("10")
--     if count == nil then 
--         return 0
--     else 
--         return count
--     end
-- end

-- 更新广播列表
function NewSignModel:udpateBroadList(list, cover)
	list = list or {}
	if cover then
		self._broadList = {}
		-- 过滤错误值
		for i,v in ipairs(list) do
			if not empty(v) then
				table.insert(self._broadList, v)
			end
		end
	else
		if not self._broadList then self._broadList = {} end
		for i,v in ipairs(list) do
			if not empty(v) then
				table.insert(self._broadList, v)
			end
		end
	end

	table.sort(self._broadList, function(a, b)
		return tonumber(a.time) > tonumber(b.time)
	end)

	-- 如果大于20取前20
	if #self._broadList > 20 then
		for i=21,#self._broadList do
			self._broadList[i] = nil
		end
	end
end
-- 广播列表
function NewSignModel:getBroadList()
	if not self._broadList then self._broadList = {} end
	return self._broadList
end

-- 今日最佳奖励
function NewSignModel:getTodayBest()
	return self:getTodayReward()[FuncNewSign.LABEL.BEST]
end

-- 检查是否可领双份奖励
function NewSignModel:isVipEnable( vip )
	return UserModel:vip() >= tonumber(vip)
end

-- 判断一个detail是否可领取
function NewSignModel:isDetailCanGet( detail )
	local totalSignCount = NewSignModel:totalSignCount()
	local vip = UserModel:vip()

	if detail.isGet == 0 then -- 未领取
		return totalSignCount >= tonumber(detail.data.day)
	elseif detail.isGet == 1 then -- 已进行普通领取
		return vip >= tonumber(detail.data.vip) 
	elseif detail.isGet == 2 then -- 已完全领取
		return false
	end
end

-- 是否有可领取物品
function NewSignModel:isItemToGet()
	local details = NewSignModel:nowTotalReceiveDetail()

	for i,v in ipairs(details) do
		if self:isDetailCanGet(v) then
			return true
		end
	end

	return false
end

-- 是否显示每日签到红点
function NewSignModel:isNewSignRedPoint()
  	if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.SIGN) then
    	return NewSignModel:isItemToGet() or not NewSignModel:isTodaySigned()
  	else
    	return false
  	end
  
end

-- 显示签到的接口
function NewSignModel:autoShowSign()
	if not NewSignModel:isTodaySigned() then
		WindowControler:showWindow("NewSignView")
	end
end

-- 设置签到抽奖奖励
function NewSignModel:setSignReward(reward)
	self.signReward = reward
end

-- 获取签到奖励
function NewSignModel:getSignReward()
	return self.signReward
end

-- 清空抽奖数据
function NewSignModel:clearSignReward()
	self.signReward = nil
end

return NewSignModel