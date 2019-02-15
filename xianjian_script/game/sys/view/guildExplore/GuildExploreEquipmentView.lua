-- GuildExploreEquipmentView.lua
--[[
	Author: wk
	Date:2018-07-09
	Description: 装备界面
]]



local GuildExploreEquipmentView = class("GuildExploreEquipmentView", UIBase);

function GuildExploreEquipmentView:ctor(winName,_type,data,cellFunc)
    GuildExploreEquipmentView.super.ctor(self, winName)
    self.equipment_tpye = _type
    self.allData = data
    self.cellFunc = cellFunc
end

function GuildExploreEquipmentView:loadUIComplete()
	self.panel_1.txt_1:setVisible(false)
	self.panel_1.rich_1:setVisible(false)
	self.buttonPos = {}
	self:initViewAlign()
	for i=1,3 do
		local x = self["mc_yeqian"..i]:getPositionX()
		local y = self["mc_yeqian"..i]:getPositionY()
		self.buttonPos[i] = {x  = x,y = y}
		self["mc_yeqian"..i]:setTouchedFunc(c_func(self.showEquipmentMc, self,i),nil,true);
	end
	self["mc_yeqian"..self.equipment_tpye]:showFrame(2)

	self:registerEvent()
	
	self:initData()
	self:addBg()
	self:showButton()
end 


--显示位置
function GuildExploreEquipmentView:showButton()
	local openArr = GuildExploreModel:getBuffOpenState()
	local penel = {} 
	for i=1,#openArr do
		self["mc_yeqian"..i]:setVisible(openArr[i])
	end
	local posIndex = 3
	for i=posIndex,1,-1 do
		if openArr[i] then
			self["mc_yeqian"..i]:setPosition(cc.p(self.buttonPos[posIndex].x,self.buttonPos[posIndex].y))
			posIndex = posIndex - 1
		end
		
	end
	
end


function GuildExploreEquipmentView:showEquipmentMc(_type)

    if _type == self.equipment_tpye then
        return
    end
    local data  =  GuildExploreModel:getequipInfoLevelArr(_type)
    self["mc_yeqian"..self.equipment_tpye]:showFrame(1)
    self["mc_yeqian".._type]:showFrame(2)
    self.equipment_tpye = _type
    dump(data,"434444444444444")
    self.allData = data
    self:initData()
    self:addBg()
end


function GuildExploreEquipmentView:addBg()
	local bgName = {
		[1] = "explore_bg_hong2.png",
		[2] = "explore_bg_lan2.png",
		[3] = "explore_bg_lv2.png",
	}

	local bgIcon =  FuncRes.iconBg( bgName[tonumber(self.equipment_tpye)] )
	local ctn_1 = self.panel_1.ctn_1
	local sprite = display.newSprite(bgIcon)
	local box = ctn_1:getContainerBox()
	-- sprite:size(box.width,box.height)
	sprite:anchor(1,0.5)

	ctn_1:addChild(sprite)

	local mc = self.panel_1.mc_1
	mc:showFrame(tonumber(self.equipment_tpye))

end

--关闭装备界面
function GuildExploreEquipmentView:closeEquipmentView()
	if self.cellFunc then
		self.cellFunc()
	end
	self:startHide()
end

function GuildExploreEquipmentView:getFuncData(cfgsName, id,key )
	local cfgsName = cfgsName
	local id = id
	local keyData
	if key then
		keyData = FuncGuildExplore.getCfgDatasByKey(cfgsName,id,key)
	else
		keyData = FuncGuildExplore.getCfgDatas( cfgsName,id )
	end
	return keyData
end

function GuildExploreEquipmentView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_close, UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_1, UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_yeqian1, UIAlignTypes.RightBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_yeqian2, UIAlignTypes.RightBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_yeqian3, UIAlignTypes.RightBottom)
	
end

function GuildExploreEquipmentView:registerEvent()
	GuildExploreEquipmentView.super.registerEvent(self);

	self.btn_close:setTouchedFunc(c_func(self.closeEquipmentView, self,i),nil,true)
	self:registClickClose("out", c_func( function()
        self:closeEquipmentView()
    end , self))

end

