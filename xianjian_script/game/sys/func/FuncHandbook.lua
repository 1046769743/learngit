--
--Author:      zhuguangyuan
--DateTime:    2018-05-22 16:26:16
--Description: 名册系统静态方法类
--

FuncHandbook = FuncHandbook or {}
FuncHandbook.isDebug = true

-- 8大奇侠归属系别 风雷水火土攻防辅
FuncHandbook.dirType = {
	feng = "1",
	lei = "2",
	shui = "3",
	huo = "4",
	tu = "5",
	offensive = "6",
	defensive = "7",
	assisted = "8",
}

-- 系别名字
FuncHandbook.dirId2Name = {
	["1"] = "风系名册",
	["2"] = "雷系名册",
	["3"] = "水系名册",
	["4"] = "火系名册",
	["5"] = "土系名册",
	["6"] = "攻系名册",
	["7"] = "防系名册",
	["8"] = "辅系名册",
}

--  攻防辅到册系的映射
FuncHandbook.Attack2DirType = {
	["1"] = FuncHandbook.dirType.offensive,
	["2"] = FuncHandbook.dirType.defensive,
	["3"] = FuncHandbook.dirType.assisted,
}

-- 五灵到册系的映射 
FuncHandbook.Wuling2DirType = {
	["1"] = FuncHandbook.dirType.feng,
	["2"] = FuncHandbook.dirType.lei,
	["3"] = FuncHandbook.dirType.shui,
	["4"] = FuncHandbook.dirType.huo,
	["5"] = FuncHandbook.dirType.tu,
}

FuncHandbook.inPlaceStatus = {
	can_enterField = "1",
	can_leaveField = "2",
	can_changeField = "3",
}

-- 奇侠评分等级标签
FuncHandbook.tagType = {
	jia = "4",
	yi = "3",
	bing = "2",
	ding = "1",
}

FuncHandbook.itemToDir = {
	["100101"] = "1",
	["100102"] = "2",
	["100103"] = "3",
	["100104"] = "4",
	["100105"] = "5",
	["100106"] = "6",
	["100107"] = "7",
	["100108"] = "8",
}

--名册顺序 
FuncHandbook.orderArr = {
	"6","7","8","2","3","4","5","1"
}

-- 奇侠战力到奇侠评分的转化系数
FuncHandbook.factorPower2Score = FuncDataSetting.getDataByConstantName("InHandbookPowerToScore")
-- 单个名册评分到单个名册显示战力的转化系数
FuncHandbook.factorDirScore2DisplayPower = FuncDataSetting.getDataByConstantName("HandbookPowerToHandbookScore")
-- 单个名册评分到单个奇侠的加成战力的转化系数
FuncHandbook.factorDirScore2additionPower = FuncDataSetting.getDataByConstantName("HandbookToPartnerScoreToPower")
-- 奇侠极限养满战力
FuncHandbook.maxValuePartnerPower = FuncDataSetting.getDataByConstantName("HandbookPartnerMax")
-- 每个坑的保底战力
FuncHandbook.maxValueBasePower = FuncDataSetting.getDataByConstantName("HandbookHolePower")
-- 每个坑的保底加成属性
FuncHandbook.basePropertyStr = FuncDataSetting.getHandbookBaseProperty()

function FuncHandbook.init()
	config_DirType = Tool:configRequire("handbook.HandbookType")
	config_DirTypeLv = Tool:configRequire("handbook.HandbookLv")
	config_ScoreTag = Tool:configRequire("handbook.HandbookTag")

	for k,v in pairs(FuncHandbook.dirId2Name) do
		FuncHandbook.dirId2Name[k] = GameConfig.getLanguage("#tid_handbooktitle_100"..k)
	end
	-- dump(FuncHandbook.dirId2Name,"__FuncHandbook.dirId2Name")

end

