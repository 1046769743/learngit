--
-- Author: gs
-- Date: 2016-10-12 14:51:47
--
local BattlePVEHpView = class("BattlePVEHpView", UIBase)

local SkillCfg = require("battle.Skill")

local _progressBg ={
    [1] = "battle_progress_hong1.png",
    [2] = "battle_progress_hong2.png",
    [3] = "battle_progress_cheng1.png",
    [4] = "battle_progress_cheng2.png",
    [5] = "battle_progress_huang1.png",
    [6] = "battle_progress_huang2.png",
    [7] = "battle_progress_lan1.png",
    [8] = "battle_progress_lan2.png",
    [9] = "battle_progress_lanlv1.png",
    [10] = "battle_progress_lanlv2.png",
    [11] = "battle_progress_qianlv1.png",
    [12] = "battle_progress_qianlv2.png",
    [13] = "battle_progress_shenlv1.png",
    [14] = "battle_progress_shenlv2.png",
    [15] = "battle_progress_zi1.png",
    [16] = "battle_progress_zi2.png"
}
local HpBarType = {
    HIDE = 0, --不显示
    BOSS= 1, --显示boss血条
    LEVEL = 2 --显示关卡血条
}

function BattlePVEHpView:loadUIComplete(  )
    FuncCommUI.setViewAlign(self.widthScreenOffset,self,UIAlignTypes.LeftTop)

    --FuncCommUI.setViewAlign(self.widthScreenOffset,self.scale9_bg,UIAlignTypes.LeftBottom)

    --FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDSTART, self.onRoundStart, self)
    
    self.mc_1:visible(false)
    self.mc_2:visible(false)
    self.mc_3:visible(false)
    self.panel_bossskill1:visible(false)
    self.panel_bossskill2:visible(false)
    self.panel_3:visible(false)

    self._hpBarType = HpBarType.HIDE
end


-- function BattlePVEHpView:initView(  )
--     if self.controler then
--         --先不加载Icon
--         --self:loadMainHeroIcon()
--     end
    
    
--     self:visible(false)
--     --self:initHpProgress()

-- end


function BattlePVEHpView:initControler( view,controler )
    self:visible(false)
	self._battleView = view
	self.controler = controler
    --波数发生变化
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_NEXTWAVE, self.onWaveChanged, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SHOW_SKILLICON, self.onWaveChanged, self)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_LEVEL_HP_SHOW, self.onWaveChanged, self)
    
end


--波数变化
function BattlePVEHpView:onWaveChanged()
    if self.controler and self.controler:chkIsXvZhang() then
        return
    end
    self:checkMainHero()
    if self._hpBarType ~= HpBarType.HIDE then
        self:visible(true)
    end
end
--[[
获取主英雄
]]
function BattlePVEHpView:checkMainHero(  )
    -- 切波的时候需要修改一下
    self._hpBarType = HpBarType.HIDE
    local wave = self.controler:getCurrentWave()
    local count = self.controler.levelInfo:getPveBossHpInfo(wave)
    local camp2 = self.controler.campArr_2
    if count and count > 0 then
        self._hpBarType = HpBarType.LEVEL
        -- 这里显示的是总的怪血量
        self._levelHpIcon = {}
        local currHp,maxHp = 0,0
        for k,v in ipairs(camp2) do
            currHp = currHp + v.data:hp()
            maxHp = maxHp + v.data:maxhp()
            v.data:addEventListener(BattleEvent.BATTLEEVENT_CHANGEHEALTH, 
                                    c_func( self.onHpChanged ,self), self)
            self._levelHpIcon[v.data.hid] = {icon = v.data:getIcon(),currHp = currHp}
            if k == 1 then
                self:updateLevelIcon(v.data:getIcon())
            end
        end
        self:loadHPInfo(maxHp,currHp,count)

        self.txt_name:setString(GameConfig.getLanguage("#tid_shareboss_407"))
    else
        for k,v in ipairs(camp2) do
            if v.data:hpCount() > 0  then
                self._hpBarType = HpBarType.BOSS
                self:loadMainHeroInfo(v)
                break
            end
        end
    end
