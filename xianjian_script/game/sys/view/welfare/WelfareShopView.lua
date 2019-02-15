--三皇里面替换奖池的系统
--2017-8-10 10:40
--@Author:wukai

local WelfareShopView = class("WelfareShopView", UIBase);

function WelfareShopView:ctor(winName)
    WelfareShopView.super.ctor(self, winName);
end


function WelfareShopView:loadUIComplete()
	self:addEventListeners()
    self.btn_refresh:setTap(c_func(self.refreshButton,self))
    self.btn_get:setTap(c_func(self.getLingShiView,self))
	self:initData()
	self:refreshbuttonInfo()
	self:tihuanIsShowRed()
end

function WelfareShopView:tihuanIsShowRed()
	local isshow = NewLotteryModel:fuliIsShowRed()
	self.btn_get:getUpPanel().panel_hongdian:setVisible(isshow)
	EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
end
function WelfareShopView:getLingShiView()
	WindowControler:showWindow("WelfaregGtLingShiView")
	--点击领取灵石按钮

	-- local cost = UserModel:totalCostGold();
	-- echo("======1111======",cost,NewLotteryModel:getLocalGold())
	-- if cost == NewLotteryModel:getLocalGold() then
	-- 	WindowControler:showTips("没有可领取的灵石")
	-- 	return 
	-- end
	-- NewLotteryServer:LingQuZhaowuFu()  --发送灵石替换协议

end

function WelfareShopView:addEventListeners()
    EventControler:addEventListener(ShopEvent.SHOPEVENT_MODEL_UPDATE, self.refreshUI, self)
    EventControler:addEventListener(MonthCardEvent.MONTH_CARD_BUY_SUCCESS_EVENT, self.refreshUI, self)
    -- EventControler:addEventListener(ShopEvent.SHOPEVENT_REFRESH_SHOP_END,self.refreshDataUI,self)
    -- EventControler:dispatchEvent(ShopEvent.SHOPEVENT_MODEL_UPDATE, data)
    EventControler:addEventListener(NewLotteryEvent.REFRESH_REPLACE_VIEW,self.refreshUI,self)
    EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE,self.tihuanIsShowRed,self)

   
end
function WelfareShopView:refreshUI()
	self:delayCall(function ()
		self:initData()
		self:refreshbuttonInfo()
	end,0.1)
	self:tihuanIsShowRed()
end

function WelfareShopView:updateWinthActInfo(actData)

end


function WelfareShopView:initData()
	--从服务器获得福利商店数据


	local datas = ShopModel:getShopItemList(FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP)
		-- dump(datas,"商店数据",8)


	local newdata = self:todoData(datas)
	self:addscollelist(newdata)
end
function WelfareShopView:todoData(datas)
	local arrtable = {}
	for i=1,#datas do
		arrtable[i] = {}
		local goodsinfo = FuncShop.getGoodsInfo(nil,datas[i].id)
		local costtable  = string.split(goodsinfo.cost[1], ",")
		arrtable[i].cost = tonumber(costtable[2])
		arrtable[i].award = {}
		arrtable[i].award[1] = "1,"..goodsinfo.itemId..","..goodsinfo.goodsNumber
		arrtable[i].buyTimes = datas[i].buyTimes
		arrtable[i].goodsid = datas[i].id
	end
	return arrtable
end
function WelfareShopView:addscollelist(data)

	if data == nil then
		return
	end
	self.data = data
	self.panel_1:visible(false)
	local rewardArray =  {} --{{1},{2},{3},{4},{5},{6}}
	-- dump(data,"商店数据")
	for k,v in pairs(self.data) do
		k = tonumber(k) 
		rewardArray[k] = {}
		rewardArray[k][1] = v.award[1]
		rewardArray[k][2] = v.cost
		rewardArray[k][3] = tonumber(k)
		rewardArray[k][4] = v.goodsid
	end

	-- dump(rewardArray)
	local createFunc_shop = function (itemdata)
		local itemView = UIBaseDef:cloneOneView( self.panel_1 )
		self:updateItem(itemView, itemdata)
		return itemView
	end
	local updateFunc_shop = function (itemdata,view,index)
		self:updateItem(view,rewardArray[index])
	end

	local newparams = {
		{
			data = rewardArray,
			createFunc = createFunc_shop,
			-- updateCellFunc = updateFunc_shop,
			perNums=3,
			offsetX = 5,
			offsetY = 35,
			itemRect = {x=0,y=-210,width=180,height = 200},
			perFrame = 0,
			heightGap = 0
		}
	}
	self.scroll_list:cancleCacheView();
	self.scroll_list:styleFill(newparams)
	-- self.scroll_list:setCanScroll(false)
