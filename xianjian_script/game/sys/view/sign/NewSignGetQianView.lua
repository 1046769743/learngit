--[[
	Author: lichaoye
	Date: 2017-05-11
	中签-view
]]

local NewSignGetQianView = class("NewSignGetQianView", UIBase)

function NewSignGetQianView:ctor( winName, params )
	NewSignGetQianView.super.ctor(self, winName)
	-- self.datas = {level = 1, reward = "1,1019,1"}
	-- self.datas = params
	self.datas = NewSignModel:getSignReward()
	-- 后端是从0开始的
	self.datas.level = tonumber(self.datas.level) + 1
end

function NewSignGetQianView:registerEvent()
	NewSignGetQianView.super.registerEvent(self)
	-- EventControler:addEventListener(LineUpEvent.PRAISE_LIST_UPDATE_EVENT, self.updateUI, self)
    self.panel_1.btn_1:setTap(c_func(self.press_btn_close, self))
end

function NewSignGetQianView:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()
	self:updateUI()
	self.ctn_texiao:removeAllChildren()

	

	if self.datas.level == 1 then
		-- 上上签
		self.showAni = self:createUIArmature("UI_newsign","UI_newsign", self.ctn_texiao, false, GameVars.emptyFunc)
		FuncArmature.changeBoneDisplay(self.showAni, "node_001", self.panel_1.txt_1)
		FuncArmature.changeBoneDisplay(self.showAni, "node_002", self.panel_1.txt_2)
		FuncArmature.changeBoneDisplay(self.showAni, "node_003", self.panel_1.txt_3)
		FuncArmature.changeBoneDisplay(self.showAni, "node_004", self.panel_1.UI_1)
		FuncArmature.changeBoneDisplay(self.showAni, "node_005", self.panel_1.txt_name)
		FuncArmature.changeBoneDisplay(self.showAni, "node_006", self.panel_1.btn_1)
		FuncArmature.changeBoneDisplay(self.showAni, "layer2h", self.panel_1.mc_1)
		self.panel_1.mc_1:showFrame(1)
		self.panel_1.mc_1:setPosition(0,0)
		self.panel_1.txt_1:setPosition(-25,90)
		self.panel_1.txt_2:setPosition(-20,85)
		self.panel_1.txt_3:setPosition(-20,85)
		self.panel_1.UI_1:setPosition(-40,40)
		self.panel_1.txt_name:setPosition(-165,35)
		self.panel_1.btn_1:setPosition(-68,30)

		self.showAni:registerFrameEventCallFunc(30,1,function () 
			self.showAni:playWithIndex(1,true)
		end)
		
	else
		-- 其他签
		self.panel_1.mc_1:showFrame(self.datas.level)
		self.showAni = self:createUIArmature("UI_newsign","UI_newsign_02", self.ctn_texiao, false, GameVars.emptyFunc)
		FuncArmature.changeBoneDisplay(self.showAni, "node_001", self.panel_1.txt_1)
		FuncArmature.changeBoneDisplay(self.showAni, "node_002", self.panel_1.txt_2)
		FuncArmature.changeBoneDisplay(self.showAni, "node_003", self.panel_1.txt_3)
		FuncArmature.changeBoneDisplay(self.showAni, "node_004", self.panel_1.UI_1)
		FuncArmature.changeBoneDisplay(self.showAni, "node_005", self.panel_1.txt_name)
		FuncArmature.changeBoneDisplay(self.showAni, "node_006", self.panel_1.btn_1)
		FuncArmature.changeBoneDisplay(self.showAni, "node_qian", self.panel_1.mc_1)

		self.panel_1.mc_1:setPosition(0,0)
		self.panel_1.txt_1:setPosition(-25,90)
		self.panel_1.txt_2:setPosition(-20,85)
		self.panel_1.txt_3:setPosition(-20,85)
		self.panel_1.UI_1:setPosition(-40,45)
		self.panel_1.txt_name:setPosition(-165,38)
		self.panel_1.btn_1:setPosition(-68,30)
		
		self.showAni:registerFrameEventCallFunc(20,1,function () 
			self.showAni:playWithIndex(1,true)
		end)
	end
	
	self:registClickClose("out")
	-- 伪造广播
	self:initFalseBroadList()
end

-- 伪造广播
function NewSignGetQianView:initFalseBroadList()
	-- 伪造广播
	if tonumber(self.datas.level) == 1 then
		local falseData = {
			{
				name = UserModel:name(),
				type = self.datas.tType,
				reward = self.datas.reward,
				time = TimeControler:getServerTime(),
			}
		}
		NewSignModel:udpateBroadList(falseData, false)
	end
	EventControler:dispatchEvent(NewSignEvent.SIGN_FINISH_EVENT)
end

-- 适配
function NewSignGetQianView:setViewAlign()
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyone, UIAlignTypes.LeftBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyfive, UIAlignTypes.RightBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.MiddleBottom)
end

function NewSignGetQianView:updateUI()
	-- 底
	self.panel_1.mc_1:showFrame(self.datas.level)
	-- 
	-- local ctn = self.mc_1.currentView.ctn_1
	-- ctn:removeAllChildren()
	-- local sp = display.newSprite(FuncNewSign.getGetQianBg(self.datas.level))
	-- sp:addTo(ctn):anchor(0, 1)
	-- 文字
	local title,des1,des2 = FuncNewSign.getSignDes( self.datas.level )
	local view = self.panel_1
	view.txt_1:setString(title)
	view.txt_2:setString(des1)
	view.txt_3:setString(des2)

	view.UI_1:setResItemData(self.datas)
	-- self.UI_1:showResItemName(true, true)
	-- 名字
	view.txt_name:setString(FuncCommon.getNameByReward( self.datas.reward ))

	local reward = string.split(self.datas.reward, ",")
	local rewardType = reward[1]
	local rewardNum = reward[#reward]
	local rewardId = reward[#reward - 1]

	FuncCommUI.regesitShowResView(view.UI_1, rewardType, rewardNum, rewardId, self.datas.reward, true, true)
end

function NewSignGetQianView:press_btn_close()
	NewSignModel:clearSignReward()
	self:startHide()
end

return NewSignGetQianView