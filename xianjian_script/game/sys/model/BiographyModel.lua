--[[
	奇侠传记Model
	author: lcy
	add: 2018.7.20
	
	user = {
		biography = {
			node1 = { -- 节点id 能索引到对应奇侠
				status = int -- 宝箱状态 0不可领，1可领，2已领取
				current = {
					hid = int -- 当前进行的子节点
					num = int -- 进度值 （某些任务会存进度）
				}
			}
		}
	}

	userext{
		biographyNodeId -- 当前正在进行的任务的Id -- 可索引到partner
	}
]]

local BiographyModel = class("BiographyModel", BaseModel)

function BiographyModel:ctor()
	
end

function BiographyModel:init(d)
	BiographyModel.super.init(self, d)
	
	-- 在这里初始化一下控制器
	-- BiographyControler:startWork()
	BiographyControler:registerFixedEvent()
end

-- 获取当前正在进行的任务Id
function BiographyModel:getCurrentNodeId()
	return tostring(UserExtModel:biographyNodeId())
end

-- 当前是否有正在进行的任务
function BiographyModel:isHasTaskInHand()
	return self:getCurrentNodeId() ~= "0"
end

--[[
	获取任务状态信息
]]
function BiographyModel:getNodeInfo(nodeId)
	local nodeInfo = self:get(nodeId)
	-- 没有的话自己给一份默认的
	if not nodeInfo then
		self:set(tostring(nodeId), self:getDefault(nodeId))
	end

	return self:get(nodeId)
end

--[[
	获取正在进行的任务信息
	return partnerId,当前任务节点,当前进行到的子节点(int)，进度值(int)
]]
function BiographyModel:getCurrentTaskInfo()
	if not self:isHasTaskInHand() then return end

	local curNodeId = self:getCurrentNodeId()
	local partnerId = FuncBiography.getBiographyValueByKey(curNodeId, "partner")
	local nodeInfo = self:getNodeInfo(curNodeId)

	return partnerId, curNodeId, nodeInfo.current.hid, nodeInfo.current.curNum
end

--[[
	判断某任务是否满足接取条件
	和不满足的原因
]]
function BiographyModel:isNodeIdCanFetch(nodeId)
	local partnerId = FuncBiography.getBiographyValueByKey(nodeId, "partner")
	local partner = PartnerModel:getPartnerDataById(partnerId)
	local condition = FuncBiography.getBiographyValueByKey(nodeId, "condition")

	if not partner then return false, {t = 0,v = 0} end

	local function checkCondition(partner, con)
		if not partner then return false end
		
		local trans = {"level", "quality", "star"}

		if trans[con.t] then
			return partner[trans[con.t]] >= con.v
		end

		if con.t == 4 then
			return self:getNodeInfo(tostring(con.v)).status ~= 0
		end
	end

	for _,c in ipairs(condition) do
		if not checkCondition(partner, c) then return false, c end
	end

	return true
end

-- 根据partnerId获取做到最远的任务索引
function BiographyModel:getMaxIdxByPartner(partnerId)
	local taskData = FuncBiography.getTaskByPartnerId(partnerId)
	for idx,nodeId in ipairs(taskData or {}) do
		local nodeInfo = BiographyModel:getNodeInfo(nodeId)
		-- 这一个还没做，或者已经是最后一个了
		if nodeInfo.status == 0 or idx == #taskData then
			return idx,nodeId
		end
	end

	return 0
end

-- 根据partnerId获取是否存在接取的任务
function BiographyModel:hasPickUpTask(partnerId)
	if not partnerId then return false end
	local pId = BiographyModel:getCurrentTaskInfo()

	return partnerId == pId
end

--[[
	根据partnerId获取是否有未领取的宝箱
	不传partnerId则判断所有人中是否有宝箱可以领取
]]
function BiographyModel:hasBoxCanGet(partnerId)
	if not partnerId then return false end
	if partnerId then
		local taskData = FuncBiography.getTaskByPartnerId(partnerId)
		for _,nodeId in ipairs(taskData or {}) do
			if self:getNodeInfo(nodeId).status == 1 then
				return true
			end
		end
	else
		-- 遍历是否有箱子
		for nodeId,info in pairs(self:data() or {}) do
			if info.status == 1 then
				return true
			end
		end
	end

	return false
end

--[[
	根据partnerId获取是否有可领取的任务
]]
function BiographyModel:isHasTaskCanGet(partnerId)
	-- 系统没开
	if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.BIOGRAPHY) then return false end
	-- 有正在做的任务不能领取其他任务
	if self:isHasTaskInHand() then return false end

	local taskData = FuncBiography.getTaskByPartnerId(partnerId)
	for idx,nodeId in ipairs(taskData or {}) do
		local nodeInfo = self:getNodeInfo(nodeId)
		if nodeInfo.status == 0 and self:isNodeIdCanFetch(nodeId) then
			return true
		end
	end

	return false
end

-- 更新
function BiographyModel:updateData( ... )
	BiographyModel.super.updateData(self, ...)
	-- 更新界面
	-- echoError("更新了")
	EventControler:dispatchEvent(BiographyUEvent.EVENT_REFRESH_UI)
end
-- 添加
function BiographyModel:addData( ... )
	BiographyModel.super.addData(self, ...)
	-- 更新界面
	-- echoError("添加了")
	EventControler:dispatchEvent(BiographyUEvent.EVENT_REFRESH_UI)
end
-- 删除
function BiographyModel:deleteData( ... )
	BiographyModel.super.deleteData(self, ...)
	-- 更新界面
	-- echoError("删除了")
	EventControler:dispatchEvent(BiographyUEvent.EVENT_REFRESH_UI)
end

-- 取默认结构（当仅领取，尚未做任务的情况下是没有数据的）
function BiographyModel:getDefault(nodeId)
	if not nodeId then
		return nil
	end

	return {
		status = 0,
		current = {
			hid = 1,
			num = 0,
		}
	}
end

return BiographyModel