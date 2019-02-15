--[[
	Author: caocheng
	Date:2017-07-31
	Description: 锁妖塔buff商店
]]
--
--Author:      zhuguangyuan
--DateTime:    2017-12-23 15:45:12
--Description: 去掉倒计时功能 将扫荡商店分离出单独界面
--


local TowerMapShopView = class("TowerMapShopView",UIBase);

function TowerMapShopView:ctor(winName,shopID,shopPos)
    TowerMapShopView.super.ctor(self,winName)
    echo("_____ 传进来的商店id _______",shopID)
   	self.shopID = shopID or "1_1"
   	self.gridPos = shopPos
   	self.buffBtnMap = {}

   	TowerMapModel:saveLocalShopInfo(shopPos.x,shopPos.y)
end

function TowerMapShopView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
	self:initBubble( self.panel_qipao )
end 

-- 弹出气泡
function TowerMapShopView:initBubble( _popupView )
	local scaleto_1 = act.scaleto(0.1,1.2,1.2)
	local scaleto_2 = act.scaleto(0.05,1.0,1.0)
	local delaytime_2 = act.delaytime(2.5)
	local scaleto_3 = act.scaleto(0.1,0)
	local delaytime_3 = act.delaytime(0.5)
	local callfun = act.callfunc(function ()
		self:updateNPCWords(_popupView)
	end)
	local seqAct = act.sequence(act.spawn(callfun,scaleto_1),scaleto_2,delaytime_2,scaleto_3,delaytime_3)
	_popupView:runAction(act._repeat(seqAct))
end
-- 更新气泡里的话
function TowerMapShopView:updateNPCWords(_popupView)
	-- _popupView.txt_1:setString(self.currentWords)
end


function TowerMapShopView:registerEvent()
	TowerMapShopView.super.registerEvent(self);
	self.btn_back:setTouchedFunc(c_func(self.press_btn_close,self))
	EventControler:addEventListener(TowerEvent.TOWEREVENT_BUYBUFF_TOWER_SUCCESS,self.UpdataNowUI,self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_CLOSE_MAP_SHOP_CONFIRMED,self.closeCurShop,self)
end

function TowerMapShopView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_bt, UIAlignTypes.MiddleTop);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_plus, UIAlignTypes.RightBottom);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_nuqi22, UIAlignTypes.RightBottom);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_xxb, UIAlignTypes.RightBottom);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_gezi_1, UIAlignTypes.Right);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_gezi_2, UIAlignTypes.Right);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_gezi_3, UIAlignTypes.Right);
end	

function TowerMapShopView:initData()
	-- 购买商店buff最少星星数量，小于改数字，关闭商店时不会弹出二次确认框
	self.minStarNum = 3

	self:updateData()
end

