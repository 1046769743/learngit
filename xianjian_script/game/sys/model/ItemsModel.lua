--
-- Author: ZhangYanguang
-- Date: 2015-11-29
-- 背包、背包列表数据类

--背包数据类
local Item = class("Item",BaseModel)
function Item:init( d )
	Item.super.init(self,d)

	--注册函数  keyData
	self._datakeys = {
		id = "" , 		--id
		num = 0,		--数量
	}

	self:createKeyFunc()
end

function Item:getType()
	return FuncItem.getItemPropByKey(self:id(),"type") or 1
end

function Item:getSubType()
	return FuncItem.getItemPropByKey(self:id(),"subType_display") or 1
end

function Item:getQuality()
	local quality = FuncItem.getItemPropByKey(self:id(),"quality")
	if quality then
		return tonumber(quality)
	end
	
	return 1
end

--[[
	- 背包列表数据类
]]
local ItemsModel = class("ItemsModel",BaseModel)

function ItemsModel:init(data)
	self.modelName = "items"
    ItemsModel.super.init(self,data)
    self._items = {}

    self.boxType = {
    	TYPE_BOX_NUM_ONE = 1,
    	TYPE_BOX_NUM_TEN = 10,
	}

    -- 背包类型枚举
    self.itemType = {
    	ITEM_TYPE_ALL = 0,         		--所有
    	ITEM_TYPE_COST = 1,				--消耗
    	ITEM_TYPE_PIECE = 2,			--碎片
        ITEM_TYPE_MATERIAL = 3,         --材料
        -- ITEM_TYPE_ARTIFACT = 4,			--神器
        ITEM_TYPE_MEMORY = 4,           --情景卡碎片  不在背包中显示
	}
	
	--有新的需要展示的类型  需要扩充这两个数组
	-- 背包子类型枚举，分类展示已不用该字段
    self.itemSubTypes = FuncItem.itemSubTypes

    -- 背包子类型枚举，分类展示使用该字段
    self.itemSubTypes_New = FuncItem.itemSubTypes_New

    self._datakeys = {
    	items = nil,                	--背包列表
	}
	self:createKeyFunc()

	self:updateData(data,true)

	self:sendRedStatusMsg()
end

--更新数据
function ItemsModel:updateData(data,isInit )
	if not isInit then
		table.deepMerge(self._data,data)
	end
	local hasGetItem = false
	for k,v in pairs(data) do
		if FuncItem.isValid(k) then
			if self._items[k] == nil then
				self._items[k] = Item.new()
				if not v.id then
					v.id = k
				end
				self._items[k]:init(v)

				if not isInit then
					hasGetItem = true
					-- self:sendGetNewItemMsg()
				end
			else
				self._items[k]:updateData(v)
			end
		end
	end

	if not isInit then
		-- if hasGetItem then
			self:sendGetNewItemMsg()
		-- end
		
		EventControler:dispatchEvent(ItemEvent.ITEMEVENT_ITEM_CHANGE,data);
	end

	self:sendRedStatusMsg()
end

-- 发送获得新道具消息
function ItemsModel:sendGetNewItemMsg() 
	EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {questType = TargetQuestModel.Type.COLLECT_ITEM});
end

-- 发送小红点状态消息
function ItemsModel:sendRedStatusMsg() 
	-- 是否有可以使用的宝箱
	if ItemsModel:hasCanUseBox() then
		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            {redPointType = HomeModel.REDPOINT.DOWNBTN.BAG, isShow = true});
	else
		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            {redPointType = HomeModel.REDPOINT.DOWNBTN.BAG, isShow = false});
	end
end

--删除数据
function ItemsModel:deleteData(data) 
	--深度删除 key
	for k,v in pairs(data) do
		if self._items[k] and v == 1 then
			self._items[k] = nil;
		end
	end

	table.deepDelKey(self._data, data, 1)

	EventControler:dispatchEvent(ItemEvent.ITEMEVENT_ITEM_CHANGE, data);

	self:sendRedStatusMsg()
