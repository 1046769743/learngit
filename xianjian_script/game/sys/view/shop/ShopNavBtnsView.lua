local ShopNavBtnsView = class("ShopNavBtnsView", UIBase)

local ALL_SHOP_TYPES = FuncShop.SHOP_TYPES
local sortBySortId = function(a, b)
	return tonumber(a.sortId) < tonumber(b.sortId)
end

function ShopNavBtnsView:ctor(winName)
	ShopNavBtnsView.super.ctor(self, winName)
end

function ShopNavBtnsView:initData()
	local shopinfos = {}
    local hasVipShop = 0
	for shopType, shopId in pairs(ALL_SHOP_TYPES) do
		local info = {shopType = shopType, shopId = shopId, sortId = 10000+ tonumber(shopId)}
		local show = true
        
		if not FuncShop.checkShopBtnCanShowByLevel(shopId) then
			show = false
		end
		if FuncShop.isVipShop(shopId) then
			local hasOpen = ShopModel:checkIsOpen(shopId)
			if not hasOpen then
				info.sortId = info.sortId + 100
			else
				hasVipShop = hasVipShop + 1
				show = true
			end
		end
       	if  show then
			table.insert(shopinfos, info)
		end
	end
	table.sort(shopinfos, sortBySortId)
	self.shopInfos = shopinfos

	local index = 1
	if hasVipShop == 1 then
		local tempShop = self.shopInfos[1]
		self.shopInfos[1] = self.shopInfos[2]
		self.shopInfos[2] = tempShop
	elseif hasVipShop == 2 then
		local shop_table = {}
		for i = 1, 10, 1 do
			if i == 1 then
				shop_table[i] = self.shopInfos[3]
			elseif i == 6 then
				shop_table[i] = self.shopInfos[2]
			else
				shop_table[i] = "0"
			end
		end
		
		local index = 1
		for i = 1, #self.shopInfos, 1 do
			while shop_table[index] ~= "0" do
				index = index + 1
			end

			if self.shopInfos[i].shopId ~= FuncShop.SHOP_TYPES.NORMAL_SHOP_2 and 
				self.shopInfos[i].shopId ~= FuncShop.SHOP_TYPES.NORMAL_SHOP_3 then
				shop_table[index] = self.shopInfos[i]
				index = index + 1
			end
		end

		self.shopInfos = shop_table
	end

	local shopInfos_left = {}
	local shopInfos_right = {}
	-- if self.type == FuncShop.btns_Type.type_left then
	-- 	for i = 1, 5, 1 do
	-- 		if pairs(self.shopInfos[i]) then
	-- 			print(k,v)
	-- 		end
	-- 	end
	-- end
	for i = 1, #self.shopInfos, 1 do
		if i < 6 then
			if self.shopInfos[i] ~= "0" then
				shopInfos_left[i] = self.shopInfos[i]
			end			
		else
			if self.shopInfos[i] ~= "0" then
				shopInfos_right[i - 5] = self.shopInfos[i]
			end				
		end		
	end

    if self.type == FuncShop.btns_Type.type_left then
    	self.shopInfos = shopInfos_left
    else
    	self.shopInfos = shopInfos_right
    end
end

function ShopNavBtnsView:loadUIComplete()
	self:registerEvent()
	self.UI_shop_btn1:visible(false)
	self:adjustMainBg()
end

function ShopNavBtnsView:refreshBtns()
	self:initData()
	self:initBtns()
end

