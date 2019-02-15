--
-- Author: xd
-- Date: 2016-07-22 14:51:47
--
local BattleTreasureView = class("BattleTreasureView", UIBase)

--左侧面板的人物头像，左侧法宝，右侧法宝
BattleTreasureView.z_order_1 = 1    --人物头像的层级
BattleTreasureView.z_order_2 =2     --左侧法宝的法宝中低层级
BattleTreasureView.z_order_3 =3     --法宝中的高层级

BattleTreasureView.maxTreasureNum = 7      --最大法宝数量
BattleTreasureView.maxTreasureViewNum = 7      --最大法宝视图数量
function BattleTreasureView:loadUIComplete(  )
	--记录剩余闪屏时间 --每次释放法宝后 闪屏时间得重置,
    self._leftFlashFrame = 0;
    self._leftInitFlashFrame = 20;


	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_left,UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_2,UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_1,UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.scale9_bg,UIAlignTypes.LeftBottom)

    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ROUNDSTART, self.onRoundStart, self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CHANGETREASURE,self.onTreasureChanged,self)
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CHANGEAUTOFIGHT,self.autoChanged,self )
    -- self.panel_left.panel_2:visible(false)

    --self:openOrCloseCharView(false)

    --人脚底下的光环
    self.panel_ren:visible(false)
    
    --加载特效资源
    -- FuncArmature.loadOneArmatureTexture("UI_zhandou", nil, true)
    --FuncArmature.loadOneArmatureTexture("UI_zhandou", nil, true)
    --self:initSmallSkillAni()


    --加载法宝动画资源
    -- FuncArmature.loadOneArmatureTexture("UI_zhandou_fabao",nil,true)


    --self.panel_left.panel_2Copy = UIBaseDef:cloneOneView(  self.panel_left.panel_2 )
    --self.panel_left:addChild(self.panel_left.panel_2Copy)
    --self.panel_left.panel_3Copy = UIBaseDef:cloneOneView(  self.panel_left.panel_3 )
    --self.panel_left:addChild(self.panel_left.panel_3Copy)
    --暂时隐藏操作栏
    self:visible(false)
end







--[[
法宝发生变化 
主要处理法宝崩溃的问题
]]
function BattleTreasureView:onTreasureChanged( event )
    echo("法宝发生变化")
    dump(event.params)
    echo("法宝发生变化")
    if event.params == 2 then
        --右侧法宝
        --self:onRightTreaOverWithRight()
        --self:onLeftTreaOverWithLeft()
        self:onClickRightTrea()

        
    elseif event.params == 1 then
        --左侧法宝
        --self:onLeftTreaOverWithLeft()
        --self:onRightTreaOverWithRight()
        self:onClickLeftTrea()

    else
        self:onLeftTreaOverWithLeft()
        self:onRightTreaOverWithRight()
    end

    --self:openOrCloseCharView(false)
    --self:checkSkillShow(self.panel_left.panel_1)

end



