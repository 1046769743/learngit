-- FuncArtifact
---去GameLuaLoader.lua，加上 FuncArtifact 文件节能运行  

FuncArtifact = {}
local cimelia = nil  --神器表
local cimeliaCombine = nil --组合神器表
local cimeliaUp = nil    --单个神器表
local combineUp = nil ---组合神器表
FuncArtifact.Fullorder = 16   ---满阶
FuncArtifact.errorType = {
	NOT_CONDITIONS = 1,    ---"进阶条件不足"
	NOT_ITEM_NUMBER = 2,   ---"道具条件不足"
	MEET_CONDITIONS = 3,---"已经是满阶"
	PLAYERLEVEL = 4, --玩家等级不足
}
FuncArtifact.ChouKaItems = {
	CHOUKA_ONE = 1,     ---抽卡1次
	CHOUKA_FIVES = 5,	---抽卡5次
}

FuncArtifact.CHOUKATYPES = {
	CHOUKA_FREE = 1,     ---免费
	CHOUKA_ITEM = 2,	---道具
	CHOUKA_RMB = 3,		--钻石
}
FuncArtifact.UPATTRTARGETTYPE = {
	star = 0,   --1主角
	attack = 1,  --2攻击 
	defense = 2,   --3防御
	assist = 3,   --4辅助
}
--技能类型
FuncArtifact.SKILLTYPE = {
	initiative = 1,  --主动
	passive = 2,   --被动
	combine = 3,   --1+2
	energy = 4, --怒气
	fivesoul = 5, -- 五灵

}
FuncArtifact.ItemsubType = {
	CONSUME = 402,   --神器进阶石
	PROPS = 401,	--神器道具

}
FuncArtifact.carnivalType = {
	COLOR_TYPE = 1,     --根据品质颜色分类
	ADVANCED_TYPE = 2,    --根据进阶数类型
}

FuncArtifact.shenqiJinhuaEtr = "获得神器精华[res/global_img_sqjh.png]"
FuncArtifact.buyChouakaStrQ  = "祈神可获神器精华送神器，今日还可以祈神<color =66ff00>"
FuncArtifact.buyChouakaStrH =  "<->次"
FuncArtifact.titleStr = "神器战力越高带来的属性增幅越大"

function FuncArtifact.init()

   cimelia= Tool:configRequire("cimelia.Cimelia")  --单件神器属性表
   cimeliaCombine = Tool:configRequire("cimelia.CimeliaCombine")  --组合神器属性和进阶表
   cimeliaUp = Tool:configRequire("cimelia.CimeliaUp")  --单件神器进阶表
   cimeliaLottery1 = Tool:configRequire("cimelia.CimeliaLotteryCommon")  --神器抽取表
   cimeliaLottery2 = Tool:configRequire("cimelia.CimeliaLotteryPurple")  --神器抽取表
   cimeliaLottery3 = Tool:configRequire("cimelia.CimeliaLotteryOrange")  --神器抽取表
   cimeliaLottery4 = Tool:configRequire("cimelia.CimeliaLotteryValue")  --神器抽取表
   cimeliaLottery5 = Tool:configRequire("lottery.LotteryOrder")  --神器抽取表
   combineUp = Tool:configRequire("cimelia.CombineUp")  --神器组合进阶表
  
   -- cimeliaLottery = Tool:configRequire("cimelia.CimeliaLottery")  --神器抽取表
end 

--获得神器抽卡道具ID
function FuncArtifact.getCLotteryItemId()
	local  itemid =  FuncDataSetting.getOriginalData("CimeliaLotteryItem")
	return itemid
end



--所有单个神器
function FuncArtifact.getAllSinglecimelia()
	return cimelia
end
--所有组合神器
function FuncArtifact.getAllcimeliaCombine()
	return cimeliaCombine
end
--根据宝物ID获得单件神器属性表详情
function FuncArtifact.byIdgetsingleInfo(artifactId)

	local result = cimelia[tostring(artifactId)]
	if not result then
		echoError("=====不存在单个神器 Id =====",artifactId,"暂时用20201代替")
		result = cimelia["20201"]
	end
	return result

end
--根据宝物ID获得组合神器属性和进阶表详情
function FuncArtifact.byIdgetCCInfo(artifactId)
	local result = cimeliaCombine[tostring(artifactId)]
	if not result then
		echoError("=====不存在组合神器 Id =====",artifactId,"暂时用202代替")
		result = cimeliaCombine["202"]
	end
	return result
