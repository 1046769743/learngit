-- ArtifactModel
--在GameLuaLoader.lua添加文件

local ArtifactModel = class("ArtifactModel", BaseModel);

function ArtifactModel:init(data)
    ArtifactModel.super.init(self, data)
    -- dump(data,"==神器数据==",8)
    self.allServerData = data or {}
    self.RewardData = {}

	self.goodcardnum = 0
	self:patchEvent()
    self:initData()

    --主城发红点
    self:sendHomeviewRed()

end

--获得抽卡道具符
function ArtifactModel:getChouKaItemNum()
	local itemID = FuncArtifact.getCLotteryItemId()
	local num =  ItemsModel:getItemNumById(itemID)
	return num
end


function ArtifactModel:patchEvent()
	EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, 
        self.sendHomeviewRed, self)
	EventControler:addEventListener(ShopEvent.SHOPEVENT_BUY_ITEM_END, self.sendHomeviewRed, self)
	EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.sendHomeviewRed, self)
end
function ArtifactModel:sendHomeviewRed()
	local isshowred  = self:freeDrawcardRed()
	local isallred = self:allred()
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
   {redPointType = HomeModel.REDPOINT.DOWNBTN.CIMELIA, isShow = isshowred or isallred})
end


function ArtifactModel:isOpenArtifactSystem()
	local isOpen, needLvl = FuncCommon.isSystemOpen("cimelia")
    if isOpen then
        WindowControler:showWindow("ArtifactMainView");
    else
    	
    	local _str = string.format(GameConfig.getLanguage("tid_common_2041"), tostring(needLvl))
        WindowControler:showTips(_str); 
    end   
end
function ArtifactModel:ByartifactIdGetType(artifact)
	
	local artifactdata = FuncArtifact.getAllSinglecimelia()
	if artifact == nil then
		return morenid
	end
	for k,v in pairs(artifactdata) do
		if tonumber(v.itemId) == tonumber(artifact) then
			return v.group
		end
	end
	local morenid = "502"
	local alldata  =  FuncArtifact.getAllcimeliaCombine()
	for k,v in pairs(alldata) do
		if v.combineColor == 2 then   --普通类型
			morenid  = k  
		end
	end

	return morenid
end


function ArtifactModel:updateData(data)
    ArtifactModel.super.updateData(self, data)
    -- dump(data,"==神器服务器数据修改==",8)
    -- dump(self.alldata,"数据变化前的结构",6)
    --[[
    ["1001"] = {
	-- 		id = 101,
	-- 		quality = 0,
	-- 		cimelias = {
	-- 			["1"] = {
	-- 				id = 1,
	-- 				quality = 1,
	-- 			},
	-- 		},]]

    for k,v in pairs(data) do
    	for _k,_v in pairs(self.alldata) do
    		if k == _k then
    			if v.quality ~= nil then
    				_v.quality = v.quality
    			end
    			if v.cimelias ~= nil then
    				for key,valuer in pairs(v.cimelias) do
    					local isserve = false 
    					if table.length(_v.cimelias) ~= 0 then
	    					for __k,__v in pairs(_v.cimelias) do
	    						if key == __k then
	    							__v.quality = valuer.quality
	    							isserve = true
	    						end
	    					end
	    					if isserve == false then
		    					_v.cimelias[key] = {}
		    					_v.cimelias[key].id = key
		    					_v.cimelias[key].quality = valuer.quality

		    				end
	    				else
	    					_v.cimelias = v.cimelias
	    				end

    				end
    			end
    		end
    	end
    end
    -- dump(self.alldata,"数据变化后的结构",6)
    EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT)
    ArtifactModel:sendHomeviewRed()
end

--[["101" = {
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
	},]]
function ArtifactModel:initData()
	local alldata = {}
	local allCCtable = FuncArtifact.getAllcimeliaCombine()
	-- dump(allCCtable,"组合数据本地表")
	for k,v in pairs(allCCtable) do
		alldata[k] = {
			id = tonumber(k),
			quality = 0,
			cimelias = {},
		}
	end
	self.alldata = alldata
	for k,v in pairs(self.alldata) do
		if self.allServerData[k] ~= nil then
			v.quality = self.allServerData[k].quality
			if self.allServerData[k].cimelias ~= nil then
				v.cimelias = self.allServerData[k].cimelias
			end
		end
	end
