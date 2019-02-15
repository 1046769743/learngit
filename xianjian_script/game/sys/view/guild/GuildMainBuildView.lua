-- GuildMainBuildView
-- Author: Wk
-- Date: 2017-10-11
-- 公会建筑中的捐献和建设界面 （太清殿）
--
--Author:      zhuguangyuan
--DateTime:    2018-04-20 16:43:52
--Description: 太清殿主界面 改版
--

local GuildMainBuildView = class("GuildMainBuildView", UIBase);

function GuildMainBuildView:ctor(winName,_type)
    GuildMainBuildView.super.ctor(self, winName);
    self.defaultSelectedIndex = tonumber(_type) or 1

    echo("_________self.defaultSelectedIndex_________",self.defaultSelectedIndex)
end

function GuildMainBuildView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initView()
	self:registerLabelEvent()
	self:initViewAlign()
	self:addbubblesRunaction()
end

function GuildMainBuildView:registerEvent()
	-- body
end



function GuildMainBuildView:addbubblesRunaction()
	-- local delaytime_1 = act.delaytime(0.2)
	local scaleto_1 = act.scaleto(0.1,1.2,1.2)
	local scaleto_2 = act.scaleto(0.05,1.0,1.0)
	local delaytime_2 = act.delaytime(4.4)
 	local scaleto_3 = act.scaleto(0.1,0)
 	local delaytime_3 = act.delaytime(0.5)
 	local callfun = act.callfunc(function ()
 		self:bubbles()
 	end)
	local seqAct = act.sequence(act.spawn(callfun,scaleto_1),scaleto_2,delaytime_2,scaleto_3,delaytime_3)
	self.panel_peopel.panel_qipao:runAction(act._repeat(seqAct))

end


--气泡
function GuildMainBuildView:bubbles()
	local sumtime = FuncGuild.getBoundsTime() 
	-- if self.Updatetime == 0 or math.fmod(self.Updatetime, sumtime) == -0 then
		local ischampions = GuildModel:judgmentIsForZBoos()  --是否是盟主
		local strtable = nil
		if ischampions then
			strtable =  {
				[1] = "#tid_group_qipao_101",
				[2] = "#tid_group_qipao_102",
				[3] = "#tid_group_qipao_103",
				[4] = "#tid_group_qipao_104",
				[5] = "#tid_group_qipao_105",
			} 
		else
			strtable =  {
				[1] = "#tid_group_qipao_103",
				[2] = "#tid_group_qipao_104",
				[3] = "#tid_group_qipao_105",
			} 
		end

		local idex = math.random(1,#strtable)
		local str = GameConfig.getLanguage(strtable[idex])
		local panel = self.panel_peopel.panel_qipao
		panel.txt_story2:setString(str)
	-- end
	-- self.Updatetime = self.Updatetime + 1

end
















function GuildMainBuildView:initData()
	self.labelNum = 3 -- 目前只有三个标签
	self.labelType = {
		["donate"] = 1,
		["useBox"] = 2,
		["construct"] = 3,
	}

	self.themeName = {
		"捐献",
		"缴纳",
		"建设",
	}

	self.UI_1:initData()
	self.UI_2:initData()
	self.UI_3:initData()
end

function GuildMainBuildView:initView()
	self.UI_donate = self.UI_1
	self.UI_construct = self.UI_2
	self.UI_useBox = self.UI_3
	
	self.btn_back:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self.btn_wen:setTouchedFunc(c_func(self.questionmark, self),nil,true);
	self:dailyCost()
end

-- 注册页签的点击函数
function GuildMainBuildView:registerLabelEvent()
	for i=1,self.labelNum do
		self["mc_"..i]:setTouchedFunc(c_func(self.selectOneLabel, self,i),nil,true)
	end
	self:selectOneLabel(self.defaultSelectedIndex)
end

-- 更新页签的选中效果
function GuildMainBuildView:selectOneLabel( _toSelectIndex )
	echo("__________toSelectIndex,self.selectedLabelIndex ________",_toSelectIndex,self.selectedLabelIndex)


	-- 突然被踢出仙盟的情况处理
	if not GuildControler:touchToMainview() then
		return 
	end

	if _toSelectIndex == self.selectedLabelIndex then
		return
	end
	self.selectedLabelIndex = _toSelectIndex
	for i=1,self.labelNum do
		local choosedView = self["mc_"..i]
		if i == self.selectedLabelIndex then
			choosedView:showFrame(2)
			choosedView:getCurFrameView().btn_1:setBtnStr(self.themeName[i],"txt_1")
			choosedView:getCurFrameView().panel_red:visible(false)
		else
			choosedView:showFrame(1)
			choosedView:getCurFrameView().btn_1:setBtnStr(self.themeName[i],"txt_1")
			choosedView:getCurFrameView().panel_red:visible(false)
		end
	end

	self:setButtonRed()

	if self.selectedLabelIndex == self.labelType.donate then
		self.UI_construct:setVisible(false)
		self.UI_useBox:setVisible(false)

		self.UI_donate:setVisible(true)
		self.UI_donate:pushText()
		self.mc_res:showFrame(1)

	elseif self.selectedLabelIndex == self.labelType.useBox then
		self.UI_donate:setVisible(false)
		self.UI_construct:setVisible(false)

		self.UI_useBox:setVisible(true)
		self.UI_useBox:pushText()
		self.mc_res:showFrame(3)

	elseif self.selectedLabelIndex == self.labelType.construct then
		self.UI_donate:setVisible(false)
		self.UI_useBox:setVisible(false)

		self.UI_construct:setVisible(true)
		self.mc_res:showFrame(1)
	end
end


function GuildMainBuildView:setButtonRed()
	local redArr  = {
		[1] = GuildModel:donationRed(),
		[2] = GuildModel:userBosRed(),
		[3] = false,
	}
	for i=1,3 do
		local mc = self["mc_"..i]
		mc:getViewByFrame(1).panel_red:visible(redArr[i])
	end
	
end

function GuildMainBuildView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title,UIAlignTypes.LeftTop) 
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_wen,UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop) 
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_res,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_cost,UIAlignTypes.MiddleTop) 
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_peopel,UIAlignTypes.LeftBottom)

	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_1,UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_2,UIAlignTypes.MiddleBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_3,UIAlignTypes.MiddleBottom)

	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_1,UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_2,UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_3,UIAlignTypes.Right)
    FuncCommUI.setScale9Align(self.widthScreenOffset,self.scale9_1,UIAlignTypes.Right,0,1.5)
end
	
-- 每日维护费用
function GuildMainBuildView:dailyCost()
	local panelcost = self.panel_cost
	local level = GuildModel:getGuildLevel()   ---获得服务器的仙盟等级
	local data = FuncGuild.getGuildLevelByPreserve(level)
	panelcost.txt_2:setString(data.maintainCost)  ---每日扣除维护费
end

-- 点击问号
function GuildMainBuildView:questionmark()
	if not GuildControler:touchToMainview() then
		return 
	end
	WindowControler:showWindow("GuildRulseView",FuncGuild.Help_Type.TAIQINGDIAN)
end

function GuildMainBuildView:press_btn_close()
	self:startHide()
end

return GuildMainBuildView;
