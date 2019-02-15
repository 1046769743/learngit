local UIBase = class("UIBase", function()
	--设置contentSize0,0 可以修复缩放的bug
    return display.newNode()
end)

UIBase.windowLevel =1
--windowName 这个是一个很重要的标记 默认为 className
UIBase.windowName = nil

UIBase._root = nil

--存储加载了动画的fla名字数组 一般 ui在关闭的时候 需要清理掉这个ui对应的动画
UIBase.aniTexArr = nil 

-- ui的基类 一定会传入一个cfgName
function UIBase:ctor(winName)
    self.windowName = winName
    self.windowCfg = WindowsTools:getUiCfg(self.windowName)
    --是否是宽适配
    if self.windowCfg.screen then
        self.widthScreenOffset = (self.windowCfg.screen[1] -GameVars.gameResWidth)
    else
        --否则就是960
        self.widthScreenOffset = GameVars.widthDistance
    end
    

    self.aniTexArr = {}
    if not CONFIG_USEDISPERSED then
		self:loadAddTextures()
	end
    self:setNodeEventEnabled(true)
end


function UIBase:onCleanup()
    --清除相关资源
    self:_clearSelfTextures()
end


local uitexpath="ui/"
function UIBase:loadAddTextures()
    local addTextures = self.windowCfg.addTex;
    if (addTextures ~= nil) and (table.nums(addTextures) ~= 0) then
        for k, v in pairs(addTextures) do
			local plistFile = string.format("%s%s.plist", uitexpath, v)
			local texFile = string.format("%s%s.png", uitexpath, v)
			GameResUtils:loadTexture(plistFile, texFile)
        end
    end 
end


--禁掉ui上的所有事件----
function UIBase:disabledUIClick(  )
    -- local disabledLayer = self:registClickClose(100000,GameVars.emptyFunc)
    -- self.__disabledLayer = disabledLayer
    if not self.__disabledLayer then
        self.__disabledLayer = self:registClickClose(100000, GameVars.emptyFunc)
    end
    self.__disabledLayer:visible(true)
end

--恢复ui的点击事件
function UIBase:resumeUIClick(  )
    if self.__disabledLayer then
        self.__disabledLayer:visible(false)
    end
end




--点击任意地方关掉ui  注册点击关事件
--zorder 如果为空 表示创建在 _root视图的下面,他会被某些按钮事件挡住 如果大于等于0 表示创建在 _root的某个zorder上面
-- touchThrough 点击事件是否穿透, nil或者false 是不穿透, true 是穿透

--[[
scaleT = {0.8,0.8,true}  
3个参数分别是宽缩放，高缩放，是否显示(用来测试用，默认false)
]] 

function UIBase:registClickClose(zorder ,call ,touchThrough,onMovedClear)
    --创建覆盖点
    touchThrough = touchThrough or false
    local coverLayer = display.newNode():anchor(0.5,0.5)
    coverLayer:setContentSize(GameVars.width *4 , GameVars.height  *4)
    local pos = self:convertToNodeSpace(cc.p(GameVars.cx ,GameVars.cy) )
    coverLayer:pos(pos.x,pos.y)

    if zorder then
        if zorder =="out" then 
            local box = self._root:getContainerBox()
            local scaleX = 1
            local scaleY = 1
            local isShow = false
            local offsetX = 0
            local offsetY = 0
            local boxWidth = box.width
            local boxHeight = box.height
            local scaleT = self.windowCfg.scaleT
            if scaleT then
                scaleX = scaleT[1] or 1
                scaleY = scaleT[2] or 1
                isShow = scaleT[3] or false
                offsetX = scaleT[4] or 0
                offsetY = scaleT[5] or 0
            end
            local nd = FuncRes.a_white( box.width * scaleX ,box.height * scaleY):addto(self._root,-1):anchor(0,1)
            if not isShow then
                nd:opacity(0)
            else
                nd:opacity(200)
            end
            -- nd:setContentSize(box.width * scale ,box.height * scale )
            nd:pos(box.x + offsetX,box.y + boxHeight + offsetY)
            nd:setTouchedFunc(GameVars.emptyFunc,nil,true,nil,nil,false)
            coverLayer:addto(self,-1)
        else
            coverLayer:addto(self._root,zorder)
        end

        
    else
        coverLayer:addto(self,-1)
    end
    coverLayer:setName(self.__cname .. "_clickClose" )
    if not call then
        if onMovedClear then
            coverLayer:setTouchedFunc(c_func(self.startHide, self),nil,not touchThrough,nil,c_func(self.startHide, self),false)
        else
            coverLayer:setTouchedFunc(c_func(self.startHide, self),nil,not touchThrough,nil,nil,false)
        end
    else
        coverLayer:setTouchedFunc(call,nil,not touchThrough,nil,nil,false)
    end

    self.coverLayer = coverLayer

    return coverLayer
