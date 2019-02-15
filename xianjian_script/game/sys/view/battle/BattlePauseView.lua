local BattlePauseView = class("BattlePauseView", UIBase);


function BattlePauseView:ctor(winName,controler)
    BattlePauseView.super.ctor(self, winName);
    self.controler = controler
end

function BattlePauseView:loadUIComplete()
    -- local coverView = WindowControler:createCoverLayer(nil, nil, GameVars.bgAlphaColor ):addto(self,-2)
	self:registerEvent();
end
-- 音效
function BattlePauseView:yinxiaoClick( )
    if AudioModel:isSoundOn() then
        LS:pub():set(StorageCode.setting_sound_st, FuncSetting.SWITCH_STATES.OFF)
    else
        LS:pub():set(StorageCode.setting_sound_st, FuncSetting.SWITCH_STATES.ON)
    end
    self:updateVoiceStatus()
end
-- -- 音乐
-- function BattlePauseView:yinyueClick( )
--     if AudioModel:isMusicOn() then
--         LS:pub():set(StorageCode.setting_music_st, FuncSetting.SWITCH_STATES.OFF)
--     else
--         LS:pub():set(StorageCode.setting_music_st, FuncSetting.SWITCH_STATES.ON)
--     end
--     self:updateVoiceStatus()
-- end
-- -- 更新音效音乐界面
-- function BattlePauseView:updateVoiceStatus()
--     -- 如果音效没开启，则进度条也设置为0、否则读取存储的音效值来这是进度
--     if not AudioModel:isSoundOn() then
--         self.panel_bg.panel_1:visible(true)
--         self.panel_bg.slider_r:setPercent(0)
--     else
--         self.panel_bg.panel_1:visible(false)
--         self.panel_bg.slider_r:setPercent(AudioModel:getSoundVolume()*100)
--     end
--     if not AudioModel:isMusicOn() then
--         self.panel_music.panel_1:visible(true)
--         self.panel_music.slider_r:setPercent(0)
--     else
--         self.panel_music.panel_1:visible(false)
--         self.panel_music.slider_r:setPercent(AudioModel:getMusicVolume()*100)
--     end
-- end

function BattlePauseView:registerEvent()
	BattlePauseView.super.registerEvent()
    -- 标题
    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid2282"))
    self.panel_bg.panel_1:visible(false)
    self.panel_music.panel_1:visible(false)
    -- 音效
    self.panel_bg.slider_r:setMinMax(0, 100)
    self.panel_bg.slider_r:setPercent(AudioModel:getSoundVolume()*100)
    self.panel_bg.slider_r:setTouchEnabled(true)
    -- android机型下卡顿，所以先注释掉看看好没好
    -- local soundChange = function (...)
    --     local per = math.floor(self.panel_bg.slider_r:getPercent()/10)
    --     AudioModel:setSoundVolume(per/10,true)
    -- end
    -- self.panel_bg.slider_r:onSliderChange(soundChange)

    local soundSliderEnd = function( per )
        per = math.floor(per/10)
        AudioModel:setSoundVolume(per/10)
    end
    self.panel_bg.slider_r:onSliderEnd(soundSliderEnd)

    -- self.panel_bg.btn_1:setTap(c_func(self.yinxiaoClick, self)) --先预留着，怕以后改回来
    self.panel_bg.btn_1:setTap(function( )
        AudioModel:setSoundVolume(0)
        self.panel_bg.slider_r:setPercent(0)
    end)
    -- panel_s
    -- progress_s
    -- 音量
    self.panel_music.slider_r:setMinMax(0,100)
    self.panel_music.slider_r:setPercent(AudioModel:getMusicVolume()*100)
    self.panel_music.slider_r:setTouchEnabled(true)

    -- local musicChange = function (...)
    --     local per = math.floor(self.panel_music.slider_r:getPercent()/10)
    --     AudioModel:setMusicVolume(per/10,true)
    -- end
    -- self.panel_music.slider_r:onSliderChange(musicChange)
    local musicSliderEnd = function( per )
        per = math.floor(per/10)
        AudioModel:setMusicVolume(per/10)
    end
    self.panel_music.slider_r:onSliderEnd(musicSliderEnd)
    self.panel_music.btn_1:setTap(function( )
        AudioModel:setMusicVolume(0)
        self.panel_music.slider_r:setPercent(0)
    end)
    -- self.panel_music.btn_1:setTap(c_func(self.yinyueClick, self))
    -- self:updateVoiceStatus()
    -- progress_s
    -- panel_s

    self.UI_1.btn_close:setTap(c_func(self.closePauseView, self))
    self.UI_1.mc_1:visible(false)
    self.btn_1:setTap(c_func(self.resumeBattle, self)) --继续游戏
    self.btn_2:setTap(c_func(self.reStartBattle, self))-- 重新开始
    self.btn_3:setTap(c_func(self.exitBattle, self))-- 退出游戏 

    if TutorialManager.getInstance():isShieldBattleExit() then
        FilterTools.setGrayFilter(self.btn_3)
        self.btn_3:setTap(function()
             WindowControler:showTips({text = GameConfig.getLanguage("#tid6014")})
        end)
    end

    -- 只有在多人试炼中才会有这个界面的监听、防止当打开战斗暂停的时候游戏结束了，会造成返回按钮的错乱
    if BattleControler:checkIsTrail() ~= Fight.not_trail  then
        EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_REWARD,self.onGameOver,self)
    end
end

function BattlePauseView:onGameOver(event)
    self:startHide()
    -- echo("战斗结束界面、如果有暂停界面，则需要关闭掉、主要是多人试炼中")
end
--关闭按钮
function BattlePauseView:closePauseView()
    self:startHide()
    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_GAMEPAUSE )
end

--退出战斗
function BattlePauseView:exitBattle()
    
    self:startHide()
    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SUREQUIT )
    -- WindowControler:showBattleWindow("BattlePauseTipView",Fight.pause_quit,function()
    --     self:startHide()
    --     FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SUREQUIT )
    -- end)
    self.controler:doClientAction(2)
end

--恢复暂停
function BattlePauseView:resumeBattle()
    self:startHide()
    FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_GAMEPAUSE )
end
-- 重新开始
function BattlePauseView:reStartBattle( )

    self:startHide()
    BattleControler:restartBattle()
    -- WindowControler:showBattleWindow("BattlePauseTipView",Fight.pause_restart,function()
    --     self:startHide()
    --     BattleControler:restartBattle()
    -- end)
end





function BattlePauseView:updateUI() 
    
end


return BattlePauseView;
