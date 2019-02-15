-- 幸运转盘
local LuckyGuyModel = class("LuckyGuyModel",BaseModel)

-- function LuckyGuyModel:init()
--     LuckyGuyModel.super.init(self)
--     self:registerEvent()
-- end

function LuckyGuyModel:registerEvent()
	LuckyGuyModel.super.registerEvent(self)
    -- 跨天时要判断是否触发转盘
    EventControler:addEventListener(TimeEvent.TIMEEVENT_HAS_OVER_DAY,self.oneDayPass,self)
end

-- 一天过期 检测是否触发转盘
function LuckyGuyModel:oneDayPass()
    EventControler:dispatchEvent(LuckyGuyEvent.LUCKYGUY_IS_OPEN_EVENT)
end

-- 买券
function LuckyGuyModel:bugTicket( num )

	local function _callBack( event )
		if event.result then
			dump(event.result,"======购买券返回数据========")
			EventControler:dispatchEvent(LuckyGuyEvent.LUCKYGUY_REFRESH_MONEY_TXT)
			WindowControler:showTips("购买成功")
		else
			WindowControler:showTips("购买失败")
		end
	end

	local params = {
		num = num
	}

	LuckyGuyServer:bugTicket( params,_callBack )
end

--抽奖
function LuckyGuyModel:playAward( type,id )
	local function _callBack( event )
		if event.result then
			dump(event.result,"======抽奖返回数据========")
			local num = event.result.data.dirtyList.u.userExt.rouletteLucky
			if num then
				EventControler:dispatchEvent(LuckyGuyEvent.LUCKYGUY_REFRESH_LUCKNUMBER_EVENT,{num = num})
			end
			if event.result.data and event.result.data.reward then
				local reward = event.result.data.reward
				EventControler:dispatchEvent(LuckyGuyEvent.LUCKYGUY_PLAY_REWARD_EVENT,{reward = reward})
			end
			if type == FuncLuckyGuy.PLAYTYPE.PLAY_FREE then
				EventControler:dispatchEvent(LuckyGuyEvent.LUCKYGUY_REFRESH_MAIN_RED)
			end
		else
			if event.error then
				if event.error.code == 10094 then
					WindowControler:showTips("活动已结束")
				end
			end
			EventControler:dispatchEvent(LuckyGuyEvent.LUCKYGUY_PLAY_SUCCESS_EVENT)
		end
	end

	local params = {
		type = type,
		id = id
	}

	LuckyGuyServer:playAward( params,_callBack )
end


function LuckyGuyModel:getActEndTime()
	local tmp,endTime = FuncLuckyGuy.getSystemHide()
	local time = endTime - TimeControler:getServerTime()
	if time <= 0 then
		time = 0
	end
	return time
end


function LuckyGuyModel:isOpenAct()
	local tmp,endTime,startTime = FuncLuckyGuy.getSystemHide()
	local nowTime = TimeControler:getServerTime()
	if tonumber(nowTime) >= startTime and tonumber(nowTime) <= endTime then
		return true
	end
	return false
end

return LuckyGuyModel