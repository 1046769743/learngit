--
-- Author: xiangdu
-- Date: 2014-01-02 10:21:52
--战斗中一些视图表达的控制器,主要是为了分担 logicalControler的压力
--
ViewPerformControler = class("ViewPerformControler")

function ViewPerformControler:ctor(controler )
    self.controler = controler
    self.logical = controler.logical
end

-- 被打的人阵位表现（显示）
function ViewPerformControler:checkElementPerform( hero, skill )
     if self.controler:isQuickRunGame() then
        return
    end
    -- 控制器
    local fControler = self.controler.formationControler
    -- 被强化了的人
    local tHeroArr = {}
    -- 被打的人
    local heroArr = AttackChooseType:getSkillCanAtkEnemy( hero,skill )
    for _,tHero in ipairs(heroArr) do
        local flag = fControler:isHeroEnhanceDef(tHero, hero:getHeroElement()) 
        -- 受到了加强和攻击者不同阵营（同阵营不是攻击行为）
        if flag and hero.camp ~= tHero.camp then
            table.insert(tHeroArr, tHero)
        end
    end

    if #tHeroArr > 0 then
        local blackFrame  = skill:sta_blackFrame() or 0
        fControler:showHitEnhanceDefElement(tHeroArr, tHeroArr[1].camp, blackFrame ~= 0)
    end
end

--半透当前回合 非相关操作人员
function ViewPerformControler:checkRelation(hero, skill,outBlack ,onlySign )
    if Fight.isDummy then
        return
    end

    -- if self.controler:isQuickRunGame() then
    --     return
    -- end

    local heroArr = {}
    local blackFrame  = skill:sta_blackFrame() or 0
    
    -- if not onlySign then
    --     if not outBlack then
    --         -- FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = self.currentCamp == 1 and 2 or 1,visible = false})
    --     else
    --     end
    -- end
    
    if outBlack then
        blackFrame = 0
    end
    if onlySign then
        blackFrame = 20
    end
    if Fight.isDummy then
        blackFrame = 0
    end

    local attackInfos = skill.attackInfos
    local heroArr = AttackChooseType:getSkillCanAtkEnemy( hero,skill )
    -- 2018.6.22 又修改成敌方所有人都在最高层级，但是不挨打的置暗
        
    if Fight.isDummy  then
        return true
    end

    if self.controler:isQuickRunGame() then
        return true
    end

    --如果黑屏
    if blackFrame > 0 then
        -- 攻击者的层级应该比其他人要高2017.9.5
        self.controler:showBlackScene()
        -- 所有敌人全部提高
        for i,v in ipairs(hero.toArr or {}) do
            -- if blackFrame > 0 and not onlySign then
                v:onSkillBlack()
            -- end
        end
        -- 2018.6.22 又修改成敌方所有人都在最高层级，但是不挨打的置暗
        -- 所有相关人提高
        for i,v in ipairs(heroArr) do
            v:onSkillBlack()
        end

        hero:onSkillBlack(Fight.zorder_blackChar + 100)
    end
    -- 处理相关人明暗
    self:setHeroViewAlpha(heroArr,hero,outBlack)
    return true
end


--让我能打到的人忽闪忽闪
function ViewPerformControler:setHeroCanAttackPerform(hero  )
     if self.controler:isQuickRunGame() then
        return
    end
    local skill = hero:getNextSkill()
    local chooseArr = AttackChooseType:getSkillCanAtkEnemy(hero,skill,true)
    local enemyArr = {}
    for i,v in ipairs(chooseArr) do
        --必须是 敌方才有这个忽闪效果s
        if  v.camp  ~= hero.camp and not v.randomHero then
            table.insert(enemyArr, v)
        end
    end
    self:setGroupViewAlpha(hero.toArr,130)

    --让这个组的人 闪现
    self:setGroupViewAlpha(enemyArr,255,130,0.3)

end



--再封装一个和流程无关的相关人员亮，无关人员暗
function ViewPerformControler:setHeroLightOrDark(lightHeroArr,darkHeroArr)
    if self.controler:isQuickRunGame() then
        return
    end
    local light = 255 -- 亮就是正常颜色
    local dark = 0.3 * 255

    if lightHeroArr then
        for _,hero in ipairs(lightHeroArr) do
            hero:tinyToColor(0.2, light)
        end
    end

    if darkHeroArr then
        for _,hero in ipairs(darkHeroArr) do
            hero:tinyToColor(0.2, dark)
        end
    end
end

