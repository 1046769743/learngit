local BattleWin = class("BattleWin", UIBase);
--local uiUrl = "uipng/"
-- BattleWin.tempResult = 
-- {
--     result=1, 
--     addExp = 10, 
--     preExp = 30, 
--     preLv = 35, 
--     lv = 36,
--     star =1, 
--     reward = {
--         [1]="1,4011,301" ,
--         [2]="1,4012,300", 
--         [3]="1,4013,300", 
--         [4]="2,300,301" ,
--         [5]="3,4201,301", 
--     },
--     heros = {
--             [5001]  = {
--                 hid = 5001,
--                 addExp = 200,
--                 preExp = 30,
--                 preLv = 3,
--                 lv = 4,
--             },
--             [5002]  = {
--                 hid = "5002",
--                 addExp = 200,
--                 preExp = 30,
--                 preLv = 3,
--                 lv = 4
--             },
--             [5003]  = {
--                 hid = "5003",
--                 addExp = 200,
--                 preExp = 30,
--                 preLv = 3,
--                 lv = 4
--             },
--             [5004]  = {
--                 hid = "5004",
--                 addExp = 200,
--                 preExp = 30,
--                 preLv = 3,
--                 lv = 4
--             },
--             [5005]  = {
--                 hid = "5005",
--                 addExp = 200,
--                 preExp = 30,
--                 preLv = 3,
--                 lv = 4
--             }
--         }, 
-- }

function BattleWin:ctor(winName,params)
    BattleWin.super.ctor(self, winName);

    -- echo("胜利界面-------------------")
    -- dump(params)
    -- echo("胜利界面-------------------")
    --echoError("xxxxxxxxxxxxxxxxx")
    self.isUpgrade = false
    --战斗结果的数据
    self.battleDatas = params
    
    self.result = self.battleDatas

    if not self.result.addExp then
        echoWarn("给的经验为空了,关卡id:",BattleControler._battleInfo.levelId)
        self.result.addExp = 0
    end

    -- echo("结算的战斗数据")
    -- dump(self.result)
    -- echo("结算的战斗数据")
    --echoError("===================")
    if BattleControler:checkIsPVP() then
        self.isPVP = true
    elseif BattleControler:checkIsTrail() ~= Fight.not_trail then
    else
        --普通pve战斗
        self.isWin = self.result.result == 1
 
        if not LoginControler:isLogin() then
            self.isLvUp = false
        else
            --self.isLvUp = params.preLv < UserModel:level()
            self.isLvUp = UserModel:isLvlUp()
        end
    end

end

function BattleWin:loadUIComplete()
    self:registerEvent()
    --这个地方需要优化  todo dev
    if not self.isPVP then
        AudioModel:playMusic(MusicConfig.s_battle_win, false)
    else
        AudioModel:playMusic(MusicConfig.s_pvp_win, false)    
    end
    -- self.panel_xy:visible(false)
    -- 注册点击任意地方事件
    --0.5秒后才可以点击胜利界面关闭
    local tempFunc = function (  )
        self:registClickClose(nil, c_func(self.pressClose, self))
    end
    self:delayCall(tempFunc, 0.5)

    self.panel_public:visible(false)


    self.isUpgrade = false

    -- 共享副本排名
    self.panel_xy:visible(false)

    self.mc_huobannum:visible(false)
    
    self.btn_1:setTap(c_func(self.doRankClick,self))
    self.btn_2:setTap(c_func(self.doReplayClick,self))

    FuncCommUI.setScale9Align(self.widthScreenOffset, self.btn_1,UIAlignTypes.RightTop ) -- tongji
    FuncCommUI.setScale9Align(self.widthScreenOffset, self.btn_2,UIAlignTypes.RightTop )--huifang

    self.btn_1:visible(false)--统计
    self.btn_2:visible(false)--回放
    -- if BattleControler:getBattleLabel() ~= GameVars.battleLabels.shareBossPve
    -- or BattleControler:getBattleLabel() ~= GameVars.battleLabels.crossPeakPvp
    --  then
    --     BattleControler.gameControler:doBattleEndCampDie(2)
    -- end

    -- echo("selff-----",self.result.battleLabels)

    if self.result.battleLabels == GameVars.battleLabels.pvp then
        if LoginControler:isLogin() then
            self:loadPVP()
        end
    -- elseif BattleControler:checkIsTrail() ~= Fight.not_trail then
    --     self:loadTrails()
    elseif BattleControler:checkIsCrossPeak() then
        self:loadCrossPeak()
    else
        self:loadAni()
    end

    self.txt_bs:visible(false)
    self.rich_bs2:visible(false)
    self.txt_s:visible(false)
    self.rich_s2:visible(false)
    self.panel_jixu:visible(false)
    self.rich_x1:visible(false)