end

--[[
    删除点击任意关闭功能
]]
function UIBase:deleteClickClose()
    if self.coverLayer then
        self.coverLayer:setVisible(false)
    end
end

--基础ui增加一个创建动画的方法 每创建动画的时候 都需要加载动画对应的fla 然后关闭ui的时候  就自动移除掉
--重复调用  FuncArmature.loadOneArmatureTexture 不会增加额外的 cpu开销

function UIBase:createUIArmature(flaName, armatureName ,ctn, iscycle ,callBack )
    if not flaName then
        echo("----------------传入空的flaName")
        return
    end
    self:insterArmatureTexture(flaName)

    return FuncArmature.createArmature(armatureName, ctn,  iscycle ,callBack )
end

--插入一个要加载的材质
function UIBase:insterArmatureTexture( flaName )
    if not table.indexof(self.aniTexArr, flaName) then
        FuncArmature.loadOneArmatureTexture(flaName ,nil ,true)
        table.insert(self.aniTexArr,flaName )
    end
end


--更新ui
function UIBase:updateUI( )
    
end

--子对象对其
function UIBase:alignChildView(  )
    
end

-- 注册事件监听，需要子类重写
function UIBase:registerEvent()
	return self
end

-- 加载完毕
function UIBase:loadUIComplete()
	return self;
end

function UIBase:loadkQuestUI(questId)
    if questId ~= nil then
        local viewName = WindowsTools:createWindow("CompQuestInfo", self.windowName);
        self._root:addChild(viewName);
        viewName:initInfoTarget(questId)
        viewName:setPosition(390, -80);
        viewName:zorder(999);
    end
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,viewName, UIAlignTypes.RightTop);
end

-- 适配屏幕
function UIBase:adaptScreen()
    -- 适配
    if self.panel_name ~= nil then
        FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_name,UIAlignTypes.LeftTop) 
    end
    
    if self.panel_title ~= nil then
        FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title,UIAlignTypes.LeftTop) 
    end

    if self.btn_back ~= nil then
        FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop) 
    end
end

-- 设置保存上一次打开的 window
function UIBase:setLaseWindowName(winName)
	self.laseWindowName = winName
end


--供子类重写 当ui开始显示的时候 会附带参数 根据需要加参数
function UIBase:onStartShowData(  )
    return nil
end

--供子类重写 当ui显示完毕的时候 会附带参数 根据需要加参数
function UIBase:onShowCompData(  )
    return nil
end

--供子类重写 当ui开始关闭的时候 会附带参数 根据需要加参数
function UIBase:onStartHideData(  )
    return nil
end

--供子类重写 当ui关闭完成的时候 会附带参数 根据需要加参数
function UIBase:onHideCompData(  )
    return nil
end

--供子类重写，当成为最层view的时候
function UIBase:onBecomeTopView()
	return nil
end

--当自身被重新pop显示的时候 供子类重写
function UIBase:onSelfPop( ... )
    
end

--当被加载到舞台的时候 ,只有通过showWindow的方式才会走到这里,供子类重写
function UIBase:onAddtoParent(  )
    