-- 获取商店id 和相应的buff数据列表
function TowerMapShopView:updateData()
	-- local allBuff = TowerMainModel:getAllShopsBuff()
	-- if allBuff then
	-- 	for k,v in pairs(allBuff) do
	-- 		for n,b in pairs(v) do
	-- 			if tostring(b) == "0" then
	-- 				self.shopID = k
	-- 				break
	-- 			end	
	-- 		end
	-- 	end
	-- end

	-- echo("_______self.shopID________",self.shopID)
	self.buffItemDataList = TowerMainModel:getShopsBuff(self.shopID)
	if not self.buffItemDataList then
		self:startHide()
		return
	end
	-- dump(self.buffItemDataList, "model中取得 self.buffItemDataList")
	self.map1 = {}
	for k,v in pairs(self.buffItemDataList) do
		self.map1[#self.map1 + 1] = k
	end 
	-- dump(self.map1, "排序前 self.map1")
	FuncTower.sortInnerBuffItems(self.map1)
	-- dump(self.map1, "排序后 self.map1")
end

function TowerMapShopView:initView()
	if table.length(self.buffBtnMap)>0 then
		for k,v in pairs(self.buffBtnMap) do
			self.buffBtnMap[k]:removeFromParent()
		end
		self.buffBtnMap = {}
	end

	-- 点击弹出buff列表界面
	self.btn_plus:setTouchedFunc(c_func(self.showBuffList,self))

	if self.map1 == nil then
		echoError("商店数据异常")
		local allShopBuffs = TowerMainModel:getAllShopsBuff()
		echo("self.shopID=",self.shopID)
		dump(allShopBuffs,"allShopBuffs------------------")
		self:startHide()
		return
	end

	for k,v in ipairs(self.map1) do
		local _buffUI = self["btn_gezi_"..k]  
		local _buffId = v
		self:updateOnePanelItem( _buffId,_buffUI )
	end
	self:updateBuffBuyStatus()
end

function TowerMapShopView:updateUI()
	-- WindowControler:showTips("当前buff状态")
end

-- 更新单个buff
function TowerMapShopView:updateOnePanelItem( _itemId,_itemView )
	local buffId = _itemId
	local buffData = FuncTower.getShopBuffData(buffId)
	-- dump(buffData, "buffData")
	local shopBuffUI = _itemView
	shopBuffUI:getUpPanel().mc_1:showFrame(buffData.color)
	shopBuffUI:getUpPanel().mc_zi:showFrame(buffData.color)
	shopBuffUI:getUpPanel().panel_yinzhang:visible(false)
	local buffDesc = buffData.tid

	local buffEffect = nil

	-- 加攻防属性类
	if not empty(buffData.effect) then
		buffEffect = buffData.effect[1]
		local buffName = nil
		if tonumber(buffEffect.key) == 11 or tonumber(buffEffect.key) == 12 then
			buffName = "防御"
		else	
			buffName = FuncBattleBase.getAttributeName(buffEffect.key)
		end	
		if buffData.target == 2 then
			buffName = ""..buffName
		else
			buffName = "单体"..buffName
		end
 		shopBuffUI:getUpPanel().mc_1.currentView.txt_1:setString(buffName)
		shopBuffUI:setTouchedFunc(c_func(self.buyBuff,self,buffId,shopBuffUI))
		-- 是否为万分比
		if buffEffect.mode == 2 then
			if  tostring(buffEffect[1]) == "2" then
				local buffNum = buffEffect.value
				buffDesc = GameConfig.getLanguageWithSwap(buffDesc, buffNum)
				shopBuffUI:getUpPanel().mc_zi.currentView.txt_2:setString(buffDesc)
			else
				local buffNum = buffEffect.value/100
				buffDesc = GameConfig.getLanguageWithSwap(buffDesc, buffNum.."%")
				shopBuffUI:getUpPanel().mc_zi.currentView.txt_2:setString(buffDesc)
			end	
		else
			local buffNum = buffEffect.value/100
			buffDesc = GameConfig.getLanguageWithSwap(buffDesc, "+"..buffNum)
			shopBuffUI:getUpPanel().mc_zi.currentView.txt_2:setString(buffDesc)
		end		
	-- 恢复类
	elseif buffData.recovery then
		buffEffect = buffData.recovery
		local buffName = nil
		if tostring(buffEffect[1]) == "2" then
			buffName = "怒气"
			-- shopBuffUI:getUpPanel().mc_1.currentView.mc_nu:showFrame(2)
			local valueEffect = tonumber(buffEffect[3])
			local valueNum = valueEffect
			buffDesc = GameConfig.getLanguageWithSwap(buffDesc, valueNum)
			shopBuffUI:getUpPanel().mc_zi.currentView.txt_2:setString(buffDesc)
		else
			-- shopBuffUI:getUpPanel().mc_zi:showFrame(1)
			local valueEffect = tonumber(buffEffect[3])
			local valueNum = valueEffect/100
			buffDesc = GameConfig.getLanguageWithSwap(buffDesc, valueNum.."%")
			shopBuffUI:getUpPanel().mc_zi.currentView.txt_2:setString(buffDesc)
			
			if tostring(buffEffect[1]) == "1" then
				buffName = "生命"
			elseif tostring(buffEffect[1]) == "3" then
				buffName = "复活"
			end
		end	

		if tostring(buffEffect[2]) == "1" then
			buffName = "单体"..buffName
			shopBuffUI:setTouchedFunc(c_func(self.enterChooseParenter,self,buffId,shopBuffUI))
		else
			buffName = "群体"..buffName
			shopBuffUI:setTouchedFunc(c_func(self.buyBuff,self,buffId,shopBuffUI))
		end
		shopBuffUI:getUpPanel().mc_1.currentView.txt_1:setString(buffName)
	elseif buffData.magicUp then
		shopBuffUI:getUpPanel().mc_1:showFrame(4)
		shopBuffUI:getUpPanel().mc_zi:showFrame(4)
		shopBuffUI:setTouchedFunc(c_func(self.buyBuff,self,buffId,shopBuffUI))
	end	
	-- 花费
	shopBuffUI:getUpPanel().txt_3:setString(buffData.cost)

	-- 根据是否买过展示不同效果
	if	tonumber(self.buffItemDataList[buffId]) == 0 then
	 	shopBuffUI:getUpPanel().panel_yinzhang:visible(false)
	else
		shopBuffUI:getUpPanel().panel_yinzhang:visible(true)
		shopBuffUI:enabled(false)
	end 	
	-- if buffData.magicUp then
	-- 	shopBuffUI:getUpPanel().mc_zi:showFrame(2)
	-- 	-- shopBuffUI:getUpPanel().mc_zi.currentView.txt_1:setString("所有伙伴".."格挡增加"..)
	-- else
	-- 	shopBuffUI:getUpPanel().mc_zi:showFrame(1)
	-- end
	local iconPath = FuncRes.iconTowerEvent(buffData.img)
	local sp = display.newSprite(iconPath)
	sp:setScale(0.7)
	shopBuffUI:getUpPanel().ctn_1:addChild(sp)

	self.buffBtnMap[buffId] = shopBuffUI
end

-- 更新商店中buff的购买状态 及星星的剩余数量
function TowerMapShopView:updateBuffBuyStatus()
	-- 更新购买状态
	if self.buffItemDataList then
		for k,v in pairs(self.buffItemDataList) do
			local buffUI = self.buffBtnMap[k]
			if	tonumber(v) == 0 then
			 	buffUI:getUpPanel().panel_yinzhang:visible(false)
			else
				buffUI:getUpPanel().panel_yinzhang:visible(true)
				buffUI:enabled(false)
			end 	
		end	
	end
	-- 更新剩余星星数量
	local nowStarNum = TowerMainModel:getCurOwnStarNum()
	self.panel_xxb.txt_2:setString(nowStarNum)

	-- 更新怒气值
	local curEnergy = TowerMainModel:getCurEnergy()
    local maxEnergy = TowerMainModel:getMaxEnergy()
    self:setEnergyNum(self.panel_nuqi22.panel_nuqizhi.mc_1,curEnergy)
    self:setEnergyNum(self.panel_nuqi22.panel_nuqizhi.mc_2,maxEnergy)
    if curEnergy < 10 then
    	if not self.offsetX then
    		self.offsetX = self.panel_nuqi22.panel_nuqizhi:getPositionX()
    	end
    	echo("__________ self.offsetX,curEnergy,maxEnergy ___________",self.offsetX,curEnergy,maxEnergy)
    	self.panel_nuqi22.panel_nuqizhi:setPositionX(self.offsetX - 13)
    end
end

function TowerMapShopView:setEnergyNum(mcView,num)
	local valueTable = number.split(num)
    local len = table.length(valueTable)
    --不能高于2
    if len > 2 then 
        return
    end 
    mcView:showFrame(len);

    local offsetx = 0
    for k, v in ipairs(valueTable) do
        local mcs = mcView:getCurFrameView()
        local childMc = mcs["mc_" .. tostring(k)]
        childMc:showFrame(v + 1)
    end
end

-- 复活伙伴 进入伙伴选择界面
function TowerMapShopView:enterChooseParenter(BuffId,view)
	-- view:setTouchEnabled(false)
	local buffData = FuncTower.getShopBuffData(BuffId)
	local nowStarNum = TowerMainModel:getCurOwnStarNum()
	if buffData.cost > nowStarNum then
		WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_042")) 
		return
	end

	local buffData = buffData.recovery[1]
	buffData = string.split(buffData,",")
	local BuffType = buffData[1]
	if tonumber(BuffType) == 3 then
		local tempBuffData = TowerMainModel:getBruiseTeamFormation(BuffType,true,0)
		if empty(tempBuffData) then
			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_043"))
			return
		end
	end
	self.chooseView = view
	local params = {
		x = self.gridPos.x,
		y = self.gridPos.y,
	}
	WindowControler:showWindow("TowerChooseBuffTarget",FuncTower.CHOOSEHERO_TYPE.SHOP_VIEW,BuffId,params)
end

-- 购买buff
function TowerMapShopView:buyBuff(BuffId,view)
	local function _buyBuffCallback(event)
	    WindowControler:setUIClickable(true)
		if event.error then 
			local errorInfo= event.error
			if tonumber(errorInfo.code) == 261101 then
				WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_044"))
	        end	
	    else   
			TowerMainModel:updateData(event.result.data)
		end
		self:updateData()
		self:checkBuffSellOut() 
	    self:updateBuffBuyStatus()
	end

	-- WindowControler:setUIClickable(false)
	local buffData = FuncTower.getShopBuffData(BuffId)
	local nowStarNum = TowerMainModel:getCurOwnStarNum()
	if buffData.cost > nowStarNum then
		WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_042"))
		WindowControler:setUIClickable(true)
		return
	else
		local params = {}
		params.buffId = tostring(BuffId)
		-- if not view:getUpPanel().ctn_effect then
			-- echoError("____特效ctn为空,清检查falsh资源是否正确 _____________")
			params.x = self.gridPos.x
			params.y = self.gridPos.y
			TowerServer:buyShopBuff(params,c_func(_buyBuffCallback))
		-- else
			-- WindowControler:setUIClickable(false)
			local btnAni = self:createUIArmature("UI_suoyaota_b","UI_suoyaota_b_lingqujiangli",view:getUpPanel().ctn_effect,false, function()
				-- WindowControler:setUIClickable(true)
				-- params.x = self.gridPos.x
				-- params.y = self.gridPos.y
				-- TowerServer:buyShopBuff(params,c_func(_buyBuffCallback))
			end)
			FuncArmature.setArmaturePlaySpeed(btnAni,1.5) 
		-- end
	end
end

-- 侦听到 购买单体buff 消息
function TowerMapShopView:UpdataNowUI(event)
	-- if not self.chooseView:getUpPanel().ctn_effect then
		-- echoError("____特效ctn为空,清检查falsh资源是否正确 _____________")
		self:updateData()
		self:checkBuffSellOut()
		self:updateBuffBuyStatus()
	-- else
		-- WindowControler:setUIClickable(false)
		local chooseAnimation = self:createUIArmature("UI_suoyaota_b","UI_suoyaota_b_lingqujiangli",self.chooseView:getUpPanel().ctn_effect,false, function()
			-- WindowControler:setUIClickable(true)
			-- self:updateData()
			-- self:checkBuffSellOut()
			-- self:updateBuffBuyStatus()
		end)
	-- end
end

-- 检查商店中的buff是否被购买完毕
function TowerMapShopView:checkBuffSellOut()
	if not TowerMainModel:isNowHasShop(self.shopID) then
		self:startHide()
	end
end

-- 关闭商店 检查是否还存在该商店 
-- 若存在 则发送请求服务器也清除相关数据
function TowerMapShopView:press_btn_close()
	local params = {}
	params.shopId = self.shopID
	params.x = self.gridPos.x
	params.y = self.gridPos.y

	local hasShop = TowerMainModel:isNowHasShop(self.shopID)
	local starNum = TowerMainModel:getCurOwnStarNum()
	if hasShop and starNum >= self.minStarNum then
		WindowControler:showWindow("TowerChooseTipsView",FuncTower.VIEW_TYPE.RECONFIRM_TIPS_CLOSE_SHOP,params)
	else
		self:closeCurShop()
	end
end

function TowerMapShopView:closeCurShop( event )
	if not self.shopID then
		self.shopID = event.params.shopId 
		self.gridPos.x = event.params.x 
		self.gridPos.y = event.params.y 
	end 
	if not TowerMainModel:isNowHasShop(self.shopID) then
		TowerMapModel:clearLocalShopInfo()
		self:startHide()
		return 
	end

	local function clearShopcallBack( serverData )
		dump(serverData.result.data, "serverData.result.data")
	    WindowControler:setUIClickable(true)
	    if serverData.result then
	    	TowerMainModel:updateData(serverData.result.data)
			EventControler:dispatchEvent(TowerEvent.TOWEREVENT_MAP_SHOP_CLOSE,{x = self.gridPos.x,y = self.gridPos.y})
			TowerMapModel:clearLocalShopInfo()
	    end
		
		self:startHide()
	end
	local params = {
		close = 1,
		x = self.gridPos.x,
		y = self.gridPos.y,
	}
	TowerServer:buyShopBuff(params,c_func(clearShopcallBack))
end

-- 展示购买的buff
function TowerMapShopView:showBuffList()
	WindowControler:showWindow("TowerBuffListView")
end

function TowerMapShopView:startHide()
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_BUFF_SHOP_VIEW_CLOSE)
	TowerMapShopView.super.startHide(self)
end

function TowerMapShopView:deleteMe()
	self:closeCurShop()
	TowerMapShopView.super.deleteMe(self);
end



return TowerMapShopView;
