-- 试炼战斗中掉落的buff
-- Author: pangkangning
-- Date: 2017-07-20
--
ViewBuff = class("ViewBuff", function ( )
    return display.newNode()
end)

function ViewBuff:ctor(controler,buffInfo,x,y)
    self.controler = controler
    self._clickDownOffset = nil
    self._laseSelectHero = nil
    self._buffInfo = buffInfo
    self.canDrop = true --是否可以z拖拽
    -- self:anchor(0,0)
    -- self:setInitPos(cc.p(x,y))
    self:setInitPos(cc.p(0,0))

    self:addBuffIcon()
    self:addLongTouch()

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_BATTLESTATE_CHANGE, self.onBattleStateChange, self)
end
function ViewBuff:setInitPos( pos )
     self._initPos =pos
end
-- 添加buff图像
function ViewBuff:addBuffIcon( )
    local buffData = ObjectCommon.getPrototypeData("battle.Buff",self._buffInfo.buffId)
    if not buffData.extraIcon then
        echoError ("掉落buff未配置buff图标",self._buffInfo.buffId)
        return
    end
    local iconSp =  display.newSprite(FuncRes.iconBuff(buffData.extraIcon)):addto(self)
end
-- -- 添加动画、test
-- function ViewBuff:addAnimature( )
--     self.particalNode = FuncArmature.getParticleNode( "buff_tuowei" ):addTo(self)
--     self.particalNode:setStartColor(cc.c4b(0,234/255, 1,1))
--     self.particalNode:setEndColor(cc.c4b(0,234/255,1,1))
--     self:updatePVisible(false)

