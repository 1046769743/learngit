
FuncDataResource = FuncDataResource or {}

FuncDataResource.RES_TYPE = {
    ITEM = "1",             -- 道具
    EXP = "2",              --经验
    COIN = "3",             --金币
    DIAMOND = "4",          --钻石
    SP = "5",               --行动力
    -- MP = "6" ,              --法力 	废弃
    ARENACOIN = "7" ,       --竞技场货币
    GUILDCOIN = "8" ,       --工会商店
    -- HUANGTONG = "9" ,        --9 某玩法货币，预留 -- 试炼需要的
    TREASURE = "10",        --完整法宝
    GIFTGOLD = "11",		--代币 赠送钻石
    -- COPPER ="12",			--熔炼商店魂牌
    -- PULSECOIN = "14",		--灵脉系统灵气 废弃
    GIFTGOLDVIP = "14",		-- 带有vip经验的仙玉（没有实际数量只用作显示）
    -- ROMANCEEXP = "15",		--奇缘好感度
    VIPEXP = "15",			-- vip经验
    -- TALENTPOINT = "16",     --天赋点 废弃
	CHIVALROUS = "17",		--侠义值
	PARTNER = "18",			--完整伙伴
	-- SANHUANGFU = "20",       --三皇造物符 废弃
	TOOL = "20",            --仙盟挖宝铲子
	-- SANHUANGREFRESHCARD = "21", --抽卡商店刷新令
	-- XINGCHEN = "22" ,		--星晨 	废弃
	LUCKYJIFEN = "22" ,		--幸运转盘积分

	ACHIEVEMENT = "23",      --成就点
	GARMENT = "24",          --五彩金丝线
	CLOTHES = "25",          --时装

    SKINCOIN = "26",          --伙伴皮肤点券
    PANRTNERSKIN = "27",		---伙伴皮肤

    USERHEADFRAME = "28",    -- 用户头像框
    CIMELIACOIN = "29",      -- 神器精华

	DIMENSITY  = "30",		 --锁妖塔魔石
    LINGSHI = "31",       --灵石
    WOOD = "32",			--灵木
    -- WULINGCOIN = "33",        --五灵币
    WULINGPOINT = "34",      --五灵点

    XIANFU = "35",  		 -- 须臾灵元

    GUILD_STONE = "36",  		 	-- 仙盟资源 星石
    GUILD_JADE = "37",  		 		-- 仙盟资源 陨玉

	-- DEPUTECOIN = "39",       -- 委托币
	MONTH = "40" ,				--月卡奖励
    OPTION = "100",         --七登和嘉年华 可选奖励
    REWARD = "99",          --奖励类型 从reward表中取对应id
    EXPLORERES = "41",	---探索资源类型
}


local dataRes = Tool:configRequire("common.DataResource")

--[[
	获得货币资源的名字
]]
function FuncDataResource.getResName(id)
	local tid = FuncDataResource.getDataByID(id).translateId;

	if tid == nil or tid == "" then
		echoWarn("FuncDataResource.getResName id=",id,",tid=",tid)
		return ""
	end
	return GameConfig.getLanguage(tid);
end

--[[
	获得货币资源的名字 英文
]]
function FuncDataResource.getResNameInEnglish(id)
	return FuncDataResource.getDataByID(id).name;
end

-- 获取英雄静态数据
function FuncDataResource.getDataByID(id)
	local data = dataRes[tostring(id) ]
	if not data then
		echoError("没有这个resID:"..tostring(id))
	end
    return data
end

-- 获取资源获取途径
function FuncDataResource.getDataAccessWay(id)
	local data = FuncDataResource.getDataByID(tostring(id))
	return data.accessWay
end

--获取资源的名字 资源可能是 道具 法宝 或者货币
function FuncDataResource.getResNameById(resType,resId)
	resType = tostring(resType)
	if resType == FuncDataResource.RES_TYPE.ITEM  then
		return FuncItem.getItemName(resId)
	elseif resType ==FuncDataResource.RES_TYPE.TREASURE then
		return GameConfig.getLanguage(FuncTreasure.getValueByKeyTD(resId,"name"))
	elseif resType ==FuncDataResource.RES_TYPE.PARTNER then
		return FuncPartner.getPartnerName(resId)
	elseif resType ==FuncDataResource.RES_TYPE.PANRTNERSKIN then
		local skindata = FuncPartnerSkin.getPartnerSkinById( resId)
		return GameConfig.getLanguage(skindata.name)
	elseif resType ==FuncDataResource.RES_TYPE.CLOTHES then
		local name = FuncGarment.getValueByKey(resId, UserModel:avatar(), "name")
		return GameConfig.getLanguage(name)
	elseif resType ==FuncDataResource.RES_TYPE.USERHEADFRAME then
		local name = FuncUserHead.getHeadFramById(resId)
		if name ~= nil then
			name = name.headFrameName
		end
		return GameConfig.getLanguage(name)
	elseif resType ==FuncDataResource.RES_TYPE.MONTH then
		local name = FuncMonthCard.getMonthCardName( resId )
		return name
	elseif resType ==FuncGuildExplore.guildExploreResType  then
		local resData = FuncGuildExplore.getCfgDatas( "ExploreResource",resId )
		return GameConfig.getLanguage(resData.translateId)
	end

    return FuncDataResource.getResName(resType);
