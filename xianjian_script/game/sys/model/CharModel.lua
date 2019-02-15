-- Author: ZhangYanguang
-- Date: 2016-04-14
-- 主角系统数据类

local CharModel = class("CharModel",BaseModel)

function CharModel:init(d)
	self.modelName = "char"

	self:initData()
	self:registerEvent()
	self:sendRedStatusMsg()

	if not IS_TODO_MAIN_RUNCATION then
		-- 判断前后端 主角战力是否一致
		-- self:checkCharPower( )
	end 
end
function CharModel:checkCharPower( )

	--如果还没有选角 那么不执行
	if AbilityModel:getCharAbility(  ) == 0 then
		echo("没选角 不需要校验战力")
		return
	end

	local clientPower = AbilityModel:getAbility({})
	local serverPower = AbilityModel:getTotalAbility(  )
	if math.abs( clientPower- serverPower ) > 1 then
		echoError("前后端战力不一致，请通知程序排查,clientPower:%d,serverPower:%d",clientPower,serverPower)
	end
	
end

-- 发送小红点状态消息
function CharModel:sendRedStatusMsg() 
	local isShowRedPoint = CharModel:showRedPoint()
	echo("==============111111=======",isShowRedPoint)
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,{ redPointType = HomeModel.REDPOINT.DOWNBTN.CHAR, isShow = isShowRedPoint })
end

function CharModel:registerEvent()
	-- 品质
	EventControler:addEventListener(UserEvent.USEREVENT_QUALITY_CHANGE, self.sendRedStatusMsg,self)
end

-- 初始化全局变量
function CharModel:initData()
	-- 缓存最大品阶
	self.maxCharQuality = nil

    self.boxStatus = {
		NOT_ENOUGH = 0,  --不足
		ENOUGH = 1, 	 --足够，未领取
		USED = 2,		 --已领取
	}

	self.CHAR_SYS = {
		SYS_ATTR = 1,
		SYS_STAR = 2,
		SYS_TALENT = 3,
		SYS_GARMENT = 4
	}
end

--更新数据
function CharModel:updateData(data)
	CharModel.super.updateData(self,data);
end

--删除数据
function CharModel:deleteData(data) 
	
end

-- 获取主角信息  如果需要获取他人的信息 则需要传入他人的数据
function CharModel:getCharData(_playerInfo)	
	local avatar = nil
	local quality = nil
	local position = nil
	local star = nil
	local starPoint = 0
	local level = nil
	local garments = nil
	local equips = nil
	local garmentId = nil
	if _playerInfo then
		avatar = _playerInfo.avatar
		quality = _playerInfo.quality
		position = _playerInfo.position
		star = _playerInfo.star
		starPoint = _playerInfo.starPoint
		level = _playerInfo.level
		garmentId = _playerInfo.userExt.garmentId
		equips = _playerInfo.equips
	else
		avatar = UserModel:avatar()
        quality = UserModel:quality()
        position = UserModel:position()
        star = UserModel:star()
        starPoint = UserModel:starPoint()
        level = UserModel:level()
        equips = UserModel:equips()
        garmentId = GarmentModel:getOnGarmentId()
	end
    local charData = {
        id = avatar,
        quality = quality,
        position = position,
        star = star,
        starPoint = starPoint,
        level = level,
        equips = equips,
        skin = garmentId,
    }
    -- dump(charData, "主角信息 --------- ")
    return charData
end

--- 主角属性获取
function CharModel:getCharAttr(  )
	local charData = CharModel:getCharData()
	local treasureId = TeamFormationModel:getOnTreasureId()
	local treasuredata = TreasureNewModel:getTreasureData(treasureId) or {}
	-- dump(treasuredata, "上阵法宝信洗", 3)
	local treasureLevel = UserModel:level()--math.floor((UserModel:level()-1)/3 + 1)
    local titleData = TitleModel:data() or {}
    local ownGarments = GarmentModel:getAllOwnGarments()
    local garments = FuncGarment.getEnabledGarments(ownGarments)
    local artifactData = ArtifactModel:data() or {}
    local userData = UserModel:getUserData()
    local memory = MemoryCardModel:data() or {}
    local params = {
        chard = charData,
        trsd = treasuredata,
        trsl = treasureLevel,
        titd = titleData,
        gard = garments,
        bwd = baowuData,
        memory = memory,
        userd = userData,
        artid = artifactData,
    }
    local attr = FuncChar.getCharFightAttribute(params)
    return attr

end

-- 判断主角的觉醒技能是否开启
function CharModel:checkCharAwakeSkill()
	-- 当前佩戴的法宝
	local star = CharModel:getCurrentTreasureStar( )
	local treasureId = TeamFormationModel:getOnTreasureId()
	local _partnerInfo = PartnerModel:getPartnerDataById(UserModel:avatar())
    local equipAwake, awakeSkillData = FuncPartner.checkPartnerEquipSkill(_partnerInfo,star,treasureId)
    if equipAwake then
    	return true
    end
    return false
end
-- 主线上阵法宝星级
function CharModel:getCurrentTreasureStar( )
	local treasureId = TeamFormationModel:getOnTreasureId()
	local treasureData = TreasureNewModel:getTreasureData(tostring(treasureId))
	local treasureStar = treasureData.star
	return treasureStar
end

-- 判断 主角单个武器装备觉醒技能 是否开启
function CharModel:checkCharWuqiAwakeSkill()
	local _partnerInfo = PartnerModel:getPartnerDataById(UserModel:avatar())
	local _equips = _partnerInfo.equips
	for i,v in pairs(_equips) do
		--判断是否是 武器装备
		if FuncChar:checkCharWuqiAwake(i) then
			-- 判断是否觉醒
			if v.awake and v.awake == 1 then
				return true
			end
		end
	end
	return false
