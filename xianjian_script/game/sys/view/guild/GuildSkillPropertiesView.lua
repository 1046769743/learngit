--
--Author:      zhuguangyuan
--DateTime:    2018-04-22 09:33:29
--Description: 仙盟科技-无极阁建筑 增加的全局属性及玩法增量 玩法耗费资源减少量 汇总展示界面
-- 1.对其他玩法的属性加成 在布阵的时候有点击入口 通关传入effectZoneType 进行区分


local GuildSkillPropertiesView = class("GuildSkillPropertiesView", UIBase);

function GuildSkillPropertiesView:ctor(winName,effectZoneType)
    GuildSkillPropertiesView.super.ctor(self, winName)
    self.effectZoneType = effectZoneType

    echo("________effectZoneType______",effectZoneType)
end

function GuildSkillPropertiesView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildSkillPropertiesView:registerEvent()
	GuildSkillPropertiesView.super.registerEvent(self);
	self.UI_1.btn_close:setTap(c_func(self.startHide,self))
	self:registClickClose("out")
end

function GuildSkillPropertiesView:initData()
	-- 初始化所有数据
	self.showDataArr = GuildModel:getShowPropertyDataByType(self.effectZoneType)

	if self.effectZoneType == FuncGuild.effectZoneType.GLOBAL then
		local resourceData = FuncGuild.getCalculateResourceData(UserModel:guildSkills())
		if resourceData and table.length(resourceData)>0 then
			for k,v in pairs(resourceData) do
				local typeName = "玩法产量加成"
				if k == "amount_produce_increase" then
					typeName = GameConfig.getLanguage("#tid_guild_skill_15")
				elseif k == "amount_cost_reduce" then
					typeName = GameConfig.getLanguage("#tid_guild_skill_16")
				end
				self.showDataArr[k] = FuncGuild.countFinalResourceAttrForShow(typeName,v)
			end
		end
	end
end

function GuildSkillPropertiesView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_skill_6"))
	self.UI_1.mc_1:visible(false)

	self.propertyScroll = self.scroll_1
	self.propertyPanel = self.panel_1
	self.resourcePanel = self.panel_2
	self.haveNonePropertiesPanel = self.panel_3
	
	self.propertyPanel:visible(false)
	self.resourcePanel:visible(false)
	self.haveNonePropertiesPanel:visible(false)

	self:updatePropertyView(self.showDataArr)
end

-- 更新属性滚动条
function GuildSkillPropertiesView:updatePropertyView( data )
	if FuncGuild.isDebug then
		dump(data, "全局属性数据")
    end
    local hasProperty = false
	if (not data) or 
		(table.length(data.char.value)==0 
		and table.length(data.offensive.value)==0 
		and table.length(data.defensive.value)==0 
		and table.length(data.assisted.value)==0) then

		if self.effectZoneType == FuncGuild.effectZoneType.GLOBAL then
		 	if (table.length(data.amount_produce_increase.value)==0 
				and table.length(data.amount_cost_reduce.value)==0 )
				then
				self.haveNonePropertiesPanel:visible(true)
			else
				hasProperty = true
			end
		else
			self.haveNonePropertiesPanel:visible(true)
		end
	else
		hasProperty = true
	end
	
	echo("______________ hasProperty ____",hasProperty)
	if hasProperty then
		-- 增加属性计数 方便排版
		for k,v in pairs(data) do
			-- 不同种类
			local numOfProperty = 0
			for kk,vv in pairs(v.value) do
				-- 这是属性
				-- 不同key属性
				if v.type then  
					for kkk,vvv in pairs(vv) do
						numOfProperty = numOfProperty + 1
					end
				-- 这是资源改变量
				elseif v.typeName then
					numOfProperty = numOfProperty + 1
				end
			end
			v.propertyNum = numOfProperty
		end
		self:updateTotalPropertyUI(data)
	end
end

