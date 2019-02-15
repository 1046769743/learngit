--[[
	Author: lichaoye
	Date: 2017-04-13
	查看阵容-Model
]]

local LineUpModel = class("LineUpModel", BaseModel)

local NUM_PER_PAGE = 10 -- 赞我的人列表，每页的个数
-- 构造假数据 容错防报错
local FALSE_DATA = {
			awaken = 0,
			id = 304,
			quality = 1,
			star = 1,
		}

function LineUpModel:init( data )
	LineUpModel.super.init(self, data)
	-- self:_updatePartnerList()

	self._praiseList = {} -- 赞我的人
	self._praiseListPage = 0 -- 当前拉取的页数
	self._showInfo = {} -- 需要展示的信息
	self._cacheInfo = nil -- 缓存信息
	-- 初始化的时候处理缓存在本地的关于机器人点赞的信息
	self:processRobotCache()
end

-- 初始化的时候处理缓存在本地的关于机器人点赞的信息
function LineUpModel:processRobotCache()
	-- 根据时间戳返回"20170415"
	local function transTime( time )
		local year = os.date("%Y",time)
		local month = os.date("%m",time)
		local day = os.date("%d",time)

		return string.format("%d%d%d",year,month,day)
	end
	-- 没有获取到证明从未初始化过，初始化一个
	local list = LS:prv():get(StorageCode.lineup_robot_praise)
	if not list then
		list = {}
	else
		list = json.decode(list)
		local nowDay = transTime(os.time())
		-- 根据时间戳更新doLike时间
		for k,v in pairs(list) do
			list[k].doLike = three(transTime(v.timeStamp) == nowDay, 1, 0)
		end
	end
	LS:prv():set(StorageCode.lineup_robot_praise, json.encode(list))
end

-- 查看是否是有效的阵容信息
function LineUpModel:checkIsVaild( formation )
	-- 当前伙伴阵容如果全部有人则有效，否则无效
	for k,v in pairs(formation.partnerFormation) do
		if v == "0" then return false end
	end

	return true
end

-- 检查别人是否满足开启
function LineUpModel:isLineUpOpen( lvl )
	local openData = FuncCommon.getSysOpenData()[FuncCommon.SYSTEM_NAME.LINEUP]
	local conditions = openData.condition
	local lvl = lvl or 1
	return (tonumber(conditions[1].v) <= tonumber(lvl)), conditions[1].v
end

function LineUpModel:getPartnerListByFormation( formation, partners )
	local list = {}
	local partners = partners

	for k,v in pairs(formation) do
		if partners then
			list[tostring(k)] = partners[tostring(k)]
		else
			list[tostring(k)] = PartnerModel:getPartnerDataById(k)
		end
	end

	return list
end

-- 生成"查看阵容功能"默认阵容
-- 选择自己战力最高的5个伙伴
function LineUpModel:initDefaultFormation()
	local allPartners = table.copy(PartnerModel:getAllPartner())
	-- 放在一个表里并且算出战力
	local _tempList = {}
	for k,v in pairs(allPartners) do
		v.power = PartnerModel:getPartnerAbility(v.id)
		table.insert(_tempList, v)
	end

	-- 战力高在前，然后直接比id了后续策划有需求再加
	local function _sortFunc( a, b )
		if tonumber(a.power) == tonumber(b.power) then
			return tonumber(a.id) > tonumber(b.id)
		end

		return tonumber(a.power) > tonumber(b.power)
	end

	table.sort(_tempList, _sortFunc)

	-- 默认阵容
	local fmt = {}
	fmt.p1 = "0"
    fmt.p2 = "0"
    fmt.p3 = "0"
    fmt.p4 = "0"
    fmt.p5 = "0"
    fmt.p6 = "0"
    -- 取前5个
    for i=1,5 do
    	local partner = _tempList[i]
    	if partner then
    		fmt["p" .. i + 1] = tostring(partner.id)
    	end
    end

    return fmt
end

-- 初始化查看阵容信息
function LineUpModel:initLineUpInfo( isSelf, data )
	if isSelf then -- 查看自己
		self:_initSelfLineUpInfo(data)
	else -- 查看他人
		self:_initOtherLineUpInfo(data)
	end
end
-- 初始化机器人的查看阵容信息
function LineUpModel:initRobotLineUpInfo(data)
	-- 先补全机器人信息
	local data = self:repairRobotInfo(data)
	-- 再按照查看他人信息的方式生成
	self:_initOtherLineUpInfo(data)