end

-- 通过ID获取item
function ItemsModel:getItemById(itemId)
	for k, v in pairs(self._items) do
		if tostring(k) == tostring(itemId) then
			return v
		end
	end

	return nil
end

-- 通过ID获取item的数量
function ItemsModel:getItemNumById(itemId)
	local item = self:getItemById(itemId)
	if item ~= nil then
		return item:num()
	end

	return 0
end

-- 背包是否是空的，一个道具都没有
function ItemsModel:isBagEmpty()
	local data = {};
	for k, v in pairs(self._items) do
		if not FuncItem.isConcealedItem(v._data.id) then
			return false
		end
	end

	return true
end

-- 获取道具种类的总数量
function ItemsModel:getItemTotalTypeNum()
	local totalNum = 0
	for k, v in pairs(self._items) do
		totalNum = totalNum + 1
	end

	return totalNum
end

-- 获取所有道具
function ItemsModel:getAllItems()
	local data = {};
	for k, v in pairs(self._items) do
		table.insert(data, v);
	end

	self:sortItems(data)
	return data;
end

-- 通过类型获取道具
function ItemsModel:getItemsByType(itemType)
	local data = {};
	for k, v in pairs(self._items) do
		local itype = FuncItem.getItemPropByKey(k,"type")
		if tostring(itype) == tostring(itemType) then
			table.insert(data, v);
		end
	end

	self:sortItems(data)

	return data;
end

function ItemsModel:getAllItemSubTypes()
	return self.itemSubTypes_New
end

-- 通过子类型获取背包中的物品
function ItemsModel:getItemsBySubType(itemSubtype)
	local ret = {}
	for k, v in pairs(self._items) do
		local itype = FuncItem.getItemPropByKey(k, "subType_display")
		if tostring(itype) == tostring(itemSubtype) then
			table.insert(ret, v)
		end
	end

	self:sortItems(ret)
	return ret
end

-- 道具排序
function ItemsModel:sortItems(data)
	table.sort(data,function(a,b)
		local aQuality = tonumber(a:getQuality())
		local aType = tonumber(a:getType())
		local aSubType = tonumber(a:getSubType())
		local aId = tonumber(a:id())

		local bQuality = tonumber(b:getQuality())
		local bType = tonumber(b:getType())
		local bSubType = tonumber(b:getSubType())
		local bId = tonumber(b:id())
		
		-- 先按照类型排序
		if aType < bType then
			return true
		elseif aType == bType then
			if aQuality > bQuality then
				return true
			elseif aQuality == bQuality then
				if aType > bType then
					return true
				elseif aType == bType then
					if aSubType > bSubType then
						return true
					elseif aSubType == bSubType then
						if aId > bId then
							return true
						end
					else 
						return false
					end
				end
			end
		end
		
		return false
    end)
end


-- 根据Id判断道具是否是宝箱
function ItemsModel:isBox(itemId)
	local itemData = FuncItem.getItemData(itemId)
	if tonumber(itemData.type) == self.itemType.ITEM_TYPE_COST 
		and tonumber(itemData.subType) == self.itemSubTypes_New.ITEM_SUBTYPE_100 
		and tonumber(itemData.subType_display) ~= self.itemSubTypes_New.ITEM_SUBTYPE_104 then
		return true
	end
	return false
end

--根据id判断道具是否是可选宝箱
function ItemsModel:isOptionBox(itemId)
	local itemData = FuncItem.getItemData(itemId)
	if tonumber(itemData.subType_display) == self.itemSubTypes_New.ITEM_SUBTYPE_104 then
		return true
	end
	return false
end