function GuildExploreEquipmentView:initData()
	local equipmentData = self:getFuncData("ExploreEquipment", self.equipment_tpye )
	self.attrit = {
		[1] = {GameConfig.getLanguage("#tid_Explore_des_116"),GameConfig.getLanguage("#tid_Explore_des_117"),GameConfig.getLanguage("#tid_Explore_des_118")},
		[2] = {GameConfig.getLanguage("#tid_Explore_des_119"),GameConfig.getLanguage("#tid_Explore_des_120"),GameConfig.getLanguage("#tid_Explore_des_121")},
		[3] = {GameConfig.getLanguage("#tid_Explore_des_122"),GameConfig.getLanguage("#tid_Explore_des_123"),GameConfig.getLanguage("#tid_Explore_des_124")},


	}
	local sumAttr = ""
	for i=1,3 do
		local panel = self.panel_1["panel_"..i]
		self:setView(panel,equipmentData,i)
		-- sumAttr = sumAttr..des.."  "
	end

	self:setButtonRed()
end


function GuildExploreEquipmentView:setButtonRed()
	for i=1,3 do
		local panel_red = self["mc_yeqian"..i]:getViewByFrame(1).panel_red
		if panel_red then
			local isShow = GuildExploreModel:getEquipRed(i)
			-- echo("=====isShow=========",i,isShow)
			panel_red:setVisible(isShow)
		end
	end
end

function GuildExploreEquipmentView:getvaluer1(data,_type)
	-- echo("=====_type=========",_type)
	local valuer = 0
	if self.equipment_tpye  == FuncGuildExplore.equipmentType.shoes then
		if _type  == 1 then
			attribute = data.attributeA2
		elseif _type == 2 then
			attribute = data.attributeB2
		elseif _type == 3 then
			attribute = data.attributeC
		end
	else
		if _type  == 1 then
			attribute = data.attributeA
		elseif _type == 2 then
			attribute = data.attributeB
		elseif _type == 3 then
			attribute = data.attributeC
		end
	end	
	for i=1,#attribute do
		valuer = valuer + attribute[i].value
	end
	valuer = (valuer/100).."%"
	return valuer
end