--回合开始
function BattleTreasureView:onRoundStart(event )

    local targetCamp = event ==nil and 1 or event.params
    if targetCamp ~= 1 then
        return 
    end
    --echo("新回合开始,",targetCamp,"==================")
    -- echo("回合开始")
    -- dump(event.params)
    -- echo("回合开始")
    local campArr = self.controler.campArr_1
    --echo(#campArr,"==================")
    local view
    for i=1,#campArr do
        local index = campArr[i].index
        if index then
            view = self.panel_2["panel_"..index]
            if view then
                self:checkDisableView(view,true)
                --判断小技能或者大招
                self:checkSkillShow(view)
                --self:checkSkillShow(view)
            end
        end
        
    end

    
    self:checkDisableView(self.panel_left.panel_1)
    if self.panel_left.panel_1.hero.data:energy()>=self.panel_left.panel_1.hero.data:maxenergy()
        and self.panel_left.panel_1.hero.data:hp()>0
     then
        self:onEnergyFull()
    end

    self:onPlayChooseTargetAni(true)

end


--[[
是否是自动战斗
]]
function BattleTreasureView:autoChanged(  )
    echo("是否是自动战斗")

    self:afterPlayChooseTargetAni()
end


--[[
选择集火目标动画
]]
function BattleTreasureView:onPlayChooseTargetAni(isRoundStart)
    --echo("回合开始----------------",isRoundStart,"===============",self.controler.logical.autoFight)
    --如果是自动战斗，则不处理

    local checkCanHandle = function ( self )
        local view
        local campArr = self.controler.campArr_1
        for i=1,#campArr do
            local index = campArr[i].index
            if index then
                view = self.panel_2["panel_"..index]
                if self:checkCanClick(view) then
                    return true
                end
            end
        end
        return false
    end
    if self.controler.logical.autoFight then
        return
    end

    if not self.controler.logical.isInRound then
        return
    end


    if not checkCanHandle(self) then
        return
    end
    if #self.controler.logical.queneArr_1>0 then
        return
    end
    if #self.controler.campArr_2<=0 then
        return
    end
    if self.jihuokuangAni == nil then
        self.jihuokuangAni=FuncArmature.createArmature("UI_zhandou_kuang",self.ctn_xuandibgAni,false,GameVars.emptyFunc)
    end
    if self.jihuokuangAni.playIndex ~= 0 then
        self.jihuokuangAni:removeFrameCallFunc()
        self.jihuokuangAni:visible(true)
        self.jihuokuangAni:playWithIndex(0,false)
        self.jihuokuangAni.playIndex = 0
    end
    if self.jihuoTxtAni == nil then
        self.jihuoTxtAni = FuncArmature.createArmature("UI_zhandou_jihuomubiaozi",self.ctn_xuandiIcon,false,GameVars.emptyFunc)
    end
    if self.jihuoTxtAni.playIndex ~= 0 then
        self.jihuoTxtAni:removeFrameCallFunc()
        self.jihuoTxtAni:visible(true)
        self.jihuoTxtAni:playWithIndex(0,false)
        self.jihuoTxtAni.playIndex = 0
    end

end


--[[
完成集火目标的选择
]]
function BattleTreasureView:afterPlayChooseTargetAni( view )
    local onJiHuocallBack
    onJiHuocallBack = function (  )
        if self.jihuokuangAni then
            self.jihuokuangAni:removeFrameCallFunc()
            self.jihuokuangAni:pause(false)
            self.jihuokuangAni.playIndex = 2
            self.jihuokuangAni:visible(false)
        end

    end
    local onJiHuoTxtcallBack2
    onJiHuoTxtcallBack2 = function (  )
        if self.jihuoTxtAni then
            self.jihuoTxtAni:removeFrameCallFunc()
            self.jihuoTxtAni:pause(false)
            self.jihuoTxtAni.playIndex = 2
            self.jihuoTxtAni:visible(false)
        end
    end
    local canAni = false
    if self.jihuokuangAni and self.jihuokuangAni.playIndex == 0 then
        canAni = true
        self.jihuokuangAni:visible(true)
        self.jihuokuangAni:registerFrameEventCallFunc(6,nil,onJiHuocallBack)
        self.jihuokuangAni:playWithIndex(1,false)
        self.jihuokuangAni.playIndex = 1
    end
    if self.jihuoTxtAni and self.jihuoTxtAni.playIndex == 0 then
        canAni = true
        self.jihuoTxtAni:visible(true)
        self.jihuoTxtAni:registerFrameEventCallFunc(9,nil,onJiHuoTxtcallBack2)
        self.jihuoTxtAni:playWithIndex(1,false)
        self.jihuoTxtAni.playIndex = 1
    end

    if not view then
        return
    end
    if  view.isChar then
        return
    end
    if not canAni then
        return
    end

    local index = view.index
    local ctn = self.panel_2["ctn_"..index]

    local ctnCallBack
    ctnCallBack = function (  )
        if ctn.ani then
            ctn.ani:removeFrameCallFunc()
            ctn.ani:visible(false)
        end
    end

    if ctn.ani == nil then
        ctn.ani = FuncArmature.createArmature("UI_zhandou_touxiangsuo",ctn,false,GameVars.emptyFunc)
    end
    if ctn.ani then
        ctn.ani:removeFrameCallFunc()
        ctn.ani:visible(true)
        ctn.ani:playWithIndex(0,false)
        ctn.ani:registerFrameEventCallFunc(nil,1,ctnCallBack)
    end




end





--某个英雄发生攻击行为
function BattleTreasureView:onHeroAttack( params )
    -- echo("某个英雄发生攻击行为")
    -- dump(params.params)
    -- echo("某个英雄发生攻击行为")
    local params = params.params
    for i=1,5 do
       local view = self.panel_2["panel_"..i]
        if view and view.hero then
            self:checkDisableView(view)
            --判断小技能或者大招
            --echo("发生攻击行为")
            --self:checkSkillShow(view)
        end
    end

    local index = params.index
    
    if index>=1 and index<=5 then
        --echo("index,",index,"检查技能显示")
        local view = self.panel_2["panel_"..index]
        self:hideSkillAni(view)
    end

    -- for i=1,3 do
    --     view = self.panel_left["panel_"..i]
    --     if view and view.hero then
    --         self:checkDisableView(view)
    --     end
    -- end
    --self.myIconView = self.panel_left.panel_1
    --self.leftTreaView = self.panel_left.panel_2
    --self.rightTreaView = self.panel_left.panel_3
     if self.panel_left.panel_1.hero then
        --echo("检测是否可用----")
         self:checkDisableView(self.panel_left.panel_1)
     end
     -- if params.handleType and params.handleType == 2 then
        
     --    if params.params == 1 then
     --        --左侧法宝上身
     --        echo("dddddd左侧法宝上身--------")
     --        --
     --        self:onClickLeftTrea()
     --    elseif params.params ==2 then
     --        --右侧法宝上身
     --        echo("右侧法宝上身--------")
     --        self:onClickRightTrea()
     --    end
     -- end
end

--[[
隐藏技能动画
]]
function BattleTreasureView:hideSkillAni( view )
    if view.djnchuxianAni then
        view.djnchuxianAni:pause(false)
        view.djnchuxianAni:visible(false)
    end
    if view.djnAni then
        view.djnAni:visible(false)
        view.djnIsShow = false
    end
    if view.xjnchuxianAni then
        view.xjnchuxianAni:visible(false)
    end
    if view.xjnAni then
        view.xjnAni:visible(false)
        view.xjnIsShow = false
    end
end


--[[
控制大技能小技能特效显示
]]
function BattleTreasureView:checkSkillShow( view)
    local hero = view.hero
    local energy = hero.data:energy()
    --echo("energy >= hero.data:maxenergy(),",energy , hero.data:maxenergy())
    if energy >= hero.data:maxenergy() then
        --显示大招
        --echo("显示大技能----")
        --view.panel_4:visible(true)
        local djnAniShowFunc = function (  )
            if view.djnAni then
                view.djnAni:visible(true)
            end
            if view.djnchuxianAni then
                view.djnchuxianAni:pause(false)
                view.djnchuxianAni:visible(false)
            end
        end
        if not view.djnchuxianAni  then
            --echo("----创建动画")
            view.djnchuxianAni = FuncArmature.createArmature("UI_zhandou_djnchuxian",view.ctn_2,false,GameVars.emptyFunc)
            --view.djnchuxianAni:visible(false)
            view.djnIsShow = false
        end
        if not view.djnAni then
            view.djnAni = FuncArmature.createArmature("UI_zhandou_088",view.ctn_2,true,GameVars.emptyFunc)
            view.djnAni:visible(false)
        end
        if not view.djnIsShow then
            --echo("大技能一直播放出现动画")
            view.djnchuxianAni:removeFrameCallFunc()
            view.djnchuxianAni:gotoAndPlay(1)
            view.djnchuxianAni:play(false)
            view.djnchuxianAni:registerFrameEventCallFunc(nil,false,djnAniShowFunc)
            view.djnchuxianAni:visible(true)

            view.djnIsShow = true
        end

        if view.xjnAni then
            view.xjnAni:visible(false)
            view.xjnIsShow = false
        end
    else
        --如果是小技能
       if hero.nextSkillIndex ==Fight.skillIndex_small then
           --view.txt_2:visible(true)
           --view.ctn_2:visible(true)
           --echo("显示小技能----------")
           local xjnAniShowFunc = function (  )
            --echo("小技能出现播放完成回调-------")
               if view.xjnAni then
                    view.xjnchuxianAni:visible(false)
                     view.xjnAni:visible(true)
                end
           end

           if not view.xjnchuxianAni then
                view.xjnchuxianAni = FuncArmature.createArmature("UI_zhandou_jinengchuxian",view.ctn_2,false,GameVars.emptyFunc)
           end
           if not view.xjnAni  then
                view.xjnAni = FuncArmature.createArmature("UI_zhandou_xjnzhuangtai",view.ctn_2,true,GameVars.emptyFunc)
                view.xjnAni:visible(false)
           end
           if not view.xjnIsShow then
                view.xjnchuxianAni:removeFrameCallFunc()
                view.xjnchuxianAni:playWithIndex(0,false)
                view.xjnchuxianAni:visible(true)
                view.xjnIsShow = true
                view.xjnchuxianAni:registerFrameEventCallFunc(nil,false,xjnAniShowFunc)
           end
           
           if view.djnAni then
                view.djnAni:visible(false)
                view.djnIsShow = false
           end
       else
            --echo("全部隐藏动画-----")
            if view.djnchuxianAni then
                view.djnchuxianAni:pause(false)
                view.djnchuxianAni:visible(false)
            end
            if view.djnAni then
                view.djnAni:visible(false)
                view.djnIsShow = false
            end
            if view.xjnchuxianAni then
                view.xjnchuxianAni:visible(false)
            end
            if view.xjnAni then
                view.xjnAni:visible(false)
                view.xjnIsShow = false
            end
       end
    end
end



function BattleTreasureView:initView(  )
	--初始化 把 法宝panel 进行特殊赋值,便于操作 
    --12对应左边的A类法宝  34567对应右边从右到左5个b类法宝
    --对应英雄编号 只拿第一组的
    for i=1,5 do
        self.panel_2["panel_"..i]:visible(false)
    end

    local campArr = self.controler.campArr_1

    --给每个位置对应好编号
    local index = 0

    for i,v in ipairs(campArr) do
        --如果是主角
        if v:checkIsMainHero() then
            self.userHero = v
            self:initHeroTrasure()
        else

            index = index +1
            local view = self.panel_2["panel_"..index]
            view.index = index
            v.index = index
            view:visible(true)
            if not view then
                echoWarn("没有这个view",index)
            end
            self:initOneHero(v, view)
        end
    end
   
    self:initLeftTrea()
    self:onRoundStart()
end


--------------------===================左侧状态控制========================-------------------

--[[
左侧头像和法宝的状态和对应的动画标签，帧
onlyIcon: 只有头像，这个时候怒气没有满           
iconAndTrea: 怒气满了，有法宝和头像，头像半透
leftTreaOn:点击了左侧法宝,
rightTreaOn:点击了右侧法宝


状态流转及其条件:
1：只有人物头像，回合开始检查 怒气满了法宝打开
2:法宝打开，点击左侧法宝
3:法宝打开，点击右侧法宝
4:左侧法宝崩溃
5:右侧法宝崩溃
6:左侧法宝情况下，怒气满了
7：右侧法宝情况下，怒气满了
8:两个法宝都显示，这个时候怒气值改变了，怒气不满了，法宝消失头像显示


]]



--[[
左侧面板的动画播放回调
]]
-- function BattleTreasureView:onTreaAniCallBack(  )
--     self.treaAni:removeFrameCallFunc()
--     --if self.treaAni.state == "on"
--     echo("动画播放完成")
--     self.treaAni:pause(false)
-- end




--[[
初始化左侧法宝人物头像
]]
function BattleTreasureView:initLeftTrea(  )

    
    self.headAni = FuncArmature.createArmature("UI_zhandou_fabao_touxiang",self.panel_left,false,GameVars.emptyFunc):zorder(self.z_order_1)
    self.panel_left.panel_1:pos(0,0)
    self.panel_left.panel_2:pos(-11,-0)
    self.panel_left.panel_3:pos(-3,-0)
    self.headAni:pos(128,-160)
    FuncArmature.changeBoneDisplay(self.headAni,"node6",self.panel_left.panel_1)
    self.headAni:playWithIndex(0,false)
    self.headAni:gotoAndPause(1)
    self.headAni:pause(false)


    -- self.treasCome = FuncArmature.createArmature("UI_zhandou_fabao_zhankaitexiao",self.panel_left,false,GameVars.emptyFunc):zorder(self.z_order_1)
    -- self.treasCome:pos(128,-160)
    -- self.treasCome:gotoAndPause(16)
    --初始化node节点状态
    
    self.leftTreaAni = FuncArmature.createArmature("UI_zhandou_fabao_zuo",self.panel_left,false,GameVars.emptyFunc):zorder(self.z_order_2)
    self.leftTreaAni:pos(128,-160)
    FuncArmature.changeBoneDisplay(self.leftTreaAni,"node2",self.panel_left.panel_2)
    self.leftTreaAni:playWithIndex(2,false)
    self.leftTreaAni:gotoAndPause(8)
    self.leftTreaAni:pause(false)

    --左侧法宝替换节点
    --local leftCopy1 = 
    --FuncArmature.changeBoneDisplay(self.leftTreaAni,"node3",)
    self.rightTreaAni = FuncArmature.createArmature("UI_zhandou_fabao_you",self.panel_left,false,GameVars.emptyFunc):zorder(self.z_order_3)
    self.rightTreaAni:pos(128,-160)
    FuncArmature.changeBoneDisplay(self.rightTreaAni,"node1",self.panel_left.panel_3)
    self.rightTreaAni:playWithIndex(2,false)
    self.rightTreaAni:gotoAndPause(8)
    self.rightTreaAni:pause(false)

--)

    self.panel_left.panel_2Copy = display.newSprite(self.leftTreaIcon):scale(0.5):pos(0,20)
    self.panel_left:addChild(self.panel_left.panel_2Copy)
    self.panel_left.panel_3Copy = display.newSprite(self.rightTreaIcon):scale(0.5):pos(0,20)
    self.panel_left:addChild(self.panel_left.panel_3Copy)



    self.panel_left.panel_2Copy:pos(0,0)
    --self.panel_left.panel_2Copy.
    self.leftTreaAniCopy = FuncArmature.createArmature("UI_zhandou_fabao_zuo",self.panel_left,false,GameVars.emptyFunc):zorder(self.z_order_2)
    self.leftTreaAniCopy:pos(128,-160)
    FuncArmature.changeBoneDisplay(self.leftTreaAniCopy,"node2",self.panel_left.panel_2Copy)
    self.leftTreaAniCopy:playWithIndex(2,false)
    self.leftTreaAniCopy:gotoAndPause(8)
    self.leftTreaAniCopy:pause(false)

    
    self.panel_left.panel_3Copy:pos(0,0)
    self.rightTreaAniCopy = FuncArmature.createArmature("UI_zhandou_fabao_you",self.panel_left,false,GameVars.emptyFunc):zorder(self.z_order_3)
    self.rightTreaAniCopy:pos(128,-160)
    FuncArmature.changeBoneDisplay(self.rightTreaAniCopy,"node1",self.panel_left.panel_3Copy)
    self.rightTreaAniCopy:playWithIndex(2,false)
    self.rightTreaAniCopy:gotoAndPause(8)
    self.rightTreaAniCopy:pause(false)

    self.treaState = "onlyIcon"
    self.aniState = "1"

