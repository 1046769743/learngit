local TreasureMainView = class("TreasureMainView", UIBase)
local STARPOINT_MAX = 5
local TREASURE_STAR_MAX = 7
function TreasureMainView:ctor(winName,id)
    TreasureMainView.super.ctor(self, winName)
    if id == "4050" then
        id = nil 
    end
    self.currentSelectId = id
    if not self.currentSelectId then
        self.currentSelectId = TreasureNewModel:getSelectTreasureId()
    end

    self.scaleAnimItem = {} -- 为了方便取按钮，别做别的用
    self.fadeInanimItem = {} -- 为了方便取组件做渐入动画，不要做别的用
end

function TreasureMainView:loadUIComplete()
    -- 适配
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_topanim.panel_name, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_topanim.btn_guize, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_topanim.panel_res, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_topanim.btn_back, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_power, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_latiao, UIAlignTypes.Right)

    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_trif, UIAlignTypes.Right)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_progress, UIAlignTypes.MiddleBottom)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_btnduo, UIAlignTypes.MiddleBottom)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_shuxing, UIAlignTypes.Left)

    -- 滚动条适配
    FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_latiao.scale9_1,UIAlignTypes.Middle,0,1)
    FuncCommUI.setScrollAlign(self.widthScreenOffset,self.panel_latiao.scroll_1,UIAlignTypes.Middle,0,0.8)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_latiao.btn_1, UIAlignTypes.MiddleBottom)

    self:initData()
    self:registerEvent()
    self:initList()

    -- self:addQuestAndChat()

    self:enterTreasure(self.currentSelectId)

    --先隐藏
    self.panel_topanim.btn_guize:setTap(function ( ... )
        -- self.proAnimTou:runAction(act.moveto(0.5 , -155+ 62*3,0 ))
        WindowControler:showWindow("TreasureGuiZeView")
    end)
    -- 背景特效
    local bgAnim = self:createUIArmature("UI_fabao","UI_fabao_beijing", self.ctn_anibg, true)

    -- 加组件
    self:addFadeIn(self.panel_trif.panel_fb.panel_shipei)
    self:addFadeIn(self.panel_trif.btn_1)
    self:addFadeIn(self.panel_trif.panel_progress)
    self:addFadeIn(self.panel_trif.ctn_upstar)

    self:doEnterAni()
    -- self:shareButton()
  



end

--添加分享按钮
function TreasureMainView:shareButton()
    -- self.mc_shuxing:getViewByFrame(1).panel_jiacheng.btn_1:setTouchedFunc(c_func(self.toChatWorld, self),nil,true);
    -- local id = self.currentSelectId
    -- local data = TreasureNewModel:isHaveTreasure(id)
    -- if data then 
    --     self.mc_shuxing:getViewByFrame(1).panel_jiacheng.btn_1:setVisible(true)
    -- else
    --     self.mc_shuxing:getViewByFrame(1).panel_jiacheng.btn_1:setVisible(false)
    -- end
end


function TreasureMainView:toChatWorld()

    local isSendCD = ChatModel:sendTreasureShareToWorldCD()

    if not isSendCD then
        WindowControler:showTips(GameConfig.getLanguage("#tid_treature_share_03"))
        return 
    end
    ChatModel.worldTreasureChatCD = TimeControler:getServerTime()

    local id = self.currentSelectId
    local data =  TreasureNewModel:getTreasureData(id)
    data.avatar = UserModel:avatar()
    local function callback(event)
        if event.result then

            WindowControler:showTips(GameConfig.getLanguage("#tid_treature_share_02"))
        end
    end


    local pamses = {
        type = 1,
        content = json.encode(data),
    }

    ChatServer:sendChatWorldShare(pamses,callback)
end


-- --添加聊天和目标按钮
-- function TreasureMainView:addQuestAndChat()
--     local arrData = {
--         systemView = FuncCommon.SYSTEM_NAME.TREASURE_NEW,--系统
--         view = self,---界面
--     }
--     QuestAndChatControler:createInitUI(arrData)
-- end



function TreasureMainView:initData()
    self.targetPos = 1
    self.allTreashues = TreasureNewModel:getAllTreasure()

    if not self.currentSelectId then
        self.currentSelectId = self.allTreashues[1]
    end
    for i,v in ipairs(self.allTreashues) do
        if self.currentSelectId == v then
            self.targetPos = i
            break
        end
    end
    self.list = self.panel_latiao.scroll_1
end
function TreasureMainView:initList()
    
    self.allTreashues = TreasureNewModel:getAllTreasure()
    self.panel_latiao.mc_1:visible(false)
    local itemPanel = self.panel_latiao.mc_1
    local createItemFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(itemPanel)
        self:updateItem(view, itemData)
        return view
    end
    local updateCellFunc = function (itemData, view)
        self:updateItem(view, itemData,true)
        return view;  
    end

    local _scrollParams = {
            {
                data = self.allTreashues,
                createFunc = createItemFunc,
                updateCellFunc = updateCellFunc,
                offsetX =10,
                offsetY =8,
                itemRect = {x=0,y= -130,width=130,height = 130},
                widthGap = 2,
                heightGap = 0,

            }
        }
    self.list:styleFill(_scrollParams);
    self.list:hideDragBar()
end

function TreasureMainView:updateItem(view,data)
    view:showFrame(1)
    -- 红点
    local redShow = TreasureNewModel:isShowRedTreasure(data)
    view.currentView.panel_red:visible(redShow)
    -- 星级
    local star = 1
    view.currentView.mc_dou:showFrame(star)
    local treasuredata = TreasureNewModel:getTreasureData(data)
    local dataCfg = FuncTreasureNew.getTreasureDataById(data);
    -- 资质
    local zizhi = dataCfg.aptitude
    view.currentView.mc_pj:showFrame(zizhi)
    view.currentView.mc_pj:visible(false)
    -- 品质

    if treasuredata then
        star = treasuredata.star
    else
        star = dataCfg.initStar
    end
    -- 策划说 头像框颜色 资质对应颜色
    local frame = FuncTreasureNew.getKuangColorFrame(data)
    view.currentView.mc_2:showFrame(frame)
    view.currentView.mc_dou:showFrame(star)
    -- icon
    local iconPath = FuncRes.iconTreasureNew(data)
    local treasureIcon = display.newSprite(iconPath)
    view.currentView.mc_2.currentView.ctn_1:removeAllChildren()
    view.currentView.mc_2.currentView.ctn_1:addChild(treasureIcon)
    -- treasureIcon:setScale(0.5)
    -- 选中框
    if data == self.currentSelectId then
        view.currentView.panel_1:visible(true)
    else
        view.currentView.panel_1:visible(false)
    end
    if treasuredata == nil then
        FilterTools.setViewFilter(treasureIcon,FilterTools.colorMatrix_gray)
    else
        FilterTools.clearFilter(treasureIcon)
    end
    -- 注册点击事件
    view:setTouchedFunc(c_func(self.setSelectTreasure,self,data,view),nil,nil,nil,nil,false)