end
--获得所有数据
function ArtifactModel:getAllData()
	
	return self:dataSorting()
end
--所有数据改格式结构  {[1] = ,[2] = }
function ArtifactModel:dataSorting()
	local index = 1
	local newtable = {}
	local allCCtable = FuncArtifact.getAllcimeliaCombine()
	local newindex = 1
	local newalltab = {}
	for k,v in pairs(allCCtable) do
		v.id = k
		newalltab[newindex] = v
		newindex = newindex + 1
	end
	newalltab = self:sortQuileAndID(newalltab)
	for i=1,#newalltab do
		local id = tonumber(newalltab[i].id)
		for k,v in pairs(self.alldata) do
			if tonumber(id) == tonumber(v.id) then
				newtable[i] = v
			end
		end
	end

	-- dump(newtable,"组合数据结构模式",8)
	-- newtable = self:getsorting(newtable)

	
	return newtable
end
function ArtifactModel:sortQuileAndID(arrTab)
	local partner_table_sort = function (a,b)
		local iask = false
		if a.combineColor < b.combineColor then
			iask = true
		elseif a.combineColor == b.combineColor then
			if a.rank < b.rank then
				iask = true
			end
		end
		return iask
    end
    table.sort(arrTab,partner_table_sort)
    return arrTab

end



function ArtifactModel:getsorting(alldata)
    local partner_table_sort = function (a,b)
        return tonumber(a.id) < tonumber(b.id)
    end
    table.sort(alldata,partner_table_sort)
    return alldata
end

--根据组合ID获取数据
function ArtifactModel:byIdgetData(artifactId)
	if self.alldata[tostring(artifactId)] == nil then
		return nil
	end
	return self.alldata[tostring(artifactId)]
end
--获得单个组合战力
function ArtifactModel:getSinglePower(artifactId)
	-- FuncArtifact.byIdgetCUInfo(artifactId)
	local sum1,sum2 = self:getIdByCCAbility(artifactId)
	local attrtable ,sumbility =  self:getSingleInitAttr(artifactId)
	local attrnumber = 0

	return attrnumber + sumbility + sum2

end

--伙伴和主角的战力之和   --组合D
function ArtifactModel:getCharAndPartherPower(ccid)

	-- local singdata = self.alldata[tostring(ccid)]
	-- FuncArtifact.getAllArtifactAttr(alldata,p_id)
	local artifactData = {}
	artifactData[ccid] = self.alldata[ccid]
	local charData = CharModel:getCharData()
   --local allability = FuncChar.getCharFightAttribute(charData,nil,nil,nil,nil,artifactData,nil)
	local userData = UserModel:getUserData()
	local params = {
        chard = charData,
        userd = userData,
        artid = artifactData,
    }
   	local allability = FuncChar.getCharFightAttribute(params)
   -- dump(allability,"========总属性战力=======")
end
--根据组合神器Id获得品质来计算战力
function ArtifactModel:getIdByCCAbility(ccid)
	local cCInfo = FuncArtifact.byIdgetcombineUpInfo(ccid)
	local cCquality = self:getCimeliaCombinequality(ccid)
	local sumbility = 0
	local nowsumbility = 0
	for i=1,cCquality do
		if i ~= cCquality then
			sumbility = sumbility + cCInfo[tostring(i)].addAbility
		end
		nowsumbility = nowsumbility + cCInfo[tostring(i)].addAbility
	end
	-- echo("=========sumbility========",cCquality,ccid,sumbility,nowsumbility)
	return sumbility,nowsumbility
end
--根据神器单个Id获得品质来计算战力
function ArtifactModel:getIdBySingleAbility(artifactId,_quality)
	
	local info = FuncArtifact.byIdgetsingleInfo(artifactId)
	local groupId = info.group
	local sumaddAbility =  0
	local nowsumaddAbility = 0
	local quality = _quality 
	if _quality == nil then
		quality = self:getalldataquality(groupId,artifactId)
	end
	-- echo("=========quality====111==quality=========",quality,_quality)
	local artifacttable = FuncArtifact.byIdgetCUInfo(artifactId)
	-- dump(artifacttable,"2222222222")

	for i=1,quality do
		if i ~= quality then
			sumaddAbility = sumaddAbility + artifacttable[tostring(i)].addAbility --ratioAddAbility
		end

		nowsumaddAbility = nowsumaddAbility + artifacttable[tostring(i)].addAbility --ratioAddAbility
	end
	-- echo("=========根据神器单个Id获得品质来计算战力==========",quality,artifactId,sumaddAbility,nowsumaddAbility)
	return sumaddAbility,nowsumaddAbility
