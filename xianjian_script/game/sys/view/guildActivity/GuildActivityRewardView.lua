--
--Author:      zhuguangyuan
--DateTime:    2018-05-10 11:11:26
--Description: 仙盟厨房奖励主界面
--
-- 1.包含星级奖励和积分奖励

local GuildActivityRewardView = class("GuildActivityRewardView", UIBase);

function GuildActivityRewardView:ctor(winName,_type)
    GuildActivityRewardView.super.ctor(self, winName)
    self.defaultSelectedIndex = tonumber(_type) or 1
end

function GuildActivityRewardView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initView()
	self:registerLabelEvent()
	self:initViewAlign()
end 

function GuildActivityRewardView:registerEvent()
	GuildActivityRewardView.super.registerEvent(self);
	self.btn_back:setTap(c_func(self.onClose, self))  -- 返回
end

function GuildActivityRewardView:initData()
	self.labelNum = 2 -- 目前只有2个标签
	self.labelType = {
		["star"] = 1,
		["accumulate"] = 2,
	}
	self.themeName = {"星级","积分",}
	self.UI_2:initData()
	self.UI_3:initData()
end

function GuildActivityRewardView:initView()
	self.UI_1.txt_1:visible(false)
	self.UI_1.panel_1:visible(false)

	self.UI_accumulate = self.UI_2
	self.UI_star = self.UI_3
end


-- 注册页签的点击函数
function GuildActivityRewardView:registerLabelEvent()
	for i=1,self.labelNum do
		self.panel_yeqian["mc_"..i]:setTouchedFunc(c_func(self.selectOneLabel, self,i),nil,true)
	end
	self:selectOneLabel(self.defaultSelectedIndex)
end

-- 更新页签的选中效果
function GuildActivityRewardView:selectOneLabel( _toSelectIndex )
	-- echo("__________toSelectIndex,self.selectedLabelIndex ________",_toSelectIndex,self.selectedLabelIndex)
	if _toSelectIndex == self.selectedLabelIndex then
		return
	end
	self.selectedLabelIndex = _toSelectIndex
	for i=1,self.labelNum do
		local choosedView = self.panel_yeqian["mc_"..i]
		if i == self.selectedLabelIndex then
			choosedView:showFrame(2)
			choosedView:getCurFrameView().btn_1:setBtnStr(self.themeName[i],"txt_1")
		else
			choosedView:showFrame(1)
			choosedView:getCurFrameView().btn_1:setBtnStr(self.themeName[i],"txt_1")
			if i == self.labelType.accumulate then
				local isShow = GuildActMainModel:isShowRewardRedPoint()
				choosedView:getCurFrameView().panel_red:visible(isShow)
			else
				choosedView:getCurFrameView().panel_red:visible(false)
			end
		end
	end

	-- 突然被踢出仙盟的情况处理
	if not GuildControler:touchToMainview() then
		return 
	end

	if self.selectedLabelIndex == self.labelType.accumulate then
		self.UI_star:setVisible(false)
		self.UI_accumulate:setVisible(true)
		self.UI_accumulate:updateUI()
		self.mc_tips:showFrame(2)
	elseif self.selectedLabelIndex == self.labelType.star then
		self.UI_accumulate:setVisible(false)
		self.UI_star:setVisible(true)
		self.UI_star:updateUI()
		self.mc_tips:showFrame(1)
	end
end

function GuildActivityRewardView:initViewAlign()
	-- TODO
end

function GuildActivityRewardView:updateUI()
	-- TODO
end

function GuildActivityRewardView:onClose()
	self:startHide()
end
function GuildActivityRewardView:deleteMe()
	GuildActivityRewardView.super.deleteMe(self);
end

return GuildActivityRewardView;
