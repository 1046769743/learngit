local PlotDialogView = class("PlotDialogView", UIBase)

--//逆向映射表
local     EmojiMap={
        UI_lihuibiaoqing_1="expression_jingya",--//惊讶
        UI_lihuibiaoqing_11="expression_yiwen",--//疑问
        UI_lihuibiaoqing_13="expression_yun",--//晕
        UI_lihuibiaoqing_3="expression_fennu",--//愤怒
        UI_lihuibiaoqing_5="expression_gaoxing",--//高兴
        UI_lihuibiaoqing_7="expression_liuhan",--//流汗
        UI_lihuibiaoqing_9="expression_ku",--//哭泣
};
--//主角动画映射
local    PlayerMap={
        [1]="art_nanzhulihui",--//男主角
        [2]="art_nvzhulihui",--//女主角
};
-- 克隆原件子集内的组件
-- local view = UIBaseDef:cloneOneView(self.mc_mailzong1:getViewByFrame(1).panel_1)
function PlotDialogView:ctor(winName, controler)
    PlotDialogView.super.ctor(self, winName)
    
    --这个应该是后边的那个黑色半透明框
    local topBorderBg = display.newColorLayer(cc.c4b(100, 50, 30, 255))
    --local topBorderBg = display.newColorLayer(cc.c4b(255, 255, 255, 0))
    topBorderBg:setPlotLayerSize(GameVars.width+300,GameVars.height+300);

    --order对应和对应的立绘
    self.rowImg = {}
    --以keyValue的形式存储.  key是立绘的名字 value是立绘对应的ctn
    self.art = {}

    --self.sire = data
    --展示对话的控制器
    self.controler = controler
    --self.oldRes = ""
    --self.plotAni = nil
    --self.oldPos = 0
    --self.oldArtPos = 0
    topBorderBg:setPosition(cc.p(100, 100));
    self:addChild(topBorderBg)

    self.ANI_RUN_ACTION =
    {
        MIDDLE_TO_LEFT = 80,
        MIDDLE_TO_RIGHT = 81,
        LEFT_TO_MIDDLE = 82,
        RIGHT_TO_MIDDLE = 83,
        LEFT_TO_RIGHT = 84,
        RIGHT_TO_LEFT = 85,
    }
    self.LOCATION =
    {
        LEFT = 1,
        MIDDLE = 2,
        RIGHT = 3
    }

    self.aniIcon = nil
    self.artIcon = nil
    self.aniCtnPos = 0

    self.btnPos = {
        left = cc.p(0,0),
        right = cc.p(0,0),
    }
    --self.originPosition=WindowControler:getScene():getPosition();
    -- AudioModel:playMusic(MusicConfig.s_battle_win, false)
end
function PlotDialogView:loadUIComplete()
    self.btState = false

    --self.mc_bg:zorder(20)
    --self.rich_1:zorder(20)
    --self.panel_name1.txt_1:setString("")
    --self.panel_name1:zorder(20)
    --self.ctn_1:zorder(20)

    self:registerEvent()
    -- 设置组件对齐方式
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_bg, UIAlignTypes.LeftBottom)
    for i=1,7 do
        self.mc_bg:showFrame(i)
        local scro_view = self.mc_bg.currentView.scale9_1
        FuncCommUI.setScale9Align(self.widthScreenOffset,scro_view,UIAlignTypes.Middle, 1, 0)
    end

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_1:getViewByFrame(1), UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_1:getViewByFrame(2), UIAlignTypes.RightBottom)


    --富文本的进度条
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.rich_1, UIAlignTypes.MiddleBottom)

    self.rich_1:setVisible(false)

    self.mc_bg:setScaleX(GameVars.width / (GameVars.gameResWidth -GameVars.widthDistance  )  )


    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_1, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_2, UIAlignTypes.RightTop)

    -- 存一下位置，方便后面调整按钮位置
    self.btnPos.left = cc.p(self.btn_2:getPosition())
    self.btnPos.right = cc.p(self.btn_1:getPosition())

    -- 添加跳过和退出按钮
    self.btn_1:setTap(function ()
        EventControler:dispatchEvent(BattleEvent.ANIMDIALOGVIEW_EXIT)
        self.controler:destoryDialog(true)
    end)
    self.btn_2:setTap(function ()
        EventControler:dispatchEvent(BattleEvent.ANIMDIALOGVIEW_JUMP)
        self.controler:destoryDialog(true)
    end)
    self.btn_1:visible(false)
    self.btn_2:visible(false)