--设置panel的详细情况
function GuildExploreEquipmentView:setView(view,data,_type)
	local level =  self.allData["level".._type] or 0  ---当前等级，
	local nextLevel = level + 1    				--- 下个等级
	local equipmentData = data[tostring(level)]
	local nextData  =  data[tostring(nextLevel)]
	local spriteA = nil
	local spriteB = nil
	local strDes = ""
	local sumAttr = ""
	local cost = nil
	if _type == 1 then
		if not nextData then
			view.mc_1:showFrame(3)
			cost = nil
			view.txt_2:setVisible(false)
			view.ctn_1:setVisible(false)
			view.ctn_2:setVisible(false)
			view.txt_3:setVisible(false)
		else
			view.txt_2:setVisible(true)
			view.ctn_1:setVisible(true)
			view.ctn_2:setVisible(true)
			view.txt_3:setVisible(true)
			view.mc_1:showFrame(1)
			local panel = view.mc_1:getViewByFrame(1)
			panel.btn_1:setTouchedFunc(c_func(self.ascensionButton, self,nextData,_type),nil,true);
			local isShowRed = GuildExploreModel:getEquipRed(self.equipment_tpye,_type)
			panel.panel_red:setVisible(isShowRed)
			cost =  nextData.costA
		end
		local valuer_1 = 0
		local eqLevel =  level
		local allData  = nextData
		if eqLevel ~= 0   then
			valuer_1 = self:getvaluer1(equipmentData,_type)
		else
			valuer_1 = "0%"
			equipmentData = data[tostring(1)]
		end

		strDes = FuncTranslate._getLanguageWithSwap(equipmentData.desA,level,valuer_1)
		view.rich_1:setString(strDes)
		if allData then
			local valuer_2 = self:getvaluer1(allData,_type)
			strDes_2 = FuncTranslate._getLanguageWithSwap(equipmentData.desA2,valuer_2)
			view.rich_2:setString(strDes_2)
		else
			-- view.rich_2:setVisible(false)
			view.rich_2:setString(FuncTranslate._getLanguageWithSwap("#tid_Explore_res_equipment_001",nextLevel,1))
		end
	else
		local exploreSkillOpen = self:getFuncData("ExploreSetting","ExploreSkillOpen")
		local guildLevel = GuildModel:getGuildLevel()

		if _type == 2 then
			-- cost =  equipmentData.costB
				if not nextData then
					view.mc_1:showFrame(3)
					cost = nil
					view.txt_2:setVisible(false)
					view.ctn_1:setVisible(false)
					view.ctn_2:setVisible(false)
					view.txt_3:setVisible(false)
				else
					view.txt_2:setVisible(true)
					view.ctn_1:setVisible(true)
					view.ctn_2:setVisible(true)
					view.txt_3:setVisible(true)
					view.mc_1:showFrame(1)
					local panel = view.mc_1:getViewByFrame(1)
					panel.btn_1:setTouchedFunc(c_func(self.ascensionButton, self,nextData,_type),nil,true);
					local isShowRed = GuildExploreModel:getEquipRed(self.equipment_tpye,_type)
					panel.panel_red:setVisible(isShowRed)
					cost =  nextData.costB
				end
				local valuer_1 = 0
				local eqLevel =  level
				local allData  = nextData
				-- echo("======eqLevel========",eqLevel,type(eqLevel))
				if eqLevel ~= 0 then
					valuer_1 = self:getvaluer1(equipmentData,_type)
				else
					valuer_1 = "0%"
					equipmentData = data[tostring(1)]
				end
				strDes = FuncTranslate._getLanguageWithSwap(equipmentData.desB,level,valuer_1)
				view.rich_1:setString(strDes)
				if allData then
					local valuer_2 = self:getvaluer1(allData,_type)
					local strDes_2 = FuncTranslate._getLanguageWithSwap(equipmentData.desB2,valuer_2)
					view.rich_2:setString(strDes_2)
				else
					view.rich_2:setString(FuncTranslate._getLanguageWithSwap("#tid_Explore_res_equipment_001",nextLevel,1))
				end

		elseif _type == 3 then
			-- cost =  equipmentData.costC
			if not nextData then
				view.mc_1:showFrame(3)
				cost = nil
				view.txt_2:setVisible(false)
				view.ctn_1:setVisible(false)
				view.ctn_2:setVisible(false)
				view.txt_3:setVisible(false)
			else
				view.txt_2:setVisible(true)
				view.ctn_1:setVisible(true)
				view.ctn_2:setVisible(true)
				view.txt_3:setVisible(true)
				view.mc_1:showFrame(1)
				local panel = view.mc_1:getViewByFrame(1)
				panel.btn_1:setTouchedFunc(c_func(self.ascensionButton, self,nextData,_type),nil,true);
				local isShowRed = GuildExploreModel:getEquipRed(self.equipment_tpye,_type)
				panel.panel_red:setVisible(isShowRed)
				cost =  nextData.costC
			end			
			local valuer_1 = 0
			local eqLevel =  level
			local allData  = nextData
			if eqLevel ~= 0 then
				valuer_1 = self:getvaluer1(equipmentData,_type)
			else
				valuer_1 = "0%"
				equipmentData = data[tostring(1)]
			end
			strDes = FuncTranslate._getLanguageWithSwap(equipmentData.desC,level,valuer_1)
			view.rich_1:setString(strDes)
			if allData then
				local valuer_2 = self:getvaluer1(allData,_type)
				local strDes_2 = FuncTranslate._getLanguageWithSwap(equipmentData.desC2,valuer_2)
				view.rich_2:setString(strDes_2)
			else
				view.rich_2:setString(FuncTranslate._getLanguageWithSwap("#tid_Explore_res_equipment_001",nextLevel,1))
			end
		end

		if guildLevel >= 10 then    ---占时不开启--exploreSkillOpen.num then
			if level >= maxLevel+1 then
				view.mc_1:showFrame(3)
				view.txt_2:setVisible(false)
				view.ctn_1:setVisible(false)
				view.ctn_2:setVisible(false)
				view.txt_3:setVisible(false)
				cost = nil
			else
				view.txt_2:setVisible(true)
				view.ctn_1:setVisible(true)
				view.ctn_2:setVisible(true)
				view.txt_3:setVisible(true)
				view.mc_1:showFrame(1)
				local panel = view.mc_1:getViewByFrame(1)
				panel.btn_1:setTouchedFunc(c_func(self.ascensionButton, self,equipmentData,_type),nil,true);
				GuildExploreModel:getEquipRed(_type)
				local isShowRed = GuildExploreModel:getEquipRed(self.equipment_tpye,_type)
				panel.panel_red:setVisible(isShowRed)
			end
		else
			view.mc_1:showFrame(2)
			local txt_1 = view.mc_1:getViewByFrame(2).txt_1
			txt_1:setString("暂未开启")
		end

	end

	if cost then
		for i=1,#cost do
			local imagePath = nil
			view["ctn_"..i]:removeAllChildren()
			local res = string.split(cost[i], ",")
			local num = 0
			local haveNum = 0
			if res[1] == FuncGuildExplore.guildExploreResType then
				local icon = self:getFuncData("ExploreResource",res[2],"icon")
				imagePath = FuncRes.getIconResByName(icon)
				num = res[3]
				haveNum = GuildExploreModel:getResCount(res[1],res[2])
			else
				local icon = FuncDataResource.getIconPathById( res[1] )
				imagePath = FuncRes.getIconResByName(icon)
				if #res == 2 then
					num = res[2]
				else
					num = res[3]
				end
				needNum,haveNum = UserModel:getResInfo( cost[i] )
			end
			local sprite = display.newSprite(imagePath)
			view["ctn_"..i]:addChild(sprite)
			sprite:size(26,26)
			-- echo("========num=======",_type,i,haevNum,num)
			if i == 1 then
				view.txt_2:setString(num)
				if tonumber(haveNum) >= tonumber(num) then
					view.txt_2:setColor(cc.c3b(99,66, 0))
				else
					view.txt_2:setColor(cc.c3b(255,0, 0))
				end
			elseif i == 2 then
				view.txt_3:setString(num)
				if tonumber(haveNum) >= tonumber(num) then
					view.txt_3:setColor(cc.c3b(99,66, 0))
				else
					view.txt_3:setColor(cc.c3b(255,0, 0))
				end
			end
		end
	end