end
function WelfareShopView:updateItem( View,itemData )
	-- dump(itemData,"22222222222222222222")
	local node = display.newNode()
	node:setContentSize(cc.size(174, 190))
	node:setPositionY(20)
	node:anchor(0,1)
	View:addChild(node)
	View.scale9_1:visible(false)
	View.panel_tihuan:visible(false)
	local reward = string.split(itemData[1], ",")
	local rewardType = tonumber(reward[1])
	local costnumber  = itemData[2]
	local rewardId  = reward[2]
	local itemnumber = reward[3]
	local  lotteryRewardView1 = View.UI_1
    lotteryRewardView1:setResItemData({reward = itemData[1]})

	lotteryRewardView1:showResItemName(false)



	local name = nil
	local itemDatas = nil
	local quality = 1
	if rewardType == 1 then
		itemDatas = FuncItem.getItemData(rewardId)
		name = GameConfig.getLanguage(itemDatas.name)
		-- quality = itemDatas.quality
	elseif rewardType == 10 then
		itemDatas = FuncTreasure.getTreasureAllConfig()[tostring(rewardId)]

		name = GameConfig.getLanguage(itemDatas.name)
		-- quality = itemDatas.quality
	elseif rewardType == 18 then
		itemDatas = FuncPartner.getPartnerById(rewardId)
		name = GameConfig.getLanguage(itemDatas.name)
		-- quality = itemDatas.initQuality
	end
	local number = UserModel:goldConsumeCoin()
	

	local lingshinumber = tonumber(self:ServerLingShiNumber()) --灵石数量  ---TODO
	if lingshinumber >= tonumber(costnumber) then
		-- View.txt_1:setColor(FuncWelfare.HEXtoC3b("0xfff5e6"))
		View.txt_1:setColor(cc.c3b(132,72,32))
	else
		View.txt_1:setColor(cc.c3b(255,0, 0))
	end
	-- echo("===========quality========",quality)
	View.mc_color:showFrame(quality)
	View.mc_color:getViewByFrame(quality).txt_1:setString(name) --品质and名称

	View.txt_1:setString(costnumber)

	local shoptype = FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP
	local shopdata = ShopModel:getShopItemList(shoptype)
	-- dump(shopdata)
	-- echo("===================SelectType============tonumber(itemData[3])==============",SelectType,tonumber(itemData[3]))
		if shopdata[tonumber(itemData[3])].buyTimes ~= 0 then
			View.scale9_1:visible(true)
			View.panel_tihuan:visible(true)
		else
			View.scale9_1:visible(false)
			View.panel_tihuan:visible(false)
		end

	node:setTouchedFunc(c_func(self.beginFunc, self,itemData),nil,false,nil,nil)
end
function WelfareShopView:beginFunc(itemData)
	local reward = string.split(itemData[1], ",")
	local rewardType = tonumber(reward[1])
	local costnumber  = itemData[2]
	local rewardId  = reward[2]
	local itemnumber = reward[3]
	local shoptype = FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP
	local shopdata = ShopModel:getShopItemList(shoptype)

	local  costInfo = FuncDataResource.RES_TYPE.LINGSHI..","..costnumber
	local buyTimes = shopdata[tonumber(itemData[3])].buyTimes

	-- local beginFunc  = function ()
		if buyTimes == 0 then
				local params = {
				itemId = rewardId,
				costInfo = costInfo,
				viewType = FuncItem.ITEM_VIEW_TYPE.SHOP,
				itemNum = itemnumber,
				okAction = c_func(self.sendsureButton,self,itemData),
				closeManual = false, 
			}
			WindowControler:showWindow("CompGoodItemView",  params)
		else
			WindowControler:showTips(GameConfig.getLanguage("#tid_welfare_001"))
		end
	-- end
end
function WelfareShopView:sendsureButton(itemData)

	local reward = string.split(itemData[1], ",")
	local rewardId  = reward[2]
	local shoptype = FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP
	local shopdata = ShopModel:getShopItemList(shoptype)
	local function _callback()
			shopdata[tonumber(itemData[3])].buyTimes = 1
			-- self:initData()
			-- self:refreshbuttonInfo()
			-- local allview =  self.scroll_list:getAllView()
			-- allview[itemData[3]].scale9_1:setVisible(true)
			-- allview[itemData[3]].panel_tihuan:setVisible(true)
			-- WindowControler:showTips("购买成功")
			FuncCommUI.startFullScreenRewardView({itemData[1]})
    end
    local cost = itemData[2] --消耗灵石的数量
    local lingshinumber = self:ServerLingShiNumber()
    if lingshinumber  < cost then
    	-- WindowControler:showTips(GameConfig.getLanguage("#tid1954"))
    	if MonthCardModel:checkLingShiShopOpen() then
			-- WindowControler:showTips("灵石不足，消费仙玉送灵石")
			WindowControler:showTips(GameConfig.getLanguage("#tid1955"))
	    	WindowControler:showWindow("MallMainView",FuncShop.SHOP_TYPES.MALL_XINANDANG)
	    	return
    	else
    		-- WindowControler:showTips("灵石不足,激活彩衣献礼,消费仙玉送灵石")
    		WindowControler:showTips(GameConfig.getLanguage("#tid1954"))
	    	WindowControler:showWindow("MonthCardMainView",FuncMonthCard.CARDYEQIAN[FuncMonthCard.card_caiyi])
	    	return
    	end
    end

    local shoptype = FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP
    --发送购买协议
    -- 商店类型 道具id ,key 第几个道具
    ShopServer:buyGoods(shoptype,itemData[4], itemData[3],_callback)