end 

function PlotDialogView:btnShow(param)
    local _tiaoguo = param.params.show
    local _fanhui = param.params.show2

    self.btn_1:setVisible(_fanhui)
    self.btn_2:setVisible(_tiaoguo)

    -- 返回显示，自己在自己的位置
    if _fanhui then
        self.btn_2:setPosition(self.btnPos.left)
    else
        -- 跳过放到右边
        self.btn_2:setPosition(self.btnPos.right)
    end
end

--[[
文字打印完成
]]
function PlotDialogView:onPrintComplete()
    --self.richPrintComplete = true
    --echo("文字打印完成----------")
end

function PlotDialogView:setAnimId(animId)
    self.animId = animId
end
 
function PlotDialogView:registerEvent()
    PlotDialogView.super.registerEvent();
    --这是跳过按钮
    -- self.btn_1:setTap(c_func( function()
    --     self.controler:skipPlot()
    -- end , self));
    EventControler:addEventListener(BattleEvent.PLOTVIEW_BTN_SHOW,self.btnShow,self)


    --self.btn_1:setTouchSwallowEnabled(true);
    --self.panel_duihua:setGlobalZOrder(100)
    --注册点击任意地方事件   
    self:registClickClose(-1, c_func( function()
        --self.controler:onTouchEvent()
        --echo("点击全屏幕 -----   是否和 skipPlot() 一样的操作")
        --echo(self.richPrintComplete,"===============")
        --if self.richPrintComplete then
            --echo("吓一跳立绘----------------------")
            --self.controler:skipPlot()
            self:skipNextPlot()
        --else
            --todo
            --echo("跳过打印---------")
         --   self.rich_1:skipPrinter()
        --end
    end , self))


    
    --self.rich_1:registerCompleteFunc(c_func(self.onPrintComplete,self))



    local _eventCallBack = { }
    -- for i = 1, 3 do
    --     _eventCallBack[i] = function()

    --     end
    --     self.panel_duihua["btn_duihua" .. i]:setTap(c_func( function()
    --         echo ("click ---------------here")
    --         self.sire:optionCallback(i)
    --         self:setOptionVisible(false)
    --     end , self));
    -- end
end 




--[[
显示界面上的
名字
立绘，带有表情的     根据入场方式确定进入场景的动画方式
把原来的立绘 隐藏掉  稍提前与 立绘动画
@params curRow:当前要显示的立绘对应的row
@params exitTab：要退出的立绘对应的row 
]]
function PlotDialogView:showNextStepView(curRow,exitTab)
   
   --echoError("===============")
   -- echo("当前order的显示数据")
   -- dump(curRow)
   -- echo("当前order的显示数据")


    --self:fadeOutLastPlayer()

   -- local callBack = function ( ... )
   --     --echo("动画播放完成的回调方法===============")
   --     self:showCurInfo( curRow )
   -- end

   --local lastPlayerHide = function (  )
       --echo("隐藏上一个人物立绘")
       self:showScene(curRow)
   --end

   --self:hideExitPlayer(exitTab,lastPlayerHide)

   --self:showCurPlayer(curRow,callBack)
   self:showCurOrderView(curRow,callBack)
   self:showCurInfo( curRow )

   if curRow.clientAction then
       ClientActionControler:sendTutoralStepToWebCenter(curRow.clientAction)
       -- if curRow.clientAction == "guide-xz-sszhduihua22" then
       --      echo("----------",curRow.clientAction)
       -- elseif curRow.clientAction == "guide-xz-sszhduihua23" then 
       --      echo("----------",curRow.clientAction)
       -- elseif curRow.clientAction == "guide-xz-sszhduihua24" then 
       --      echo("----------",curRow.clientAction)
       -- elseif curRow.clientAction == "guide-xz-sszhduihua25" then 
       --      echo("----------",curRow.clientAction)
       -- end
       echo("----------",curRow.clientAction)
   end
   
  --self:stopAllActions()
   --self:delayCall(c_func(self.skipNextPlot,self), 5)