end
-- 进入法宝信息还是法宝解锁
function TreasureMainView:enterTreasure(id)
    local data = TreasureNewModel:getTreasureData(id)
    -- dump(data,"当前 法宝信息")
    if data then
        self:refreshTreasureInfo(id,true)
    else
        -- 判断 合成或者解锁
        local dataCfg = FuncTreasureNew.getTreasureDataById(id)
        if dataCfg.unlockType == 1 then
            self:unlockTreasure(id,false)
        elseif dataCfg.unlockType == 2 then
            self:combineTreasureUI(id,false)
        end

    end
    if self.mc_shuxing.currentView.panel_jiacheng.scroll_1 then
        self.mc_shuxing.currentView.panel_jiacheng.scroll_1:gotoTargetPos(self.targetPos, 1, 1)
    end
end

function TreasureMainView:refreshRedPoint()
    local id = self.currentSelectId
    for i,v in pairs(self.allTreashues) do
        id = v
        local view = self.list:getViewByData(id)    
        local redShow = TreasureNewModel:isShowRedTreasure(id)
        if view then
            view.currentView.panel_red:visible(redShow)
        end
    end
    
    

end

-- 法宝的展示刷新
function TreasureMainView:initFbPanel(id)
    local panelFb = self.panel_trif.panel_fb
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    -- 天 地 通天
    panelFb.mc_zizhi:showFrame(dataCfg.aptitude)
    panelFb.mc_zizhi:visible(false)

    FuncCommUI.regesitShowTreasureTipView(panelFb.mc_zizhi,posDes,false)
    panelFb.mc_zizhi:setTouchSwallowEnabled(true)
    -- icon 
    -- local iconPath = FuncRes.iconTreasureNew(id)
    -- local treasureIcon = display.newSprite(iconPath)
    -- panelFb.ctn_1:removeAllChildren()
    -- panelFb.ctn_1:addChild(treasureIcon) 

    if not self.lihuiId or self.lihuiId ~= id then
        self.lihuiId = id
        self.treasLihui = FuncTreasureNew.getTreasLihui(id)
        panelFb.ctn_1:removeAllChildren()
        panelFb.ctn_1:addChild(self.treasLihui)
        self.treasLihui:scale(1.2)
        panelFb.ctn_1:setPositionX(250)
    end
    if TreasureNewModel:getTreasureData(id) then
        FilterTools.clearFilter(self.treasLihui)
    else
        FilterTools.setGrayFilter(self.treasLihui )
    end
    
end 


-- 合成法宝
function TreasureMainView:combineTreasureUI(id)
    self:initFbPanel(id)
    self:refreshStar(id)
    self:refreshProgress(id)
    self:refreshBtn(id)
    self.panel_power:visible(false)
    -- self:refreshPower(id)
    self:refreshInfo(id)
    self:hideProgressEffect(false)
end
-- 解锁法宝
function TreasureMainView:unlockTreasure(id,isShow)
    self:initFbPanel(id)
    self:refreshStar(id)
    self:refreshProgress(id)
    self:refreshBtn(id)
    self.panel_power:visible(false)
    -- self:refreshPower(id)
    self:refreshInfo(id)
end
-- 刷新法宝信息-- 这是已拥有的
function TreasureMainView:refreshTreasureInfo(id)
    self:initFbPanel(id)
    self:refreshStar(id)
    self:refreshProgress(id)
    self:refreshBtn(id)
    self.panel_power:visible(true)
    self:refreshPower(id)
    self:refreshInfo(id)
    self:hideProgressEffect(true)
end

-- 刷新星级
function TreasureMainView:refreshStar(id)
    local panel_star = self.panel_trif.panel_fb.panel_shipei
    local mc_star = panel_star.mc_dou
    -- 显示最多星
    mc_star:showFrame(7)
    local data = TreasureNewModel:getTreasureData(id)
    if data then
        panel_star:visible(true)
        local star = data.star
        for i=1,7 do
            if star >= i then
                mc_star.currentView["mc_"..i]:showFrame(1)
            else
                mc_star.currentView["mc_"..i]:showFrame(2)
            end
        end
    else
        panel_star:visible(false)
    end
    
end

-- 加按钮
function TreasureMainView:addBtn(btn)
    table.insert(self.scaleAnimItem, btn)
end

-- 加渐入
function TreasureMainView:addFadeIn(item)
    table.insert(self.fadeInanimItem, item)
end

