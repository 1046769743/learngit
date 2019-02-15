




--[[
战斗结算  胜利和失败都在这里
]]
local BattleResult = class("BattleResult", UIBase);



-- {
--     result=1, 
--     addExp = 10, 
--     preExp = 30, 
--     preLv = 35, 
--     star =1, 
--     reward = {
--         [1]="1,4011,301" ,
--         [2]="1,4012,300", 
--         [3]="1,4013,300", 
--         [4]="2,300,301" ,
--         [5]="3,4201,301", 
--         } 
-- }


BattleResult.tempResult = 
{
    result=1, 
    addExp = 10, 
    preExp = 30, 
    preLv = 35, 
    star =1, 
    reward = {
        [1]="1,4011,301" ,
        [2]="1,4012,300", 
        [3]="1,4013,300", 
        [4]="2,300,301" ,
        [5]="3,4201,301", 
    },
    heros = {
            [5001]  = {
                hid = 5001,
                addExp = 200,
                preExp = 30,
                preLv = 3,
                lv = 4,
            },
            [5002]  = {
                hid = "5002",
                addExp = 200,
                preExp = 30,
                preLv = 3,
                lv = 4
            },
            [5003]  = {
                hid = "5003",
                addExp = 200,
                preExp = 30,
                preLv = 3,
                lv = 4
            },
            [5004]  = {
                hid = "5004",
                addExp = 200,
                preExp = 30,
                preLv = 3,
                lv = 4
            },
            [5005]  = {
                hid = "5005",
                addExp = 200,
                preExp = 30,
                preLv = 3,
                lv = 4
            }
        }, 
}


function BattleResult:ctor(winName,params,battleLabel)
    BattleResult.super.ctor(self, winName);
    -- echo("战斗结果-------------")
    -- dump(params)
    -- echo("战斗结果-------------")
    --self.isUpgrade = false
    --self.battleDatas = params
    params = self.tempResult
    self.isWin = params.result == 1
    self.result = params
    -- 这地方不是限定了战斗结果页是worldPve了么？
    -- battleLabel =  GameVars.battleLabels.worldPve  --GameVars.battleLabels.pvp
    -- self.battleLabel = battleLabel
    self.isShowRwd = true
end

function BattleResult:loadUIComplete()
    self:registerEvent()
    self:setViewStyle()
    self:uiAdjust()
    WindowControler:createCoverLayer(nil, nil, GameVars.bgAlphaColor):addto(self, -2)
    -- 注册点击任意地方事件

    --0.5秒后才可以点击胜利界面关闭
    local tempFunc = function (  )
        self:registClickClose(nil, c_func(self.pressClose, self))
    end

    self:delayCall(tempFunc, 0.5)

    
    self:updateUI()
    --self:setViewStyle()
    --WindowControler:createCoverLayer(nil, nil, GameVars.bgAlphaColor):addto(self, -2)
end 



function BattleResult:uiAdjust()
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_close, UIAlignTypes.RightTop);
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop);   
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.RightTop);  
    -- FuncCommUI.setScale9Align(self.widthScreenOffset, self.scale9_ding,UIAlignTypes.MiddleTop,1 )
end



function BattleResult:pressClose(  )
    echo("点击关闭---------")
    self:startHide()
    if self.isShowRwd then
        if not LoginControler:isLogin() then
            if #self.result.winRwd ==0 then
                echo("未登录，没有奖励物品--")
                FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
                return
            end
        else
            if #self.result.reward == 0 then
                echo("没有奖励物品")
                FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
                return
            end
        end
        WindowControler:showBattleWindow("BattleReward",self.result)
    end
end


function BattleResult:setViewStyle()


end 



function BattleResult:registerEvent()
    --BattleResult.super.registerEvent()
    -- --echo("注册了关闭事件============")
    -- self:registClickClose("out",function ( ... )
    --     echo("点击到了窗口的任意位置------")
    -- end)
end


 