end



--[[
跳到下一条
]]
function PlotDialogView:skipNextPlot(  )

        --echo("点击下一条------",self.canSkip,(not self.needJump))
    if self.controler and self.canSkip and (not self.needJump) then
        self.controler:skipPlot()
    end
end




--[[
是否可以下一条
震屏期间不能下一条
]]
function PlotDialogView:setCanSkip( isCanSkip )
    self.canSkip = isCanSkip
end



--[[
显示场景
这个相当于不需要了
因为字幕效果 不需要这个
]]
function PlotDialogView:showScene( rowData )
    if self.scene then self.scene:clear() self.scene = nil end
    if rowData.scene ~= nil then
        self.scene = display.newSprite(FuncRes.iconBg( rowData.scene..".png" )):addto(self,-10)    
         self.scene:pos(GameVars.width/2+GameVars.UIbgOffsetX,-GameVars.height/2)
    end
    
end

--[[
显示当前的立绘对话
这里要判断是否有选择框
目前只会显示一个人物立绘
]]
function PlotDialogView:showCurOrderView(rowData,callBack)
    -- echo("当前的rowData--------")
    -- dump(rowData)
    -- echo("当前的rowData--------")

    local adjustT = rowData.adjust 
    if not adjustT then
        adjustT = {}
        echoError("此时 plottem中id为",rowData.id,"中adjust字段没配 用默认的")
    end

    --这里需要判断 是否有选择
    local frame = 1
    local dir = -1
    local offsetY = tonumber(adjustT[3]) or -120
    local offsetX = tonumber(adjustT[2]) or 50
    local _scale = tonumber(adjustT[1]) or 3
    --local align = UIAlignTypes.LeftBottom
    if tonumber(rowData.pos)>0.5 then  -- 右边
        frame = 2
        dir = 1
--        offsetX = -offsetX
        --align = UIAlignTypes.RightBottom
    end
    self.mc_1:showFrame(frame)
    local view = self.mc_1.currentView
    -- dump(rowData, "--------------ddd---------", 4)
    local player = self:loadImgRes(rowData.img, true,rowData.emoji,rowData.actionSource)
    local ctn = view.ctn_zuo
    ctn:removeAllChildren()
        
    player:setPositionX(offsetX)
    player:setPositionY(offsetY)
    player:setScaleX(_scale*-1)
    player:setScaleY(_scale)
    player:addTo(ctn)

end

function PlotDialogView:hideUI( isHide )
    self.mc_1:visible(isHide)
    self.mc_bg:visible(isHide)
    self.rich_1:visible(isHide)
end