end

--提升按钮
function GuildExploreEquipmentView:ascensionButton(equipmentDatal,_type)
	-- dump(equipmentDatal,"装备数据 ========")
	local cost = nil
	if _type == 1 then
		cost = equipmentDatal.costA
	elseif _type == 2 then
		cost = equipmentDatal.costB
	elseif _type == 3 then
		cost = equipmentDatal.costC
	end

	local isenough =  GuildExploreModel:getItemCountIsOk( cost )
	if not isenough then
		WindowControler:showTips("材料不足,不能提升")
		return 
	end

	self:sendServerData(_type)

end


--发送到服务器
function GuildExploreEquipmentView:sendServerData(index)
	
	local function callBack(event)
		if event.result then
			-- dump(event.result,"装备提升返回数据 ========")
			
			if event.result.data.result == 0 then
				local reward  = event.result.data.reward
				local equip = event.result.data.equip
				WindowControler:showTips("提升成功")
				GuildExploreModel:setEquipInfoLevel(self.equipment_tpye,index)
				-- self.allData["level"..index] = self.allData["level"..index] + 1
				-- if self.allData["level"..index] >= 20 then
				-- 	self.allData["level"..index] = 20
				-- end

				for k,v in pairs(equip) do
					if self.allData[k] then
						self.allData[k] = v
					end
				end

				---刷新道具--TODO
				for k,v in pairs(reward) do
					GuildExploreModel:setResCount(v)
				end
				self:createBuffEff(self.equipment_tpye,index)
				self:initData()
				self:setButtonRed()
				EventControler:dispatchEvent(GuildExploreEvent.GUILD_EXPLORE_REFESH_RED)
			end
		end
	end

	local params = {
		tid = self.allData.tid,
		index = index,
	}

	GuildExploreServer:ascensionEquipmentData(params,callBack)
end



--创建特效
function GuildExploreEquipmentView:createBuffEff(t,index )
	local aniArr = {
		"UI_xianmengtansuo_a_buff_gongi", "UI_xianmengtansuo_a_buff_fangyu", "UI_xianmengtansuo_a_buff_jiasu"
	}
	local offset = {347-563+35,-99}

	local aniName = aniArr[tonumber(t)]
	
	local aniGuang = aniName.."_"..index

	local ani1 = self[aniName]
	if not ani1 then
		self[aniName] = self:createUIArmature("UI_xianmengtansuo_a", aniName, self.panel_1.mc_1.currentView, false, GameVars.emptyFunc)
		ani1 = self[aniName]
		ani1:pos(offset[1],offset[2])
	end
	ani1:stop()
	ani1:setVisible(false)
	self:stopAllActions()
	local tempFunc = function (  )
		ani1:setVisible(true) 
		ani1:startPlay(false)
	end

	self:delayCall(tempFunc, 0.5)


	local ani2 = self[aniGuang] 	
	if not ani2 then
		self[aniGuang] = self:createUIArmature("UI_xianmengtansuo_a", aniGuang, self.panel_1.mc_1.currentView, false, GameVars.emptyFunc)
		ani2 = self[aniGuang]
		ani2:pos(offset[1],offset[2])
	else
		ani2:setVisible(true)
		ani2:startPlay(false)
	end

end




return GuildExploreEquipmentView;
