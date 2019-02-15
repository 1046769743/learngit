--
--Author:      zhuguangyuan
--DateTime:    2017-12-23 16:17:57
--Description: 扫荡商店
--

local TowerSweepShopView = class("TowerSweepShopView", UIBase);

function TowerSweepShopView:ctor(winName)
    TowerSweepShopView.super.ctor(self, winName)
end

function TowerSweepShopView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerSweepShopView:registerEvent()
	TowerSweepShopView.super.registerEvent(self);
end

-- ===============================================================
-- 获取扫荡数据
function TowerSweepShopView:initData()
	if not self._tempFloor then
		self._tempFloor = 1
	end
	self.buffItemDataList = {} --TowerMainModel:getSweepShopsBuff()

	self:updateData(self._tempFloor)
end

-- 更新扫荡的商店数据
function TowerSweepShopView:updateData()
	-- 获取扫荡商店的buff列表数据
	local oldShopIds = self.shopIdList
	local oldBuffs = self.buffItemDataList
	self.shopIdList,self.buffItemDataList = TowerMainModel:getNextFloorBuffList(self._tempFloor)
	-- dump(self.shopIdList, "________________ 处理前 self.shopIdList")
	-- dump(self.buffItemDataList, "________________ 处理前 self.buffItemDataList")	
	if table.length(self.shopIdList) == 1 then
		echo("_________ table.length(self.shopIdList) == 1 __________")
		local leftShopId = self.shopIdList[1]
		local leftBuffs = self.buffItemDataList
		local oldShopId = nil
		self.shopIdList = oldShopIds
		self.buffItemDataList = oldBuffs

		-- dump(self.shopIdList, "________________ 处理中1 self.shopIdList")
		-- dump(self.buffItemDataList, "________________ 处理中1 self.buffItemDataList")	

		for k,v in pairs(self.shopIdList) do
			if tostring(v) ~= tostring(leftShopId) then
				oldShopId = tostring(v)
			end
		end
		for k,v in pairs(self.buffItemDataList) do
			if tostring(v.shopId) == tostring(oldShopId) then
				v.haveBoughtNum = 1
			else
				for kk,vv in pairs(leftBuffs) do
					if vv.buffId == v.buffId then
						v.haveBoughtNum = vv.haveBoughtNum
					end
				end
			end
		end
	end
		-- dump(self.shopIdList, "________________ 处理中2 self.shopIdList")
		-- dump(self.buffItemDataList, "________________ 处理中2 self.buffItemDataList")	

	while(table.isEmpty(self.buffItemDataList)) and (self._tempFloor<10) do
		self._tempFloor = self._tempFloor + 1
		self.shopIdList,self.buffItemDataList = TowerMainModel:getNextFloorBuffList(self._tempFloor)
	end
	
	-- 按照消耗的葫芦数量进行排序
	FuncTower.sortBuffItems(self.buffItemDataList)
	dump(self.shopIdList, "________________ 处理后 self.shopIdList")
	dump(self.buffItemDataList, "________________  处理后 self.buffItemDataList")
	if not self.buffItemDataList or empty(self.buffItemDataList) then
		self:press_btn_close()
	end

end

-- 排序
function TowerSweepShopView:sortBuffItems(data)
	table.sort(data,function(a,b)
		local aCost = FuncTower.getShopBuffData(a).cost
		local bCost = FuncTower.getShopBuffData(b).cost

		-- 先按照类型排序
		if aCost < bCost then
			return true
		end
		return false
    end)
end

-- ===============================================================
function TowerSweepShopView:initView()
	-- self.UI_1.txt_1:setString("封魔补给")
	-- 点击弹出buff列表界面
	self.btn_plus:setTouchedFunc(c_func(self.showBuffList,self))
	self:updateUI()
end

-- 展示购买的buff
function TowerSweepShopView:showBuffList()
	WindowControler:showWindow("TowerBuffListView")
end

