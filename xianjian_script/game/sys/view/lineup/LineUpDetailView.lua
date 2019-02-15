--[[
	Author: lichaoye
	Date: 2017-04-13
	查看阵容-查看详情
]]
local LineUpDetailView = class("LineUpDetailView", UIBase)

function LineUpDetailView:ctor( winName )
	LineUpDetailView.super.ctor(self, winName)
end

function LineUpDetailView:registerEvent()
	LineUpDetailView.super.registerEvent(self)
    self.panel_back.btn_back:setTap(c_func(self.press_btn_close, self))
end

function LineUpDetailView:loadUIComplete()
	self:initVar()
	self:registerEvent()
	self:setViewAlign()
	self:updateUI()
end

-- 适配
function LineUpDetailView:setViewAlign()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_back, UIAlignTypes.RightTop)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.scale9_ding, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_gfj, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_name, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_power, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_level, UIAlignTypes.LeftTop)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zhan, UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.MiddleBottom)

    -- mc_1里的
    local currentView = self.mc_1.currentView
    FuncCommUI.setViewAlign(self.widthScreenOffset,currentView.panel_des, UIAlignTypes.MiddleBottom)
end

function LineUpDetailView:updateUI()
	self:updateDetails()
	self:updateScroll()
end

function LineUpDetailView:updateDetails(itemData)
	local itemData = itemData or LineUpModel:getDetailList()[self._curIdx]
	
	if self._curIdx == 1 then -- 主角
		self.panel_title.mc_1:showFrame(1)
		local qualityData = FuncChar.getCharQualityDataById(itemData.quality)
		self.mc_1:showFrame(1)
		local currentView = self.mc_1.currentView
		-- 仙盟
		local guildName = itemData.guildName
		if not guildName or guildName == "" then
			guildName = GameConfig.getLanguage("chat_own_no_league_1013")
		end
		currentView.panel_des.txt_1:setString(guildName)
		-- 签名
		local sign = itemData.sign

		if not sign or sign == "" then
			sign = GameConfig.getLanguage("tid_friend_sign_max_word_1037")
		end

		currentView.panel_des.txt_3:setString(sign)
		-- 名字
		local name = itemData.name
		
		if name == "" then
			name = GameConfig.getLanguage("tid_common_2001")
		end
		
		-- self.mc_1.currentView.panel_name.txt_1:setString(name)
		self.panel_name.txt_1:setString(name)
		-- +stepName
		local stepName = ""
		if qualityData.stepName and qualityData.stepName ~= "" then
			stepName = "+" .. qualityData.stepName
		end
		self.panel_name.txt_2:setString(stepName)

		local offsetX = FuncCommUI.getStringWidth(name, 28) + 5
		self.panel_name.txt_2:pos(self.panel_name.txt_1:getPositionX() + offsetX, self.panel_name.txt_1:getPositionY()+ 2)
		
		-- 战力
		self.panel_power.UI_number:setPower(itemData.power)
		-- 主角类型
		self.panel_gfj.mc_gfj:showFrame(1)
		-- 法宝
		local treasureData = LineUpModel:getTreasure()
		-- self.mc_1.currentView.UI_fb.mc_1:showFrame(2)
		local treasurePanel = currentView.panel_Fb
		-- self.mc_1.currentView.UI_fb.mc_1.currentView.btn_1:getUpPanel().panel_1
		-- icon
		local _sp = display.newSprite(FuncRes.iconTreasure(treasureData.id)):size(80,70)
		treasurePanel.ctn_1:removeAllChildren()
		treasurePanel.ctn_1:addChild(_sp)
		-- 品质
		-- treasurePanel.mc_1:showFrame(TreasuresModel:getTreasureQualityById(treasureData.id))
		-- 名字
		-- treasurePanel.mc_zi:showFrame(TreasuresModel:getTreasureQualityById(treasureData.id))
		-- currentView.txt_name:setString(GameConfig.getLanguage(TreasuresModel:getTreasureName(treasureData.id)))
		-- 等级（隐藏）
		-- treasurePanel.txt_goodsshuliang:visible(false)
		-- treasurePanel.txt_goodsshuliang:setString(treasureData.level)
		-- 星级
		treasurePanel.mc_star:showFrame(treasureData.star)
	else -- 伙伴
		self.panel_title.mc_1:showFrame(2)
		-- 伙伴的表格
	    local _partnerInfo = FuncPartner.getPartnerById(itemData.id)
		self.mc_1:showFrame(2)
		local currentView = self.mc_1.currentView
		-- 伙伴类型
		self.panel_gfj.mc_gfj:showFrame(tonumber(_partnerInfo.type) + 1)
		local _power = PartnerModel:getPartnerAbility(itemData.id)
		self.panel_power.UI_number:setPower(_power)
		-- 装备
		self:updateEquipment(currentView, itemData.equips, _partnerInfo.equipment)
		-- 技能
		self:updateSkill(currentView, itemData)
		-- 名字
		-- self.mc_1.currentView.panel_name.txt_1:setString(GameConfig.getLanguage(_partnerInfo.name) .. "+" .. itemData.quality)
		self.panel_name.txt_1:setString(GameConfig.getLanguage(_partnerInfo.name))
		self.panel_name.txt_2:setString("+" .. itemData.quality)

		local offsetX = FuncCommUI.getStringWidth(GameConfig.getLanguage(_partnerInfo.name), 28) + 5
		self.panel_name.txt_2:pos(self.panel_name.txt_1:getPositionX() + offsetX, self.panel_name.txt_1:getPositionY()+ 2)
	end

	-- 公用部分
	-- 台子
	local platform = self.mc_1.currentView.panel_zhu
	-- 人物
	local _ctn = platform.ctn_1
	_ctn:removeAllChildren()
	local _sprite = FuncLineUp.initNpc(itemData)
	_sprite:setScale(1.7)
	_ctn:addChild(_sprite)
	-- 星级（不知道有没有0星，但是出现了，先在这里做个容错吧）
	if tonumber(itemData.star) == 0 then
		platform.mc_dou:visible(false)
	else
		platform.mc_dou:visible(true)
		platform.mc_dou:showFrame(itemData.star)
	end
	-- 等级
	-- platform.txt_1:setString("lv." .. itemData.level)
	self.txt_level:setString(itemData.level .. GameConfig.getLanguage("tid_common_2049")) 
	-- 站位信息
	self:updateFormation(self.panel_zhan, LineUpModel:getPosInFormationById(itemData.id))