end


-- window 创建完毕，开始显示
function UIBase:startShow()
    --加载材质
    --恢复ui点击事件
    self._isShow = true
    EventControler:dispatchEvent(UIEvent.UIEVENT_STARTSHOW ,{ui=self,data = self:onStartShowData()})

    self:resumeUIClick()
    self:visible(true)
    self._root:stopAllActions()

    if self.colorLayer then
        self.colorLayer:visible(true)
        if not self.windowCfg.skipColorLayerAnim then
            self.colorLayer:opacity(0)
            self.colorLayer:fadeTo(0.2, 255)
        end
    end

	if self.windowCfg.style == 1 then
		self._root:opacity(0)
		local act = cc.Sequence:create(act.fadein(0.3),act.callfunc(handler(self,self.showComplete)))
    	self._root:runAction(act)
        
    elseif self.windowCfg.style == 2 then -- 弹窗动画
        if not self.__styleAni then
             --显示完毕
            local ani = self:createUIArmature("UI_common", "UI_common_tanchu", self, true, nil)
            FuncArmature.setArmaturePlaySpeed(ani,1)
            self.__styleAni = ani

            --找到中心点
            local  pos = self:convertToNodeSpace(cc.p(GameVars.width /2,GameVars.height/2) )
            ani:pos(pos.x ,pos.y )
            self._root:pos(-pos.x,-pos.y)

            FuncArmature.changeBoneDisplay( ani,"bone",self._root )
        end
        self.__styleAni:removeFrameCallFunc()
        self.__styleAni:playWithIndex(0,false)
        self.__styleAni:registerFrameEventCallFunc( self.__styleAni:getAnimation():getRawDuration(),1,c_func(self.showComplete, self) )
    else
        self:showComplete()
    end

    return self
end

-- window 显示完毕
function UIBase:showComplete()
    -- 适配屏幕
    -- self:adaptScreen()
    if self._root:isVisible() then
        EventControler:dispatchEvent(UIEvent.UIEVENT_SHOWCOMP  ,{ui=self,data = self:onShowCompData()})
        --一个显示完成 通知windowControler 更新ui显示
        WindowControler:updateUiVisible()
    end
    
	return self
end

-- window 缓存时的渐隐过程
function UIBase:startHide()
    --防止重复点击
    if  self._isHide then
        return
    end
    EventControler:dispatchEvent(UIEvent.UIEVENT_STARTHIDE  ,{ui=self,data = self:onStartHideData()})
    --需要在这里移除事件,否则ui注册的事件可能还是会多执行一次导致报错f
    EventControler:clearOneObjEvent(self)
    FightEvent:clearOneObjEvent(self)


    self:disabledUIClick()
    self._root:stopAllActions()
    
    if self.colorLayer then
        self.colorLayer:stopAllActions()
        self.colorLayer:visible(false)
    end

    -- echo("UIBase:startHide", cc.Director:getInstance():getTextureCache():getTextureForKey("anim/armature/linggen.png"));
    -- echo("SpriteFrameCache", cc.SpriteFrameCache:getInstance():getSpriteFrame("linggen_xuanfeng.png"));

	self._isHide = true


    --通知window管理器 移除自己
    WindowControler:removeWindowFromGroup(self.windowName)
    self._isWindowClose =true

    -- 如果返回true 是给对应的ui自己去做退场行为 自己手动在合适时机调用hideComplete
    if self:doHideCompleteFunc( ) then
        return
    end
    -- 逐渐隐藏
	if self.windowCfg.style == 1 then
    	--self:fadeOut(0.2)
    	local act = cc.Sequence:create(act.fadeout(0.2),act.callfunc(handler(self,self.hideComplete)))
    	self._root:runAction(act)
    elseif self.windowCfg.style == 2 then
        self:disabledUIClick()
        if self.__styleAni then
            self.__styleAni:removeFrameCallFunc()
        end

        -- self:visible(false)
        self:delayCall(c_func(self.hideComplete, self),0.0001)

    else
        --这里只隐藏root 不需要隐藏所有的,否则会存在因为卡顿造成的 连续点击2次开关ui
        self._root:visible(false)
        if self.__bgView then
            self.__bgView:visible(false)
        end
        self:delayCall(c_func(self.hideComplete, self),0.0001)

    end
    return self