end    


-- 退出战斗
function BattleWin:pressClose()
    if self.isUpgrade then
        
    end
   self:showOther()
   self:delayCall(function( )
       self:startHide()
   end, 0.5)

    --如果登录了。不是pvp 并且不是剧情  这个字原来的流程
    -- if LoginControler:isLogin() and (not self.isPVP) and (not BattleControler._battleInfo.withStory) then
    --     WindowControler:showBattleWindow("BattleReward",self.battleDatas)
    --     -- return
    -- end
    -- self:startHide()


end


function BattleWin:registerEvent()

end
-- 加载立绘资源
function BattleWin:loadArt( lihuiAni)
    local charView 
    if BattleControler:checkIsTrail() ~= Fight.not_trail then
        charView = self:getTrialArt()
    elseif BattleControler:checkIsCrossPeak() then
        charView = self:getCrossPeakHeroArt()
    elseif BattleControler:getBattleLabel() == GameVars.battleLabels.biographyPve then
        -- 奇侠传记获取的另外的立绘
        charView = self:getBiographyArt()
    else
        charView = self:getMaxDamageHeroArt()
    end
    FuncArmature.changeBoneDisplay(lihuiAni,"layer1",charView)
end
-- 加载挖的一个洞[用于显示立绘的]
function BattleWin:loadDongArt( dongAni,nameStr,pos)
    local cmSp =  display.newSprite(FuncRes.iconOther("global_img_jsza.png"))
    if pos and pos.x and pos.y then
        cmSp:pos(pos.x,pos.y)
    else
        cmSp:pos(95,-23)
    end
    FuncArmature.changeBoneDisplay(dongAni,nameStr,cmSp)
end

-- 巅峰竞技场界面
function BattleWin:loadCrossPeak( )
    -- dump(self.battleDatas,"self.battleDatas====")
    -- self:loadTrails()
    self.cpAnim = self:createUIArmature("UI_zhandoujiesuan","UI_zhandoujiesuan_jingjichangjiesuan",self.ctn_big,false,GameVars.emptyFunc):pos(0,0)
    self.cpAnim:pos(500,-300)
    self.cpAnim:playWithIndex(0, false)

    
    --让所有子动画都只播放一次
    self.cpAnim:setAllChildAniPlayOnce()

    
    self.cpAnim:getBone("layer4"):visible(false)


    self:delayCall(c_func(self.loadDongArt,self,self.cpAnim,"node10",cc.p(65,-23)), 0.2)

    -- 加载立绘
    local lihuiAni = self.cpAnim:getBoneDisplay("layer10")
    self:delayCall(c_func(self.loadArt,self,lihuiAni,charView), 0.4)


    local view = WindowsTools:createWindow("BattleCrossPeakResult",self.battleDatas):addto(self)
    
    self.panel_jixu:pos(-230*GameVars.width/1400,-70*GameVars.height/768)
    local txtAni = self.cpAnim:getBoneDisplay("layer5")
    FuncArmature.changeBoneDisplay(txtAni,"layer1",self.panel_jixu)   
    
    self.panel_jixu:visible(true)