end
-- 初始化boss的信息
function BattlePVEHpView:loadMainHeroInfo(mainHero)
    self.mainHero = mainHero
    
    local count = mainHero.data:hpCount()
    local maxHp = mainHero.data:maxhp()
    local currHp = mainHero.data:hp()
    self:loadHPInfo(maxHp,currHp,count)

    self:loadMainHeroIcon()
    self:initSkillIcon()
    mainHero.data:addEventListener(BattleEvent.BATTLEEVENT_CHANGEHEALTH, c_func( self.onHpChanged ,self), self)
    -- 更新技能图标
    self:updateSkillIcon()
end
-- 加载血条相关
function BattlePVEHpView:loadHPInfo(maxHp,currHp,count)
    -- 初始化血条数
    local per = maxHp/count -- 每一管血对应的血量
    self.mainHpArr = {} --初始化的时候直接存储每一管血对应的具体最大值最小值
    for i=1,count do
        local tmpCount
        if i == 1 then
            tmpCount = 1 --只有第一管血是红色的
        else
            tmpCount = ((i-1)%7)*2 + 1 
            if tmpCount == 1 then
                tmpCount = 15
            end
        end
        -- bgIdx:是对应的图片底图信息
        local tmp = {idx = i,min=math.ceil((i-1)*per),max=math.ceil(i*per),bgIdx = tmpCount}
        if count == i then
            tmp.max = maxHp
        end
        table.insert(self.mainHpArr,tmp)
    end
    -- 设置血条的缓动方向及开始的值
    for i=1,3 do
        self.panel_1["progress_"..i]:setDirection(ProgressBar.l_r)
        self.panel_1["progress_"..i]:setPercent(100)
    end
    self:udpateHpInfo(currHp,true)
end
-- 更新血条相关的数据信息
function BattlePVEHpView:udpateHpInfo(currHp,isFirst)
    -- local currHp = self.mainHero.data:hp()
    -- 显示几管血数字
    local currHpInfo
    for i,v in ipairs(self.mainHpArr) do
        if currHp >= v.min and currHp <= v.max then
            currHpInfo = v
            break
        end
    end
    if not currHpInfo then
        return
    end
    currHpInfo.p = math.ceil(100 * (currHp - currHpInfo.min) /(currHpInfo.max - currHpInfo.min ))
    -- 初始化一些需要缓动的参数
    local state = 1
    if isFirst then
        state = 0
    end
    self:_setOldHpInfo(currHpInfo,state)
    self.currHpInfo = currHpInfo
    self:updateHpProgress(currHp) --更新hp进度
    self:updateHpShow() --更新hp血条数目
end
-- 设置旧的血量值 state:0初始化 1在缓动中 -1缓动结束
function BattlePVEHpView:_setOldHpInfo(currHpInfo,state)
    -- 如果正在缓动，则不需要设置p值
    if self._oldCurrHpInfo and (self._oldCurrHpInfo.state == 0 or self._oldCurrHpInfo.state == 1) then
        return
    end
    self._oldCurrHpInfo = table.copy(currHpInfo)
    self._oldCurrHpInfo.state = state