end
--刷新需要数量刷新
function WelfareShopView:refreshbuttonInfo()
	local costid,costnumber = self:refreshCostnumber()
	local refreshnumber = tonumber(FuncDataSetting.getOriginalData("RefreshNum3"))
	local doingtimes = self:ServerRefreshNumber()   ---刷新次数
	local sumtimes = 0--CountModel:getLotterymanyrefreshCount()
	if refreshnumber - doingtimes >= 0 then
		sumtimes = refreshnumber - doingtimes
	end
	-- echo("======doingtimes============",doingtimes,costnumber)
	-- self.txt_1:setString("刷新消耗:"..costnumber)  ---消耗
	-- self.txt_2:setString("剩余刷新次数:"..sumtimes.."/"..refreshnumber)  --次数
	local shopId = FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP
	local timeToShow =  ShopModel:getNextRefreshTime(shopId )
	self.txt_3:setString(GameConfig.getLanguage("tid_shop_1020")..fmtSecToHHMM(timeToShow))
end

---获得第几次的刷新数据
function WelfareShopView:refreshCostnumber()
	local shopId = FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP
	local times = self:ServerRefreshNumber()   ---刷新次数
	local costtable = FuncShop.getRefreshCost( shopId,times+1 ) --刷新消费
	local cost = string.split(costtable, ",")
	local costid = cost[1]
	local costnumber = cost[2]
	return costid,tonumber(costnumber)
end

--服务器刷新的次数
function WelfareShopView:ServerRefreshNumber()
	local  refreshnumbers = CountModel:getLotterymanyrefreshCount()
	return refreshnumbers
end
--灵石的服务器数量
function WelfareShopView:ServerLingShiNumber()
	local  lingshinumbers = UserModel:goldConsumeCoin()
	return lingshinumbers
end


function WelfareShopView:refreshButton()
	local costid,costnumber = self:refreshCostnumber()
	local refreshnumber = tonumber(FuncDataSetting.getOriginalData("RefreshNum3"))   --当天次数
	local doingtimes =	self:ServerRefreshNumber()   ---刷新次数 --服务器次数
	if refreshnumber - doingtimes <= 0 then 
		WindowControler:showTips(GameConfig.getLanguage("#tid_welfare_003"))
		return
	end

	-- local lingshi =  self:ServerLingShiNumber()
	-- if lingshi < costnumber then
	-- 	WindowControler:showTips("灵石不足，无法购买")
	-- 	return
	-- end
	-- ---发送刷新协议
	-- local shoptype = FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP
	-- NewLotteryServer:Refreshbutton(shoptype,c_func(self.refreshUI, self))

	local shoptype = FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP
	local status = ShopModel:getLoginAttentionStatus(shoptype)
	if status then
		ShopModel:onBtnRefreshTap(shoptype)
	else
		WindowControler:showWindow("ShopRefreshView", shoptype)
	end
end

function WelfareShopView:refreshDataUI(result)
	if not result.result then
		return
	end
	--TODO
	dump(result.result,"刷新返回数据",6)
	-- local shopdata = result.result.data.dirtyList.u.shops
	-- if shopdata ~= nil then
		-- self:initData()
		-- self:refreshbuttonInfo()

	-- end
	-- WindowControler:showTips("刷新成功")
end

function WelfareShopView:press_btn_close()
    self:startHide()
end



return WelfareShopView
--[[
unction 'call'
 "刷新返回数据" = {
     "id"     = 2000003
     "method" = 1604
     "result" = {
         "data" = {
             "dirtyList" = {
                 "u" = {
                     "_id"     = "dev_7006"
                     "counts" = {
                         "36" = {
                             "count"      = 1
                             "expireTime" = 1483732800
                             "id"         = "36"
                         }
                     }
                     "finance" = {
                         "coin" = 60000
                     }
                     "shops" = {
                         "7" = {
                             "goodsList" = {
                                 1 = {
                                     "id" = "6"
                                 }
                                 2 = {
                                     "id" = "2"
                                 }
                                 3 = {
                                     "id" = "6"
                                 }
                                 4 = {
                                     "id" = "14"
                                 }
                                 5 = {
                                     "id" = "14"
                                 }
                                 6 = {
                                     "id" = "7"
                                 }
                             }
                             "lastFlushTime" = 1483702937
                         }
                     }
                 }
             }
         }
         "serverInfo" = {
             "serverTime" = 1483702937482
         }
     }
 }
 --]]