-- 刷新按钮
function TreasureMainView:refreshBtn(id)
    local data = TreasureNewModel:getTreasureData(id)
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    local curOnTreasureId = TeamFormationModel:getOnTreasureId()
    self.scaleAnimItem = {}

    if data then
        self.panel_trif.btn_1:setVisible(true)
        self.panel_trif.mc_btnduo:showFrame(1)
        -- 判断是否满级
        local maxStar = dataCfg.maxStar
        if maxStar == data.star then
            self.panel_trif.btn_1:setVisible(false)
            self.panel_trif.mc_btnduo.currentView.mc_1:showFrame(3)
            local panel = self.panel_trif.mc_btnduo.currentView.mc_1.currentView
            if curOnTreasureId == id then
                panel:setVisible(false)
            else
                panel:setVisible(true)
                panel.btn_1:setTouchedFunc(function ()
                        TeamFormationModel:updatePveTrea(id)
                    end)
                self:addBtn(panel.btn_1)
            end
        else
            -- 显示消耗
            if data.starPoint >= STARPOINT_MAX then
                -- 此时是升星状态
                self.panel_trif.mc_btnduo.currentView.mc_1:showFrame(2)
                local panel = self.panel_trif.mc_btnduo.currentView.mc_1.currentView
                panel.btn_sx:setTap(function (  )
                        -- WindowControler:showTips("此时可升星")
                        self.beforAbility = self:getAbility(id)
                        self.beforAttr = self:starPointAttr()
                        self:disabledUIClick(  )
                        TreasureNewServer:treasureUpStar(id,c_func(self.upStarCallBack,self))
                        FuncTreasureNew.playUpstarSound()
                end)
                self:addBtn(panel.btn_sx)
            else
                -- 此时是提升状态 
                if curOnTreasureId == id then
                    self.panel_trif.mc_btnduo.currentView.mc_1:showFrame(4)
                else
                    self.panel_trif.mc_btnduo.currentView.mc_1:showFrame(1)
                end
                
                local panel = self.panel_trif.mc_btnduo.currentView.mc_1.currentView
                local starCfg = FuncTreasureNew.getTreasureUpstarDataByKeyID(id, data.star)
                local needNum = starCfg.cost[data.starPoint + 1]
                local haveNum = ItemsModel:getItemNumById(id)
                panel.txt_1:setString(haveNum.."/"..needNum)
                self:addFadeIn(panel.txt_1)
                self:addFadeIn(panel.panel_wtf)
                if needNum > haveNum then
                    FilterTools.setGrayFilter(panel.btn_2)
                    panel.btn_2:setTap(function (  )
                        --碎片不足无法提升
                        WindowControler:showWindow("GetWayListView", id,needNum);
                        WindowControler:showTips(GameConfig.getLanguage("#tid_treature_new_45207"))
                    end)
                    -- 红点 
                    panel.btn_2:getUpPanel().panel_red:visible(false)
                    self:addBtn(panel.btn_2)
                else
                    FilterTools.clearFilter(panel.btn_2)
                    panel.btn_2:setTap(function (  )
                        -- WindowControler:showTips("此时可以提升")
                        self.beforAbility = self:getAbility(id)
                        self.beforAttr = self:starPointAttr()
                        self:disabledUIClick(  )
                        TreasureNewServer:treasureUpStar(id,c_func(self.upStarCallBack,self))
                        FuncTreasureNew.playUpstarpointSound()
                    end)
                    panel.btn_2:getUpPanel().panel_red:visible(true)
                    self:addBtn(panel.btn_2)
                end
                -- 万能碎片
                local starCfg = FuncTreasureNew.getTreasureUpstarDataByKeyID(id, data.star)
                local needNum = starCfg.cost[data.starPoint + 1] 
                self.panel_trif.btn_1:setTap(function (  )
                    local wnNum = ItemsModel:getItemNumById("4050")
                    local _haveNum = ItemsModel:getItemNumById(id)
                    local _needNum = needNum * (5-data.starPoint)
                    
                    if wnNum <= 0 then
                        if _needNum <= 0 then
                            _needNum = needNum
                        end
                        WindowControler:showTips(GameConfig.getLanguage("#tid_treature_tips_333"))
                        WindowControler:showWindow("GetWayListView", "4050",_needNum);
                    else
                        if _needNum <= 0 then
                            _needNum = wnNum
                        end
                        WindowControler:showWindow("TreasureWanNengSuiPianView",id,_needNum)
                    end
                end)

                if panel.btn_1 then
                    panel.btn_1:setTouchedFunc(function ()
                        TeamFormationModel:updatePveTrea(id)
                    end)
                    self:addBtn(panel.btn_1)
                end            
            end
        end
    else
        self.panel_trif.btn_1:setVisible(false)
        self.panel_trif.mc_btnduo:showFrame(2)
        local panel = self.panel_trif.mc_btnduo.currentView
        -- 判断是否可激活
        local dataCfg = FuncTreasureNew.getTreasureDataById(id)
        if dataCfg.unlockType == 1 then
            if TreasureNewModel:isCanJiesuo( id ) then
                 FilterTools.clearFilter(panel.btn_1)
                panel.btn_1:getUpPanel().panel_red:visible(true)
                panel.btn_1:setTap(function (  )

                    self.beforAbility = self:getAbility(id)
                    self.beforAttr = self:starPointAttr()
                    TreasureNewServer:combineTreasure(id,c_func(self.combineTreasureCallBack,self))
                    FuncTreasureNew.playJiHuoSound()
                end)
            else
                FilterTools.setGrayFilter(panel.btn_1)
                panel.btn_1:setTap(function (  )
                    -- 解锁条件尚未达成
                    WindowControler:showTips(GameConfig.getLanguage("#tid_treature_new_45205"))
                end)
                -- 红点 
                panel.btn_1:getUpPanel().panel_red:visible(false)
            end
            self:addBtn(panel.btn_1)
        elseif dataCfg.unlockType == 2 then
            local needNum = dataCfg.pieceNum
            local haveNum = ItemsModel:getItemNumById(id)
            if haveNum >= needNum then
                FilterTools.clearFilter(panel.btn_1)
                panel.btn_1:getUpPanel().panel_red:visible(true)
                panel.btn_1:setTap(function (  )
                    self.beforAbility = self:getAbility(id)
                    self.beforAttr = self:starPointAttr()
                    TreasureNewServer:combineTreasure(id,c_func(self.combineTreasureCallBack,self))
                    FuncTreasureNew.playJiHuoSound()
                end)
            else
                FilterTools.setGrayFilter(panel.btn_1)
                panel.btn_1:setTap(function (  )
                    -- 碎片不足 无法解锁
                    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
                    local _name = GameConfig.getLanguage(dataCfg.name)
                    WindowControler:showTips(GameConfig.getLanguageWithSwap("tid_treature_tips_222",_name))
                    WindowControler:showWindow("GetWayListView", id,needNum);
                    -- WindowControler:showTips(GameConfig.getLanguage("#tid_treature_new_45206"))
                end)
                -- 红点 
                panel.btn_1:getUpPanel().panel_red:visible(false)
            end
            self:addBtn(panel.btn_1)
        end
        local btn2 = panel.btn_2
        self:addBtn(btn2)
        btn2:setTap(function (  )
            WindowControler:showWindow("TreasureInfoNewView", id);
        end)
    end
end