end

--获取icon
function FuncDataResource.getIconPathById( id )
	local data = FuncDataResource.getDataByID(tostring(id))
	local iconPath = data.icon
	return iconPath
end

--获取资源品质 
function FuncDataResource.getQualityById( resType,resId )
	if resType == FuncDataResource.RES_TYPE.ITEM then
		return FuncItem.getItemQuality(resId)
	elseif resType == FuncDataResource.RES_TYPE.TREASURE then
		--那么是获取法宝品质
		return FuncTreasure.getValueByKeyTD(resId,"initQuality")  
	elseif resType == FuncDataResource.RES_TYPE.EXPLORERES then
		local resData = FuncGuildExplore.getCfgDatas( "ExploreResource",resId )
		if not resData.quality then
			echo("========探索资源类型 没有配置品质 默认给===1=======",resType,resId)
		end
		return resData.quality or 1 ---先默认给1，防止报错
	end
	--否则就是获取其他的品阶
	local data = FuncDataResource.getDataByID(resType)
	-- dump(data, "\n\ndata===")
	if not data.quality then
		echoError("resType:",resType,"resId:",resId,'没有配置quality')
	end
	return data.quality
end


--获取资源描述
function FuncDataResource.getResDescrib(resType, resId )
	if resType == FuncDataResource.RES_TYPE.ITEM then
		return FuncItem.getItemDescrib(resId)
	elseif resType == FuncDataResource.RES_TYPE.TREASURE then
		return FuncTreasure.getTreasureDes(resId);
	elseif resType == FuncDataResource.RES_TYPE.PARTNER then
		return GameConfig.getLanguage(FuncPartner.getDescribe(resId))
	elseif resType == FuncDataResource.RES_TYPE.PANRTNERSKIN then
		local skindata = FuncPartnerSkin.getPartnerSkinById( resId)
		return GameConfig.getLanguage(skindata.desTranslate)
	elseif resType == FuncDataResource.RES_TYPE.CLOTHES then
		local dis =  FuncGarment.getValueByKey(resId, UserModel:avatar(), "desTranslate")
		return GameConfig.getLanguage(dis)
	elseif resType ==FuncDataResource.RES_TYPE.USERHEADFRAME then
		local headFrameDescrip = FuncUserHead.getHeadFramById(resId)
		if headFrameDescrip ~= nil then
			headFrameDescrip = headFrameDescrip.headFrameDescrip
		end
		return GameConfig.getLanguage(headFrameDescrip)
	elseif resType ==FuncGuildExplore.guildExploreResType  then
		local resData = FuncGuildExplore.getCfgDatas( "ExploreResource",resId )
		return GameConfig.getLanguage(resData.des)
	end
	--否则就是获取其他的品阶
	local data = FuncDataResource.getDataByID(resType)
	local tid = data.des
	if not tid then
		echoWarn("没有为这个资源配置描述:",resType,resId)
		return "还没有配置描述" ..tostring(resType)
	end
	return  GameConfig.getLanguage(tid) 
end



--获取一个资源需要的折扣价格  discount 折扣万分比  needRound,是否需要取整 空不需要 , 1向下取整,2 math.round,3 向上取整
function FuncDataResource.getResZhekouNums( resStr,discount,needRound )
	if not discount then
		return  resStr
	end
	local tempArr  = string.split(resStr, ",")
	local resType = tempArr[1];
	local resNums 
	if resType == UserModel.RES_TYPE.ITEM then
		resNums = tempArr[3]
	else
		resNums = tempArr[2]
	end
	resNums = tonumber(resNums) * discount/10000
	if needRound == 1 then

		resNums = math.floor(resNums)
	elseif needRound == 2 then
		resNums = math.round(resNums)
	elseif needRound == 3 then
		resNums = math.ceil(resNums)
	end
	local resutlStr = ""
	if resType == UserModel.RES_TYPE.ITEM then
		resutlStr = resType..","..tempArr[2]..resNums
	else
		resutlStr = resType..","..resNums
	end

	return resutlStr
end