end

-- function BattleTreasureView:setAniDisable( val )
--     if val then
--         self
--     else
--     end
-- end


--[[
头像播放的回调
]]
function BattleTreasureView:headAniCallBack(  )
    self.headAni:removeFrameCallFunc()
    self.headAni:pause(false)
end
--[[
法宝相遇动画播放回调
]]
function BattleTreasureView:treasComeCallBack(  )
    --self.treasCome:removeFrameCallFunc()
    self.headAni:pause(false)
end

--[[
左侧法宝播放回调
]]
function BattleTreasureView:leftTreaAniCallBack(  )
    self.leftTreaAni:removeFrameCallFunc()
    self.leftTreaAni:pause(false)
end
--[[
右侧法宝动画播放回调
]]
function  BattleTreasureView:rightTreaAniCallBack(  )
    self.rightTreaAni:removeFrameCallFunc()
    self.rightTreaAni:pause(false)
end

function BattleTreasureView:onAniPlayCallBack( ani )
    if ani then
        ani:removeFrameCallFunc()
        ani:pause(false)
    end
end

--[[
怒气值不满到 怒气满 回合开始检测
依据当前的状态
]]
function BattleTreasureView:onEnergyFull()

    if self.treaState == "onlyIcon" then
    --if "onlyIcon" == "onlyIcon" then
        --头像隐藏
        self.headAni:removeFrameCallFunc()
        self.headAni:playWithIndex(0,false)
        self.headAni:gotoAndPlay(1)
        self.headAni:registerFrameEventCallFunc(10,1,c_func(self.onAniPlayCallBack,self,self.headAni))
        --左侧头像分开

        self.leftTreaAni:removeFrameCallFunc()
        self.leftTreaAni:playWithIndex(1,false)
        self.leftTreaAni:gotoAndPlay(1)
        self.leftTreaAni:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.leftTreaAni))
        --右侧头像分开
        self.rightTreaAni:removeFrameCallFunc()
        self.rightTreaAni:playWithIndex(1,false)
        self.rightTreaAni:gotoAndPlay(1)
        self.rightTreaAni:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.rightTreaAni))
        self.treaState = "iconAndTrea"
    elseif self.treaState == "leftTreaOn" then

        self.leftTreaAni:removeFrameCallFunc()
        self.leftTreaAni:playWithIndex(1,false)
        self.leftTreaAni:gotoAndPlay(1)
        self.leftTreaAni:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.leftTreaAni))


        self.rightTreaAni:removeFrameCallFunc()
        self.rightTreaAni:playWithIndex(1,false)
        self.rightTreaAni:gotoAndPlay(1)
        self.rightTreaAni:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.rightTreaAni))


        --self.leftTreaAni:zorder(self.z_order_3)
        --self.rightTreaAni:zorder(self.z_order_2)
        self.treaState = "iconAndTreaWithLeftTreaon"

    elseif self.treaState == "rightTreaOn" then
        self.leftTreaAni:removeFrameCallFunc()
        self.leftTreaAni:playWithIndex(1,false)
        self.leftTreaAni:gotoAndPlay(1)
        self.leftTreaAni:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.leftTreaAni))
        
        self.rightTreaAni:removeFrameCallFunc()
        self.rightTreaAni:playWithIndex(1,false)
        self.rightTreaAni:gotoAndPlay(1)
        self.rightTreaAni:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.rightTreaAni))

        -- self.rightTreaAni:zorder(self.z_order_3)
        -- self.leftTreaAni:zorder(self.z_order_2)
        self.treaState = "iconAndTreaWithRightTreaOn"
    end
