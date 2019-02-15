----宝库主界面
local GuildTreasureMainView = class("GuildTreasureMainView", UIBase);

function GuildTreasureMainView:ctor(winName,_type,digTool)
    GuildTreasureMainView.super.ctor(self, winName);
    self.defaultSelectedIndex = tonumber(_type) or FuncGuild.guild_Treasure_Main_view_First.TREASURE
    self.digTool = digTool

    echo("_________self.defaultSelectedIndex_________",self.defaultSelectedIndex)
end

function GuildTreasureMainView:loadUIComplete()
	self:registerEvent()
	self:initViewAlign()
	self:initData()
	self:initUI()
	self:refreshYiJiYeQianState()
	self:showlapseView()
end

function GuildTreasureMainView:registerEvent()
	-- body
	-- require "game.sys.view.guild.GuildTreasureMainView"
	self.btn_back:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self.btn_wen:setTouchedFunc(c_func(self.questionmark, self),nil,true);
	self.mc_1:getViewByFrame(1).UI_1.btn_dig:setTouchedFunc(c_func(self.PopupWindow, self),nil,true);
	EventControler:addEventListener(GuildEvent.REFRESH_DIGTOOLNUM, self.refreshGoDigRed, self)
	EventControler:addEventListener(GuildEvent.REFRESH_TREASURE_MAIN_VIEW, self.updateYiJiPanel, self)
end

function GuildTreasureMainView:initData()
	GuildControler:getWishList()
	self.labelNum = 2 -- 目前只有两个标签
	self.themeName = {
		"宝物",
		"心愿",
	}

	----获取地图数据  刷新地图的状态
    local function _callback( event )
        if event.result then
            local digTool = event.result.data.digTool or 0
            EventControler:dispatchEvent(GuildEvent.REFRESH_DIGTOOLNUM,{digTool = digTool})
        end
    end
    GuildServer:getGuildDigList(_callback)
end

function GuildTreasureMainView:showlapseView()
	local lapse = GuildModel:isFullmaintenanceCost()
	if lapse then
		self.mc_1:visible(true)
		self.UI_5:visible(false)
	else
		self.mc_1:visible(false)
		self.UI_5:visible(true)
		self.UI_5.btn_2:setTouchedFunc(c_func(self.goDonate, self),nil,true);
	end
end 

--去捐献
function GuildTreasureMainView:goDonate()
	if not GuildControler:touchToMainview() then
		return 
	end
	WindowControler:showWindow("GuildMainBuildView")
	self:press_btn_close()
end

---- 跳到藏宝图
function GuildTreasureMainView:PopupWindow(  )
	WindowControler:showWindow("GuildDigMapMainView")
end

function GuildTreasureMainView:initUI()
	self:initYiJiYeQian()
	self:YiJiYeQianTap(self.defaultSelectedIndex)
end


function GuildTreasureMainView:initYiJiYeQian()
	local panel = self.panel_yeqian
    for i = 1,self.labelNum do
        local mc = panel["mc_yeqian"..i]
        local btn = mc.currentView.btn_baoxiang1
        btn:setTap(c_func(self.YiJiYeQianTap,self,i))
    end
    self:refreshRedPoint()
end

----刷新一级页签选中状态
function GuildTreasureMainView:refreshYiJiYeQianState()
	local panel = self.panel_yeqian
    for i = 1,self.labelNum do
        local mc = panel["mc_yeqian"..i]
        if self.defaultSelectedIndex == i then
            mc:showFrame(2)
        else
            mc:showFrame(1)
        end
    end
end

----一级页签点击事件
function GuildTreasureMainView:YiJiYeQianTap( _type )
    self.defaultSelectedIndex = _type
    self:refreshYiJiYeQianState()
    self:refreshRedPoint()
    self:updateYiJiPanel()
end

----点击一级页签 更新中间部分区域
function GuildTreasureMainView:updateYiJiPanel()
	self.erjiIndex = GuildModel:defaultSelectRedBoxID() or 1
    self.mc_1:showFrame(self.defaultSelectedIndex)
    local view = self.mc_1
    if self.defaultSelectedIndex == FuncGuild.guild_Treasure_Main_view_First.TREASURE then
    	view:showFrame(self.defaultSelectedIndex)
    	view.currentView.UI_1:updateUI(self.erjiIndex)
    elseif self.defaultSelectedIndex == FuncGuild.guild_Treasure_Main_view_First.WISH then
    	view:showFrame(self.defaultSelectedIndex)
    end
    self.UI_1.txt_1:setString(self.themeName[self.defaultSelectedIndex])
end

--更新红点
function GuildTreasureMainView:refreshRedPoint()
	local redShow = GuildModel:refreshGuildBaoKuRed()
	local panel = self.panel_yeqian
    panel["mc_yeqian"..1]:getViewByFrame(1).btn_baoxiang1:getUpPanel().panel_red:visible(redShow)
    panel["mc_yeqian"..2]:getViewByFrame(1).btn_baoxiang1:getUpPanel().panel_red:visible(false)

    local red
    local toolMaxNum = GuildModel:getToolMaxNum()
    if (tonumber(self.digTool) or 0) >= (tonumber(toolMaxNum) or 10) then
    	red = true
    else
    	red = false
    end
    self.mc_1:getViewByFrame(1).UI_1.btn_dig:getUpPanel().panel_red:visible(red)
end

function GuildTreasureMainView:refreshGoDigRed( event )
	-- dump(event.params.digTool,"event = = = = = = =")
	if event then
		self.digTool = event.params.digTool
	end
	self:refreshRedPoint()
end

----适配
function GuildTreasureMainView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title,UIAlignTypes.LeftTop) 
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_wen,UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop) 
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res,UIAlignTypes.RightTop)
end
	
-- 每日维护费用
function GuildTreasureMainView:dailyCost()
	local panelcost = self.panel_cost
	local level = GuildModel:getGuildLevel()   ---获得服务器的仙盟等级
	local data = FuncGuild.getGuildLevelByPreserve(level)
	panelcost.txt_2:setString(data.maintainCost)  ---每日扣除维护费
end

-- 点击问号
function GuildTreasureMainView:questionmark()
	if not GuildControler:touchToMainview() then
		return 
	end
	WindowControler:showWindow("GuildRulseView",FuncGuild.Help_Type.TREASURY)
end

function GuildTreasureMainView:press_btn_close()
	self:startHide()
end

return GuildTreasureMainView;
