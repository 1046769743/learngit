--
-- Author: dou
-- Date: 2014-03-10 14:18:29
--
ModelEffectNum = class("ModelEffectNum", ModelBasic)

ModelEffectNum.target = nil --跟随对象
ModelEffectNum.info = nil --跟随信息
ModelEffectNum.frame =0 

-- 记录调用次数，使第一次时可以正常显示
ModelEffectNum.__count = 0 

--目前8个特效 分别是 动画名字,flash对应的mc名字,文字宽高
local typeToAniNameObj = {
    ["1"] = {"common_num_putongshanghai","mc_shanghai",40,44},             --普通减血 
    ["2"] = {"common_num_baojishanghai","mc_baoji",50,60},              --暴击减血

    ["7"] = {"common_num_zhiliao","mc_zhiliao",42,44},                --普通加血
    ["8"] = {"common_num_jianuqi","mc_nuqi",42,44},                 --普通加法力
    ["9"] = {"common_num_jiannuqi","mc_nuqi",42,44},                --普通减法力
    ["13"] = {"common_num_jinengjianxue","mc_shanghai",40,44},             --技能减血
    ["20"] = {"common_num_shanbi","miss",20,24},           --闪避
}

function ModelEffectNum:ctor( ...)
    self.modelType = Fight.modelType_effect
	ModelEffectNum.super.ctor(self,...)
	--特效 深度排列类型优先级比较高
	self.depthType = 9
    self.totalFrame =0
	self.data = {}
end



