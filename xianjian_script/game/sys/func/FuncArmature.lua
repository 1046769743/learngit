FuncArmature=FuncArmature or {}

local flashArmatureCfgData 
local spineArmatureCfgData 
if not DEBUG_SERVICES  then
    flashArmatureCfgData = Tool:configRequire("viewConfig.AnimationConfig")
    spineArmatureCfgData = Tool:configRequire("viewConfig.SpineAniConfig")
end






local armatureSpeed = 1

local ArmatureExpand = {}
function ArmatureExpand:gotoAndPause(frame )
    self:getAnimation():gotoAndPause(frame)
    return self
end


--让某一个动画播放某个后播放这个动画的另外一个label
--fromLabelIndex 起始标签index, nextLabelIndex下一个标签的index,是否循环下一个标签 0或者空不循环 1或者true和循环
function ArmatureExpand:runEndToNextLabel( fromLabelIndex,nextLabelIndex ,isCycle,hide,stopframe)
    self:removeFrameCallFunc()
    isCycle = isCycle and isCycle or false
    if not hide then
        hide = false
    end
    -- body
    self:playWithIndex(fromLabelIndex,0)

    --停留时间
    if stopframe then
        self:delayCall(c_func(self.playWithIndex, self,nextLabelIndex,isCycle,hide),stopframe/GameVars.GAMEFRAMERATE )
    else
        self:delayCall(c_func(self.playWithIndex, self,nextLabelIndex,isCycle,hide),self:getAnimation():getRawDuration()/GameVars.GAMEFRAMERATE )
    end
    

    -- self:registerFrameEventCallFunc(self:getAnimation():getRawDuration()-1,1,)

end

--让所有子动画都只播放一次
function ArmatureExpand:setAllChildAniPlayOnce(  )
    local children = self:getChildren()
    for i,v in ipairs(children) do
        --必须是bone
        if tolua.type(v) == "pc.Bone" then

            local disObj = v:getDisplayManager():getDecorativeDisplayByIndex(0)
     
            if disObj then
                local disView = disObj:getDisplay()
                if tolua.type(disView) == "pc.Armature" then
                    disView:getAnimation():playWithIndex(0,0,0)
                end
            end
        end
    end
end



--播放某一个动画
function ArmatureExpand:playWithIndex( labelIndex, isCycle,hide )
    labelIndex = labelIndex or 0 
    if isCycle ==0 then
        isCycle = 0
    else
        isCycle = isCycle and 1 or 0
    end
    FuncArmature.playOrPauseArmature(self, true)
    self:resumeArmature()
    self:getAnimation():playWithIndex(labelIndex,0,isCycle)
    if hide then
        self:doByLastFrame(false, true)
    end
end




function ArmatureExpand:gotoAndPlay(frame )
    self:getAnimation():gotoAndPlay(frame)
    return self
end

--1 是正 2是反向
function ArmatureExpand:setWay( way )
    self:getAnimation():setWay(way)
end

--隐藏某个bone
function ArmatureExpand:visibleBone(boneName, value)
    local bone = self:getBone(boneName)
    if bone then
        bone:setVisible(value)
    end
    
    return self
end


--获取一个bone的显示对象  index  表示显示的是第几个 默认为0
function ArmatureExpand:getBoneDisplay(boneName,index )
    index = index or 0
    local bone = self:getBone(boneName)
    if not bone  then
        echo("错误的bone:",boneName)
        return nil
    end
    local disObj = bone:getDisplayManager():getDecorativeDisplayByIndex(index)
    if not disObj then
        return nil
    end
    local ani = disObj:getDisplay()
    if tolua.type(ani) == "pc.Armature"  then
        --那么扩展这个对象
        ArmatureExpand.extend(ani)
    end
    return ani
end

