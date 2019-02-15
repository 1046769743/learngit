--[[
	Author: lichaoye
	Date: 2017-05-04
	魂匣主界面
]]
local NewLotterySoulView = class("NewLotterySoulView", UIBase)

function NewLotterySoulView:ctor( winName )
	NewLotterySoulView.super.ctor(self, winName)
	self._playing = false
end

function NewLotterySoulView:registerEvent()
	NewLotterySoulView.super.registerEvent(self)
	-- EventControler:addEventListener(LineUpEvent.PRAISE_LIST_UPDATE_EVENT, self.updateUI, self)
    self.panel_buyone.btn_1:setTap(c_func(self.press_btn_close, self))
end

function NewLotterySoulView:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()
	self:updateUI()
end

-- 适配
function NewLotterySoulView:setViewAlign()
   FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyone, UIAlignTypes.LeftBottom)
   FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyfive, UIAlignTypes.RightBottom)
   FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.MiddleBottom)
end

function NewLotterySoulView:updateUI()
	self:updateCenter()
	self:updateBtn()
	-- 创建隔离层
	self:initMaskLayer()
end

function NewLotterySoulView:initMaskLayer()
	local nd = display.newNode():size(GameVars.width, GameVars.height):addTo(self._root):zorder(100)
	nd:anchor(0, 1)
	nd:pos(GameVars.UIbgOffsetX, GameVars.UIbgOffsetY)
	self._maskLayer = nd
end

function NewLotterySoulView:showMask()
	if not self._maskLayer then
		self:initMaskLayer()
	end
	self._maskLayer:setTouchedFunc(function()
	end,nil,true)
	EventControler:dispatchEvent(NewLotteryEvent.START_LOTTERY, {noBgAction = true})
end

function NewLotterySoulView:hideMask()
	if self._maskLayer then
		self._maskLayer:setTouchEnabled(false)
	end
	EventControler:dispatchEvent("RUNACTION_START_NEWLOYYERY", {noBgAction = true})
end

function NewLotterySoulView:playRolling()
	local ctn = self.ctn_texiao
	ctn:removeAllChildren()
	
	self._playing = true
	self:showMask()
	self.iconAnim = self:createUIArmature("UI_chouka_d","UI_chouka_d_sixiangliuguang", ctn, false, function ()
		-- if not NewLotteryModel:getSoulReward() then
		-- 	WindowControler:showWindow("NewLotterySoulRewardView")
		-- else
		-- 	WindowControler:showTips("没有抽奖数据")
		-- end
		self._playing = false
		self:hideMask()
	end)

	self.iconAnim:registerFrameEventCallFunc(115,1,function()
		if NewLotteryModel:getSoulReward() then
			WindowControler:showWindow("NewLotterySoulRewardView")
		else
			WindowControler:showTips(GameConfig.getLanguage("#tid_chouka_024")) 
		end
	end)

	self.iconAnim:pos(self.iconAnim:getPositionX(), self.iconAnim:getPositionY() - 10)
end

function NewLotterySoulView:goToReward(consume,times)
	if UserModel:getGold() < consume*times then
		WindowControler:showTips(GameConfig.getLanguage("tid_common_1001"))  
		return 
	end
	-- 点的时候判断一下活动开没开
	local LotterySoulData = FuncNewLottery.getMyServerLotterySoulData()
	if LotterySoulData then
		self:playRolling()
		NewLotteryServer:requestSoulDrawCard(times, LotterySoulData.id, function ()
		    -- WindowControler:showWindow("NewLotterySoulRewardView")
		end)
	else
		echoError("活动没开啊")
	end
end

function NewLotterySoulView:updateBtn()
	local consume = tonumber(FuncDataSetting.getDataByConstantName("LotteryBoxConsume"))
	-- 左侧
	self.panel_buyone.txt_1:setString(consume)
	-- 右侧
	self.panel_buyfive.txt_1:setString(consume*5)
	-- 获取本服魂匣信息
	-- local LotterySoulData = FuncNewLottery.getMyServerLotterySoulData()
	-- if not LotterySoulData then echoError("活动没开啊") return end

	self.panel_buyone.btn_1:setTap(function()
		if not self._playing then
			self:goToReward(consume,1)
		end
	end)

	self.panel_buyfive.btn_1:setTap(function()
		if not self._playing then
			self:goToReward(consume,5)
		end
	end)
end

function NewLotterySoulView:updateCenter()
	-- 获取本服魂匣信息
	local LotterySoulData = FuncNewLottery.getMyServerLotterySoulData()
	if not LotterySoulData then echoError("活动没开啊") return end
	
	local partners = LotterySoulData.partner
	local outPanel = self
	for i,v in ipairs(partners) do
		local panel = outPanel["ctn_" .. i]
		if tonumber(v) ~= 0 and panel then
			panel:visible(true)
			-- 伙伴的表格
		    -- local _partnerInfo = FuncPartner.getPartnerById(v)
		    local _sprite = FuncPartner.getHeroSpine(v)
		    _sprite:setScaleX(-1)
		    panel:removeAllChildren()
		    panel:addChild(_sprite)

		    -- 触摸层
		    local panel_click = display.newNode()
		    panel_click:anchor(0.5, 0)
		    panel_click:size(80, 150)
		    panel_click:addTo(panel)
		    panel_click:setTouchedFunc(function()
		    	echo("点人了!!!")
		    	WindowControler:showWindow("PartnerInfoUI",v)
		    end)
		    panel.panel_click = panel_click
		else
			if panel then
				panel:visible(false)
			end
		end
	end
end

function NewLotterySoulView:press_btn_close()
	self:startHide()
end

return NewLotterySoulView