end
--获取所有组合战力
function ArtifactModel:getAllDataPower()
	local sumbility = 0
	-- local teamFormation = TeamFormationModel:getFormation( FuncTeamFormation.formation.pve)
	-- local teamPartners = {}
	-- -- for i=2,6 do
	-- -- 	local id = teamFormation.partnerFormation["p"..i]
	-- -- 	if id then
	-- -- 		table.insert(teamPartners, id)
	-- -- 	end
	-- -- end
	-- local treasureId = TeamFormationModel:getOnTreasureId()
	-- local userData = UserModel:getAbilityUserData()
	-- sumbility = FuncArtifact.getArtifactAllPower( userData)
	-- return sumbility
	for k,v in pairs(self.alldata) do
		sumbility = sumbility + self:getSinglePower(k)
	end
	return sumbility
end
--获得单个组合基本属性  ---组合ID
function ArtifactModel:getSingleInitAttr(artifactId,isnext)
	local battle = {}
	local levbility = 0
	if self.alldata[tostring(artifactId)] == nil then
		return battle
	end	
	local artifactdata = self.alldata[tostring(artifactId)]

	battle, levbility = self:getSingleInitAttrByData(artifactdata, isnext)
	return battle, levbility
end

--获得分享战力数据
function ArtifactModel:getShareDataPower(data)
	dump(data,"33333333333333333333")
	local quality = data.quality
	local ccid = data.id
	local sumbility,nowsumbility = FuncArtifact.getIdByCCAbility(ccid,quality)
	local battle, levbility = self:getSingleInitAttrByData(data)  --getCimeliaCombinequality
	return nowsumbility + levbility

end

function ArtifactModel:getSingleInitAttrByData(_artifactData, isnext)

	local battle = {}
	local levbility = 0	
	if not _artifactData or table.length(_artifactData) == 0 then
		return battle
	end
	local battleindex = 1
	for k,v in pairs(_artifactData.cimelias) do
		local id = v.id
		local quality = v.quality
		local s_table = table.deepCopy(FuncArtifact.byIdgetCUInfo(id))
		local itemdata = s_table[tostring(quality)]
		if isnext then
			local count = 0
			for k, v in pairs( s_table ) do
		        count = count + 1
		    end

			if quality+1 <= count then
				itemdata = s_table[tostring(quality+1)]
				local initAttr = itemdata.initAttr
				-- levbility = levbility + itemdata.addAbility   --lvAbility
				local sum1,sum2 = self:getIdBySingleAbility(id,quality)
				levbility = levbility + sum2
				if initAttr ~= nil then
					for i=1,#initAttr do
						local Attribute = initAttr[i]
			            -- dump(battle,"2222222333334444")
			            if #battle == 0 then
			                battle[battleindex] = Attribute
			                battleindex = battleindex + 1
			            else
			                local servedata = false
			                for index=1,#battle do
			                    if battle[index].key == Attribute.key and battle[index].mode == Attribute.mode then
			                        battle[index].value = battle[index].value + Attribute.value
			                        servedata = true
			                    end 
			                end
			                if servedata == false then
			                    battle[battleindex] = Attribute
			                    battleindex = battleindex + 1
			                end
			            end
					end
				end
			end
		else
			local initAttr = itemdata.initAttr
			-- levbility = levbility + itemdata.addAbility   --lvAbility
			local sum1,sum2 = self:getIdBySingleAbility(id,quality)
			levbility = levbility + sum2
			if initAttr ~= nil then
				for i=1,#initAttr do
					local Attribute = initAttr[i]
		            -- dump(battle,"2222222333334444")
		            if #battle == 0 then
		                battle[battleindex] = Attribute
		                battleindex = battleindex + 1
		            else
		                local servedata = false
		                for index=1,#battle do
		                    if battle[index].key == Attribute.key and battle[index].mode == Attribute.mode then
		                        battle[index].value = battle[index].value + Attribute.value
		                        servedata = true
		                    end 
		                end
		                if servedata == false then
		                    battle[battleindex] = Attribute
		                    battleindex = battleindex + 1
		                end
		            end
				end
			end
		end
	end
	return battle,levbility