--获取一个bone当前index的显示对象
function ArmatureExpand:getCurIndexBoneDisplay(boneName)
    local bone = self:getBone(boneName)
    if not bone then
        echo("错误的bone:",boneName)
        return nil
    end
    local disObj = bone:getDisplayManager():getCurrentDecorativeDisplay()
    if not disObj then
        echo("没有获取到")
        return nil
    end
    local ani = disObj:getDisplay()
    if tolua.type(ani) == "pc.Armature"  then
        --那么扩展这个对象
        ArmatureExpand.extend(ani)
    end
    return ani
end

--这里暂停 会停住子动画 ignoreChild 是否 忽略子动画,默认 是让子动画一起停住
function ArmatureExpand:pause(ignoreChild )
    if ignoreChild then
        self:getAnimation():pause()
    else
        FuncArmature.playOrPauseArmature(self, false )
    end
   
    -- self:getAnimation():pause()
    return self
end
--播放 让子动画播放nag ignoreChild 是否 忽略子动画 ,默认让子动画一起播放
function ArmatureExpand:play( ignoreChild )
    if ignoreChild then
        self:getAnimation():resume()
    else
        FuncArmature.playOrPauseArmature(self, true )
    end
    
    -- self:getAnimation():resume()
end

function ArmatureExpand:getCurrentFrame( )
    return self:getAnimation():getCurrentFrameIndex()
end


--开始播放  
-- stopChild 是否停子动画,默认不停止 
-- isHide 是否隐藏
function ArmatureExpand:startPlay(isCycle, stopChild ,isHide)
    local index = isCycle and 1 or 0
    self:resumeArmature()
    self:visible(true)
    self:gotoAndPlay(1)
    local tempFunc = function (  )
        if stopChild then
            self:pause()
        else
            self:pause(true)
        end
        if isHide then
            self:visible(true)
        end
    end
    if isHide or stopChild  then
        self:doByLastFrame(false,false,tempFunc)
    end
    



    self:getAnimation():playWithIndex(0,0,index)
    return self
end




--设置停止到最后一帧 clear 是否销毁 ,  hide 是否隐藏,   callBack  回调函数
function ArmatureExpand:doByLastFrame( clear, hide ,callBack)
    local func = function (  )
        self._actionDelay = nil
        local totalFrame = self:getAnimation():getRawDuration()

        if callBack then
            if hide then
                self:gotoAndPause(totalFrame)
                self:pause()
                self:visible(false)
            end

            callBack()
        else
            self:gotoAndPause(totalFrame)
            if clear then
                self:pause()
                self:visible(false)
                self:removeFromParent(true)
                -- self:delayCall(c_func(self.clear,self,true), 0.001 )
            elseif hide then
                self:visible(false)
                self:pause()
            else
                self:pause()

            end
        end
    end
    -- self._actionDelay = self:delayCall(func, (self.totalFrame )/GameVars.GAMEFRAMERATE )
    -- 1表示回调1次
    self:getAnimation():registerFrameEventCallFunc(self:getAnimation():getRawDuration(),1,func)

end
--resumeArmature 复原动画 重新调用播放动画的时候 一般要注意 resumeArmature
--play的时候 默认复原一次
--给动画注册回调 
function ArmatureExpand:registerFrameEventCallFunc( frame,times,func )
    frame = frame or self.totalFrame
    times = times or 1
    self:getAnimation():registerFrameEventCallFunc(frame,times,func)
end

--移除动画注册的回调
function ArmatureExpand:removeFrameCallFunc(  )
    self:getAnimation():removeFrameCallFunc()
end


--让动画从指定的帧循环 播放
function ArmatureExpand:setCycle( startFrame,endFrame )
    
    if (not startFrame) or (not endFrame) then
        return
    end
    local totalFrame = self.totalFrame
    local listener = function ( dt )
        if self:getAnimation():getCurrentFrameIndex() == endFrame or self:getAnimation():getCurrentFrameIndex() == (endFrame +1) then
            self:getAnimation():gotoAndPlay(startFrame)
        end
    end
    --ani:scheduleUpdateWithPriorityLua(listener, 0)
    self:schedule(listener, 1/GameVars.GAMEFRAMERATE )