function TowerSweepShopView:updateUI()
	local allBuff = TowerMainModel:getAllShopsBuff()
	local nowBuffShopNum = table.length(allBuff)
	-- local currentView = self.btn_1:getCurFrameView()
	if nowBuffShopNum <= 2 then
		self.btn_back:setVisible(true)
		self.btn_back:setTouchedFunc(c_func(self.press_btn_close,self))
		self.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_055")) 
		self._isFinished = true
		self.btn_1:setTouchedFunc(c_func(self.checkNextShop,self,self._isFinished))
	else
		self.btn_back:setVisible(false)
		self.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_056"))
		self._isFinished = false
		self.btn_1:setTouchedFunc(c_func(self.checkNextShop,self,self._isFinished))
	end
	
	local function callBackFunc()
		self:updateBuffBuyStatus()
	end
	local buffNum = #self.buffItemDataList
	for i=1,buffNum do
		local buffUI = self["btn_gezi_"..i]  
		local buffId = self.buffItemDataList[i].buffId 
		local shopId = self.buffItemDataList[i].shopId
		if i == buffNum then
			self:updateOnePanelItem( shopId,buffId,buffUI ,callBackFunc)
		else
			self:updateOnePanelItem( shopId,buffId,buffUI )
		end
	end

	-- 更新怒气值
	local curEnergy = TowerMainModel:getCurEnergy()
	local maxEnergy = TowerMainModel:getMaxEnergy()
    self:setEnergyNum(self.panel_nuqi.panel_nuqizhi.mc_1,curEnergy)
    self:setEnergyNum(self.panel_nuqi.panel_nuqizhi.mc_2,maxEnergy)
    if curEnergy < 10 then
     	if not self.offsetX then
    		self.offsetX = self.panel_nuqi.panel_nuqizhi:getPositionX()
    	end
    	self.panel_nuqi.panel_nuqizhi:setPositionX(self.offsetX - 13)
    end
end

function TowerSweepShopView:setEnergyNum(mcView,num)
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
        -- --如果是数字1
        -- if v == 1 then
        --     offsetx = offsetx - self.numeOneOffset 
        -- end
        -- local xpos = (k-1) * self.perWidth + offsetx + self.initOffset
        -- local childCtn = mcs["ctn_" .. tostring(k)]
        -- if v == 1 then
        --     offsetx = offsetx - self.numeOneOffset 
        -- end
        -- childMc:setPositionX(xpos)
        -- childCtn:setPositionX(xpos)
    end
end


function TowerSweepShopView:updateBuffBuyStatus()
	if self.buffItemDataList then
		local buffNum = #self.buffItemDataList
		for i = 1,buffNum do
			local _data = self.buffItemDataList[i]
			-- dump(_data, "self.buffItemDataList[i]")
			-- dump(self.buffBtnMap, "self.buffBtnMap")
			local buffUI = self.buffBtnMap[_data.shopId.."_".._data.buffId]
			if buffUI then
				if tonumber(_data.haveBoughtNum) == 0 then
				 	buffUI:getUpPanel().panel_yinzhang:visible(false)
				else
					buffUI:getUpPanel().panel_yinzhang:visible(true)
					buffUI:enabled(false)
				end 
			end
		end
	end
	
	local nowStarNum = TowerMainModel:getCurOwnStarNum()
	self.panel_xxb.txt_2:setString(nowStarNum)
end



-- ===============================================================
-- 关闭当前商店
-- 检查是否有下一个商店
function TowerSweepShopView:checkNextShop(_isFinished)
	local delayTime = 0.1
	local  function _gotBuffCallBack( serverData )
		if serverData.error then
		else
			TowerMainModel:updateData(serverData.result.data)
		end	
	end

	if TowerMainModel:isNowHasShop(self.shopIdList[1]) then
		delayTime = delayTime + 0.2
		local params = {
			buffId = "0",
			shopId = self.shopIdList[1]
		}
		TowerServer:getSweepBuff(params,c_func(_gotBuffCallBack))	
	end
	if TowerMainModel:isNowHasShop(self.shopIdList[2]) then
		delayTime = delayTime + 0.2
		local params = {
			buffId = "0",
			shopId = self.shopIdList[2]
		}
		TowerServer:getSweepBuff(params,c_func(_gotBuffCallBack))
	end

	local function delaycallFunc( ... )
		if _isFinished then
			self:startHide()
		else
			-- 下一层商店
			self._tempFloor = self._tempFloor + 1
			self:updateData()
			self:updateUI()
		end
	end
	self:delayCall(c_func(delaycallFunc),delayTime)
end