end

-- 技能
function LineUpDetailView:updateSkill( view, itemData )
	local showList = LineUpModel:getSkillInOrder(itemData)

	for i=1,3 do
		local currentView = view["panel_fb" .. i]
		local nowData = showList[i]
		local _skillInfo = nowData.skillInfo
		-- 技能图标
		local _ctn = currentView.ctn_1
		_ctn:removeAllChildren()
		local _iconPath = FuncRes.iconSkill(_skillInfo.icon)
		local _iconSp = display.newSprite(_iconPath):addTo(_ctn)
		-- 技能名
		currentView.txt_2:setString(GameConfig.getLanguage(_skillInfo.name))

		if nowData.level > 0 then -- 已开启
			currentView.txt_1:setString(nowData.level)
			currentView.panel_suo:visible(false)
			-- currentView:setTouchedFunc(c_func(self.onSkillTouch, self, currentView, nowData))
			FuncCommUI.regesitShowSkillTipView(currentView, {partnerId = nowData.partnerId, id = nowData.id, level = nowData.level or 1,isUnlock = true,_index = nowData._index,isHIdeXL = true}, false)
		else -- 置灰（和伙伴界面一致，那么等级就先显示一级吧）
			currentView.txt_1:setString("1")
			currentView.panel_suo:visible(true)
			currentView:setTouchEnabled(false)
		end
	end
end
-- 技能点击
function LineUpDetailView:onSkillTouch( view, skillData )
	-- -- 获取组件位置
	-- local _worldPoint = view:convertToWorldSpace(cc.p(0, 0))
	-- local fixpos = cc.p(_worldPoint.x - 150, _worldPoint.y + 50)
	-- WindowControler:showWindow("PartnerSkillDetailView",{id = skillData.id, level = skillData.level},fixpos)
	FuncCommUI.regesitShowSkillTipView(view, {id = skillData.id, level = skillData.level or 1,isUnlock = (skillData.level > 0),_index = skillData._index}, false)
end

-- 更新阵容信息
function LineUpDetailView:updateFormation(view, pos)
	if not LineUpModel:isFunc() then -- 非功能入口不显示站位
		view:visible(false)
	else
		for i=1,6 do
			view["mc_" .. i]:showFrame(three(i == pos, 2, 1))
		end
	end 
end

