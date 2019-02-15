--[[
	Author: lxh
	Date:2018-05-02
	Description: 排行榜中神器排行单一神器详情查看界面
]]

local RankListArtifactDetailView = class("RankListArtifactDetailView", UIBase);

function RankListArtifactDetailView:ctor(winName, _itemData)
    RankListArtifactDetailView.super.ctor(self, winName)
    self.artifactData = _itemData
end

function RankListArtifactDetailView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	-- self:updateUI()
end 

function RankListArtifactDetailView:registerEvent()
	RankListArtifactDetailView.super.registerEvent(self);

	self.panel_bg.btn_close:setTouchedFunc(c_func(self.startHide, self))
	self:registClickClose("out")
end

function RankListArtifactDetailView:initData()
	self.artifactId = self.artifactData.combineId
	self.quality = 0
	if self.artifactData.qualityData then
	 	self.quality = self.artifactData.qualityData.quality
	end 
	self.artifactAllData = FuncArtifact.byIdgetCCInfo(self.artifactId)--组合神器数据
	self.skillData =  FuncArtifact.byIdgetcombineUpInfo(self.artifactId)--组合神器进阶数据
	self.skillTable = nil
	if self.quality == 0 then  ---未获取的时候
		self.skillTable = self.skillData[tostring(1)]
	else
		self.skillTable = self.skillData[tostring(self.quality)]
	end

	local kind = self.skillTable.kind
	local _quility = self.quality
	if kind == 4 and self.quality > 0 then
		for i = 1, tonumber(self.quality) do
			local growEnergy = self.skillData[tostring(i)].growEnergy
			if growEnergy ~= nil then
				_quility = i
			end
		end
		if self.skillData.growEnergy == nil then
			self.skillTable = self.skillData[tostring(_quility)]
		end
	end

	self.attrList =  ArtifactModel:getSingleInitAttrByData(self.artifactData.qualityData)
	self.ccListdata = ArtifactModel:getCCAttrlistTable(self.artifactId)

end

function RankListArtifactDetailView:getOffsetYForFirstGroup()
	self.skillLevel = self.quality
	if tonumber(self.quality) == 0 then
		self.skillLevel = 1
	end
    self.des = FuncArtifact.byIdgetCCInfo(self.artifactId).combineSkillDes
	self.skillsArrtStr = FuncPartner.getCommonSkillDesc(self.skillTable, tonumber(self.skillLevel), self.des)
	local _, offsetY = self.panel_1.rich_12:setStringByAutoSize(self.skillsArrtStr, 0)
	if offsetY > 70 then
		offsetY = offsetY - 70
	else
		offsetY = 0
	end
	return offsetY
end