-- 根据Id判断道具是否显示红点
function ItemsModel:showRedPoint(itemId)
	local itemData = FuncItem.getItemData(itemId)
	-- if tonumber(itemData.subType_display) == self.itemSubTypes_New.ITEM_SUBTYPE_100 or
	-- 	tonumber(itemData.subType_display) == self.itemSubTypes_New.ITEM_SUBTYPE_104  then
	-- 	if itemData.ignoreRedPoint and tonumber(itemData.ignoreRedPoint) == 1 then
	-- 		return false
	-- 	else
	-- 		return true
	-- 	end
	-- end

	return false
end

-- 是否有可以使用的宝箱
function ItemsModel:hasCanUseBox()
	for k, v in pairs(self._items) do
		local itemId = k
		if self:showRedPoint(itemId) then
			return true
		end
	end

	return false
end

-- 检查道具是否满足使用条件
function ItemsModel:checkItemUseCondition(itemId,itemNum)
	local canUse = false
	local itemTypeBox = self.itemType.ITEM_TYPE_COST

	if itemNum == nil then
		itemNum = 1
	end

	local itype = FuncItem.getItemPropByKey(itemId,"type")

	-- 宝箱都为可用
	if tostring(itype) == tostring(itemTypeBox) then
		canUse = true

		local ownItemNum = self:getItemNumById(itemId)
		if ownItemNum < itemNum then
			canUse = false
		end
	end

	return canUse
end

-- 检查打开宝箱条件是否满足
function ItemsModel:checkUseBoxCondition(itemId,itemNum)
	if itemNum == nil then
		itemNum = 1
	end

	local itemData = FuncItem.getItemData(itemId)
	local canUse = itemData.use

	if canUse ~= nil and tonumber(canUse) == 1 then
		if itemData.useCondition ~= nil then
			local itemCondition = itemData.useCondition[1]
			if itemCondition ~= nil then
				local needItemCond = string.split(itemCondition,",")
				local needItemId = needItemCond[1]
				local needItemNum = needItemCond[2]
				local needItemTotalNum = needItemNum * itemNum
				if self:getItemNumById(needItemId) >= needItemTotalNum then
					return true,needItemId
				else
					return false,needItemId
				end
			end
		end
	end
	return false,nil
end

-- 获取道具使用效果
function ItemsModel:getItemUseEffect(itemId)
	local itemData = FuncItem.getItemData(itemId)
	local useEffect = itemData.useEffect
	if useEffect ~= nil then
		return useEffect[1]
	end
	return nil
end

-- 获取道具数量上限
function ItemsModel:getItemSuperLimit(itemId)
	local limitNum = FuncItem.getItemPropByKey(itemId,"Superposition") 
	return limitNum
end

-- 格式化item数量
function ItemsModel:getFormatItemNum(itemId)
	local itemNum = self:getItemNumById(itemId)
	local itemLimitNum = FuncItem.getItemPropByKey(itemId,"Superposition") or 1
	if itemNum > itemLimitNum then
        itemNum = itemLimitNum 
    end

	return itemNum
end

-- 获取途径数据排序
function ItemsModel:sortGetWayListData(getWayListData)
	if getWayListData == nil or #getWayListData == 0 then
		return
	end
	
	-- 获取途径id降序排
    table.sort(getWayListData, function(getWayId_1,getWayId_2)
        local getWayData_1 = FuncCommon.getGetWayDataById(getWayId_1)
        local getWayData_2 = FuncCommon.getGetWayDataById(getWayId_2)

        local open_1 = 0
        local open_2 = 0

        if self:isGetWayOpen(getWayData_1) then
            open_1 = 1
        end

        if self:isGetWayOpen(getWayData_2) then
            open_2 = 1
        end

        if open_1 > open_2 then
            return true
        elseif open_1 == open_2 then
            if getWayId_1 < getWayId_2 then
                return true
            else
                return false
            end
        end
    end )
end

