-- Author: Wk
-- Date: 2017-07-22
-- 组合神器系统进阶界面

local ArtifactCombinationView = class("ArtifactCombinationView", UIBase);

function ArtifactCombinationView:ctor(winName,cimeliaCombineId)
    ArtifactCombinationView.super.ctor(self, winName);
    --宝物Id
    self.cimeliaCombineId = cimeliaCombineId or 1001
end

function ArtifactCombinationView:loadUIComplete()

	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
 -- 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_ziyuan, UIAlignTypes.RightTop)
 --   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)

 	self.x1 = self["UI_5"]:getPositionX()
	self.x2 = self["txt_goodsshuliang1"]:getPositionX()
 	self:registClickClose("out")
   	self.panel_di.btn_close:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);
	self:registerEvent()
	self:initData()
	self:AdvancedButtonRedShow()

	-- self.UI_1.btn_1:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);
	-- self.UI_1.txt_1:setString("组合进阶")


end 
function ArtifactCombinationView:AdvancedButtonRedShow() 
	local isshow,_type,itemname = ArtifactModel:ByCCIDgetAdvanced(self.cimeliaCombineId)
	self.mc_1:getViewByFrame(1).btn_1:getUpPanel().panel_red:setVisible(isshow)
	if isshow == false then
		if _type == 1 then
			self.txt_name2:setVisible(not isshow)
		else
			self.txt_name2:setVisible(false)
		end
	else
		self.txt_name2:setVisible(not isshow)
	end
end

function ArtifactCombinationView:registerEvent()
	EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.initData, self)
end

function ArtifactCombinationView:initData()
	local ccId = self.cimeliaCombineId  --组合技能ID
	local info = FuncArtifact.byIdgetCCInfo(ccId)
	local anim = info.combineicon --组合动画
	
	FuncArtifact.addChildMiddle(self.ctn_1,ccId)

	self:RightView()
	self:LeftViewData()
