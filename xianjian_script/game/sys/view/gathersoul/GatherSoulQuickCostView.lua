--[[
	Author: TODO
	Date:2018-07-31
	Description: TODO
]]

local GatherSoulQuickCostView = class("GatherSoulQuickCostView", UIBase);
--[[
	data = [
		needGold = 0,
		items = {
			{id = 101,needNums = 1,hasNums = 1 },
		}
		
	]

]]

function GatherSoulQuickCostView:ctor(winName,frame,data ,callBack)
    GatherSoulQuickCostView.super.ctor(self, winName)

    echo("======frame======",frame)
    self.data = data
    self.frame = frame
    self.callBack = callBack
end

function GatherSoulQuickCostView:loadUIComplete()
	self:registerEvent()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GatherSoulQuickCostView:registerEvent()
	GatherSoulQuickCostView.super.registerEvent(self);
end


function GatherSoulQuickCostView:initView()
	-- TODO
end

function GatherSoulQuickCostView:initViewAlign()
	-- TODO
end

function GatherSoulQuickCostView:initData(frame,data ,callBack)

	self.data = data
    self.frame = frame
    self.callBack = callBack
    self:updateUI()
end

function GatherSoulQuickCostView:updateUI()
	self.UI_1.mc_1:setVisible(false)
	local titleName = "#tid_lottery_title_1"
	self.UI_1.txt_1:setString(GameConfig.getLanguage(titleName))
	self.mc_1:showFrame(self.frame)
	self.UI_1.btn_close:setVisible(false)
	self.btn_1:setTap(c_func(self.pressCancleBtn,self))
	self.btn_2:setTap(c_func(self.pressSureBtn,self))

	-- 更新ui显示
	local view = self.mc_1.currentView
	local itemsInfo = self.data.items
	local isShowBtn = NewLotteryModel:checkIsQuickBuySoul(  )
	if self.frame == 1 then
		view.txt_7:setString("("..itemsInfo[1].hasNums .."/".. itemsInfo[1].needNums..")")
		view.txt_11:setString("("..itemsInfo[2].hasNums .."/".. itemsInfo[2].needNums..")")
		view.rich_1:setString("仙玉x"..self.data.needGold)
		view.scale9_1:setTouchedFunc(c_func(self.pressAutoBuyBtn,self), nil, true)
		view.panel_1:setVisible(isShowBtn)
	elseif self.frame == 2 then
		view.txt_7:setString("("..itemsInfo[1].hasNums .."/".. itemsInfo[1].needNums..")")
		view.txt_2:setString("仙玉x"..self.data.needGold)
		view.scale9_1:setTouchedFunc(c_func(self.pressAutoBuyBtn,self), nil, true)
		view.panel_1:setVisible(isShowBtn)
	elseif self.frame == 3 then
		view.txt_11:setString("("..itemsInfo[1].hasNums .."/".. itemsInfo[1].needNums..")")
		view.rich_1:setString("仙玉x"..self.data.needGold)
		view.txt_13:setTouchedFunc(c_func(self.pressAutoBuyBtn,self), nil, true)
		view.panel_1:setVisible(isShowBtn)
	elseif self.frame == 4 then
		view.txt_1:setString("聚魂符x"..itemsInfo[1].needNums)
		view.txt_3:setString("加速符x"..itemsInfo[2].needNums)
		view.panel_1:setVisible(NewLotteryModel:getIsFirstQuickSoulButton())
		view.scale9_1:setTouchedFunc(c_func(self.pressAutoSoul,self), nil, true)
	end

end


--点击自动购买
function GatherSoulQuickCostView:pressAutoBuyBtn(  )
	if  NewLotteryModel:checkIsQuickBuySoul(  ) then
		NewLotteryModel:setQuickBuySoul( false )
		self.mc_1.currentView.panel_1:setVisible(false)
	else
		NewLotteryModel:setQuickBuySoul( true )
		self.mc_1.currentView.panel_1:setVisible(true)
	end

	EventControler:dispatchEvent(NewLotteryEvent.QUICK_BUY_SOUL)


end

--点击本地登入不再提示
function GatherSoulQuickCostView:pressAutoSoul(  )
	echo("========点击本地登入不再提示=========",NewLotteryModel:getIsFirstQuickSoulButton())
	if NewLotteryModel:getIsFirstQuickSoulButton() then
		NewLotteryModel:setIsFirstQuickSoulButton(false)
		self.mc_1.currentView.panel_1:setVisible(false)
	else
		NewLotteryModel:setIsFirstQuickSoulButton(true)
		self.mc_1.currentView.panel_1:setVisible(true)
	end
end


function GatherSoulQuickCostView:pressSureBtn(  )
	echo("==========1111111111=============",self.frame)
	if self.frame == 4 then
		local isQuickBuy = NewLotteryModel:checkIsQuickBuySoul(  )
		-- echo("=====isQuickBuy======",isQuickBuy)
		if isQuickBuy then  --是自动购买  --播放动画
			local pames,data = NewLotteryModel:showGatherSoulQuickCostView()
			if data.needGold ~= 0 then
				if UserModel:getGold() <  data.needGold then
					WindowControler:showWindow("MallMainView",FuncShop.SHOP_CHONGZHI)
					return 
				end
			end
			NewLotteryServer:doQuickLottery( c_func(self.onSureServerBack,self) )
		else
			if self.data.needGold ~= 0 then
				if UserModel:getGold() <  self.data.needGold then
					WindowControler:showWindow("MallMainView",FuncShop.SHOP_CHONGZHI)
					return 
				end
			end
			if self.callBack then
				echo("4444444444444444444444")
				dump(self.data.items,"数据结构 =======")
				local isEnough = true
				if self.data.items then
					local data1 = self.data.items[1]
					local data2 = self.data.items[2]
					if data1 then
						if data1.hasNums < data1.needNums then
							isEnough = false
						end
					end
					if data2 then
						if data2.hasNums < data2.needNums then
							isEnough = false
						end
					end
				end
				if not isEnough then
					self.callBack()
				else	
					NewLotteryServer:doQuickLottery( c_func(self.onSureServerBack,self) )
				end
			end
		end
	else
		if self.data.needGold ~= 0 then
			if UserModel:getGold() <  self.data.needGold then
				WindowControler:showWindow("MallMainView",FuncShop.SHOP_CHONGZHI)
				return 
			end
		end

		NewLotteryServer:doQuickLottery( c_func(self.onSureServerBack,self) )
	end

end

function GatherSoulQuickCostView:onSureServerBack( serverInfo )
	self:pressCancleBtn()
	if not serverInfo.result then
		return
	end
	dump(serverInfo,"快速购买=========")
	local isAllfinish = NewLotteryModel:allherSoulDataIsFinish()
	local alldata = NewLotteryModel:getGatherSoulData()
	local maxCount = FuncNewLottery.getMaxCreateAllItem()
	echo("=============",table.length(alldata),isAllfinish)
	if isAllfinish or table.length(alldata) == maxCount then
		echo("========所有都完成========")
		if not isAllfinish then
			NewLotteryModel:playjuhunAction(serverInfo.result)
		end
		EventControler:dispatchEvent(NewLotteryEvent.ALLFINISH_JUHUN)
	else
		echo("========快捷购买=======")
		if self.callBack then
			self.callBack(serverInfo.result)
		end
	end

end


function GatherSoulQuickCostView:pressCancleBtn(  )
	NewLotteryModel:setIsQucikSoul()
	self:startHide()
end

function GatherSoulQuickCostView:deleteMe()
	-- TODO

	GatherSoulQuickCostView.super.deleteMe(self);
end

return GatherSoulQuickCostView;