end

--[[
头像是否可点击
]]
-- function BattleTreasureView:onHeadCanClick( val )
--     if val then

--     end
-- end


--[[
怒气值满，到怒气值不满 回合开始检测  这个动画没有
]]
function BattleTreasureView:onEnergyNotFullWithFull()
    -- body
end

--[[
 点击左侧法宝 
]]
function BattleTreasureView:onClickLeftTrea(  )
   if self.treaState == "iconAndTrea" or 
    self.treaState == "iconAndTreaWithLeftTreaon" or 
    self.treaState == "iconAndTreaWithRightTreaOn" then
        --左侧法宝跳到最后一帧 停止
        self.leftTreaAni:removeFrameCallFunc()
        self.leftTreaAni:playWithIndex(3,false)
        self.leftTreaAni:gotoAndPause(8)
        --右侧法宝跳到最后一帧 停止
        self.rightTreaAni:removeFrameCallFunc()
        self.rightTreaAni:playWithIndex(3,false)
        self.leftTreaAni:gotoAndPause(8)
        --左侧Copy移动 到相应位置
        self.leftTreaAniCopy:removeFrameCallFunc()
        self.leftTreaAniCopy:playWithIndex(0,false)
        self.leftTreaAniCopy:gotoAndPlay(1)
        self.leftTreaAniCopy:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.leftTreaAniCopy))
        --右侧Copy慢慢消失
        self.rightTreaAniCopy:removeFrameCallFunc()
        self.rightTreaAniCopy:playWithIndex(2,false)
        self.rightTreaAniCopy:gotoAndPlay(1)
        self.rightTreaAniCopy:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.rightTreaAniCopy))
        --右侧头像显示
        self.headAni:removeFrameCallFunc()
        self.headAni:playWithIndex(1,false)
        self.headAni:gotoAndPlay(1)
        self.headAni:registerFrameEventCallFunc(6,1,c_func(self.onAniPlayCallBack,self,self.headAni))
        self.treaState = "leftTreaOn"
   end