end

-- "101" = {
-- 		id = 101,
-- 		quality = 0,
-- 		cimelias = {
-- 			"1001" = {
-- 				id = 1001,
-- 				quality = 1,
-- 			},
-- 			"1002" = {
-- 				id = 1002,
-- 				quality = 7,
-- 			},
-- 		},
-- 	},
--获得组合神器品质 ccid ==> CimeliaCombineid 就是组合神器ID
function ArtifactModel:getCimeliaCombinequality(ccid)
	local quality = 0
	if self.alldata[tostring(ccid)] == nil then
		echo("=======该数据未激活=============")
		return quality
	end
	quality = self.alldata[tostring(ccid)].quality
	return quality
end
--获取所有单个神器品质
function ArtifactModel:getalldataquality(groupId,cimeliaId)
	local quality = 0
	-- dump(self.alldata,"所有属性",7)
	if self.alldata[tostring(groupId)] == nil then
		echo("=======该数据未激活=============")
		return quality
	end
	local groupdata = self.alldata[tostring(groupId)]
	local cimeliadata =	groupdata.cimelias[tostring(cimeliaId)]
	if cimeliadata == nil then
		return quality
	end
	return cimeliadata.quality
end
--单个进阶属性显示 根据宝物id
function ArtifactModel:getSingleAdvancedAttribute(cimeliaId,ischang)
	local cimeliadata = FuncArtifact.byIdgetCUInfo(cimeliaId)
	local artifactdata = FuncArtifact.byIdgetsingleInfo(cimeliaId)
	local quality = self:getalldataquality(artifactdata.group,cimeliaId)

	local currentdata =nil
	local nextdata = nil

	if ischang then
		currentdata = cimeliadata[tostring(quality)]
		nextdata = cimeliadata[tostring(quality-1)]
	else
		currentdata = cimeliadata[tostring(quality)]
		nextdata = cimeliadata[tostring(quality+1)]
	end
	
	local currentable = {}
	local nexttable = {}
	if currentdata ~= nil then
		local curreninitAttr = currentdata.initAttr
		if curreninitAttr ~= nil then
			for i=1,#curreninitAttr do
				currentable[i] = curreninitAttr[i]
			end
		end
	end
	if nextdata ~= nil then
		if nextdata.initAttr ~= nil then
			for i=1,#nextdata.initAttr do
				nexttable[i] = nextdata.initAttr[i]
			end
		end
	end

	local newtable = {}
	if #currentable >= #nexttable then
		for i=1,#currentable do
			local isare = false
			for _x=1,#nexttable do
				if currentable[i].key == nexttable[_x].key and currentable[i].mode == nexttable[_x].mode then
					local combination = {[1] = currentable[i] ,[2] = nexttable[_x]}
					table.insert(newtable,combination)
					isare = true
				end
			end
			if isare == false then
				local combination = {[1] = currentable[i]}
				table.insert(newtable,combination)
			end
		end
	else
		for i=1,#nexttable do
			local isare = false
			for x=1,#currentable do
				if currentable[x].key == nexttable[i].key and currentable[x].mode == nexttable[i].mode then
					local combination = {[1] = currentable[x] ,[2] = nexttable[i]}
					table.insert(newtable,combination)
					isare = true
				end
			end
			if isare == false then 
				local combination = {[1] = {key = nexttable[i].key,value = 0,mode = nexttable[i].mode},[2] = nexttable[i]}
				table.insert(newtable,combination)
			end
		end
	end
		--[[
		currentable = {
			[1] = {key = 1,value = 2,mode = 3},	
			[2] = {key = 1,value = 2,mode = 3},
		}
		nextdata = {
			[1] = {key = 1,value = 2,mode = 3},	
			[2] = {key = 1,value = 2,mode = 3},
		}
		newtable = {
			[1] = {[1] = {},[2] = {}},
		}
	]]
	local extstep = nil  --下一阶解锁
	local cimeliadata = FuncArtifact.byIdgetCUInfo(cimeliaId)
	local allnextattr = {}
	local indexs = 1
	-- dump(cimeliadata,"222222222222222")
	for i=1,table.length(cimeliadata) do
		if cimeliadata[tostring(i)].upAttr ~= nil then
			allnextattr[indexs] = {}
			allnextattr[indexs].quality = i
			-- dump(cimeliadata[tostring(i)],"3333333333333",8)
			local upAttr = nil
			if cimeliadata[tostring(i)].upAttr ~= nil then	
				allnextattr[indexs].attr = cimeliadata[tostring(i)].upAttr
			end
			if cimeliadata[tostring(i)].upAttrDes ~= nil then
				-- echo(cimeliadata[tostring(i)].upAttrDes,"======4444=====")
				allnextattr[indexs].des = cimeliadata[tostring(i)].upAttrDes 
			end 
			indexs = indexs + 1
		end
	end
	-- quality 当前品质
	local nextattr = {}
	for i=1,#allnextattr do
		if allnextattr[i].quality == (quality + 1) then
			nextattr[1] = {}
			nextattr[1] = { 
				quality = allnextattr[i].quality,
				attr = allnextattr[i].attr,
				des = allnextattr[i].des
			}
		end
	end

	--[[
		allnextattr = {
			[1] = { quality = 1,attr = {} ,des = "#tid1001"},
			[4] = { quality = 4,attr = {} ,des = "#tid1001"},
		}
	]]


	return newtable,nextattr,allnextattr