end

--注入扩展方法
function ArmatureExpand.extend( ani )
    for k,v in pairs(ArmatureExpand) do
        ani[k] = v
    end
end

--[[

Armature :gotoAndPause(frameIndex) 停止到某一帧
          gotoAndPlay(frameIndex)  从某一帧开始播放

          virtual void gotoAndPlay(int frameIndex);

     pause();
     resume();
     stop();
    totalFrame 获取某个动画的 长度
    
    备注:如果有 换装操作  比如 吧nodeA  替换ani 的某个bone  
    bone播放完毕以后  在吧nodeA 取出来  那么需要的操作
    --设置父类的矩阵为空,同时马上visit一下
    {
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1,


    }
    nodeA:setAdditionalTransform(yuanshiJuzhen)
    nodeA:visit()
]]

--加载某个动画材质  加载完毕以后做的回调函数
--synchro 是否是 同步加载资源  false 是异步加载 true 是同步加载

--[[
    { textureName = textureName, {isXmlLoad = true, isTexture = nil} }
]]
FuncArmature.tempLoadComplete = {}

function FuncArmature.loadOneArmatureTexture(textureName, callFunc, synchro)
    local texture, plist, xml = FuncRes.armature(textureName)
    local time1 = os.clock()

    -- local tempCall = function (  )
    --     echo(os.clock() - time1,"___加载图片时间----------")
    --     pc.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(xml,callFunc)
    -- end

    --都加载完才回调
    local function textureSynFunc(plist, texture)
        FuncArmature.tempLoadComplete[textureName].isTexture = true;
        if FuncArmature.tempLoadComplete[textureName].isXmlLoad == true then 
            if callFunc then 
                callFunc();
            end 
            FuncArmature.tempLoadComplete[textureName] = nil;
        end 
    end

    local function xmlSynFunc()
        FuncArmature.tempLoadComplete[textureName].isXmlLoad = true;
        if FuncArmature.tempLoadComplete[textureName].isTexture == true then 
            if callFunc then 
                callFunc();
            end 
            FuncArmature.tempLoadComplete[textureName] = nil;
        end         
    end
    
    if not synchro then
        --异步
        FuncArmature.tempLoadComplete[textureName] = {isXmlLoad = false, isTexture = false};
        pc.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(xml, xmlSynFunc);
        display.addSpriteFrames(plist, texture, textureSynFunc);
    else
        --同步
        local t1 = os.clock()
        pc.ArmatureDataManager:getInstance():addArmatureFileInfo(xml)
        display.addSpriteFrames(plist, texture);
        --echo(os.clock() - t1,"___创建时间111耗费")
        if callFunc then
            callFunc()
        end
    end
    
end

--textureName材质名称  clearAnimation 是否清除动画数据 默认不清除
function FuncArmature.clearOneArmatureTexture(  textureName,clearAniParse)
    local texture,plist,xml = FuncRes.armature(textureName)
    local count = display.removeSpriteFramesWithFile(plist,texture)

    --这里的计数  和 sprite保持一致
    if display.getSpriteFramesCount(texture ) <= 0 then
        


        if clearAniParse then
            pc.ArmatureDataManager:getInstance():removeArmatureFileInfo(xml)
        end
    end
    -- echoError(textureName,"___clearOneArmatureTexture__",count,display.getSpriteFramesCount(plist ))
end



--获取某个aramture名称
--[[
    ctn 传入一个容器
    isCycle 是否循环播放
    callBack 播放完毕后的回调   如果 isCycle 是false  那么才会执行callBack 如果 iscycle为false 没有传递 callBack,那么动画播放完毕后 会删除
]]