end
--右侧进阶道具展示
function ArtifactCombinationView:RightView()
	local ccId = self.cimeliaCombineId  --组合技能ID
	local newquality =  ArtifactModel:getCimeliaCombinequality(ccId)
	local info = FuncArtifact.byIdgetCCInfo(ccId)
	local name = GameConfig.getLanguage(info.combineName)
	local colorframe = info.combineColor
	-- self.panel_c:setVisible(false)	
	self.mc_name:showFrame(colorframe)
	local quality = newquality
	if quality>= FuncArtifact.Fullorder then 
		self.UI_5:setVisible(false)
		self.UI_6:setVisible(false)
		self.txt_goodsshuliang1:setVisible(false)
		self.txt_goodsshuliang2:setVisible(false)
	end
	for i=1,2 do
		self["UI_"..(i+4)]:setVisible(false)
		self["txt_goodsshuliang"..i]:setVisible(false)
	end

	if quality ~= 0 then
		name = name.."+"..quality
		-- self.panel_c:setVisible(true)
		-- self.panel_c.txt_1:setString("+"..quality)
		-- self.panel_c.mc_kuang:showFrame(colorframe)
		if quality >= FuncArtifact.Fullorder then
			quality = quality - 1
		end
	end
	self.mc_name:getViewByFrame(colorframe).txt_1:setString(name)
	local ccInfo = FuncArtifact.byIdgetcombineUpInfo(ccId)
	-- 进阶条件描述
	local conditionDes = GameConfig.getLanguage(ccInfo[tostring(quality+1)].conditionDes)
	self.txt_name2:setString(conditionDes)
	if newquality < FuncArtifact.Fullorder then  --满阶
		-- dump(ccInfo,"1111111111111111111")
		self.mc_1:showFrame(1)    --setVisible(true)
		if ccInfo[tostring(quality+1)] ~= nil then
			local cost = ccInfo[tostring(quality+1)].cost
			-- dump(cost,"222222222222222")
			for i=1,#cost do
				local itemTOfF = true  ---道具是否足够
				local costtable = string.split(cost[i], ",");
				local types =  costtable[1]
				local itemid = tonumber(costtable[2])
				local neednumbers = tonumber(costtable[3])---消耗数量
				if types == FuncDataResource.RES_TYPE.ITEM then
					local iteminfo = FuncItem.getItemData(itemid)  --道具详情
					local havenumber = ItemsModel:getItemNumById(itemid)
					if havenumber >= neednumbers then

					else
						itemTOfF = false

					end
					local numbers = havenumber.."/"..neednumbers
					local itemdata = types..","..itemid..",".."0"
					self["UI_"..(i+4)]:setVisible(true)
					self["UI_"..(i+4)]:setResItemData({reward = itemdata})
					self["UI_"..(i+4)]:showResItemName(true)
				    self["UI_"..(i+4)]:showResItemNum(false)
				    self["txt_goodsshuliang"..i]:setVisible(true)
				    self["txt_goodsshuliang"..i]:setString(numbers)
				    self["UI_"..(i+4)]:showResItemNameWithQuality()
				    -- self["UI_"..i].panelInfo.txt_goodsshuliang:setString(numbers)
				    self["UI_"..(i+4)]:setTouchedFunc(c_func(self.getItemPath, self,itemid))
				    local names = FuncItem.getItemName(itemid)
					self["UI_"..(i+4)].panelInfo.mc_zi.currentView.txt_1:setString(names)
				end
				-- if itemTOfF then
				-- 	self.btn_1:getUpPanel().panel_red:setVisible(true)
				-- else
				-- 	self.btn_1:getUpPanel().panel_red:setVisible(false)
				-- end
			end

			if #cost == 1 then
				self["UI_5"]:setPositionX(self.x1 + 63)
				self["txt_goodsshuliang1"]:setPositionX(self.x2 + 63)
			else
				self["UI_5"]:setPositionX(self.x1)
				self["txt_goodsshuliang1"]:setPositionX(self.x2)
			end
			if quality ~= 0 then
				self.mc_1:getViewByFrame(1).btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_shenqi_003"))
			else
				self.mc_1:getViewByFrame(1).btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_shenqi_004"))
			end
			
		end
	else
		-- self.btn_1:setVisible(false)
		self.mc_1:showFrame(2)
	end
	local button = self.mc_1:getViewByFrame(1).btn_1
	FilterTools.clearFilter(button)
	button:setTouchedFunc(c_func(self.AdvancedButtonCallBack, self,ccId));
	local isok,_type,itemname = ArtifactModel:ByCCIDgetAdvanced(self.cimeliaCombineId)
	if isok == false then
		if _type == FuncArtifact.errorType.NOT_CONDITIONS then
			FilterTools.setGrayFilter(button)
		elseif _type == FuncArtifact.errorType.NOT_ITEM_NUMBER then 
			FilterTools.setGrayFilter(button)
		end
	end
end
function ArtifactCombinationView:getItemPath( itemid )
	WindowControler:showWindow("GetWayListView",itemid)
