--[[
	Author: TODO
	Date:2017-07-27
	Description: TODO
]]

local EliteConditionView = class("EliteConditionView", UIBase);

function EliteConditionView:ctor(winName, itemData)
    EliteConditionView.super.ctor(self, winName)
    self.currentRaidData = itemData
end

function EliteConditionView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function EliteConditionView:registerEvent()
	EliteConditionView.super.registerEvent(self);
	self:registClickClose("out")

end

function EliteConditionView:initData()
    FuncCommUI.addBlackBg(self.widthScreenOffset,self._root,100)
end

function EliteConditionView:initView()
	self.mc_passCondition1 = self.mc_1
	self.mc_passCondition2 = self.mc_2
	self.mc_passCondition3 = self.mc_3

	self.txt_condition1 = self.txt_1
	self.txt_condition2 = self.txt_2
	self.txt_condition3 = self.txt_3
end

function EliteConditionView:initViewAlign()
	-- TODO
end

function EliteConditionView:updateUI()
	local string1 = self.currentRaidData.oneStar
	local string2 = self.currentRaidData.twoStar
	local string3 = self.currentRaidData.threeStar

	self.txt_condition1:setString( GameConfig.getLanguage(string1) )
	self.txt_condition2:setString( GameConfig.getLanguage(string2) )
	self.txt_condition3:setString( GameConfig.getLanguage(string3) )
	
	-- 亮色显示所有葫芦
	self.mc_passCondition1:showFrame(1)
	self.mc_passCondition2:showFrame(1)
	self.mc_passCondition3:showFrame(1)

	-- -- 通过读取战斗结果设置所得葫芦个数
 --    local raidScore = WorldModel:getBattleStarByRaidId( self.currentRaidData.id )
 --    if raidScore == WorldModel.stageScore.SCORE_ONE_STAR then
 --        self.mc_passCondition1:showFrame(1)
 --        self.mc_passCondition2:showFrame(2)
 --        self.mc_passCondition3:showFrame(2)
 --    elseif raidScore == WorldModel.stageScore.SCORE_TWO_STAR then
 --        self.mc_passCondition1:showFrame(1)
 --        self.mc_passCondition2:showFrame(1)
 --        self.mc_passCondition3:showFrame(2)
 --    elseif raidScore == WorldModel.stageScore.SCORE_THREE_STAR then
 --        self.mc_passCondition1:showFrame(1)
 --        self.mc_passCondition2:showFrame(1)
 --        self.mc_passCondition3:showFrame(1)
 --    elseif raidScore == WorldModel.stageScore.SCORE_LOCK then
 --        self.mc_passCondition1:setVisible(false)
 --        self.mc_passCondition2:setVisible(false)
 --        self.mc_passCondition3:setVisible(false)
 --    end
end

function EliteConditionView:deleteMe()
	-- TODO

	EliteConditionView.super.deleteMe(self);
end

return EliteConditionView;