-- 更新总体属性ui
function GuildSkillPropertiesView:updateTotalPropertyUI(_data)
	-- 属性展示函数
	local createItemFunc = function( _itemData )
		local itemView = UIBaseDef:cloneOneView(self.propertyPanel)
		itemView:visible(true)
		self:updateOneTypeProperty(_itemData,itemView)
		return itemView
	end
	local updateItemFunc = function( _itemData,_itemView )
		local itemView = _itemView
		self:updateOneTypeProperty(_itemData,itemView)
		return itemView
	end
	self.propertyData = _data

	-- 产量增加或者耗费量减少函数
	local createResourceItemFunc = function( _itemData )
		local itemView = UIBaseDef:cloneOneView(self.resourcePanel)
		itemView:visible(true)
		self:updateOneResource(_itemData,itemView)
		return itemView
	end
	local updateResourceItemFunc = function( _itemData,_itemView )
		local itemView = _itemView
		self:updateOneResource(_itemData,itemView)
		return itemView
	end	

	self.charNum = self:numOfrow(self.propertyData.char.propertyNum) + 2
	self.offensiveNum = self:numOfrow(self.propertyData.offensive.propertyNum) + 2
	self.defensiveNum = self:numOfrow(self.propertyData.defensive.propertyNum) + 2
	self.assistedNum = self:numOfrow(self.propertyData.assisted.propertyNum) + 2

	if self.propertyData.amount_produce_increase then
		self.amount_produce_increaseNum = self.propertyData.amount_produce_increase.propertyNum + 2
	else
		self.amount_produce_increaseNum = 0
	end
	if self.propertyData.amount_cost_reduce then
		self.amount_cost_reduceNum = self.propertyData.amount_cost_reduce.propertyNum + 2
	else
		self.amount_cost_reduceNum = 0
	end
	echo("__ self.charNum,self.offensiveNum,self.defensiveNum,self.assistedNum _____",self.charNum,self.offensiveNum,self.defensiveNum,self.assistedNum)
	self.propertyParams = {
		{
	        data = {self.propertyData.char},
	        createFunc = createItemFunc,
	        updateCellFunc = updateItemFunc,
	        perNums= 1,
	        offsetX = 25,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 10,
	        itemRect = {x=0,y=-40*self.charNum,width = 370,height = 40*self.charNum }, -- 动态计算
	        perFrame = 1,
	        flag = "char"
		},	
		{
	        data = {self.propertyData.offensive},
	        createFunc = createItemFunc,
	        updateCellFunc = updateItemFunc,
	        perNums= 1,
	        offsetX = 25,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 10,
	        itemRect = {x=0,y=-40*self.offensiveNum,width = 370,height = 40*self.offensiveNum}, -- 动态计算
	        perFrame = 1,
	        flag = "offensive"
		},	
		{
	        data = {self.propertyData.defensive},
	        createFunc = createItemFunc,
	        updateCellFunc = updateItemFunc,
	        perNums= 1,
	        offsetX = 25,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 10,
	        itemRect = {x=0,y=-40*self.defensiveNum,width = 370,height = 40*self.defensiveNum}, -- 动态计算
	        perFrame = 1,
	        flag = "defensive"
		},
		{
	        data = {self.propertyData.assisted},
	        createFunc = createItemFunc,
	        updateCellFunc = updateItemFunc,
	        perNums= 1,
	        offsetX = 25,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 10,
	        itemRect = {x=0,y=-40*self.assistedNum,width = 370,height = 40*self.assistedNum}, -- 动态计算
	        perFrame = 1,
	        flag = "assisted"
		},	
		{
	        data = {self.propertyData.amount_produce_increase},
	        createFunc = createResourceItemFunc,
	        updateCellFunc = updateResourceItemFunc,
	        perNums= 1,
	        offsetX = 25,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 10,
	        itemRect = {x=0,y=-40*self.amount_produce_increaseNum,width = 370,height = 40*self.amount_produce_increaseNum}, -- 动态计算
	        perFrame = 1,
	        flag = "amount_produce_increase"
		},	
		{
	        data = {self.propertyData.amount_cost_reduce},
	        createFunc = createResourceItemFunc,
	        updateCellFunc = updateResourceItemFunc,
	        perNums= 1,
	        offsetX = 25,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 10,
	        itemRect = {x=0,y=-40*self.amount_cost_reduceNum,width = 370,height = 40*self.amount_cost_reduceNum}, -- 动态计算
	        perFrame = 1,
	        flag = "amount_cost_reduce"
		},	
	}

	-- 如果没有资源变更条目则隐藏
	if not self.propertyData.amount_cost_reduce or table.length(self.propertyData.amount_cost_reduce.value)==0 then
		for k,v in ipairs(self.propertyParams) do
			if v.flag == "amount_cost_reduce" then
				self.propertyParams[k] = nil
			end
		end
	end
	if not self.propertyData.amount_produce_increase or table.length(self.propertyData.amount_produce_increase.value)==0 then
		for k,v in ipairs(self.propertyParams) do
			if v.flag == "amount_produce_increase" then
				self.propertyParams[k] = nil
			end
		end
	end

	-- 没有某个类型(攻击 辅助 防御 主角)的属性 则隐藏相应条目
	if table.length(self.propertyData.assisted.value)==0 then
		for k,v in ipairs(self.propertyParams) do
			if v.flag == "assisted" then
				self.propertyParams[k] = nil
			end
		end
	end
	if table.length(self.propertyData.defensive.value)==0 then
		for k,v in ipairs(self.propertyParams) do
			if v.flag == "defensive" then
				self.propertyParams[k] = nil
			end
		end
	end
	if table.length(self.propertyData.offensive.value)==0 then
		for k,v in ipairs(self.propertyParams) do
			if v.flag == "offensive" then
				self.propertyParams[k] = nil
			end
		end
	end
	if table.length(self.propertyData.char.value)==0 then
		for k,v in ipairs(self.propertyParams) do
			if v.flag == "char" then
				self.propertyParams[k] = nil
			end
		end
	end

	local params = {}
	for k,v in pairs(self.propertyParams) do
		params[#params + 1] = v
	end 
	if FuncGuild.isDebug then
		dump(self.propertyParams, "self.propertyParams")
	end
	self.propertyScroll:cancleCacheView()
    self.propertyScroll:styleFill(params)
end

-- 更新一种类型的属性
-- 主角 攻击 防御 辅助
function GuildSkillPropertiesView:updateOneTypeProperty( _itemData,itemView )
	if FuncGuild.isDebug then
		dump(_itemData, "desciption _itemData ")
	end
	local txtTitle = FuncGuild.appendTargetName[_itemData.type].."属性"
	itemView.txt_title:setString(txtTitle)
	itemView.panel_1:visible(false)

	self.perDisX = 300
	self.perDisY = -40

	self.offsetX = 45
	self.offsetY = 0

	-- 属性数量
	numOfProperty = 0
	for k,v in pairs(_itemData.value) do
		local propertyName = FuncBattleBase.getAttributeName( k )
		for kk,vv in pairs(v) do
			numOfProperty = numOfProperty + 1
			local value = nil
			if tostring(kk) == "2" then
				value = (vv/100).."%"
			elseif tostring(kk) == "3" then
				value = vv
			end
			local str = propertyName.." : +"..value
			echo("________ numOfProperty,str _v.key______________",numOfProperty,str,v.key)
			local oneTxtView = UIBaseDef:cloneOneView(itemView.panel_1)
			oneTxtView:visible(true)
			oneTxtView:parent(itemView)
			oneTxtView:anchor(0,1)
			oneTxtView:pos( self.perDisX*(-(numOfProperty%2) + 1) + self.offsetX,
							self.perDisY*(self:numOfrow(numOfProperty)) + self.offsetY)
			oneTxtView.txt_1:setString(str)
			oneTxtView.mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(k)])
		end
	end
