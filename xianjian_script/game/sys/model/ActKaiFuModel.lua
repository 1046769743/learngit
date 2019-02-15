-- 开服抢购 model


local ActKaiFuModel = class("ActKaiFuModel", BaseModel)

function ActKaiFuModel:init(d)
	ActKaiFuModel.super.init(self, d)
	self.data = d 
	self.firstShowRed = true
	EventControler:addEventListener(TimeEvent.TIMEEVENT_HAS_OVER_DAY,self.getQianggouData,self)
	
	self:getQianggouData( )
end

-- 判断是否已经购买了
function ActKaiFuModel:checkGetted(day,index)
	local key = self:getDataKey(day, index)
	if not key then
		return false
	end
	if self.data and self.data[key] then
		return true
	end
	return false
end

function ActKaiFuModel:updateData(data)
	ActKaiFuModel.super.updateData(self, data)

	dump(data, "ppppppp", 5)
	if data and self._data then
		table.deepMerge(self._data,data)
	end
end



function ActKaiFuModel:getDataKey(day, index)
	return string.format("%s_%s", day, index)
end

function ActKaiFuModel:setFirstShowRed(_bool)
	self.firstShowRed = _bool
end

function ActKaiFuModel:getFirstShowRed()
	
	return self.firstShowRed
end

function ActKaiFuModel:kaifuRed()
	local allData = FuncActivity.getRushBuyConfig( )
	for i,v in pairs(allData) do
		for index=1,2 do
			local red = self:checkRed(i,index )
			if red and self.firstShowRed then
				return true
			end
		end
	end
	return false
end

--开服抢购 小页签红点
function ActKaiFuModel:smallRed( day )
	for index=1,2 do
		local red = self:checkRed(day,index )
		if red then
			return true
		end
	end
	return false
end

function ActKaiFuModel:checkRed(day,index )
	if self:isBuyItem(day,index) then
		return true
	end
	return false
end
-- 是否可购买 
-- 0 可以   1 还未开放 2 已经购买过  3 已经售罄 4 仙玉不足
function ActKaiFuModel:checkBuyCondition(day,index)
	local serverInfo = LoginControler:getServerInfo()
	local haveOpenDay = UserModel:getCurrentDaysByTimes(serverInfo.openTime)
	echo("haveOpenDay =============== day============= ",haveOpenDay,day)
    if tonumber(haveOpenDay) >= tonumber(day) then
        if ActKaiFuModel:checkGetted(day,index) then
            return 2
        else
            if self:getQianggouDataByidAndIndex(day,index )<=0 then -- 判断是否卖完
                return 3
            end
            local xianjia = FuncActivity.getRushBuyCostById( day,index )
            if UserModel:getGold() >= xianjia then
		        return 0
	        else
		        return 4
	        end
        end
        
    else
        return 1
    end
end

-- 只返回可以购买的
function ActKaiFuModel:isBuyItem(day,index)
	local serverInfo = LoginControler:getServerInfo()
	local haveOpenDay = UserModel:getCurrentDaysByTimes(serverInfo.openTime)
    if tonumber(haveOpenDay) >= tonumber(day) then
        if ActKaiFuModel:checkGetted(day,index) then
        	return false
        else
        	if self:getQianggouDataByidAndIndex(day,index )>0 then -- 判断是否卖完
                return true
            end
        end
    end
    return false
end

function ActKaiFuModel:upDataQianggouData( data )
	if data then
		table.deepMerge(self.salesInfo,data)
	end
end

function ActKaiFuModel:setQianggouData( data )
	if data then
		self.salesInfo = data
	end
end
function ActKaiFuModel:getQianggouData( )
	-- echoError("qingqiu kaifu shuju ===========")
	ActivityServer:getKaiFuQianggouData({}, c_func(self.qianggouDataCallBack,self))
end
function ActKaiFuModel:qianggouDataCallBack( event )
	if event.result then
		local salesInfo = event.result.data.salesInfo
		self.salesInfo = salesInfo
		-- dump(salesInfo, "抢购回来的数据	====", 5)
	end
	EventControler:dispatchEvent(ActivityEvent.ACTEVENT_KAIFU_QIANGGOU_DATA)
end
function ActKaiFuModel:getQianggouDataByidAndIndex(id,index )
	if self.salesInfo and self.salesInfo[tostring(id)] then
		if self.salesInfo[tostring(id)][tostring(index)] then
			return self.salesInfo[tostring(id)][tostring(index)]
		end
	end
	return 0
end
function ActKaiFuModel:isHasQianggouData( )
	if self.salesInfo then
		local serverInfo = LoginControler:getServerInfo()
		local days = UserModel:getCurrentDaysByTimes(serverInfo.openTime)
		echo("当前开服天数 === ",days)
		if days >=0 then
			local todayData = FuncActivity.getRushBuyById( days )
			if todayData then
				return true
			end
		end	
	end
	return false
end
return ActKaiFuModel