end
--[[
竞技场界面的加载
]]
function BattleWin:loadPVP()
    if TutorialManager.getInstance():isInTutorial() then
        self.btn_1:visible(false)
        self.btn_2:visible(false)
    else
        self.btn_1:visible(true)
        self.btn_2:visible(true)
    end
    
    self.pvpwinAni = self:createUIArmature("UI_zhandoujiesuan","UI_zhandoujiesuan_jingjichangjiesuan",self.ctn_big,false,GameVars.emptyFunc)
    self.pvpwinAni:setAllChildAniPlayOnce()
    self.pvpwinAni:pos(500,-300)


    self:delayCall(c_func(self.loadDongArt,self,self.pvpwinAni,"node10",cc.p(65,-23)), 0.2)
    -- 加载立绘
    local lihuiAni = self.pvpwinAni:getBoneDisplay("layer10")
    self:delayCall(c_func(self.loadArt,self,lihuiAni,charView), 0.4)
   
    -- self.pvpwinAni:getBone("layer4"):visible(false)

    if self.result.historyRank <= self.result.userRank then
        self.pvpwinAni:getBone("layer4"):visible(false)
    else
        local bone = self.pvpwinAni:getBoneDisplay("layer4")
        local pmtsNd = UIBaseDef:cloneOneView(self.panel_xy.panel_pmwz) --排名提升
        if self.result.lastHistoryTopRank <= self.result.userRank then
            pmtsNd.panel_lishi:visible(false)
        end
        pmtsNd:pos(0,0)
        FuncArmature.changeBoneDisplay(bone,"layer1",pmtsNd)
        local pmNode = UIBaseDef:cloneOneView(self.panel_xy.panel_pm) --排名文字
        pmNode:pos(0,-20)
        pmNode.txt_1:setString(self.result.historyRank)
        pmNode.txt_2:setString(self.result.userRank)
        FuncArmature.changeBoneDisplay(bone,"layer2",pmNode)

        local reward = self.result.reward
        local num = 0
        if reward and #reward > 0 then
            local reward_table = string.split(reward[1], ",")
            num = tonumber(reward_table[2])
        end
        if num > 0 then
            local pmjlNode = UIBaseDef:cloneOneView(self.panel_xy.panel_pvp) --排名奖励
            pmjlNode:pos(50,0)
            pmjlNode.txt_4:setString(num)
            FuncArmature.changeBoneDisplay(bone,"layer3",pmjlNode)
        end
    end

    self.panel_jixu:pos(-230*GameVars.width/1400,-70*GameVars.height/768)
    local txtAni = self.pvpwinAni:getBoneDisplay("layer5")
    FuncArmature.changeBoneDisplay(txtAni,"layer1",self.panel_jixu)   
    
    self.panel_jixu:visible(true)
    self.pvpwinAni:playWithIndex(0, false)


    -- if self.result.historyRank <= self.result.userRank then
    --     -- 没有突破最高排名了
    --     -- self.pvpwinAni:getBone("layer8"):visible(false)
    --     local urank = UIBaseDef:cloneOneView(self.panel_public.txt_paiming)
    --     urank:visible(true)
    --     urank:pos(-40,24)
    --     urank:setString(self.result.userRank)
    --     self.pvpwinAni:getBoneDisplay("layer8"):getBone("lishizuigao"):setVisible(false)
    --     self.pvpwinAni:getBoneDisplay("layer8"):getBoneDisplay("layer2"):getBone("layer1"):visible(false)
    --     self.pvpwinAni:getBoneDisplay("layer8"):getBoneDisplay("layer3"):getBone("node2"):visible(false)
    --     self.pvpwinAni:getBoneDisplay("layer8"):getBoneDisplay("layer3"):getBone("node2"):visible(false)
    --     FuncArmature.changeBoneDisplay(self.pvpwinAni:getBoneDisplay("layer8"):getBoneDisplay("layer3"),"node1",urank)
    --     urank:setScale(1.5)
    --     urank:pos(20,28)
    --     local textRank =  UIBaseDef:cloneOneView(self.panel_xy.txt_2)
    --     textRank:setPositionX(45)
    --     textRank:setPositionY(5)
    --     FuncArmature.changeBoneDisplay(self.pvpwinAni:getBoneDisplay("layer8"):getBoneDisplay("layer3"),"layer4",textRank)
    --     self.pvpwinAni:getBoneDisplay("layer8"):getBoneDisplay("layer3"):getBone("layer3"):visible(false)
    -- else
    --     --突破历史最高排名
    --     if self.result.lastHistoryTopRank <= self.result.userRank then
    --         self.pvpwinAni:getBoneDisplay("layer8"):getBone("lishizuigao"):setVisible(false)
    --         self.panel_xy.panel_pvp:visible(false)
    --         self.pvpwinAni:getBoneDisplay("layer8"):getBone("layer2"):visible(false)
    --     else
    --         -- local sendText =  UIBaseDef:cloneOneView(self.panel_xy.txt_3)
    --         -- -- 新需求  不显示通过邮件发放奖励描述
    --         -- sendText:setString(" ")
    --         local reward = self.result.reward
    --         local num = 0
    --         if reward and #reward > 0 then
    --             local reward_table = string.split(reward[1], ",")
    --             num = reward_table[2]
    --         end
    --         local sendText =  UIBaseDef:cloneOneView(self.panel_xy.panel_pvp)
    --         if tonumber(num) > 0 then
    --             sendText.txt_4:setString(tostring(num))
    --             -- self.pvpwinAni:getBoneDisplay("layer8"):getBoneDisplay("layer2"):visible(false)
    --             FuncArmature.changeBoneDisplay(self.pvpwinAni:getBoneDisplay("layer8"):getBoneDisplay("layer2"),"layer1",sendText)
    --             sendText:pos(-10,-30)
    --             sendText:setScale(0.6)
    --         else
    --             self.panel_xy.panel_pvp:visible(false)
    --             self.pvpwinAni:getBoneDisplay("layer8"):getBone("layer2"):visible(false)
    --         end              
    --     end
    --     -- self.pvpwinAni:getBone("node1"):visible(false)
    --     local urank = UIBaseDef:cloneOneView(self.panel_public.txt_paiming)
    --     urank:visible(true)
    --     urank:pos(-70,28)
    --     urank:setString(self.result.userRank)
    --     FuncArmature.changeBoneDisplay(self.pvpwinAni:getBoneDisplay("layer8"):getBoneDisplay("layer3"),"node1",urank)
    --     urank:setScale(1.5)
    --     local hisrank = UIBaseDef:cloneOneView(self.panel_public.txt_shangsheng)
    --     hisrank:setAnchorPoint(cc.p(0,0.5))
    --     hisrank:setAlignment(cc.TEXT_ALIGNMENT_LEFT)
    --     hisrank:visible(true)
    --     hisrank:pos(-85,37)
    --     -- hisrank:setColor(cc.c3b(0,255,0))
    --     hisrank:setString(self.result.historyRank - self.result.userRank)
    --     FuncArmature.changeBoneDisplay(self.pvpwinAni:getBoneDisplay("layer8"):getBoneDisplay("layer3"),"node2",hisrank)
    --     hisrank:setScale(2.2)
    --     self.pvpwinAni:getBoneDisplay("layer8"):getBoneDisplay("layer3"):getBone("layer3"):setPositionY(-6)

    --     local textRank =  UIBaseDef:cloneOneView(self.panel_xy.txt_1)
    --     textRank:setPositionY(5)
    --     FuncArmature.changeBoneDisplay(self.pvpwinAni:getBoneDisplay("layer8"):getBoneDisplay("layer3"),"layer4",textRank)

    -- end

    -- self.panel_jixu:pos(-230*GameVars.width/1400,-70*GameVars.height/768)
    -- local txtAni = self.pvpwinAni:getBoneDisplay("layer5")
    -- FuncArmature.changeBoneDisplay(txtAni,"layer1",self.panel_jixu)   
    
    -- self.panel_jixu:visible(true)
    -- self.pvpwinAni:playWithIndex(0, false)