function LineUpDetailView:updateEquipment( view, _playerEquip, _equipData )
	for i,v in ipairs(_equipData) do
		 view["UI_" .. i].mc_1:showFrame(1)
		local currentView = view["UI_" .. i].mc_1.currentView
		local equipPanel = currentView.btn_1:getUpPanel().panel_1
		local equipData = FuncPartner.getEquipmentById(v)
		local equipLvl = _playerEquip[v].level
		equipData = equipData[tostring(equipLvl)]

		-- 装备
		local _ctn = equipPanel.ctn_1
		_ctn:removeAllChildren()
		local _spriteRes = FuncRes.iconPartnerEquipment(FuncPartner.getEquipmentIcon(v, i))
		local _sprite = display.newSprite(_spriteRes):addTo(_ctn)
		-- 红点
		equipPanel.panel_red:visible(false)
		-- 装备等级
		equipPanel.txt_goodsshuliang:setString(equipData.showLv[1].key)
		-- 装备品质
		equipPanel.mc_kuang:showFrame(equipData.quality)
		-- 装备名
		equipPanel.mc_zi:showFrame(equipData.quality)
		equipPanel.mc_zi.currentView.txt_1:setString(GameConfig.getLanguage(equipData.name))
		
		-- equipPanel:setTouchedFunc(c_func(self.onEquipTouch, self, currentView, _playerEquip[v]))
		FuncCommUI.regesitShowEquipTipView(currentView, _playerEquip[v])
	end
end
-- 装备点击
function LineUpDetailView:onEquipTouch( view, equipData )
	-- 获取组件位置
    local _worldPoint = view:convertToWorldSpaceAR(cc.p(0,0))
    local scene = WindowControler:getCurrScene()
    local _nodePoint = scene._root:convertToNodeSpaceAR(_worldPoint)

    local fixpos = cc.p(_nodePoint.x - 50, _nodePoint.y + 100)

    WindowControler:showWindow("LineUpEquipTipsView",equipData, fixpos)
    -- FuncCommUI.regesitShowEquipTipView(view, equipData)
end

function LineUpDetailView:updateItem(view, itemData, idx )
	local panel = view
	panel._idx = idx

	panel.txt_3:setString(itemData.level)

	-- 选中框
	panel.panel_1:visible(idx == self._curIdx)
	-- 红点
	panel.panel_red:visible(false)

    local _iconPath = nil
    if itemData.isChar then
    	-- 品质
    	local qualityData = FuncChar.getCharQualityDataById(itemData.quality)
    	-- 边框颜色
    	local border = qualityData.border
    	panel.mc_2:showFrame(tonumber(border)) 
    	_iconPath = itemData.icon
    else
    	-- 品质
    	local _frame = FuncPartner.getPartnerQuality(tostring(itemData.id))[tostring(itemData.quality)].color
    	panel.mc_2:showFrame(_frame) 
    	-- 伙伴的表格
    	local _partnerInfo = FuncPartner.getPartnerById(itemData.id)
    	_iconPath = _partnerInfo.icon
    end
    -- 伙伴的Icon
    local _ctn = panel.mc_2.currentView.ctn_1
    local _spriteIcon = display.newSprite(FuncRes.iconHero(_iconPath))
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:pos(-1,0)
    headMaskSprite:setScale(0.99)

    -- 通过遮罩实现头像裁剪
    _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,_spriteIcon)
    _ctn:removeAllChildren()
    _ctn:addChild(_spriteIcon)
    _spriteIcon:scale(1.2)

    -- 星级（不知道有没有0星，但是出现了，先在这里做个容错吧）
    if tonumber(itemData.star) == 0 then
    	panel.mc_dou:visible(false)
    else
    	panel.mc_dou:visible(true)
    	panel.mc_dou:showFrame(itemData.star)
    end
    -- -- 注册按钮回调事件
    panel:setTouchedFunc(c_func(self.onCellTouchCallFunc, self, itemData, idx) )
    panel:setTouchSwallowEnabled(true)
end

function LineUpDetailView:updateScroll()
	local partners = LineUpModel:getDetailList()
	local pNums = #partners
	self.panel_1.mc_1:showFrame(pNums)
	local currentView = self.panel_1.mc_1.currentView
	currentView.__pNums = pNums

	for i=1,pNums do
		local itemData = partners[i]
		local idx = i
		local view = currentView["panel_ren" .. i]
		self:updateItem(view, itemData, idx)
	end
end

-- 初始化变量
function LineUpDetailView:initVar()
	self._curIdx = 1 -- 右侧选中的人物
end

function LineUpDetailView:press_btn_close()
	self:startHide()
end

function LineUpDetailView:onCellTouchCallFunc( itemData, idx)
	if self._curIdx == idx and not isinit then return end

	self._curIdx = idx

	local currentView = self.panel_1.mc_1.currentView

	for i=1,currentView.__pNums do
		local view = currentView["panel_ren" .. i]
		view.panel_1:visible(view._idx == self._curIdx)
	end

	-- 刷新左侧
	self:updateDetails(itemData)
end

return LineUpDetailView