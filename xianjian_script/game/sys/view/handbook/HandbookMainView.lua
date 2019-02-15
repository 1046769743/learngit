--
--Author:      zhuguangyuan
--DateTime:    2018-05-22 16:09:25
--Description: 名册系统 - 册系主界面,风雷水火土攻防辅
--


local HandbookMainView = class("HandbookMainView", UIBase);

function HandbookMainView:ctor(winName)
    HandbookMainView.super.ctor(self, winName)
end

function HandbookMainView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function HandbookMainView:registerEvent()
	HandbookMainView.super.registerEvent(self);
	self.btn_back:setTap(c_func(self.onClose, self))
	self.panel_right:setTouchedFunc(c_func(self.updatePage,self,2),nil,true)
	self.panel_left:setTouchedFunc(c_func(self.updatePage,self,1),nil,true)
	-- 奇侠上阵下阵及换阵
    EventControler:addEventListener(HandbookEvent.HANDBOOK_DATA_UPDATA, self.onePartnerPosChanged, self)
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.initView, self)
    self:updatePage(1)

    self.panel_title.btn_rule:setTap(c_func(self.showHelp,self))
end

function HandbookMainView:showHelp(  )
	WindowControler:showWindow("HandbookRuleView")
end


--翻页按钮
function HandbookMainView:updatePage( index )
	self.mc_1:showFrame(index)
	if index == 1 then
		self.panel_left:visible(false)
		self.panel_right:visible(true)
	else
		self.panel_left:visible(true)
		self.panel_right:visible(false)
	end

end


-- 一个奇侠阵位发生变化的时候 会影响到两个系 可以找到奇侠所在的两个系 单独更新
-- 这里采用刷新全部的方式来刷新
function HandbookMainView:onePartnerPosChanged( event )
	self:updateAllDirsView()
end

function HandbookMainView:initData()
	-- TODO
end

function HandbookMainView:initView()
	local isInit = true
	self:updateAllDirsView(isInit)
end

-- 打开详情界面
function HandbookMainView:enterDirDetailView( dirId )
	local needLevel = FuncHandbook.getUnlockLevel( dirId )
	if UserModel:level() < needLevel then
		WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid_handbooktips_004",needLevel,FuncHandbook.dirId2Name[dirId]))
	else
		WindowControler:showWindow("HandbookOneDirDetailView",dirId) 
	end
	
end

function HandbookMainView:updateAllDirsView(isInit)
	self.panel_left.panel_red:visible(false)
	self.panel_right.panel_red:visible(false)
	local dirs = FuncHandbook.dirType
	self.orderToFrame = {
		["6"] = 1,
		["7"] = 1,
		["8"] = 1,
		["2"] = 1,
		["1"] = 2,
		["3"] = 2,
		["4"] = 2,
		["5"] = 2,

 	}

	for i=1,8 do
		local dirNode

		-- if i <= 4 then
		-- 	dirNode = self.mc_1:getViewByFrame(1)
		-- else
		-- 	dirNode = self.mc_1:getViewByFrame(2)
		-- end
		local dirId = tostring(i)
		dirNode = self.mc_1:getViewByFrame(self.orderToFrame[dirId])
		local dirView = dirNode["panel_"..dirId]
		if isInit then
			local needLevel = FuncHandbook.getUnlockLevel( dirId )
			if UserModel:level() < needLevel then
				FilterTools.setGrayFilter(dirView)
			else
				FilterTools.clearFilter(dirView)
			end
			local dirName = FuncHandbook.dirId2Name[dirId]
			dirView.txt_1:setString(dirName)
			dirView:setTouchedFunc(c_func(self.enterDirDetailView,self,dirId))
		end
		self:updateOneDirView(dirId,dirView)
	end

	-- for k,dirId in pairs(dirs) do
	-- 	local dirView = self.panel_1["panel_"..dirId]
	-- 	if isInit then
	-- 		local dirName = FuncHandbook.dirId2Name[tostring(dirId)]
	-- 		dirView.txt_1:setString(dirName)
	-- 		dirView:setTouchedFunc(c_func(self.enterDirDetailView,self,dirId))
	-- 	end
	-- 	self:updateOneDirView(dirId,dirView)
	-- end
end

-- 更新一个名册详情panelView
function HandbookMainView:updateOneDirView(dirId,dirView)
	local inplacePartnerNums = HandbookModel:getEnterFieldInOneDir( dirId )
	dirView.mc_1:showFrame(inplacePartnerNums+1)

	local userData = UserModel._data
	local power = FuncHandbook.getPowerAdditionOneDir( userData,dirId ) 
	dirView.panel_power.txt_3:setString(power)
	if power <=0 then
		dirView.panel_power:visible(false)
	else
		dirView.panel_power:visible(true)
	end


	local isHasFreePartner = HandbookModel:isShowDirRed( dirId )
	dirView.panel_red:visible(isHasFreePartner)
	if isHasFreePartner then
		if self.orderToFrame[dirId] == 1 then
			self.panel_left.panel_red:visible(true)
		elseif self.orderToFrame[dirId] == 2 then
			self.panel_right.panel_red:visible(true)
		end
	end
end

function HandbookMainView:initViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_1, UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_left, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_right, UIAlignTypes.Right)
end

function HandbookMainView:updateUI()
end

function HandbookMainView:deleteMe()
	HandbookMainView.super.deleteMe(self);
end

function HandbookMainView:onClose()
	self:startHide()
end

return HandbookMainView;