-- 更新商店的一个buff的显示 
function TowerSweepShopView:updateOnePanelItem( _shopId,_itemId,_itemView,_callbackFunc )
	local buffId = _itemId
	local buffData = FuncTower.getShopBuffData(buffId)
	local buffDesc = buffData.tid
	local shopBuffUI = _itemView
	shopBuffUI:getUpPanel().mc_1:showFrame(buffData.color)
	shopBuffUI:getUpPanel().mc_zi:showFrame(buffData.color)
	shopBuffUI:getUpPanel().panel_yinzhang:visible(false)

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
		shopBuffUI:setTouchedFunc(c_func(self.getSweepShopBuff,self,_shopId,buffId,shopBuffUI))
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
	elseif buffData.magicUp then
		shopBuffUI:getUpPanel().mc_1:showFrame(4)
		shopBuffUI:getUpPanel().mc_zi:showFrame(4)
		shopBuffUI:setTouchedFunc(c_func(self.getSweepShopBuff,self,_shopId,buffId,shopBuffUI))
	end		

	shopBuffUI:getUpPanel().txt_3:setString(buffData.cost)
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
	if not self.buffBtnMap then
		self.buffBtnMap = {}
	else
		self.buffBtnMap[_shopId.."_"..buffId] = shopBuffUI
	end
	if _callbackFunc then
		_callbackFunc()
	end
end

-- 购买id 为BuffId 的buff
function TowerSweepShopView:getSweepShopBuff(_shopId,BuffId,view)
	-- WindowControler:setUIClickable(false)
	local buffData = FuncTower.getShopBuffData(BuffId)
	local nowStarNum = TowerMainModel:getCurOwnStarNum()
	if buffData.cost > nowStarNum then
		WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_042"))
		-- WindowControler:setUIClickable(true)
		return
	else
		local params = {
			buffId = tostring(BuffId),
			shopId = _shopId,
		}
		-- if not view:getUpPanel().ctn_effect then
			-- echoError("____特效ctn为空,清检查falsh资源是否正确 _____________")
			TowerServer:getSweepBuff(params,c_func(self.getBuffCallback,self))
		-- else
			-- WindowControler:setUIClickable(false)
			local btnAni = self:createUIArmature("UI_suoyaota_b","UI_suoyaota_b_lingqujiangli",view:getUpPanel().ctn_effect,false, function()
				-- WindowControler:setUIClickable(true)
				-- TowerServer:getSweepBuff(params,c_func(self.getBuffCallback,self))
			end)
			btnAni:pos(-13,0)
			FuncArmature.setArmaturePlaySpeed(btnAni,1.5) 
		-- end
	end
end
function TowerSweepShopView:getBuffCallback(serverData)
	--更改当前界面状态
    -- WindowControler:setUIClickable(true)
	if serverData.error then 
		local errorInfo = serverData.error
		if tonumber(errorInfo.code) == 261101 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_044"))
        end	
    else   
		TowerMainModel:updateData(serverData.result.data)
	end
	self:checkBuffSellOut() 
end
function TowerSweepShopView:checkBuffSellOut()
	if not TowerMainModel:isNowHasShop(self.shopIdList[1]) 
		and not TowerMainModel:isNowHasShop(self.shopIdList[2]) then
		echo("_______ 该层已经买完 _______")
		if self._isFinished then
			self:startHide() 
		else
			-- 下一层商店
		
			echo("_______ 该层已经买完  下一层商店_______")

			self._tempFloor = self._tempFloor + 1
			self:updateData()
			self:updateUI()
		end
	else
		echo("_______ 该层没有买完 _______")
		self:updateData()
		self:updateBuffBuyStatus()
	end	
end

function TowerSweepShopView:initViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_gezi_1, UIAlignTypes.Left);
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_gezi_2, UIAlignTypes.Left);
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_gezi_3, UIAlignTypes.Left);
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_gezi_4, UIAlignTypes.Right);
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_gezi_5, UIAlignTypes.Right);
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_gezi_6, UIAlignTypes.Right);

	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop);
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_plus, UIAlignTypes.Bottom);
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_nuqizhi, UIAlignTypes.Bottom);
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_xxb, UIAlignTypes.RightBottom);
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_bt, UIAlignTypes.MiddleTop);
end


function TowerSweepShopView:press_btn_close()
	self:startHide()
end

function TowerSweepShopView:deleteMe()
	-- TODO
	TowerSweepShopView.super.deleteMe(self);
end

return TowerSweepShopView;