-- 刷新进度条
function TreasureMainView:refreshProgress(id)
    local data = TreasureNewModel:getTreasureData(id)
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    local progressPanel = self.panel_trif.panel_progress

    -- 添加 背景条 背景特效
    
    if data then
        local starPoint = data.starPoint 
        progressPanel:visible(true)
        local progressBar = progressPanel.progress_1 
        -- 进度条显示
        if data.star == dataCfg.maxStar then
            progressPanel:visible(false)
        else
            progressPanel:visible(true)
            progressBar:setPercent(starPoint/STARPOINT_MAX*100)
            if starPoint < STARPOINT_MAX then
                local starCfg = FuncTreasureNew.getTreasureUpstarDataByKeyID(id, data.star)
                local needNum = starCfg.cost[data.starPoint + 1]
                local haveNum = ItemsModel:getItemNumById(id)
                progressPanel.txt_1:setString(haveNum .. " / " .. needNum)
            else
                progressPanel.txt_1:visible(false)
            end

            -- 进度条特效
            self:addProgressEffect( starPoint )
        end
        progressPanel.txt_1:visible(false)
        progressPanel.panel_tiaozi:visible(true)

    else
        -- 判断 合成或者解锁 
        -- 1、条件解锁;2、碎片合成
        progressPanel.txt_1:visible(true)
        progressPanel.panel_tiaozi:visible(false)
        local dataCfg = FuncTreasureNew.getTreasureDataById(id)
        if dataCfg.unlockType == 1 then
            progressPanel:visible(false)
        elseif dataCfg.unlockType == 2 then
            progressPanel:visible(true)

            local needNum = dataCfg.pieceNum
            local haveNum = ItemsModel:getItemNumById(id)
            progressPanel.txt_1:setString(haveNum .. " / " .. needNum)
            local progressBar = progressPanel.progress_1
            progressBar:setPercent(haveNum/needNum*100)
        end
    end
end
-- 添加进度条特效
function TreasureMainView:addProgressEffect( starPoint,isRun,callback ,powerCallBack)
    -- 进度条特效
    local progressPanel = self.panel_trif.panel_progress

    if not self.proAnimBg then
        self.proAnimBg= self:createUIArmature("UI_fabao","UI_fabao_nengliangchangtai",
             progressPanel.ctn_probg, true);
    end

    if not self.proAnimJd then
        self.proAnimJd = self:createUIArmature("UI_fabao","UI_fabao_nengliangjindu",
             progressPanel.ctn_progd, true);
        self.proAnimTou = self:createUIArmature("UI_fabao","UI_fabao_zoujindulizi",
             progressPanel.ctn_progd, true);
        self.proAnimMan = self:createUIArmature("UI_fabao","UI_fabao_nenglianman",
                progressPanel.ctn_progd, true);
    end

    local animJdWZ = self.proAnimJd:getBone("zhezhao")
    if not isRun then
        animJdWZ:setPositionX(-175 + 63*starPoint)
        self.proAnimTou:setPositionX(-155+ 62*starPoint)
        if starPoint == 0 or starPoint == 0 then
            self.proAnimTou:visible(false)
        else
            self.proAnimTou:visible(true)
        end
        self:hideProJianTouEffect(starPoint)
    else
        if not callBack then
            callBack = function (  )
                -- body
            end
        end
        local _time = 0.5
        self.proAnimTou:visible(true)
        self.proAnimTou:runAction(act.sinout(act.moveto(_time , -155+ 62*starPoint,0 )))
        animJdWZ:runAction(act.sinout(act.moveto(_time , -175 + 63*(starPoint),0 )))
        self:delayCall(function ( ... )
            self:hideProJianTouEffect(starPoint)
        end, _time)
        self:delayCall(function ( ... )
            callback()
            if powerCallBack then
                powerCallBack()
            end
        end, 1.0)
    end
    -- 进度条满的特效
    if starPoint == 5 then
        self.proAnimMan:visible(true)
    else
        self.proAnimMan:visible(false)
    end
end
-- 进度条特效 尽头
function TreasureMainView:hideProJianTouEffect(starPoint)
    if self.proAnimTou then
        if starPoint == 0 or starPoint == 5  then
            self.proAnimTou:visible(false)
        else
            self.proAnimTou:visible(true)
        end
    end
end
-- 是否隐藏进度条特效
function TreasureMainView:hideProgressEffect(show)
    
    if show == false then
        if self.proAnimJd then
            self.proAnimJd:visible(show)
            self.proAnimTou:visible(show)
            self.proAnimMan:visible(show)
        end
    else
        if self.proAnimJd then
            self.proAnimJd:visible(true)
        end
        
    end
end
-- 获取战力
function TreasureMainView:getAbility(id)
    local data = TreasureNewModel:getTreasureData(id)
    if not data then
        return 0
    end
    local level = UserModel:level()--math.floor((UserModel:level()-1)/3 + 1)
    local ability = FuncTreasureNew.getTreasureAbility(data,level)
    return ability
end
-- 刷新战力
function TreasureMainView:refreshPower( id )
    -- 战力
    local data = TreasureNewModel:getTreasureData(id)
    if not data then
        return 0
    end
    local level = UserModel:level()--math.floor((UserModel:level()-1)/3 + 1)
    local ability = FuncTreasureNew.getTreasureAbility(data,level)
    self.panel_power.UI_number:setPower(ability)
end
-- 刷新详情
function TreasureMainView:refreshInfo(id,isRefresh)
    local data = TreasureNewModel:getTreasureData(id)
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    local _name = GameConfig.getLanguage(dataCfg.name)
    local _type = dataCfg.type --定位 攻防辅
    local _wuling = dataCfg.wuling
    local _aptitude = dataCfg.aptitude -- 资质
    if data then
        self.mc_shuxing:showFrame(1)
        if isRefresh then
            self:refrenshOwnTreasInfo(id) 
        else
           self:ownTreasInfo(id) 
        end
        
    else
        -- 判断 合成或者解锁 
        -- 1、条件解锁;2、碎片合成
        if dataCfg.unlockType == 1 then
            self.mc_shuxing:showFrame(3)
            self:jiesuoTreasure(id)
        elseif dataCfg.unlockType == 2 then
            self.mc_shuxing:showFrame(2)
            local btn1 = self.mc_shuxing.currentView.panel_jiacheng.btn_1
            local needNum = dataCfg.pieceNum
            local haveNum = ItemsModel:getItemNumById(id)
            btn1:setTap(function (  )
                WindowControler:showWindow("GetWayListView", id,needNum);
            end)
        end

        local panel = self.mc_shuxing.currentView.panel_jiacheng
        -- name
        echo("FuncTreasureNew.getNameColorFrame(id) ==",FuncTreasureNew.getNameColorFrame(id)," == id --",id)
        panel.panel_name.mc_1:showFrame(FuncTreasureNew.getNameColorFrame(id))
        panel.panel_name.mc_1.currentView.txt_1:setString(_name)
        panel.panel_name.mc_dingwei:showFrame(_type)
        panel.panel_name.mc_tu2:showFrame(_wuling)
        panel.panel_name.btn_1:setVisible(false)
    end