-- 判断获取途径是否开启,参数为getWayData(获取途径对应的数据)
function ItemsModel:isGetWayOpen(getWayData)
	-- dump(getWayData, "\n\ngetWayData==")
    local getWayType = tonumber(getWayData.type)
    local funcIndex = getWayData.index
    local isOpen = false

    -- 依赖一级系统
    if getWayType == FuncCommon.GETWAY_TYPE.TYPE_1 or getWayType == FuncCommon.GETWAY_TYPE.TYPE_4 then   	
    	isOpen = FuncCommon.isSystemOpen(funcIndex) 
    	if funcIndex == FuncCommon.SYSTEM_NAME.GUILD or funcIndex == FuncCommon.SYSTEM_NAME.GUILDBOSS then
	     	isOpen = GuildModel:isInGuild()
	    end     
	    if funcIndex == FuncCommon.SYSTEM_NAME.MALL and getWayData.linkPara[1] == FuncShop.SHOP_TYPES.MALL_XINANDANG then
        	isOpen = ShopModel:checkIsOpen(FuncShop.SHOP_TYPES.MALL_XINANDANG)
        end
    -- 副本类型
    elseif getWayType == FuncCommon.GETWAY_TYPE.TYPE_2 then
        local raidId = getWayData.raidId
        if funcIndex == FuncCommon.SYSTEM_NAME.TRAIL then
    		isOpen = TrailModel:isopenType(getWayData.linkPara[1])
    	else
    		isOpen = WorldModel:canEnterRaid(raidId)
    	end       
    -- 不依赖系统，默认开启
    elseif tonumber(getWayType) == FuncCommon.GETWAY_TYPE.TYPE_3 then
        isOpen = true
    else
    	echoError("ItemsModel:isGetWayOpen 配置错误 getWayType=",getWayType)
    end

    return isOpen
end
--
function ItemsModel:isResIdGetWayOpen( resId )
	local isItem = FuncItem.checkItemById(resId)
	local getWayListData
    if isItem == true then
        -- 是道具
        local itemData = FuncItem.getItemData(resId)
        getWayListData = itemData.accessWay
    else
        -- 非道具资源
        local   _baseResource=FuncDataResource.getDataByID(resId);
        getWayListData = _baseResource.accessWay--FuncDataResource.getDataAccessWay(self.resId)
    end
    if getWayListData == nil then
    	getWayListData = {}
    end
    for i,v in pairs(getWayListData) do
    	local data = FuncCommon.getGetWayDataById(v)
    	if data.link ~= "UI_shop" and ItemsModel:isGetWayOpen(data) then
    		return true
    	end
    end
    return false
end

--判断一个item能否从副本中获取
function ItemsModel:isItemCanGetByPve(_itemId)
	local itemCfg = FuncItem.getItemData(_itemId)
	local accessWay = itemCfg.accessWay
	if accessWay then
		for i,v in ipairs(accessWay) do
			local getWayId = v
			local getWayData = FuncCommon.getGetWayDataById(getWayId)
			if getWayData.type == FuncCommon.GETWAY_TYPE.TYPE_2 and self:isGetWayOpen(getWayData) then
				return true
			end
		end
	end

	local cost = itemCfg.cost
	local needIndex = 0
	local canGetIndex = 0
	if cost then
		for i,v in ipairs(cost) do
			local splitStr = string.split(v, ",")
			if splitStr[1] == FuncDataResource.RES_TYPE.ITEM then
				needIndex = needIndex + 1
				if self:isItemCanGetByPve(splitStr[2]) then
					canGetIndex = canGetIndex + 1
				end
			end
		end
		if canGetIndex == needIndex then
			return true
		end
	end

	return false
end

--是不是法宝碎片
function ItemsModel:isTreasurePiece(resType, itemId)
	if tostring(resType) == UserModel.RES_TYPE.ITEM then 
		local itemType = FuncItem.getItemType(itemId);
		local subType = FuncItem.getItemSubType(itemId);
		if itemType == self.itemType.ITEM_TYPE_PIECE and 
				subType == self.itemSubTypes_New.ITEM_SUBTYPE_201 then 
			return true;
		else 
			return false;
		end 
	else 
		return false
	end 