end
--[[
点击右侧法宝
]]
function BattleTreasureView:onClickRightTrea(  )
   if self.treaState == "iconAndTrea" or 
    self.treaState == "iconAndTreaWithLeftTreaon"  or
    self.treaState == "iconAndTreaWithRightTreaOn"
    then
        
        --左侧法宝跳到最后一帧 停止
        self.leftTreaAni:removeFrameCallFunc()
        self.leftTreaAni:playWithIndex(3,false)
        self.leftTreaAni:gotoAndPause(8)
        --右侧法宝跳到最后一帧 停止
        self.rightTreaAni:removeFrameCallFunc()
        self.rightTreaAni:playWithIndex(3,false)
        self.leftTreaAni:gotoAndPause(8)
        

        self.leftTreaAniCopy:removeFrameCallFunc()
        self.leftTreaAniCopy:playWithIndex(2,false)
        self.leftTreaAniCopy:gotoAndPlay(1)
        self.leftTreaAniCopy:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.leftTreaAniCopy))



        self.rightTreaAniCopy:removeFrameCallFunc()
        self.rightTreaAniCopy:playWithIndex(0,false)
        self.rightTreaAniCopy:gotoAndPlay(1)
        self.rightTreaAniCopy:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.rightTreaAniCopy))


        self.headAni:removeFrameCallFunc()
        self.headAni:playWithIndex(1,false)
        self.headAni:gotoAndPlay(1)
        self.headAni:registerFrameEventCallFunc(6,1,c_func(self.onAniPlayCallBack,self,self.headAni))

        self.treaState = "rightTreaOn"
   end
end
--[[
左侧法宝在身 左侧法宝崩溃
]]
function BattleTreasureView:onLeftTreaOverWithLeft(  )
    echo("左侧法宝崩溃-----------------")
    --if self.treaState == "leftTreaOn" then

        self.leftTreaAniCopy:removeFrameCallFunc()
        self.leftTreaAniCopy:playWithIndex(3,false)
        self.leftTreaAniCopy:gotoAndPlay(1)
        self.leftTreaAniCopy:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.leftTreaAniCopy))

        self.headAni:removeFrameCallFunc()
        self.headAni:playWithIndex(1,false)
        self.headAni:gotoAndPlay(1)
        --self.headAni:registerFrameEventCallFunc(6,1,c_func(self.headAniCallBack,self))
        --self.treaState = "onlyIcon"
    --end
end
--[[
右侧法宝在身，右侧法宝崩溃
]]
function BattleTreasureView:onRightTreaOverWithRight(  )
    echo("右侧法宝崩溃----")
    --if self.treaState == "rightTreaOn" then

        self.rightTreaAniCopy:removeFrameCallFunc()
        self.rightTreaAniCopy:playWithIndex(3,false)
        self.rightTreaAniCopy:gotoAndPlay(1)
        self.rightTreaAniCopy:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.rightTreaAniCopy))

        self.headAni:removeFrameCallFunc()
        self.headAni:playWithIndex(1,false)
        self.headAni:gotoAndPlay(1)
        self.headAni:registerFrameEventCallFunc(6,1,c_func(self.onAniPlayCallBack,self,self.headAni))
        --self.treaState = "onlyIcon"
    --end