-- 读取配表获得相应坑位的加成属性
function FuncHandbook.getOneDirData ( dirId )
	local data = config_DirType[tostring(dirId)]
	if data then
		return data
	else
		echoError("对应名册数据不存在:",dirId)
	end
end
-- 读取配表获得相应坑位的加成属性
function FuncHandbook.getPropertiesByDirAndIndex( dirId,index )
	local data = config_DirType[tostring(dirId)]
	if data then
		local properties = data["property"..index]
		return properties
	end
end

-- 获取一个系所有等级的数据
function FuncHandbook.getOneDirAllLevelData( dirId )
	local data = config_DirTypeLv[tostring(dirId)]
	if data then
		return data
	end
end
-- 获取一个系不同等级的数据
function FuncHandbook.getOneDirLvData( dirId,level )
	local data = FuncHandbook.getOneDirAllLevelData( dirId )
	if data then
		for k,v in pairs(data) do
			if k == tostring(level) then
				return v
			end
		end
	end
end

-- 获取一个名册能升级到的等级
function FuncHandbook.getOneDirMaxLevel( dirId )
	local maxLevel = 0
	local data = FuncHandbook.getOneDirAllLevelData( dirId )
	for k,v in pairs(data) do
		maxLevel = maxLevel + 1
	end
	return maxLevel
end

function FuncHandbook.getTagDataByPlayerlevel( level )
	local levelTagData = config_ScoreTag[tostring(level)]
	if levelTagData then
		return levelTagData.tag
	end
end
-- ========================================================================
-- 评分 战力 属性计算
-- ========================================================================
-- 获取伙伴在其所在名册下的属性加成及战力
-- 计算伙伴战力及属性的时候用到
function FuncHandbook.getHandbookAddProperties(userData,partnerId)
	local propertyTotal,totalPower = {},0
	local configData = FuncPartner.getPartnerById(partnerId)
	local dir1,dir2 = tostring(configData.type),tostring(configData.elements)
	dir1 = FuncHandbook.Attack2DirType[dir1]
	dir2 = FuncHandbook.Wuling2DirType[dir2]
	local dirArr = {}
	dirArr[1]=dir1
	dirArr[2]=dir2
	for i=1,2 do
		local dirId = dirArr[i]
		local arr = FuncHandbook.getPropertyAddFromOneDir(userData,dirId)
	    for k,v in pairs(arr) do
			for kk,vv in pairs(v) do
	            local tempProperty = {}
	            tempProperty.key = vv.key
	            tempProperty.value = vv.value
	            tempProperty.mode = vv.mode
	            table.insert(propertyTotal,tempProperty)
			end
        end
		-- local oneDirPower = FuncHandbook.getPowerAdditionOneDir( userData,dirId )
		-- totalPower = totalPower + oneDirPower
	end
	-- if FuncHandbook.isDebug then
		-- dump(propertyTotal, "propertyTotal")
		-- dump(totalPower, "totalPower", nesting)
	-- end
	return propertyTotal
end