end
-- 补全机器人信息
function LineUpModel:repairRobotInfo( data )
	local data = table.copy(data)
	-- 修复阵容信息
	for k,v in pairs(data.formations.partnerFormation) do
		data.formations.partnerFormation[k] = tonumber(v)
	end
	-- 把1号位换成主角
	data.formations.partnerFormation["p1"] = 1
	for k,v in pairs(data.formations.treasureFormation) do
		data.formations.treasureFormation[k] = tonumber(v)
	end
	data.formation = data.formations

	-- 修复伙信息
	for k,v in pairs(data.partners) do
		local equipment = FuncPartner.getPartnerById(v.id).equipment
		local equips = {}
		-- 修复伙伴装备信息
		for _,ve in pairs(equipment) do
			equips[ve] = {
				id = tonumber(ve),
				level = 10, -- 初始化10级
			}
		end
		data.partners[k].equips = equips
		-- 修复伙伴技能信息
		local skill = FuncPartner.getPartnerById(v.id).skill
		local skills = {}
		for _,vs in pairs(skill) do
			skills[vs] = 1 -- 初始化1级
		end
		data.partners[k].skills = skills
		-- 伙伴的starPoint初始化为0
		data.partners[k].starPoint = 0
		-- 默认都没有仙混
		data.partners[k].souls = {}
	end
	-- 背景id默认为1
	data.backgroundId = 1

	-- 赞的信息（本地找）
	data.doLike, data.likeNum = LineUpModel:getRobotPraise( data.rid )
	-- 总战力
	data.totalAbility = data.ability
	-- 签名
	data.sign = ""
	-- 机器人的标志
	data.isRobot = true
	-- 机器人主角战力（先写个总战力的1/6，因为这个战力有问题）
	data.charAbility = math.floor(data.ability / 6)
	-- 机器人主角1星
	data.star = 1
	-- 好友信息，肯定不是好友
	data.isFriend = 0
	-- 时装id
	data.garment = ""
	return data
end

-- 设置机器人点赞信息
function LineUpModel:setRobotPraise( rid, info )
	local praiseList = LS:prv():get(StorageCode.lineup_robot_praise)
	praiseList = json.decode(praiseList)
	local t = {
		doLike = info.doLike,
		likeNum = info.likeNum,
		timeStamp = os.time(), -- 当前时间戳
	}
	praiseList[tostring(rid)] = t
	-- 在本地存一下
	LS:prv():set(StorageCode.lineup_robot_praise, json.encode(praiseList))
end

-- 获取机器人点赞信息
function LineUpModel:getRobotPraise( rid )
	local praiseList = LS:prv():get(StorageCode.lineup_robot_praise)
	praiseList = json.decode(praiseList)
	local info = praiseList[tostring(rid)]
	if not info then
		info = {
			doLike = 0,
			likeNum = math.random(1,25), -- 随机一个
		}

		self:setRobotPraise(rid, info)
	end
	return info.doLike, info.likeNum
end

-- 返回是否是查看自己的界面
function LineUpModel:isSelf()
	return self._showInfo.isSelf
end

-- 获取当前界面是否为机器人
function LineUpModel:isRobot()
	return self._showInfo.isRobot
end

-- 处理自己的信息
-- @@data = {doLike = 1, likeNum = 99} 自己的时候只会请求这两个数据
function LineUpModel:_initSelfLineUpInfo(data)
	self._showInfo = {}
	-- 是否是功能玩法
	self._showInfo.isFunc = false -- 自己一定不是
	-- 是否是查看自己
	self._showInfo.isSelf = true
	-- 是否是好友
	self._showInfo.isFriend = false -- 自己不存在这个问题
	-- 处理需要展示的列表 --
	local partnerFormation = nil
	local lineUpFormation = TeamFormationModel:getLineUpFormation()
	
	if self:checkIsVaild(lineUpFormation) then -- 有效，说明以前部署过
		partnerFormation = lineUpFormation.partnerFormation
	else -- 无效，说明第一次使用此功能，需要前端默认给出一套阵容
		partnerFormation = self:initDefaultFormation()
	end
	
	-- 处理伙伴阵容信息 --
	self._showInfo.partnerFormation = self:_managePartnerFormation(partnerFormation)
	-- 处理伙伴阵容信息 --

	-- 根据阵容取出伙伴信息
	local partners = self:getPartnerListByFormation(self._showInfo.partnerFormation)
	-- 伙伴信息处理
	local showList = self:_managePartnerList(partners)
	-- 主角信息
	local charInfo = self:_manageCharInfo()
	table.insert(showList, 1, charInfo)
	self._showInfo.detailList = showList
	-- 处理需要展示的列表 --

	-- 选择法宝信息
	self._showInfo.treasure = self:getTreasureByFormation(lineUpFormation.treasureFormation, TeamFormationModel:getAllTreas())

	-- 总战力
	self._showInfo.totalPower = UserModel:getAbility()
	-- 今日是否赞过该玩家(网络请求)
	self:setPraiseInfo(data)
	-- 背景Id
	self._showInfo.backgroundId = UserExtModel:backgroundId()