end

---获得组合进阶道具
function ArtifactModel:getCCadvancedItem(ccid)
	
end
-- 获得组合进阶属性列表
function ArtifactModel:getCCAttrlistTable(ccid)
	local combineUpdata = FuncArtifact.byIdgetcombineUpInfo(ccid)
	local ccAttrlist = {}
	local _index = 1
	for i=1,table.length(combineUpdata) do
		local skillUpDes = combineUpdata[tostring(i)].skillUpDes
		if skillUpDes ~= nil then
			ccAttrlist[_index] = {}
			ccAttrlist[_index].skillUpDes = skillUpDes
			ccAttrlist[_index].ccid = ccid
			ccAttrlist[_index].quality = i
			_index = _index + 1
		end
	end
	return ccAttrlist
end
function ArtifactModel:getDesStaheTable(des,isvaluer)
    if des == nil then
        return ""
    end
    local buteData = FuncChar.getAttributeData()
    -- echo("==============",buteData[tostring(des.key)])
    local buteName = GameConfig.getLanguage(buteData[tostring(des.key)].name)
    -- GameConfig.getLanguage(buteData[tostring(des.key)].name)

    local valuer = FuncArtifact.getFormatFightAttrValue(des.key,des.value)
    --echo("=======valuer======",des.key,valuer)
    -- echo("=======valuer======",des.key,valuer)
    --local str = buteName..valuer
    local str = "<color=89674B>"..buteName.."<-> <color=008c0d>"..valuer.."<->"
    if des.mode == 2 then   ---万分比
	    local desvalue = des.value/100
	    --str = buteName.." "..desvalue.."%"
	    str = "<color=89674B>"..buteName.."<->  <color=008c0d>"..desvalue.."%<->"
	end
	-- elseif des.mode == 3 then   --固定值
	-- 	local desvalue = des.value
	-- 	str = buteName.." "..desvalue
	-- end
    if isvaluer == false then
    	return buteName
    end
    return str
end





--所有背包中的神器
function ArtifactModel:getbackpackArtifactItem()
	local allArtifact = FuncArtifact.getAllSinglecimelia()
	local itemAndNumber = {}
	local _index = 1
	for k,v in pairs(allArtifact) do
		
		local itemid = v.itemId
		local itemnumber = ItemsModel:getItemNumById(itemid)  ---测试
		if itemnumber ~= 0 then
			itemAndNumber[_index] = {}
			itemAndNumber[_index].id = tonumber(k)
			itemAndNumber[_index].number = itemnumber
			_index = _index + 1
		end
	end
	return itemAndNumber