function BattleResult:updateUI()
    if self.isWin  then
        self.mc_zhuangtai2:showFrame(1)
        if BattleControler:checkIsWorldPVE() or
         BattleControler:getBattleLabel() == GameVars.battleLabels.guildGve then
            --如果是pve
            self.mc_zhuangtai:showFrame(1)
            --星级
            self.mc_zhuangtai.currentView.mc_xingxingnum:showFrame(self.result.star)
            --主角经验  这里需要一个动画或者变化
            self.mc_zhuangtai.currentView.txt_1:setString(self.result.preLv)
            --主角增加的经验   
            self.mc_zhuangtai.currentView.txt_2:setString(self.result.addExp)

            --左侧立绘 头像
            local avator = 101    --UserModel:avatar()
            local level = 1     --UserModel:level()
            local tHid = 1
            -- local charView = FuncChar.getCharOnTreasure(avator,level,tHid, false)
            -- charView:setScale(3)
            
            -- charView:playLabel(charView.actionArr.stand,true)

            local charView =  FuncRes.getArtSpineAni("art_LiXiaoYaoLiHui")
            charView:gotoAndStop(1)
            charView:setPosition(cc.p(0,-240))

            self.mc_lihui:showFrame(1)
            self.mc_lihui.currentView.ctn_1:addChild(charView)


            --每个英雄增加了多少经验
            local heros = table.values(self.result.heros)
            --这里应该对heros进行一次排序
            self.mc_zhuangtai.currentView.mc_huobannum:showFrame(#heros)

            -- hid = "5005",
            --     addExp = 200,
            --     preExp = 30,
            --     preLv = 3

            local count = #heros
            if count > 5 then
                -- 这个肯定会留坑，应该在布阵阶段屏蔽的，既然要这么兼容我也没办法 tracup #10885
                echoError ("主线、或者精英为什么能上超过5个伙伴的阵容")
                count = 5
            end
            for k = 1,count do
                local panel = self.mc_zhuangtai.currentView.mc_huobannum.currentView["panel_"..k]
                --等级
                panel.txt_1:setString(heros[k].lv)
                --经验
                panel.txt_2:setString("EXP+"..heros[k].addExp)
                --头像
                local icon = FuncPartner.getPartnerById(heros[k].hid).icon
                panel.ctn_1:addChild(display.newSprite( FuncRes.iconHero(icon ..".png")):size(78,78) )
            end


        elseif BattleControler:checkIsPVP() then
            --竞技场等
            self.mc_zhuangtai:showFrame(2)
            --排名 或者排名  上升  1:当前排名   2：表示突破了最高排名拿到了历史最高排名
            self.mc_zhuangtai.currentView.mc_zhuangtai:showFrame(1)



        end
    else
        --普通pve输了

        self.mc_zhuangtai2:showFrame(2)
        --失败的提示
        self.mc_zhuangtai:showFrame(3)

        self.mc_lihui:showFrame(2)

        self.mc_zhuangtai.currentView.btn_3:setTap(c_func(self.showRank,self))
        self.mc_zhuangtai.currentView.btn_4:setTap(c_func(self.doReBattle,self))

        -- mc_1  提示能力增加的方法  当前做的是  6 帧一样的




        
    end
end



--[[
胜利加载
]]
function BattleResult:loadWinResult(  )
   
end


--[[
战斗胜利  几个字的 动画
]]
function BattleResult:loadWinTitleAni(  )
    
end


--[[
星星 
]]
function BattleResult:loadStarAni( ... )
    
end

--[[
有无伙伴死亡
]]








--[[
查看排名
]]
function BattleResult:showRank(  )
    echo("查看排名")
end

--[[
重新进行战斗
]]
function BattleResult:doReBattle( )
    echo("重新进行战斗")
end





function BattleResult:hideComplete()
    BattleResult.super.hideComplete(self)
    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
end


function BattleResult:deleteMe()
    BattleResult.super.deleteMe(self)
    self.controler = nil
end 

return BattleResult;
