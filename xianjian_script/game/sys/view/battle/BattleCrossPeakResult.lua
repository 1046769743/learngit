-- Author: pangkangning
-- Note:巅峰竞技场战斗结算处理
-- Date: 2018-02-26 

local BattleCrossPeakResult = class("BattleCrossPeakResult", UIBase);

function BattleCrossPeakResult:ctor(winName,params)
    BattleCrossPeakResult.super.ctor(self, winName)
    self.battleDatas = params
end
function BattleCrossPeakResult:loadUIComplete()
    if not self.battleDatas.crossPeak then
        return
    end
    self.panel_dfjjc:visible(false)
    -- 积分
    local addScore = self.battleDatas.crossPeak.addScore
    if addScore > 0 then
        self.panel_xjdj.mc_jf:showFrame(1)
        self.panel_xjdj.mc_jf.currentView.txt_2:setString(addScore)
    else
        self.panel_xjdj.mc_jf:showFrame(2)
        self.panel_xjdj.mc_jf.currentView.txt_2:setString(addScore)
    end
    local sconum = self.battleDatas.crossPeak.addCrossPeakCoin or GameConfig.getLanguage("#tid_crosspeak_029")
    self.panel_xjdj.txt_3:setString(sconum)
    -- 宝箱显示
    if tonumber(self.battleDatas.result) == 2 then
        self.panel_xjdj.mc_bx:showFrame(2)
    else
        self.panel_xjdj.mc_bx:showFrame(1)
        local boxId = self.battleDatas.crossPeak.newBoxId
        if boxId then
            local boxIcon = FuncCrosspeak.getBoxIcon(boxId)
            local boxIconPath = FuncRes.crossBoxIcon( boxIcon )
            local boxIconSp = display.newSprite(boxIconPath)
            boxIconSp:scale(0.8)
            boxIconSp:pos(50,-80)
            local view = self.panel_xjdj.mc_bx.currentView.mc_box.currentView
            view.panel_bx:removeAllChildren()
            view.panel_bx:addChild(boxIconSp)
        else
            self.panel_xjdj.mc_bx.currentView.mc_box:showFrame(2)
            isNotBox = true
        end
    end
end
return BattleCrossPeakResult