end

-- 处理查看阵容的其他玩家信息
function LineUpModel:_initOtherLineUpInfo( data )
	local data = data or {}
	self._showInfo = {}
	-- 是否是功能玩法
	self._showInfo.isFunc = not (tonumber(data.formationId) == FuncTeamFormation.formation.check_lineup)
	-- 是否是查看自己
	self._showInfo.isSelf = false
	-- 是否是好友
	self._showInfo.isFriend = (tonumber(data.isFriend) == 1)
	-- 是否是机器人
	self._showInfo.isRobot = data.isRobot
	-- 处理伙伴阵容信息 --
	self._showInfo.partnerFormation = self:_managePartnerFormation(data.formation.partnerFormation)
	-- 处理伙伴阵容信息 --

	-- 处理需要展示的列表 --
	-- 根据阵容取出伙伴信息
	local partners = self:getPartnerListByFormation(self._showInfo.partnerFormation, data.partners)
	-- 伙伴信息
	local showList = self:_managePartnerList(partners)
	-- 主角信息
	local charInfo = self:_manageCharInfo(data)
	table.insert(showList, 1, charInfo)
	self._showInfo.detailList = showList
	-- 处理需要展示的列表 --

	-- 选择法宝信息
	self._showInfo.treasure = self:getTreasureByFormation(data.formation.treasureFormation, data.treasures)

	-- 总战力
	self._showInfo.totalPower = data.totalAbility

	-- 今日是否赞过该玩家、玩家被赞总次数
	self:setPraiseInfo(data)
	self._showInfo.formation = data.formation
	-- 背景Id
	self._showInfo.backgroundId = data.backgroundId or 1
	self._otherData = data
end

-- 获取当前背景
function LineUpModel:getBackground()
	return self._showInfo.backgroundId
end

-- 写入点赞信息
function LineUpModel:setPraiseInfo( data )
	-- 今日是否赞过该玩家
	self._showInfo.doLike = three(data.doLike == 1, true, false)
	-- 玩家被赞总次数
	self._showInfo.likeNum = data.likeNum
	-- 玩家曾被赞过的最大次数（用于背景解锁）
	self._showInfo.likeTimes = data.likeTimes
end

-- 获取法宝信息
function LineUpModel:getTreasure()
	-- 构造假数据 容错防报错
	if not self._showInfo.treasure then
		self._showInfo.treasure = FALSE_DATA
	end
	return self._showInfo.treasure
end

-- 取得某个法宝是否在展示
function LineUpModel:checkTreasureOnShow( info )
	local treasure = self._showInfo.treasure or {}

	return three(treasure.id == info.id, 1, 0)
end

-- 根据阵容取得法宝信息
function LineUpModel:getTreasureByFormation( treasureFormation, treasures )
	local treasureFormation = treasureFormation or {}
	local treasureId = treasureFormation["p1"] -- 直接取一号位的
	local treasure = nil
	if treasureId then
		for k,v in pairs(treasures) do
			if tonumber(v.id) == tonumber(treasureId) then
				treasure = v
				break
			end
		end
	else
		-- 直接取一个战力最高的
		treasure, treasureId = self:_manageTreasures(treasures)
	end

	-- 顺便存一下法宝的阵型（只存一号位）
	self._showInfo.treasureFormation = {}
	self._showInfo.treasureFormation.p1 = tonumber(treasureId)

	return treasure
end