--[[
显示当前的立绘对话
]]
function PlotDialogView:showCurPlayer( rowData,callBack)

    -- echo("当前的rowData--------")
    -- dump(rowData)
    -- echo("当前的rowData--------")

    --echo("--------------")
    --获取相应的资源
    local pos = rowData.pos
    --echo("GameVars.width",GameVars.width,"GameVars.UIbgOffsetX",GameVars.UIbgOffsetX,"GameVars.UIOffsetX",GameVars.UIOffsetX,"GameVars.sceneOffsetX",GameVars.sceneOffsetX)

    local targetX = (GameVars.width-200)*pos+20
    --local targetX = 0 --(GameVars.width-270)*pos+110-GameVars.UIbgOffsetX
    --local targetX = GameVars.width
    local targetY = self.ctn_zuo:getPositionY()
    local cb = function ( ... )
            if callBack then
                callBack()
            end
    end

    -- local dir = rowData.dir
    -- if dir == nil then dir = 1 end
    -- if dir == 1 then dir = -1 end

     local dir = 1
     if rowData.dir ~= nil and rowData.dir ~= 1 then
        dir = -1
     end


    --这里要判断创建的立绘ctn是否存在  如果存在 则直接调用 执行action，如果不存在。则创建
    if self.art[rowData.img] == nil then

        local player = self:loadImgRes(rowData.img, true,rowData.emoji,rowData.actionSource)
        local ctn = UIBaseDef:cloneOneView(self.ctn_zuo)
        
        FuncCommUI.setViewAlign(self.widthScreenOffset,ctn, UIAlignTypes.MiddleBottom)
        
        ctn:zorder(-10)
        self.ctn_zuo:getParent():addChild(ctn)
        
        player:setScaleX(1*dir)
        player:setScaleY(1)
        --FilterTools.setFlashColor(player, "lowLight" )
        player:addTo(ctn)
        ctn:visible(true)
        

        --保存每个步骤的立绘内容
        self.rowImg[rowData.order] = {node = ctn,data = rowData}
        self.art[rowData.img] = ctn
        self.lastPlayerData = {node = ctn,data = rowData}


        

        if rowData.cutin == 1 then
            --左侧滑入
            --看效果
            ctn:setPositionX(-300)
            ctn:setPositionY(targetY)
            ctn:runAction(
                cc.Sequence:create(
                    cca.moveTo(0.5,targetX,targetY),
                    cc.CallFunc:create(cb)
                )
            )
        elseif rowData.cutin == 2 then
            --右侧滑入
            ctn:setPositionX(GameVars.width+300)
            ctn:setPositionY(targetY)
            ctn:runAction(
                cc.Sequence:create(
                    cca.moveTo(0.5,targetX,targetY),
                    cc.CallFunc:create(cb)
                )
            )   
        elseif rowData.cutin == 3 then
            --FadeIn
            ctn:setPositionX(targetX)
            ctn:setPositionY(targetY)
            cnt:setOpacity(0)
            ctn:runAction(
                cc.Sequence:create(
                    cc.FadeIn:create(0.5),
                    cc.CallFunc:create(cb)        
                )     
            )
        end
    else
        --调用的立绘已经存在的情况
        self.rowImg[rowData.order] = {node = self.art[rowData.img],data = rowData}
        --echo("这里=================")
        self.rowImg[rowData.order].node:setScaleX(1*dir)
        self.rowImg[rowData.order].node:setScaleY(1)
        --相应的立绘执行相应的移动和放大和缩小
        if self.lastPlayerData.node ==  self.rowImg[rowData.order].node then
            --echo("相等的===========================")
            --如果就是上一个。那么执行 移动操作就可以了
            self.rowImg[rowData.order].node:runAction(
                cc.Sequence:create(
                    act.moveto(0.4, targetX, targetY),
                    cc.CallFunc:create(cb)
                )
            )
            
            --self.rowImg[rowData.order].node:runAction(act.bouncein( act.scaleto(10/GameVars.GAMEFRAMERATE ,1,1) ) )
            self.rowImg[rowData.order].node:runAction( act.scaleto(5/GameVars.GAMEFRAMERATE ,1,1)  )
            --local toColor = FilterTools.turnColorTranform(0.4,0.4,0.4,1,0,0,0,0)
            --FilterTools.flash_easeBetween(self.rowImg[rowData.order].node,5,nil,"lowLight",toColor)
            FilterTools.flash_easeBetween(self.rowImg[rowData.order].node,5,nil,"lowLight2","oldFt")

        else
            --如果不是上一个，已经被缩小隐藏了。则执行发达，移动操作
            self.rowImg[rowData.order].node:runAction(
                cc.Sequence:create(
                        act.moveto(0.4, targetX, targetY),
                        cc.CallFunc:create(cb)    
                        )
                    )
            --self.rowImg[rowData.order].node:runAction(act.bouncein( act.scaleto(10/GameVars.GAMEFRAMERATE ,1,1) ) )
            self.rowImg[rowData.order].node:runAction( act.scaleto(5/GameVars.GAMEFRAMERATE ,1,1)  )
            local toColor = FilterTools.turnColorTranform(0.4,0.4,0.4,1,0,0,0,0)
            FilterTools.flash_easeBetween(self.rowImg[rowData.order].node,5,nil,"lowLight2","oldFt")
            --FilterTools.flash_easeBetween(self.rowImg[rowData.order].node,5,nil,"lowLight",toColor)
        end


        self.lastPlayerData = {node = self.art[rowData.img],data = rowData}
    end
    self:chkZorder()