-- 获取一个阵位 站上一个奇侠时获得的属性加成
-- 加成的属性加给名册内的所有奇侠
-- 单坑奇侠属性加成 = 配置百分比上限 * (当前坑中奇侠战力/配置的战力上限)*(1+名册百分比加成) + 配置的单坑属性加成
function FuncHandbook.getPropertyAddFromOneDir(userData,dirId)
	local handbookData = FuncHandbook.getUserHandbookData(userData.handbooks) 
	-- dump(handbookData, "handbookData", nesting)
	local allPartnerData = userData.partners
	local loveData = userData.loves
	local allSkinsData = userData.skins

	local arr = {}
	local oneDirData = handbookData[tostring(dirId)]
	if oneDirData then
		local positionsStatus = oneDirData.positions
		local dirLevel = oneDirData.level or 1
		local inplaceNum = 0   -- 上阵奇侠数量
		for index,inplacePartnerId in pairs(positionsStatus) do
			if tostring(inplacePartnerId) ~= "" then
				inplaceNum = inplaceNum + 1
				-- 配置的百分比上限
				local properties = table.deepCopy(FuncHandbook.getPropertiesByDirAndIndex(dirId,index) )
				-- 计算在位伙伴战力
				local inplacePartnerData = allPartnerData[tostring(inplacePartnerId)]
				local inplacePartnerPower = FuncPartner.getPartnerAbility(inplacePartnerData, userData, userData.formation,{handbooks =1})
					
				

				-- 配置的单奇侠养成战力上限
				local powerExtreme = FuncHandbook.maxValuePartnerPower
				-- 名册加成百分比
				local curData = FuncHandbook.getOneDirLvData( dirId,dirLevel )
				local addFactor = (1 + curData.score/10000)
				-- 计算
				local factor = (inplacePartnerPower/powerExtreme)*addFactor
				for k,oneProperty in pairs(properties) do
					oneProperty.value = math.floor(oneProperty.value * factor)
				end
				table.insert(arr,properties)
			end
		end
		-- 配置的单个阵位加成的基础属性
		local baseProperties = FuncDataSetting.getHandbookBaseProperty()
		for k,oneProperty in pairs(baseProperties) do
			oneProperty.value = math.floor(oneProperty.value * inplaceNum)
		end
		table.insert(arr,baseProperties)
	end
	-- dump(arr, "arr111", nesting)
	return arr
end

-- 获取一个名册评分
function FuncHandbook.getScoreOneDir( userData,dirId )
	local totalScore = 0
	local handbookData = FuncHandbook.getUserHandbookData(userData.handbooks) 
	local oneDirData = handbookData[tostring(dirId)]
	if oneDirData then
		local positionsStatus = oneDirData.positions
		for index,inplacePartnerId in pairs(positionsStatus) do
			if tostring(inplacePartnerId) ~= "" then
				local score = FuncHandbook.getScoreOnePartner(userData.partners[inplacePartnerId],  userData,dirId)
				totalScore = totalScore + score
			end
		end
	end
	return totalScore
end

-- 获取一个名册的战力加成
function FuncHandbook.getPowerAdditionOneDir( userData,dirId )
	local totalPower = 0
	local handbookData = FuncHandbook.getUserHandbookData(userData.handbooks) 
	local oneDirData = handbookData[tostring(dirId)]
	if oneDirData then
		local positionsStatus = oneDirData.positions
		for index,inplacePartnerId in pairs(positionsStatus) do
			if tostring(inplacePartnerId) ~= "" then
				local power = FuncHandbook.getPowerAdditionOnePartner(userData.partners[inplacePartnerId], userData,dirId)
				totalPower = totalPower + power
			end
		end
	end
	return totalPower
end

--获取所有名册的战力加成 
function FuncHandbook.getAllHandBookAddition( userData )
	local handbookData = FuncHandbook.getUserHandbookData(userData.handbooks) 
	local powerMap = {}
	for k,v in pairs(handbookData) do
		local oneDirData = v
	 	local positionsStatus = oneDirData.positions
	 	local totalPower = 0
		for index,inplacePartnerId in pairs(positionsStatus) do
			if tostring(inplacePartnerId) ~= "" then
				local power = FuncHandbook.getPowerAdditionOnePartner(userData.partners[inplacePartnerId], userData,k)
				totalPower = totalPower + power
			end
		end
		powerMap[k] = totalPower
	 end
	 --存储所有系的战力加成
	 return powerMap
end

--获取伙伴在哪个名册
function FuncHandbook.getPartnerWorkingDir( partnerId,userData )
	local handbookData = userData.handbooks
	if not handbookData then
		return ""
	end
	for k,v in pairs(handbookData) do
		for kk,vv in pairs(v.positions) do
			if tostring(vv) == tostring(partnerId) then
				return  k
			end
		end
	end

	return ""

end