end
------------------------------------------------------------------------
------------------------------------------------------------------------
--- 主角战力获取
function CharModel:getCharAbility( treaId,isLog,starPoint )
	--如果不传递参数 那么走 服务器的战力
	if (not treaId) and (not starPoint)  then
		return AbilityModel:getCharAbility(  )
	end
	local charData = table.copy(CharModel:getCharData())
	if starPoint then
		charData.starPoint = 0
	end
	local treasureId = treaId
	if not treasureId then
		treasureId = TeamFormationModel:getOnTreasureId()
	end
	-- echo("----主角的 上阵法宝ID === ",treasureId)
	local treasureData = TreasureNewModel:getTreasureData(tostring(treasureId))
	local treasureLevel = UserModel:level()--math.floor((UserModel:level()-1)/3 + 1)
    local titleData = TitleModel:getHisData()

    -- dump(titleData, "====== model 00000", 5)
    local ownGarments = GarmentModel:getAllServerGarments()
    local garmentIds = FuncGarment.getEnabledGarments(ownGarments,true)
    --local artifactData = ArtifactModel:data() -- 宝物不要了
    local userData = UserModel:getUserData()
    local level = treasureLevel
    local memory = MemoryCardModel:data()
    local params = {
        chard = charData,
        trsd = treasureData,
        trsl = treasureLevel,
        titd = titleData,
        garmid = garmentIds,
        userd = userData,
        skillLevel = level,
        memory = memory
    }
	local ability = FuncChar.getCharAbility(params,isLog)

	-- echo("主角战力 === ",ability)
	return  math.floor(ability)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--获取主角或者伙伴的战力
function CharModel:getCharOrPartnerAbility(_id)
    if FuncPartner.isChar(_id) then
        return CharModel:getCharAbility()
    else
        -- 伙伴战力
        return PartnerModel:getPartnerAbility(tostring(_id))
    end
end

--取主角或者奇侠战力 starpoint 为0时的战力
function CharModel:getCharOrPartner0PointAbility(_id)
	if FuncPartner.isChar(_id) then
        return CharModel:getCharAbility(nil,nil,0)
    else
        -- 伙伴战力
        return PartnerModel:getPartnerAbility(tostring(_id),nil,0)
    end
end

-- 获得主角星尘 数量
function CharModel:getStarDirt()
    return ItemsModel:getItemNumById(FuncChar.starDirt)
end



--获取当前zhujue的基础属性
function CharModel:getCharProperty()
    local attrIdArr = {
		2,  --气血
		10, --攻击
		11, --物防
		12, --法防
	}
    local charProperty = {}
    for i=1,#attrIdArr do
		local attrValue = self:getAttrValue(attrIdArr[i])
        local isTrue,_key = FuncPartner.isInitProperty(attrIdArr[i]) 
        charProperty[_key] = attrValue
	end
	charProperty["starPower"] = CharModel:getCharOrPartner0PointAbility(UserModel:avatar())
    charProperty["power"] = UserModel:getCharAbility()
    local info = {
        quilityBorder = FuncChar.getBorderFramByQuality(UserModel:quality()),--品质边框
        id = UserModel:getCharId(), -- id
        star = UserModel:star(),    -- 星级
        level = UserModel:level(), --等级
        quality = UserModel:quality(),-- 品质
        starPoint = UserModel:starPoint(),-- 星级节点
    }
    charProperty["info"] = info
    return charProperty
end
function CharModel:getAttrValue(attrId)
	local charAttrData = CharModel:getCharAttr()
	local attrValue = 0
	for i=1,#charAttrData do
		if attrId == charAttrData[i].key then
			attrValue = charAttrData[i].value
		end
	end

	attrValue = FuncBattleBase.getFormatFightAttrValue(attrId,attrValue)

	return attrValue
end

---------------------------------------------------------------------------------------------
--------------------------------------废弃之后删除-------------------------------------------
---------------------------------------------------------------------------------------------


-- 是否展示主角小红点
function CharModel:showRedPoint()
    local isShow = false
    if PartnerModel:isShowQualityRedPoint(UserModel:avatar()) then
        isShow = true
    end
    --升级
    if PartnerModel:isShowUpgradeRedPoint(UserModel:avatar()) then
        isShow = true
    end
    --升星
    if PartnerModel:isShowStarRedPoint(UserModel:avatar()) then
        isShow = true
    end
    --技能
    if PartnerModel:redPointSkillShow(UserModel:avatar()) then
        isShow = true
    end
    -- 装备
    if PartnerModel:redPointEqiupShow(UserModel:avatar()) then
        isShow = true
    end
	return isShow
end

--得到主角头像
function CharModel:getCharIconSp()
	return self:getCharIconByHid( tostring(UserModel:avatar()) );
end

--通过hid获得icon
function CharModel:getCharIconByHid(hid)
	local iconConfig = FuncChar.getHeroAvatar(tostring(hid));
	local path = FuncRes.iconHero( iconConfig );
	return display.newSprite(path);
end

function CharModel:isShowCharCrownRed()
	local charcrownid = UserModel:crown()
	local CharCrowndata = FuncChar.ByIDgetCharCrowndata(charcrownid+1)
	if UserModel:crown() >= 10 then
		return false,1
	end
	if CharCrowndata == nil then
		return false
	end
	local charAbility =  self:getCharAbility()
	local needbility = CharCrowndata.condition
	local twofile = CharCrowndata.cost
	local twofiles = string.split(twofile[1], ",");
	local coin = UserModel:getCoin()
	if  tonumber(coin) < tonumber(twofiles[2]) then
		return false,2
	end
	if tonumber(charAbility) < tonumber(needbility)  then 
		return false,3
	end
	return true
end

return CharModel