end



--[[
设置每个立绘的zorder
]]
function PlotDialogView:chkZorder(  )
    for k,v in pairs(self.art) do
        if not tolua.isnull(v) then
               if v == self.lastPlayerData.node then
                    v:zorder(0)
                else
                    v:zorder(-1)
               end 
        end
    end
end

--[[
显示名字
富文本文字
]]
function PlotDialogView:showCurInfo( rowData )
    self.needJump = false

    self:clearChooseView()
    local view = self.mc_1.currentView
    local name = ""
    if LoginControler:isLogin() then
        name = UserModel:name()
    end

    
    view.txt_1:setString(FuncPlot.getLanguage(rowData.name,name))
    --view.panel_name1:zorder(20)
    self.rich_1:setVisible(true)

    -- 设置男女的对话内容
    local __str = nil
    local __soundN = nil
    if tostring(UserModel:avatar()) == "101" then
        __str = rowData.text
        __soundN = rowData.bsound
    else
        if rowData.text1 then
            __str = rowData.text1 
            
        else
            __str = rowData.text 
            -- __soundN = nil--rowData.bsound -- 此处修改是应策划要求 没配时 就不播放
            -- echoError("找 剧情对话 没有配女 对话   id === "..rowData.id)
        end
        __soundN = rowData.gsound
    end
    local displayTxt = FuncPlot.getLanguage(__str,name)

    self:setRichText(displayTxt)
    if self.currentSound then
        echo("dangqian guanbi de yinxiao  =11= ",self.currentSound)
        -- AudioModel:stopSound(self.currentSound)
        audio.pauseAllSounds()
    end
    if __soundN then
        self.currentSound = AudioModel:playSound(__soundN)
    end

    self.btn_talk:visible(false)
    local posX,posY = self.btn_talk:getPositionX(),self.btn_talk:getPositionY()

    local chooseArr = {}
    for i=1,4,1 do
        if rowData["dialog"..i] then
            table.insert(chooseArr, rowData["dialog"..i])
        end
    end

    local cnt = #chooseArr
    --获取view 按钮真正所在的位置
    local getRealPosY = function ( index )
        local posY = posY + index*80-(cnt)/2*80
        return posY
    end

    --遍历选择项，然后绑定按钮事件 执行跳转操作
    for k,v in ipairs(chooseArr) do
        local chooseAni = self:createUIArmature("UI_lihuibiaoqing", "UI_lihuibiaoqing_juqingduihua"
            ,self,false,GameVars.emptyFunc)
        local kuang = chooseAni:getBoneDisplay("kuang")
        local tishi = chooseAni:getBoneDisplay("layer3")
        -- kuang:playWithIndex(1,false,false)
        tishi:play()
        local view = UIBaseDef:cloneOneView(self.btn_talk):visible(true)
        view:pos(0,0)
        chooseAni:pos(GameVars.gameResWidth/2,getRealPosY(k)) --:addto(self.btn_talk:getParent())

        FuncArmature.changeBoneDisplay(chooseAni,"wenzi",view)
        view:getUpPanel().txt_1:setString(FuncPlot.getLanguage(v[1].n,UserModel:name(  )))
        view:setTouchedFunc(c_func(self.doJumpToAction,self,v),nil,nil,nil,nil,false)

        table.insert(self.chooseViewArr,chooseAni)

        self.needJump = true
    end

end


