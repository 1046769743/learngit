-- GuildWelfareMainView
-- Author: Wk
-- Date: 2017-10-12
-- 公会账房 福利主界面
local GuildWelfareMainView = class("GuildWelfareMainView", UIBase);

function GuildWelfareMainView:ctor(winName,selectType)
    GuildWelfareMainView.super.ctor(self, winName);
    self.selectType = selectType
end

function GuildWelfareMainView:loadUIComplete()

	self:registerEvent()

	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_wen,UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title,UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop) 
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_3,UIAlignTypes.RightTop)

	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)
	-- self:registClickClose(-1, c_func( function()
 --        self:press_btn_close()
 --    end , self))

    self:registClickClose("out")


	self.titlename = {
		[1] = "祈福",
		[2] = "红利",
		[3] = "红包",
	}

	self.uiArr = {
		[1] = self.UI_x1,
		[2] = self.UI_x2,
		[3] = self.UI_x3,
		[4] = self.UI_x4,
	}


	self.selectIndex = 1
	self.UI_1.txt_1:setString(self.titlename[self.selectIndex])
		
	if not GuildRedPacketModel.ui_select then
		self:defaultYeQian()
	else
		self:selectYeQian(2)
		self:showMyRedPacketView()
	end
	self:setButton()




	GuildRedPacketModel:getServeData()

	local isshow_0 = GuildModel:blessingRed() or false
	local isshow_1 = GuildModel:bonusListRed()
	local isshow_2 = GuildRedPacketModel:grabRedPacketRed() or GuildRedPacketModel:sendRedPacketRed() or false
	-- echo("=====isshow_1========",isshow_1,isshow_2)
	if not self.selectType then
		if isshow_0 then
			self:selectYeQian(1)
		elseif isshow_1 then
			self:selectYeQian(2)
		elseif isshow_2 then
			self:selectYeQian(3)
		end
	else
		self:defaultYeQian()
	end

	self:showlapseView()


end 

function GuildWelfareMainView:registerEvent()
	EventControler:addEventListener(GuildEvent.GUILD_REDPACKET_SHOW, self.showRedPacketView, self)
	EventControler:addEventListener(GuildEvent.GUILD_REDPACKET_SHOW_MY, self.showMyRedPacketView, self)
end

	

function GuildWelfareMainView:onBecomeTopView()

	if GuildRedPacketModel.redPacketView then
		GuildRedPacketModel.redPacketView:setVisible(false)
	end
	self.UI_x4:initData()
end

--显示自己的红包
function GuildWelfareMainView:showMyRedPacketView()
	GuildRedPacketModel.ui_select = true
	if self.UI_x4 ~= nil then
		self.UI_x4:setVisible(true)
		self.UI_x4:initData()
	end
	if self.UI_x3 ~= nil then
		self.UI_x3:setVisible(false)
	end
	self.UI_1.txt_1:setString("我的红包")
end

--显示仙盟里面的红包
function GuildWelfareMainView:showRedPacketView()
	-- echo("1111111111111111 ===UI_x2")
	if self.UI_x4 ~= nil then
		self.UI_x4:setVisible(false)
	end
	if self.UI_x3~= nil then
		self.UI_x3:setVisible(true)
		self.UI_x3:initData()
	end
	self.UI_1.txt_1:setString(self.titlename[3])
end


function GuildWelfareMainView:showlapseView()
	local lapse = GuildModel:isFullmaintenanceCost()
	if lapse then
		self.UI_todo:setVisible(false)
		self:defaultYeQian()
	else
		self.UI_todo:setVisible(true)
		for k,v in pairs(self.uiArr) do
			v:setVisible(false)
		end
	end
end 

function GuildWelfareMainView:defaultYeQian()
	local number = #self.titlename 
	for i=1,number do
		self.panel_yeqian["mc_yeqian"..i]:showFrame(1)
	end
	for k,v in pairs(self.uiArr) do
		v:setVisible(false)
	end
	self.panel_yeqian["mc_yeqian"..self.selectIndex]:showFrame(2)
	self["UI_x"..self.selectIndex]:setVisible(true)
	self["UI_x"..self.selectIndex]:initData()
	self:yeqianShowRed()
	
end

function GuildWelfareMainView:setButton()
	self.btn_wen:setTouchedFunc(c_func(self.helpbutton, self),nil,true);
	self.btn_back:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	local panel = self.panel_yeqian
	local number = #self.titlename
	for i=1,number do
		panel["mc_yeqian"..i]:setTouchedFunc(c_func(self.selectYeQian, self,i),nil,true);
	end
	self.UI_todo.btn_2:setTouchedFunc(c_func(self.goingDonation, self),nil,true);
end
function GuildWelfareMainView:goingDonation()
	if not GuildControler:touchToMainview() then
		return 
	end
	WindowControler:showWindow("GuildMainBuildView")
	self:press_btn_close()
end

function GuildWelfareMainView:selectYeQian(index)
	if not GuildControler:touchToMainview() then
		return 
	end
	if index == self.selectIndex then
		return 
	end

	local lapse = GuildModel:isFullmaintenanceCost()
	if not lapse then
		return 
	end

	-- if index == 2 then
	-- 	echo("红包界面 ====== 正在研发")
	-- 	WindowControler:showTips("红包界面 ====== 正在研发")
	-- 	return
	-- end
	local panel = self.panel_yeqian
	panel["mc_yeqian"..index]:showFrame(2)
	panel["mc_yeqian"..self.selectIndex]:showFrame(1)
	self:showUIView(index)
	self:yeqianShowRed()
	
end

function GuildWelfareMainView:showUIView(index)
	for k,v in pairs(self.uiArr) do
		v:setVisible(false)
	end
	if self["UI_x"..index] then
		self["UI_x"..index]:setVisible(true)
		self["UI_x"..index]:initData()
		if self["UI_x"..self.selectIndex] then
			self["UI_x"..self.selectIndex]:setVisible(false)

		end
	end

	self.selectIndex = index
	self.UI_1.txt_1:setString(self.titlename[self.selectIndex])
end




function GuildWelfareMainView:helpbutton()
	if not GuildControler:touchToMainview() then
		return 
	end
	WindowControler:showWindow("GuildRulseView",FuncGuild.Help_Type.QIFU)
	
	

	
end


function GuildWelfareMainView:press_btn_close()
	EventControler:dispatchEvent(GuildEvent.GUILD_REDPACKET_SHOW_RED)
	GuildRedPacketModel.ui_select = false
	self:startHide()
end


function GuildWelfareMainView:yeqianShowRed()
	local isshow_1 = GuildModel:bonusListRed()
	local isshow_2 = GuildRedPacketModel:grabRedPacketRed() or GuildRedPacketModel:sendRedPacketRed() or false
	local isshow_0 = GuildModel:blessingRed() or false
	self.panel_yeqian.mc_yeqian1:getViewByFrame(1).btn_baoxiang1:getUpPanel().panel_red:visible(isshow_0)
	self.panel_yeqian.mc_yeqian2:getViewByFrame(1).btn_baoxiang1:getUpPanel().panel_red:visible(isshow_1)
	self.panel_yeqian.mc_yeqian3:getViewByFrame(1).btn_baoxiang1:getUpPanel().panel_red:visible(isshow_2)
end


return GuildWelfareMainView;