end

--根据宝物ID获得单件神器进阶表详情
function FuncArtifact.byIdgetCUInfo(artifactId)

	local result  = cimeliaUp[tostring(artifactId)]
	if not result then
		echoError("=====不存在单个神器宝物进阶 Id =====",artifactId,"暂时用20201代替")
		result = cimeliaUp["20201"] 
	end
	return result
end

--获得所有抽卡数据
function FuncArtifact.getAllLotteryReward()
	 cimeliaLottery = {}
   for k,v in pairs(cimeliaLottery1) do
   		cimeliaLottery[#cimeliaLottery+1] = v
   end
   for k,v in pairs(cimeliaLottery2) do
   		cimeliaLottery[#cimeliaLottery+1] = v
   end
   for k,v in pairs(cimeliaLottery3) do
   		cimeliaLottery[#cimeliaLottery+1] = v
   end
   for k,v in pairs(cimeliaLottery4) do
   		cimeliaLottery[#cimeliaLottery+1] = v
   end
   for k,v in pairs(cimeliaLottery5) do
   		if tonumber(k) > 10000 then
	   		cimeliaLottery[#cimeliaLottery+1] = v
	   	end
   end
	return cimeliaLottery


end


--根据组合宝物ID获得神器抽取表详情
function FuncArtifact.byIdgetcombineUpInfo(artifactId)
	local result  = combineUp[tostring(artifactId)]
	if not result then
		echoError("=====不存在组合神器宝物 Id =====",artifactId,"暂时用202代替")
		result = combineUp["202"]
	end
	return result
end 
--神器钻石单抽花费
function FuncArtifact.getCConsumeNumber()
	local numbers = FuncDataSetting.getDataByConstantName("CimeliaLotteryConsume")
	return numbers or 0
end
--神器钻石五连花费
function FuncArtifact.cLotteryGoldConsume()
	local numbers = FuncDataSetting.getDataByConstantName("CimeliaLotteryGoldConsume")
	return numbers or 0
end
-- 神器钻石单抽每日免费次数
function FuncArtifact.cLotteryFreeTime()
	local numbers = FuncDataSetting.getDataByConstantName("CimeliaLotteryFreeTime")
	return numbers or 0
end
--  神器抽每抽1次给予的神器精华数量
function FuncArtifact.cLotteryCimeliaCoin()
	local numbers = 0
	return numbers or 0
end
--一天可以购买多少次神器抽卡
function FuncArtifact.todayBuyItems()
	local viplevel = UserModel:vip()
	local number = FuncCommon.getVipPropByKey(viplevel, "buyCimeliaTime")
	return number
end
--购买多少次获得橙色神器
function FuncArtifact.getBuyitemsGetGoods()
	return 20
end
-- 获取格式化的战斗属性值 比如 是免伤率  attrValue 传进来的是500 那就 返回 5%  如果是 攻击力 返回500
function FuncArtifact.getFormatFightAttrValue(key,attrValue)
    local newAttrValue = attrValue
    local attrData = FuncBattleBase.getAttributeData(key)
    local attrKeyName = attrData.keyName
    local percentKeyArr = {
        Fight.value_crit,Fight.value_resist,Fight.value_critR,
        Fight.value_block,Fight.value_wreck,Fight.value_blockR,
        Fight.value_injury,Fight.value_avoid,Fight.value_limitR,
		Fight.value_guard,Fight.value_buffHit,Fight.value_buffResist
    }
    --判断哪些是百分比属性
    if table.indexof(percentKeyArr, attrKeyName) then
        newAttrValue = (newAttrValue /100)
        -- 百分比的保留2位小数
        newAttrValue = newAttrValue * 1.00
        if newAttrValue >= 0 then
            newAttrValue = string.format("%0.1f", newAttrValue) 
        end
        
        newAttrValue = newAttrValue .. "%"
    else
        -- 非百分比舍弃小数部分
        newAttrValue = newAttrValue * 1.00
        newAttrValue = string.format("%0.0f", newAttrValue) 
    end

    return newAttrValue
end



---ccid组合ID
function FuncArtifact.addChildToCtn(_ctn,ccid,quality)
	_ctn:removeAllChildren()
	local CCInfo =  FuncArtifact.byIdgetCCInfo(ccid)
	local iconname = CCInfo.combineicon
	local icon =   FuncRes.iconCimelia(iconname) ---FuncRes.iconTalent( iconname)
	local spritename = display.newSprite(icon)
	local frame = CCInfo.frame  --边框
	-- spritename:setScale(0.5)
	_ctn:addChild(spritename)  --宝物图片
	if quality == 0 then
		FilterTools.setGrayFilter(spritename)
	else
		FilterTools.clearFilter(spritename)
	end
end
function FuncArtifact.addChildMiddle(_ctn,ccid)
	ccid = tostring(ccid)
	_ctn:removeAllChildren()
	local CCInfo =  FuncArtifact.byIdgetCCInfo(ccid)
	local iconname = CCInfo.spine

	local npcAnimName = iconname
    local npcAnimLabel = "stand"
    echo("=========npcAnimName=========",npcAnimName)
    local  spritename = ViewSpine.new(npcAnimName,nil,nil,nil);
    spritename:playLabel(npcAnimLabel);

	_ctn:addChild(spritename)  --宝物图片

	local ccquality = ArtifactModel:getCimeliaCombinequality(ccid)
 	if ccquality ~= 0 then
 		FilterTools.clearFilter(spritename)
 	else
 		FilterTools.setGrayFilter(spritename)
 	end

 	return spritename
end

-- --获得伙伴和主角的属性
-- function FuncArtifact:getPartnerandCilmeattr()
-- 	-- FuncArtifact.UPATTRTARGETTYPE
-- 	-- FuncArtifact.ATTRTYPE
-- end
--获得所有神器基本属性
function FuncArtifact.getAllArtifactAttr(alldata,p_id)
	local inintarrtable = {}
	local datas = nil
	local types = nil

	local ischar = FuncPartner.isChar(p_id)
	if ischar then  --主角
		types = tostring(FuncArtifact.UPATTRTARGETTYPE.star)
	else   ---伙伴
		datas =  FuncPartner.getPartnerById(p_id)
		types =  tostring(datas.type)
	end

	if alldata == nil then
		echoError("传入的神器数据是 is nil ")
		return inintarrtable
	end
	for k,v in pairs(alldata) do 
		--组合神器
		if v.quality ~= nil and  v.quality ~= 0 then
			local ccinfo =  FuncArtifact.byIdgetcombineUpInfo(k)
			for _i = 1,tonumber(v.quality) do 
				local ccdata = ccinfo[tostring(_i)]
				if  ccdata.kind == FuncArtifact.SKILLTYPE.passive or
				    ccdata.kind == FuncArtifact.SKILLTYPE.energy or 
				    ccdata.kind == FuncArtifact.SKILLTYPE.fivesoul or
				    ccdata.kind == FuncArtifact.SKILLTYPE.combine then
					if ccdata.upEffectTarget ~= nil then
						for i=1,#ccdata.upEffectTarget do
							if types == ccdata.upEffectTarget[i] then
								if ccdata.upEffect ~= nil then
									for x=1,#ccdata.upEffect do
										table.insert(inintarrtable,ccdata.upEffect[x])
									end
								end
							end
						end
					end
				end
			end	
		end
		--单个神器
		if v.cimelias ~= nil and table.length(v.cimelias) ~= 0 then
			for key,valuer in pairs(v.cimelias) do
				local artifactid = key
				local artifacquality = tonumber(valuer.quality)
				local arrtable =  FuncArtifact.byIdgetCUInfo(artifactid)
 				local data =  arrtable[tostring(artifacquality)]
				if  data.initAttrTarget ~= nil then
					for i=1,#data.initAttrTarget do
						if types == data.initAttrTarget[i] then
							local initAttr = data.initAttr
							if initAttr ~= nil then
								for _x=1,#initAttr do
									table.insert(inintarrtable,initAttr[_x])
								end
							end
						end
					end
				end
				for _i = 1,tonumber(valuer.quality) do 
					local artifacquality = _i
					local arrtable =  FuncArtifact.byIdgetCUInfo(artifactid)
	 				local data =  arrtable[tostring(artifacquality)]
					if data.upAttrTarget ~= nil then
						for i=1,#data.upAttrTarget do
							if types == data.upAttrTarget[i] then
								local upAttr = data.upAttr
								if upAttr ~= nil then
									for _x=1,#upAttr do
										table.insert(inintarrtable,upAttr[_x])
									end
								end
							end
						end
					end
				end
			end
		end
	end
	local skillArrt = FuncArtifact.getSkillArrtTable(alldata,types)

	for i=1,#skillArrt do
		table.insert(inintarrtable,skillArrt[i])
	end


	return inintarrtable
end
-- 组合神器的属性计算 （即神器技能的属性）
function FuncArtifact.getArtifactSkillAttr( alldata,p_id )
	local inintarrtable = {}
	local datas = nil
	local types = nil
	if alldata == nil then
		echoError("传入的神器数据是 is nil ")
		return inintarrtable
	end
	local ischar = FuncPartner.isChar(p_id)
	if ischar then  --主角
		types = tostring(FuncArtifact.UPATTRTARGETTYPE.star)
	else   ---伙伴
		datas =  FuncPartner.getPartnerById(p_id)
		types =  tostring(datas.type)
	end
	for k,v in pairs(alldata) do 
		--组合神器
		if v.quality ~= nil and  v.quality ~= 0 then
			local ccinfo =  FuncArtifact.byIdgetcombineUpInfo(k)
			local ccdata = ccinfo[tostring(v.quality)]
			if ccdata.kind == FuncArtifact.SKILLTYPE.passive or
			   ccdata.kind == FuncArtifact.SKILLTYPE.energy or 
			   ccdata.kind == FuncArtifact.SKILLTYPE.fivesoul or 
			   ccdata.kind == FuncArtifact.SKILLTYPE.combine then
				if ccdata.upEffectTarget ~= nil then
					for i=1,#ccdata.upEffectTarget do
						if types == ccdata.upEffectTarget[i] then
							if ccdata.upEffect ~= nil then
								for x=1,#ccdata.upEffect do
									table.insert(inintarrtable,ccdata.upEffect[x])
								end
							end
						end
					end
				end
			end
		end
	end
	return inintarrtable
end
--获得神器总战力  --伙伴或者主角id
function FuncArtifact.getAllArtifactPower(alldata,p_id)
	local artifactbine = 0  --组合神器战力
	local singleactbine = 0 --单个神器战力
	local sumbility = 0  --综合战力之和
	local arrtable = table.length(alldata)
	if arrtable == 0  then
		return sumbility
	end

	artifactbine = FuncArtifact.byTypegetCCAbility(alldata,"addAbility")
	singleactbine = FuncArtifact.byTypegetsingleAbility(alldata,"addAbility")
	sumbility = artifactbine + singleactbine
	return sumbility
end
--获得万分比的战力属性
function FuncArtifact.getAllThousandPower(alldata,p_id)

	local artifactbine = 0  --组合神器战力
	local singleactbine = 0 --单个神器战力
	local sumbility = 0  --综合战力之和
	local arrtable = table.length(alldata)
	if arrtable == 0  then
		return sumbility
	end

	artifactbine = FuncArtifact.byTypegetCCAbility(alldata,"ratioAddAbility")
	singleactbine = FuncArtifact.byTypegetsingleAbility(alldata,"ratioAddAbility")
	sumbility = artifactbine + singleactbine
	return sumbility

end
--组合神器获得战力和百分比战力
function FuncArtifact.byTypegetCCAbility(alldata,_type)
	local sumbility = 0
	for k,v in pairs(alldata) do
		local ccid = k  --组合神器id
		local quality = tonumber(v.quality)  --组合神器品质
		if quality ~= nil and quality ~= 0  then
			local ccInfoarr = FuncArtifact.byIdgetcombineUpInfo(ccid)
			for i=1,quality do
				sumbility = sumbility + ccInfoarr[tostring(i)][_type]
			end
		end
	end
	return sumbility
end
--单个神器获得战力和百分比战力
function FuncArtifact.byTypegetsingleAbility(alldata,_type)
	local sumbility = 0
	for k,v in pairs(alldata) do
		if v.cimelias ~= nil and table.length(v.cimelias) ~= 0 then
			for key,valuer in pairs(v.cimelias) do
				local artifactid = key
				local artifacquality = tonumber(valuer.quality)
				local arrtable =  FuncArtifact.byIdgetCUInfo(artifactid)
				for i=1,artifacquality do
					sumbility = sumbility + arrtable[tostring(i)][_type]
				end
			end
		end
	end
	return sumbility
end 

--根据类型获得数量
function FuncArtifact.getJinHuaNumber(_type)
	local numbers = FuncDataSetting.getJinHuaNumbers()
	return tonumber(_type) * numbers
end

--获得组合技能属性
function FuncArtifact.getSkillArrtTable(alldata,types)
	local arrtable = {}
	if table.length(alldata) ~= 0 then
		for k,v in pairs(alldata) do
			if v.quality ~= 0 then
				local ccid = v.id
				local quality = v.quality
				local ccdata = FuncArtifact.byIdgetcombineUpInfo(ccid)
				local skillEffectTarget = ccdata[tostring(quality)].skillEffectTarget
				if skillEffectTarget ~= nil then
					for _i=1,#skillEffectTarget do
						if  tonumber(skillEffectTarget[_i]) == tonumber(types) then
							local subAttr =  ccdata[tostring(quality)].subAttr
							if subAttr ~= nil then
								for _x=1,#subAttr do
									table.insert(arrtable,subAttr[_x])
								end
							end
						end
 					end
				end
			end
		end
	end
	-- dump(arrtable,"组合技能属性",8)
	return arrtable
end

--[[
神器系统战力= 万分比宝物战力值+单件宝物固定值+宝物突破阶数补充值；
]]

-- 计算神器总战力 固定值+万分比*对应伙伴
function FuncArtifact.getArtifactAllPower( userData)
	-- local power = 0
 --    local baowuData = userData.cimeliaGroups or {}
	-- --主角的战力
	-- local avatar = userData.avatar
	-- local charPower = FuncChar.getCharInitChar(userData,treasureId)
	-- local charPowerPer = FuncArtifact.getAllThousandPower(baowuData,avatar) / 10000
	-- power = power + charPowerPer * charPower
	-- -- 伙伴战力
	-- local partners = userData.partners
	-- local lovesData = userData.loves or {}
	-- for i,v in pairs(teamPartners) do
 --        local data = partners[tostring(v)]
	-- 	local partnerPowerPer = FuncArtifact.getAllThousandPower(baowuData,data.id)
	-- 	power = power + partnerPower * partnerPowerPer / 10000
	-- end
	local power = 0
	local baowuData = userData.cimeliaGroups or {}
	-- 宝物万分比
	local baowuPer = FuncArtifact.getAllThousandPower(baowuData)
	-- 宝物固定值
	local baowuPower = FuncArtifact.getAllArtifactPower(baowuData) 
	-- echo("=================== 宝物固定值 ==== ",baowuPower)
	-- echo("=================== 宝物万分比 ==== ",charPowerPer)
	power = baowuPer + baowuPower
	-- echo("计算神器总战力 ==== ",power)
	return power

end

-- 神器对应的战斗数据
-- 给战斗用的数据 怒气相关、换灵相关
function FuncArtifact.getArtifactDataForBattle(userData)
	local baowuData = userData.cimeliaGroups or {}
	-- dump(baowuData, "pppppp", 5)
	local dataT = {}
	for i,v in pairs(baowuData) do
		local ccinfo =  FuncArtifact.byIdgetcombineUpInfo(i)
		local ccdata = ccinfo[tostring(v.quality)]
		if ccdata then
			dataT[i] = {}
			dataT[i].kind = ccdata.kind
			if ccdata.kind == 1 then
				dataT[i].data = FuncPartner.getPartnerSkillKind1Attr(ccdata)
			elseif ccdata.kind == 2 then
				-- dataT[i].data = FuncPartner.getPartnerSkillKind2Attr(ccdata)
			elseif ccdata.kind == 3 then
				local artiData = FuncArtifact.byIdgetCCInfo(i)

				local data = {
					battleSkillId = tonumber(ccdata.mapSkill),
					hid = tostring(ccdata.mapSkill),
					lvl = v.quality,
					skillParams = FuncPartner.getPartnerSkillKind1Attr(ccdata, v.quality),
					priority = artiData.priority or 99, -- 同一阶段技能释放优先级依据
					applyType = tonumber(ccdata.applyType or 0),
					energyCost = tonumber(ccdata.energyCost or 0),
					combineId = i, -- 留一下对应神器组合的id
				}
				dataT[i].data = data
				-- dataT[i].data = FuncPartner.getPartnerSkillKind3Attr(ccdata)
			elseif ccdata.kind == 4 then
				dataT[i].data = FuncPartner.getPartnerSkillKind4Attr(ccdata)
			elseif ccdata.kind == 5 then
				dataT[i].data = FuncPartner.getPartnerSkillKind5Attr(ccdata)
			end
		end
	end
	-- dump(dataT, "=====shenqi=======", 6)
	return dataT
end

-- 根据神器Id获取战斗资源
function FuncArtifact.getArtifactResForBattle(userData)
	local baowuData = userData.cimeliaGroups or {}

	local dataT = {}
	for i,v in pairs(baowuData) do
		local ccinfo =  FuncArtifact.byIdgetcombineUpInfo(i)
		local ccdata = ccinfo[tostring(v.quality)]

		local artiData = FuncArtifact.byIdgetCCInfo(i)

		if ccdata then
			dataT[i] = {}
			if ccdata.kind == 3 then
				-- 神器相关资源
				if artiData and artiData.effSpine then
					for _,name in ipairs(artiData.effSpine) do
						table.insert(dataT[i], name)
					end
				end
				-- 找技能镜头相关资源
				local skill = ObjectCommon.getPrototypeData( "battle.Skill",tostring(ccdata.mapSkill) )
				if skill and skill.cameraSpineParams then
					local cameraSkilParams = skill.cameraSpineParams
					if cameraSkilParams.jingtou ~= "0" then
						table.insert(dataT[i], cameraSkilParams.jingtou)
					end
					if cameraSkilParams.wenzi ~= "0" then
						table.insert(dataT[i], cameraSkilParams.wenzi)
					end
					if cameraSkilParams.lihui ~= "0" then
						table.insert(dataT[i], cameraSkilParams.lihui)
					end
				end
			end
		end
	end

	return dataT
end






--散件神器激活时调用
function FuncArtifact.playSArtifactActiveSound()
	AudioModel:playSound(MusicConfig.s_cimelia_xiaojiehuo)
end

--整件神器激活时调用
function FuncArtifact.playCCArtifactActiveSound()
	AudioModel:playSound(MusicConfig.s_cimelia_dajiehuo)
end

--整件和散件神器进阶成功时都调用该音效
function FuncArtifact.playArtifactActiveSound()
	AudioModel:playSound(MusicConfig.s_cimelia_jinjie)
end

--神器分解时调用
function FuncArtifact.playArtifactFenJieSound()
	AudioModel:playSound(MusicConfig.s_cimelia_fenjie)
end
--单次、五连抽成功时都调用该音效
function FuncArtifact.playArtifactChouKaSound()
	AudioModel:playSound(MusicConfig.s_cimelia_choushenqi)
end
--翻转符咒音效时调用
function FuncArtifact.playArtifactFanPaiSound()
	AudioModel:playSound(MusicConfig.s_cimelia_fanfuzhou)
end

function FuncArtifact.getArtifactValueByIdAndKey(_id, _key)
	local artifactInfo = FuncArtifact.byIdgetCCInfo(_id)
	if not artifactInfo then
		echoError("=====不存在组合神器 Id =====",_id,"暂时用202代替")
		artifactInfo = cimeliaCombine["202"]
	end

	local value = artifactInfo[tostring(_key)]
	if not value then
		echoError("=====组合神器 Id =====", _id, "key值  未配置==", _key)
	end

	return value
end



--根据组合神器Id获得品质来计算战力
function FuncArtifact.getIdByCCAbility(ccid,quality)
	local cCInfo = FuncArtifact.byIdgetcombineUpInfo(ccid)
	local cCquality = quality or 1--self:getCimeliaCombinequality(ccid)
	local sumbility = 0
	local nowsumbility = 0

	for i=1,cCquality do
		nowsumbility = nowsumbility + cCInfo[tostring(i)].addAbility
	end
	
	return sumbility,nowsumbility
end






--数据结构
--[[
{
	"101" = {
		id = 101,
		quality = 0,
		cimelias = { 
			"1001" = {
				id = 1001,
				quality = 1,
			},
			"1002" = {
				id = 1002,
				quality = 7,
			},
		},
	},
	"102" = {
		id = 102,
		quality = 0,
		cimelias = {
			"2001" = {
				id = 2001,
				quality = 1,
			},
		},
	},
}
]]