end
-- 解锁条件
function TreasureMainView:jiesuoTreasure(id)
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    local conditionT = dataCfg.unlockCondition
    local conditionSort = function ( a,b )
        local _a = TreasureNewModel:isUnlock(a)
        local _b = TreasureNewModel:isUnlock(b)
        if _a == _b and _a == true then
            return false
        elseif _a == _b and _a == false then
            return false
        elseif _a == true then
            return false
        else
            return true
        end
    end
    table.sort(conditionT,conditionSort)
    local panel = self.mc_shuxing.currentView.panel_jiacheng
    local createFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(panel.btn_1)
        self:updateConditionItem(view, itemData)
        return view
    end
    panel.btn_1:visible(false)
    local updateFunc = function (itemData,_view)
        self:updateConditionItem(_view,itemData)
    end
    local _scrollParams = {
            {
                data = conditionT,
                createFunc= createFunc,
                updateFunc = updateFunc,
                perFrame = 1,
                offsetX =0,
                offsetY =5,
                itemRect = {x=0,y= -67,width=328,height = 67},
                widthGap = 0,
                heightGap = 0,
                perNums = 1,
            }
        }
    panel.scroll_1:styleFill(_scrollParams);
    panel.scroll_1:hideDragBar()
end
function TreasureMainView:updateConditionItem(view, itemData)
    local isUnLock ,str,getwayFunc = TreasureNewModel:isUnlock(itemData)
    view:getUpPanel().txt_1:setString(str)
    if isUnLock then
        -- view:setTap(function (  )
        --     WindowControler:showTips("已经解锁")
        -- end)
        view:getUpPanel().mc_suo:showFrame(2)
        view:getUpPanel().mc_1:showFrame(2)
        view:getUpPanel().panel_x:visible(false)
        view:enabled(false)
    else
        view:enabled(true)
        view:setTap(getwayFunc)
        view:getUpPanel().mc_suo:showFrame(1)
        view:getUpPanel().mc_1:showFrame(1)
        view:getUpPanel().panel_x:visible(true)
    end
end
-- 计算
-- 刷新法宝详情
function TreasureMainView:refrenshOwnTreasInfo(id)
    self:treasName(self.treasInfoView[1],id)
    self:peidaiShuXing(self.treasInfoView[2],id)
    self:yongjiuShuXing(self.treasInfoView[3],id)
    self:skillShow(self.treasInfoView[4],id)
end
-- 已拥有详情
function TreasureMainView:ownTreasInfo(id)
    local panel = self.mc_shuxing.currentView.panel_jiacheng
    local scroll_info = panel.scroll_1
    self.treasInfoView = {}
    for i=1,4 do
        panel["panel_"..i]:visible(false)
    end
    local createFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(panel["panel_"..itemData])
        self:updateTreasInfoItem(view, itemData,id)
        return view
    end
    local updateFunc = function (_item,_view)
        self:updateTreasInfoItem(_view,_item,id)
    end

    local starAttrT = FuncTreasureNew.getStarAttrMap( id )
    local data = TreasureNewModel:getTreasureData(id)
    -- 计算永久激活高
    local gao = (math.ceil(data.star/2) + 1) < 4 and (math.ceil(data.star/2) + 1) or 4
    local gao3 = 30 + 25*gao 

    local _offSetX = -23
    local _scrollParams = {
            {
                data = {1},
                createFunc= createFunc,
                updateFunc = updateFunc,
                perFrame = 1,
                offsetX =_offSetX+90,
                offsetY =0,
                itemRect = {x=0,y= -60,width=330,height = 60},
                widthGap = 0,
                heightGap = 0,
                perNums = 1,
            },
            {
                data = {2},
                createFunc= createFunc,
                updateFunc = updateFunc,
                perFrame = 1,
                offsetX =_offSetX,
                offsetY =0,
                itemRect = {x=0,y= -80,width=330,height = 80},
                widthGap = 0,
                heightGap = 0,
                perNums = 1,
            },
            {
                data = {3},
                createFunc= createFunc,
                updateFunc = updateFunc,
                perFrame = 1,
                offsetX =_offSetX,
                offsetY =20,
                itemRect = {x=0,y= -gao3,width=330,height = gao3},
                widthGap = 0,
                heightGap = 0,
                perNums = 1,
            },
            {
                data = {4},
                createFunc= createFunc,
                updateFunc = updateFunc,
                perFrame = 1,
                offsetX =_offSetX,
                offsetY =20,
                itemRect = {x=0,y= -550,width=330,height = 550},
                widthGap = 0,
                heightGap = 0,
                perNums = 1,
            }
        }
    scroll_info:styleFill(_scrollParams);
    scroll_info:hideDragBar()
end
function TreasureMainView:updateTreasInfoItem(view, itemData,id)
    if tonumber(itemData) == 1 then
        self:treasName(view,id)
    elseif tonumber(itemData) == 2 then
        self:peidaiShuXing(view,id)
    elseif tonumber(itemData) == 3 then
        self:yongjiuShuXing(view,id)
    elseif tonumber(itemData) == 4 then
        self:skillShow(view,id)
    end
    self.treasInfoView[itemData] = view
end
-- shuxin name
function TreasureMainView:treasName( view,id )
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    local _name = GameConfig.getLanguage(dataCfg.name)
    local _type = dataCfg.type --定位 攻防辅
    local _aptitude = dataCfg.aptitude -- 资质
    local panel = view
    panel.mc_1:showFrame(FuncTreasureNew.getNameColorFrame(id))
    panel.mc_1.currentView.txt_1:setString(_name)
    panel.mc_dingwei:showFrame(_type)
    panel.mc_tu2:showFrame(dataCfg.wuling)


    panel.btn_1:setTouchedFunc(c_func(self.toChatWorld, self),nil,true);

    local id = self.currentSelectId
    local data = TreasureNewModel:isHaveTreasure(id)
    if data then 
        panel.btn_1:setVisible(true)
    else
        panel.btn_1:setVisible(false)
    end

end
-- 佩戴属性
function TreasureMainView:peidaiShuXing(view,id)
    local panel = view

    local data = TreasureNewModel:getTreasureData(id)
    local key = "attribute"..data.star   
    --显示基础属性
    local sxArra = FuncTreasureNew.getTreasureDataByKeyID(id, key)
    -- dump(sxArra, "\nsxArra")
    for i,v in ipairs(sxArra) do
        if i <= 4 then
            local des = FuncTreasureNew.getAttrDesTable(v)
            panel["txt_"..i]:setString(des)
        end
    end
