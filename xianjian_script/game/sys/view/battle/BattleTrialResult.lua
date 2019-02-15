
-- Author: pangkangning
-- Note:试炼战斗结算处理
-- Date: 2018-02-26 

local BattleTrialResult = class("BattleTrialResult", UIBase);

function BattleTrialResult:ctor(winName,params)
    BattleTrialResult.super.ctor(self, winName)
    self.battleDatas = params
end
function BattleTrialResult:loadUIComplete()
    
    local str
    local star = self.battleDatas.star
    star = FuncCommon:getBattleStar(star) or 0
    local bLabel = BattleControler:checkIsTrail()
    if bLabel == Fight.trail_shanshen then
        str = "#tid_trial_"..3000+star
    elseif bLabel == Fight.trail_huoshen then
        str = "#tid_trial_"..3003+star
    elseif bLabel == Fight.trail_daobaozhe then
        str = "#tid_trial_"..3006+star
    end
    if not str then str = "" end
    -- 统计伤害
    self.rich_x1:setString(GameConfig.getLanguage(str))

    local data,maxValue = StatisticsControler:getTrailStatisData()
    if BattleControler:checkIsTrail() == Fight.trail_huoshen then
        self.panel_zuijia.txt_2:visible(false)
        -- 承受最高伤害的角色
    else
        -- 造成伤害最高的角色
        self.panel_zuijia.txt_1:visible(false)
    end

    local  _spriteIcon = display.newSprite( FuncRes.iconHero(data.icon ))
    _spriteIcon:setScale(1.2)

    local quality = data.quality or 1
    local star = data.star or 1

    self.panel_zuijia.panel_1.mc_2:showFrame(tonumber(FuncChar.getBorderFramByQuality(quality) ) )
    self.panel_zuijia.panel_1.txt_3:setString(data.lv)
    self.panel_zuijia.panel_1.mc_2.currentView.ctn_1:addChild(_spriteIcon )
    self.panel_zuijia.panel_1.mc_dou:showFrame(star)
    local nextPer
    if data.value == 0 or maxValue == 0 then
        nextPer = 0
    else
        nextPer = math.round(data.value/maxValue*100)
    end
    self.panel_zuijia.panel_progress.progress_1:setPercent(0)
    self.panel_zuijia.panel_progress.progress_1:tweenToPercent(nextPer)
    self.panel_zuijia.panel_progress.txt_1:setString(string.format("%s/%s",math.round(data.value),maxValue))

end
return BattleTrialResult