--
--Author:      zhuguangyuan
--DateTime:    2018-05-22 16:39:22
--Description: 名册系统动态数据处理类
--

local HandbookModel = class("HandbookModel", BaseModel)

function HandbookModel:ctor()
end

-- local userHandbooks = self:getUserHandbookData()
 -- ==========userHandbooks" = {
 --     "1" = {
 --         "level"     = 1
 --         "positions" = {
 --             1 = ""
 --             2 = ""
 --             3 = ""
 --         }
 --			"ability" = 11
 --     }...
 -- }



 
HandbookModel.hasInitData = true

function HandbookModel:init(d)
	HandbookModel.super.init(self, d)
	--初始化所有的默认数据	
	for k,v in pairs(FuncHandbook.dirType) do
		if not self._data[tostring(v)] then
			local tempDir = {
				["level"] = 1,
				["positions"] = {
					["1"] = "",
					["2"] = "",
					["3"] = "",
				},
				["addAbility"] = 0,
			}
			self._data[tostring(v)] = tempDir
		end
	end

	self:registerEvent()
	self:onePartnerPosChanged()
end



--删除数据
function HandbookModel:deleteData( data ) 
	HandbookModel.super.deleteData(self,data);
end




-- ========================================================================
-- 红点逻辑
-- ========================================================================
-- 判断某个名册下是否有空闲阵位
function HandbookModel:isHasFreePosition( dirId )
	local freeIndex = {}
	local dirData = self:getDirDatas(dirId)
	if not dirData then
		return freeIndex
	end
	local posStatus = dirData.positions
	if posStatus and table.length(posStatus)>0 then
		for i=1,5 do
			local partnerId = posStatus[tostring(i)]
			if partnerId == "" then
				freeIndex[#freeIndex + 1] = i
			end
		end
	end
	return freeIndex
end

-- 判断某个名册下是否有可上阵的空闲奇侠
-- 返回数组
function HandbookModel:isHasFreePartners( dirId,needToSort )
	local freePartners = {}
	local selfDirPartners = self:getAllOwnPartnersInOneDir(dirId)

	if selfDirPartners and table.length(selfDirPartners)>0 then
		for k,partnerId in pairs(selfDirPartners) do
			local workDir = self:getOnePartnerWorkingDir(partnerId)
			if workDir == "" then
				freePartners[#freePartners + 1] = partnerId
			end
			
		end
	end
	-- dump(freePartners, "========= 排序前 freePartners", nesting)
	if table.length(freePartners)>0 and needToSort then
		local function sortFunc(a,b)
			local pa = PartnerModel:getPartnerAbility(a)
			local pb = PartnerModel:getPartnerAbility(b)
			return pa > pb
		end
		table.sort(freePartners,sortFunc)
	end
	-- dump(freePartners, "========= 排序后 freePartners", nesting)
	for k,v in ipairs(freePartners) do
		local pa = PartnerModel:getPartnerAbility(v)
	end
	-- dump(freePartners,"____freePartners")
	return freePartners
end

-- 是否显示红点 - 名册下有阵位可上奇侠
function HandbookModel:isShowDirRed( dirId )
	local freeIndex,freePartnerId = nil,nil
	freeIndex = self:isHasFreePosition( dirId )

	local needLevel = FuncHandbook.getUnlockLevel( dirId )
	if UserModel:level()< needLevel then
		return false
	end

	if freeIndex and table.length(freeIndex)>0 then
		freePartnerId = self:isHasFreePartners( dirId )
	end
	if freePartnerId and table.length(freePartnerId) >0 then
		return true
	else
		return self:isDirCanUpLevel(dirId)
	end
end

--某个dir是否能升级
function HandbookModel:isDirCanUpLevel(dirId  )
	--如果有可以升级的名册
	local dirLevel = self:getOneDirLevel( dirId )
	if dirLevel == 16 then
		return false
	end
	local dirData = FuncHandbook.getOneDirLvData( dirId,dirLevel )
	-- echo("dirLevel ================= ",dirLevel)
	-- dump(dirData,"dirData ================ ")
	local isConditionOk = UserModel:isResEnough(dirData.cost)
	--满足条件就显示小红点
	if isConditionOk == true then
		return true
	end
	return false

end


-- 是否显示红点 - 名册总红点
function HandbookModel:isShowHandbookRed()
	local dirs = FuncHandbook.dirType
	for k,dirId in pairs(dirs) do
		local isShow = self:isShowDirRed( dirId )
		if isShow then
			return isShow
		end
	end
	return false
end



function HandbookModel:updateData( data )
	HandbookModel.super.updateData(self,data)

    EventControler:dispatchEvent(HandbookEvent.HANDBOOK_DATA_UPDATA,data)
    self:onePartnerPosChanged()
end

-- ========================================================================
-- 监听消息
-- ========================================================================
function HandbookModel:registerEvent()
    -- 获得新奇侠
    EventControler:addEventListener(PartnerEvent.PARTNER_NUMBER_CHANGE_EVENT, self.getNewPartner, self)
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.getNewPartner, self)
    
    -- 奇侠上阵下阵及换阵
    -- EventControler:addEventListener(HandbookEvent.ONE_PARTNER_ENTER_FIELD, self.onePartnerPosChanged, self)
    -- EventControler:addEventListener(HandbookEvent.ONE_PARTNER_LEAVE_FIELD, self.onePartnerPosChanged, self)
    -- EventControler:addEventListener(HandbookEvent.ONE_PARTNER_EXCHANGE_FIELD, self.onePartnerPosChanged, self)
end

function HandbookModel:getNewPartner( event )
	self:onePartnerPosChanged()
end

function HandbookModel:onePartnerPosChanged( event )

	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
		{redPointType = HomeModel.REDPOINT.DOWNBTN.HANDBOOK, isShow = HandbookModel:isShowHandbookRed()})

