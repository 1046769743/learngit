-- GuildExploreLineupView.lua
-- Author: Wk
-- Date: 2017-07-05
-- 占矿布阵主界面

local GuildExploreLineupView = class("GuildExploreLineupView", UIBase);

--上阵的数量
local lineupNum = {
	mining = 3,
	building = 4,
}
--采矿的数据allData  {id = ,name = ,_type = ,callBack = ,index = }
function GuildExploreLineupView:ctor(winName,allData)
    GuildExploreLineupView.super.ctor(self, winName);
    self.allData = allData

    dump(self.allData,"采矿的数据allData ============ ")
end

function GuildExploreLineupView:loadUIComplete()
	 self._sortType = true
	--上阵伙伴的数据
	self.lineupPartnerData = {}
	self.UI_1.txt_1:setString(self.allData.name)
	self.panel_2.panel_1:setVisible(false)
	self:setAllButton()
	self:setUIViewAlign()
	self:registerEvent()
	self:initData()
end 

function GuildExploreLineupView:setAllButton()
	self.UI_1.btn_1:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);
	self.btn_1:setTouchedFunc(c_func(self.sendPantnerData, self),nil,true);
	self.btn_2:setTouchedFunc(c_func(self.sendAllPantnerData, self),nil,true);
	-- self.panel_2.btn_1:setTouchedFunc(c_func(self.partnerButtonOne, self),nil,true);
	-- self.panel_2.btn_2:setTouchedFunc(c_func(self.partnerButtonTwo, self),nil,true);
end


function GuildExploreLineupView:setUIViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop)

end

function GuildExploreLineupView:registerEvent()
	GuildExploreLineupView.super.registerEvent(self)
	-- EventControler:addEventListener(NewLotteryEvent.NEXT_VIEW_UI,self.nextView,self);

end


function GuildExploreLineupView:initData()
	self:partnerSort()
	self:setPartnerListUI()
	self:setLineupPartnerData({})
	self:setTopMcData()
end


