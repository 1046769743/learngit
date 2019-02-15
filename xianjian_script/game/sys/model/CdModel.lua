local CdModel = class("CdModel", BaseModel)

CdModel.CD_ID = {
	-- CD_ID_NEWLOTTERY_TOKEN_FREE = 1,--令牌抽卡免费时间
    -- CD_ID_PVP_DOWN_LEVEL = 7,     --PVP系统 user-level 低于某等级（50）cd id
    CD_ID_PVP_UP_LEVEL = 2,       --PVP系统, 目前这个数据已经不和VIP,LEVEL挂钩了,只表示单纯的一个时间冷却标志
    -- CD_ID_LOTTERY_TOKEN_FREE = 3, --令牌抽卡免费时间
    CD_ID_LOTTERY_GOLD_FREE = 4,  --钻石抽卡免费时间
    CD_ID_TOWER_AUTO_FIGHT_TIME = 5,  --扫荡时间
    CD_ID_PVP_NEW_TIMER = 6,        --新版本,PVP系统VIP低于6时计时器
    CD_ID_NEWLOTTERY_TOKEN_FREE = 1,
}

function CdModel:init(d)
	CdModel.super.init(self, d)
	local id_map = CdModel.CD_ID
	local serverTime = TimeControler:getServerTime()
	for cd_id_key, id in pairs(id_map) do
		id = id..''
		d[id] = d[id] or {}
		local modelData = d[id]
		local expireTime = modelData.expireTime or 0
		--local data = 
		local leftTime = expireTime - serverTime
		if leftTime > 0 then
			TimeControler:startOneCd(cd_id_key, leftTime)
		end
	end
end

function CdModel:getCdExpireTimeById(cdId)
	local cds = self._data 
	for k,v in pairs(cds) do
		if tostring(k) == tostring(cdId) then
			return v.expireTime or 0
		end
	end
	return 0
end

--根据id获取剩余cd时间
function CdModel:getLeftCdTime(cdId)
	local expireTime = self:getCdExpireTimeById(cdId)
	return expireTime - TimeControler:getServerTime()
end

function CdModel:updateData(data)
	CdModel.super.updateData(self, data)
	--数据更新时自动开启cd
	local serverTime = TimeControler:getServerTime()
	for cd_id, info in pairs(data) do
		local eventKey = self:getCdTimeEventKeyByCdId(cd_id)
		local expireTime = info.expireTime or 0
		TimeControler:startOneCd(eventKey, expireTime - serverTime)
	end
end

function CdModel:deleteData(data)
	CdModel.super.deleteData(self, data)
	for k, v in pairs(data) do
		local eventKey = self:getCdTimeEventKeyByCdId(k)
		TimeControler:startOneCd(eventKey, 0)
	end
end

function CdModel:getCdTimeEventKeyByCdId(cdId)
	cdId = tostring(cdId)
	for eventKey, id in pairs(CdModel.CD_ID) do
		if cdId == tostring(id) then
			return eventKey
		end
	end
end

return CdModel