-- 处理法宝信息（直接取一个战力最高的）
function LineUpModel:_manageTreasures( data )
	local list = {}

	for k,v in pairs(data) do
		echoError("此时需要玩家等级 现在没有暂时用自己的等级")
		local level = UserModel:level()
		v.power = FuncTreasureNew.getTreasureAbility(data,level)
		table.insert(list, v)
	end

	local function _sortFunc( a, b )
		if tonumber(a.power) == tonumber(b.power) then
			if tonumber(a.star) == tonumber(b.star) then
				return tonumber(a.id) < tonumber(b.id)
			end

			return tonumber(a.star) > tonumber(b.star)
		end

		return tonumber(a.power) > tonumber(b.power)
	end
	-- 构造假数据 容错防报错
	list[1] = list[1] or FALSE_DATA
	return list[1],list[1].id
end

-- 处理伙伴阵容信息
function LineUpModel:_managePartnerFormation( data )
	local list = {}
	dump(data,"如果都是1的话证明你查看的是机器人")
	for i=1,6 do
		local id = data["p" .. i].partner.partnerId
		list[tostring(id)] = i
	end

	return list
end

-- 更新赞我的人列表 @@isOverWirte 是否直接覆盖以前的数组
function LineUpModel:updatePraiseList( info, page, isOverWirte )
	if isOverWirte then
		self._praiseList = info
	else
		for i,v in ipairs(info) do
			table.insert(self._praiseList, v)
		end
	end

	self._praiseListPage = page
end

-- 通过Info更新赞我的人列表中的某一个
function LineUpModel:udpatePraiseListByInfo( info )
	if not self._praiseList or not info then return end
	local rid = info.rid
	for i,v in ipairs(self._praiseList) do
		if rid == v.rid then
			-- 为了能够刷刷新，需要创建新的table
			local temp = table.copy(self._praiseList[i])
			for k,v in pairs(info) do
				temp[k] = v
			end
			self._praiseList[i] = temp
			break
		end
	end
end

-- 获取赞我的人的列表
function LineUpModel:getPraiseList()
	return self._praiseList
end

-- 获取需要拉取的页数
function LineUpModel:getNeedPullPage(idx)
	-- if #self._praiseList == NUM_PER_PAGE * self._praiseListPage then
	if idx == NUM_PER_PAGE * self._praiseListPage then
		return self._praiseListPage + 1
	else
		return false
	end
end

-- 获取总战力
function LineUpModel:getTotalPower()
	return self._showInfo.totalPower
end

-- 是否赞过
function LineUpModel:hasPraised()
	return self._showInfo.doLike
end

-- 获取赞的数量
function LineUpModel:getPraisedNum()
	return self._showInfo.likeNum
end

-- 获取曾经最大获赞数量（解锁背景用）
function LineUpModel:getMaxPraiseNum()
	return self._showInfo.likeTimes
end

-- 处理伙伴的列表
function LineUpModel:_managePartnerList(_originPartner)
	local partnerList = {}
	
	local _originPartner = _originPartner or {}

	for _,v in pairs(_originPartner) do
		table.insert(partnerList, v)
	end

	--对伙伴排序
	local function _table_sort(a,b)
	    --品质
	    if a.quality == b.quality then
	    	--星级
	    	if a.star == b.star then
	    		--等级
	    		if a.level == b.level then
	    			-- id
	    			return a.id < b.id 
	    		end

	    		return a.level > b.level
	    	end

	    	return a.star > b.star
	    end

	    return a.quality > b.quality
	end

	table.sort(partnerList, _table_sort)

	return partnerList
end

-- 组织自己的主角信息
function LineUpModel:_manageCharInfo(otherInfo)
	local otherInfo = otherInfo

	local charInfo = nil
	if otherInfo then -- 他人信息
		charInfo = {
			name = otherInfo.name,
			power = otherInfo.charAbility or 123456,
			quality = otherInfo.quality or 1,
			level = otherInfo.level,
			avatar = otherInfo.avatar,
			garmentId = three(otherInfo.garment == "", nil, otherInfo.garment),
			id = 1,
			icon = FuncChar.getHeroData(otherInfo.avatar).icon,
			sign = otherInfo.sign,
			guildName = otherInfo.guildName,

			isSelf = false,
			isChar = true,
		}
	else -- 自己信息（自己可能都不需要这些信息）
		charInfo = {
			name = UserModel:name(),
			power = UserModel:getAbility(),
			quality = UserModel:quality(),
			level = UserModel:level(),
			avatar = UserModel:getCharId(),
			-- garmentId 自己的信息不在这里取garmentId
			id = 1,
			-- charId = UserModel:getCharId(),
			icon = FuncChar.getHeroData(UserModel:getCharId()).icon,
			sign = FriendModel:getUserMotto(),

			isSelf = true,
			isChar = true,

			treasures = {},
		}
	end
	

	return charInfo