-- 获取单个奇侠评分
function FuncHandbook.getScoreOnePartner(partnerInfo,userData,dirId)
	local handbookData = userData.handbooks
	if dirId == "" or (not dirId) then
		return 0
	end
	--忽略计算 名册战力
	local partnerPower = FuncPartner.getPartnerAbility(partnerInfo, userData, userData.formations,{handbooks = 1})
	
	local score = partnerPower/FuncHandbook.factorPower2Score

	-- 名册加成百分比
	local oneDirData = handbookData[tostring(dirId)]
	if oneDirData then
		local dirLevel = oneDirData.level or 1
		local curData = FuncHandbook.getOneDirLvData( dirId,dirLevel )
		local addFactor = (1 + curData.score/10000)
		score =  math.floor(score * addFactor)
		-- echo("___partnerId:%s,_剔除名册战力:%d___score_:%d_level:%d_addFactor:%.2f",partnerInfo.id,partnerPower,score,dirLevel,addFactor)
		return (score)
	else
		return 0
	end
end

-- 获取一个奇侠在位产生的战力加成
function FuncHandbook.getPowerAdditionOnePartner( partnerInfo,userData,dirId )
	local score = FuncHandbook.getScoreOnePartner(partnerInfo,userData,dirId)
	local onePosAddPower = math.floor(score / FuncHandbook.factorDirScore2additionPower + FuncHandbook.maxValueBasePower)
	-- echoError("_HandbookPower__partnerId:%s,_score:%d,_addPower:%d",partnerInfo.id,score,onePosAddPower)
	return (onePosAddPower)
end

-- 读取配表获得相应坑位的加成属性
function FuncHandbook.getPropertyAddFromOneStation(dirId,index)
	return FuncHandbook.getPropertiesByDirAndIndex(dirId,index)
end

-- 转换成如下形式 key = {
-- 	mode = value
-- }
function FuncHandbook.formatProperties( arr )
	local properties = {}
	for k,v in pairs(arr) do
		for kk,vv in pairs(v) do
			if not properties[vv.key] then
				properties[vv.key] = {}
			end
			if not properties[vv.key][vv.mode] then
				properties[vv.key][vv.mode] = 0
			end
			properties[vv.key][vv.mode] =  properties[vv.key][vv.mode] + vv.value
		end
	end
	-- dump(properties, "properties", nesting)
	return properties
end

-- 获取一个评分对应的等级
function FuncHandbook.getPartnerTagByScore( score )
	local playerLevel = UserModel:level()
	local tagData = FuncHandbook.getTagDataByPlayerlevel( playerLevel )
	local tagNum = 4
	local tag = FuncHandbook.tagType.ding --"1"
	for i=4,1,-1 do
		local limit = tagData[i]
		if tonumber(score) >= tonumber(limit) then
			tag = tostring(i)
			break
		end
	end
	return tag
end

-- 将服务器数据进行转化,初始化服务器没有初始化的数据
function FuncHandbook.getUserHandbookData(userHandbooks)
	local userHandbooks = userHandbooks or {}
	for k,v in pairs(FuncHandbook.dirType) do
		if userHandbooks[tostring(v)] then
		else
			local tempDir = {
				["level"] = 1,
				["positions"] = {
					["1"] = "",
					["2"] = "",
					["3"] = "",
				},
			}
			userHandbooks[tostring(v)] = tempDir
		end
	end
	return userHandbooks
end


--获取对应的解锁花费 
function FuncHandbook.getCostByDir( dirId,index )
	local data = FuncHandbook.getOneDirData ( dirId )
	local indexArr = data.index
	return toint(indexArr[index])
end

--获取对应dir的icon
function FuncHandbook.getDirIconSp( dirId )
	local data = FuncHandbook.getOneDirData ( dirId )
	local icon = data.icon
	return display.newSprite( FuncRes.iconHandbook( icon) )
end

--获取对应dir的icon
function FuncHandbook.getUnlockLevel( dirId )
	local data = FuncHandbook.getOneDirData ( dirId )
	return data.level
end