--福利主界面
--2017-8-9 10:40
--@Author:wukai

local WelfareMinView = class("WelfareMinView", UIBase);

local NEW_SIGN_TYPE = {
	DAILYSIGN = 1, -- 每日签到
	REBATE = 2, ---三皇替换奖池  ---灵石
	TILIREAWRD = 3,--体力
}

function WelfareMinView:ctor(winName,titletype)
    WelfareMinView.super.ctor(self, winName);

    self.titletype = titletype  --or table.length(NEW_SIGN_TYPE)
    -- echo("==========titletype=========", self.titletype)

    self.lotteryView = {}
end

function WelfareMinView:loadUIComplete()
	self:disabledUIClick()

	self:registerEvent();
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_close, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.scroll_2, UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_bg, UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_2, UIAlignTypes.RightTop)
	self.mc_1:setVisible(false)
	
	self.btn_close:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);

	self:AddRightListView()
	self:showCellItmeFram()

	self:delayCall(function( )
		local _lstype = NEW_SIGN_TYPE.REBATE
		local ishave =  self:hasRedPoint(_lstype)
		if ishave then
			WindowControler:showWindow("WelfaregGtLingShiView")
		end
		self:resumeUIClick()
	end,0.3)
	


end 

function WelfareMinView:registerEvent()
	WelfareMinView.super.registerEvent();
	EventControler:addEventListener(NewLotteryEvent.REFRESH_REPLACE_VIEW,self.showCellItmeFram,self)
	EventControler:addEventListener(WelfareEvent.REFRESH_MAIN_VIEW_RED,self.showCellItmeFram,self)
	-- EventControler:addEventListener(NewSignEvent.SIGN_FINISH_EVENT, self.updateSign, self)
	-- EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, self.setButtonRedisFalse, self);
	-- EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE, self.setButtonRedisFalse, self);
end

function WelfareMinView:tableSort(arrdata)
   local  newtable = {}
   table.sort(arrdata,function(a,b)
                local rst = false
                if a.isred > b.isred then
                    rst = true
                elseif a.isred == b.isred then
                    if a.id > b.id then
                        rst = true
                    else
                        rst = false
                    end
                else
                	rst = false
                end
                return rst
        end)
   newtable = arrdata 
   return newtable
end

function WelfareMinView:AddRightListView()

	self.datalist = {}
	local index = 1
	-- for i=1,#FuncWelfare.VIEW_SYSTEM_NAME_TYPE do
	-- 	local systemname = FuncWelfare.VIEW_SYSTEM_NAME_TYPE[i]
	-- 	local isopen = FuncCommon.isSystemOpen(systemname)
	-- 	if isopen then
	-- 		local str = FuncWelfare.TYPE_TO_INDEX[i]
	-- 		self.datalist[index] = NEW_SIGN_TYPE[str]
	-- 		index = index + 1
	-- 	end
	-- end

	-- for i=#FuncWelfare.VIEW_SYSTEM_NAME_TYPE,1,-1 do
	-- 	local str = FuncWelfare.TYPE_TO_INDEX[i]
	-- 	local systemname = FuncWelfare.VIEW_SYSTEM_NAME_TYPE[i]
	-- 	local isopen = FuncCommon.isSystemOpen(systemname)
	-- 	if isopen then
	-- 		self.datalist[index] = NEW_SIGN_TYPE[str]
	-- 		index = index + 1
	-- 	end
	-- end

	local newtable = {}
	local index = 1
	for i=1,#FuncWelfare.VIEW_SYSTEM_NAME_TYPE  do
		local systemname = FuncWelfare.VIEW_SYSTEM_NAME_TYPE[i]
		local isopen = FuncCommon.isSystemOpen(systemname)
		if isopen then
			local isred =  self:hasRedPoint(i)
			local str = FuncWelfare.TYPE_TO_INDEX[i]
			local _table = nil 
			if isred then
				_table = { id = NEW_SIGN_TYPE[str],isred = 1 }
				table.insert(newtable,1,_table)
			else
				_table = { id = NEW_SIGN_TYPE[str],isred = 0 }
				table.insert(newtable,_table)
			end
		end
	end
	newtable = self:tableSort(newtable)

	if #newtable ~= 0 then
		self.datalist = {}

		for i=1,#newtable do
			self.datalist[i] = 	newtable[i].id
		end
		if self.titletype == nil then
			self.titletype = newtable[1].id
			-- if newtable[1].id == NEW_SIGN_TYPE.TILIREAWRD then
			-- 	self.titletype = NEW_SIGN_TYPE.REBATE
			-- end
		end
	end
	if self.titletype == nil then
		self.titletype = table.length(NEW_SIGN_TYPE)
	end

	self.mc_1:setVisible(false)
	local function createFunc( itemData)
		local view = UIBaseDef:cloneOneView(self.mc_1)
		self:updateCellRightItem(view, itemData)
		return view
	end

	local scrollParams = {
		{
			data = self.datalist,
			createFunc = createFunc,
			offsetX = 57,
            offsetY = 10,
			perFrame = 0,
			itemRect = {x = 0,y = -110,width = 180,height = 110},
			perNums= 1,
			heightGap = 0
		}
	}
	local scrollList = self.scroll_2
	scrollList:hideDragBar()
	scrollList:styleFill(scrollParams)
	-- local index = self:byDatagetIndex(self.titletype)
	self:selectitem(self.titletype)