--     self.ani = gameUi:createUIArmature("UI_zhandou","UI_zhandou_diaobaoxiang", self, false,function( )
--     self.ani:getBoneDisplay("a1"):playWithIndex(self:getFrameIndex(self._drop.id))
-- end

function ViewBuff:getFrameIndex(buffid )
    local buffData = ObjectCommon.getPrototypeData("battle.Buff",buffid)
    local _type = buffData.type
    if _type == Fight.buffType_gongji then
        return 1
    elseif _type == Fight.buffType_baoji then 
        return 3
    elseif _type == Fight.buffType_trialAddChoose then
        return 4
    elseif _type == Fight.buffType_nuqi then
        return 5
    elseif _type == Fight.buffType_HOT then
        return 6
    elseif _type == Fight.buffType_hudun then
        return 7
    elseif _type == Fight.buffType_bingtai then
        return 2
    elseif _type == Fight.buffType_jinghua_hao then
        return 8
    end
    echoError("Buff未找到对应的帧数 id:",buffid)
    return 0
end

function ViewBuff:onBattleStateChange( )
    -- 当是我方回合的时候，才能拖拽
    local bState = self.controler.logical:getBattleState()
    if bState == Fight.battleState_formation then
        self:updateTexiao(true)
        self:opacity(255)
    else
        self:updateTexiao(false)
        self:opacity(125)
    end
end
-- 添加拖拽事件
function ViewBuff:addLongTouch( )
    local nd = display.newNode()
    local viewSize = {width=100,height=100}
    nd:setContentSize(cc.size(viewSize.width,viewSize.height) )
    -- local viewSize = self.ani:getContentSize()
    -- echo("aabb--",viewSize.width,viewSize.height)
    -- nd:setContentSize(cc.size(viewSize.width*2,viewSize.height*2) )--为了方便点击、所以放大一倍
    nd:addto(self,-1)
    nd:anchor(0.5,0.5)
    nd:setTouchedFunc(GameVars.emptyFunc, nil, true, 
        c_func(self.pressClickBuffViewDown, self), c_func(self.pressClickViewMove, self),
        false,c_func(self.pressClickBuffViewUp, self) )
end

-- 检查buff是否能拖拽
function ViewBuff:chkCanDrop( )
    if self.canDrop == false then
        return false
    end
    if self.controler.logical.currentCamp ~= 1 then
        return false
    end
    -- 只有在布阵状态才可以拖拽
    local bState = self.controler.logical:getBattleState()
    if bState ~= Fight.battleState_formation then
        return false
    end
    -- 回合结->回合开始这个阶段也不能拖拽
    if bState == Fight.battleState_wait or bState == Fight.battleState_battle or
        bState == Fight.battleState_switch then
        return false
    end
    return true
end
-- 获取发送的参数
function ViewBuff:getTmpInfo(htype,rid)
    local info = {htype=htype,rid = rid or nil,bId=self._buffInfo.bId,bType = 
                Fight.drop_buff,buffId=self._buffInfo.buffId}
    return info
end

function ViewBuff:pressClickBuffViewDown(event)
    if not self:chkCanDrop() then
        return
    end
    local dx = (event.x - self._initPos.x )*Fight.cameraWay
    local dy = self._initPos.y-event.y
    self._clickDownOffset = {dx,dy}

    local server = self.controler.server

    local info = self:getTmpInfo(Fight.trial_buffHand)
    server:sendHeroPickBuffHandle(info)
    -- 添加拖拽的时候显示的buff文字详情
    if not self.showAnim then
        self.showAnim = ViewArmature.new("common_zishanshuo"):addto(self)

        local buffData = ObjectCommon.getPrototypeData("battle.Buff",self._buffInfo.buffId)
        local frame = Fight.buffMapFlowWordHao[buffData.type]
        if not frame then
            echoError("试炼bufftype:%s没有对应的显示帧--使用默认帧代替",buffData.type)
            frame = 1
        end
        --跳到对应的帧上
        ModelEffectBasic:checkShowBuffBone(self.showAnim.currentAni:getBone("layer1"),frame,Fight.buffKind_hao,false)

        self.showAnim.currentAni:setScaleX(-Fight.cameraWay )
        self.showAnim:pos(0,80)
    end
    self.showAnim:visible(true)
end
function ViewBuff:pressClickViewMove(event)
    if not self._clickDownOffset then return end
    self:updatePVisible(true)
    self:updateTexiao(false)
    local targetX = event.x*Fight.cameraWay - self._clickDownOffset[1]
    local targetY = event.y + self._clickDownOffset[2]
    self:pos(-targetX,targetY)

    local pos = self.controler.layer.a122:convertToNodeSpaceAR(event)
    local heroObj,index= self:getTargetHero(pos.x,-pos.y)
    if heroObj then
        if self._laseSelectHero then
            if self._laseSelectHero == heroObj then 
                return 
            end
            self._laseSelectHero.myView:opacity(255)
        end
        -- 判断角色是否是我方的
        if heroObj.data.characterRid == self.controler:getUserRid() then

            local trialType = BattleControler:checkIsTrail()
            
            self._laseSelectHero = heroObj
            heroObj.myView:opacity(100)
        end
    else
        if self._laseSelectHero then 
            self._laseSelectHero.myView:opacity(255)
            self._laseSelectHero = nil
        end
    end
end
function ViewBuff:pressClickBuffViewUp(event)
    if self.showAnim then self.showAnim:visible(false) end
    if not self._clickDownOffset then return end
    local targetX = event.x*Fight.cameraWay - self._clickDownOffset[1]
    local targetY = event.y + self._clickDownOffset[2]
    self:pos(-targetX,targetY)

    local pos = self.controler.layer.a122:convertToNodeSpaceAR(event)
    local heroObj,index = self:getTargetHero(pos.x,-pos.y)
    if not heroObj then
        -- 拖拽到角色icon身上也可以
        local tmpHero = self.controler.gameUi.icon_view:chkPosIsInHeadIcon(event)
        if tmpHero then
            heroObj = tmpHero
            index = tmpHero.data.posIndex
        end
    end

    -- 额外增加是否是我方玩家判断、比如敌方玩家刚刚换到这个位置、但是不是我方的
    if heroObj and heroObj.data.characterRid == self.controler:getUserRid() then
        if self.controler:chkTrialGuideBuff() then
            --发送消息   关闭新手引导
            EventControler:dispatchEvent(TutorialEvent.TUTORIAL_SLIDE_OVER_EVENT )
        end
        if not self:chkCanDrop() then
            self:_resetBuff()
            return
        end
        -- self:resetBuffPos(true)
        local server = self.controler.server

        local info = self:getTmpInfo(Fight.trial_buffUse,heroObj.data.rid)
        server:sendHeroPickBuffHandle(info)
        return
    end
    -- BattleControler.gameControler
    self:_resetBuff() 
end
function ViewBuff:_resetBuff( )
    transition.moveTo(self,
        {x =self._initPos.x, y = self._initPos.y, time =0.2,
        -- easing = "exponentialIn",
        onComplete = c_func(self.resetBuffPos, self,false)
        }) 
end
-- 重置buff数据、比如拖拽失败、回合开始等 isPick:true 已经拾取
function ViewBuff:resetBuffPos(isPick)
    if self._laseSelectHero then
        self._laseSelectHero.myView:opacity(255)
        self._laseSelectHero = nil
    end
    self._clickDownOffset = nil
    if not isPick then
        self:updatePVisible(false)
        self:pos(self._initPos.x,self._initPos.y)
        self:updateTexiao(true)
        local info = self:getTmpInfo(Fight.trial_buffOff)
        if not self.controler:isReplayGame() then
            self.controler.server:sendHeroPickBuffHandle(info)
        end
    end
end
function ViewBuff:getTargetHero(posx,posy )
    local targetObj,index = self.controler:getAreaTargetByPos(Fight.camp_1,posx,posy)
    if targetObj then
        return targetObj,index
    else
        return nil
    end
end
-- 设置是否可拖拽
function ViewBuff:setCanDrop(canDrop )
    self.canDrop = canDrop
end
-- 添加特效
function ViewBuff:addTeXiao( )
    local anim = self.controler.gameUi:createUIArmature("UI_shilian_zhandou",
        "UI_shilian_zhandou_buffjihuo", self, false,GameVars.emptyFunc)
    self:delayCall(function ( ... )
        self.xhAnim = self.controler.gameUi:createUIArmature("UI_shilian_zhandou",
            "UI_shilian_zhandou_buff_xunhuan", self, true,GameVars.emptyFunc)
    end,0.8)
end
function ViewBuff:updateTexiao( value )
    if self.xhAnim then
        self.xhAnim:visible(value)
    end
end
-- 更新粒子特效的显隐
function ViewBuff:updatePVisible(value )
    if self.particalNode then
        self.particalNode:visible(value)
    end
end