end
--设置旧的战力
function ArtifactModel:setoldPower(power)
	self.oldPowerValuer = power
end
function ArtifactModel:getoldPower()
	return self.oldPowerValuer or 0
end


--服务器购买的总次数次数
function ArtifactModel:getBuyItems()
	local number =	CountModel:getArtifactDayCount()
	return number or 0
end
--抽卡道具的数量道具
function ArtifactModel:ChouKaItemsNumber()
	return self:getChouKaItemNum()
end

--设置抽卡类型
function ArtifactModel:setChouaType(_type)
	self.choukaType = _type
end
function ArtifactModel:getChouaType()
	return  self.choukaType
end

--判断抽卡条件
function ArtifactModel:judgeFile(_type)
	local sumcount = FuncArtifact.todayBuyItems()  --总次数 判断
	local buyItems = ArtifactModel:getBuyItems()
	local shenyuitems = sumcount - buyItems
	if buyItems - sumcount >= 0 then
		if CountModel:getArtifactCount() ~= 0 then
			if self:getChouKaItemNum() > 0 then
			else
				WindowControler:showTips(GameConfig.getLanguage("#tid_shenqi_001"));
				return false
			end
		else
			if _type == FuncArtifact.ChouKaItems.CHOUKA_ONE then
				return true
			else
				if self:getChouKaItemNum() > 0 then
				else
					WindowControler:showTips(GameConfig.getLanguage("#tid_shenqi_002"));
					return false
				end
			end
		end
	end 
	local gold = UserModel:getGold()
	if _type == FuncArtifact.ChouKaItems.CHOUKA_ONE then
		if self:getChouKaItemNum() > 0 then
			return true
		end
		if  CountModel:getArtifactCount() == 0 then
			return
		end
		if shenyuitems >= FuncArtifact.ChouKaItems.CHOUKA_ONE then
			local rmboneitems = FuncArtifact.getCConsumeNumber()   ---一次花费
			if gold >= rmboneitems then
				return true
			else
				-- WindowControler:showTips(GameConfig.getLanguage("tid_common_1001"));
				-- WindowControler:showWindow("MallMainView",FuncShop.SHOP_CHONGZHI)
				WindowControler:showWindow("CompGotoRechargeView")
				return false
			end
		else
			WindowControler:showTips(GameConfig.getLanguage("#tid_shenqi_002"));
			return false
		end
		
	else
		if self:getChouKaItemNum() >= 5 then
			return true
		end

		if shenyuitems >= FuncArtifact.ChouKaItems.CHOUKA_FIVES then
			local rmbFiveitems = FuncArtifact.cLotteryGoldConsume()   --五次花费
			if gold >= rmbFiveitems then
				return true
			else
				-- WindowControler:showTips(GameConfig.getLanguage("tid_common_1001"));
				-- WindowControler:showWindow("TempGotoRechargeView")
				-- WindowControler:showWindow("MallMainView",FuncShop.SHOP_CHONGZHI)
				WindowControler:showWindow("CompGotoRechargeView")
				return false
			end
		else 
			WindowControler:showTips(GameConfig.getLanguage("#tid_shenqi_002"));
			return false
		end
		
	end

	return false
end
--免费抽奖显示红点
function ArtifactModel:freeDrawcardRed()
	local isred = false
	if CountModel:getArtifactCount() == 0 then
		isred = true
	end
	return isred
end
function ArtifactModel:allred()
	local arrtable = FuncArtifact.getAllcimeliaCombine()
	for k,v in pairs(arrtable) do
		local singlered = ArtifactModel:ByCCIDgetAdvancedRedShow(k)
		local isShowRed = ArtifactModel:ByCCIDgetAdvanced(k)
		if singlered then
			return true
		end
		if isShowRed then
			return true
		end
	end
	return false
end

--抽卡奖励设置奖励
function ArtifactModel:setRewardData(reward)
	self.RewardData = {}
	for i=1,#reward do
		self.RewardData[i] = {}
		local rewardtable = string.split(reward[i], ",")
		self.RewardData[i][1] = rewardtable[1]
		self.RewardData[i][2] = rewardtable[2]
		self.RewardData[i][3] = rewardtable[3]
	end

