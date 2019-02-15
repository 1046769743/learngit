--[[
	奇侠传记静态配表数据
	author: lcy
	add: 2018.7.20
]]

FuncBiography = FuncBiography or {}

local Biography = nil
local BiographyEvent = nil
local BiographyNode = nil

function FuncBiography.init()
	Biography = Tool:configRequire("biography.Biography")
	BiographyEvent = Tool:configRequire("biography.BiographyEvent")
	BiographyNode = Tool:configRequire("biography.BiographyNode")
end

local function getTemp( config )
	for k,v in pairs(config) do
		return k
	end

	return "none"
end

function FuncBiography.getBiographyValueByKey(id, key)
	local t1 = Biography[tostring(id)]
	if t1 == nil then
		local tmp = getTemp(Biography)
		echoError("FuncBiography.getBiographyValueByKey id not found ",id," use",tmp)
		t1 = Biography[tmp]
	end

	return t1[tostring(key)]
end

function FuncBiography.getBiographyNodeValueByKey(id1, id2, key)
	local t1 = BiographyNode[tostring(id1)]
	if t1 == nil then
		local tmp = getTemp(BiographyNode)
		echoError("FuncBiography.getBiographyNodeValueByKey id1 not found ",id1," use",tmp)
		t1 = BiographyNode[tmp]
		-- return nil
	end

	local t2 = t1[tostring(id2)]
	if t2 == nil then
		local tmp = getTemp(t1)
		echoError("FuncBiography.getBiographyNodeValueByKey id2 not found ",id2," use",tmp)
		t2 = t1[tostring(tmp)]
	end

	return t2[tostring(key)]
end

function FuncBiography.getBiographyEventValueByKey(id, key)
	local t1 = BiographyEvent[tostring(id)]
	if t1 == nil then
		local tmp = getTemp(BiographyEvent)
		echoError("FuncBiography.getBiographyEventValueByKey id not found ",id," use",tmp)
		t1 = BiographyEvent[tmp]
	end

	return t1[tostring(key)]
end

-- 根据伙伴获取任务节点顺序
function FuncBiography.getTaskByPartnerId(partnerId)
	local partner = FuncPartner.getPartnerById(partnerId)
	if partner then
		return partner.biography
	else
		echoError("没有伙伴数据",partnerId)
		return nil
	end
end

-- 根据节点获取事件参数
function FuncBiography.getEventsByNodeAndStep(nodeId,step)
	local eventId = FuncBiography.getBiographyNodeValueByKey(nodeId, step, "eventid")
	return BiographyEvent[tostring(eventId)]
end

-- 获取玩法说明
function FuncBiography.getGuide()
	return "#tid_biography_1005"
end

-- 获取界面左侧title
function FuncBiography.getTitle()
	return "#tid_biography_1014"
end

-- 接取条件,这几个文字
function FuncBiography.getCondition()
	return "#tid_biography_1015"
end

-- 获取放弃标题和文本
function FuncBiography.getGiveUp()
	return "#tid_biography_1010","#tid_biography_1011"
end

-- 获取有正在进行的传记的提示
function FuncBiography.getHasBiographyTips()
	return "#tid_biography_1016"
end

-- 奖励预览标题
function FuncBiography.getRewardTitle()
	return "#tid_shenqi_012"
end

--[[
	根据condition返回描述的tid
	0伙伴1等级2品质3星级
]]
function FuncBiography.getDesByCondition(condition)
	local trans = {
		[0] = "#tid_biography_1006",
		[1] = "#tid_biography_1007",
		[2] = "#tid_biography_1008",
		[3] = "#tid_biography_1009",
	}

	return trans[condition.t]
end

return FuncBiography