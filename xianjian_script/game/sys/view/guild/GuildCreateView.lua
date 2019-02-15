-- GuildCreateView
-- Author: Wk
-- Date: 2017-09-29
-- 公会创建界面
local GuildCreateView = class("GuildCreateView", UIBase);

function GuildCreateView:ctor(winName)
    GuildCreateView.super.ctor(self, winName);
    self.defaultselect = 1
end

function GuildCreateView:loadUIComplete()

 	self.UI_1.btn_1:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
 	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_024")) 
 
	self:registerEvent()
	self:initData()
	self:setTopButton()
	
end 

function GuildCreateView:registerEvent()
	EventControler:addEventListener(GuildEvent.GUILD_jump_TO_RECOMMEND, self.successNextGuild, self)
	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)
	EventControler:addEventListener(GuildEvent.BREAK_CREATE_TO_UI, self.breakUI, self)

end
function GuildCreateView:initData()
	self.uiview = {
		[1] = self.UI_3,
		[2] = self.UI_4,
		-- [3] = self.UI_7,
		[3] = self.UI_5,
		[4] = self.UI_6,
		
	}
	self.cellfun = {
		[1] = self.setGuildName,
		[2] = self.setGuildGroup,
		[3] = self.setGuildIcon,
		[4] = self.successGuild,
	}

	self.UI_3:setCellFun(c_func(self.cellfun[1], self))--self.cellfun[1])
	self.UI_4:setCellFun(c_func(self.cellfun[3], self))
	self.UI_5:setCellFun(c_func(self.cellfun[4], self))
	-- self.UI_7:setCellFun(c_func(self.cellfun[3], self))
end

--显示第一个叶签按钮
function GuildCreateView:setTopButton()
	self:showNextView(self.defaultselect)
end

--仙盟输入群号
function GuildCreateView:setGuildGroup()
	self.defaultselect = self.defaultselect + 1
	self:showNextView(self.defaultselect )
end

function GuildCreateView:breakUI()
	self.defaultselect = 1
	self:showNextView(self.defaultselect )
end
-- 仙盟起名
function GuildCreateView:setGuildName()
	echo("==========起名完成=========")
	self.defaultselect = self.defaultselect + 1
	self:showNextView(self.defaultselect )
end




-- 仙盟标志
function GuildCreateView:setGuildIcon()
	-- body
	self.defaultselect = self.defaultselect + 1
	self:showNextView(self.defaultselect )

end

-- 创建成功仙盟
function GuildCreateView:successGuild()
	-- 跳转到成功界面
	WindowControler:showWindow("GuildSucceedView");

end
function GuildCreateView:successNextGuild()




	self.defaultselect = self.defaultselect + 1
	
	self:showNextView(self.defaultselect )
end

function GuildCreateView:showNextView(_index)
	self.UI_2:setdefaultSelect(_index)
	self:uiIsShow(_index)
end

function GuildCreateView:uiIsShow(_selectID)
	for i=1,#self.uiview do
		if i == _selectID then
			self.uiview[i]:setVisible(true)
		else
			self.uiview[i]:setVisible(false)
		end
		if _selectID == 4 or _selectID == 2   then  --初始化邀请列表
			self.uiview[i]:initData()
		end
	end

end



function GuildCreateView:press_btn_close()
	local isok = GuildModel:isInGuild()
	if isok then
		GuildControler:getMemberList(1)
	end
	self:startHide()
end


return GuildCreateView;
