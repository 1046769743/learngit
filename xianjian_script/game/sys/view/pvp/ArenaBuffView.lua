--
-- Author:LXH
-- Date: 2018-03-13 09:41:23
--

local ArenaBuffView = class("ArenaBuffView", UIBase);

function ArenaBuffView:ctor(winName, _buffId)
    ArenaBuffView.super.ctor(self, winName)
    self.buffId = _buffId
end

function ArenaBuffView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function ArenaBuffView:registerEvent()
	ArenaBuffView.super.registerEvent(self);

	self.UI_1.btn_close:setTouchedFunc(c_func(self.close, self))
	self:registClickClose("out")
end

function ArenaBuffView:initData()
	self.buffData = FuncPvp.getBuffDataByBuffId(self.buffId)
	self.attackAttr = self.buffData.attackProperty
	for i,v in ipairs(self.attackAttr) do
		v.index = i
		v.isAttack = true
	end

	local attackParams = {}
	attackParams.tags = self.buffData.attackTeam
	attackParams.attr = self.attackAttr

	-- self.defendAttr = self.buffData.defendProperty
	-- for i,v in ipairs(self.defendAttr) do
	-- 	v.index = i
	-- end
	-- self.defendTxt = {}
	-- for i,v in ipairs(self.buffData.defendTeam) do
	-- 	local name = FuncCommon.getTagNameByTypeAndId(v.key, v.value)
	-- 	table.insert(self.defendTxt, name)
	-- end
	-- if self.buffData.defendPartnerProperty then
	-- 	self.defendPartnerProperty = self.buffData.defendPartnerProperty
	-- end
	self.allData = {}

	if self.attackAttr then
		table.insert(self.allData, attackParams)
	end

	--合并数据
	local mergeData = {}
	if self.buffData.attackPartnerProperty then
		self.attackPartnerProperty = self.buffData.attackPartnerProperty
	end
	for i,v in ipairs(self.attackPartnerProperty) do
		local partnerId = v.partnerId
		if mergeData[tostring(partnerId)] then
			local attr = {key = v.key, value = v.value, mode = v.mode}
			table.insert(mergeData[tostring(partnerId)], attr)
		else
			mergeData[tostring(partnerId)] = {}
			local attr = {key = v.key, value = v.value, mode = v.mode}
			table.insert(mergeData[tostring(partnerId)], attr)
		end
	end
	
	--根据合并后的数据构建滚动条用的数据
	for k,v in pairs(mergeData) do
		local partnerId = k
		for ii,vv in ipairs(v) do
			vv.index = ii			
		end
		local data = {}
		data.partnerId = partnerId
		data.attr = v
		table.insert(self.allData, data)
	end

	self:initScrollCfg()
end

function ArenaBuffView:initScrollCfg()
	self.panel_1:setVisible(false)
	local creatFunc = function (itemData)
		local view = UIBaseDef:cloneOneView(self.panel_1)
		self:updateItemView(itemData, view)
		return view
	end

	local reuseCellFunc = function (itemData, view)
		self:updateItemView(itemData, view)
	end

	self.panel_fgx:setVisible(false)
	local createItemLineFunc = function (itemData)
		local view = UIBaseDef:cloneOneView(self.panel_fgx)
        return view
	end

	-- 仙盟无极阁属性加成
	self.panel_2:setVisible(false)
	local creatGuildFunc = function (itemData)
		local view = UIBaseDef:cloneOneView(self.panel_2)
		self:updateGuildPropertyItemView(itemData, view)
		return view
	end
	local reuseGuildCellFunc = function (itemData, view)
		self:updateGuildPropertyItemView(itemData, view)
	end

	self.itemViewParams = {
        data = nil,
        createFunc = creatFunc,
        updateCellFunc = reuseCellFunc,
        perNums= 1,
        offsetX = 50,
        offsetY = -10,
        widthGap = 0,
        heightGap = 0,
        perFrame = 1,
        itemRect = {x = 0, y = -215,width = 350,height = 215},
        cellWithGroup = 1,
    }

    self.itemLineParams = {
    	data = {""},
        createFunc = createItemLineFunc,
        itemRect = {x = 0, y = -25, width = 400, height = 25},
        perNums= 1,
        offsetX = 15,
        offsetY = -10,
        widthGap = 0,
        heightGap = 0,
        perFrame = 1,
        updateCellFunc = GameVars.emptyFunc,
        cellWithGroup = 2,
    }

    -- 仙盟无极阁属性加成
   	self.guildItemViewParams = {
        data = nil,
        createFunc = creatGuildFunc,
        updateCellFunc = reuseGuildCellFunc,
        perNums= 1,
        offsetX = 50,
        offsetY = -10,
        widthGap = 0,
        heightGap = 0,
        perFrame = 1,
        itemRect = {x = 0, y = -215,width = 350,height = 215},
        -- cellWithGroup = 3,
    }