function FuncArmature.createArmature(armatureName,ctn, iscycle, callBack )
    if not pc.ArmatureDataManager:getInstance():getAnimationData(armatureName) then
        echoError (armatureName .. " is not exisit")
        --暂时用点击特效代替防止卡死
        armatureName = "UI_ClickEffect"
    end


    local ani = pc.Armature:create(armatureName)
    -- ani:getAnimation():setTimelineType(1)
    --ani:scheduleUpdate()
    --设置一个动画的播放速度
    FuncArmature.setArmaturePlaySpeed(ani,1)

    if ctn then
        ctn:addChild(ani)
    end

    if iscycle then
        ani:getAnimation():playWithIndex(0,0,1)
    else
        ani:getAnimation():playWithIndex(0,0,0)
    end

    ArmatureExpand.extend( ani )
    
    local totalFrame = ani:getAnimation():getRawDuration()
    ani.totalFrame = totalFrame
    --如果不是循环的
    if not iscycle then 
        ani:doByLastFrame(true,false,callBack)
    end
     --如果是ui特效 那么按照固定时间播放特效
    if string.find(armatureName,"UI_") then
        ani:getAnimation():setTimelineType(1)
    end
    return ani
end

--判断是否有某个动作
function FuncArmature.checkHasArmature( armatureName )
    if pc.ArmatureDataManager:getInstance():getAnimationData(armatureName) then
        return true
    end
    return false
end




--设置一个动画的速度 因为需要考虑到子动画的速度也是需要改变的 
--默认是正常速度 
function FuncArmature.setArmaturePlaySpeed( ani ,speed)

    local oldSpeed = speed
    speed = speed  and (speed *armatureSpeed) or armatureSpeed
    ani:getAnimation():setSpeedScale(speed)

    local childArr = ani:getChildren()
    local childAni
    --遍历所有子对象  设置子对象的播放速度  使他和游戏保持一致
    for i,v in ipairs(childArr) do
        if v.getDisplayManager then
            local arr = v:getDisplayManager():getDecorativeDisplayList()
            for i=1,#arr do
                childAni =   arr[i]:getDisplay()
                if childAni and tolua.type(childAni) == "pc.Armature" then
                    FuncArmature.setArmaturePlaySpeed(childAni,oldSpeed)
                end
            end
        end
    end

end


--让动画播放
function FuncArmature.setArmaturePlay( ani,index )
    index = index or 0
    local childArr = ani:getChildren()
    local childAni
    ani:getAnimation():playWithIndex(index,0,1)
    --遍历所有子对象 让子对象也自动播放. 在armature里 所有的动画都是默认不播放的
    for i,v in ipairs(childArr) do
        if v.getDisplayManager then
             local arr = v:getDisplayManager():getDecorativeDisplayList()
            for i=1,#arr do
                childAni =   arr[i]:getDisplay()
                if childAni and tolua.type(childAni) == "pc.Armature" then
                    childAni:getAnimation():playWithIndex(0,0,1)
                end
            end
        end
    end

end








local aniCacheObj = {}

--缓存一个动画
function FuncArmature.cacheOneArmature( ani,armatureName )
    if not aniCacheObj[armatureName] then
        aniCacheObj[armatureName] = {}
    end
    ani:retain()
    table.insert(aniCacheObj[armatureName], ani)

end

--获取一个动画
function FuncArmature:getOneCacheAni( armatureName )
    if not aniCacheObj[armatureName]   then
        return nil
    end
    local arr = aniCacheObj[armatureName] 
    if #arr ==0 then
        return nil
    end

    local ani = arr[1]
    ani:release()
    table.remove(arr,1)
    return ani
end



--播放或者暂停某个动画
function FuncArmature.playOrPauseArmature(armature, value )
    if value then
        armature:getAnimation():resume()
    else
        armature:getAnimation():pause()
    end

    local childArr = armature:getChildren()
    for i,v in ipairs(childArr) do
        --必须是bone
        if tolua.type(v) == "pc.Bone" then
            --而且这个bone 必须有子动画
            local nd = v:getDisplayRenderNode()
            if nd and tolua.type(nd) == "pc.Armature" then
                FuncArmature.playOrPauseArmature(nd, value )
            end
        end
    end

    