function GuildExploreLineupView:setTopMcData()
	local resData = {}  --开采的数据
	if self.allData.allData then
		minePeopleCount = table.length(self.allData.allData.occupy)--当前采矿人数
	else
		minePeopleCount = 0
	end
	local panel = nil
	local iconPath = nil--资源路径

	--上阵伙伴总战力 --TODO
	local _type = self.allData._type
	if _type == FuncGuildExplore.lineupType.building then
		self.mc_1:showFrame(3)
		panel = self.mc_1:getViewByFrame(3)
		local base =  self:getFuncData( "base" )
		-- local baseUp =  self:getFuncData( "baseUp" )
		local baseArr = string.split(base[1], ",")
		local ability = baseArr[1]
		local addAbility = baseArr[2]
		local time = baseArr[3]
		local _type = baseArr[4]
		local itemId = baseArr[5]
		local count = baseArr[6]
		local addNum = baseArr[7]

		local newpartnerIdList = {}
		if self.lineupPartnerData ~= nil then
			for k,v in pairs(self.lineupPartnerData) do
				table.insert(newpartnerIdList,v.id)
			end
		end

		local partnerAbility = GuildExploreModel:getPartnersAbility(newpartnerIdList)


		if _type == FuncGuildExplore.guildExploreResType then
			local keyData = FuncGuildExplore.getCfgDatas("ExploreResource",itemId)
			iconPath = FuncRes.getIconResByName(keyData.icon)
			count = baseArr[6]
		else
			local icon = FuncDataResource.getIconPathById( _type )
			iconPath = FuncRes.getIconResByName(icon)
			count = baseArr[5]
		end

		local resNum = 0
		if partnerAbility <= tonumber(ability) then
			resNum = tonumber(count)
		else
		 	local floor =	math.floor((partnerAbility -tonumber(ability))/tonumber(addAbility))
		 	resNum = tonumber(addNum)*floor + tonumber(count)
		end 


		if tonumber(time) ==  1 then
			panel.txt_2:setString(resNum.."/分钟")
		else
			panel.txt_2:setString(resNum.."/"..time.."分钟")
		end
		-- panel.txt_2:setString(resNum.."/分钟")
	else
		local resArr = nil
		--读取第一个字段的资源  timeYield
		local index = minePeopleCount
		-- if minePeopleCount == 0 then
		-- 	index = 1
		-- end
		local tid = self.allData.tid
		resArr =  self:getFuncData( "timeYield" )
		if resArr then  
			local reward = resArr[1]
			local res = string.split(reward, ",")
			if res[2] == FuncGuildExplore.guildExploreResType then
				local keyData = FuncGuildExplore.getCfgDatas("ExploreResource",res[3])
				iconPath = FuncRes.getIconResByName(keyData.icon)
			else
				local icon = FuncDataResource.getIconPathById( res[2] )
				iconPath = FuncRes.getIconResByName(icon)
			end
		else
			-- resArr =  self:getFuncData( "timeYield2" )
			-- local reward = resArr[index]
			-- local res = string.split(reward, ",")
			-- local iconName = FuncDataResource.getIconPathById( res[1] )
			-- iconPath = FuncRes.getIconResByName(iconName)
		end
		if minePeopleCount <= 0 then
			index = 1
			self.mc_1:showFrame(1) 
			panel = self.mc_1:getViewByFrame(1)
			local res = string.split(resArr[index], ",")
			local baseNum = 0
			if res[2] == FuncGuildExplore.guildExploreResType then
				baseNum = res[4]
			else
				baseNum = res[3]
			end
			if tonumber(res[1]) ==  1 then
				panel.txt_2:setString(baseNum.."/分钟")
			else
				panel.txt_2:setString(baseNum.."/"..res[1].."分钟")
			end
			
			panel.btn_help:setTouchedFunc(c_func(self.desButton, self,panel.btn_help),nil,true);
		else
			local questResArr = nil
			self.mc_1:showFrame(2) 
			panel = self.mc_1:getViewByFrame(2)
			local panel_text = nil
			if minePeopleCount <= 2 then
				panel.mc_1:showFrame(1)
				panel_text = panel.mc_1:getViewByFrame(1)
				questResArr = resArr[2]
			else
				panel.mc_1:showFrame(2)
				panel_text = panel.mc_1:getViewByFrame(1)
				questResArr = resArr[3]
			end
			local res = string.split(questResArr, ",")
			local baseNum = 0
			if res[2] == FuncGuildExplore.guildExploreResType then
				baseNum = res[4]
			else
				baseNum = res[3]
			end
			if tonumber(res[1]) ==  1 then
				panel_text.txt_2:setString(baseNum.."/分钟")
			else
				panel_text.txt_2:setString(baseNum.."/"..res[1].."分钟")
			end

			panel.btn_des:setTouchedFunc(c_func(self.desButton, self,panel.btn_des),nil,true);
		end
		self:setmineTime(panel)
		self:unscheduleUpdate()
		self:scheduleUpdateWithPriorityLua(c_func(self.setmineTime, self,panel) ,0)
		

	end

	panel.ctn_1:removeAllChildren()
	local sprite = display.newSprite(iconPath)
	sprite:size(35,35)
	panel.ctn_1:addChild(sprite)



	-- panel.btn_help:setTouchedFunc(c_func(self.buttonHelp, self),nil,true);

end

function GuildExploreLineupView:desButton(_ctn)
	-- WindowControler:showWindow("GuildExploreResTipsView",self.allData.id);
	GuildExploreEventModel:showResInfoView(self.allData.tid,_ctn)
end

--设置开采的时间
function GuildExploreLineupView:setmineTime(panel)
	local allData = self.allData.allData
	local data = FuncGuildExplore.getCfgDatas( "ExploreMine",allData.tid )
	local time = data.time[allData.mineSize]
	if time == nil then
		echo("========不存在===ExploreMine=时间=time 的 下标==",allData.mineSize)
		time = data.time[1]
	end
	local sumTime = time/3600
	-- dump(self.allData,"22222222222222222")
	if allData.occupy ~= nil then
		local peopleNum = table.length(allData.occupy)
		local finishTime = allData.finishTime
		if finishTime == -1 then
			panel.txt_3:setString("剩余可开采"..sumTime.."小时")
			local percent = 100
			panel.progress_1:setPercent(percent)
		else
			local shenyu = self:calculateTime(finishTime)
			panel.txt_3:setString("剩余可开采"..shenyu.."小时")
			local percent = (finishTime - TimeControler:getServerTime())/time*100
			panel.progress_1:setPercent(percent)
		end
		if peopleNum == 0 then
			peopleNum = 1
		end

		local timeYield = data.timeYield[peopleNum]
		local res = string.split(timeYield, ",")
		local num = 0
		if res[2]  ==  FuncGuildExplore.guildExploreResType then
			num = res[4]
		else
			num = res[3]
		end
		local panelText = panel
		if panel.mc_1 then
			local minePeopleCount = table.length(self.allData.allData.occupy)
			if minePeopleCount <= 2 then
				panelText = panel.mc_1:getViewByFrame(1)
			else
				panelText = panel.mc_1:getViewByFrame(2)
			end
		end

		if panelText.txt_2 then
			if tonumber(res[1]) == 1 then
				panelText.txt_2:setString(num.."/分钟")
			else
				panelText.txt_2:setString(num.."/"..res[1].."分钟")
			end

		end

		
	end