end


--[[
打开排名列表
]]
function BattleWin:doRankClick(  )
    local data = BattleControler.gameControler:getBattleAnalyze()
    --构建战斗数据
    WindowControler:showBattleWindow("BattleAnalyze",data)

end

--[[
重新播放
]]
function BattleWin:doReplayClick()
    self:startHide()
    BattleControler:replayLastGame(BattleControler._battleInfo,true)
end

-- 锁妖塔额外处理
function BattleWin:loadTowerExt(  )
    self.winAni:getBone("layer3"):visible(false)
    local cStar = self.result.currStar
    -- 锁妖塔如果有获得葫芦、则把星级改为获得葫芦数，没有则隐藏葫芦、隐藏话
    if cStar and cStar > 0 and cStar <= 3 then
        self.winAni:getBone("node1"):visible(true)
        local epNode = UIBaseDef:cloneOneView(self.rich_x1)
        epNode:visible(true)
        epNode:pos(-200,0)
        local nanduStr = GameConfig.getLanguage("#tid_tower_ui_"..(124+cStar))
        epNode:setString(GameConfig.getLanguageWithSwap("#tid_tower_ui_098",cStar,nanduStr))
        local epAni = self.winAni:getBoneDisplay("node1")
        FuncArmature.changeBoneDisplay(epAni,"layer1",epNode)
        for i=1,3 do
            if i <= cStar then
                self.winAni:getBone("UI_zhandoujiesuan_xing"..i):visible(true)
            else
                self.winAni:getBone("UI_zhandoujiesuan_xing"..i):visible(false)
            end
        end
        -- 显示葫芦底
        for i=1,3 do
            self.winAni:getBoneDisplay("layer9"):getBoneDisplay("element_"..(5 + i)):visible(true)
        end
    else
        -- 隐藏葫芦底
        for i=1,3 do
            self.winAni:getBoneDisplay("layer9"):getBoneDisplay("element_"..(5 + i)):visible(false)
        end
    end