function ShopNavBtnsView:initBtns()
	local shopBtnInfos = table.deepCopy(self.shopInfos)
	-- dump(shopBtnInfos,"商店类型======")
	self.btns = {}
	local createFunc = function(btnInfo,_index)
		local btn = UIBaseDef:cloneOneView(self.UI_shop_btn1)
		btn:setBtnNavView(self)
		btn:setShopId(btnInfo.shopId)
		btn:updateUI()
		self.btns[btnInfo.shopId] = btn
		return btn
	end
	-- self.panel_sui:visible(false)
	-- local createFunc1 = function(btnInfo,_index)
	-- 	local btn = UIBaseDef:cloneOneView(self.panel_sui)
	-- 	return btn
	-- end
	local params = {
		{
			data = shopBtnInfos,
			createFunc = createFunc,
			perNums = 1,
			offsetX = 43,
			offsetY = 43,
			widthGap = 0,
			heightGap = 7,
			itemRect = {x=0,y= -72,width = 140,height = 72},
			perFrame=0
		},
		-- {
		-- 	data = {1},
		-- 	createFunc = createFunc1,
		-- 	perNums = 1,
		-- 	offsetX = 4,
		-- 	offsetY = -35,
		-- 	widthGap = 0,
		-- 	heightGap = 0,
		-- 	itemRect = {x=0,y= -105,width = 93,height = 81},
		-- 	perFrame=0
		-- }
	}
	self.scroll_1:hideDragBar()
	self.scroll_1:styleFill(params)
	-- if #shopBtnInfos <= 4 then
	self.scroll_1:setCanScroll(false)
	-- end
end

function ShopNavBtnsView:setMainView(shopMainView, _type)
	self.shopMainView = shopMainView
	self.type = _type
	self:initData()
	self:initBtns()
end

function ShopNavBtnsView:registerEvent()
end

function ShopNavBtnsView:selectShop(shopId,_isFirstGuild)
	local btns = self.btns
	local lastShopId = self._last_shop_id
	-- if self.type == FuncShop.btns_Type.type_left then
 --    	echoError("___doShowShop_left_______", "\n\nlastShopId===", lastShopId, "shopId===", shopId)
 --    else
 --    	echoError("___doShowShop_right_______", "\n\nlastShopId===", lastShopId, "shopId===", shopId)
 --    end

	--点击同一个商店，返回
	if lastShopId and btns[lastShopId] and btns[shopId] and tostring(shopId) == tostring(lastShopId) then
		btns[shopId]:setSelected(true)
		return 
	end

	if lastShopId and btns[lastShopId] then
		btns[lastShopId]:setSelected(false)
		if not btns[shopId] then
			self._last_shop_id = nil
		end
	end

	if btns[shopId] then
		btns[shopId]:setSelected(true)
		ShopModel:setSelectdShopId(shopId)
		self._last_shop_id = shopId
		self:doShowShop(shopId, _isFirstGuild)
	end


	-- if self.type == FuncShop.btns_Type.type_left then
 --    	echoError("___doShowShop_left_______", "\n\nlastShopId===", self._last_shop_id)
 --    else
 --    	echoError("___doShowShop_right_______", "\n\nlastShopId===", self._last_shop_id)
 --    end
	--- 选中都移动标签
	-- if touchfile == nil  then
	-- 	touchfile = false
	-- end
	-- if touchfile == false then
		-- self.scroll_1:pageEaseMoveTo( tonumber(shopId),1,0.2 )
	-- end
	
end

function ShopNavBtnsView:doShowShop(shopId, _isFirstGuild)
	-- if self.type == FuncShop.btns_Type.type_left then
 --    	echoError("___doShowShop_left_______")
 --    else
 --    	echoError("___doShowShop_right_______")
 --    end
	
	if self.shopMainView then		
		if _isFirstGuild then
			self.shopMainView:delayShowShop(shopId)
		else
			self.shopMainView:showShop(shopId)
		end
	end
end

function ShopNavBtnsView:close()
	self:startHide()
end

function ShopNavBtnsView:adjustMainBg()
   local scalex = GameVars.width*1.0/GameVars.gameResWidth
   local scaley = GameVars.height*1.0/GameVars.gameResHeight

   --页签背景拉伸适配
--   local panelBgBox = self.panel_bg:getContainerBox()
 --  self.panel_bg:runAction(act.moveby(0, 0, panelBgBox.height*1.0*(scaley-1)/2))
--   self.panel_bg:setScaleY(scaley)

   -- FuncCommUI.setScrollAlign(self.widthScreenOffset,self.scroll_1, UIAlignTypes.Middle, 0, 1)
end

return ShopNavBtnsView