end

function ArenaBuffView:buildItemScrollParams()
	local scrollParams = {}
	if #self.allData > 0 then
		for i,v in ipairs(self.allData) do
			local copyItemParams = table.deepCopy(self.itemViewParams)
		    copyItemParams.data = {v}
		    local offsetY = (math.round(#v.attr / 2) - 2) * 36
		    if v.partnerId then
		    	offsetY = offsetY + 5
		    elseif v.tags then
		    	local count = 0
		    	for ii,vv in ipairs(v.tags) do
					local curTagPartners = FuncPartner.getPartnersByTags(vv)
					for iii,vvv in ipairs(curTagPartners) do
						count = count + 1
					end
				end
				offsetY = offsetY + math.floor((count - 1) / 6) * 60
		    end
		    
		    copyItemParams.itemRect = {x = 0, y = -(215 + offsetY),width = 350,height = 215 + offsetY}
		    scrollParams[#scrollParams + 1] = copyItemParams
		    
		    -- 分割线
	        local copyLineParams = table.deepCopy(self.itemLineParams)
	        scrollParams[#scrollParams + 1] = copyLineParams
		end	    
	end

	-- 无极阁加成
	local copyGuildParams = table.deepCopy(self.guildItemViewParams)
	local guildDataArr = GuildModel:getShowPropertyDataByType(FuncGuild.effectZoneType.PVP)
	offsetY = 0
	local tempArr = {}
	local isHasKey = false
	for target,v in pairs(guildDataArr) do
		offsetY = offsetY + 40
		isHasKey = false
		for key,value in pairs(v) do
			if type(value) == "table" then
				local offsety1 = 0
				for attr,modeValue in pairs(value) do
					offsety1 = offsety1 + 40
					isHasKey = true
				end
				if isHasKey then
					offsetY = offsetY + offsety1/2
				end
			end
		end
		if isHasKey then
			tempArr[target] = guildDataArr[target]
		end
	end
	if table.length(tempArr)>0 then
		copyGuildParams.data = {tempArr}
		copyGuildParams.itemRect = {x = 0, y = -(215 + offsetY),width = 350,height = 215 + offsetY}
		scrollParams[#scrollParams + 1] = copyGuildParams
	end
	return scrollParams
end

function ArenaBuffView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_pvp_des004"))
	self.UI_1.mc_1:setVisible(false)

	self:updateAttackAttrView()
	-- self:updateDefendAttrView()
end

function ArenaBuffView:updateAttackAttrView()
	local scrollParams = self:buildItemScrollParams()
	self.scroll_1:styleFill(scrollParams)
	self.scroll_1:hideDragBar()
end

function ArenaBuffView:updateDefendAttrView()
	local defendParams = {}
	if self.defendPartnerProperty then
		local copyItemViewParams = table.deepCopy(self.itemViewParams)
		copyItemViewParams.data = self.defendPartnerProperty
		defendParams[#defendParams + 1] = copyItemViewParams
	end

	if self.defendAttr then
		local copyItemViewParams = table.deepCopy(self.itemViewParams)
		copyItemViewParams.data = self.defendAttr
		defendParams[#defendParams + 1] = copyItemViewParams
	end
	self.scroll_2:styleFill(defendParams)
	self.scroll_2:hideDragBar()
end

function ArenaBuffView:updateItemAttr(_view, attr)
	local attrGroup = {key = attr.key, value = attr.value,mode = attr.mode}
	local attrKeyName = FuncBattleBase.getAttributeName(attrGroup.key)
	local attrValue = FuncBattleBase.getFormatFightAttrValueByMode(attrGroup.key, attrGroup.value, attrGroup.mode)
	local attr_str = attrKeyName.."+"..attrValue
	_view.panel_1.mc_biao0:showFrame(FuncPartner.ATTR_KEY_MC[tostring(attrGroup.key)])
	_view.panel_1.txt_1:setString(attr_str)
end

function ArenaBuffView:updateItemView(itemData, view)
	view.panel_1:setVisible(false)
	view.scroll_2:setVisible(false)
	if itemData.partnerId then		
		local partnerId = itemData.partnerId
		local partnerName = FuncPartner.getPartnerName(partnerId)
		view.txt_1:setString(partnerName)
		
		for i,v in ipairs(itemData.attr) do
			local panel_attr = UIBaseDef:cloneOneView(view.panel_1)
			self:updateItemAttr(panel_attr, v)
			panel_attr:addto(view)
			local offsetX = ((v.index - 1) % 2) * 200
			local offsetY = (math.round(v.index / 2) - 1) * 40
			panel_attr:pos(-120 + offsetX, -65 - offsetY)
		end
		local partner_offsetY = -(math.round(#itemData.attr / 2) - 2) * 36 - 152
		-- view.scroll_2:pos(0, -152 - scroll_offsetY)
		local partners = {partnerId}
		-- self:updatePartnerScroll(view, partners)
		self:updatePartners(view, partners, partner_offsetY)
	else
		local name = ""	
		for i,v in ipairs(itemData.tags) do
			local name_tid = FuncCommon.getTagNameByTypeAndId(v.key, v.value)
			local tempStr = GameConfig.getLanguage(tostring(name_tid))
			if i < #itemData.tags then
				tempStr = tempStr.."、"
			else
				tempStr = tempStr..GameConfig.getLanguage("#tid_pvp_des007")
			end
			name = name..tempStr
		end				
		view.txt_1:setString(name)
		for i,v in ipairs(itemData.attr) do
			local panel_attr = UIBaseDef:cloneOneView(view.panel_1)
			self:updateItemAttr(panel_attr, v)
			panel_attr:addto(view)
			local offsetX = ((v.index - 1) % 2) * 200
			local offsetY = (math.round(v.index / 2) - 1) * 40
			panel_attr:pos(-120 + offsetX, -65 - offsetY)
		end

		local partner_offsetY = -(math.round(#itemData.attr / 2) - 2) * 36 - 152
		-- view.scroll_2:pos(0, -152 - scroll_offsetY)
		local partners = {}
		for i,v in ipairs(itemData.tags) do
			local curTagPartners = FuncPartner.getPartnersByTags(v)
			for ii,vv in ipairs(curTagPartners) do
				table.insert(partners, vv)
			end
		end
		self:updatePartners(view, partners, partner_offsetY)
		-- self:updatePartnerScroll(view, partners)
	end
end

function ArenaBuffView:updatePartners(_view, _partners, partner_offsetY)
	_view.panel_fbiconnew1:setVisible(false)

	for i = 1, #_partners, 1 do
		local view = UIBaseDef:cloneOneView(_view.panel_fbiconnew1)
		local offsetX = (i - 1) % 6 * 58
		local offsetY = math.floor((i - 1) / 6) * 60
		self:updatePartnerItem(view, _partners[i])
		view:addto(_view)
		view:pos(offsetX, partner_offsetY - offsetY)
	end
end

function ArenaBuffView:updatePartnerScroll(_view, _partners)
	_view.panel_fbiconnew1:setVisible(false)

	local createFunc = function (itemData)
		local view = UIBaseDef:cloneOneView(_view.panel_fbiconnew1)
		self:updatePartnerItem(view, itemData)
		return view
	end

	local reuseCellFunc = function (itemData, view)
		self:updatePartnerItem(view, itemData)
	end
	local offsetX = 0
	local num = #_partners
	if num < 6 then
		offsetX = (6 - num) * 30 - 5
	end

	local params = {
		{
			data = _partners,
			createFunc = createFunc,
	        updateCellFunc = reuseCellFunc,
	        perNums= 1,
	        offsetX = offsetX,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
	        itemRect = {x = 0, y = -60,width = 60,height = 60},
		}
	}

	_view.scroll_2:styleFill(params)
	_view.scroll_2:hideDragBar()
end

-- 更新仙盟属性
function ArenaBuffView:updateGuildPropertyItemView( itemData, itemView )
	itemView.txt_title:visible(false)
	itemView.panel_1:visible(false)
	local offsetY = -60 
	for target,v in pairs(itemData) do
		for key,value in pairs(v) do
			-- 显示标题
			if key == "type" then
				local typeTitle = UIBaseDef:cloneOneView(itemView.txt_title)
				typeTitle:pos(0,offsetY)
				typeTitle:parent(itemView)
				local titleName = FuncNewLove.appendTargetName[tonumber(value)]
				typeTitle:setString(titleName)
				offsetY = offsetY - 40
			end
			-- 显示属性item
			if key == "value" then
				local offy = 0
				for attr,modeValue in pairs(value) do
					offy = offy + 1
					local propertyItem = UIBaseDef:cloneOneView(itemView.panel_1)
					propertyItem:parent(itemView)
					local dd = (offy%2)==0 and 1 or 0
					local yy = offsetY + math.floor((offy-1)/2)*(-40)
					-- echo("_________ dd,yy",dd,yy)
					propertyItem:pos(200*dd,yy)
					propertyItem.mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(attr)])
					for kkkk,vvvv in pairs(modeValue) do
						propertyItem.txt_1:setString(FuncBattleBase.getAttributeName( attr )..(vvvv/100).."%")
					end
				end
				offsetY = offsetY - 60*(math.floor((offy-1)/2)+1)
			end
		end
	end
end

function ArenaBuffView:updatePartnerItem(_view, _itemData)
	_view.mc_dou:setVisible(false)
	_view.txt_3:setVisible(false)
	_view.panel_txtdi:setVisible(false)
	_view.mc_2:showFrame(1)
	local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
    headMaskSprite:pos(-1,0)
    headMaskSprite:setScale(0.99)
	local iconName = FuncPartner.getPartnerIconById(_itemData)
	local iconSprite = display.newSprite(FuncRes.iconHero(iconName))
	iconSprite = FuncCommUI.getMaskCan(headMaskSprite, iconSprite)
	iconSprite:setScale(1.1)
	local ctn_partner = _view.mc_2.currentView.ctn_1
	ctn_partner:removeAllChildren()
	ctn_partner:addChild(iconSprite)
	iconSprite:setTouchedFunc(c_func(self.showPartnerDetailView, self, _itemData))
end

function ArenaBuffView:showPartnerDetailView(_partnerId)
	WindowControler:showWindow("PartnerInfoUI", _partnerId)
end

function ArenaBuffView:initViewAlign()
	
end

function ArenaBuffView:updateUI()
	-- TODO
end

function ArenaBuffView:close()
	self:startHide()
end

function ArenaBuffView:deleteMe()
	-- TODO

	ArenaBuffView.super.deleteMe(self);
end

return ArenaBuffView;