end
function ArtifactModel:getRewardData()
	-- dump(self.RewardData,"00000000000")
	return self.RewardData
end
--设置点击抽卡次数类型
function ArtifactModel:setTouchType(_type)
	self.loteryType = _type
end
function ArtifactModel:getTouchType()
	return self.loteryType

end
--抽卡基本获得精华数量
function ArtifactModel:getJinHuaNumbers()
	return FuncArtifact.getJinHuaNumber(self.loteryType)
end
--根据组合进阶ID  ccid 判断是否满住条件  1 进阶条件 2 进阶道具
function ArtifactModel:ByCCIDgetAdvanced(ccid)
	local ccquality = ArtifactModel:getCimeliaCombinequality(ccid)  --组合品质
	if ccquality >= FuncArtifact.Fullorder then
		return false
	end
	local ccinfo = FuncArtifact.byIdgetcombineUpInfo(ccid)  --组合神器进阶数据表
	local singleCCData = ccinfo[tostring(ccquality+1)]
	if singleCCData ~= nil then
		local condition =  singleCCData.condition  --进阶条件
		for i=1,#condition do
			local conditioninfo = condition[i]
			local artifactid = conditioninfo.cimelia  ---宝物ID
			local artifactquality = conditioninfo.quality
			local groupId = FuncArtifact.byIdgetsingleInfo(artifactid).group
			local currentquality = ArtifactModel:getalldataquality(groupId,artifactid)
			if currentquality < artifactquality then
				return false,FuncArtifact.errorType.NOT_CONDITIONS
			end
		end


		local cost = singleCCData.cost
		if cost ~= nil then
			for i=1,#cost do
				local costtable = string.split(cost[i], ",");
				local types =  costtable[1]
				local itemid = tonumber(costtable[2])
				local neednumbers = tonumber(costtable[3])---消耗数量
				local havenumber = ItemsModel:getItemNumById(itemid)
				local iteminfo = FuncItem.getItemData(itemid)  --道具详情
				local name = ""
				if iteminfo ~= nil then
					name = iteminfo.name
				end
				if havenumber < neednumbers then
					return false,FuncArtifact.errorType.NOT_ITEM_NUMBER,name,itemid
				end
			end
		end
		return true
	end
end
--根据组合ID获得每个道具的red显示不显示
function ArtifactModel:ByCCIDgetAdvancedRedShow(ccid)
	local ccinfo = FuncArtifact.byIdgetCCInfo(ccid)
	local contain_table = ccinfo.contain   --多少个宝物以
	for i=1,#contain_table do
		local cimeliaid = contain_table[i]
		local isshow = self:getSingleAdvancedRed(cimeliaid)
		if isshow then
			return true
		end
	end
	return false
	
end
--获得单个神器进阶
function ArtifactModel:getSingleAdvancedRed(artifactid)
	-- echo("=======artifactid===1=========",artifactid)
	local groupId =  FuncArtifact.byIdgetsingleInfo(artifactid).group
	-- echo("=======artifactid===22222222222222222222=========")
	local artifactquality = ArtifactModel:getalldataquality(groupId,artifactid)
	local artifactInfo = FuncArtifact.byIdgetCUInfo(artifactid)
	-- echo("=======artifactid===2=========",artifactid)
	if artifactquality < FuncArtifact.Fullorder then
		if artifactInfo ~= nil then
			local singleData = artifactInfo[tostring(artifactquality+1)]
			local  condition =  singleData.condition  --进阶条件
			local tiaojian = string.split(condition[1], ",");
			if tonumber(tiaojian[1]) == 1 then   --主角达到XX等级
				local level = tiaojian[2]
				if UserModel:level() >= tonumber(level) then
				else
					return false,FuncArtifact.errorType.PLAYERLEVEL,nil,level
				end
			end

			if singleData ~= nil then
				for i=1,#singleData.cost do
					local costtable = string.split(singleData.cost[i], ",");
					local types =  costtable[1]
					local itemid = tonumber(costtable[2])
					local neednumbers = tonumber(costtable[3])---消耗数量
					local havenumber = ItemsModel:getItemNumById(itemid)
					local iteminfo = FuncItem.getItemData(itemid)  --道具详情
					if havenumber < neednumbers then
						return false,FuncArtifact.errorType.NOT_ITEM_NUMBER,iteminfo.name,nil,itemid
					end
				end
			end
			return true
		else
			echoError("=====组合神器进阶数据没配，找金钊   Id =====",artifactid)
			return false
		end
	else
		return false,FuncArtifact.errorType.MEET_CONDITIONS
	end