end


--释放所有的动画
function FuncArmature.clearALLCacheAni(  )
    for k,v in pairs(aniCacheObj) do
        for i,s in ipairs(v) do
            s:release()
        end
    end
end

--给某个动画某个bone换装
function FuncArmature.changeBoneDisplay( ani,boneName,changeNode,  boneIndex )
    local bone = ani:getBone(boneName)
    
    if not bone then
        return
    end
    boneIndex = boneIndex or 0
    bone:addDisplay(changeNode,boneIndex)
    --如果是有parent的   那么 需要把 parent设置为  bone ,bone的坐标永远是0,0 这样才能校对好位置
    changeNode:parent(bone);
    -- if changeNode:getParent() then
    --     --changeNode:removeFromParent(false)
    -- end
end


--把替换的node 从bone里面 再取出来
-- targetNode 需要被拿出来的对象 , 
--  parentNode 被添加到的 父容器 ,这个必须有 
-- displayIndex 这个替换的node的 boneIndex 默认是0
function FuncArmature.takeNodeFromBoneToParent( targetNode ,parentNode, displayIndex )

    displayIndex = displayIndex or 0

    local bone = targetNode:getParent() 
    if  bone and tolua.type(bone) == "pc.Bone" then
        targetNode:setAdditionalTransform({a=1,b=0,c=0,d=1,tx=0,ty=0})
        local tempNode = display.newNode()
        bone:addDisplay(tempNode,displayIndex)
    end

    local colorProgram = cc.GLProgramCache:getInstance():getGLProgram("colorTransForm")
    local noMvpProgram = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP") 

    local tempNod

    FuncArmature.resumeGlState( targetNode )
    targetNode:parent(parentNode)
    targetNode:visible(true)
end

function FuncArmature.resumeGlState( node )
    if tolua.type(node) =="cc.Sprite" then
        if node:getGLProgram() == colorProgram  then
            node:setGLProgram(noMvpProgram )
        end
    end

    local childArr = node:getChildren()

    for i,v in ipairs(childArr) do
        FuncArmature.resumeGlState(v)
    end
end


--获取一个动画的frame数据
function FuncArmature.getFlashArmatureFrameData( armatureName )
    return flashArmatureCfgData[armatureName]
end

function FuncArmature.getSpineArmatureFrameData( spineName, armatureName )
    local cfg = spineArmatureCfgData[spineName] 
    if not cfg then
        return nil
    end

    if not armatureName then
        return cfg

    else
        if not cfg.actionFrames[armatureName] then
            return nil
        end
    end

    return cfg
end


--获取一个动画所在的fla名字 ,不包括人物动画的fla
function FuncArmature.getArmatureFlaName( armatureName )
    local frameData = FuncArmature.getFlashArmatureFrameData( armatureName )
    if not frameData  then
        --那么返回第一个这个特效的第一个字母
        return nil
    end
    return frameData.fla
end



--获取粒子特效  只用传特效名称 不带.plist
function FuncArmature.getParticleNode( particleName )
    return cc.ParticleSystemQuad:create("anim/particle/" ..particleName..".plist" ):pos(0,0)
end


local animationSpineMap = {}


--获取一个动画名称对应的 材质名称
function FuncArmature.getSpineName( animation )
    if not animation then
        return nil
    end
    local spineName = animationSpineMap[animation]
    if spineName == 0 then
        return nil
    end
    --首先要排除extract资源
    for k,v in pairs(spineArmatureCfgData) do
        if not string.find(k,"Extract") then
            for kk,vv in pairs(v.actionFrames) do
                if kk == animation then
                    animationSpineMap[animation] = k
                    return  k
                end
            end
        else
            -- echoError("为什么找到Extract了",k,v)
        end
        
    end
    animationSpineMap[animation] = 0
    return nil
end 