end

function ItemsModel:isTreasurePieceByItemId(itemId)
	local subType = FuncItem.getItemSubType(itemId);
	if  subType == self.itemSubTypes_New.ITEM_SUBTYPE_201 then 
		return true;
	else 
		return false;
	end 
end

--是不是伙伴碎片
function ItemsModel:isPartnerPiece(resType, itemId)
	if tostring(resType) == UserModel.RES_TYPE.ITEM then 
		local itemType = FuncItem.getItemType(itemId);
		local subType = FuncItem.getItemSubType(itemId);
		if itemType == self.itemType.ITEM_TYPE_PIECE and 
				subType == self.itemSubTypes_New.ITEM_SUBTYPE_202 then 
			return true;
		else 
			return false;
		end 
	else 
		return false
	end 	
end

--判断是不是装备碎片
function ItemsModel:isEquipmentPiece(resType, itemId)
	if tostring(resType) == UserModel.RES_TYPE.ITEM then 
		local itemType = FuncItem.getItemType(itemId);
		local subType = FuncItem.getItemSubType(itemId);
		if itemType == self.itemType.ITEM_TYPE_PIECE and 
				subType == self.itemSubTypes_New.ITEM_SUBTYPE_205 then 
			return true;
		else 
			return false;
		end 
	else 
		return false
	end
end

--获取已有可出售物品列表
function ItemsModel:getCanSellItems()
    local sellTabel = self:getItemsBySubType(102)
--    dump(sellTabel,"+++++++++++")
    local haveItemsT = {}
    for i,v in pairs(sellTabel) do
        local _num = self:getItemNumById(v._data.id)
        if _num > 0 then
            local data = { id = v._data.id , num = _num }
            table.insert(haveItemsT,data)
        end
    end
--    self:sortItems(haveItemsT)
--    dump(haveItemsT,"sadasdadadsadada")
    return haveItemsT
end

-- 判断两个itemId，是否是相同的类型
function ItemsModel:isSameItemType(itemId1,itemId2)
	return FuncItem.getItemPropByKey(itemId1,"type") == FuncItem.getItemPropByKey(itemId2,"type")
end

function ItemsModel:setSelectedType(_curSelectedType)
	self.curSelectedType = _curSelectedType
end

function ItemsModel:getSelectedType()
	return self.curSelectedType
end

--动态生成获取途径列表
function ItemsModel:creatDynamicAccess(_type, _itemId, _accessWay)
	local access_table = {}
	local accessWayId = _accessWay[1]
	local maxCount = FuncDataSetting.getDataByConstantName("FiveSoulGetWayCount")
	if _type == self.itemSubTypes_New.ITEM_SUBTYPE_314 then
		local endlessId = UserExtModel:endlessId()		
		if endlessId > 0 then
			local count = 1
			for i = endlessId, 1, -1 do
				local itemFlag = FuncEndless.getItemFlagById(i)
				--这里限制最多显示5条，这个数值需要策划确定后配到表里面去 TODO
				if itemFlag and tostring(itemFlag) == tostring(_itemId) and count <= maxCount then
					local accessId = accessWayId.."_"..i
					table.insert(access_table, accessId)
					count = count + 1
					if count > maxCount then
						break
					end
				end
			end
		else
			endlessId = 1
		end

		if #access_table == 0 then
			for i = endlessId, FuncEndless.getAllEndlessCount(), 1 do
				local itemFlag = FuncEndless.getItemFlagById(i)
				if itemFlag and tostring(itemFlag) == tostring(_itemId) then
					local accessId = accessWayId.."_"..i
					table.insert(access_table, accessId)
					break
				end
			end
		end
	end

	return access_table
end

function ItemsModel:getSubTypeDisplay()
	return self.itemSubTypes_New
end

return ItemsModel