end
-- 永久激活属性 
function TreasureMainView:yongjiuShuXing(view,id)
    local attrData = FuncChar.getAttributeData()
    local panel = view
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    panel.txt_biaoti2:setString(GameConfig.getLanguage("#tid_treature_ui_003")..GameConfig.getLanguage(dataCfg.xianshiweizhi))
    for i=1,6 do
        panel["txt_"..i]:visible(false)
    end
    local starAttrT = FuncTreasureNew.getStarAttrMap( id )
    local data = TreasureNewModel:getTreasureData(id)

    -- dump(data,"33333333333333")
    for i=1,data.star do
        if i <= 6 then
            -- 获取星级属性加成
            local _starP = 6
            if i == data.star then
                _starP = data.starPoint
            end
            local des = FuncTreasureNew.getTreaStarAttr( id,i,_starP )
            panel["txt_"..i]:visible(true)
            -- echo("=============",des)
            panel["txt_"..i]:setString(des)
        end
    end
    local posY = -122
    if data.star < 6 then
        local attrName = GameConfig.getLanguage(attrData[tostring(starAttrT[data.star + 1].attr[1].key)].name)
        local _str1 = GameConfig.getLanguage("#tid_treature_ui_002")
        local _str2 = GameConfig.getLanguage("#tid_treature_ui_009")
        panel.rich_1:setString(attrName.._str1..(data.star + 1).._str2)
        local gao = (math.ceil(data.star/2) + 1) < 4 and (math.ceil(data.star/2) + 1) or 4
        panel.rich_1:setPositionY(posY + 31*(4-gao))
        panel.btn_eye:setPositionY(posY + 28*(4-gao))

        panel.rich_1:visible(true)
        panel.btn_eye:visible(true)
    else
        panel.rich_1:visible(false)
        panel.btn_eye:visible(false)
    end
    if data.star < 3 then
        panel.scale9_2:setScaleY(0.5)
        panel.panel_starxian2:visible(false)
        panel.panel_starxian3:visible(false)
    elseif data.star < 5 then
        panel.scale9_2:setScaleY(0.8)
        panel.panel_starxian2:visible(true)
        panel.panel_starxian3:visible(false)
    else
        panel.scale9_2:setScaleY(1.05)
        panel.panel_starxian2:visible(true)
        panel.panel_starxian3:visible(true)
    end

    panel.btn_eye:scale(0.85)
    panel.btn_eye:setTap(function (  )
        WindowControler:showWindow("TreasureStarAttrView",id)
    end)
end
-- 技能
function TreasureMainView:skillShow(view,id)
    self.view3 = view
    local avatar = UserModel:avatar()
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    local data = TreasureNewModel:getTreasureData(id)
    local skills = FuncTreasureNew.getTeasureSkillsByIdAndAvatar(id,avatar)
    local starSkillT = FuncTreasureNew.getStarSkillMap(id,avatar)

    for i,v in pairs(starSkillT) do
        local skillPanel = view["panel_"..v.star]
        local skillData = FuncTreasureNew.getTreasureSkillDataDataById(v.skill)
        local iconPath = FuncRes.iconSkill(skillData.icon)
        local skillIcon = display.newSprite(iconPath)
        if skillData.priority == 1 then
            skillIcon:setScale(0.75)
        end
        skillPanel.ctn_1:removeAllChildren()
        skillPanel.ctn_1:addChild(skillIcon)
        skillPanel.panel_number.txt_1:setString(UserModel:level())
        skillPanel.txt_1:setString(GameConfig.getLanguage(skillData.name))
        if data.star >= v.star then
            -- 技能解锁
            skillPanel.panel_suo:visible(false)
            FilterTools.clearFilter(skillIcon)
        else
            skillPanel.panel_suo:visible(false)
            FilterTools.setGrayFilter(skillIcon)
        end
        skillPanel.mc_nu:showFrame(skillData.jiaobiao)

        FuncCommUI.regesitShowTreasureSkillTipView(skillIcon,
            {treasureId = id,skillId = v.skill,index = i,data = data})
    end

    --添加 全部装备觉醒+4星法宝的觉醒技能
    local awakeSkillId = FuncTreasureNew.getTreasureAwakeSkillId(id,avatar)
    local _skillPanel = view["panel_7"]
    local _skillData = FuncTreasureNew.getTreasureSkillDataDataById(awakeSkillId)
    local _iconPath = FuncRes.iconSkill(_skillData.icon)
    local skillIcon = display.newSprite(_iconPath)
    if _skillData.priority == 1 then
        skillIcon:setScale(0.75)
    end
    _skillPanel.ctn_1:removeAllChildren()
    _skillPanel.ctn_1:addChild(skillIcon)
    _skillPanel.panel_number.txt_1:setString(UserModel:level())
    _skillPanel.txt_1:setString(GameConfig.getLanguage(_skillData.name))

    -- 判断是否解锁
    local charData = CharModel:getCharData()
    local equipAwake, awakeSkillData = FuncPartner.checkPartnerEquipSkill(charData,data.star,id)
    if equipAwake then
        -- 技能解锁
        _skillPanel.panel_suo:visible(false)
        FilterTools.clearFilter(skillIcon)
    else
        _skillPanel.panel_suo:visible(false)
        FilterTools.setGrayFilter(skillIcon)
    end
    _skillPanel.mc_nu:showFrame(_skillData.jiaobiao)

    FuncCommUI.regesitShowTreasureSkillTipView(skillIcon,
        {treasureId = id,skillId = awakeSkillId,index = 8,data = data})
end


-- 处理选中框
function TreasureMainView:setSelectTreasure(id,view)
    if id == self.currentSelectId then
        return 
    end
    -- 选中框处理
    local lastView = self.list:getViewByData(self.currentSelectId)
    if lastView then
        lastView.currentView.panel_1:visible(false)
    end
    view.currentView.panel_1:visible(true)
    self.currentSelectId = id
    TreasureNewModel:setSelectTreasureId(self.currentSelectId)
    self:enterTreasure(self.currentSelectId)
    --添加刷新分享按钮
    -- self:shareButton()
end

function TreasureMainView:registerEvent()
    TreasureMainView.super.registerEvent();
    
    EventControler:addEventListener(TreasureNewEvent.COMBINE_SUCCESS_EVENT,self.combineTreasureCallBack,self)
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE,self.refreshRedPoint,self)
     --金币增加
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE,self.itemsChange,self)

    self.panel_topanim.btn_back:setTap(c_func(self.onBtnBackTap,self))
    -- 伙伴刷新
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE,self.shuaxinFaBaoUIByCondition,self)
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE,self.shuaxinFaBaoUIByCondition,self)
    EventControler:addEventListener(UserEvent.USEREVENT_ACHIEVMENT_POINT_CHANGE,self.shuaxinFaBaoUIByCondition,self)
    EventControler:addEventListener(TreasureNewEvent.DRESS_TREASURE_SUCCESS, self.shuaxinFaBaoUI, self)
    
    -- 进度条中 去获得按钮
    self.panel_trif.panel_progress.btn_1:setTap(c_func(self.showGetWayList,self))
    
