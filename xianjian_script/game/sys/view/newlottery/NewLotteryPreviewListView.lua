--[[
	Author: 张燕广
	Date:2018-08-23
	Description: 聚魂抽卡预览功能
]]

local NewLotteryPreviewListView = class("NewLotteryPreviewListView", UIBase);

--[[
	targetPartnerId:目标奇侠Id
]]
function NewLotteryPreviewListView:ctor(winName,targetPartnerId)
    NewLotteryPreviewListView.super.ctor(self, winName)

    self.targetPartnerId = targetPartnerId
end

function NewLotteryPreviewListView:loadUIComplete()
	self:initData()
	self:registerEvent()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function NewLotteryPreviewListView:registerEvent()
	NewLotteryPreviewListView.super.registerEvent(self);
	self.btn_back:setTap(c_func(self.startHide,self))

	self.mc_1:showFrame(1)
	self.mc_1.currentView.btn_1:setTap(c_func(self.onClickTag,self,self.TAG_TYPE.PARTNER))

	self.mc_2:showFrame(1)
	self.mc_2.currentView.btn_1:setTap(c_func(self.onClickTag,self,self.TAG_TYPE.ITEM))
end

function NewLotteryPreviewListView:initData()
	self.TAG_TYPE = {
		PARTNER = 1,
		ITEM = 2
	}
	self.partnerDataList,self.itemDataList = NewLotteryModel:getallPreviewData()

	if self.targetPartnerId == nil then
		self.targetPartnerId = self.partnerDataList[1].itemID
	end

	self.targetPartnerData = self:getPartnerDataById(self.targetPartnerId)

	-- 默认选择第一个页签
	self.defaultTagIndex = 1
end

function NewLotteryPreviewListView:initView()
	self:initScrollCfg()
end

function NewLotteryPreviewListView:initScrollCfg()
	self.panel_qixiatouxiang:setVisible(false)

	local createItemViewFunc = function(itemData) 
		local itemView = UIBaseDef:cloneOneView(self.panel_qixiatouxiang)
		self:setItemView(itemData,itemView)
		return itemView
	end

	local updateItemViewFunc = function(itemData,itemView)
		self:setItemView(itemData,itemView)
	end

	self.itemListParams = 
	{	
		{
            data = self.itemDataList,
            createFunc = createItemViewFunc,
            updateCellFunc = updateItemViewFunc,
            itemRect = { x = 0, y = 0, width = 100, height = 110 },
            perNums = 6,
            offsetX = -53,
	        offsetY = 16,
	        widthGap = 43,
	        heightGap = 20,
	        perFrame = 5,
        },
    }

    self.partnerListParams = 
	{	
		{
            data = self.partnerDataList,
            createFunc = createItemViewFunc,
            updateCellFunc = updateItemViewFunc,
            itemRect = { x = 0, y = 0, width = 100, height = 115 },
            perNums = 3,
            offsetX = -60,
	        offsetY = 10,
	        widthGap = -5,
	        heightGap = 10,
	        perFrame = 3,
        },
    }
end

function NewLotteryPreviewListView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title,UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop)
end

function NewLotteryPreviewListView:updateUI()
	self:onClickTag(self.defaultTagIndex)
end

function NewLotteryPreviewListView:onClickTag(tagIndex)
	if self.curSelectTagIndex == tagIndex then
		return
	end

	self.curSelectTagIndex = tagIndex

	self:updateTagStatus()

	if self.curSelectTagIndex == self.TAG_TYPE.PARTNER then
		self:updatePartnerListView()
	elseif self.curSelectTagIndex == self.TAG_TYPE.ITEM then
		self:updateItemListView()
	end
end

-- 更新伙伴列表
function NewLotteryPreviewListView:updatePartnerListView()
	self.mc_liangzhuangtai:showFrame(2)
	local itemScroller = self.mc_liangzhuangtai.currentView.scroll_1

	local partnerData = self.targetPartnerData
	self:showPartnerInfo(partnerData)

	local dataIndex = self:getDataIndex(partnerData)
	itemScroller:styleFill(self.partnerListParams)
	itemScroller:gotoTargetPos(dataIndex,1,1)
end

function NewLotteryPreviewListView:getPartnerDataById(partnerId)
	for k,v in pairs(self.partnerDataList) do
		if v.itemID == partnerId then
			return v
		end
	end

	return nil
end

function NewLotteryPreviewListView:getDataIndex(partnerData)
	for i=1,#self.partnerDataList do
		if partnerData == self.partnerDataList[i] then
			return i
		end
	end
end

function NewLotteryPreviewListView:showPartnerInfo(partnerData)
	echo("partnerData itemID ",partnerData.itemID)
	self.targetPartnerData = partnerData

	self:updatePartnerInfo(partnerData)
	self:updatePartnerSelectStatus()
end