end
function BattlePVEHpView:updateHpShow( )
    if self.controler and self.controler:chkIsXvZhang() then
        return
    end
    if self.controler:isQuickRunGame() then
        return
    end
    local tmpIdx = self.currHpInfo.idx
    local tmpArr = {}
    for i=1,999 do
        local a,b = math.modf(tmpIdx/10)
        table.insert(tmpArr,math.round(b*10))
        if a == 0 then
            break
        else
            tmpIdx = a
        end
    end
    local maxCount = 4
    -- dump(tmpArr,"s===")
    if #tmpArr > maxCount then
        echoError ("血条数不能超过999条")
        return
    end
    for i=1,maxCount do
        if i <= #tmpArr then
            -- 显示对应的值
            self["mc_"..i]:visible(true)
        else
            self["mc_"..i]:visible(false)
        end
    end
    -- 不是只有一管血的时候，需要显示X 符号
    -- if #tmpArr > 1 and tmpArr[1] > 1 then
        self["mc_"..(#tmpArr+1)]:visible(true) --显示X、所有多显示一位
        self["mc_1"]:showFrame(11) --第一位显示x
        -- 显示对应的值
        local j = 1
        for i=#tmpArr,1,-1 do
            j = j + 1
            -- echo("jjj",i,j,tmpArr[i] + 1)
            if self["mc_"..j] then
                self["mc_"..j]:showFrame(tmpArr[i] + 1)
            end
        end
    -- else
    --     self["mc_1"]:showFrame(tmpArr[1] + 1)
    -- end
end
-- 更新血条的显示
function BattlePVEHpView:updateHpProgress(currHp)
    if self.controler:isQuickRunGame() then
        return
    end
    local p = math.ceil(100 * (currHp - self.currHpInfo.min) /(self.currHpInfo.max - self.currHpInfo.min ))

    -- dump(self.currHpInfo,"s====")
    -- echo("--now---percent======",p,self.currHpInfo.idx)
    local bgSp = FuncRes.iconBar(_progressBg[self.currHpInfo.bgIdx])
    self.panel_1.progress_3:setBarSprite(bgSp)
    self.panel_1.progress_3:setPercent(p)
    local nowIdx = self.currHpInfo.idx
    if nowIdx == 1 then
        -- 只有一管血了
        self.panel_1.progress_1:visible(false) --背景血层隐藏
    else
        nowIdx = self.currHpInfo.idx -1
        local tmpIdx = self.mainHpArr[nowIdx].bgIdx
        local tmpSp = FuncRes.iconBar(_progressBg[tmpIdx])
        self.panel_1.progress_1:visible(true) -- 显示背景层的血条、并且是下一管血颜色
        self.panel_1.progress_1:setPercent(100)
        self.panel_1.progress_1:setBarSprite(tmpSp)
    end
    if p < self._oldCurrHpInfo.p or self.currHpInfo.idx < self._oldCurrHpInfo.idx then
        if self._oldCurrHpInfo.state == 0 then
            self._oldCurrHpInfo.state = 1
            -- echo("需要缓动===",p,self._oldCurrHpInfo.p,self.currHpInfo.idx,self._oldCurrHpInfo.idx)
            -- 说明需要缓动
            self:delayCall(c_func(self.updateHpPercentAnim,self),0.2) --延迟一下
        end
    else
        -- 加血、不做缓动特效
        if p > self._oldCurrHpInfo.p then
            self._oldCurrHpInfo.state = -1
            self:_setOldHpInfo(self.currHpInfo,0)
            self.panel_1.progress_2:setPercent(p)
        end
        local tmpIdx = self.mainHpArr[nowIdx].bgIdx
        local tmpSp = FuncRes.iconBar(_progressBg[tmpIdx+1])
        self.panel_1.progress_2:setBarSprite(tmpSp)
        self.panel_1.progress_2:setPercent(p)
    end
end
-- 血条缓动
function BattlePVEHpView:updateHpPercentAnim()
    local newPercent = self.currHpInfo.p
    local isSub = false
    if self.currHpInfo.idx < self._oldCurrHpInfo.idx then
        self.panel_1.progress_3:visible(false)
        newPercent = 0
        isSub = true
    else
        -- 此时在显示前景血条
        self.panel_1.progress_3:visible(true)
    end
    local time = math.ceil(self.panel_1.progress_2:getPercent() - newPercent)/5
    -- echo("缓动====",newPercent,isSub,time)
    self.panel_1.progress_2:tweenToPercent(newPercent,time,function( )
        -- 更新值
        if self.currHpInfo.idx >= self._oldCurrHpInfo.idx and
            newPercent <= self.currHpInfo.p then
            self._oldCurrHpInfo.state = -1
            self:_setOldHpInfo(self.currHpInfo,0)
            self.panel_1.progress_2:setPercent(self.currHpInfo.p)
            -- echo("缓动结束===")
            return
        end
        if isSub then
            self.panel_1.progress_2:setPercent(100)
            -- 切回背景层
            self._oldCurrHpInfo.bgIdx = self._oldCurrHpInfo.bgIdx - 2
            if self._oldCurrHpInfo.bgIdx == 1 then
                self._oldCurrHpInfo.bgIdx = 15
            end
            -- 降一格血
            self._oldCurrHpInfo.idx = self._oldCurrHpInfo.idx - 1
            local tmpIdx = self._oldCurrHpInfo.bgIdx+1
            if self.currHpInfo.idx == 1 then
                tmpIdx = self.currHpInfo.bgIdx+1 --最后一格血的缓动血条不需要变化
            end
            local tmpSp = FuncRes.iconBar(_progressBg[tmpIdx])
            self.panel_1.progress_2:setBarSprite(tmpSp)
        end
        self:updateHpPercentAnim()
    end) 
end

--加载头像(关卡血条的时候，头像会频繁的变，消耗性能的)
function BattlePVEHpView:loadMainHeroIcon(heroModel)
    heroModel = heroModel or self.mainHero
    if heroModel then
        local icon = FuncRes.iconHead(heroModel.data:getHeadIcon())  --FuncRes.iconHero(hid)
        local iconSp = display.newSprite(icon)
        iconSp:size(90,90)
        self.panel_2.ctn_1:removeAllChildren()
        self.panel_2.ctn_1:addChild(iconSp)
        local name = heroModel.data:getName()
        self.txt_name:setString(name)
    end
end
--[[
检查当前以后多少个技能
显示buff技能图标
]]
function BattlePVEHpView:initSkillIcon(  )
    if self.mainHero and self.mainHero.data then
        local allBuff = self.mainHero.data.hpAiObj:getAllBuffInfo()
        allBuff = table.values(allBuff)

        -- echo("所有的buff-----------------")
        -- dump(allBuff)
        -- echo("所有的buff-----------------")
        self.skillIconView ={}          --保存所有的view对象
        for kk,vv in pairs(allBuff) do
            if vv.replace == 1 then --当vv.replace = 2时是试炼buff掉落
                local view = UIBaseDef:cloneOneView( self.mc_bufferObj )
                local icon = ObjectBuff.new(vv.id):sta_icon()
                view:showFrame(1)
                --echo("当前的icon")
                if icon == nil then icon = "battle_img_bianshen" end
                view.currentView.ctn_1:addChild(display.newSprite(FuncRes.icon( "buff/"..icon..".png" )))
                view:showFrame(2)
                view.currentView.ctn_2:addChild(display.newSprite(FuncRes.icon( "buff/"..icon.."2.png" )))
                self.skillIconView[tostring(vv.id)] = view
                --view:pos((kk-1)*40-(#allBuff)*40/2,0)
                view:pos((kk-1)*40-120,16)
                self.ctn_bufferjineng:addChild(view)
            end
        end
        self:checkSkillIcon()
    end
end


--[[
判断buff技能图标是否激活
]]
function BattlePVEHpView:checkSkillIcon(  )
    if self.mainHero and self.mainHero.data then
       local allActiveBuff = self.mainHero.data.hpAiObj:getActiveBuffInfo()
       -- echo("所有激活的buff")
       -- dump(allActiveBuff)
       -- echo("所有激活的buff")
       local chkExist = function ( key )
           for kk,vv in pairs(allActiveBuff) do
               if tostring(vv.id) == tostring(key) then
                return true
               end
           end
           return false
       end
       if self.skillIconView then
           for k,v in pairs(self.skillIconView) do
               if chkExist(k) then
                    v:showFrame(1)
                else
                    v:showFrame(2)
               end
           end
        end
    end
end

--当boss血量发生改变的时候
function BattlePVEHpView:onHpChanged()
    local currHp = 0

    -- self._levelHpIcon[v.data.hid] = {icon = v.data:getIcon(),currHp = currHp}
    local _icon = nil
    if self._hpBarType == HpBarType.LEVEL then
        -- 这里显示的是总的怪血量
        for k,v in ipairs(self.controler.campArr_2) do
            local tmpHp = v.data:hp()
            local tmpValue = self._levelHpIcon[v.data.hid]
            currHp = currHp + tmpHp
            if tmpValue and  tmpValue.currHp ~= tmpHp and (not _icon) then
                _icon = tmpValue.icon
            end
            self._levelHpIcon[v.data.hid].currHp = tmpHp
        end
        -- 更新谁被打了
        if _icon then
            self:updateLevelIcon(_icon)
        end
    else
        currHp = self.mainHero.data:hp()
    end
    self:udpateHpInfo(currHp)
end
-- 更新关卡血条的图像及名字
function BattlePVEHpView:updateLevelIcon(iconStr )
    local tmpArr = self.panel_2.ctn_1._iconArr
    if not tmpArr then
        self.panel_2.ctn_1._iconArr = {}
        tmpArr = self.panel_2.ctn_1._iconArr
    end
    local icon = FuncRes.iconHead(iconStr)
    local iconSp = display.newSprite(icon)
    iconSp:size(90,90)
    if not tmpArr[iconStr] then
        tmpArr[iconStr] = iconSp
        -- self.panel_2.ctn_1:removeAllChildren()
        self.panel_2.ctn_1:addChild(iconSp)
    else
        for k,v in pairs(tmpArr) do
            if k == iconStr then
                v:visible(true)
            else
                v:visible(false)
            end
        end
    end
end

function BattlePVEHpView:pressSkillViewDown(view)
    if not view.skillDB then
        return
    end
    local x,y = view:getPosition()
    self.panel_3:setPosition(x + 60,y)
    self.panel_3:visible(true)
    self.panel_3.txt_2:setString(GameConfig.getLanguage(view.skillDB.name))
    self.panel_3.rich_1:setString(GameConfig.getLanguage(view.skillDB.skillTips))
end
function BattlePVEHpView:pressSkillViewUp(view)
    if not view.skillDB then
        return
    end
    self.panel_3:visible(false)
end

-- 显示技能图标
function BattlePVEHpView:updateSkillIcon( )
    local _loadSkillIcon = function ( skillId,idx )
        local view = self["panel_bossskill"..idx]
        view:visible(true)
        view.ctn_1:removeAllChildren()
        local skillDB = SkillCfg[tostring(skillId)]
        if not skillDB then
            echoError("未获取到技能数据",skillId)
            return
        end
        if not skillDB.skillIcon then
           view:visible(false)
           return
        end
        -- 添加技能图标
        display.newSprite( FuncRes.iconSkill(skillDB.skillIcon)):addTo(view.ctn_1):scale(0.66)
        view.skillDB = skillDB
        if not view._init then
            view._init = true
            view:setTouchedFunc(GameVars.emptyFunc, nil, true, c_func(self.pressSkillViewDown, self,view), nil,false,c_func(self.pressSkillViewUp, self,view) )
        end
    end
    local treasureData = self.mainHero.data.curTreasure
    -- echoError("aa===:",self.mainHero.data.curTreasure.hid,"b=b==")
    -- dump(treasureData.skill3,"s===",3)
    if treasureData.skill4 then
        if treasureData.skill3 then
            _loadSkillIcon(treasureData.skill3.hid,1)
        end
        _loadSkillIcon(treasureData.skill4.hid,2)
    else
        if treasureData.skill3 then
            _loadSkillIcon(treasureData.skill3.hid,1)
        end
        if treasureData.skill2 then
            _loadSkillIcon(treasureData.skill2.hid,2)
        end
    end
end



return BattlePVEHpView