end

-- ========================================================================
-- 其他接口函数
-- ========================================================================
-- 获取一个名册的等级
function HandbookModel:getOneDirLevel( dirId )
	local oneDirData = self:getDirDatas(dirId)
	if oneDirData and oneDirData.level then
		return oneDirData.level
	else
		return 1
	end
end

-- 获取一个名册的占位情况
function HandbookModel:getOneDirPositionStatus( dirId )
	local oneDirData = self:getDirDatas(dirId)
	if oneDirData and oneDirData.positions then
		return oneDirData.positions
	end
end

-- 获取一个名册上阵奇侠数
function HandbookModel:getEnterFieldInOneDir( dirId )
	local num = 0
	local oneDirData = self:getDirDatas(dirId)
	if oneDirData then
		local positionsStatus = oneDirData.positions
		for index,inplacePartnerId in pairs(positionsStatus) do
			if tostring(inplacePartnerId) ~= "" then
				num = num + 1
			end
		end
	end
	return num
end

-- 获取某一系别的所有已拥有的奇侠
function HandbookModel:getAllOwnPartnersInOneDir( dirId )
	local partnerdata = PartnerModel:getAllPartner()
	local tb = {}
	for k,v in pairs(partnerdata) do
		local partnerConfigData = FuncPartner.getPartnerById(k)
		local dir1,dir2 = partnerConfigData.type,partnerConfigData.elements
		dir1 = FuncHandbook.Attack2DirType[tostring(dir1)]
		dir2 = FuncHandbook.Wuling2DirType[tostring(dir2)]
		if dirId == dir1 then
			table.insert(tb, k)
		elseif dirId == dir2  then
			table.insert(tb, k)
		end
	end
	return tb
	
end

-- 获取某一奇侠当前所在系别
function HandbookModel:getOnePartnerWorkingDir( partnerId )
	for k,v in pairs(self._data) do
		for kk,vv in pairs(v.positions) do
			if vv == partnerId then
				return  k
			end
		end
	end

	return ""
end


--获取某个名册下的信息
function HandbookModel:getDirDatas( dirId )
	return self._data[tostring(dirId)] 
end




return HandbookModel