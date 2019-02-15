FuncItem= FuncItem or {}

local itemDataCfg = nil
local itemActionData = nil
local itemReward = nil
local quickBuyItem = nil

--用于显示通用物品详情
FuncItem.ITEM_VIEW_TYPE ={
	SIGN = "SIGN",
	SHOP = "SHOP",
	ONLYDETAIL = "ONLYDETAIL",
}

FuncItem.itemSubTypes = {
	ITEM_SUBTYPE_100 = 100,     	--宝箱(可以打开的道具)
	ITEM_SUBTYPE_201 = 201,     	--法宝碎片
	ITEM_SUBTYPE_305 = 305,         --法宝万能碎片
	ITEM_SUBTYPE_202 = 202,			--奇侠碎片
	ITEM_SUBTYPE_203 = 203,			--主角星魂碎片
	ITEM_SUBTYPE_299 = 299,			--其他碎片，在背包系统可以直接合成的一种碎片
	ITEM_SUBTYPE_401 = 401,         --神器
	ITEM_SUBTYPE_402 = 402,         --神器升级
	ITEM_SUBTYPE_310 = 310,			--升品
	ITEM_SUBTYPE_314 = 314,			--装备
	ITEM_SUBTYPE_205 = 205,         --装备碎片
}

FuncItem.itemSubTypes_New = {
	ITEM_SUBTYPE_100 = 100,     	--宝箱(可以打开的道具)
	ITEM_SUBTYPE_104 = 104,			--可选宝箱
	ITEM_SUBTYPE_201 = 201,     	--法宝碎片
	-- ITEM_SUBTYPE_305 = 305,         --法宝万能碎片
	ITEM_SUBTYPE_202 = 202,			--奇侠碎片
	ITEM_SUBTYPE_204 = 204,			--主角星魂碎片
	ITEM_SUBTYPE_203 = 203,			--其他碎片，在背包系统可以直接合成的一种碎片
	ITEM_SUBTYPE_205 = 205,         --装备碎片
	ITEM_SUBTYPE_312 = 312,         --神器
	-- ITEM_SUBTYPE_402 = 402,         --神器升级
	ITEM_SUBTYPE_310 = 310,			--升品
	ITEM_SUBTYPE_311 = 311,			--装备
	ITEM_SUBTYPE_314 = 314,			--五灵
}

--可选宝箱界面 增加减少数量的四个按钮 依次为 最小，-1，+1，最大
FuncItem.OPTION_BTN_TYPE = {
	LEFT = 1,
	MIDDLE_LEFT = 2,
	MIDDLE_RIGHT = 3,
	RIGHT = 4,
}

-- 背包类型枚举
FuncItem.itemType = {
	ITEM_TYPE_COST = 1,				--消耗
	ITEM_TYPE_PIECE = 2,			--碎片
    ITEM_TYPE_MATERIAL = 3,         --材料
    ITEM_TYPE_MEMORY = 4,           --情景卡碎片  不在背包中显示
}

function FuncItem.init(  )
	itemDataCfg = Tool:configRequire("items.Item")
	itemActionData = Tool:configRequire("items.ItemAction")
	itemReward = Tool:configRequire("items.Reward")
	itemOptionData = Tool:configRequire("items.Option")
	quickBuyItem = Tool:configRequire("items.QuickBuyItem")
end

function FuncItem.getRewardData(id)
	local reward = itemReward[tostring(id)]
	if not reward then
		echoError("FuncItem.getRewardData  id ", id ," not found")
	end
	return reward
end

function FuncItem.checkItemById(id)
	local item = itemDataCfg[tostring(id)]
	if item ~= nil then 
		return true
	else
		return false
	end
end

function FuncItem.getItemData(itemId)
	itemId = tostring(itemId)
	local item = itemDataCfg[itemId]
	if item ~= nil then 
		return item
	else
		echoWarn("FuncItem.getItemData item id " .. itemId .. " not found")
	end
    return nil
end

function FuncItem.getItemActionData(itemSubType)
	itemSubType = tostring(itemSubType)
	local curActionData = itemActionData[itemSubType]
	if curActionData ~= nil then 
		return curActionData
	else
		echoWarn("FuncItem.getItemActionData itemSubType " .. itemSubType .. " not found")
	end

    return nil
end

function FuncItem.getItemActionValue(itemSubType,keyName)
	local curActionData = FuncItem.getItemActionData(itemSubType)
	if curActionData then
		return curActionData[keyName]
	end
end