end
function ArtifactCombinationView:AdvancedButtonCallBack(ccId)
	echo("=============组合进阶按钮===========",ccId)
	local newquality =  ArtifactModel:getCimeliaCombinequality(ccId)
	if newquality >= FuncArtifact.Fullorder then
		WindowControler:showTips(GameConfig.getLanguage("#tid_shenqi_005"))
		return 
	end
	
	local oldpower = ArtifactModel:getSinglePower(ccId)
	ArtifactModel:setoldPower(oldpower)
	-- WindowControler:showWindow("ArtifactCombinSuccess",ccId)
	local isok,_type,itemname,itemid  = ArtifactModel:ByCCIDgetAdvanced(self.cimeliaCombineId)
	if isok == false then
		if _type == FuncArtifact.errorType.NOT_CONDITIONS then
			local ccId = self.cimeliaCombineId  --组合技能ID
			local newquality =  ArtifactModel:getCimeliaCombinequality(ccId)
			local ccInfo = FuncArtifact.byIdgetcombineUpInfo(ccId)
			local conditionDes = GameConfig.getLanguage(ccInfo[tostring(newquality+1)].conditionDes)
			WindowControler:showTips(conditionDes)
		elseif _type == FuncArtifact.errorType.NOT_ITEM_NUMBER then 
			local name = GameConfig.getLanguage(itemname)
			local _str = string.format(GameConfig.getLanguage("#tid_shenqi_017"),name)
			WindowControler:showTips(_str)
			echo("==========itemid========",itemid)
			WindowControler:showWindow("GetWayListView",itemid)
		end
		return 
	end

	local function callBack(_param)
		-- dump(_param.result,"组合进阶结果",10)
		if (_param.result ~= nil) then
			-- local rewards = _param.result.data.dirtyList.rewards
			-- FuncArtifact.playCCArtifactActiveSound()
			self:initData()
			self:AdvancedButtonRedShow()
			WindowControler:showWindow("ArtifactCombinSuccess",ccId)
		else
			if _param.error ~= nil then
				local error_code = _param.error.code 
				local tip = GameConfig.getErrorLanguage("#error"..error_code)
				WindowControler:showTips(tip)
			end
   		end
    end
	local params = {}
	params.groupId = tostring(ccId)
	ArtifactServer:CombinationAdvanced(params, callBack)
end
--左侧组合技能展示
function ArtifactCombinationView:LeftViewData()
	local ccId = self.cimeliaCombineId  --组合技能ID
	local info = FuncArtifact.byIdgetCCInfo(ccId) 
	local quality =  ArtifactModel:getCimeliaCombinequality(ccId)
	local name = GameConfig.getLanguage(info.combineName)
	-- 组合技能名称
	local skillName = GameConfig.getLanguage(info.skillName)
	-- 组合技能图标
	local skillIcon = info.skillIcon
	if skillIcon ~= nil then
		local imagename =	FuncRes.iconSkill(skillIcon)
		local sprites = display.newSprite(imagename)
		self.panel_zuo.panel_1.ctn_1:addChild(sprites)
	else
		echoError("没有技能资源图片，表里没配，找金钊 技能组合ID",ccId)
	end
	self.panel_zuo.panel_1:setTouchedFunc(c_func(self.ShowSkillInfoTip, self,ccId),nil,true);
	-- 组合技能描述
	local combineSkillDes = GameConfig.getLanguage(info.combineSkillDes)
	local colorframe = info.combineColor
	if quality ~= 0 then
		name = name.."+"..quality
		-- skillName = skillName.."+"..quality
	end
	-- self.panel_zuo.mc_name:showFrame(colorframe)
	-- self.panel_zuo.mc_name:getViewByFrame(colorframe).txt_1:setString(name)
	
	self.panel_zuo.panel_1.txt_name:setString("等级"..quality)
	self.panel_zuo.txt_name:setString(skillName)
	local ccdata = FuncArtifact.byIdgetcombineUpInfo(ccId)
	-- self.panel_zuo.txt_lv:setString("等级"..quality)
	local data = ccdata[tostring(quality)]  --growEnergy
	local kind = data.kind
	local _quility = quality
	if kind == 4 then
		for i=1,tonumber(quality) do
			local growEnergy = ccdata[tostring(i)].growEnergy
			if growEnergy ~= nil then
				_quility = i
			end
		end
		if data.growEnergy == nil then
			data = ccdata[tostring(_quility)]
		end
	end

	local _str = FuncPartner.getCommonSkillDesc(data,tonumber(quality),info.combineSkillDes)
	self.panel_zuo.rich_1:setString(_str)

	self:LeftListViewData()