end
--[[
玩家血量 变成了0 死了
]]
function BattleTreasureView:onHeroDied(  )
    if self.treaState == "onlyIcon" then
        --当前只有头像 不处理
    elseif self.treaState == "iconAndTrea" then
        --当前怒气满了 但是死了
        self.leftTreaAni:removeFrameCallFunc()
        self.leftTreaAni:playWithIndex(2,false)
        self.leftTreaAni:gotoAndPlay(1)
        self.leftTreaAni:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.leftTreaAni))

        self.rightTreaAni:removeFrameCallFunc()
        self.rightTreaAni:playWithIndex(2,false)
        self.rightTreaAni:gotoAndPlay(1)
        self.rightTreaAni:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.rightTreaAni))
        self.treaState = "onlyIcon"
    elseif self.treaState == "leftTreaOn" then
        --左侧法宝在身
        self.leftTreaAniCopy:removeFrameCallFunc()
        self.leftTreaAniCopy:playWithIndex(3,false)
        self.leftTreaAniCopy:gotoAndPlay(1)
        self.leftTreaAniCopy:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.leftTreaAniCopy))
        self.treaState = "onlyIcon"
    elseif self.treaState == "rightTreaOn" then
        --右侧法宝在身
        self.rightTreaAniCopy:removeFrameCallFunc()
        self.rightTreaAniCopy:playWithIndex(3,false)
        self.rightTreaAniCopy:gotoAndPlay(1)
        self.rightTreaAniCopy:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.rightTreaAniCopy))
        self.treaState = "onlyIcon"
    elseif self.treaState == "iconAndTreaWithLeftTreaon" then
        self.leftTreaAni:removeFrameCallFunc()
        self.leftTreaAni:playWithIndex(2,false)
        self.leftTreaAni:gotoAndPlay(1)
        self.leftTreaAni:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.leftTreaAni))

        self.rightTreaAni:removeFrameCallFunc()
        self.rightTreaAni:playWithIndex(2,false)
        self.rightTreaAni:gotoAndPlay(1)
        self.rightTreaAni:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.rightTreaAni))

        self.leftTreaAniCopy:removeFrameCallFunc()
        self.leftTreaAniCopy:playWithIndex(3,false)
        self.leftTreaAniCopy:gotoAndPlay(1)
        self.leftTreaAniCopy:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.leftTreaAniCopy))
        self.treaState = "onlyIcon"
    elseif self.treaState == "iconAndTreaWithRightTreaOn" then
        self.leftTreaAni:removeFrameCallFunc()
        self.leftTreaAni:playWithIndex(2,false)
        self.leftTreaAni:gotoAndPlay(1)
        self.leftTreaAni:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.leftTreaAni))

        self.rightTreaAni:removeFrameCallFunc()
        self.rightTreaAni:playWithIndex(2,false)
        self.rightTreaAni:gotoAndPlay(1)
        self.rightTreaAni:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.rightTreaAni))
        self.rightTreaAniCopy:removeFrameCallFunc()
        self.rightTreaAniCopy:playWithIndex(3,false)
        self.rightTreaAniCopy:gotoAndPlay(1)
        self.rightTreaAniCopy:registerFrameEventCallFunc(nil,1,c_func(self.onAniPlayCallBack,self,self.rightTreaAniCopy))
        self.treaState = "onlyIcon"
    end
end


--[[
玩家血量没有死亡了
]]
function BattleTreasureView:onMainHeroOver(  )
    
end



function BattleTreasureView:initControler( view,controler )
	self._battleView = view
	self.controler = controler

end

--[[
初始化主角法宝
]]
function BattleTreasureView:initHeroTrasure(  )
    local treasures = self.userHero.data.treasures
    local index = 0
    local view
    for i,v in ipairs(treasures) do
        if v.treaType ~= "base" then
            index = index +1
            if index >=3 then
                break
            end
            local treasure = v
            if not treasure then
                treasure = treasures[1]
            end
            local icon = FuncRes.iconEnemyTreasure(treasure:sta_icon())
            local iconSp = display.newSprite(icon):scale(0.5):pos(0,20)

            view = self.panel_left["panel_"..(index+1)]
            if index+1 == 2 then
                self.leftTreaIcon = icon
            end
            if index+1 == 3 then
                self.rightTreaIcon = icon
            end
            view.treasure = treasure
            view.treasureIndex = index
            view.panel_1.ctn_1:addChild(iconSp)
            --先判断特效名字
            local quality =treasure:sta_quality()
            --显示星级
            view.panel_1.mc_dou:showFrame(treasure:star() or 2)
            --显示品质
            view.panel_1.mc_1:showFrame(quality)
            view.mc_1:visible(false)
            view.hero = self.userHero
            view:setTouchedFunc(c_func(self.pressTreasureIcon,self,view),cc.rect(-92/2, -92/2, 92, 92),false)

            --初始化panel2_copy,panel3_copy
            -- view = self.panel_left["panel_"..(index+1).."Copy"]
            -- view.treasure = treasure
            -- view.treasureIndex = index
            -- view.panel_1.ctn_1:addChild(display.newSprite(icon):scale(0.5):pos(0,20))
            -- view.panel_1.mc_dou:showFrame(treasure:star() or 2)
            -- view.panel_1.mc_1:showFrame(quality)
            -- view.mc_1:visible(false)
            -- view.hero = self.userHero
            -- view:setTouchedFunc(c_func(self.pressTreasureIcon,self,view),nil,false)

        else
            view = self.panel_left["panel_"..1]
            --标记这个view是 主角
            view.isChar = true
            self:initOneHero(self.userHero, view)

        end
    end

end