end
-- 
function TreasureMainView:itemsChange()
    echo("道具发生变化了-------------")
    local id = self.currentSelectId
    local data = TreasureNewModel:getTreasureData(id)
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    -- dump(dataCfg,"222222222222222")
    local progressPanel = self.panel_trif.panel_progress

    if data then
        local progressBar = progressPanel.progress_1
        -- 进度条显示
        if data.starPoint < STARPOINT_MAX and data.star < TREASURE_STAR_MAX then
            local starCfg = FuncTreasureNew.getTreasureUpstarDataByKeyID(id, data.star)
            local needNum = starCfg.cost[data.starPoint + 1]
            local haveNum = ItemsModel:getItemNumById(id)
            progressPanel.txt_1:setString(haveNum .. "/" .. needNum)
            progressPanel.txt_1:visible(true)
        else
            progressPanel.txt_1:visible(false)
        end
    else
        -- 判断 合成或者解锁 
        -- 1、条件解锁;2、碎片合成
        local dataCfg = FuncTreasureNew.getTreasureDataById(id)
        if dataCfg.unlockType == 1 then
            progressPanel:visible(false)
        elseif dataCfg.unlockType == 2 then
            progressPanel:visible(true)
            local needNum = dataCfg.pieceNum
            local haveNum = ItemsModel:getItemNumById(id)
            progressPanel.txt_1:setString(haveNum .. "/" .. needNum)
            local progressBar = progressPanel.progress_1
            progressBar:setPercent(haveNum/needNum*100)
        end
    end
    progressPanel.txt_1:visible(false)
    self:refreshBtn(id)
end
-- 解锁条件刷新
function TreasureMainView:shuaxinFaBaoUIByCondition()
    local id = self.currentSelectId
    local data = TreasureNewModel:getTreasureData(id)
    if data then
        
    else
        -- 判断 合成或者解锁
        local dataCfg = FuncTreasureNew.getTreasureDataById(id)
        if dataCfg.unlockType == 1 then
            self:delayCall(c_func(self.shuaxinFaBaoUI,self), 0.5)  
        end

    end
end
-- 法宝信息变化刷新
function TreasureMainView:shuaxinFaBaoUI()
    self:initList() 
    self:refreshItem()
    self:refreshTreasureInfo(self.currentSelectId, true)
    if self.easeMoveScroll then
        local index = 1
        for i,v in ipairs(self.allTreashues) do
            if v == self.currentSelectId then
                index = i
                break
            end
        end
        self.list:gotoTargetPos(index, 1, 1)
    end
    self.easeMoveScroll = false
end
-- 播放升星动画
function TreasureMainView:upStarAnimEffect(star,callback,powerCallBack)
    local ctnUpstar = self.panel_trif.ctn_upstar --ctn_starAnim
    -- local upStarAnim = self:createUIArmature("UI_fabao_shengxingguiji","UI_fabao_shengxingguiji_erxing",
    --          ctnUpstar, true);
    -- 进度条的升星特效
    local progressPanel = self.panel_trif.panel_progress
    local upStarProAnim = self:createUIArmature("UI_fabao","UI_fabao_nengliangtiao",
              ctnUpstar, false);
    upStarProAnim:setPositionX(-10)

    local getAnimName = function (  )
        local animName = "UI_fabao_shengxingguiji_erxing"
        if star == 2 then
            animName = "UI_fabao_shengxingguiji_erxing"
        elseif star == 3 then
            animName = "UI_fabao_shengxingguiji_sanxing"
        elseif star == 4 then
            animName = "UI_fabao_shengxingguiji_sixing"
        elseif star == 5 then
            animName = "UI_fabao_shengxingguiji_wuxing"
        elseif star == 6 then
            animName = "UI_fabao_shengxingguiji_liuxing"
        elseif star == 7 then
            animName = "UI_fabao_shengxingguiji_qixing"
        end
        return animName
    end
    local starCallBack = function ( ... )
        local panel_star = self.panel_trif.panel_fb.panel_shipei
        local mc_star = panel_star.mc_dou
        local upStarAnim1 = self:createUIArmature("UI_fabao","UI_fabao_01",
            mc_star, true);
        upStarAnim1:setPositionY((star-1)*(-30) - 14)
        upStarAnim1:setPositionX(15.5)
        upStarAnim1:doByLastFrame(true,true)
        self:delayCall(function (  )
            local _itemView = self.list:getViewByData(self.currentSelectId)
            if _itemView then
                self:updateItem(_itemView,self.currentSelectId)
            end
            
            callback()
        end, 2.1)
        self:delayCall(function (  )
            self:addTiShengEffect()
        end, 1.2)
        self:delayCall(function (  )
            WindowControler:showWindow("TreasureUpStarShowView", self.currentSelectId,powerCallBack);
            self:ownTreasInfo(self.currentSelectId)
        end, 2.2)
        
    end
    self:delayCall(function ( ... )
        local upStarAnim = self:createUIArmature("UI_fabao_shengxingguiji",getAnimName(),
            ctnUpstar, true);
        upStarAnim:doByLastFrame(true,true,starCallBack)
    end, 0.5) 

end
-- 法宝升星回调
function TreasureMainView:upStarCallBack(param)
    local id = self.currentSelectId
    if param.result then

        local data = TreasureNewModel:getTreasureData(id) 
        local callback = function (  )
            -- self:showAttrAndAbility()
            self:refreshStar(id)
            self:refreshProgress(id)
            self:refreshBtn(id)
            self:refreshPower(id)
            self:refreshInfo(id,true)
            self:resumeUIClick(  )
        end
        -- local powerCallBack = function (  )
        --     self:showAttrAndAbility()
        -- end
        if data.starPoint == 0 then
            -- 此时是升星状态
            self:upStarAnimEffect(data.star,callback,function()
                -- self:showAttrAndAbility()
                self:showTiShengAnim(true)
            end)
            -- WindowControler:showWindow("TreasureUpStarShowView", id);
        else
            self:addProgressEffect( data.starPoint,true,callback ,function()
                self:showTiShengAnim()
            end)
            self:addTiShengEffect()
        end
    else
        self:resumeUIClick(  )
    end