end
--技能属性替换
function ArtifactCombinationView:skillAttrTiHuan(ccId,skilldes)
	local skillsArrtStr = GameConfig.getLanguage(skilldes)
	local quality =  ArtifactModel:getCimeliaCombinequality(ccId)
	if quality == 0 then
		quality = 1
	end
	local ccdata = FuncArtifact.byIdgetcombineUpInfo(ccId)
	local subAttr =  ccdata[tostring(quality)].subAttr
	if subAttr ~= nil then
		for i=1,#subAttr do
			local key = subAttr[i].key
			local attrValue = subAttr[i].value
			local valuer = FuncBattleBase.getFormatFightAttrValue(key,attrValue)
			local _th = "#"..tostring(i)
			skillsArrtStr = string.gsub(skillsArrtStr, _th, tostring(valuer).."%");
		end
		return skillsArrtStr
	else
		return ""
	end
end
--点击技能弹tips
function ArtifactCombinationView:ShowSkillInfoTip(cimeliaid)
	echo("------------点击技能弹tips-------")
	WindowControler:showWindow("ArtifactSkillTipsView",cimeliaid)
	
end
--最左边进阶属性描述
function ArtifactCombinationView:LeftListViewData()
	local ccId = self.cimeliaCombineId  --组合技能ID
	local ccListdata = ArtifactModel:getCCAttrlistTable(ccId)
	-- dump(ccListdata,"111111111111111111111")


	self.panel_zuo.mc_gnlm:setVisible(false)
	self.panel_zuo.panel_gnlm:setVisible(false)
	self.panel_zuo.panel_jh:setVisible(false)
	local createRankItemFunc = function(itemData)
    local baseCell = UIBaseDef:cloneOneView(self.panel_zuo.mc_gnlm);
        self:cellviewData(baseCell, itemData)
        return baseCell;
    end

    local  _scrollParams = {
        {
            data = ccListdata,
            createFunc = createRankItemFunc,
            -- updateFunc= updateFunc,
            perNums = 1,
            offsetX = 10,
            offsetY = 15,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -50, width = 130, height = 50},
            perFrame = 0,
        }
    }    
    -- self.scroll_1:cancleCacheView();
    self.panel_zuo.scroll_2:styleFill(_scrollParams);

	local quality =  ArtifactModel:getCimeliaCombinequality(ccId)

    self.panel_zuo.panel_gnlm:setVisible(true)
    self.panel_zuo.panel_gnlm.txt_1:setString("")
	for k,v in pairs(ccListdata) do
		if v.quality == quality+1 then
			local des = GameConfig.getLanguage(v.skillUpDes)
			self.panel_zuo.panel_gnlm.txt_1:setString(des)
		end
	end

end
function ArtifactCombinationView:cellviewData(baseCell, itemData)
	-- skillUpDes
	-- ccid
	echo("---- 123456789 ---")
	dump(itemData)
	local quality = ArtifactModel:getCimeliaCombinequality(itemData.ccid)
	local des = GameConfig.getLanguage(itemData.skillUpDes)
	local namestr =  "等级"..itemData.quality
	local _str = des--attrname.."+"..valuer.."("..des..")"
	local Frame = 1
	local color = "<color=8C9695>"
	if quality >= itemData.quality then 
		-- Frame = 1
		-- baseCell:showFrame(Frame)
		color = "<color=008c0d>"
	elseif itemData.quality == (quality + 1) then  --下一个阶级显示黄色
		-- Frame  = 2
		-- baseCell:showFrame(Frame)
		color = "<color=89674B>"
	end
	-- baseCell:getViewByFrame(Frame).rich_12:setString(namestr)
	baseCell:getViewByFrame(Frame).rich_1:setString(color..namestr.." ".._str.."<->")


end

function ArtifactCombinationView:clickButtonBack()
	ArtifactModel:sendHomeviewRed()
	self:startHide()
end


return ArtifactCombinationView;