--[[
执行跳转操作
1 = {
-         "l" = 10                                  跳转到的plotId
-         "n" = "#tid_plot_32"                      选择框上面的plotTips
-         "x" = "heixiu"                            跳转到的animationLabel
-         "y" = 0                                   跳转到的animationLabel对应的frame
-     }
]]
function PlotDialogView:doJumpToAction( data )

    if toint(data[1].l ) ~= 0 then
        --plotControl跳转到相应的plotId
        self.controler:skipNewPlot(tostring(data[1].l))
        return 
    end

    local lbl = tostring(data[1].x)
    local frameCnt = toint(data[1].y)

    if lbl ~= "0" or frameCnt ~= 0 then
        --动画需要跳转
        --echo("发送消息--------")
        self.controler:destoryDialog()
        EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_ANIMATION_JUMP_FRAME,{animLabel = lbl,frame = frameCnt})
    else
        --需要解锁当前的锁
        echo("ppppppppppppppppp----------------")
        self.controler:skipPlot()
    end
end

function PlotDialogView:clearChooseView( )
    if self.chooseViewArr then
        if #self.chooseViewArr>0 then
            for k,v in ipairs(self.chooseViewArr) do
                self.chooseViewArr[k]:clear()
            end
        end
       
    end
    self.chooseViewArr = {}
end

--[[
显示框
]]
 function PlotDialogView:setBackGroupImg(board)
    if board == nil then return end 
     if(board>0)then
        self.mc_bg:showFrame(board)
     else
        self.panel_duihua:setVisible(false);
        self.ctn_zuo:removeAllChildren(); ---//tatata
        self.ctn_zhong:removeAllChildren();
        self.ctn_you:removeAllChildren();
     end
 end 

-- 加载图片
function PlotDialogView:loadImgRes(resName, isArt,_emoji,_action)
    if resName == nil then 
        echoError("loadImgRes image name is null 暂时用主角代替");
        local   avatar=UserModel:avatar();
        -- resName = PlayerMap[1];
        local garmentId = GarmentModel:getOnGarmentId()
        resName = FuncGarment.getGarmentSpinName(garmentId,avatar)
    end
    local    _image;

    --加载Spine动画
   if(resName == "player")then
          local   avatar=UserModel:avatar();
          -- resName = PlayerMap[1];
          local garmentId = GarmentModel:getOnGarmentId()
          resName = FuncGarment.getGarmentSource(garmentId, avatar)
   end
    local sourceCfg = FuncTreasure.getSourceDataById(resName)
    local artSpine= FuncRes.getSpineViewBySourceId(resName,nil,true ,sourceCfg)
    if _action then
        artSpine:playLabel(sourceCfg[_action], true)
    end
    if(_emoji ~=nil)then
        assert(_emoji ~="");
        local   pos=artSpine:getBonePos(EmojiMap[_emoji]);--//加载逆向映射表
        local   ani=self:createUIArmature("UI_lihuibiaoqing", _emoji, artSpine, true, GameVars.emptyFunc);
        ani:pos(pos.x,pos.y);
    end
    if not artSpine then
        echoError("resName === ",resName)
    end
    return   artSpine;
end 

function PlotDialogView:loadPlayerImg(data, runAct)
    -- 该处可以用于立绘显示 以及  动画所用立绘形象
    local _ipos = data.pos
    -- 初始朝向
    local   _dir=_ipos[2]== 2 and 1 or -1;
    self.aniIcon = self:loadImgRes(data.img, false,data.emoji,data.actionSource)
    local _pos = _yuan3(self.aniCtnPos ~= 0, self.aniCtnPos, _ipos[1])
    self.aniIcon:setPositionX(50)
    self.aniIcon:setScaleX(_dir);
    self.plotCtn[_pos]:removeAllChildren();
    --self.aniIcon:parent(self.plotCtn[_pos])
    self.plotCtn[_pos]:addChild(self.aniIcon)
    self.oldPos = _pos
    if runAct then
        self:runAniAction(data)
    end
end 

function PlotDialogView:runAniAction(data)
    if self.aniIcon == nil then return end
    local _posX = self:getCtnPos(data.enterAni):convertLocalToNodeLocalPos(self.aniIcon)
    self.otherCtn=  self.oldPos
    function _callBack()
        self.sire:aniCompleteCallBack()
    end
    -- local _action = cc.Sequence:create(cc.MoveTo:create(10, cc.p(_posX, self.aniIcon:getPositionY())), cc.CallFunc:create(_callBack))
    local _args = { onComplete = _callBack }
    local _dir = _yuan3(data.pos[2] == 1, 1, -1)
    -- self.aniIcon:setScaleX(_dir)
    transition.execute(self.aniIcon, cc.MoveBy:create(0.5, cc.p(_posX.x*self.aniIcon:getScaleX(), self.aniIcon:getPositionY())), _args)