end

function GuildExploreLineupView:calculateTime(_finishTime)
	local times = _finishTime - TimeControler:getServerTime()
	if times > 0 then
		times = TimeControler:turnTimeSec(times, TimeControler.timeType_hhmmss)
	else
		times = ""
	end
	return times
end



function GuildExploreLineupView:buttonHelp()
	echo("===========详情=============")  
end


--设置上阵伙伴的数据
function GuildExploreLineupView:setLineupPartnerData(data)
	local _type = self.allData._type
	if _type == FuncGuildExplore.lineupType.mining then
		if #data == 0 then
			for i=1,lineupNum.mining do
				data[i] = {}
			end
		else
			for i=1,lineupNum.mining do
				if data[i] == nil then
					data[i] = {}
				end
			end
		end
		self:setLineupScroll(data)
	elseif _type == FuncGuildExplore.lineupType.building then
		if #data == 0 then
			for i=1,lineupNum.building do
				data[i] = {}
			end
		else
			for i=1,lineupNum.building do
				if data[i] == nil then
					data[i] = {}
				end
			end
		end
		self:setLineupScroll(data)
	end

end

--设置上阵的滚动条
function GuildExploreLineupView:setLineupScroll(data)

	self:setTopMcData()
 	local _type = self.allData._type
 	local pames = 1
 	local num = 0
	if _type == FuncGuildExplore.lineupType.mining then
		self.mc_ctn:showFrame(1)
		pames = 1 
		num = lineupNum.mining
	elseif _type == FuncGuildExplore.lineupType.building then
		self.mc_ctn:showFrame(2)
		pames = 2
		num = lineupNum.building
	end
	-- dump(data,"3333333333333")
	for i=1,num do
		local view = self.mc_ctn:getViewByFrame(pames)
		self:cellLineUpviewData(view["panel_"..i], data[i])
	end
end

function GuildExploreLineupView:cellLineUpviewData(view, itemData)
	view.ctn_1:removeAllChildren()
	if not itemData or not itemData.id then
		return
	end
	local partnerData = itemData
	local partnerID = itemData.id
	local avatar = itemData.avatar
	local skin = itemData.skin
	local sourceId = nil
	local npc = nil
	if skin and skin ~= "" then
		-- sourceId = FuncPartnerSkin.getPartnerSkinSourceId(skin)
		if partnerID ==  UserModel:avatar() then
			npc = FuncGarment.getSpineViewByAvatarAndGarmentId(avatar, UserExtModel:garmentId())
		else
			sourceId = FuncPartnerSkin.getPartnerSkinSourceId(skin)
		end
	else
		if partnerID ==  UserModel:avatar() then
			sourceId = FuncPartner.getSourceId(avatar)
		else
			sourceId = FuncPartner.getSourceId(partnerID)
		end
	end
	local spineView = nil
	if sourceId then
		local spine = FuncTeamFormation.getSpineName( sourceId )
	    local sourceData = FuncTreasure.getSourceDataById(sourceId)
	    spineView = ViewSpine.new(spine,{},nil,spine,nil,sourceData)
	else
		spineView = npc
	end
    view.ctn_1:addChild(spineView)
    spineView:playLabel("stand",true)
    local node = display.newNode()
    node:anchor(0.5,0)
    node:size(220,170)
    view.ctn_1:addChild(node)

    node:setTouchedFunc(c_func(self.removePartnerSpine, self,view,itemData),nil,true);
end

function GuildExploreLineupView:removePartnerSpine(view,itemData)
	view.ctn_1:removeAllChildren()

	for k,v in pairs(self.lineupPartnerData) do
		if v.id == itemData.id then
			self.lineupPartnerData[k] = nil
		end
	end
	self:partnerSort()
	self:setPartnerListUI()
	self:setTopMcData()
end