function RankListArtifactDetailView:getOffsetYForSecondGroup()
	local offsetY = 0
	if #self.attrList > 0 then
	 	offsetY = math.floor((#self.attrList - 1) / 2) * 40
	end
	return offsetY
end

function RankListArtifactDetailView:getOffsetYForThirdGroup()
	local offsetY = 0
	for i,v in ipairs(self.ccListdata) do
		local panel_des = self.panel_3.panel_1
		local des = GameConfig.getLanguage(v.skillUpDes)
		local _str = des
		local color = "<color=8C9695>"
		if self.quality >= v.quality then 
			color = "<color=008c0d>"
		elseif v.quality == (self.quality + 1) then  --下一个阶级显示黄色
			color = "<color=89674B>"
		end
		local _, height = panel_des.rich_2:setStringByAutoSize(color.._str.."<->", 0)

		offsetY = offsetY + height + 10
	end
	return offsetY
end

function RankListArtifactDetailView:initView()
	self.panel_1:setVisible(false)
	self.panel_2:setVisible(false)
	self.panel_3:setVisible(false)

	local offsetY1 = self:getOffsetYForFirstGroup()
	local offsetY2 = self:getOffsetYForSecondGroup()
	local offsetY3 = self:getOffsetYForThirdGroup()
	local createFunc1 = function (itemData)
		local view = UIBaseDef:cloneOneView(self.panel_1)
		self:updateNameAndIcon(view, itemData)
		return view 
	end

	local createFunc2 = function (itemData)
		local view = UIBaseDef:cloneOneView(self.panel_2)
		self:updateAttrView(view, itemData)
		return view 
	end

	local createFunc3 = function (itemData)
		local view = UIBaseDef:cloneOneView(self.panel_3)
		self:updateEffectDes(view, itemData)
		return view 
	end

	local params = {
		{	
			data = {1},
			createFunc = createFunc1,
			offsetX = 20,
			offsetY = 40,
			widthGap = 0,
			heightGap = 0,
			perFrame = 1,
			perNums = 1,
			itemRect = {x = 0, y = -(160 + offsetY1), width = 350, height = 160 + offsetY1},

		},
		{
			data = {2},
			createFunc = createFunc2,
			offsetX = 40,
			offsetY = -40,
			widthGap = 0,
			heightGap = 0,
			perFrame = 1,
			perNums = 1,
			itemRect = {x = 0, y = -(90 + offsetY2), width = 350, height = 90 + offsetY2},
		},
		{
			data = {3},
			createFunc = createFunc3,
			offsetX = 20,
			offsetY = 0,
			widthGap = 0,
			heightGap = 0,
			perFrame = 1,
			perNums = 1,
			itemRect = {x = 0, y = -(60 + offsetY3), width = 350, height = 60 + offsetY3},
		},
	}

	self.scroll_1:styleFill(params)
	self.scroll_1:hideDragBar()
end

function RankListArtifactDetailView:initViewAlign()
	-- TODO
end

function RankListArtifactDetailView:updateNameAndIcon(_view, itemData)
	local artifactName = GameConfig.getLanguage(self.artifactAllData.combineName)  --组合名称
	local skillName = GameConfig.getLanguage(self.artifactAllData.skillName)  --组合技能名称
	local skillIcon = self.artifactAllData.skillIcon  --组合技能图标
	local skillDes = self.artifactAllData.combineSkillDes  --组合技能描述
	if self.quality ~= 0 then
		artifactName = artifactName.."+"..self.quality
	end
	local colorFrame = self.artifactAllData.combineColor
	_view.mc_name:showFrame(colorFrame)
	_view.mc_name.currentView.txt_1:setString(artifactName)

	_view.txt_name:setString(skillName)
	_view.panel_1.txt_1:setString("等级"..self.quality)
	_view.panel_1.ctn_1:removeAllChildren()
	if skillIcon ~= nil then
		local sprites = display.newSprite(FuncRes.iconSkill(skillIcon))
		_view.panel_1.ctn_1:addChild(sprites)
		if self.quality == 0 then
			FilterTools.setGrayFilter(sprites)
		else
			FilterTools.clearFilter(sprites)
		end
	else
		echoError("没有技能资源图片，表里没配，找金钊 技能组合所在ID",self.artifactId)
	end
	-- _view.panel_1:setTouchedFunc(c_func(self.ShowSkillInfoTip, self, self.artifactId), nil, true);
	_view.rich_12:setString(self.skillsArrtStr)
end

function RankListArtifactDetailView:updateAttrView(_view, itemData)
	_view.panel_1:setVisible(false)
	if #self.attrList == 0 then
		local panel_attr = UIBaseDef:cloneOneView(_view.panel_1)
		panel_attr.mc_1:setVisible(false)
		panel_attr.txt_1:setString("")
		panel_attr.txt_2:setString(GameConfig.getLanguage("#tid_ranklist_003"))
		panel_attr:addto(_view)
		panel_attr:pos(-20, -40)
	else
		for i,v in ipairs(self.attrList) do
			local panel_attr = UIBaseDef:cloneOneView(_view.panel_1)
			local des = ArtifactModel:getDesStaheTable(v, false)
			panel_attr.txt_1:setString(des)
			local str = v.value
		    if v.mode == 2 or v.mode == 3 then   ---百分比
			    local desvalue = v.value / 100
			    str = "  "..desvalue.."%"
			end
			panel_attr.txt_2:setString(str)
			panel_attr.mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(v.key)])

			panel_attr:addto(_view)
			local offsetX = math.floor((i - 1) % 2) * 210 - 5
            local offsetY = -math.floor((i - 1) / 2) * 40 - 40
            panel_attr:pos(offsetX, offsetY)
		end
	end
end

function RankListArtifactDetailView:updateEffectDes(_view, itemData)
	_view.panel_1:setVisible(false)
	local offsetX = 15
	local offsetY = 0
	for i,v in ipairs(self.ccListdata) do 
		local panel_des = UIBaseDef:cloneOneView(_view.panel_1)
		panel_des:addto(_view)
		panel_des:pos(offsetX, offsetY - 50)
		local des = GameConfig.getLanguage(v.skillUpDes)
		local namestr =  GameConfig.getLanguage("#tid_ranklist_001")..v.quality
		local _str = des
		local color = "<color=8C9695>"
		if self.quality >= v.quality then 
			color = "<color=008c0d>"
		elseif v.quality == (self.quality + 1) then  --下一个阶级显示黄色
			color = "<color=89674B>"
		end
		panel_des.rich_1:setString(color..namestr.."<->")
		local _, height = panel_des.rich_2:setStringByAutoSize(color.._str.."<->", 0)

		offsetY = -height + offsetY - 10
	end
end

function RankListArtifactDetailView:updateUI()
	
end

--点击技能弹tips
function RankListArtifactDetailView:ShowSkillInfoTip(artifactId)
	WindowControler:showWindow("ArtifactSkillTipsView", artifactId)	
end

function RankListArtifactDetailView:deleteMe()
	-- TODO

	RankListArtifactDetailView.super.deleteMe(self);
end

return RankListArtifactDetailView;