end 
 
-- 再每次播放动画时都会移除当前动画  
function PlotDialogView:removeSpineImg()
    --  echo("_____removeSpineImg_____")
    if self.oldPos ~= 0 then
        if self.aniIcon ~= nil then
            self.aniIcon:setPositionX(0)
        end
        self.plotCtn[self.oldPos]:removeChild(self.aniIcon)
        self.oldPos = 0
        self.aniIcon = nil
        self.oldRes = ""
    end
    for i = 1, 3 do
        self.panel_duihua["btn_duihua" .. i]:setVisible(false)
        self["panel_" .. i]:setVisible(false)
    end
end

function PlotDialogView:cleanLastAni()
    --  echo("_____cleanLastAni_____")
    if self.oldPos ~= 0 then
 --//       self.plotCtn[self.oldPos]:removeChild(self.aniIcon) --//暂时屏蔽掉,策划说不让删除以前的动画
        self.oldRes = ""
        self.aniIcon = nil
    end
    if self.oldArtPos ~= 0 then
 --       self.plotCtn[self.oldArtPos]:removeChild(self.artIcon)
    end
    if(self.otherCtn ~=nil )then
        self.plotCtn[self.otherCtn]:removeAllChildren();
        self.otherCtn=nil;
        self.aniIcon=nil;
    end
    self.oldRes = ""
    self:setNameVisible(-1)
    self.aniCtnPos = 0
    self.rich_1:setVisible(false)
    if self.plotAni and self.oldPos>0 then
       self.plotCtn[self.oldPos]:removeChild(self.plotAni);
 --       self.plotAni:clear()
    end
    self.plotAni=nil;
    self.ctn_1:setVisible(false)
end 
-- 移除当前动画
function PlotDialogView:removeCurAni()
    if self.plotAni then
        for _index=1, 3 do
                self.plotCtn[_index]:removeChild(self.plotAni);
        end
--        self.plotAni:delayCall(c_func(self.plotAni.visible, self.plotAni, false), 0.0001)
        self.plotAni = nil
    end
end 

function PlotDialogView:setNameVisible(id)
    for i = 1, 3 do
 --       local _v = _yuan3(id == i, true, false)
        self["panel_name" .. i]:setVisible(id == i)
    end
end
  
function PlotDialogView:getCtnPos(_aniID)

    if _aniID == self.ANI_RUN_ACTION.MIDDLE_TO_RIGHT or _aniID == self.ANI_RUN_ACTION.LEFT_TO_RIGHT then
        self.aniCtnPos = self.LOCATION.RIGHT
    elseif _aniID == self.ANI_RUN_ACTION.LEFT_TO_MIDDLE or _aniID == self.ANI_RUN_ACTION.RIGHT_TO_MIDDLE then
        self.aniCtnPos = self.LOCATION.MIDDLE
    elseif _aniID == self.ANI_RUN_ACTION.RIGHT_TO_LEFT or _aniID == self.ANI_RUN_ACTION.MIDDLE_TO_LEFT then
        self.aniCtnPos = self.LOCATION.LEFT
    end
    return self.plotCtn[self.aniCtnPos]
end 

function PlotDialogView:updateText(data)
    _yuan3(data.rich_1, self.panel_1.txt_1:setString(getPlotLanguage(data.rich_1)), nil)
end 