function FuncItem.isValid(itemId)
	local ret = true
	if itemId == nil or itemId == "" then
		ret =  false
	else
		local item = FuncItem.getItemData(itemId)
		if item == nil then
			ret =  false
		else
			ret = true
		end
	end

	if not ret then
		echoWarn("FuncItem.isValid itemId=",itemId," is invalid")
	end

	return ret
end

function FuncItem.getItemPropByKey(itemId,key)
	local item = FuncItem.getItemData(tostring(itemId))
	local value = nil
	if item ~= nil then
		value = item[key]
		if value == nil then
			echoWarn("FuncItem.getItemPropByKey item id=",itemId," key=",key,",not found")
		end
		return value
	else
		echoWarn("FuncItem.getItemPropByKey item id ",itemId," not found")
		return value
	end
end

function FuncItem.getItemType(itemId)
	local item = FuncItem.getItemData(itemId)
	local itemType = item.type
	if itemType ~= nil then
		return itemType
	else
		echo("FuncItem.getItemType item id not found", itemId)
		return nil
	end
end

-- 判断碎片是否是主角星魂
function FuncItem.checkCharSoulId(itemId)
	local subType = FuncItem.getItemSubType(itemId)
	if subType == FuncItem.itemSubTypes_New.ITEM_SUBTYPE_204 then
		return true
	end
	return false
end

-- 判断碎片是否是奇侠碎片
function FuncItem.checkPartnerId(itemId)
	local subType = FuncItem.getItemSubType(itemId)
	if subType == FuncItem.itemSubTypes_New.ITEM_SUBTYPE_202 then
		return true
	end
	return false
end

function FuncItem.getItemSubType(itemId)
	local item = FuncItem.getItemData(itemId)
	local itemType = item.subType_display
	if itemType ~= nil then
		return itemType
	else
		echo("FuncItem.getItemSubType item id not found", itemId)
		return nil
	end
end

-- 获取道具单价
function FuncItem.getItemBuyPrice(itemId)
	local itemData = FuncItem.getItemData(itemId)
	if itemData ~= nil then
		return itemData["buyPrice"]
	else
		echo("FuncItem.getItemBuyPrice item id not found", itemId)
		return nil
	end
end

-- 获取道具名称
function FuncItem.getItemName(itemId)
	local itemData = FuncItem.getItemData(itemId)
	if itemData ~= nil then
		return GameConfig.getLanguage( itemData["name"])
	else
		echo("FuncItem.getItemName item id not found", itemId)
		return nil
	end
end

--获取道具品质
function FuncItem.getItemQuality( itemId )
	local itemData = FuncItem.getItemData(itemId)
	local quality = numEncrypt:getNum(itemData.quality)
	if quality ==0 then
		echoWarn("这个道具的品质为0,itemId:",itemId)
		quality = 1
	end
	return quality
end

--获取icon
function FuncItem.getIconPathById( itemId )
	local itemData = FuncItem.getItemData(itemId)
	return itemData.icon
end


--获取道具描述
function FuncItem.getItemDescrib( itemId )
	local itemData = FuncItem.getItemData(itemId)
	local tid = itemData.des
	if not tid then
		echoWarn("没有为这个道具配置描述:",itemId)
		return "还没有配置描述" ..tostring(itemId) 
	end
	return  GameConfig.getLanguage(tid)
end

--分割字符串 : 1,1001,2  类型,id,数量
function FuncItem.getItemInfoFromStr(infoStr)
	local ret = string.split(infoStr, ',')
	return ret[1], ret[2], tonumber(ret[3])
end

-- 根据道具碎片Id，获取其合成后的道具Id
-- 如果不可合成其他道具，返回nil
function FuncItem.getComposeItemId(itemPieceId)
	local composeItemId = nil
	
	if itemPieceId == nil or itemPieceId == "" then
		return composeItemId
	end

	for k,v in pairs(itemDataCfg) do
		local costArr = v.cost
		if costArr then
			local curCond = nil
			for i=1,#costArr do
				curCond = costArr[i]
				local arr = string.split(curCond,",")
				if #arr >=2 and tostring(arr[1]) == FuncDataResource.RES_TYPE.ITEM 
					and tostring(arr[2]) == tostring(itemPieceId) then
					composeItemId =  k
					return composeItemId
				end
			end
		end
	end

	return composeItemId
end

--通过optionId获取可选奖励信息
function FuncItem.getOptionInfoById(optionId)
	local optionInfo = itemOptionData[tostring(optionId)]
	if not optionInfo then
		echoError("Option.csv not configur optionId==", optionId)
		return 
	else
		local info = optionInfo.info
		if not info then
			echoError("Option.csv  info  not configur optionId==", optionId)
			return 
		else
			return info
		end
	end