function ModelEffectNum:setInfo(target,ctn, type,num )

	local node = self:createHurtLable(type,num)
    node:zorder(target.__zorder + 1)
    self.totalFrame = 35
    node:setScaleX(Fight.cameraWay )

    --存储目标
    self.target = target

    local numeEffArr = self.target.__numEffArr
    --临时特效数组
    if not numeEffArr then
        self.target.__numEffArr = {self}
        numeEffArr =self.target.__numEffArr
    else
        --来一个特效就插入一个特效
        table.insert(numeEffArr, 1,self)
    end

    local heiOff = 22

    --echo(#numeEffArr,type,"___特效长度----")
    self:initView(ctn,node,target.pos.x,target.pos.y,target.pos.z-target.data.viewSize[2] - 38 )

    -- self.myView.currentAni:playWithIndex(0, false)
    -- self.myView:delayCall(c_func(self.myView.currentAni.playWithIndex,self.myView.currentAni,1, false), self.myView.currentAni.totalFrame/GameVars.GAMEFRAMERATE )
    -- self.myView.currentAni:runEndToNextLabel(0, 1, false)
    for i,v in ipairs(numeEffArr) do
        local yIndex = i %20
        if yIndex ==0 then
            yIndex = 20
        end

        v:setPos(self.pos.x -(i-1)*0*self.target.way ,self.pos.y,0-target.data.viewSize[2] - 38 - (yIndex-1) * heiOff )
        --进行跳帧
        -- if i < #numeEffArr then
        --      -- v.myView.currentAni:removeFrameCallFunc()
        --     if v.myView.currentAni:getAnimation():getMovementCount() <2 then
        --         echoWarn("动画"..v.myView.currentAni:getName().."_的帧标签少于2个")
        --     else
        --         --todo
        --     end

        --     -- v.myView.currentAni:playWithIndex(1, false)
        -- end
        --相对缩放
        -- v.myView:setScale(math.pow(0.95,i-1))
    end

end

--创建挨打效果
function ModelEffectNum:createHurtLable(type,num)
    -- body
    -- type = 2

    local cfg = typeToAniNameObj[tostring(type)]
    
    if not cfg then
        echoWarn("错误的数字特效类型:",type)
        return display.newNode()
    end

    local aniName = cfg[1]

    local view = ViewArmature.new(aniName)

    if type == 20 then
        return view
    end

    local bone = view.currentAni:getBone("node")

    local mcCfg = UIBaseDef:getUIChildCfgs("UI_battle_public",cfg[2])
    num = math.ceil(num)
    if bone then

        --那么创建数字特效
        local params = {
            uiCfg = mcCfg,
            number = num > 0 and ("+"..num) or num,
            width = cfg[3],
            halign = "center",
            valign = "center",
            height = cfg[4],
        }

        --如果是暴击减血
        if tostring(type) =="2" then
            params.number = math.abs(num)
            params.halign = "left"
        end

        if view.currentAni._numNode then 
            view.currentAni._numNode:setString(params.number)
        else
            local mcView = NumberEffect.new(params)
            FuncArmature.changeBoneDisplay(view.currentAni, "node", mcView)
            view.currentAni._numNode = mcView
        end

        
    end

    return view

end





--根据类型判定坐标
function ModelEffectNum:turnFollowPos(  )
	
	self:setWay(self.target.way)
	self.pos.x = self.target.pos.x +  self.pianyiPos.x * way
	self.pos.y =self.target.pos.y +  self.pianyiPos.y 
	self.pos.z = self.target.pos.z +  self.pianyiPos.z 
end


function ModelEffectNum:runBySpeedUpdate( )
    self:realPos(self)
    self.updateCount = self.updateCount + 1
    -- --如果是最后一帧
    -- if self.updateCount <= 20 then
    --     if self.target.__leftNumFrame > 0 then
    --         self.target.__leftNumFrame = self.target.__leftNumFrame -1
    --         --如果目标
    --         if self.target.__leftNumFrame <=0 then
    --             self.target.__numEffs =0
    --         end
    --     end
    -- end


    if self.updateCount % 3 ==1 then
        -- self.myView:zorder(self.target.__zorder +1)
    end

    if self.updateCount == self.totalFrame then

        if self.target.__numEffArr then
            table.removebyvalue(self.target.__numEffArr, self)
        end

        self:deleteMe()
    end

end


--创建得分总伤害 totalDamage  总伤害  heroArr命中的英雄数组 
function ModelEffectNum:createTotalDamage(totalDamage)
    local middlePos = BattleControler.gameControler.middlePos
    if BattleControler.gameControler:isQuickRunGame() then
        return
    end

    if Fight.isDummy then
        return
    end
    local ypos = 400
    local zpos = 0
    --如果小于100 return
    -- if totalDamage < 100 then
    --     return
    -- end

    if totalDamage > 9999999 then
        totalDamage = 9999999
    end
    totalDamage = math.round(totalDamage)

    local titleEff = BattleControler.gameControler.__totalDamageEff

    if not titleEff then
        titleEff = FuncArmature.createArmature("UI_zhandou_zongshanghai", BattleControler.gameControler.gameUi._root, false, GameVars.emptyFunc)
        titleEff:pos(GameVars.halfResWidth ,-510)
        FuncCommUI.setViewAlign(self.widthScreenOffset,titleEff,UIAlignTypes.MiddleBottom)

        BattleControler.gameControler.__totalDamageEff = titleEff
        --按照帧播放
        titleEff:getAnimation():setTimelineType(1)
        titleEff.__oldDmg = 0
        --0:第一次出现，1:如果在播放
        titleEff.__statusLabel = 0
        titleEff.__isEnd = false
        titleEff.__count = 0
    end
    -- 数字对应的动画
    local numberAnim = titleEff:getBoneDisplay("layer10_copy")
    local zhezhaoAnim = titleEff:getBoneDisplay("layer11")


    -- titleEff:stopAllActions()
    titleEff:removeFrameCallFunc()
    titleEff:visible(true)
    -- 根据伤害获取对应帧数
    local getShowFrameIndex = function( dmg )
        for i=1,3 do
            numberAnim:getBone("node"..i):visible(true)
            zhezhaoAnim:getBone("node"..i):visible(true)
        end
        local frameIdx
        --7位数
        if     dmg >= 1000000 then
            frameIdx = 5
        elseif dmg >= 100000 then
            frameIdx = 4
        elseif dmg >= 10000 then
            frameIdx = 3
        elseif dmg >= 1000 then
            frameIdx = 2
        else
            frameIdx = 1
            if dmg >= 100 then
            elseif dmg >= 10 and dmg < 100 then
                numberAnim:getBone("node3"):visible(false)
                numberAnim:getBone("node2"):visible(true)
                zhezhaoAnim:getBone("node3"):visible(false)
                zhezhaoAnim:getBone("node2"):visible(true)
            elseif dmg >= 0 and dmg < 10 then
                numberAnim:getBone("node3"):visible(false)
                numberAnim:getBone("node2"):visible(false)
                zhezhaoAnim:getBone("node3"):visible(false)
                zhezhaoAnim:getBone("node2"):visible(false)
            end
        end
        return frameIdx
    end
    local turnNumFrame = function (dmg)
        local strDamage = tostring(dmg)
        local strLeng = string.len(strDamage)
        for i=1,strLeng do
            local childAni = numberAnim:getBoneDisplay("node"..i)
            local childzAni = zhezhaoAnim:getBoneDisplay("node"..i)
            local numFrame = tonumber( string.sub (strDamage,i,i) )
            numFrame = numFrame == 0  and 10 or numFrame
            childAni:playWithIndex(numFrame-1)
            childzAni:playWithIndex(numFrame-1)
        end
        local frameff = getShowFrameIndex(dmg)
        numberAnim:gotoAndPause(frameff)
        zhezhaoAnim:gotoAndPause(frameff)
        -- echo("当前数字、伤害、总伤害====",dmg,titleEff.__currDmg,titleEff.__oldDmg)
    end
    -- 创建缓动特效
    local createFromToFrame = function()
        -- echo("bb---",titleEff.__statusLabel,titleEff.__currDmg,titleEff.__oldDmg)
        if titleEff.__statusLabel ~= 2 then
            -- 如果还没到总伤害显示的阶段，则显示伤害=总伤害
            if titleEff.__statusLabel < 2 then
                titleEff.__currDmg = titleEff.__oldDmg
            end
            turnNumFrame(titleEff.__currDmg)
            return
        end
        local _cDmg,_tDmg = titleEff.__currDmg,titleEff.__oldDmg

        local tmpDmg = _tDmg - _cDmg
        if tmpDmg > 0 then
            -- 分5帧播放
            local totalFrame = 1
            if tmpDmg > 5 then
                totalFrame = 5
            end
            local frameInc = math.ceil(tmpDmg/totalFrame) --每一帧增长的伤害值
            -- echo("分帧播放暗===",totalFrame,frameInc)
            -- 设置正确的值
            local setFrameNum = function (  )
                titleEff.__currDmg = titleEff.__currDmg + frameInc
                if titleEff.__currDmg > _tDmg then
                    titleEff.__currDmg = _tDmg
                end
                turnNumFrame(titleEff.__currDmg)
            end
            for i=1,totalFrame do
                numberAnim:delayCall(setFrameNum,i/GameVars.GAMEFRAMERATE )
            end
        else
            turnNumFrame(_tDmg)
        end
    end
    -- titleEff:removeFrameCallFunc()
    -- 播放标签
    local _playEffNum = function(labelIdx,callback)
        if labelIdx == 3 and not titleEff.__isEnd then
            return
        end
        createFromToFrame()
        titleEff.__statusLabel = labelIdx
        titleEff:removeFrameCallFunc()
        titleEff:playWithIndex(labelIdx, false)
        turnNumFrame(titleEff.__currDmg) --没换一次标签都需要重新先设置一次伤害数字
        if callback then
            titleEff:doByLastFrame(false,false,function( )
                callback()
            end)
        end
    end
    -- 根据statusLabel播放对应的动画
    local _playAnim = function(sLabel )
        if sLabel == 0 then
            _playEffNum(0,function( )
                _playEffNum(1,function( )
                    _playEffNum(2,function( )
                        _playEffNum(3)
                    end)
                end)
            end)
        elseif sLabel == 1 then
            _playEffNum(1,function( )
                _playEffNum(2,function( )
                    _playEffNum(3)
                end)
            end)
        elseif sLabel == 2 then
            _playEffNum(2,function( )
                _playEffNum(3)
            end)
        elseif sLabel == 3 then
            titleEff:stopAllActions()
            titleEff:gotoAndPause(48)
            if not titleEff.__isEnd then
                return
            end
            titleEff:delayCall(function( )
                _playEffNum(3)
            end, 5/GameVars.GAMEFRAMERATE )
        end
    end
    if titleEff.__count == 0 then
        -- 第一个人去打（总伤害动画未播放过），第一个atk伤害作用的同时，播放总伤害素材
        titleEff.__currDmg = totalDamage
        titleEff.__oldDmg = totalDamage
        titleEff.__statusLabel = 0
        titleEff.__isEnd = false
        -- 所有label动画都归零
        for i=1,5 do
            for j=1,7 do
                local childAni = numberAnim:getBoneDisplay("node"..i)
                if childAni then
                    childAni:playWithIndex(1)
                end
            end
        end
        _playAnim(0)
    else
        local currFrame = titleEff:getCurrentFrame()
        -- echo("标签:%s 帧:%s,总次数:%s,是否结束:%s伤害:%s--总伤害:%s",
        --     titleEff.__statusLabel,currFrame,titleEff.__count,titleEff.__isEnd,
        --     titleEff.__oldDmg,totalDamage)
        if titleEff.__statusLabel == 0 then
            titleEff.__oldDmg = totalDamage
            _playAnim(1)
        elseif titleEff.__statusLabel == 1 then
            if currFrame < 7 then
                titleEff.__oldDmg = totalDamage
                _playAnim(2)
            end
        elseif titleEff.__statusLabel == 2 then
            if currFrame < 37 then
                titleEff.__oldDmg = totalDamage
            else
                titleEff.__oldDmg = totalDamage
                if titleEff.__isEnd then
                    _playAnim(3)
                end
            end
        elseif titleEff.__statusLabel == 3 then
            titleEff.__oldDmg = totalDamage
            if titleEff.__isEnd then
                _playAnim(3)
            end
        end
    end

    titleEff.__count = titleEff.__count + 1
    -- 创建缓动动画
    createFromToFrame()

    -- 设置一个技能释放结束的状态
    function titleEff:setShowEnd( )
        if titleEff.__isEnd then
            return
        end
        titleEff.__isEnd = true
        titleEff.__count = 0
        -- local currFrame = titleEff:getCurrentFrame()

        if titleEff.__statusLabel <= 2 then
            titleEff:delayCall(function( )
                _playEffNum(3)
            end, 10/GameVars.GAMEFRAMERATE )
        end
    end
end

-- 显示总伤害

--创建怒气伤害
--chance 1出现  2  增加 3是最后一个
-- 废除chance 因为判定存在很多问题2017.9.1
function ModelEffectNum:createSkillDamage( totalDamage,chance)
    if Fight.isDummy  then
        return
    end

    local middlePos = GameVars.width/2

    local lastEff = BattleControler.gameControler.__skillDamageEff 
    if BattleControler.gameControler:isQuickRunGame() then
        return
    end

    if not lastEff then
        local gameui = BattleControler.gameControler.gameUi
        --先创建标题动画
        lastEff = FuncArmature.createArmature("UI_zhandou_nvqishanghai", gameui._root, false, GameVars.emptyFunc)
     
        lastEff:pos(50,-100)

        FuncCommUI.setViewAlign(gameui.widthScreenOffset,lastEff,UIAlignTypes.LeftTop)
        BattleControler.gameControler.__skillDamageEff  = lastEff
        lastEff.numNodeArr = {}
        -- lastEff:setScaleX(Fight.cameraWay )

        -- local childAni1 = lastEff:getBoneDisplay("layer11")
        local childAni2 = lastEff:getBoneDisplay("layer1")

        -- lastEff.numNode1  = display.newNode()
        lastEff.numNode2  = display.newNode()
        -- FuncArmature.changeBoneDisplay( childAni1,"layer3",lastEff.numNode1,  0 )
        FuncArmature.changeBoneDisplay( childAni2,"layer3",lastEff.numNode2,  0 )
        lastEff:getAnimation():setTimelineType(1)
    else
        lastEff:visible(true)
    end

    if totalDamage > 99999 then
        totalDamage = 99999
    end
    totalDamage = math.round(totalDamage)
    
    local createAni = function (ani, x,y,fromIndex,toIndex )
        ani = ani and ani  or FuncArmature.createArmature("UI_zhandou_212",lastEff.numNode2,true)
        ani:pos(x,y)
        -- echo(fromIndex,toIndex,"_________aaaaaaaaaaa")
        ani:stopAllActions()
        -- if fromIndex == toIndex then
        --     ani:gotoAndPause(fromIndex)
        -- else
        -- 按照上面的写法，非第一次创建的情况，有时候会发生显示不全的问题2017.7.25
        if true then
            ani:gotoAndPlay(fromIndex)
            local stopAni = function (  )
                ani:gotoAndPause(toIndex)
            end
            local dxFrame = toIndex - fromIndex
            if dxFrame < 0 then
                dxFrame = dxFrame +10
            end
            -- dxFrame = dxFrame +10
            ani:delayCall(stopAni, dxFrame/GameVars.GAMEFRAMERATE )
            -- ani:registerFrameEventCallFunc(toIndex,1,c_func(stopAni,ani,toIndex))
        end
        return ani
    end


    local strDamage = tostring(totalDamage)
    
    local xoff =-12
    local numWidth = 40
    local strLeng = string.len(strDamage)
    local targetX =0
    local numNodeArr = lastEff.numNodeArr

    for i,v in pairs(numNodeArr) do
        v:visible(false)
    end
    -- echo(totalDamage,"_______________技能当前伤害",strLeng)
    for i=1, strLeng do
        targetX = (i-1)*numWidth  + xoff
        local numFrame = tonumber( string.sub (strDamage,i,i) )
        local fromFrame = 1
        local oldAni = numNodeArr[strLeng - i +1]
        numFrame = numFrame == 0 and 10 or numFrame
        if oldAni then
            oldAni:visible(true)
            --如果是初始化 那么fromFrame 从10开始
            -- if chance == 1 then

            -- else
                fromFrame = oldAni:getCurrentFrame()
                fromFrame = fromFrame > 10 and 10 or fromFrame
            -- end

            -- echo(oldAni,fromFrame, numFrame,"__________",i)
            createAni(oldAni,targetX,0,fromFrame, numFrame)
        else
            numNodeArr[strLeng - i +1] = createAni(nil,targetX,0,fromFrame, numFrame)
            -- echo("新建ani",fromFrame, numFrame,"__________",i)
        end
    end


    local hidNode = function (  )
        lastEff:visible(false)
        -- 归零
        for _,ani in ipairs(numNodeArr) do
            ani:gotoAndPause(10)
        end
    end

    local delayPlay = function (  )
        lastEff:playWithIndex(1, false)
        lastEff:delayCall(hidNode,1)
    end
    --先停止action
    lastEff:stopAllActions()
    lastEff:removeFrameCallFunc()
    lastEff:visible(true)

    -- 记录调用次数，使第一次时可以正常显示（因为用chance来判断是否是第一次伤害已经不准确了）
    self.__count = self.__count + 1

    -- 给一个隐藏方法
    if not lastEff.hideEff then
        local this = self
        function lastEff:hideEff()
            if not self.hasExeHide then
                lastEff:delayCall(delayPlay,0.8)
                self.hasExeHide = true
                this.__count = 0
            end
        end
    end
    -- 记录是否执行过隐藏操作
    lastEff.hasExeHide = false
    --[[
    --如果是最后一次伤害 那么0.3秒以后 隐藏
    if chance == 3 then
        echo("__延迟隐藏")
        lastEff:stopAllActions()
        lastEff:delayCall(delayPlay,1.2)
        lastEff.hasExeHide = true
    --如果是初始化
    elseif chance == 1 then

        lastEff:playWithIndex(0, false)
    --如果是单次伤害
    elseif chance == 4 then
        lastEff:playWithIndex(0, false)
        lastEff:stopAllActions()
        lastEff:delayCall(delayPlay,2)
        lastEff.hasExeHide = true
    end
    ]]
    if self.__count == 1 then
        lastEff:playWithIndex(0, false)
    end

    return lastEff
end


function ModelEffectNum:deleteMe( ... )
	ModelEffectNum.super.deleteMe(self,...)
	self.target = nil
end


return ModelEffectNum