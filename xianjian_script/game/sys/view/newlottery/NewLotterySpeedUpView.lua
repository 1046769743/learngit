-- NewLotterySpeedUpView
-- 三皇台加速造物列表系统
-- 时间： 2018-3-29
-- author: Wk

local NewLotterySpeedUpView = class("NewLotterySpeedUpView",UIBase);

-- isAll  ---是不是一键加速
function NewLotterySpeedUpView:ctor(winName,isAll,_callback,singleData)
	NewLotterySpeedUpView.super.ctor(self, winName);   ---把自身当参数传入
	self.allData = NewLotteryModel:getGatherSoulData()
	self.isAll = isAll
	self._callback = _callback
	self.singleData = singleData
end

function NewLotterySpeedUpView:loadUIComplete()      -----加载UIflash文件

	self.UI_1.btn_close:setTap(c_func(self.press_btn_close,self));
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_lottery_1018"))

	self:registerEvent()
	self:registClickClose("out")
	self:updataUI()

end

function NewLotterySpeedUpView:registerEvent()
	EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.updataUI, self)
end

function NewLotterySpeedUpView:updataUI()
	self.isSelect = false  --是否显示 勾勾
	local costnum = FuncNewLottery:speedUpCreationCostItem()
	local num = 1
	if self.isAll then
		local serveTime  = TimeControler:getServerTime()
		num = 0
		for k,v in pairs(self.allData) do
			if serveTime < v.finishTime then
				num = num + 1
			end
		end
		if num == 0 then
			num = 1
		end
	end

	-- local str = GameConfig.getLanguage("#tid_lottery_1019")
	local str_1 = GameConfig.getLanguageWithSwap("#tid_lottery_1019",unpack({1}))
	self.rich_1:setString(str_1)


	-- local str = GameConfig.getLanguage("#tid_lottery_1020")
	local remainingNum = NewLotteryModel:speedUpItremData()
	if tonumber(remainingNum) >= 9999 then
		remainingNum = 9999
	end
	local str_2 = GameConfig.getLanguageWithSwap("#tid_lottery_1020",unpack({remainingNum}))
	--加速道具
	self.rich_4:setString(str_2)



	-- self.panel_gou:setTouchedFunc(c_func(self.slectGougou,self));

	-- self.panel_gou.panel_1:setVisible(self.isSelect)

	self.UI_1.mc_1:showFrame(1)
	self.UI_1.mc_1:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.sureButton,self));

	local text = self.UI_1.mc_1:getViewByFrame(1).btn_1:getUpPanel().txt_1
	local remainingNum = NewLotteryModel:speedUpItremData()
	if remainingNum <= 0 then
		text:setString(GameConfig.getLanguage("#tid_lottery_1024"))
	else
		text:setString(GameConfig.getLanguage("#tid_lottery_1025"))
	end

end

--确定按钮
--批量造物
function NewLotterySpeedUpView:sureButton()
	echo("=========批量造物==========")

	-- local data = NewLotteryModel:getGatherSoulData()
	-- local count = FuncNewLottery.getMaxCreateAllItem()
	-- dump(data,"222222222222222222222")
	-- if table.length(data) <= 0 then
	-- 	WindowControler:showTips(GameConfig.getLanguage("#tid_lottery_1013"))
	-- 	return
	-- end
	local remainingNum = NewLotteryModel:speedUpItremData()
	echo("======remainingNum========",remainingNum)
	if remainingNum <= 0 then
		-- WindowControler:showTips(GameConfig.getLanguage("#tid_lottery_1026"))
		WindowControler:showWindow("GetWayListView",FuncNewLottery.getCostItemId())
		return 
	end

	-- local isAllfinish = NewLotteryModel:allherSoulDataIsFinish()
	-- echo("========isAllfinish=========",isAllfinish)
	-- if isAllfinish then
	-- 	WindowControler:showTips("造物已全部完成,可以点击领取")--GameConfig.getLanguage("#tid_lottery_1011"))
	-- 	return
	-- end
	local allData = NewLotteryModel:getGatherSoulData()
	local serverTime = TimeControler:getServerTime() 

	local function _cllback(event)
		if event.result then
			-- dump(event.result,"=======--加速造物据数据返回=======")
			-- WindowControler:showTips(GameConfig.getLanguage("#tid_lottery_1014"))
			local reward = event.result.data.reward
			dump(reward,"=======--加速造物据数据返回=======")
			-- local newReward = {}
			-- for k,v in pairs(reward) do
			-- 	local datas = string.split(v, ",")
			-- 	table.insert(newReward,datas)
			-- end
			-- NewLotteryModel:setServerData(newReward)
			-- NewLotteryModel:removegatherSoulData()
			-- WindowControler:showWindow("NewLotteryJieGuoView")
			local pos = {}
			for k,v in pairs(allData) do
				if serverTime >=  v.finishTime then
					table.insert(pos,v.pos)
				end
			end
			table.insert(pos,self.singleData.pos)

			dump(pos,"播特效的点==111==")
			self:press_btn_close()
			-- EventControler:dispatchEvent(NewLotteryEvent.REFRESH_ZAOWU_FINISH_UI,pos)
			EventControler:dispatchEvent(NewLotteryEvent.ADD_JUHUN_EFFECT,{pos = pos ,reward = reward})
		else
			local error_code = event.error.code 
			local tip = GameConfig.getErrorLanguage("#error"..error_code)
			WindowControler:showTips(tip)
			self:press_btn_close()
		end
		if self._callback then
			self._callback()
			self:press_btn_close()
		end
		
	end
	local arrID = {}

	local params = {
		ids = {self.singleData.id},
	}
	NewLotteryServer:speedUpLottery(params,_cllback)

end

function NewLotterySpeedUpView:slectGougou()
	-- if self.isSelect then
	-- 	self.panel_gou.panel_1:setVisible(not self.isSelect)
	-- 	self.isSelect = false
	-- else
	-- 	self.panel_gou.panel_1:setVisible(not self.isSelect)
	-- 	self.isSelect = true
	-- end
	
end




function NewLotterySpeedUpView:press_btn_close()    ----点击使得该层消失
	self:startHide()
end
return NewLotterySpeedUpView