end
-- 获取当前主角信息
--[[
	为了满足需求：当从赞我的人列表里点其他人的详情的时候要同时刷新掉赞我的人的信息
	1 = {
-                     "avatar" = 101
-                     "level"  = 55
-                     "name"   = "刁锦程"
-                     "rid"    = "dev_140"
-                     "sec"    = "dev"
-                     "times"  = 1
-                 }
]]
function LineUpModel:getCurCharInfo()
	local char = self._showInfo.detailList[1] -- list里的第一个是主角
	local rid, sec = self:getServerInfo()
	local charInfo = {
		avatar = char.avatar,
		level = char.level,
		name = char.name,
		rid = rid,
		sec = sec,
	}
	return charInfo
end
-- 获取法宝列表
function LineUpModel:getTreasureList()
	-- 策划要求的排序(上阵->战力->星级->id)（没有战力）
	local treasures = TeamFormationModel:getAllTreas()

	for i,v in ipairs(treasures) do
		treasures[i].inTeam = self:checkTreasureOnShow(v)
	end

	local function _sortFunc(a, b)
		if a.inTeam == b.inTeam then
			if tonumber(a.star) == tonumber(b.star) then
				return tonumber(a.id) < tonumber(b.id)
			end

			return tonumber(a.star) > tonumber(b.star)
		end

		return a.inTeam > b.inTeam
	end

	table.sort(treasures, _sortFunc)

	return treasures
end
-- 获取伙伴列表
function LineUpModel:getPartnerList()
	local list = {}
	local partners = PartnerModel:getAllPartner()

	for k,v in pairs(partners) do
		v.inTeam = three(self:getPosInFormationById(v.id) == 0, 0, 1)
		table.insert(list, v)
	end

	--对伙伴排序
	local function _table_sort(a,b)
		-- 是否在阵容中
		if a.inTeam == b.inTeam then
		    --品质
		    if a.quality == b.quality then
		    	--星级
		    	if a.star == b.star then
		    		--等级
		    		if a.level == b.level then
		    			-- id
		    			return a.id < b.id 
		    		end

		    		return a.level > b.level
		    	end

		    	return a.star > b.star
		    end

		    return a.quality > b.quality
		end

		return a.inTeam > b.inTeam
	end

	table.sort(list, _table_sort)

	return list
end

-- 获取详情里显示的人
function LineUpModel:getDetailList()
	return self._showInfo.detailList
end

-- 根据id获得在阵容中的位置
function LineUpModel:getPosInFormationById( id )
	return self._showInfo.partnerFormation[tostring(id)] or 0
end

-- 获取排序后的需要显示的技能
function LineUpModel:getSkillInOrder( itemData,isHero,heroId)
	local _playSkill = nil
	local _skillData = nil
	if isHero then
		_skillData = isHero
		_playSkill = itemData
	else
		_skillData = FuncPartner.getPartnerById(itemData.id).skill
		_playSkill = itemData.skills
	end	
	local showList = {}
	local _tempList = {}
	for i,v in ipairs(_skillData) do
		table.insert(_tempList, {
			partnerId = itemData.id or heroId,
			id = tonumber(v),
			level = _playSkill[v] or 0,
			skillInfo = FuncPartner.getSkillInfo(v) or FuncTreasureNew.getTreasureSkillDataDataById(tonumber(v)),
			_index = i, -- 第几个技能
		})
	end

	local function sortFunc( a, b )
		if tonumber(a.level) == tonumber(b.level) then
			return tonumber(a.id) < tonumber(b.id)
		end
		return tonumber(a.level) > tonumber(b.level)
	end

	table.sort( _tempList, sortFunc )

	-- 取前三个
	for i=1,3 do
		table.insert(showList, _tempList[i])
	end

	return showList
end
-- 当前玩法模式
function LineUpModel:isFunc()
	return self._showInfo.isFunc
end
-- 获取当前显示玩家的服务器信息
function LineUpModel:getServerInfo()
	return self._showInfo.trid, self._showInfo.tsec
end

-- 设置当前显示玩家的服务器信息
function LineUpModel:setServerInfo(trid, tsec)
	self._showInfo.trid = trid
	self._showInfo.tsec = tsec