end
-- 试炼
function BattleWin:loadTrails()
    self.winAni:getBone("layer3"):visible(false)
    local view = WindowsTools:createWindow("BattleTrialResult",self.battleDatas):addto(self)
end
-- 加载经验条(主角等级、经验)
function BattleWin:loadExp( )
    self.winAni:getBone("layer2"):visible(true)--主角等级
    --等级
    local lvNode = UIBaseDef:cloneOneView(self.panel_public.txt_level)
    lvNode:visible(true)
    lvNode:pos(0,23)
    lvNode:setString(self.result.lv)
    local lvAni = self.winAni:getBoneDisplay("layer2"):getBoneDisplay("layer9")
    FuncArmature.changeBoneDisplay(lvAni,"node1",lvNode)  

    --经验
    local expNode = UIBaseDef:cloneOneView(self.panel_public.txt_exp)
    expNode:visible(true)
    expNode:pos(0,23)
    expNode:setString(self.result.addExp )

    -- local expNode = display.newSprite(FuncRes.icon( "buff/battle_img_bianshen.png" ))
    -- echo(self.tempResult.lv,"===============")
    local expAni = self.winAni:getBoneDisplay("layer2"):getBoneDisplay("jingyan")
    FuncArmature.changeBoneDisplay(expAni,"layer2",expNode)  
    local jingyanbone = self.winAni:getBoneDisplay("layer2"):getBone("jingyan")
    if tonumber(self.result.addExp) == 0 then
        jingyanbone:visible(false)
    else
        jingyanbone:visible(true)
    end
end
-- 添加排行显示
function BattleWin:addRankInfo( )
    self.winAni:registerFrameEventCallFunc(35,1,function ()
        if self.rich_bs2 and self.rich_s2 and self.result.damage and self.result.rank then
            self.txt_bs:visible(true)
            self.rich_bs2:visible(true)
            self.txt_s:visible(true)
            self.rich_s2:visible(true)
            self.rich_bs2:setString("<color = 7eff28>"..self.result.damage.."<->")
            self.rich_s2:setString("<color = 7eff28>"..self.result.rank.."<->")
        end
    end)
end
-- 主线、经验、无底深渊、试炼、锁妖塔用三种胜
function BattleWin:checkIs3Sheng()
    local bLabel = BattleControler:getBattleLabel()
    if bLabel == GameVars.battleLabels.worldPve or
        bLabel == GameVars.battleLabels.endlessPve or
        BattleControler:checkIsTrail() ~= Fight.not_trail 
        then
        return true
    end
    return false
end

--[[
加载界面动画   pve类型战斗
]]
function BattleWin:loadAni(  )
    -- dump(LoginControler:isLogin(),"今天的状态1")
    if PrologueUtils:showPrologue() then
        self.btn_1:visible(false)
    else
        -- local x,y = self.btn_2:getPosition()
        -- self.btn_1:pos(x,y)
        self.btn_1:visible(true)
    end

    local star = FuncCommon:getBattleStar(self.result.star)
    if star == 0 then star = 3 end
    local flaArr = {"UI_zhandoujiesuan_xiansheng","UI_zhandoujiesuan","UI_zhandoujiesuan_wansheng"}
    local animStr = flaArr[3]
    local bLabel = BattleControler:getBattleLabel()
    -- 主线、经验、无底深渊、试炼 用三种胜
    if self:checkIs3Sheng() then
        animStr = flaArr[star]
    end

    --UI_zhandoujiesuan
    self.winAni = self:createUIArmature("UI_zhandoujiesuan",animStr,self.ctn_big,false,GameVars.emptyFunc):pos(0,0)
    self.winAni:pos(500,-300)
    -- self.winAni:anchor(0,0)
    self.winAni:playWithIndex(0, false)
    --让所有子动画都只播放一次
    self.winAni:setAllChildAniPlayOnce()

    self.winAni:getBone("node1"):visible(false)--顺利通关(锁妖塔用)
    self.winAni:getBone("layer2"):visible(false)--主角等级
    if self:checkIs3Sheng() then
        if star == 3 then
            self.winAni:getBone("layer5"):visible(false) --隐藏‘胜利’字
        end
        self.winAni:getBoneDisplay("layer3"):getBoneDisplay("chuzi"):playWithIndex(star-1)
    else
        self.winAni:getBone("layer_sl"):visible(false) --隐藏‘完胜’字
        self.winAni:getBone("layer3"):visible(false)--顺利通关字样
        -- 隐藏三葫芦 和葫芦底
        for k = 1,3 do
            self.winAni:getBone("UI_zhandoujiesuan_xing"..k):visible(false)
            self.winAni:getBoneDisplay("layer9"):getBoneDisplay("element_"..(5 + k)):visible(false)
        end
    end
    if BattleControler:checkIsTower() then
        -- 锁妖塔葫芦的意思是获得几个葫芦(永远显示完胜[flash里面有胜利标签])
        self:loadTowerExt()
    end
    if bLabel == GameVars.battleLabels.worldPve then
        self:loadExp()
        if LoginControler:isLogin() then
            self:updateHeros()
        end
    end
    if BattleControler:checkIsShareBossPVE() or
        bLabel == GameVars.battleLabels.guildBossPve or 
        bLabel == GameVars.battleLabels.guildBossGve
        then
        self:addRankInfo()
    end
    if BattleControler:checkIsTrail() ~= Fight.not_trail then
        self:loadTrails()
    end

    self:delayCall(c_func(self.loadDongArt,self,self.winAni,"node10"), 0.2)

    local lihuiAni = self.winAni:getBoneDisplay("layer10")
    self:delayCall(c_func(self.loadArt,self,lihuiAni), 0.4)

    self.panel_jixu:pos(-230*GameVars.width/1400,-70*GameVars.height/768)
    local txtAni = self.winAni:getBoneDisplay("layer23")
    FuncArmature.changeBoneDisplay(txtAni,"layer1",self.panel_jixu)  
    self.panel_jixu:visible(true)