--[[
初始化法宝显示
]]
function BattleTreasureView:initOneHero( hero ,view)
    --当这个视图绑定hero 
    view.hero = hero
    --同时拿到英雄的法宝 技能图像进行暂时
    local iconSp = display.newSprite(FuncRes.iconHero(hero:getIcon()))

    local clipNode = display.newClippingRectangleNode(cc.rect(-92/2, -92/2, 92, 92))
    clipNode:setCascadeOpacityEnabled(true)
    clipNode:addChild(iconSp)
    view.mc_2:showFrame(1)
    local contenter = view.mc_2.currentView
    --contenter.ctn_1:addChild(iconSp)
    contenter.ctn_1:addChild(clipNode)
    --侦听英雄血量变化和能量变化
    view.hero.data:addEventListener(BattleEvent.BATTLEEVENT_CHANGEHEALTH, c_func( self.onHpChanged ,self,view), self)
    view.hero.data:addEventListener(BattleEvent.BATTLEEVENT_CHANGEENEGRY, c_func( self.onEnergyChange ,self,view), self)
    self:onEnergyChange(view,true)
    self:onHpChanged(view,true)



    -- nd:setTouchedFunc(GameVars.emptyFunc, 
    --     nil, 
    --     true, 
    --     c_func(self.pressClickViewDown, self), 
    --     c_func(self.pressClickViewMove, self),
    --     false,
    --     c_func(self.pressClickViewUp, self) 
    --     )




    view:setTouchedFunc(c_func(self.pressHeroIcon,self,view),
        cc.rect(-92/2, -92/2, 92, 92),
        false,
        c_func(self.pressHeroIconBegin,self,view),
        c_func(self.pressHeroIconMoved,self,view),
        false,
        c_func(self.pressHeroIconEnded,self,view)
        )

end




--英雄血量发生变化
function BattleTreasureView:onHpChanged( view,isinit)
    --local percent = math.round( view.hero.data:hp()/ view.hero.data:maxhp() *100 )
    local percent = view.hero.data:hp()/ view.hero.data:maxhp() *100
    --如果小于0  那么置灰
    if percent <=0 then
        percent = math.round(percent)
        --self:checkSkillShow(view)
        FilterTools.setGrayFilter(view, 1)
        --所有特效停止
        if view.djnAni then
            view.djnAni:visible(false)
        end
        if view.xjnAni then
            view.xjnAni:visible(false)
        end

        if view.isChar then
            --self:openOrCloseCharView(false)
            FilterTools.setGrayFilter(self.headAni, 1)
            --FilterTools.setGrayFilter(self.treasCome,1)
            FilterTools.setGrayFilter(self.leftTreaAni,1)
            FilterTools.setGrayFilter(self.rightTreaAni,1)
            self:onHeroDied()

        end
        if view.ctn_2 then
            view.ctn_2:visible(false)
        end
        --怒气 设置 0 如果血量<=0 则 怒气值就没有意义
        --echo("血量为0  怒气也设置为0")
        view.panel_2.progress_1:tweenToPercent(0)

    else
        FilterTools.clearFilter()
    end
    local fcnt = 20
    if isinit then fcnt = 0 end
    view.panel_1.progress_1:tweenToPercent(percent,fcnt)
end

--英雄生命发生变化
function BattleTreasureView:onEnergyChange( view,isinit)

    local percent = math.floor( view.hero.data:energy()/ view.hero.data:maxenergy() *100 )
    --local hpPercent =  math.round( view.hero.data:hp()/ view.hero.data:maxhp() *100 )
    local hpPercent =   view.hero.data:hp()/ view.hero.data:maxhp() *100 
    if hpPercent<=0 then
        percent = 0
    end
    --echo("能量百分比:",percent)
    local fcnt = 20
    if isinit then fcnt = 0 end
    view.panel_2.progress_1:tweenToPercent(percent,fcnt)
    --如果是主角  
    if view.isChar then
        --这里暂时这么做 todo dev
        --self:checkSkillShow(view)
        --echo("能量发生变化")
    else
        --self:checkSkillShow(view)
    end
end

--展开或者收缩左下侧的点击区域 true  是展开 false 是收缩
function BattleTreasureView:openOrCloseCharView( value )

end

--[[
开始点击Icon
]]
function BattleTreasureView:pressHeroIconBegin( view )
    --echo("开始点击Icon")
    if not self:checkCanClick(view) then
        return
    end

    view.hero:pressClickViewDown()
end

--[[
点击Icon移动
]]
function BattleTreasureView:pressHeroIconMoved( view )
    --echo("点击Icon移动")
    --pressClickViewMove
    if not self:checkCanClick(view) then
        return
    end

    view.hero:pressClickViewMove()
end

--[[
松开Icon
]]
function BattleTreasureView:pressHeroIconEnded( view )
    --echo("松开Icon")

    if not self:checkCanClick(view) then
        return
    end

    view.hero:pressClickViewUp()
end