--伙伴排序
function GuildExploreLineupView:partnerSort()
	self:getPartnerData()
	local index = 1
	local newTable = {}

	for k,v in pairs(self.partnerData) do
		local isHas = GuildExploreModel:getpartnerIsHas(v.id)
		v.pos = 1
		if  not isHas then
			v.pos = 100 
		end
		newTable[index] = v
		index = index + 1
	end
	-- table.sort(newTable,c_func(self.partner_table_sort,self))
	local isHas = GuildExploreModel:getpartnerIsHas(UserModel:avatar())
	local pos =  1
	if not isHas then
		pos = 100
	end
	local mySelfData = {
		avatar = UserModel:avatar(),
        quality = UserModel:quality(),
        position = UserModel:position(),
        star = UserModel:star(),
        starPoint = UserModel:starPoint(),
        level = UserModel:level(),
        equips = UserModel:equips(),
        garmentId = GarmentModel:getOnGarmentId(),
        id = UserModel:avatar(),
        skin = UserExtModel:garmentId(),
        pos = pos,
        ability = CharModel:getCharAbility(), --UserModel:getcharSumAbility(),
	}
	table.insert(newTable,mySelfData)

	-- dump(newTable,"333333333333333333")
	table.sort(newTable,c_func(self.partner_isBattle_sort,self))
	-- table.sort(newTable,c_func(self.sortPos,self))

	self.partnerData = newTable
end

function GuildExploreLineupView:sortPos(a,b)
	
end

function GuildExploreLineupView:partner_isBattle_sort(a,b)
	local data_a = GuildExploreModel:getUnitInfoDataByPartnerId(a.id)
	local data_b = GuildExploreModel:getUnitInfoDataByPartnerId(b.id)
	-- if  a.pos < b.pos then
	-- 	if  data_a.ability > data_b.ability then
	-- 		return true
	-- 	else
	-- 		return false
	-- 	end
	-- end

	-- if  data_a.ability > data_b.ability then 

	if a.pos > b.pos then
		return false
	elseif a.pos == b.pos then
		if data_a and data_b  then
			if data_a.ability and data_b.ability then
				if  data_a.ability > data_b.ability then
					return true
				elseif data_a.ability < data_b.ability then
					return false
				end
			else
				return false
			end
		else
			return false
		end
	elseif a.pos < b.pos then
		return true

	end 

	
    return false

end

--对伙伴排序
function GuildExploreLineupView:partner_table_sort(a,b)
    local _sortType = function (_ret)
        if self._sortType then
            return _ret
        else    
            return not _ret
        end
    end
    local res = PartnerModel:partner_table_sort( a,b )

    return _sortType(res)
end

--获得所有伙伴
function GuildExploreLineupView:getPartnerData()
	self.partnerData = GuildExploreModel:getPartnerData() --PartnerModel:getAllPartner()
end



function GuildExploreLineupView:setPartnerListUI()
	local _scrollParams = self:initScrollData()
    self.panel_2.scroll_1:refreshCellView( 1 )
    self.panel_2.scroll_1:styleFill(_scrollParams);
end




function GuildExploreLineupView:initScrollData()

	local createFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_2.panel_1);
        self:cellviewData(baseCell, itemData)
        return baseCell;
    end
    local updateCellFunc = function (itemData,view)
    	self:cellviewData(view, itemData)
	end


    local  _scrollParams = {
        {
            data = self.partnerData,
            createFunc = createFunc,
            updateCellFunc= updateCellFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -84, width = 105, height = 84},
            perFrame = 1,
        }
    }    
    return _scrollParams
end

function GuildExploreLineupView:cellviewData(baseCell, itemData)

	-- dump(itemData,"333333333333")
	local partnerId = itemData.id
	local skin = itemData.skin
	if partnerId == UserModel:avatar()  then
		-- local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
		local avatar = itemData.avatar
		baseCell.UI_1:updataUI(avatar,skin)
	else
		baseCell.UI_1:updataUI(partnerId,skin)
	end
	baseCell.panel_1:setVisible(false)
	baseCell.panel_2:setVisible(false)
	baseCell.panel_3:setVisible(false)
	-- echo("======partnerId======",partnerId)
	local isLineUp = self:getpartnerIsLineUp(partnerId)
	if isLineUp then
		baseCell.panel_1:setVisible(true)
		baseCell.panel_2:setVisible(true)
	end
	local isHas = GuildExploreModel:getpartnerIsHas(partnerId) ---是否可用
	if not isHas then
		baseCell.panel_1:setVisible(true)
		baseCell.panel_3:setVisible(true)
	end


	baseCell:setTouchedFunc(c_func(self.itemSendLineup, self,baseCell,itemData),nil,true);
end