end

-- starHide 时是否立即执行hideComplete方法 
-- false 是立即执行
function UIBase:doHideCompleteFunc(  )
    return false
end

-- 隐藏完毕
function UIBase:hideComplete()
    EventControler:dispatchEvent(UIEvent.UIEVENT_HIDECOMP ,{ui=self,data = self:onHideCompData()})
    
    local tempFunc = function (  )
        local currentMemery = collectgarbage("count")
        collectgarbage("collect")
        printInfo(string.format(" On winClose Memory before:%0.2f KF, current: %0.2f KB", currentMemery,collectgarbage("count")))

    end

	-- 如果是缓存，则只需要清楚掉某些资源
	if self.windowCfg.cache == true then
		if self.windowCfg.clearTex then
		end
	else
        self:deleteMe()

	end

    return self
end



--销毁函数
function UIBase:deleteMe(  )
    if tolua.isnull(self) then 
        echoError("为什么自身被销毁了")
        return
    end

    if self.died  then
        echoError("重复销毁ui,",self.windowName)
        return
    end
    self.died = true

    self:deleteAllChild()
    self:removeFromParent(true)

    
end


function UIBase.deleteAllChild(self )
    local childArr = self:getChildren()
   
    if #childArr>0 then

        for i=#childArr,1,-1 do
            local childView = childArr[i]
            if not tolua.isnull(childView) then
                if childView.deleteMe then
                    childView:deleteMe()
                else
                    UIBase.deleteAllChild(childView)
                end
            end
            
        end
    end

end


--判断是否是全屏ui
function UIBase:checkIsFullUI(  )
    local windowCfg = self.windowCfg
    --如果是有bg的 那么一定是全屏的
    if windowCfg.bg then
        return true
    end
    --如果特别指定了 full的 
    if windowCfg.full then
        return true
    end

    --判断是否包含通用bg
    if self._hasCheckBg == nil then
        local uicfg = self.__uiCfg
        local hasBg = false
        local chArr = uicfg[UIBaseDef.prop_child]

        for k,v in pairs(chArr) do
            local clName = v[UIBaseDef.prop_className]
            if clName  and (clName =="UI_comp_bg" or  clName =="UI_comp_bg2" )  then
                hasBg = true
            end
        end
        if hasBg then
            self._hasCheckBg = 1
        else
            self._hasCheckBg = 0
        end

    end
    --如果是有公用背景的
    if self._hasCheckBg ==1 then
        return true
    end

    return false

end

--当退出战斗时 需要缓存的数据 以便 恢复这个ui时 记录数据
function UIBase:getEnterBattleCacheData(  )
    return  {}
end

--当退出战斗后 恢复这个ui时 ,会把这个cacheData传递给ui
function UIBase:onBattleExitResume(cacheData )
    
end

-- 更换背景图片
function UIBase:changeBg(bgName,isFade)
    local windowCfg = self.windowCfg

    -- 删除原背景
    local curBgView = self.__bgView
    if curBgView then
        local removeFunc = function ( ... )
            curBgView:removeFromParent()
            curBgView = nil
            --移除背景材质
            if windowCfg.bg then
                FuncRes.removeBgTexture(windowCfg.bg )
            end
        end
        -- if isFade then
        --     curBgView:runAction(cc.Sequence:create(
        --             act.fadeout(0.5),
        --             act.callfunc(c_func(removeFunc))
        --         ))
        -- else
        --     removeFunc()
        -- end
        removeFunc()
        
    end

    -- 创建新背景
    --这里不能修改配置的bg, 否则修改的是原始数据会造成多加载几次背景
    -- windowCfg.bg = bgName
    local newBgView = display.newSprite(FuncRes.iconBg(bgName), -GameVars.UIOffsetX, GameVars.UIbgOffsetY):anchor(0,1)
        :addto(self,-2);
    FuncCommUI.setBgScaleAlign(newBgView,windowCfg.bgScale)
    newBgView:setName(windowCfg.bg)
    self.__bgView = newBgView
    if isFade then
        newBgView:opacity(0)
        newBgView:runAction(act.fadein(0.5))
    end