--让相关人员亮  无关人员按
function ViewPerformControler:setHeroViewAlpha( heroArr,hero ,outBlack )
    -- 不做亮暗处理了2017.8.31
    -- 又做亮暗处理了2017.11.20
    -- if true then
    --     return
    -- end
    if self.controler:isQuickRunGame() then
        return
    end

    local targetOff = 0.3 * 255
    if hero and  hero.camp == 1 then
        --那么要比其他人亮一些
        targetOff = 0.3* 255
    end
    local targetOff2 = 0.3 * 255
    -- 隐藏自己血条
    hero.data:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = hero.camp,visible = false})
    for k,v in pairs(hero.campArr) do
        if not table.indexof(heroArr,v) then
            if  v ~= hero then
                --如果已经攻击了 那么需要更暗一些
                if self.currentCamp == v.camp  and  v.hasOperate and (not self:checkIsInQuene(v) ) then
                    v:tinyToColor(0.2, targetOff2)
                else
                    v:tinyToColor(0.2, targetOff)
                end
                
            else
                v:tinyToColor(0.2, 255)
            end
            if not outBlack then
                -- 取消让己方血条隐藏2017.8.2
                if v ~= hero then
                    v.data:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = v.camp,visible = true})
                end
            end
            
        else
            v:tinyToColor(0.2, 255)
            if not outBlack then
                -- v.data:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = v.camp,visible = true})
            end
        end
    end

    for k,v in pairs(hero.toArr) do
        if not  table.indexof(heroArr,v) and v ~= hero then
            v:tinyToColor(0.2, targetOff2)
            if not outBlack then
                -- 取消让敌方血条隐藏2017.8.2
                v.data:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = v.camp,visible = true})
            end
        else
            v:tinyToColor(0.2, 255)
            if not outBlack then
                -- v.data:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = v.camp,visible = true})
            end
        end
    end
end

--回合前 让敌对阵营的人暗 减少对他们的点击欲望 
function ViewPerformControler:setGroupViewAlpha( campArr,alpha,tweenColor,time)
     if self.controler:isQuickRunGame() then
        return
    end
    time = time or 0.2
    alpha = alpha or 255
    for i,v in ipairs(campArr) do
        v:tinyToColor(time, alpha,tweenColor)
    end
end

--回合结束 复原透明度
function ViewPerformControler:resumeViewAlpha( isEndRound )
    if Fight.isDummy then
        return
    end
     if self.controler:isQuickRunGame() then
        return
    end
    -- 去掉明暗变化，简单屏蔽(2017.7.14)
    local attakedLight= 1 * 255
    -- local attakedLight= 0.5 * 255

    if isEndRound then
        
    end
    local targetLight = 255
    for k,v in pairs(self.controler.campArr_1) do
        if isEndRound then
            if not v.data:checkCanAttack() and self.currentCamp == v.camp then
                v:tinyToColor(0.2,attakedLight)
            else
                v:tinyToColor(0.2,targetLight)
            end
            
        else
            --如果已经有攻击而且不在队列里面；并且不是正在攻击的人2017.7.4
            if v.hasOperate and (not self.logical:checkIsInQuene(v) ) and v ~= self.logical.attackingHero then
                v:tinyToColor(0.2,attakedLight)
            elseif not v.data:checkCanAttack() and self.currentCamp == v.camp then
                v:tinyToColor(0.2,attakedLight)
            else
                v:tinyToColor(0.2,targetLight)
            end
        end
        
    end

    for k,v in pairs(self.controler.campArr_2) do
        if not v.data:checkCanAttack() and self.currentCamp == v.camp then
            v:tinyToColor(0.2,attakedLight)
        else
            v:tinyToColor(0.2,targetLight)
        end
    end

end


--创建一个空地面特效
function ViewPerformControler:createAtkUseEff( posArr )
     if self.controler:isQuickRunGame() then
        return
    end
    if self._atkUseEffMap then
        for k,v in pairs(self._atkUseEffMap) do
            v:removeFromParent()
        end
    end
    self._atkUseEffMap = {}
    for i,v in ipairs(posArr) do
        local posIndex = v.posIndex
        local pos = v.pos
        local ani = self._atkUseEffMap[posIndex]
        if not ani then
            self._atkUseEffMap[posIndex] = FuncArmature.createArmature("UI_zhandou_jihuomubiao", nil, true) 
            ani = self._atkUseEffMap[posIndex]
            -- ani:addto(self.controler.layer:getGameCtn(1),100)
            ani:addto(self.controler.layer.a122,Fight.zorder_formation + 20)
        end
        ani:pos(pos.x,-pos.y)
        ani:visible(true)
        if v.camp == 2 then
            ani:setScaleX(-1)
        end

    end

end

--隐藏所有的AtkUseEff
function ViewPerformControler:hideAllAtkUseEff(  )
     if self.controler:isQuickRunGame() then
        return
    end
    if not self._atkUseEffMap then
        return
    end

    for k,v in pairs(self._atkUseEffMap) do
        v:setVisible(false)
    end
end