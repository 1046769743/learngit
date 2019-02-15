--
-- Author: SunJiacheng
-- Date: 2018-03-23
-- 资源找回数据类

--资源找回数据类
local RetrieveModel = class("RetrieveModel",BaseModel)
function RetrieveModel:init( d )

-- 	"reward" = {
-- -                 1 = "1000,1,40201,1,1"
-- -                 2 = "1000,1,40202,1,1"
-- -                 3 = "1000,1,40203,1,1"
-- -                 4 = "1000,1,40204,1,1"
-- -             }

	-- d = {
	-- 		["tower"] = {
	-- 			["reward"] ={
	-- 				[1] = "1,19001,1",
	-- 				[2] = "1,19002,1",
	-- 				[3] = "1,40201,1",
	-- 				[4] = "1,40201,1",
	-- 			},
	-- 			["costGold"] = 100
	-- 		},
	-- 		["pvp"] = {
	-- 			["reward"] ={
	-- 				[1] = "1,40201,1",
	-- 				[2] = "1,40202,1",
	-- 			},
	-- 			["costGold"] = 100
	-- 		},
	-- 		["trial"] = {
	-- 			["reward"] ={
	-- 				[1] = "1,40201,1",
	-- 			},
	-- 			["costGold"] = 100
	-- 		},
	-- 		["endless"] = {
	-- 			["reward"] ={
	-- 				[1] = "1,40201,1",
	-- 				[2] = "1,40202,1",
	-- 				[3] = "1,40201,1",
	-- 			},
	-- 			["costGold"] = 100
	-- 		},
	-- 	}

	-- for k,v in pairs(d) do
	-- 	v.id = k
	-- end

	RetrieveModel.super.init(self,d)
	-- dump(self._data,"资源找回数据")
end

function RetrieveModel:setRetrieveData(data)
	-- dump(data,"yyyyyyyyyy")
    -- for k,v in pairs(data) do
    -- 	for kk,vv in pairs(self._data) do
    -- 		if kk == k then
    -- 			-- self._data[kk] = data[k]
    -- 			for kkk,vvv in pair(vv) do
    -- 				if vvv.complete and vvv.complete == 1 then
    -- 					self._data[kk].complete = 1
    -- 				end
    -- 			end
    -- 		end
    -- 	end
    -- end
    for kk,vv in pairs(self._data) do
    	if kk == data then
    		vv.complete = 1
    	end
    end
end

function RetrieveModel:getRetrieveData()
	local data = self._data
	-- dump(data, "data ==========")
	local retData = {}
	for k,v in pairs(data) do
		local num = #retData +1
		retData[num]= table.copy(v)
		retData[num].id = k
	end
	local sortData = self:sortData(retData)

	---- 可领取的放在前面
	local tmpArr = {}
	local len = table.length(sortData)
	for i = len, 1, -1 do
		if table.length(sortData[i].reward) ~= 0 then
			table.insert(tmpArr,sortData[i])
			table.remove(sortData,i)
		end
	end

	for k,v in pairs(tmpArr) do
		table.insert(sortData,1,v)
	end

	return sortData
end

function RetrieveModel:getFuncTxt( id )
	local data = FuncCommon.getSysOpenData()
	-- dump(data,"ddddddddd")
	for k,v in pairs(data) do
		if id == k then
			return v.xtname
		end
	end
	return nil
end

-- 获取功能的图片
function RetrieveModel:getFuncImage( id )
	local data = FuncCommon.getSysOpenData()
	-- dump(data,"ddddddddd")
	for k,v in pairs(data) do
		if id == k then
			return v.resRetrieveIcon
		end
	end
	return nil
end

function RetrieveModel:getRedRot()
	if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.RETRIEVE) then
		return false
	end
	for kk,vv in pairs(self._data) do
    	if vv.complete ~= 1 and next(vv.reward) then
    		return true
    	end
    end
    return false
end

-- 获取展示顺序
function RetrieveModel:getFuncSort( id )
	local data = FuncCommon.getSysOpenData()
	
	for k,v in pairs(data) do
		if v.retrieveOrder and v.retrieveOrder == tostring(id) then
			return k
		end

	end
	return nil
end

function RetrieveModel:sortData(data )
	
	for k,v in pairs(data) do
		if v.id == "tower" then
			table.remove(data,k)
		end
	end

	local openSys = {}

	for k,v in pairs(data) do
		if FuncCommon.isSystemOpen(v.id) then
			table.insert(openSys, v)
		end
	end

	local sortTable = {}
	for i=1,9 do
		local key = RetrieveModel:getFuncSort(i)
		-- echo("------------系统::"..key)
		if key then
			for k,v in pairs(openSys) do
				if key == v.id then
					table.insert(sortTable,v)
					break
				end
			end
		end
	end
	return sortTable
end

-- 刷新界面
function RetrieveModel:updateData(data)
	-- dump(data,"服务端同步刷新资源找回数据")
	for k,v in pairs(data) do
		for kk,vv in pairs(self._data) do
			if kk == k then
				if v.costGold then
					vv.costGold = v.costGold
				end
				if v.complete then
					vv.complete = v.complete
				end
				if v.reward then
					vv.reward = v.reward
				end
			end
		end
	end
	-- self._data = data

	EventControler:dispatchEvent(ActivityEvent.ACTEVENT_RETRIEVE_ITEM)
end

return RetrieveModel