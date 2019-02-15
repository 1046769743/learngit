-- GuildBlessingView
-- Author: Wk
-- Date: 2017-10-11
-- 公会祈福主界面
local GuildBlessingView = class("GuildBlessingView", UIBase);

function GuildBlessingView:ctor(winName,_selectYeQian)
    GuildBlessingView.super.ctor(self, winName);
    self._selectYeQian = tonumber(_selectYeQian)
end

function GuildBlessingView:loadUIComplete()

	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_wen,UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title,UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop) 
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_3,UIAlignTypes.RightTop)

	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)
	-- self:registClickClose(-1, c_func( function()
 --        self:press_btn_close()
 --    end , self))

    self:registClickClose("out")


	self.titlename = FuncGuild.titlename
	self.uiViewArr = {
		[1] = self.UI_1,
		[2] = self.UI_2,
		[3] = self.UI_shouji,
		[4] = self.UI_guild_jiaohuan,
	}

	if self._selectYeQian and self._selectYeQian == 2 then
		self._selectYeQian = 1
	end
	self.selectIndex = self._selectYeQian or 1
	self.UI_di.txt_1:setString(self.titlename[self.selectIndex])
	
	self:defaultYeQian()
	self:setButton()

	self:showlapseView()

	self:getServeData()
end 

function GuildBlessingView:getServeData()
	if GuildModel._baseGuildInfo.prayCount == nil then
		GuildControler:getMemberList("")
	end
end
function GuildBlessingView:showlapseView()
	local lapse = GuildModel:isFullmaintenanceCost()
	if lapse then
		self.UI_todo:setVisible(false)
		self:defaultYeQian()
	else
		self.UI_todo:setVisible(true)
		for k,v in pairs(self.uiViewArr) do
			if v then
				v:setVisible(false)
			end
		end
	end
end

function GuildBlessingView:defaultYeQian()


	self.panel_yeqian.mc_yeqian2:setVisible(false)



	for i=1,#self.titlename do
		self.panel_yeqian["mc_yeqian"..i]:showFrame(1)
		-- self["UI_"..i]:setVisible(false)
		if self.uiViewArr[i] ~= nil then
			self.uiViewArr[i]:setVisible(false)
		end
	end
	self.panel_yeqian["mc_yeqian"..self.selectIndex]:showFrame(2)
	if self.uiViewArr[self.selectIndex] ~= nil then
		self.uiViewArr[self.selectIndex]:setVisible(true)
		self.uiViewArr[self.selectIndex]:initData()
	end
	-- self["UI_"..self.selectIndex]:setVisible(true)
end

--显示叶签红点
function GuildBlessingView:showYeQianRed()
	local alldata = FuncGuild.getAllExchangeData()
	local isshored = false
	for k,v in pairs(alldata) do
		local isred = GuildModel:boxExchanegIsShowRed(k)
		if isred then
			isshored = true
		end
	end
	local panel = self.panel_yeqian
	for i=1,#self.titlename do
		local panel_red = panel["mc_yeqian"..i]:getViewByFrame(1).btn_baoxiang1:getUpPanel().panel_red
		if panel_red then
			panel_red:setVisible(isshored)
		end
	end
end

function GuildBlessingView:setButton()
	self.btn_wen:setTouchedFunc(c_func(self.helpbutton, self),nil,true);
	self.btn_back:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	local panel = self.panel_yeqian
	for i=1,#self.titlename do
		local panel_red = panel["mc_yeqian"..i]:getViewByFrame(1).btn_baoxiang1:getUpPanel().panel_red
		if panel_red then
			panel_red:setVisible(false)
		end
		panel["mc_yeqian"..i]:setTouchedFunc(c_func(self.selectYeQian, self,i),nil,true);
	end
	self.UI_todo.btn_2:setTouchedFunc(c_func(self.goingDonation, self),nil,true);
	self:showYeQianRed()
end
function GuildBlessingView:goingDonation()
	if not GuildControler:touchToMainview() then
		return 
	end
	WindowControler:showWindow("GuildMainBuildView")
	EventControler:dispatchEvent(GuildEvent.CLOSE_INFO_VIEW_EVENT)
	self:press_btn_close()
end

function GuildBlessingView:selectYeQian(index)
	if not GuildControler:touchToMainview() then
		return 
	end
	if index == self.selectIndex then
		return 
	end
	if index ==  2 then
		return 
	end
	local panel = self.panel_yeqian
	panel["mc_yeqian"..index]:showFrame(2)
	panel["mc_yeqian"..self.selectIndex]:showFrame(1)
	self:showUIView(index)
	
end

function GuildBlessingView:showUIView(index)

	-- self["UI_"..index]
	self.uiViewArr[index]:setVisible(true)
	if self.uiViewArr[index].initData  ~= nil then
		self.uiViewArr[index]:initData()
	end
	-- self["UI_"..self.selectIndex]:setVisible(false)
	self.uiViewArr[self.selectIndex]:setVisible(false)

	if index == 4 then  ---先单独处理交换按钮
		-- self.uiViewArr[index]:createViewData()
	end

	self:showYeQianRed()
	self.selectIndex = index
	self.UI_di.txt_1:setString(self.titlename[self.selectIndex])
end



function GuildBlessingView:helpbutton()
	echo("帮助界面 ====== 正在研发")
	if not GuildControler:touchToMainview() then
		return 
	end
	WindowControler:showWindow("GuildRulseView",FuncGuild.Help_Type.QIFU)
end
function GuildBlessingView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end



function GuildBlessingView:press_btn_close()
	EventControler:dispatchEvent(GuildEvent.GET_QIFU_REWARD)
	self:startHide()
end


return GuildBlessingView;
