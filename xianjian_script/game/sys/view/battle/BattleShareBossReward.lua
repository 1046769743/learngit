-- 共享副本战斗结算
-- 2017.10.20 pangkangning
local BattleShareBossReward = class("BattleShareBossReward", UIBase);




BattleShareBossReward.winRwd= 
{
    [1]="10,101,100" ,
    [2]="10,101,101", 
    [3]="10,102,300", 
    [4]="10,104,100" ,
    [5]="10,105,100", 
    [6]="10,105,100",
    [7]="10,105,100",
    [8]="10,105,100",
    [9]="10,105,100",
    [10]="10,105,100",
}




--[[
@params params 表示的是奖励宝箱
]]
function BattleShareBossReward:ctor(winName,params)
    BattleShareBossReward.super.ctor(self, winName);
    self.params = params
    
    if not LoginControler:isLogin() then
        self.params = self.winRwd
    end
end

function BattleShareBossReward:loadUIComplete()
    self:registerEvent();
    -- 居中
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_1,UIAlignTypes.MiddleTop)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_2,UIAlignTypes.MiddleTop)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_2,UIAlignTypes.MiddleBottom)
    --
    AudioModel:playMusic(MusicConfig.s_com_reward, false)

    -- 注册点击任意地方事件

    --3秒后才可以点击胜利界面关闭
    local tempFunc = function (  )
        self:registClickClose(nil, c_func(self.pressClose, self))
    end
    self:delayCall(tempFunc, 0.5)

    self:delayCall(c_func(self.loadAni,self), 1/GameVars.GAMEFRAMERATE)
    self:loadItems()
end 
-- 加载动画
function BattleShareBossReward:loadAni(  )
    local callBack = function()
        self.boxAni:pause(false) 
        self.boxAni:getBoneDisplay("xuhuan"):playWithIndex(0, true)   
    end
    self.boxAni = self:createUIArmature("UI_zhandoujiesuan","UI_zhandoujiesuan_baoxiang",self.ctn_1,false,GameVars.emptyFunc)
    self.boxAni:pos(-20,0)
    self.boxAni:removeFrameCallFunc()
    self.boxAni:registerFrameEventCallFunc(nil, false, callBack)

    -- self.bgAni = FuncCommUI.createSuccessArmature(10):addto(self.ctn_1):pos(0,-110)
    -- self.bgAni:getBone("di2"):visible(false)
end

-- 加载 奖励
function BattleShareBossReward:loadItems(  )
    -- dump(self.params,"结算奖励====")
    local createAniFunc = function(index,data,num)
        local view = self.mc_1.currentView["mc_"..num].currentView["panel_"..index]
        view.showAni = self:createUIArmature("UI_zhandoujiesuan","UI_zhandoujiesuan_chutubiao",view.ctn_1, false, GameVars.emptyFunc)    
        local itemNode = view.UI_1
        itemNode:visible(true):pos(0,0)
        local rwd = {reward = data}
        itemNode:setRewardItemData(rwd)
        FuncArmature.changeBoneDisplay(view.showAni,"node1",itemNode)
        local needNum, hasNum, isEnough, resType, resId = UserModel:getResInfo(rwd.reward)
        FuncCommUI.regesitShowResView(itemNode, resType, needNum, resId, rwd.reward, true, true)
        itemNode:setTouchSwallowEnabled(true)
    end
    if self.params.finalReward and #self.params.finalReward > 0 then
        self.mc_1:showFrame(2)
        local reward = FuncItem.getRewardArrayByCfgData(self.params.reward)
        local count = #reward
        if count > 3 then
            count = 3
        end
        self.mc_1.currentView["mc_1"]:showFrame(count)
        for i=1, count do
            self.mc_1.currentView["mc_1"].currentView["panel_"..i].UI_1:visible(false)
            local itemStr = reward[i]
            self.mc_1.currentView["mc_1"].currentView["panel_"..i]:delayCall(c_func(createAniFunc,i,itemStr,1),(20+(i-1)*3)/GameVars.GAMEFRAMERATE)
        end
        local finalReward = FuncItem.getRewardArrayByCfgData(self.params.finalReward)
        local count2 = #finalReward
        if count2 > 3 then
            count2 = 3
        end
        self.mc_1.currentView["mc_2"]:showFrame(count2)
        for i=1, count2 do
            self.mc_1.currentView["mc_2"].currentView["panel_"..i].UI_1:visible(false)
            local itemStr = finalReward[i]
            self.mc_1.currentView["mc_2"].currentView["panel_"..i]:delayCall(c_func(createAniFunc,i,itemStr,2),(20+(i-1)*3)/GameVars.GAMEFRAMERATE)
        end
    else
        self.mc_1:showFrame(1)
        local reward = FuncItem.getRewardArrayByCfgData(self.params.reward)
        local count = #reward
        if count > 3 then
            count = 3
        end
        self.mc_1.currentView["mc_1"]:showFrame(count)
        for i=1, count do
            self.mc_1.currentView["mc_1"].currentView["panel_"..i].UI_1:visible(false)
            local itemStr = reward[i]
            self.mc_1.currentView["mc_1"].currentView["panel_"..i]:delayCall(c_func(createAniFunc,i,itemStr,1),(20+(i-1)*3)/GameVars.GAMEFRAMERATE)
        end
    end
end

-- 退出战斗
function BattleShareBossReward:pressClose()
    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
    self:delayCall(function( )
        self:startHide()
    end, 0.5) 
end

function BattleShareBossReward:deleteMe()
    BattleShareBossReward.super.deleteMe(self)
    self.controler = nil
end 

return BattleShareBossReward;