end

--支持将reward转化为通用的奖励数组
function FuncItem.getRewardArrayByCfgData(_cfgData)
	local rewardArr = {}

	for i,v in ipairs(_cfgData) do
		local str_table = string.split(v, ",")
		if tostring(str_table[1]) == FuncDataResource.RES_TYPE.REWARD then
			local rewardId = str_table[2]
			local rewardData = FuncItem.getRewardData(rewardId)
			for ii,vv in ipairs(rewardData.info) do
				local str_table2 = string.split(vv, ",")
				local reward = nil
				if str_table2[2] == FuncDataResource.RES_TYPE.ITEM or str_table2[2] == FuncDataResource.RES_TYPE.PARTNER
					or str_table2[2] == FuncDataResource.RES_TYPE.USERHEADFRAME or str_table2[2] == FuncDataResource.RES_TYPE.OPTION
					or str_table2[2] == FuncDataResource.RES_TYPE.CLOTHES or str_table2[2] == FuncDataResource.RES_TYPE.PANRTNERSKIN
					or str_table2[2] == FuncDataResource.RES_TYPE.TREASURE or str_table2[2] == FuncDataResource.RES_TYPE.REWARD then
					
					reward = string.format("%s,%s,%s", str_table2[2], str_table2[3], str_table2[4])
				else
					reward = string.format("%s,%s", str_table2[2], str_table2[3])
				end
				table.insert(rewardArr, reward)
			end			
		else
			table.insert(rewardArr, v)
		end
	end

	return rewardArr
end

--通用奖励展示，需要传入展示用的mc，展示的奖励数据 needShowName是否显示名字 needShowNum是否显示数量 needShowRedPoint是否显示红点
--regesitShowEvent是否注册点击显示详情tip    不传后面的参数则都默认为false
function FuncItem.updateRewardView(_mc, _rewardData, needShowName, needShowNum, needShowRedPoint, regesitShowEvent)
	--数据转换  转换为通用奖励数据
	local rewardArr = FuncItem.getRewardArrayByCfgData(_rewardData)
	local totalFrame = MultiStateExpand:getTotalFrameNum()
	local rewardCount = #rewardArr
	--如果总数量大于mc的总帧数  则只显示前totalFrame个
	if rewardCount > totalFrame then
		rewardCount = totalFrame
	end
	local needShowName = needShowName or false
	local needShowRedPoint = needShowRedPoint or false
	local needShowNum = needShowNum or false
	local regesitShowEvent = regesitShowEvent or false
	_mc:showFrame(rewardCount)
	local panel_reward = _mc.currentView
	for i = 1, rewardCount, 1 do
		local commonUI = panel_reward["UI_" .. tostring(i)]
		if rewardArr[i] then			
			local reward = string.split(rewardArr[i], ",")
			local rewardType = reward[1]
			local rewardNum = reward[table.length(reward)]
			local rewardId = reward[table.length(reward) - 1]
			commonUI:setVisible(true)
			commonUI:setResItemData({reward = rewardArr[i]})
			commonUI:showResItemName(needShowName)
			commonUI:showResItemNum(needShowNum)
			commonUI:showResItemRedPoint(needShowRedPoint)
			if regesitShowEvent then
				FuncCommUI.regesitShowResView(commonUI,
	            	rewardType, rewardNum, rewardId, rewardArr[i], true, true)
			end
	    else
	    	commonUI:setVisible(false)
		end
	end
end

-- 获取道具快捷购买数据
function FuncItem.getQuickBuyItemData( itemId )
	if not quickBuyItem[tostring(itemId)] then
		echoError("FuncItem.getQuickBuyItemData item id not found", itemId)
	end
	return quickBuyItem[tostring(itemId)]
end

--判断是否是隐藏道具  暂时只有情景卡碎片是隐藏不显示的
function FuncItem.isConcealedItem(_id)
	local data = FuncItem.getItemData(_id)
	if data.type == FuncItem.itemType.ITEM_TYPE_MEMORY then
		return true
	end
	return false
end

--得到合成道具所需要的碎片数
function FuncItem.getNumFrag(itemId, fragId)
    local itemCombineCostVec = FuncItem.getItemPropByKey(itemId, "cost")
    for i,v in pairs(itemCombineCostVec) do
        local costStr = string.split(v,",")
        if tonumber(costStr[1]) == 1 then
            if tostring(costStr[2]) == tostring(fragId) then
                return tonumber(costStr[3])
            end
        end
    end
    return 0
end