end
function WelfareMinView:byDatagetIndex(selectid)
	for i=1,#self.datalist do
		if self.datalist[i] == tonumber(selectid) then
			return i
		end
	end
	return 1  --默认
end
function WelfareMinView:updateCellRightItem(cellview,itemData)
	

	local cellname = FuncWelfare.NEW_SIGN_TYPE_STR[tonumber(itemData)]
	cellview:getViewByFrame(1).panel_1.txt_1:setString(cellname)
	cellview:getViewByFrame(2).panel_1.txt_1:setString(cellname)
	cellview:getViewByFrame(1).panel_hongdian:setVisible(false)
	cellview:getViewByFrame(2).panel_hongdian:setVisible(false)
	if self._nowIdx == itemData then
		cellview:showFrame(2)
	end
	local frame = FuncWelfare.XIANSHI_TYPE[itemData]
	-- echo("===========frame========",frame)
	cellview:getViewByFrame(1).mc_xianshi:showFrame(frame)
	cellview:getViewByFrame(2).mc_xianshi:showFrame(frame)
	-- if self.titletype == itemData then
	-- 	self:selectitem(itemData)
	-- end
	cellview:setTouchedFunc(c_func(self.selectitem, self,itemData),nil,true);
end
function WelfareMinView:selectitem(itemData)
	echo("=============itemDatas============",itemData)
	local itemDatas =  self:byDatagetIndex(itemData)
	-- local systemname = FuncWelfare.VIEW_SYSTEM_NAME_TYPE[itemData]
	-- local isOpen, needLvl = FuncCommon.isSystemOpen(systemname);
	-- if not isOpen then
	-- 	WindowControler:showTips("系统暂未开启")
	-- 	return
	-- end
	-- echo("=============itemDatas============",itemDatas)
	local index = 1
	if  tonumber(itemData) ==	FuncWelfare.WELFARE_TYPE.TILIREAWRD then
		index = 2 
	end
	local bgName = FuncWelfare.BGNAME[index]
	echo("=====bgName==========",bgName)
	self:changeBg(bgName )


	self:showCellItmeFram()
	local allViewArr = self.scroll_2:getAllView()
	for k,v in pairs(allViewArr) do
		if k == itemDatas then
			v:showFrame(2)
		else
			v:showFrame(1)
		end
	end

	local viewname = nil
	if tonumber(itemData) == FuncWelfare.WELFARE_TYPE.REBATE then
		self.mc_2:showFrame(2)
	elseif tonumber(itemData) ==  FuncWelfare.WELFARE_TYPE.DAILYSIGN then
		self.mc_2:showFrame(3)
	elseif tonumber(itemData) ==  FuncWelfare.WELFARE_TYPE.TILIREAWRD then
		self.mc_2:showFrame(3)
	end
	if self.lotteryView[itemDatas] then
		self:ViewIsShow(itemDatas)
		return
	end
	


	viewname = FuncWelfare.VIEW_TO_TYPE[tonumber(itemData)]
	self.lotteryView[itemDatas] =  WindowControler:createWindowNode(viewname)--"NewLotteryShopView")
	self.lotteryView[itemDatas]:setPosition(cc.p(0,0))
    self.ctn_view:addChild(self.lotteryView[itemDatas])
    self:ViewIsShow(itemDatas)
	
end
function WelfareMinView:ViewIsShow(index)
	for k,v in pairs(self.lotteryView) do
		if self.lotteryView[k] ~= nil then
			if k == index then
				self.lotteryView[k]:setVisible(true)
			else
				self.lotteryView[k]:setVisible(false)
			end
		end
	end
end
--点击第几个，显示第几帧
function WelfareMinView:showCellItmeFram()
	local allViewArr = self.scroll_2:getAllView()
	

	for k,v in pairs(allViewArr) do
		local _type = self.datalist[tonumber(k)]
		local isshowred = self:hasRedPoint(_type)
		local systemname = FuncWelfare.VIEW_SYSTEM_NAME_TYPE[k]
		local isOpen, needLvl = FuncCommon.isSystemOpen(systemname);
		if not isOpen then
			isshowred = false
		end
		v:getViewByFrame(1).panel_hongdian:setVisible(isshowred)
	end
end


function WelfareMinView:hasRedPoint(idx)
	local _call = {
		[FuncWelfare.WELFARE_TYPE.DAILYSIGN] = function()
			return NewSignModel:isNewSignRedPoint()
		end,
		[FuncWelfare.WELFARE_TYPE.REBATE] = function()
			return  NewLotteryModel:fuliIsShowRed() --替换商店显示红点方法调用
		end,
		[FuncWelfare.WELFARE_TYPE.TILIREAWRD] = function()
			return  WelfareModel:getTiliRed()
		end
	}


	return _call[idx]()
end

function WelfareMinView:clickButtonBack()
	WelfareModel:sendHomeRed() --退出发送红点到主城
    self:startHide();
end




return WelfareMinView;