-- 点击英雄图标
function BattleTreasureView:pressHeroIcon(view)
    --echo("点击英雄的图标-------")
    if not self:checkCanClick(view) then
        return
    end

    self:afterPlayChooseTargetAni(view)

    if view.isChar then
         --能量满的时候 不能释放普通法宝的 不管是不是素颜都不能放普通法宝
        if  view.hero.data:energy() >= view.hero.data:maxenergy()  then
            return 
        end
    else
        local djnClickAniCallBack
        djnClickAniCallBack = function (  )
            --echo("大技能点击特效播放完成-----")
            view.djnClickAni:pause(false)
            view.djnClickAni:visible(false)
        end
        local xjnClickAniCallBack
        xjnClickAniCallBack = function (  )
            view.xjnClickAni:removeFrameCallFunc()
            --echo("小技能点击特效播放完成------")
            view.xjnClickAni:pause(false)
            view.xjnClickAni:visible(false)
        end
        local hero = view.hero
        local energy = hero.data:energy()
        if energy >= hero.data:maxenergy() then
            --当前是大技能点击特效
            if not view.djnClickAni then
                view.djnClickAni= FuncArmature.createArmature("UI_zhandou_djnengdianji",view.ctn_2,false,GameVars.emptyFunc)
                view.djnClickAni:visible(false)
            end
            if view.djnClickAni then
                --echo("大技能点击特效展示----------")
                view.djnClickAni:visible(true)
                view.djnClickAni:play(false)
                view.djnClickAni:doByLastFrame(false,true,djnClickAniCallBack)
            end
        else
            if hero.nextSkillIndex == Fight.skillIndex_small then
                --当前是小技能点击特效
                if not view.xjnClickAni then
                    view.xjnClickAni = FuncArmature.createArmature("UI_zhandou_xjndianji",view.ctn_2,false,GameVars.emptyFunc)
                    view.xjnClickAni:visible(false)
                end
                if view.xjnClickAni then
                    --echo("小技能点击特效展示-----------")
                    view.xjnClickAni:removeFrameCallFunc()
                    view.xjnClickAni:visible(true)
                    view.xjnClickAni:play(false)
                    view.xjnClickAni:gotoAndPlay(0,false)
                    --view.xjnClickAni:doByLastFrame(false,true,xjnClickAniCallBack)
                    view.xjnClickAni:registerFrameEventCallFunc(11,false,xjnClickAniCallBack)
                end
            else
                --普通攻击没有效果
                -- if view.xjnClickAni then
                --     --view.xjnClickAni:pause
                -- end
            end
        end
        --点击特效
        -- local callBack
        -- callBack = function (  )
        --     view.clickAni:pause(false)
        -- end
        -- if not view.clickAni  then
        --     view.clickAni= FuncArmature.createArmature("UI_zhandou_fabao_dianji",view.ctn_2,false,GameVars.emptyFunc)
        -- end
        -- view.clickAni:removeFrameCallFunc()
        -- view.clickAni:playWithIndex(0,false)
        -- view.clickAni:registerFrameEventCallFunc(15,1,callBack)


    end
    self.controler.logical:insterOneHandle(1,view.hero.data.posIndex,Fight.operationType_giveSkill)
end

-- 点击法宝图标
function BattleTreasureView:pressTreasureIcon(view)
    if not self:checkCanClick(view) then
       return
    end
    --如果能量是不满的
    if view.hero.data:energy() < view.hero.data:maxenergy() then
        return
    end

    local callBack
    callBack = function (  )
        view.treaClickAni:removeFrameCallFunc()
        view.treaClickAni:visible(false)
        view.treaClickAni:pause(false)
    end

    if not view.treaClickAni then
        view.treaClickAni = FuncArmature.createArmature("UI_zhandou_dajinengdianji",view.panel_1.ctn_1,false,GameVars.emptyFunc)
        view.treaClickAni:visible(false)
    end
    if view.treaClickAni then
        view.treaClickAni:removeFrameCallFunc()
        view.treaClickAni:visible(true)
        view.treaClickAni:playWithIndex(0,false)
        view.treaClickAni:registerFrameEventCallFunc(nil,false,callBack)
    end

    --如果是同一个treasure  那么就放小技能 否则就 换法宝
    -- if view.hero.data.curTreasure == view.treasure then
    --    self.controler.logical:insterOneHandle(1,view.hero.data.posIndex,Fight.operationType_giveSkill)
    -- else
    --     self.controler.logical:insterOneHandle(1,view.hero.data.posIndex,Fight.operationType_giveTreasure,view.treasureIndex)
    -- end
    -- self.controler.logical:insterOneHandle(1,view.hero.data.posIndex,Fight.operationType_giveTreasure,view.treasureIndex)
    
    

end

--判断某个法宝能否点击
function BattleTreasureView:checkCanClick( view )
    local hero = view.hero
    
    if self.controler.logical.currentCamp ~= 1 then
        return false
    end

    --如果游戏模式是不可操作的
    if not self.controler:checkCanHandle() then
        return false
    end
    
    if not view.hero.data:checkCanAttack() then
        return
    end
    if view.hero.data:hp()<=0 then
        return false
    end

    --如果已经 攻击了
    if hero.hasOperate then
        return false
    end

    return true
end


--屏蔽掉不能点击的视图   检查是否可以放技能
function BattleTreasureView:checkDisableView( view,isRoundStart)


    if not self:checkCanClick(view) then
        --local icon = view.mc_2.currentView.ctn_1
        
        if view.isChar then
            --echo("变灰------")
            --self.headAni:opacity(76)
            self.panel_left:opacity(120)
        else
            view:opacity(120)
        end
    else
        if view.isChar then
            --echo("不变灰-----")
            --self.headAni:opacity(255)
            self.panel_left:opacity(255)
        else
            view:opacity(255)
            local callBack
            callBack = function (  )
                view.canClickAni:pause(false)
            end
            if not view.canClickAni then
                 view.canClickAni = FuncArmature.createArmature("UI_zhandou_fabao_liang",view.ctn_2,false,nil)
            end
            if isRoundStart then
                view.canClickAni:removeFrameCallFunc()
                view.canClickAni:playWithIndex(0,false)
                view.canClickAni:registerFrameEventCallFunc(16,false,callBack)
            end
        end
    end
end



--
--------------------------侦听事件---------------------------

--更新法宝
function BattleTreasureView:updateTreasure( event )
    
end

--当威能发生变化
function BattleTreasureView:updateHeroUI( event )

	
end






return BattleTreasureView