end

-- 获取奇侠展示立绘
function BattleWin:getBiographyArt(  )
    local pId = BiographyControler:getCacheBattlePartnerId()
    echo("显示奇侠id===",pId)
    local data1 = PartnerModel:getPartnerDataById(pId)
    local sp = FuncPartner.getPartnerLiHuiByIdAndSkin(pId,data1.skin)
    local nd = display.newNode()
    --向下适配
    FuncCommUI.setScale9Align(self.widthScreenOffset, sp,UIAlignTypes.MiddleBottom )
    sp:addto(nd)
    sp:setAnimation(0,"ui", true)
    return nd
end

--获取最高伤害人的立绘(现在是最高战力的立绘)
function BattleWin:getMaxDamageHeroArt(  )
    local sp 

    --如果没有登入 直接返回 
    if not LoginControler:isLogin() then
        sp = FuncGarment.getGarmentLihui("",UserModel:avatar())
    else
        -- 获取伙伴战力并与主角比较
        local maxAblity = CharModel:getCharAbility()
        -- 如果是使用npc，则直接显示主角
        local maxObj = nil
        local useNpc = BattleControler.gameControler.levelInfo.useNpc
        if not useNpc or useNpc == 1 then 
            -- dump(self.result.damages)
            local tmpTbl = BattleControler:getPartnerIds() --获取伙伴的id
            -- 比较战力
            for i,v in ipairs(tmpTbl) do
                local partnerInfo = PartnerModel:getPartnerDataById(v)
                -- dump(partnerInfo)
                if partnerInfo then
                    -- 战力 
                    --function FuncPartner.getPartnerAbility( _partnerInfo,userData )
                    local ability = FuncPartner.getPartnerAbility(partnerInfo,UserModel:data(),nil)
                    if ability > maxAblity then
                        maxObj = v
                        maxAblity = ability
                    end
                end
            end
        end
        if maxObj then
            local data1 = PartnerModel:getPartnerDataById(maxObj)
            sp = FuncPartner.getPartnerLiHuiByIdAndSkin(maxObj,data1.skin)
        else
            local avatar = UserModel:avatar()
            local garmentId = UserExtModel:garmentId()
            sp = FuncGarment.getGarmentArtSp(garmentId,avatar)
        end
    end
    -- 特殊关卡，暂时写死在这里（比武招亲显示李逍遥的立绘）
    if BattleControler.__levelHid == "10305" then
        sp = FuncPartner.getPartnerLiHuiByIdAndSkin("5003","")
    end
    local nd = display.newNode()
    --向下适配
    FuncCommUI.setScale9Align(self.widthScreenOffset, sp,UIAlignTypes.MiddleBottom )
    sp:addto(nd)
    sp:setAnimation(0,"ui", true)
    return nd
end

