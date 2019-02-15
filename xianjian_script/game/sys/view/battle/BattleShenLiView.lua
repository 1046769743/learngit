-- 
-- Author: pangkangning
-- Note: 共闯秘境UI
-- Date: 2018-05-15 
--
-- BattleGuildSpiritPowerView
local BattleShenLiView = class("BattleShenLiView", UIBase)

function BattleShenLiView:ctor(winName,controler)
    BattleShenLiView.super.ctor(self, winName)
    self.controler = controler
    self._spArr = {} -- 神力数据
    self._selectIdx = 1 --选中的神力(默认选中第一个)
end
function BattleShenLiView:loadUIComplete(controler)

    self.panel_5.btn_close:setTap(c_func(self.closeSpiritPowerView,self))
    self.btn_shiyongshenli:setTap(c_func(self.useSpiritPower,self))

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_shiyongshenli,UIAlignTypes.MiddleBottom)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SPIRIT_RECOMMEND, self.onSpiritRecommend, self)

    self.panel_shenlixiangqing.panel_yituijian:visible(false)
end
-- 更新神力数据相关
function BattleShenLiView:showSpiritView( )
    local spArr = self.controler.artifactControler:getSpiritPowerArr()
    if #spArr ~= 3 then
        echoError ("神力数据不对-应该有三个才对")
        return 
    end
    self._spArr = {}
    for k,v in pairs(spArr) do
        local node = self.panel_5["panel_shenli"..k]
        node.panel_tuijian:visible(false)
        node.ctn_1:setTouchedFunc(c_func(self.onSpiritClick,self,view,k),nil,true)
        local csData = FuncGuildBoss.getConcertSkillDataById(v.id)
        table.insert(self._spArr,{data = v,view = node,cfgData = csData})
        -- 更新技能图标
        if node.iconSp then
            node.iconSp:removeFromParent()
            node.iconSp = nil
        end
        node.iconSp = display.newSprite(FuncRes.iconSkill(csData.icon)):addTo(node.ctn_1)
    end
    -- 默认选择第一个神力数据用于展示
    self:updateTipInfo(self._selectIdx)
    self:updateViewShow()
end
-- 更新神力使用方的ui
function BattleShenLiView:updateViewShow( )
    local isMy = self.controler.artifactControler:checkIsMeUseSpirit()
    if isMy then
        self.panel_5.btn_close:visible(true)
        self:checkUseOrRecommend(true)
    else
        self.panel_5.btn_close:visible(false)
        self:checkUseOrRecommend(false)
    end
end
-- 更新推荐
function BattleShenLiView:onSpiritRecommend( event )
    local haveRecomend = false
    for k,v in pairs(self._spArr) do
        -- 是否是推荐的
        if v.data.isRecomend == Fight.spiritPower_recomend then
            v.view.panel_tuijian:visible(true)
            if self._selectIdx == k then
                self.panel_shenlixiangqing.panel_yituijian:visible(true)
                haveRecomend = true
            end
        else
            v.view.panel_tuijian:visible(false)
        end
    end
    if not haveRecomend then
        self.panel_shenlixiangqing.panel_yituijian:visible(false)
    end
end
-- 更新神力tip显示与否
function BattleShenLiView:updateTipInfo(idx)
    local spiritInfo = self._spArr[idx]
	-- 获取神力显示详情
	self.panel_shenlixiangqing:visible(b)
    self.panel_shenlixiangqing.txt_1:setString(GameConfig.getLanguage(spiritInfo.cfgData.name))
    self.panel_shenlixiangqing.txt_2:setString(GameConfig.getLanguage(spiritInfo.cfgData.describe))
    -- 更新高亮与否
    for k,v in pairs(self._spArr) do
        if idx == k then
            v.view.mc_1:showFrame(2)
        else
            v.view.mc_1:showFrame(1)
        end
    end
    self:onSpiritRecommend()
end
-- 更新神力推荐的显示与否
function BattleShenLiView:updateRecomendInfo(sid)
    for i=1,3 do
        local node = self.panel_5["panel_shenli"..i]
        -- 显示神力
        if sid == node.__sid then
            node.panel_tuijian:visible(true)
        else
            node.panel_tuijian:visible(false)
        end
    end
end
-- 更新神力的使用方式
function BattleShenLiView:updateSPUseInfo( sid )
    -- self.panel_toptips.
end
-- 更新使用神力、取消使用
function BattleShenLiView:checkUseOrCancel(use)
    if use then
        self.btn_shiyongshenli:visible(true)
        self.btn_fanhui2:visible(false)
        self:checkUseOrRecommend(true)
    else
        self.btn_shiyongshenli:visible(false)
        self.btn_fanhui2:visible(true)
    end
end
-- 是推荐还是使用神力
function BattleShenLiView:checkUseOrRecommend(use)
    if use then
        self.btn_shiyongshenli:getUpPanel().mc_1:showFrame(1)
        self.panel_xuanzetips.mc_1:showFrame(1)
    else
        self.btn_shiyongshenli:getUpPanel().mc_1:showFrame(2)
        self.panel_xuanzetips.mc_1:showFrame(2)
    end
end
-- 使用神力
function BattleShenLiView:useSpiritPower( )
    local spiritInfo = self._spArr[self._selectIdx]
    local isMy = self.controler.artifactControler:checkIsMeUseSpirit()
    if isMy then
        -- 切面关闭，然后弹使用方式
        -- 使用一个神力
        self.controler.gameUi.gpPowerView:updateSpiritUse(true,spiritInfo.data.id)
    else
        self.controler.server:sendRecommendOneSpirit({sid=spiritInfo.data.id})
    end
end
function BattleShenLiView:closeSpiritPowerView( )
    -- 发送服务器，取消使用神力
    self.controler.server:sendEndSpiritRound()
end
-- 点击了哪个神力
function BattleShenLiView:onSpiritClick(btn,idx )
    self._selectIdx = idx
    self:updateTipInfo(self._selectIdx)
end
return BattleShenLiView