function PlotDialogView:updateUI(data,isShowText)
    if data == nil then return end

    -- board[string]	根据配置选择对话版不同的样式
    local bg = data.bg
    -- bg[string]	场景文件名，如果有，切换成对应背景，如过无，就保留当前背景，不额外加载图片
    local sfx = data.sfx
    -- sfx[string]	进场时候的音效，如果没有进场动画就不播放
    local enterAni = data.enterAni
    -- enterAni[string]	定义的动画组，依次播放【动画ID;】，动画结束后，立绘出现在对应位置
    -- 可以为空，为空就直接出现在预订位置。
    local emoji = data.emoji
    -- emoji[string]	说话时立绘上显示的表情，
    local effect = data.effect
    -- effect[string]	说话时身上的特效【特效ID】，可以为空

    local _pos = _yuan3(self.aniCtnPos ~= 0, self.aniCtnPos, data.pos[1] or  0)
    self:setNameVisible(_pos)
    self["panel_name" .. _pos]:setVisible(true)
   
    local _name = _yuan3(data.name == nil, UserModel:name(), getPlotLanguage(data.name))
    self["panel_name" .. _pos].txt_1:setString(_name)
--//表情面板
    local   _panel=self["panel_" .. _pos];
--//如果表情不为空
    self["panel_" .. _pos]:setVisible(false)

    -- self["panel_"..data.pos[1]]:addChild()
    -- text[string]	对话文本
    self.rich_1:setVisible(true)
 
    self.rich_1:setVisible( isShowText )
  
--//判断是否有需要参数替换
    local     _text=getPlotLanguage(data.text);
    if(data.param_place ~= nil)then
          local     _user_name = UserModel:name();
          for _key,_value in pairs(data.param_place) do
                local   _replace=_user_name;
                if(_value ~="player")then
                         _replace=GameConfig.getLanguage(_value);
                end
                _text  = string.gsub(_text, "#".._key, _replace)
          end
    end
    self:setRichText(_text)
    local bg2 = data.bg2
    -- bg2[string]	切换的背景图ID
    local shake = data.shake
    -- afterAni[vector<string>]	文本结束后，如果角色退场，会播放动画序列【动画I；】
    local scr = data.scr
    -- scr[string]	对话结束后执行脚本

    local glaType = data.glaType
    ------------  ------------  ------------  ------------ 
    if data.img ~= nil then 
     self:loadPlayerImg(data, false)
    end 
    ------------  ------------  ------------  ------------ 
   self.ctn_1:setVisible(true)
  
 
end 
-- 一当前动画全部结束
function PlotDialogView:plotDialogComplete(data)
    --    echo("plotDialogComplete")
    -- 清理上一场数据
    self:cleanLastAni()
    -- 添加上一次立绘
    self:showArtIcon(data, state)

end 
function PlotDialogView:showArtIcon(data)
    -- 设置立绘显示
    if data.stay == nil then return end
    if(data.board>0)then
         self.artIcon=self:loadImgRes(data.img, true,data.emoji,data.actionSource)
         self.plotCtn[data.stay[1]]:removeAllChildren();
         self.artIcon:parent(self.plotCtn[data.stay[1]])
         local _dir = data.stay[2] == 2  and 1  or  -1
         self.artIcon:setScaleX(0.9*_dir)
         self.artIcon:setScaleY(0.9);
 --       self.artIcon:setColor(cc.c3b(80, 80, 80))
         --FilterTools.setGrayFilter(self.artIcon);
         FilterTools.setFlashColor(self.artIcon, "lowLight" );
--        self.artIcon:setScale(0.9*_dir)
        self.oldArtPos = data.stay[1]
    end
end 


--[[
设置富文本内容
打印文本   startPrinter打印富文本
startPrinter(str,speed)
]]
function PlotDialogView:setRichText(str)
    if str ~= nil then 
        self.rich_1:setString(str,cc.size(40,40))
    end 
end


--[[
deleteMe() 方法 清除自身
]]
function PlotDialogView:deleteMe()
    if self.currentSound then
        echo("dangqian guanbi de yinxiao  == ",self.currentSound)
        -- AudioModel:stopSound(self.currentSound)
        audio.pauseAllSounds()
    end
    PlotDialogView.super.deleteMe(self)
    self.controler = nil
    self.animId = nil
end 

function PlotDialogView:setFanhuiBtnVisable(isShow)
    self.btn_2:setVisible(isShow)
end 


return PlotDialogView;