end

-- 更新一种类型的资源展示条目
function GuildSkillPropertiesView:updateOneResource( _itemData,itemView )
	if FuncGuild.isDebug then
		dump(_itemData, "===============desciption _itemData ")
	end
	local txtTitle = _itemData.typeName
	itemView.txt_title:setString(txtTitle)
	itemView.panel_1:visible(false)

	self.perDisX = 160
	self.perDisY = -40

	self.offsetX = 45
	self.offsetY = 0

	-- 属性数量
	numOfProperty = 0
	for k,v in pairs(_itemData.value) do
		numOfProperty = numOfProperty + 1
		local value = v.value
		if v.valueChangeMode == 1 then
			value = value/100
		end
		local str = GameConfig.getLanguageWithSwap(v.desc,value) 
		local oneTxtView = UIBaseDef:cloneOneView(itemView.panel_1)
		oneTxtView:visible(true)
		oneTxtView:parent(itemView)
		oneTxtView:anchor(0,1)
		oneTxtView:setPositionY(self.perDisY*(numOfProperty) + self.offsetY)
		oneTxtView.txt_1:setString(str)
		oneTxtView.mc_1:showFrame(2)
	end
end



-- 行数
function GuildSkillPropertiesView:numOfrow( _num )
	local t1,t2 = math.modf(_num/2) 
	if t2 > 0 then
		t2 = 1
	end
	return t1 + t2
end

-- 更新一个属性txtView
function GuildSkillPropertiesView:updateOneText( _textView,key,value )
	local text = FuncBattleBase.getAttributeName( key ).."+"..value
	_textView:setString(text)
end

function GuildSkillPropertiesView:initViewAlign()
	-- TODO
end

function GuildSkillPropertiesView:updateUI()
	-- TODO
end

function GuildSkillPropertiesView:deleteMe()
	GuildSkillPropertiesView.super.deleteMe(self);
end

return GuildSkillPropertiesView;