function GuildExploreLineupView:getpartnerIsLineUp(partnerId)
	for k,v in pairs(self.lineupPartnerData) do
		if v.id == partnerId then
			return true
		end
	end
	return false
end

--点击伙伴上阵
function GuildExploreLineupView:itemSendLineup(baseCell,itemData)
	local partnerid = itemData.id
	local isHas = GuildExploreModel:getpartnerIsHas(partnerid) ---是否可用
	if  not isHas then
		WindowControler:showTips(GameConfig.getLanguage("#tid_Explore_des_114"))
		return 
	end

	local isLineUp = self:getpartnerIsLineUp(partnerid)
	if isLineUp then
		-- echo("=======伙伴已派遣=======")
		WindowControler:showTips(GameConfig.getLanguage("#tid_Explore_des_113"))
		return 
	end
	
	local num = self:getFuncData( "positionNum" )
	local count = 0
	for k,v in pairs(self.lineupPartnerData) do
		if v.id ~= nil then
			count = count + 1
		end
	end
	if count >= num then
		-- echo("=======上阵伙伴已到最大=======",num,count)
		WindowControler:showTips(GameConfig.getLanguage("#tid_Explore_des_112"))
		return 
	end
	-- dump(self.lineupPartnerData,"555555555555555555")
	for i=1,#self.lineupPartnerData do
		if self.lineupPartnerData[i] then
			if self.lineupPartnerData[i].id == nil then
				self.lineupPartnerData[i] = nil
			end
		end
	end

	-- table.insert(self.lineupPartnerData,itemData)

	-- local num = 0
	-- if self.allData._type == FuncGuildExplore.lineupType.mining then
	-- 	num = 3
	-- elseif self.allData._type == FuncGuildExplore.lineupType.building then
	-- 	num = 4
	-- end

	for i=1,num do
		if not self.lineupPartnerData then
			self.lineupPartnerData = {}
		end
		if self.lineupPartnerData[i] == nil then
			self.lineupPartnerData[i] = itemData
			break
		end
	end




	self:setLineupPartnerData(table.copy(self.lineupPartnerData))


	--处理伙伴头相的问题
	--TODO
	baseCell.panel_1:setVisible(true)
	baseCell.panel_2:setVisible(true)

end

function GuildExploreLineupView:getFuncData( key )
	local cfgsName = nil
	if self.allData._type == FuncGuildExplore.lineupType.mining then
		cfgsName = "ExploreMine"
	elseif self.allData._type == FuncGuildExplore.lineupType.building then
		cfgsName = "ExploreCity"
	end
	local id = self.allData.tid
	local keyData = FuncGuildExplore.getCfgDatasByKey(cfgsName,id,key)
	return keyData
end


--派遣伙伴数据
function GuildExploreLineupView:sendPantnerData()
	echo("=======派遣伙伴数据=======")
	local count = 0
	for k,v in pairs(self.lineupPartnerData) do
		if v.id ~= nil then
			count = count + 1
		end
	end

	if self.allData._type == FuncGuildExplore.lineupType.mining then
		local num = self:getFuncData( "positionNum" )
		

		if count < num then
			echo("=======派遣伙伴人数不足=======")
			WindowControler:showTips(GameConfig.getLanguage("#tid_Explore_des_110"))
			return 
		end
	elseif self.allData._type == FuncGuildExplore.lineupType.building then
		if count <= 0 then
			echo("=======未选中派遣伙伴=======")
			WindowControler:showTips("未选中派遣伙伴")--GameConfig.getLanguage("#tid_Explore_des_110"))
			return 
		end	
	end

	self:sendServerBack()

end

