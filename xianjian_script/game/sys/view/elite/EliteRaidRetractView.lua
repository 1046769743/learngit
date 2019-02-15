--
--Author:      zhuguangyuan
--DateTime:    2017-07-26 13:56:20
--Description: 关卡视图--未展开
--


local EliteRaidRetractView = class("EliteRaidRetractView", UIBase);

function EliteRaidRetractView:ctor(winName)
    EliteRaidRetractView.super.ctor(self, winName)
end

function EliteRaidRetractView:loadUIComplete()
	-- self:initData()
	-- self:initView()

	-- self:registerEvent()
	-- self:initViewAlign()

	-- self:updateUI()
end 



----------------------------------------------
--
----------------------------------------------
function EliteRaidRetractView:initData(itemData)
	self.itemData = itemData
end



----------------------------------------------
--
----------------------------------------------
function EliteRaidRetractView:initView()
    -- self.huluMC = self.mc_hulu
    -- self.eliteTimesMC = self.mc_num
    -- self.btnPassRaidRules = self.btn_guize
    -- self.panelUnfold = self.panel_zipian
    -- self.mainRewardUI = self.UI_1
end



----------------------------------------------
--
----------------------------------------------
function EliteRaidRetractView:registerEvent()
	EliteRaidRetractView.super.registerEvent(self);
end



----------------------------------------------
--
----------------------------------------------
function EliteRaidRetractView:initViewAlign()
	-- TODO
end



----------------------------------------------
--
----------------------------------------------
function EliteRaidRetractView:initUI()
    -- -- 设置节名称
    -- local RaidName = GameConfig.getLanguage(self.itemData.name)
    -- local chapter = self.currentStoryId - 200
    -- RaidName = self.numMap[chapter].."章"..self.numMap[self.itemData.section].."节"
    -- self.txt_zhangjie:setString(RaidName)


    -- -- 展示本关卡可获得的最贵重奖品/暂时展示第1个
    -- -- 点击可显示tips
    -- local rewardString =self.itemData["bonusView"]
    -- local str1 = rewardString[1]
    -- local params = {
    --     reward = str1,
    -- }
    -- mainRewardUI:setResself.itemData(params)
    -- mainRewardUI:setTouchEnabled(false)
    -- mainRewardUI:showResItemNum(false)  -- 隐藏数量

    -- -- 下方显示今日剩余挑战次数
    -- -- todo 监听扫荡或者挑战事件
    -- local leftTimes = WorldModel:getEliteRaidLeftTimes( self.itemData.id )
    -- if leftTimes == 0 then
    --     eliteTimesMC:showFrame(1)
    -- elseif leftTimes == 1 then
    --     eliteTimesMC:showFrame(2)
    -- elseif leftTimes == 2 then
    --     eliteTimesMC:showFrame(3)
    -- elseif leftTimes == 3 then
    --     eliteTimesMC:showFrame(4)
    -- elseif leftTimes == 4 then
    --     eliteTimesMC:showFrame(5)
    -- end
    
    -- -- 设置葫芦
    -- -- 通过读取战斗结果设置所得葫芦个数
    -- local raidScore = WorldModel:getBattleStarByRaidId( self.itemData.id )
    -- huluMC:setVisible(true)
    -- if raidScore == WorldModel.stageScore.SCORE_ONE_STAR then
    --     huluMC:showFrame(1)
    -- elseif raidScore == WorldModel.stageScore.SCORE_TWO_STAR then
    --     huluMC:showFrame(2)
    -- elseif raidScore == WorldModel.stageScore.SCORE_THREE_STAR then
    --     huluMC:showFrame(3)
    -- elseif raidScore == WorldModel.stageScore.SCORE_LOCK then
    --     huluMC:showFrame(4)
    -- end

    -- -- 设置通关问号
    -- -- 点击可显示通关规则
    -- btnPassRaidRules:setTap(function()
    --     WindowControler:showWindow("EliteConditionView", self.itemData)
    -- end)

    -- -- 展开画卷
    -- panelUnfold:setTouchedFunc(function()
    --     echo("@@@@@@@@@@@@@@@@@@@@@: 展开画卷 @@@@@@@@@@@@@@@@@@@@@@@@@")
    --     self.currentUnfoldRaidId = self.itemData.id
    --     self.currentCenterRaidNum = tonumber( string.sub(self.itemData.id, 5, 5) )
    --     echoWarn(self.currentUnfoldRaidId)
    --     self:updateRaidList()
    -- end)
end



----------------------------------------------
--
----------------------------------------------
function EliteRaidRetractView:updateUI()
	-- TODO
end

function EliteRaidRetractView:deleteMe()
	-- TODO

	EliteRaidRetractView.super.deleteMe(self);
end

return EliteRaidRetractView;