-- 获取仙界对决显示立绘(显示最高伤害的角色)
function BattleWin:getCrossPeakHeroArt(  )
    local sp 
    --如果没有登入 直接返回 
    if not LoginControler:isLogin() then
        sp = FuncGarment.getGarmentLihui("",UserModel:avatar())
    else
        local data = FuncDataSetting.getDataByHid("CrossPeakCactusId")
        local maxDemage,hid = 0 ,0
        local _getMaxDemage = function( arr )
            if not arr then return end
            for k,v in pairs(arr) do
                -- 仙人掌不参与结算显示
                if data and data.str == v.data.hid then
                else
                    local tmp = StatisticsControler:getRidTotalDamage(v.data.rid)
                    if tmp > maxDemage then
                        maxDemage = tmp 
                        hid = v.data.hid
                        if v.data.isCharacter then
                            hid = "1"
                        end
                    end
                end
            end
        end
        -- 替补阵容伤害为0，所以不用考虑
        local camp = BattleControler:getTeamCamp()
        _getMaxDemage(BattleControler.gameControler["campArr_"..camp])
        _getMaxDemage(BattleControler.gameControler["diedArr_"..camp])
        if hid == "1" or hid == 0 then
            local avatar = UserModel:avatar()
            local garmentId = UserExtModel:garmentId()
            sp = FuncGarment.getGarmentArtSp(garmentId,avatar)
        else
            local mapping = FuncCrosspeak.getPartnerMapping(hid)
            local data = PartnerModel:getPartnerDataById(mapping.partnerId)
            local skin = ""
            if data then
                skin = data.skin
            end
            sp = FuncPartner.getPartnerLiHuiByIdAndSkin(mapping.partnerId,skin)
        end
    end
    local nd = display.newNode()
    if sp then
        --向下适配
        FuncCommUI.setScale9Align(self.widthScreenOffset, sp,UIAlignTypes.MiddleBottom )
        sp:addto(nd)
        sp:setAnimation(0,"ui", true)
    end
    return nd
end
-- 获取试炼立绘
function BattleWin:getTrialArt(  )
    local nd = display.newNode()
    local sp
    if not LoginControler:isLogin() then
        sp = FuncGarment.getGarmentLihui("",UserModel:avatar())
    else
        local data,maxValue = StatisticsControler:getTrailStatisData()
        if data.isCharacter then
            local avatar = data.hid
            local garmentId = data.garmentId
            sp = FuncGarment.getGarmentLihui(garmentId,avatar)
        else
            local skin = data.skin
            sp = FuncPartner.getPartnerLiHuiByIdAndSkin(data.hid,skin)
        end
    end
    if sp then
        sp:addto(nd)
        --向下适配
        FuncCommUI.setScale9Align(self.widthScreenOffset, sp,UIAlignTypes.MiddleBottom )
    end
    sp:pos(0,-30)
    sp:setAnimation(0,"ui", true)
    return nd
end