end

-- 更换伙伴
function LineUpModel:partnerFormationChange( beReplacedId, rePlaceId )
	local beReplacedId, rePlaceId = tostring(beReplacedId), tostring(rePlaceId)
	
	if beReplacedId == rePlaceId then return end

	local beReplacedPos = LineUpModel:getPosInFormationById(beReplacedId)
	local replacedPos = LineUpModel:getPosInFormationById(rePlaceId)
	-- echo("beReplacedId", beReplacedId, "rePlaceId", rePlaceId, "beReplacedPos", beReplacedPos, "replacedPos", replacedPos)
	if replacedPos == 0 then -- 换上来的不在阵上
		self._showInfo.partnerFormation[rePlaceId] = self._showInfo.partnerFormation[beReplacedId]
		self._showInfo.partnerFormation[beReplacedId] = nil
	else -- 换上来的在阵上
		self._showInfo.partnerFormation[beReplacedId],self._showInfo.partnerFormation[rePlaceId] = self._showInfo.partnerFormation[rePlaceId],self._showInfo.partnerFormation[beReplacedId]
	end

	-- 根据阵容取出伙伴信息
	local partners = self:getPartnerListByFormation(self._showInfo.partnerFormation)
	-- 伙伴信息处理
	local showList = self:_managePartnerList(partners)

	local count = 2
	for i,v in ipairs(showList) do
		self._showInfo.detailList[count] = v
		count = count + 1
	end

	EventControler:dispatchEvent(LineUpEvent.PARTNER_FORMATION_UPDATE_EVENT)
end

-- 更换法宝
function LineUpModel:treasureFormationChange( rePlaceId )
	-- 更新阵容信息
	self._showInfo.treasureFormation.p1 = rePlaceId
	-- 更新法宝信息
	self._showInfo.treasure = TeamFormationModel:getTreaById(rePlaceId)

	EventControler:dispatchEvent(LineUpEvent.TREASURE_FORMATION_UPDATE_EVENT)
end

-- 更换背景
function LineUpModel:bgChange( bgId )
	self._showInfo.backgroundId = bgId
	-- 通知背景更换
	EventControler:dispatchEvent(LineUpEvent.BG_UPDATE_EVENT)
end

-- 是否有缓存信息
function LineUpModel:hasCacheOwnInfo()
	return not empty(self._cacheInfo)
end

-- 缓存自己的信息
function LineUpModel:cacheOwnInfo()
	self._cacheInfo = self._showInfo
end

-- 恢复缓存信息
function LineUpModel:popCacheOwnInfo()
	self._showInfo = self._cacheInfo
	self._cacheInfo = nil
end

-- 是否是好友
function LineUpModel:isFriend()
	return self._showInfo.isFriend
end

-- 退出之后默认和服务器同步一下阵容和背景
function LineUpModel:syncFormation()
	-- 检查两个阵容是否相等
	local function isEqual( f1, f2 )
		for k,v in pairs(f1) do
			if tostring(v) ~= tostring(f2[k]) then return false end
		end

		return true
	end
	-- 查看自己的阵容才需要同步
	if self._showInfo.isSelf then
		local params = {}
		params.id = tostring(FuncTeamFormation.formation.pve)
		params.formation = {}
		params.formation.partnerFormation = {}

		for k,v in pairs(self._showInfo.partnerFormation) do
			params.formation.partnerFormation["p" .. v] = tonumber(k)
		end

		params.formation.treasureFormation = self._showInfo.treasureFormation

		-- 检查和本地阵容是否有改变
		local lineUpFormation = TeamFormationModel:getLineUpFormation()

		if not isEqual(params.formation.partnerFormation, lineUpFormation.partnerFormation)
			or not isEqual(params.formation.treasureFormation, lineUpFormation.treasureFormation)
			then
			TeamFormationServer:doFormation(params)
		end

		-- 检查背景是否有所改变
		if tostring(self._showInfo.backgroundId) ~= tostring(UserExtModel:backgroundId()) then
			LineUpServer:setBackGround(self._showInfo.backgroundId)
		end
	end
end

function LineUpModel:getOtherTeamFormation()
	if self._showInfo.formation then
		return self._showInfo.formation
	end
end

function LineUpModel:getOtherTeamFormationData()

	if self._otherData then
		return self._otherData
	end
end
return LineUpModel