-- 更新当前选择的伙伴信息
function NewLotteryPreviewListView:updatePartnerInfo(data)
	local curPartnerInfo = data
	local partnerId = curPartnerInfo.itemID

	local mcView = self.mc_liangzhuangtai.currentView
	local ctn = mcView.ctn_1

	-- 延迟创建spine
	self:delayCall(c_func(self.updatePartnerSpineView,self,partnerId,ctn),1/GameVars.GAMEFRAMERATE)

	mcView.mc_namebig:showFrame(1)

	local partnerCfgData = FuncPartner.getPartnerById(partnerId)
	
	local partnerName = GameConfig.getLanguage(partnerCfgData.name)
	local len = string.utf8len(partnerName)
	if len >= 4 then
		mcView.mc_namebig:showFrame(2)
	end

	-- 属性
	local mcShuxing = mcView.mc_namebig.currentView.mc_shuxing
	mcShuxing:showFrame(tonumber(partnerCfgData.type))

	-- 名字
	local txtName = mcView.mc_namebig.currentView.txt_1
	txtName:setString(partnerName)

	-- 描述
	local des = GameConfig.getLanguage(FuncPartner.getDescribe(partnerId))
	local txtDes = mcView.txt_texing
	FuncCommUI.setVerTicalTXT( {str = des, space = 1, txt = txtDes} )

	mcView.btn_qixaixiangqing:setTap(c_func(self.showPartnerDetailInfo,self,partnerId))
	mcView.panel_kong:setTouchedFunc(c_func(self.showPartnerDetailInfo,self,partnerId))
end

function NewLotteryPreviewListView:updatePartnerSpineView(partnerId,ctn)
	local spine = FuncPartner.getPartnerOrCgarLiHui(partnerId,nil)
	spine:scale(0.8)
	ctn:removeAllChildren()

	local maskSprite = display.newSprite(FuncRes.iconOther("activity_bg_zhezhao"))
	maskSprite:setScaleX(1.2)
	maskSprite:anchor(0.5,0)
	maskSprite:pos(-20,0)
	spine = FuncCommUI.getMaskCan(maskSprite, spine)
	spine:pos(-40,0)
	ctn:addChild(spine)
end

-- 更新奇侠选中状态
function NewLotteryPreviewListView:setSelectStatus(partnerData,itemView)
	if not itemView or not partnerData then
		return
	end

	if partnerData == self.targetPartnerData then
		itemView:setResSelected(true)
	else
		itemView:setResSelected(false)
	end
end

-- 更新奇侠选中状态
function NewLotteryPreviewListView:updatePartnerSelectStatus()
	local scroller = self.mc_liangzhuangtai.currentView.scroll_1
	local itemView = scroller:getViewByData(partnerData)

	for k,v in pairs(self.partnerDataList) do
		local itemView = scroller:getViewByData(v)
		if itemView then
			self:setSelectStatus(v,itemView.UI_2)
		end
	end
end

function NewLotteryPreviewListView:showPartnerDetailInfo(partnerId)
	local params = {id = partnerId}
   	WindowControler:showWindow("PartnerCompInfoView", params,UserModel:data(),false)
end

-- 更新道具列表
function NewLotteryPreviewListView:updateItemListView()
	self.mc_liangzhuangtai:showFrame(1)
	local itemScroller = self.mc_liangzhuangtai.currentView.scroll_1
	itemScroller:styleFill(self.itemListParams)
end

function NewLotteryPreviewListView:setItemView(data,itemView) 
	itemData = data._type..","..data.itemID..",1"
	local view = itemView.UI_2
	view:setResItemData({reward = itemData})
	view:showResItemNum(false)

	local rewards = string.split(itemData, ",")
  	local resType = rewards[1]
	local resId = rewards[2]
	local needNum = rewards[3]

	if  tostring(resType) == FuncDataResource.RES_TYPE.PARTNER  then
		view:showResItemName(true,true)
		view.panelInfo.mc_zi:showFrame(tonumber(7))
		local mcZi = view.panelInfo.mc_zi
    	local nameTxt = mcZi.currentView.txt_1
  		nameTxt:setString(view.itemNameWithNotNum)
  		nameTxt:setColor(cc.c3b(0x84,0x48,0x20));
  		itemView.panel_kuu:setVisible(true)
  		view:hideBgCase()
  		view:setTouchEnabled(true)
  		view:getResItemIconCtn():setTouchedFunc(c_func(self.showPartnerInfo, self,data),nil,true);
  	else
  		view:showResItemName(true,true,nil,true)
  		view:showResItemNameWithQuality()
  		itemView.panel_kuu:setVisible(false)
		FuncCommUI.regesitShowResView(view, resType, needNum, resId,itemData,true,true)
	end

	self:setSelectStatus(data,view)
end

function NewLotteryPreviewListView:updateTagStatus()
	for k,v in pairs(self.TAG_TYPE) do
		local tagIndex = v
		if v == self.curSelectTagIndex then
			self["mc_" .. tagIndex]:showFrame(2)
		else
			self["mc_" .. tagIndex]:showFrame(1)
		end
	end
end

function NewLotteryPreviewListView:deleteMe()
	NewLotteryPreviewListView.super.deleteMe(self);
end

return NewLotteryPreviewListView;