end

--抽卡剩余的次数
function ArtifactModel:DrawCardItems()
	return  FuncArtifact.todayBuyItems() - ArtifactModel:getBuyItems()
end

--选着抽卡的类型
function ArtifactModel:setchoukaType(select_type)
	self.choukaType = select_type
end
function ArtifactModel:activeArtifactNum()
	local sumnum = 0
	local sinnum = 0
	if self.alldata ~= nil then
		for k,v in pairs(self.alldata) do
			local num = table.length(v.cimelias)
			sinnum = sinnum + num
			if v.quality ~= 0 then
				sumnum = sumnum + 1
			end
		end
	end
	-- echo("=====神器任意激活数量===单个和总数量====",sumnum,sinnum)
	return sumnum,sinnum
end
--获得神器等阶数量
function ArtifactModel:artifactQuilityNum(quility)
	local num = 0
	if self.alldata ~= nil then
		for k,v in pairs(self.alldata) do
			if v.quality == quility then
				num = num + 1
			end
		end
	end
	return num
end

--设置未打开的号卡牌数量
function ArtifactModel:setGoodCardNum(num)
	self.goodcardnum = self.goodcardnum + num
	if self.goodcardnum <= 0  then
		self.goodcardnum = 0
	end
end
function ArtifactModel:getGoodCardNum()
	return self.goodcardnum 
end

function ArtifactModel:setselectArID(id)
	self.selectArID = id
end
function ArtifactModel:getselectArID()
	return self.selectArID 
end

function ArtifactModel:getArtifactCountByQualityOrAdvance(_type, _targetValue)
	local result = 0
	if _type == FuncArtifact.carnivalType.COLOR_TYPE then
		for k,v in pairs(self.allServerData) do
			local color = FuncArtifact.getArtifactValueByIdAndKey(k, "combineColor")
			if tonumber(v.quality) >= 1 and tonumber(color) == tonumber(_targetValue) then
				result = result + 1
			end

		end
	elseif _type == FuncArtifact.carnivalType.ADVANCED_TYPE then
		for k,v in pairs(self.allServerData) do
			if tonumber(v.quality) >= tonumber(_targetValue) then
				result = result + 1
			end
		end
	end
	return result
end


--发送分享到聊天界面
function ArtifactModel:sendChatToWorld(data)

    local function callback(event)
		if event.result then
			WindowControler:showTips("分享成功")--GameConfig.getLanguage("#tid_Talk_101"))
		end
	end

	local text =  json.encode({"1","2"})  --测试用
	local  param={};
	param.content= _text; --{_text};
	param.type = 1   ---分享的类型
	ChatServer:sendWorldMessage(param,callback);
end




--显示单个神器属性漂字
function ArtifactModel:showNumberEff(_ctn,orderpreview,nextattr,callBack)
	

	local params = {
		text = {},
		isAnimation  = true,
		isEffectType = FuncCommUI.EFFEC_NUM_TTITLE.ACTIVATION,
		callBack = callBack,
		x = 0,
		y = -40,
	}
	if orderpreview ~= nil then
		for i=1,#orderpreview do
			local qian  = orderpreview[i][1]
			local hou  = orderpreview[i][2]
			local attrname = ArtifactModel:getDesStaheTable(qian,false)
			local valuer = hou.value -  qian.value
			if qian.mode == 2 then
				valuer = (valuer/100).."%"
			elseif qian.mode == 3 then
				valuer = valuer
			end
			local str = attrname.."+"..valuer
			table.insert(params.text,str)
		end
	end
	if nextattr then
		for i=1,#nextattr do
			local des = GameConfig.getLanguage(nextattr[i].des)
			table.insert(params.text,des)
		end
	end

	if params.text then
		if #params.text ~= 0 then
			FuncCommUI.playNumberRunaction(_ctn,params)
		end
	end


end






return ArtifactModel;

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



















