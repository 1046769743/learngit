--
--Author:      zhuguangyuan
--DateTime:    2018-06-09 11:27:48
--Description: 情缘等级详情
--

local NewLoveLevelDetailView = class("NewLoveLevelDetailView", UIBase);

function NewLoveLevelDetailView:ctor(winName,mainPartnerId,vicePartnerId)
    NewLoveLevelDetailView.super.ctor(self, winName)
    self.mainPartnerId = mainPartnerId
    self.vicePartnerId = vicePartnerId
    echo("___________ 情缘等级详情 mainPartnerId",mainPartnerId)
end

function NewLoveLevelDetailView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function NewLoveLevelDetailView:registerEvent()
	NewLoveLevelDetailView.super.registerEvent(self)
	self.UI_1.btn_close:setTap(c_func(self.startHide,self))
	self:registClickClose("out")
end

function NewLoveLevelDetailView:initData()
	self.mainPartnerData =  PartnerModel:getPartnerDataById(self.mainPartnerId)
	if not self.mainPartnerData then
		self.mainPartnerStar = 0
		self.mainPartnerLoves = {} 
		self.mainPartnerResonateLv = 0
	else
		self.mainPartnerStar = self.mainPartnerData.star
		self.mainPartnerLoves = self.mainPartnerData.loves 
		self.mainPartnerResonateLv = self.mainPartnerData.resonanceLv
		echo("主伙伴共鸣等级-- ",self.mainPartnerResonateLv)
	end
	self.loveLevelData = {}
	local loveId = FuncNewLove.getLoveIdByPartnerId(self.mainPartnerId,self.vicePartnerId)
	for i=0,FuncNewLove.maxLevel do
		-- 属性加成
		local dataArr = FuncNewLove.getLovelevelUpProperty(loveId,i)
		local itemData = {
			level = i,
			attr = dataArr,
		}
		self.loveLevelData[#self.loveLevelData + 1] = itemData
	end
	-- dump(self.loveLevelData, "self.loveLevelData", nesting)
end

function NewLoveLevelDetailView:initView()
	self.UI_1.txt_1:setString("情缘属性")
	self.UI_1.mc_1:visible(false)


	self:initScrollCfg()
	self:updateAttackAttrView()
end


function NewLoveLevelDetailView:updateAttackAttrView()
	local scrollParams = self:buildItemScrollParams()
	self.scroll_1:styleFill(scrollParams)
	self.scroll_1:hideDragBar()
end

function NewLoveLevelDetailView:initScrollCfg()
	-- 创建标题item--------------------------------
	self.txt_1:setVisible(false)
	local createTitleFunc = function (itemData)
		local view = UIBaseDef:cloneOneView(self.txt_1)
		local mainName = FuncPartner.getPartnerName(self.mainPartnerId)
		view:setString(mainName.."获得属性加成")
		-- view:setPositionX(view:getPositionX()+150)
        return view
	end
	-- 创建属性item--------------------------------
	self.panel_1:setVisible(false)
	local creatFunc = function (itemData)
		local view = UIBaseDef:cloneOneView(self.panel_1)
		self:updateItemView(itemData, view)
		return view
	end
	local reuseCellFunc = function (itemData, view)
		self:updateItemView(itemData, view)
	end
	-- 创建分割条----------------------------------
	self.panel_x:setVisible(false)
	local createItemLineFunc = function (itemData)
		local view = UIBaseDef:cloneOneView(self.panel_x)
        return view
	end
	-- 标题
	self.titleViewParams = {
        data = {""},
        createFunc = createTitleFunc,
        -- updateCellFunc = GameVars.emptyFunc,
        perNums= 1,
        offsetX = 100,
        offsetY = 20,
        widthGap = 0,
        heightGap = 0,
        perFrame = 1,
        itemRect = {x = 0, y = -20,width = 246,height = 20},
        cellWithGroup = 1,
    }
    -- 每个等级情缘属性
	self.itemViewParams = {
        data = nil,
        createFunc = creatFunc,
        -- updateCellFunc = reuseCellFunc,
        perNums= 1,
        offsetX = 40,
        offsetY = 0,
        widthGap = 0,
        heightGap = 0,
        perFrame = 1,
        itemRect = {x = 0, y = -89,width = 425,height = 89},
        cellWithGroup = 3,
    }
    -- 分割条
    self.itemLineParams = {
    	data = {""},
        createFunc = createItemLineFunc,
        itemRect = {x = 0, y = -25, width = 400, height = 25},
        perNums= 1,
        offsetX = 0,
        offsetY = 0,
        widthGap = 0,
        heightGap = 0,
        perFrame = 1,
        -- updateCellFunc = GameVars.emptyFunc,
        cellWithGroup = 2,
    }
end

function NewLoveLevelDetailView:updateItemView(itemData, itemView)
	-- dump(itemData, "itemData", nesting)
	local loveId,loveLevel,loveValue,condition = NewLoveModel:getVicePartnerLoveData( self.mainPartnerId,self.vicePartnerId,self.mainPartnerLoves )
	echo("______ loveId,loveLevel,loveValue ",loveId,loveLevel,loveValue)
	-- 当前标签
	if tonumber(itemData.level) == tonumber(loveLevel) then
		itemView.panel_dq:visible(true)
	else
		itemView.panel_dq:visible(false)
	end
	local titleView = nil
	-- 如果情缘等级为0  则做特殊显示
	if tonumber(itemData.level) == 0 then
		itemView.mc_1:showFrame(2)
		titleView = itemView.mc_1:getCurFrameView()
		titleView.txt_1:setString("未拥有奇侠")
		itemView.panel_1.mc_pro:visible(false)
		itemView.panel_1.txt_1:setString("无属性加成")
		itemView.panel_1.txt_1:setPositionX(itemView.panel_1.txt_1:getPositionX() + 80)
		return
	else
		itemView.mc_1:showFrame(1)
		titleView = itemView.mc_1:getCurFrameView()
	end

	local mainName = FuncPartner.getPartnerName(self.mainPartnerId)
	local viceName = FuncPartner.getPartnerName(self.vicePartnerId)
	titleView.txt_1:setString(mainName)
	titleView.txt_2:setString(viceName)
	-- 情缘等级描述
	local targetLevel = itemData.level
	local frameNum = targetLevel
	-- if frameNum < 1 then
	-- 	frameNum = 1
	-- end
	titleView.mc_1:showFrame(frameNum+1)
	local loveTipsDesc = FuncNewLove.getLoveLevelDescById(loveId,targetLevel)
	loveTipsDesc = GameConfig.getLanguage(loveTipsDesc)
	titleView.mc_1:getCurFrameView().txt_1:setString(loveTipsDesc)

	itemView.panel_1:visible(false)
	for i,v in ipairs(itemData.attr) do
		local panel_attr = UIBaseDef:cloneOneView(itemView.panel_1)
		self:updateItemAttr(panel_attr, v)
		panel_attr:addto(itemView)
		local offsetX = ((i - 1) % 2) * 160
		local offsetY = (math.round(i / 2) - 1) * 40
		panel_attr:pos( offsetX, -45 + offsetY)
		-- 如果只有一个属性则将属性居中
		if table.length(itemData.attr) == 1 then
			panel_attr:setPositionX(120)
		end
	end
end

function NewLoveLevelDetailView:updateItemAttr(_view, attr)
	-- dump(attr, "desciption", nesting)
	local attrGroup = {key = attr.property, value = attr.value,mode = attr.mode}
	local attrKeyName = FuncBattleBase.getAttributeName(attrGroup.key)
	local attrValue = FuncBattleBase.getFormatFightAttrValueByMode(attrGroup.key, attrGroup.value, attrGroup.mode)
	local attr_str = attrKeyName.."+"..attrValue
	_view.mc_pro:showFrame(FuncPartner.ATTR_KEY_MC[tostring(attrGroup.key)])
	_view.txt_1:setString(attr_str)
end

function NewLoveLevelDetailView:buildItemScrollParams()
	local scrollParams = {}
	-- 标题
    local copyTitleParams = table.deepCopy(self.titleViewParams)
    scrollParams[#scrollParams + 1] = copyTitleParams
    -- 分割线
    local copyLineParams = table.deepCopy(self.itemLineParams)
    scrollParams[#scrollParams + 1] = copyLineParams
	if #self.loveLevelData > 0 then
		for i,v in ipairs(self.loveLevelData) do
			local copyItemParams = table.deepCopy(self.itemViewParams)
		    copyItemParams.data = {v}
		    local offsetY = (math.round(#v.attr / 2)) * 36
		    copyItemParams.itemRect = {x = 0, y = -(89 + offsetY),width = 425,height = 89 + offsetY}
		    scrollParams[#scrollParams + 1] = copyItemParams
		    -- 分割线
	        local copyLineParams = table.deepCopy(self.itemLineParams)
	        scrollParams[#scrollParams + 1] = copyLineParams
		end	    
	end
	return scrollParams
end
function NewLoveLevelDetailView:initViewAlign()
	-- TODO
end

function NewLoveLevelDetailView:updateUI()
	-- TODO
end

function NewLoveLevelDetailView:deleteMe()
	-- TODO

	NewLoveLevelDetailView.super.deleteMe(self);
end

return NewLoveLevelDetailView;