--发送数据到服务器
function GuildExploreLineupView:sendServerBack()

	local newpartnerIdList = {}
	for k,v in pairs(self.lineupPartnerData) do
		table.insert(newpartnerIdList,v.id)
	end

	local function callBack(event)
		if event.result then
			-- dump(event.result,"派遣成功返回数据========")
			if event.result.data.result == 0 then
				WindowControler:showTips("派遣成功")--GameConfig.getLanguage("#tid_Explore_des_110"))
				local finishTime  = event.result.data.finishTime
				for k,v in pairs(newpartnerIdList) do
					local partnerData = GuildExploreModel:getPartnersById(v)
					local eventModel = {}
					if partnerData then
						eventModel = {
							hpPercent = partnerData.hpPercent or 0,
							dispatch = self.allData.id,
							ability = partnerData.ability or 100,
							id = partnerData.id,
						}
					else
						eventModel = {
							hpPercent = 100,
							dispatch = self.allData.id,
							ability = UserModel:getcharSumAbility(),
							id = v,
						}

					end
					GuildExploreModel:setUnitInfoDataByPartnerId(v,eventModel)
				end
				local serveTime = TimeControler:getServerTime()
				if self.allData.callBack then
					local data = {
					    cTime    = serveTime,
					    position = self.allData.index,
					    rid      = UserModel:rid(),
					    name = UserModel:name(),
					    group = self.allData.group,
					    finishTime = finishTime,
					}
					self.allData.callBack(data)
				end
				-- EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPOREEVENT_SEND_PANTNER_UI)
			end
			
		else
			-- local error_code = event.error.code 
			-- local tip = GameConfig.getErrorLanguage("#error"..error_code)
			-- WindowControler:showTips(tip)
			if self.allData._type == FuncGuildExplore.lineupType.mining then
				--矿脉
				EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPLORE_MINE_SERVE_ERROR_REFRESHUI,FuncGuildExplore.lineupType.mining)
			elseif self.allData._type == FuncGuildExplore.lineupType.building then
				-- 建筑
				EventControler:dispatchEvent(GuildExploreEvent.GUILDEXPLORE_CITY_SERVE_ERROR_REFRESHUI,FuncGuildExplore.lineupType.building)
			end

		end
		self:clickButtonBack()
	end

	local pames = {
		eventId = self.allData.id,
		index = self.allData.index,
		partnerIdList = newpartnerIdList,
		group = self.allData.group,
	} 

	-- dump(self.allData,"派遣伙伴数据参数=====")

	if self.allData._type == FuncGuildExplore.lineupType.mining then
		--矿脉
		GuildExploreServer:occupationMineServer(pames,callBack)
	elseif self.allData._type == FuncGuildExplore.lineupType.building then
		-- 建筑
		GuildExploreServer:occupationCityServer(pames,callBack)
	end

	

end

--一键上阵伙伴数据
function GuildExploreLineupView:sendAllPantnerData()
	echo("=======一键上阵伙伴数据=======")
	local partnerNum = table.length(self.partnerData)
	local count = table.length(self.lineupPartnerData)
	if partnerNum == 0 then
		WindowControler:showTips(GameConfig.getLanguage("#tid_Explore_des_110"))
		return 
	end

	local num = self:getFuncData( "positionNum" )
	-- echoError("====派遣人数===num========",num,count)
	if self.allData._type == FuncGuildExplore.lineupType.mining then
		if count >= num then
			WindowControler:showTips(GameConfig.getLanguage("#tid_Explore_des_111"))
			return 
		end
	end

	if count == 0 then
		for i=1,num do
			local data = self.partnerData[i]
			if data ~= nil then
				local isHas = GuildExploreModel:getpartnerIsHas(data.id) ---是否可用
				if isHas then
					self.lineupPartnerData[i] = data
					-- table.insert(self.lineupPartnerData,data)
				end
			end
		end
	else
		for i=1,num do
			if self.lineupPartnerData[i] == nil then
				local partnerData = nil
				for index = 1,#self.partnerData do
					local data = self.partnerData[index]
					local ishave = false
					for k,v in pairs(self.lineupPartnerData) do
						if v.id == data.id then
							ishave = true
						end
					end
					if not ishave then
						partnerData = data
						break
					end
				end
				if partnerData then
					local isHas = GuildExploreModel:getpartnerIsHas(partnerData.id) ---是否可用
					if isHas then
						self.lineupPartnerData[i] = partnerData
						-- table.insert(self.lineupPartnerData,partnerData)
					end
				end
			end
		end
	end
	-- dump(self.lineupPartnerData,"44444444444444")

	if self.lineupPartnerData  and  #self.lineupPartnerData ~= 0 then
		self:setLineupPartnerData(self.lineupPartnerData)
		self:partnerSort()
		self:setPartnerListUI()
	else
		WindowControler:showTips("未有奇侠可派遣")--GameConfig.getLanguage("#tid_Explore_des_110"))
	end
end


function GuildExploreLineupView:partnerButtonOne()
	if self._sortType then
		self._sortType = false
	else
		self._sortType = true
	end
	self:partnerSort()
	self:setPartnerListUI()
end

function GuildExploreLineupView:partnerButtonTwo()
	WindowControler:showWindow("PartnerDisplayView")
end


function GuildExploreLineupView:clickButtonBack()
	self:startHide()
end


return GuildExploreLineupView;