end


--开始做背景动画 ,返回背景动画持续的时长(秒为单位),这个是用来表示我需要多久后才判定这个ui展示完毕,我好通知这个它底下的ui全部隐藏
function UIBase:startBgAction(  )
    return 0
end


--清理自身加载的纹理
function UIBase:_clearSelfTextures(  )

    
    local _isWindowClose  =self._isWindowClose
    local winName = self.windowName

    if self._hasClearTexture then
        echoError(winName,"____hasClearTexture_")
        return
    end
    -- echo(winName,"_____clearSelfTextures_")
    self._hasClearTexture = true
    
    -- 是否是需要手动删除材质的 比如 很多list 并不是在 移除listview的时候就移除材质 而是应该在移除ui的时候 清除材质
    if self.windowCfg   then

        if self.windowCfg.ui and  (not self.windowCfg.handleClearTexture ) then

            -- echo(winName,"移除材质：".."ui/"..self.windowCfg.ui ..".plist" );
            FuncRes.removeOneUITexture( self.windowCfg.ui )
        end

        if self.__commonTextureName then
            FuncRes.removeOneUITexture( self.__commonTextureName )
            -- echo("移除公用ui材质：",self.__commonTextureName)
        end

        --移除背景
        if self.windowCfg.bg then
            -- echo("移除背景材质,",self.windowCfg.bg)
            FuncRes.removeBgTexture( self.windowCfg.bg )
        end


        if self.windowCfg.addTex then
            for i,v in ipairs(self.windowCfg.addTex) do
                if v ~= self.windowCfg.ui and v ~= self.__commonTexture then
                    FuncRes.removeOneUITexture( v )
                    -- echo("_移除addTex----","ui/"..v ..".plist")
                end
            end
        end

        if self.windowCfg.aniTex then
            for k,v in pairs(self.windowCfg.aniTex) do
                if not FuncCommon.isCommonTexture(v ) then
                    -- echo("移除动画："..v ..".bobj" );
                    FuncArmature.clearOneArmatureTexture( v,true)
                end
            end
        end
    end

    --让配置置空但是不要销毁
    self.__uiCfg = nil


    self.died = true
    EventControler:clearOneObjEvent(self)
    FightEvent:clearOneObjEvent(self)
    if self.windowName == "PartnerUpQualityView" then 
        dump(self.aniTexArr,"_self.aniTexArr")
    end
     --清除掉 加载的动画材质
    for i,v in ipairs(self.aniTexArr) do
        if not FuncCommon.isCommonTexture(v ) then
            echo("移除动画："..v ..".bobj" );
            FuncArmature.clearOneArmatureTexture( v,true)
        end
    end
    self.aniTexArr = nil

    if IS_CLEAR_PACKAGE_AFTER_HIDE and self.windowCfg.package then
        local cfgUIUrl = "uiConfig."
        local viewPackage = "game.sys.view."..self.windowCfg.package.."."..self.windowName
        local uiPackage = cfgUIUrl..self.windowCfg.ui
        package.loaded[viewPackage] = nil
        package.loaded[uiPackage] = nil
    end
    if _isWindowClose then
        local tempFunc = function (  )
            --每关闭3次ui做一次清理纹理操作
            if WindowControler.hasCreatWindowNums %4 == 2 or  DEBUG_MEM then
                WindowControler:clearUnusedTexture()
            end
            
            TextureControler:compareTextureState( winName )
        end
        
        WindowControler:globalDelayCall(tempFunc, 0.1)
        
    end

end



return UIBase