function BattleWin:updateHeros(  )
    --每个英雄增加了多少经验
    -- echo("更新英雄的经验加成---------")

    local heros = {}
    if self.result.damages ~= nil then
        local allHeros = table.values(self.result.damages.camp1)
        for k,v in pairs(allHeros) do
            if not v.isMainHero then
                local hid = v.hid
                --这里是个坑=====   这里为什么要加一个order
                --local index = TeamFormationModel:getPartnerRealPIdx( hid,self.result.battleLabels )
                --v.order = index
                table.insert(heros, v)
            end
        end
    end
    
    if #heros == 0 then
        self.mc_huobannum:visible(false)
        return    
    end
    self.mc_huobannum:visible(true)
    table.sort( heros, function(a,b)  
        if a.order == nil or b.order == nil then return true end
        return a.order<b.order
      end )
    --这里应该对heros进行一次排序
    self.mc_huobannum:showFrame(#heros)

    for k=1,#heros,1 do
        local panel = self.mc_huobannum.currentView["panel_"..k]
        panel.panel_1:visible(false)
    end

    --动画结束
    local callBack2
    callBack2 = function ( panel,data )
        if not data.addExp then
            data.addExp = 0
            echoWarn("伙伴没有加经验暂时给0,hid:",data.hid)
        end
        -- dump(data)
        --品质
        panel.panel_1.mc_1:showFrame( tonumber(FuncChar.getBorderFramByQuality(data.quality) ) )
        panel.panel_1:visible(true)
        --星级
        panel.panel_1.mc_2:showFrame(data.star)
        --等级
        panel.panel_1.txt_3:setString(data.lv)

        local addExps =0
        if data.lv > data.preLv then
            addExps= data.addExp
        elseif data.lv == data.preLv then
            if data.exp == 0 then
                addExps= data.addExp
            else
                addExps = data.exp - data.preExp
            end
        end
        --经验、添加一个与主角等级的判定
        if addExps == 0 and self.result.lv == data.lv  then
            -- 经验已满，这个时候就不需要动画了
            panel.panel_1.txt_2:setString(GameConfig.getLanguage("#tid_battle_2"))
        else
            --增加伙伴经验
            panel.panel_1.txt_2:setString(GameConfig.getLanguage("#tid_battle_1")..addExps)
        end

        local  _spriteIcon
        if data.garmentId then
            _spriteIcon = FuncPartner.getPartnerIconByIdAndSkin(data.hid,data.garmentId)
        else
            _spriteIcon = display.newSprite( FuncRes.iconHero(data.icon ))
        end
        _spriteIcon:scale(1.2)
        
        panel.panel_1.mc_1.currentView.ctn_1:addChild(_spriteIcon)

        local lastExp = math.round((data.exp-data.addExp)/data.maxExp*100)
        if lastExp<=0 then lastExp = 0 end
        local nextExp = math.round(data.exp/data.maxExp*100)
        if data.exp == 0 then
            nextExp = math.round(data.addExp/data.maxExp*100)
        end
       
        panel.panel_1.progress_1:setPercent(lastExp)
        if addExps > 0 then
            panel.panel_1.progress_1:tweenToPercent(nextExp)
        end

        if data.lv> data.preLv then
            --升级了
           panel.ctn_2.lvUpAni= self:createUIArmature("UI_zhandoujiesuan", "UI_zhandoujiesuan_zhujueshengji", panel.ctn_2, false, nil)
           panel.ctn_2.lvUpAni:playWithIndex(0,false)
        end

    end



    --icon显示
    local callBack
    callBack = function ( panel,data )
        --UI_zhandoujiesuan
        panel.chuxianAni = self:createUIArmature("UI_zhandoujiesuan","UI_zhandoujiesuan_chuxian",panel.ctn_1,false,GameVars.emptyFunc):pos(0,0)
        --panel.chuxianAni = FuncArmature.createArmature("UI_zhandoujiesuan_chuxian",panel.ctn_1,false,GameVars.emptyFunc):pos(0,0)
        panel.chuxianAni:scale(1.2)
        panel.chuxianAni:playWithIndex(0)
    end

    -- dump(heros)
    for k = 1,#heros do
        local panel = self.mc_huobannum.currentView["panel_"..k]
        
        panel:delayCall( c_func(callBack,panel,heros[k] ), (45+(k-1)*3)/GameVars.GAMEFRAMERATE )
        panel:delayCall( c_func(callBack2,panel,heros[k] ), (47+(k-1)*3)/GameVars.GAMEFRAMERATE )
        
    end
end



function BattleWin:hideComplete()
    BattleWin.super.hideComplete(self)
    -- echo("___隐藏胜利完毕----1111")
end
function BattleWin:showOther( )
     --如果没有登录  直接退出游戏
    if not LoginControler:isLogin() then
        FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
        return
    end
    if BattleControler:checkIsShareBossPVE() or
        BattleControler:getBattleLabel() == GameVars.battleLabels.guildBossPve or
        BattleControler:getBattleLabel() == GameVars.battleLabels.guildBossGve
      then
        if not self.battleDatas.reward or #self.battleDatas.reward == 0 then
            -- echo("没有奖励物品---")
            FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
            return
        end
        WindowControler:showBattleWindow("BattleShareBossReward",self.battleDatas)
        return
    end


    --如果登录了。不是pvp 并且不是剧情  这个字原来的流程
    if LoginControler:isLogin() and (not self.isPVP)  then
        if not self.battleDatas.reward or #self.battleDatas.reward == 0 then
            -- echo("没有奖励物品---")
            FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
            return
        end
        WindowControler:showBattleWindow("BattleReward",self.battleDatas)
        return
    end

    --pvp 或者剧情  并且没有升级
     if (self.isPVP or  BattleControler._battleInfo.withStory) and (not self.isLvUp)  then
        FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
        return
    end


    --登录了，并且升级了 在剧情中
    if LoginControler:isLogin() and self.isLvUp and BattleControler._battleInfo.withStory then
        WindowControler:showBattleWindow("CharLevelUpView", UserModel:level(),true)
    end
end


function BattleWin:deleteMe()
    BattleWin.super.deleteMe(self)
    self.controler = nil
end 

return BattleWin;