end
-- 刷新选中框
function TreasureMainView:refreshItem()
    local lastView = self.list:getViewByData(self.currentSelectId)
    if lastView then
        self:updateItem(lastView, self.currentSelectId)
    end
end
-- 合成 或 解锁
function TreasureMainView:combineTreasureCallBack(params)
    if params.result then
        echo("解锁 成功")
        self:addNewTreasureEffect(function()
            self.easeMoveScroll = true
            self:shuaxinFaBaoUI()
            -- self:showAttrAndAbility()
            -- 先弹界面关了之后弹属性和战力等
            WindowControler:showWindow("TreasureJihuoView", {
                treasureId = TreasureNewModel:getTreasureData(self.currentSelectId).id,
                callBack = function()
                    self:showTiShengAnim(true)
                end
            })
        end)
    else

    end
end
-- 添加提升特效
function TreasureMainView:addTiShengEffect()
    local ctn = self.panel_trif.panel_fb.ctn_a1
    local newTreaAnim = self:createUIArmature("UI_fabao_tishengjihuo","UI_fabao_tishengjihuo_tisheng",
              ctn, true);
    newTreaAnim:setPositionY(-130)
    newTreaAnim:setPositionX(20)
    newTreaAnim:doByLastFrame(true,true)
end
-- 添加解锁特效
function TreasureMainView:addNewTreasureEffect(callBack)
    -- 屏蔽点击
    self:disabledUIClick()

    local ctn = self.panel_trif.panel_fb.ctn_a1
    local newTreaAnim = self:createUIArmature("UI_fabao_tishengjihuo","UI_fabao_tishengjihuo_shangsheng",
              ctn, true);
    newTreaAnim:setPositionY(140)
    newTreaAnim:setPositionX(70)
    newTreaAnim:doByLastFrame(true,true,function()
        if callBack then callBack() end
        self:resumeUIClick()
    end)
end
-- 去获得
function TreasureMainView:showGetWayList()
    WindowControler:showWindow("GetWayListView", self.currentSelectId,1);
end
--返回 
function TreasureMainView:onBtnBackTap()
    -- WindowControler:showWindow("TreasureUpStarShowView", self.currentSelectId);
    self:startHide()
end

-- 获得当前法宝属性
function TreasureMainView:getFabaoAttr()
    if conditions then
        --todo
    end
end
-- 播放战力变化和属性效果
function TreasureMainView:showAttrAndAbility(  )
    -- 添加战力变化
    local afterAbility = self:getAbility(self.currentSelectId)
    FuncCommUI.showPowerChangeArmature(self.beforAbility, afterAbility );
    -- 属性变化
    local beforAttr = self.beforAttr

    local treasureData = TreasureNewModel:getTreasureData(self.currentSelectId)
    local addAttr = FuncTreasureNew.getUpStarAddAttr(treasureData.id,treasureData.star,treasureData.starPoint)
    
    --local addAttr = FuncPartner.getPartnerAddAttr(beforAttr,afterAttr)
    dump(addAttr,"addAttr-----------",3)
    local panel = self.mc_shuxing.currentView.panel_jiacheng
    local txt = nil
    if panel.panel_name then
        txt = panel.panel_name.mc_1.currentView.txt_1
    else
        txt = panel.panel_1.mc_1.currentView.txt_1
    end
     
    FuncTreasureNew.showAttrEffect(txt,self.panel_trif.panel_fb.ctn_attr,addAttr,0,0)
end
-- 播放策划需求的提升
function TreasureMainView:showTiShengAnim(noAnim)
    -- 添加战力变化
    local afterAbility = self:getAbility(self.currentSelectId)
    -- FuncCommUI.showPowerChangeArmature(self.beforAbility, afterAbility );

    -- 属性变化
    local beforAttr = self.beforAttr
    local treasureData = TreasureNewModel:getTreasureData(self.currentSelectId)
    local addAttr = FuncTreasureNew.getUpStarAddAttr(treasureData.id,treasureData.star,treasureData.starPoint)

    -- 转换一下
    addAttr = FuncBattleBase.formatAttribute( addAttr )
    -- 标题
    local dataCfg = FuncTreasureNew.getTreasureDataById(treasureData.id)
    -- 标题
    local title = GameConfig.getLanguage(dataCfg.xianshiweizhi)
    -- 拼接文本
    local des = title .. ": "
    local text = {}
    for i=1,#addAttr do
        local info = addAttr[i]
        -- 还得根据model转换一下value
        local value = info.value
        if info.mode == 2 or info.mode == 4 then
            value = info.value / 100
            value = string.format("%0.1f",value) .. "%"
        end
        table.insert(text, des .. info.name .. "+" .. value)
    end
    self.panel_trif.panel_fb.ctn_attr:removeAllChildren()
    -- 调用效果
    FuncCommUI.playNumberRunaction(self.panel_trif.panel_fb.ctn_attr, {
        text = text,
        callBack = function()
            -- 战力
            FuncCommUI.showPowerChangeArmature(self.beforAbility, afterAbility )
        end,
        isEffectType = three(noAnim,nil,FuncCommUI.EFFEC_TTITLE.ADVANCED),
    })
end
-- 星级变化带来的属性增长
function TreasureMainView:starPointAttr()
    local treasureData = TreasureNewModel:getTreasureData(self.currentSelectId)
    if not treasureData then
        return {}
    end
    local afterAttr = FuncTreasureNew.getTreasureAttr( treasureData )
    
    return afterAttr
end

-- 做入场动画
function TreasureMainView:doEnterAni()
    if self._hasDoEnterAni then return end
    self._hasDoEnterAni = true
    -- 先移动动画
    -- 顶部动画
    FuncUITool.doMoveAndBounce(self.panel_topanim, 0, cc.p(0,69), 0.2, cc.p(0,10), 0.2)
    -- 左侧
    FuncUITool.doMoveAndBounce(self.mc_shuxing, 0.1, cc.p(-411, 0), 0.2, cc.p(-10, 0), 0.2)
    -- 右侧
    FuncUITool.doMoveAndBounce(self.panel_latiao, 0, cc.p(144, 0), 0.2, cc.p(10, 0), 0.2)    

    -- 按钮 再弹按钮
    -- FuncUITool.doScaleAndBounce(view, delay, time)
    for i,btn in ipairs(self.scaleAnimItem) do
        FuncUITool.doScaleAndBounce(btn, 0.2, 1.2, 0.3, 0.1)
    end

    -- 渐入内容 最后一起渐入
    for i,view in ipairs(self.fadeInanimItem) do
        FuncUITool.doFadeIn(view, 0.5, 0.2)
    end
end

return TreasureMainView
