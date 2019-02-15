--
-- Author: xd
-- Date: 2015-11-26 15:16:44
local Window_test = class("Window_test", function (  )
    return display.newNode()
end)


 local sharedTextureCache = cc.Director:getInstance():getTextureCache()

function Window_test:ctor()
    self._root = display.newNode():addto(self)
    local layer = WindowControler:createCoverLayer(0,GameVars.height ,cc.c4b(99,99,99,255),false,{1136,640}):addto(self,-1)


    self:creatBtns("返回主场景",c_func(self.backSceneMain,self))

    --需要自己在这里设置uid
    self:creatBtns("用指定的UID登入",c_func(self.specialLogin,self,"231"))


    self:creatBtns("重置序章",c_func(self.resetPrologue,self),true)
    self:creatBtns("仙盟地图",c_func(self.guildExplore,self))
    self:creatBtns("重置探索场景",c_func(self.resetExplore,self))

    -- self:creatBtns("跳过序章",c_func(self.skipPrologue,self))
    -- self:creatBtns("开启新手引导", c_func(self.openTuroral, self))
    -- self:creatBtns("开启触发试引导", c_func(self.openToggerTuroral, self))
    -- self:creatBtns("配置文件检查", c_func(self.configTest, self))

    -- self:creatBtns("所有关卡战斗", c_func(self.battleConfirm, self))

    self:creatBtns("共闯秘境单人", c_func(self.enterGame, self,"55000",GameVars.battleLabels.guildBossPve))

    self:creatBtns("普通关卡", c_func(self.enterGame, self,"10201",GameVars.battleLabels.worldPve))


    self:creatBtns("巅峰帐号1",c_func(self.enterDianfeng, self,"pa082307","123456"))
    self:creatBtns("巅峰帐号2",c_func(self.enterDianfeng, self,"pa082308","123456"))

    -- self:creatBtns("共闯秘境", c_func(self.enterGuildBossGve, self))
    -- self:creatBtns("共闯秘境1", c_func(self.enterGuildBossGve, self,"pa053001","123456"))
    -- self:creatBtns("共闯秘境2", c_func(self.enterGuildBossGve, self,"pa053002","123456"))


    self:creatBtns("日志战斗", c_func(self.logsGame, self))
    -- self:creatBtns("普通关卡1", c_func(self.enterGame, self,"t10101",GameVars.battleLabels.worldPve))

    -- self:creatBtns("普通关卡2", c_func(self.enterGame, self,"t10102",GameVars.battleLabels.worldPve))
    -- self:creatBtns("普通关卡3", c_func(self.enterGame, self,"t10103",GameVars.battleLabels.worldPve))
    -- self:creatBtns("普通关卡4", c_func(self.enterGame, self,"t10104",GameVars.battleLabels.worldPve))
    -- self:creatBtns("普通关卡5", c_func(self.enterGame, self,"t10105",GameVars.battleLabels.worldPve))


    -- self:creatBtns("战斗反向",c_func(self.enterTestRever,self,"10101",GameVars.battleLabels.worldPve))
    -- self:creatBtns("boss关卡", c_func(self.enterGame, self,"70000",GameVars.battleLabels.worldPve))
    -- self:creatBtns("竞技场关卡", c_func(self.enterGame,self,"103" ,GameVars.battleLabels.pvp))

    -- self:creatBtns("山神", c_func(self.enterGame,self,"3000" ,GameVars.battleLabels.trailPve))   --这是试炼1
    -- self:creatBtns("火神", c_func(self.enterGame,self,"3101" ,GameVars.battleLabels.trailPve2))
    -- self:creatBtns("盗宝者", c_func(self.enterGame,self,"3200" ,GameVars.battleLabels.trailPve3))
    -- self:creatBtns("锁妖塔", c_func(self.enterGame,self,"80101" ,GameVars.battleLabels.towerPve))
    -- self:creatBtns("共享副本", c_func(self.enterGame,self,"70301" ,GameVars.battleLabels.shareBossPve))
    -- -- self:creatBtns("比武招亲", c_func(self.enterGame,self,"80013" ,GameVars.battleLabels.towerPve))
    -- -- self:creatBtns("守护宝物", c_func(self.enterGame,self,"80013" ,GameVars.battleLabels.towerPve))
    -- self:creatBtns("仙盟GVE", c_func(self.enterGame,self,"20101" ,GameVars.battleLabels.guildGve))
    
    -- self:creatBtns("轶事夺宝", c_func(self.enterGame,self,"60010" ,GameVars.battleLabels.missionMonkeyPve))
    -- self:creatBtns("比武切磋", c_func(self.enterGame,self,"60020" ,GameVars.battleLabels.missionBattlePve))
    -- self:creatBtns("战斗服测试", c_func(self.serviceDebug,self))
    -- self:creatBtns("无尽深渊", c_func(self.enterGame, self,"54000",GameVars.battleLabels.endlessPve))

    -- self:creatBtns("仙灵对决机器人", c_func(self.crosspeakRobot,self))

    -- self:creatBtns("帧事件测试", c_func(self.spineFrameTest, self))


    -- self:creatBtns("大地图测试", c_func(self.testMap2, self))


    self:creatBtns("动画编辑器", c_func(self.animDialogTest, self, 100000))
    self:creatBtns("神器调试", c_func(self.shenqiTest, self))

    self:creatBtns("缘伴系统", c_func(self.yuanbanTest, self))

    self:creatBtns("福利", c_func(self.fuliText, self))

    self:creatBtns("动画编辑器检查", c_func(self.animDialogCheck, self, 100000))
    -- self:creatBtns("立绘对话", c_func(self.plotDialog, self))
    self:creatBtns("立绘对话", c_func(self.plotDialog, self, 100))

    --    --这是试炼2
    -- self:creatBtns("删除多余spine",c_func(self.checkDelSpine,self))

    -- self:creatBtns("六界", c_func(self.enterWorld, self))
    -- -- 寻仙
    -- self:creatBtns("道具路径匹对", c_func(self.daojupipeianniu, self))
    -- -- 聊天
    -- self:creatBtns("聊天", c_func(self.chatTest, self),true)
    -- --道具
    -- self:creatBtns("背包", c_func(self.itemTest, self))
    -- --创角
    -- self:creatBtns("仙盟", c_func(self.roleTest, self))
    -- --锁妖塔
    -- self:creatBtns("锁妖塔地图", c_func(self.towerTest, self))
    -- self:creatBtns("gve2场景", c_func(self.newLovePropertyEntrance, self))
    -- self:creatBtns("情缘全局属性点亮", c_func(self.newLovePropertyLighten, self))
    self:creatBtns("精英探索场景", c_func(self.newLovePropertyEntrance, self))
    self:creatBtns("精英机关", c_func(self.newLovePropertyLighten, self))

    -- if OPEN_TUTORAL == true then 
    --     require("game.sys.view.tutorial.TutorialManager")

    --     self:tutorialTest();
    -- end 

    -- self:creatBtns("富文本测试",c_func(self.addrichText,self))
    -- self:creatBtns("一键脏字检查",c_func(self.chazhaobuxianshizifu,self))
    -- self:creatBtns("阵型设置",c_func(self.formationSet,self))
    -- self:creatBtns("波纹滤镜测试",c_func(self.waterTest,self), true)
    -- self:creatBtns("loading测试", c_func(self.loadingTest, self))
    -- self:creatBtns("清理本地阵型",c_func(self.teamTest,self))

    self:creatBtns("获取战报",c_func(self.getBattleLog,self), true)

    self:creatBtns("检查Assets巨图",c_func(self.checkBigImg,self), true)
    -- 
    self:creatBtns("重置用户状态",c_func(self.resetUserStatus,self), true)

    self:creatBtns("查看委托币数量",c_func(self.getWTBNum,self), true)

    self:creatBtns("spine换装测试",c_func(self.spineChangeWeapon,self),true)

    self:creatBtns("月卡特权", c_func(self.yuekatequan, self))
    self:creatBtns("月卡商城", c_func(self.yuekashangcheng, self))
    -- local content = "<color=0000FF,size=24>小明<->充值<color=00FF00,size=24>10000<->仙玉"
    -- self.richText = RichTextExpand.new()
    -- self.richText:setContentSize(cc.size(450, 300))
    -- self:addChild(self.richText)
    -- self.richText:setText(content)
    -- self.richText:startPrinter(10)
    -- self.richText:pos(300,-300)


    -- local view = WindowControler:createWindowNode("BulleTip")
    -- view:setTxt("<color=0000FF,size=24>小明<->充值<color=00FF00,size=24>10000<->仙玉")
    -- view:pos(0,0)
    -- FuncArmature.loadOneArmatureTexture("UI_lihuibiaoqing", nil, true)
    -- local ani =FuncArmature.createArmature("UI_lihuibiaoqing_tanhua", self, true)
    -- ani:pos(300,300)

    -- FuncArmature.changeBoneDisplay( ani,"layer1",view )
    -- ani:playWithIndex(1, true, false)

    self:creatBtns("奇侠展示", c_func(self.enterSkinFirstShowView, self, "5014"))
    self:creatBtns("演示关卡测试", c_func(self.enterMiniBattle, self, "t30001"), false)

    self:creatBtns("地形编辑器", c_func(self.enterTerrainEditor, self))
    --[[
        解析序列化的战报
        
        将战报放在logs/encryptedLog 文件夹下，点按钮;
        解析后会以同名文件形式保存在logs/decodedLog下

        如果没有对应文件夹，直接点击按钮会自动创建文件夹
    ]]
    self:creatBtns("解析战报", c_func(self.battleDecode, self))
    --幻境协战boss
    self:creatBtns("幻境协战", c_func(self.shareBossBtn, self))
end

function Window_test:shareBossBtn()
    WindowControler:showWindow("ShareBossCompView", 1, nil, {"1004", "1005", "1006"})
end

function Window_test:guildExplore(  )
    -- UserModel:init({gold = 1000})

    local callFunc = function ( d )
        if  d and (not d.result) then
            return
        end
        if not LoginControler:isLogin() then
            GuildExploreModel:initOneMap(  )
            local window =WindowControler:showWindow("GuildExploreGrid")
            window._root:removeAllChildren()
            require("game.sys.view.guildExplore.init")

            self.controler = ExploreControler.new(window)
        else
            -- WindowControler:showWindow("GuildExploreMainView")
        end
        -- dump(d,"___callData")
        
        
    end
    if not LoginControler:isLogin() then
        callFunc({result = 1})
    else
        GuildExploreServer:startGetServerInfo(callFunc)
    end
    -- GuildExploreServer:startGetServerInfo(callFunc)

    
end

--重置仙盟数据
function Window_test:resetExplore(  )
    ServerJavaSystem:sendRequest({}, "gm.clearGuild")
end

function Window_test:getWTBNum( ... )
    local a = UserModel:getDeputeCoin( )
    echo("当前委托币数量为:",a)
end
-- 重置用户状态
function Window_test:resetUserStatus(  )
    Server:sendRequest({},MethodCode.user_resetUserStatus,nil,true,true,false )
end

--检查巨图
function Window_test:checkBigImg(  )
    local checkFunc
    local mb = 1024*1024
    checkFunc = function ( path )
        for file in lfs.dir(path) do
            if file ~="." and file~= ".." then
                local curDir = path..file
                local mode = lfs.attributes(curDir, "mode")
                if mode == "file" then
                    local targetfile =  io.open(curDir, "rb")
                    if targetfile then
                       local size = targetfile:seek("end")
                        --如果大于10M 判定为巨图
                        if size > mb* 10  then
                            echoWarn("___巨图:"..math.round(size/mb *100)/100 .."mb,",curDir)
                        end
                        targetfile:close()
                    end
                    
                elseif mode == "directory" then
                    checkFunc(curDir .. "/")
                else
                    
                end
            end
            
        end
    end
    local t1 = os.clock()
    checkFunc("../Assets/")
    echo("checkend---图片检查完毕",os.clock() - t1)

end


function Window_test:specialLogin( uid )
        
    local tempFunc = function ( resultData )
        LoginControler._uname = uid
        LoginControler:doLoginBack(resultData)
    end

    local platForm = ServiceData.curPlatform
    local cfg =ServiceData.platformCfg[platForm]
    HttpServer:sendHttpRequest({uid=uid,serviceId=PLATFORM_LOGIN_GROUP}, MethodCode.user_loginByUid, tempFunc,nil,true,true)

end


function Window_test:enterDianfeng( userName,password )
    LoginControler:quickLoginByData(userName,password)

    local tempFunc = function (  )
        CrossPeakModel:openCrossPeakUI( )
    end


    local onLoginComp = function (  )
        CrossPeakModel.currentRank = 10 
        --更新下用户状态
        CommonServer:updateUserState()
        WindowControler:showWindow("CrosspeakNewMainView")
    end

    WindowControler:globalDelayCall(onLoginComp, 1)

end


function Window_test:waterTest()
    local sp = FilterTools.setWaterWave({node = self,w = GameVars.width,h = GameVars.height,offX = 0,offY = 0},{type = 2,pos = cc.p(0.3,0.5)})
    sp:pos(0,0):anchor(0,0)
    sp:addto(self)
end

function Window_test:addrichText()
   WindowControler:showWindow("ChatInfoCellView");
end
function Window_test:backSceneMain(  )
    if LoginControler:isLogin() then
        WindowControler:showWindow("WorldMainView");
    end
end

--测试
Window_test.btnNums = 0

local hangNums = 5
local wid = 150
local hei = 70
--创建一个测试按钮只用传递一个显示文本和一个点击函数即可,目前是自动排列
function Window_test:creatBtns( text,clickFunc,skipClear )
    self.btnNums = self.btnNums + 1
    local xIndex =  self.btnNums %hangNums 
    xIndex = xIndex == 0 and hangNums or xIndex
    local yIndex = math.ceil( self.btnNums/hangNums )
    local xpos = GameVars.UIOffsetX +  (xIndex-1) * wid  + 30

    local ypos = GameVars.height - GameVars.UIOffsetY-(yIndex-1) * hei - 70
    local sp = display.newNode():addto(self._root):pos(xpos,ypos):anchor(0,0)
    sp:size(130,50)

    local callBack = function (  )
        if not skipClear then
            self:clear()
        end
        clickFunc()
    end

    display.newRect(cc.rect(0, 0,130, 50),
        {fillColor = cc.c4f(1,1,1,0.8), borderColor = cc.c4f(0,1,0,1), borderWidth = 1}):addto(sp)

    display.newTTFLabel({text = text, size = 20, color = cc.c3b(255,0,0),font="ttf/"..GameVars.fontName})
            :align(display.CENTER, sp:getContentSize().width/2, sp:getContentSize().height/2)
            :addTo(sp):pos(65,25)
    sp:setTouchedFunc(callBack,cc.rect(0,0,127,64))
end


function Window_test:onExit()
end


--===================================================================
-- 富文本测试
function Window_test:fuwenbenTest()
    
    local _richText =  RichTextExpand.new():pos(200,400)
    _richText:ignoreContentAdaptWithSize(false)
    _richText:setContentSize(cc.size(200, 100))
    local re1 = _richText:getRichElementText(1, cc.c3b(255, 255, 255), 255, "哈哈This color is white  ", GameVars.fontName, 20)
    local re2 = _richText:getRichElementText(2, cc.c3b(255, 255,   0), 255, "哈哈This color is white  ", GameVars.fontName, 20)
    local re3 = _richText:getRichElementText(3, cc.c3b(0,   0, 255), 255, "This one is blue. ", GameVars.fontName, 20)
    local re4 = _richText:getRichElementText(4, cc.c3b(0, 255,   0), 255, "And green. ", GameVars.fontName, 20)
    local re5 = _richText:getRichElementText(5, cc.c3b(255,  0,   0), 255, "Last one is red ", GameVars.fontName, 10)
    local re6 = _richText:getRichElementLinkLineNode(6, cc.c3b(255,  0,   0), 255, "哈哈This one", GameVars.fontName, 20)
    local re7 = _richText:getRichElementText(7, cc.c3b(255,  0,   0), 255, "Last one is red ", GameVars.fontName, 20)


    local func = function (  )
    end
    -- FuncArmature.loadOneArmatureTexture("test",nil,true)
    -- self._aniEff = FuncArmature.createArmature("zhandouzhong_kongzhixunhuan", nil, true,func)
    -- local re8 = _richText:getRichElementCustomNode(8, cc.c3b(255,  0,   0), 255, self._aniEff)

    local re9 = _richText:getRichElementImage(8, cc.c3b(255,  0,   0), 255, "ui/image_16.png")


    _richText:pushBackElement(re1)

    _richText:pushBackElement(re9)

    _richText:addNewLine()
    --_richText:pushBackElement(re2)
    _richText:insertElement(re2,0)

    -- _richText:pushBackElement(re8)
    
    _richText:pushBackElement(re3)
    _richText:addNewLine()
    _richText:pushBackElement(re4)
    _richText:pushBackElement(re5)
    
    _richText:pushBackElement(re6)
    _richText:addNewLine()
    _richText:pushBackElement(re7)

    
    
    self:addChild(_richText)

    self:delayCall(handler(self, self.delayCallHandler))
end


function Window_test:testFilter(  )
    WindowControler:showWindow("DebugFilterView")
end


function Window_test:enterCharView()
    if not self:checkLoginOk() then return end
    -- WindowControler:showWindow("CharAttributeView")
    WindowControler:showWindow("CharMainView")
end


function Window_test:treasureTest()
    if not self:checkLoginOk() then return end
    WindowControler:showWindow("TreasureEntrance");
end

-- 竞技场
function Window_test:aranaTest()
    if not self:checkLoginOk() then return end
    WindowControler:showWindow("ArenaMainView")
end

function Window_test:homeBtn()
    WindowControler:showWindow("HomeMainView");
end

function Window_test:guildTest()
    -- 判断境界够不够
    local needState = FuncDataSetting.getDataByEncStr(FuncDataSetting.getOriginalData("GuildState"));
    echo("needState:" .. tostring(needState));
    if needState <= UserModel:state() then
        -- todo 判断是否已经加入了公会
        if UserModel:guildId() == "" then
            WindowControler:showWindow("GuildBlankView");
        else
            echo("已经加入公会");
            -- 取公会数据数据
            -- WindowControler:showWindow("GuildHomeView");
            EventControler:dispatchEvent(GuildEvent.GUILD_GET_MEMBERS_EVENT,
            { });
        end
    else
        WindowControler:showTips( { text = "境界不足" })
    end
end

-- 邮件
function Window_test:enterMail()
    -- body
    WindowControler:showWindow("MailView", QuestType.MainLine)
end

-- 商城
function Window_test:enterShop()
    if not self:checkLoginOk() then return end
    WindowControler:showWindow("ShopView")
end

-- 排行榜
function Window_test:enterRank()
    local callBack = function(data)
        echo("enterRank callBack...")
        if data.result then
            WindowControler:showWindow("RankMainView", data.result.data)
        else
            echo("enterRank 请求error")
        end
    end

    RankServer:getRankList(2, 1, 10, c_func(callBack))
end

-- 签到
function Window_test:signView()
    WindowControler:showWindow("SignView");
end

-- 抽卡
function Window_test:enterLottery()
    if not self:checkLoginOk() then return end
    WindowControler:showWindow("LotteryMainView");
end

function Window_test:enterTrial()
    if TrailModel:isTrailOpen(TrailModel.TrailType.ATTACK, 1) == true then
        WindowControler:showWindow("TrialEntranceView");
    else
        WindowControler:showTips( { text = "等级不足" });
    end
end

-- 进入六届
function Window_test:enterWorld()
    echo("enterWorld====")
    WindowControler:showWindow("WorldMainView");
    -- WindowControler:showWindow("WorldMainView");
    -- WindowControler:showWindow("WorldPVELevelListView");
end

function Window_test:enterPVE()
    if not self:checkLoginOk() then return end
    WindowControler:showWindow("WorldPVEMainView");
end

-- 奇缘
function Window_test:enterRomance()
    if not self:checkLoginOk() then return end
    WindowControler:showWindow("RomanceView");
end


-- 任务
function Window_test:questTest()

    local isOpen, needLvl = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.MAIN_LINE_QUEST);
    if isOpen == true then 
        WindowControler:showWindow("QuestView");
    else 
        WindowControler:showTips("需要等级 " .. tostring(needLvl));
    end 
end

function Window_test:combineInterface()
   
end 

-- 战斗胜利
function Window_test:fightResult()
       local _params ={result=1, addExp = 10, preExp = 30, preLv = 35, star =1, reward = {[1]="1,4011,301" ,[2]="1,4012,300", [3]="1,4013,300", [4]="2,300,301" ,[5]="3,4201,301", } }
 

        local uiWin = WindowsTools:createWindow("BattleWin",_params)
        uiWin:addto(self._root):zorder(100):pos(GameVars.UIbgOffsetX +100 ,GameVars.scaleHeight)
        uiWin.battleDatas = _params
        uiWin:startShow()
        uiWin:updateUI( _params)


--        local uiLose = WindowsTools:createWindow("BattleLose")
--        uiLose.battleDatas = _params
--        uiLose:addto(self):zorder(100):pos(100,GameVars.scaleHeight)
--        uiLose:startShow()
--        uiLose:updateUI( _params) 
end 



--战斗失败
function Window_test:fightLose(  )
     local _params ={result=1, addExp = 10, preExp = 30, preLv = 35, star =1, reward = {[1]="1,4011,301" ,[2]="1,4012,300", [3]="1,4013,300", [4]="2,300,301" ,[5]="3,4201,301", } }
 

        local uiWin = WindowsTools:createWindow("BattleLose",_params)
        uiWin:addto(self._root):zorder(100):pos(GameVars.UIbgOffsetX+100 ,GameVars.scaleHeight)
        uiWin.battleDatas = _params
        uiWin:startShow()
        uiWin:updateUI( _params)
end



--[[
胜利宝箱
]]
function  Window_test:winBox(  )
    local uiWin = WindowsTools:createWindow("BattleReward",_params)
    uiWin:addto(self._root):zorder(100):pos(GameVars.UIbgOffsetX+100 ,GameVars.scaleHeight)
    uiWin.battleDatas = _params
    uiWin:startShow()
    uiWin:updateUI( _params)
end





--[[
战斗 伤害对比
]]
function Window_test:fightCompare(  )
    local uiWin = WindowsTools:createWindow("BattleAnalyze")
        uiWin:addto(self._root):zorder(100):pos(GameVars.UIbgOffsetX+100 ,GameVars.scaleHeight)
        uiWin:startShow()
        -- uiWin.battleDatas = _params
        -- uiWin:startShow()
        uiWin:updateUI( _params)
end



function Window_test:debugConnData(t)
    WindowControler:showWindow("TestConnView")
end





function Window_test:openTuroral()
    WindowControler:showTips( { text = "进主界面看引导" })
    
    require("game.sys.view.tutorial.TutorialManager")

    self:tutorialTest();
end


function Window_test:openToggerTuroral()
    IS_OPEN_TURORIAL = true;
    local unforcedTutorialManager = UnforcedTutorialManager.getInstance();
    if unforcedTutorialManager:isAllFinish() == false then 
        unforcedTutorialManager:startWork();
    end
end

function Window_test:configTest()
    local testView = require("game.sys.view.test.ConfigTestView").new():addto(self._root)
end

function Window_test:spineFrameTest()
    -- local testView = require("game.sys.view.test.ConfigTestView").new():addto(self._root)
    echo("-----spineFrameTest----");

    local sp = ViewSpine.new("20010_luorulieyaomo", {}, "", "20010_luorulieyaomo"):addto(
        self._root):pos(200, 300);
    sp:playLabel("attack3",false,false)

    local totalCnt = sp:getTotalFrames()
    echo("罗如烈总帧数----",totalCnt,"===============")

    -- sp:setEventCallBack(
    --     function (event)
    --         dump(event);
    --     end, ViewSpine.EventType.ANIMATION_START);

    -- sp:setEventCallBack(
    --     function (event)
    --           print(string.format("[spine] %d complete: %d", 
    --                                   event.trackIndex, 
    --                                   event.loopCount))
    --       end, ViewSpine.EventType.ANIMATION_END);

    -- sp:setEventCallBack(
    --     function (event)
    --         dump(event);
    --     end, ViewSpine.EventType.ANIMATION_COMPLETE);

    -- sp:setEventCallBack(
    --     function (event)
    --         dump(event);
    --     end, ViewSpine.EventType.ANIMATION_EVENT);


    -- sp:setAnimationEventCallBack("footstep", function (event)
    --     echo("---footstep----")
    --     dump(event, "----");
    -- end);

    -- sp:setAnimationEventCallBack("headAttach", function (event)
    --     echo("---headAttach----")
    --     dump(event, "----");
        
    -- end);


    -- sp.currentAni:setScale(0.5);
    -- sp:setPlaySpeed(0.2);
    -- sp:playLabel("run", true);

    -- local allEventArray = sp:getAllEventName();
    -- dump(allEventArray, "----allEventArray----");

end


function Window_test:showGamble()
    
end

function Window_test:guanFengTest()

    local params = {
        colorize = "#0000cc",--nil就是不设置这个参数
        amount = 2.4, --单独测试ok

        contrast = 3, --单独测试ok ok

        brightness = 2,  --单独测试ok ok
        saturation = 3,   --单独测试ok

        hue = 300,  --单独测试ok
        -- threshold = 200, --单独测试ok
    }   

    local matrix = ColorMatrixFilterPlugin:genColorTransForm(params);

    ColorMatrixFilterPlugin:dumpMatrix(matrix);


    local sprite = display.newSprite("asset/test/test123.png");
    self._root:addChild(sprite);

    sprite:setPosition(200, 300);
    sprite:setScale(1);


    local sprite2 = display.newSprite("asset/test/test123.png");
    self._root:addChild(sprite2);

    sprite2:setPosition(600, 300);
    sprite2:setScale(1);

    FilterTools.setColorMatrix(sprite2, matrix);
    

    -- local sp = ViewSpine.new("eff_treasure413_xutianding", {}, "", "eff_treasure413_xutianding"):addto(
    --     self._root):pos(200, 300);

    -- sp:playLabel("attack", true);
    -- -- sp:playLabel("stand_1", true);

    -- sp.currentAni:setScale(1);
    -- sp:setPlaySpeed(1);

end
function Window_test:serviceDebug( )
    GameLuaLoader:loadGameBattleInit()
    if not UserModel._data then
        UserModel:init({level =1})
    end
    local str = '{"battleId":"156","randomSeed":538675151,"battleUsers":[{"_id":"dev_2099","name":"0000","level":40,"avatar":101,"userExt":[],"quality":1,"star":1,"skins":[],"garments":[],"titles":[],"cimeliaGroups":[],"equips":{"20010":{"id":20010,"level":1},"20009":{"id":20009,"level":1},"20012":{"id":20012,"level":1},"20011":{"id":20011,"level":1}},"starPoint":0,"position":0,"fiveSoulLevel":1,"fivesouls":[],"treasures":{"304":{"id":304,"star":1,"awaken":0,"starPoint":0}},"formation":{"id":"15","treasureFormation":{"p2":"0","p1":"304"},"partnerFormation":{"p2":{"partner":{"partnerId":"1","rid":"dev_2099"},"element":{"elementId":"0","rid":"dev_2099"}},"p1":{"partner":{"partnerId":"0","rid":"dev_2099"},"element":{"elementId":"0"}},"p4":{"partner":{"partnerId":"0","rid":"dev_2099"},"element":{"elementId":"0"}},"p3":{"partner":{"partnerId":"0","rid":"dev_2099"},"element":{"elementId":"0"}},"p6":{"partner":{"partnerId":"0","rid":"dev_2099"},"element":{"elementId":"0"}},"p5":{"partner":{"partnerId":"0","rid":"dev_2099"},"element":{"elementId":"0"}}}},"userBattleType":1,"sec":"dev","team":1}],"battleParams":{"monsterInfo":{"monsterId":"10080"}},"battleLabel":"15","operation":[],"battleResultClient":[]}'
    local jsonData = json.decode(str)
    local battleInfo = BattleControler:turnServerDataToBattleInfo(jsonData)
    battleInfo.isDebug = true
    -- dump(battleInfo)
    BattleControler:startBattleInfo(battleInfo)
end
function Window_test:crosspeakRobot( )
    GameLuaLoader:loadGameBattleInit()
    if not UserModel._data then
        UserModel:init({level =1,rid = 1})
    end
    local tmpInfo = ObjectCommon:getCrossPeakData()
    local battleInfo = BattleControler:turnServerDataToBattleInfo(tmpInfo)
    battleInfo.isDebug = true
    -- dump(battleInfo)
    BattleControler:startBattleInfo(battleInfo)
end
-- 共闯秘境
function Window_test:enterGuildBossGve(userName,password)
    LoginControler:quickLoginByData(userName,password)

    local tempFunc = function (  )
        CrossPeakModel:openCrossPeakUI( )
    end


    local onLoginComp = function (  )
        CrossPeakModel.currentRank = 10 
        --更新下用户状态
        CommonServer:updateUserState()
        WindowControler:showWindow("GuildMainView")
        WindowControler:globalDelayCall(function( )
            WindowControler:showWindow("GuildActivityEntranceView")
            WindowControler:globalDelayCall(function( )
                WindowControler:showWindow("GuildBossInfoView")
            end, 1)
        end, 3)
    end

    WindowControler:globalDelayCall(onLoginComp, 1)

    -- GameLuaLoader:loadGameBattleInit()
    -- if not UserModel._data then
    --     UserModel:init({level =1,_id ="dev16_12474" })
    -- end
    -- local tmpInfo= GameStatistics:getLogsBattleInfo( Fight.statistic_file )
    -- local battleInfo = BattleControler:turnServerDataToBattleInfo(tmpInfo)
    -- -- battleInfo.isDebug = true
    -- -- dump(battleInfo)
    -- BattleControler:startBattleInfo(battleInfo)
end



local function sureEnterGame(  t,battleLabel,index, des)
    -- local tutorialManager = TutorialManager.getInstance();
    -- tutorialManager:startWork(self);
    if des then
        BattleDebug(des)
    end

    local keyArrbefore = Tool:getGlobalKey( )

    -- IS_IGNORE_LOG = true
    local start = collectgarbage("count")
    local ti = os.clock()

    if not UserModel._data then
        UserModel:init({level =1})
    end
    local battleInfo = { }
    battleInfo.battleUsers = { }
    local defaultHero = ObjectCommon:getServerData()
    for i = 1, #defaultHero do
        table.insert(battleInfo.battleUsers, defaultHero[i])
    end
    battleInfo.levelId = t
    --这是pve
    battleInfo.battleLabel =  battleLabel or GameVars.battleLabels.worldPve  --GameVars.battleLabels.worldPve

    -- 这里模拟锁妖塔血量信息 Test
    if battleLabel == GameVars.battleLabels.towerPve then
        battleInfo.battleParams = {}
        local bParams = battleInfo.battleParams
        -- 锁妖塔数据
        local p1 = {userRid = UserModel:rid(),hid=101,hpPercent=9000,energyPercent=1000}
        local p2 = {userRid = UserModel:rid(),hid=5005,hpPercent=100,energyPercent=10000}
        local hpInfo = {
                -- bossHp = 1000,
                enemy = {
                    {energyPercent=1000,hpPercent=2760,rid="801010_2_1"},
                    {energyPercent=1000,hpPercent=9763,rid="801010_3_1"},
                    {energyPercent=1000,hpPercent=9763,rid="801010_4_1"},
                },
                levelHpPercent = 3000,
            }
        bParams.unitInfo = {json.encode(p1),json.encode(p2)}
        bParams.towerInfo={
            monsterId=1001,--关卡怪物id
            star = 2,
            -- bossHp=1000,
            buffs = {
                -- ["300221"]=1,
            },
            propChange=0,--比如，某个怪物死亡对指定的角色造成攻防血降低10%
            tempBuffs = {
                -- ["101"]=1,
            },
            hpInfo = json.encode(hpInfo),
            energy = 6,--怒气值
        }
    elseif battleLabel == GameVars.battleLabels.trailPve then
        battleInfo.battleParams = {trialId = 3001}
    elseif battleLabel == GameVars.battleLabels.trailPve2 then
        battleInfo.battleParams = {trialId = 3006}
    elseif battleLabel == GameVars.battleLabels.trailPve3 then
        -- 掉落的法宝
        battleInfo.dropTreasures = {
            [1] = {
                awaken = 0,
                id = "304",
                star = 1,
            },
            [2] = { 
                awaken = 0,
                id = "404",
                star = 1,
            },
        }
    elseif battleLabel == GameVars.battleLabels.shareBossPve then
        battleInfo.battleParams = {}
        local bParams = battleInfo.battleParams
        local hpInfo = {
            {hpPercent=1000,rid="103011_1_1"},
            {hpPercent=5000,rid="103011_2_1"},
            {hpPercent=1,rid="103011_3_1"},
            {hpPercent=7000,rid="103011_4_1"},
            {hpPercent=9000,rid="103010_5_1"},
        }
        local shareBossInfo = {bossId = "101",bossHp = "",buffId="1"}
        battleInfo.shareBossInfo = shareBossInfo
    elseif battleLabel == GameVars.battleLabels.guildGve then
        battleInfo.battleParams = {
            monsterInfo = {
                monsterId = 10078,
            }
        }
    elseif battleLabel == GameVars.battleLabels.missionMonkeyPve then
        battleInfo.battleParams = {id = "100"}
    elseif battleLabel == GameVars.battleLabels.missionMonkeyPve then
        battleInfo.battleParams = {endlessId = 1}
    end

    battleInfo.isDebug = true
    -- dump(battleInfo)
    BattleControler:startBattleInfo(battleInfo)

    -- BattleControler:onExitBattle(  )
    -- IS_IGNORE_LOG = false

     local keyArrEnd = Tool:getGlobalKey( )
     local arr  = Tool:compareKey( keyArrEnd,keyArrbefore )
     for i,v in pairs(arr) do
         print(i,v,"_addkey")
     end

     collectgarbage("collect")
    local other = collectgarbage("count")
    BattleDebug(os.clock() - ti .."_runIndex:"..index.."_memory,s:"..start.."_e:"..other..",add:",other-start)
    -- local keyArr = 
end 
function Window_test:logsGame( )
    GameLuaLoader:loadGameBattleInit()
    local btInfo = GameStatistics:getLogsBattleInfo("bt_2018_8_1_17_33_13_dev_310_log")
    WindowControler:globalDelayCall(function ()
        local bInfo = BattleControler:turnServerDataToBattleInfo(btInfo)
        BattleControler:startBattleInfo(bInfo)
    end,0.5)
end

-- 战斗测试
function Window_test:enterGame(t,battleLabel)
    GameLuaLoader:loadGameBattleInit()
    
    

    for i=1,1 do
        WindowControler:globalDelayCall(c_func(sureEnterGame,t,battleLabel,i,"测试关卡"), i*0.5)
    end


   -- 
    --一下注释掉的是PVP测试
    --battleInfo.battleLabel = GameVars.battleLabels.pvp          --竞技场类型的
    --BattleControler:startPVP(battleInfo)

end

-- 测试所有关卡战斗
function Window_test:battleConfirm()
    -- IS_SISSION_MAPPING
    -- 做一个关卡的分类
    --[[
        1w 开头的 主线
        2w 开头的 精英关卡
        3k 开头的 试炼
        50000-50999 共享副本
        51000-51999 情缘关卡
        52000-52999 仙盟GVE
        60000-69999 六界轶事
        80000-90000 锁妖塔配置
    ]]

    Fight.isDummy = true -- 纯逻辑
    Fight.escape_damage = 0 -- 无敌
    Fight.all_high_hp = false --高血量

    IS_IGNORE_LOG = true -- 关log

    local function getTestLabel(levelId)
        local nLevelId = tonumber(levelId)

        if not nLevelId then return end

        local function inSection(a, b)
            return nLevelId >= a and nLevelId < b
        end

        if inSection(10000,19999) then
            return {"六界主线",GameVars.battleLabels.worldPve}
        elseif inSection(20000, 29999) then
            return {"精英关卡",GameVars.battleLabels.worldPve}
        elseif inSection(50000, 50999) then
            return {"共享副本",GameVars.battleLabels.shareBossPve}
        elseif inSection(51000,51999) then
            return {"情缘关卡",GameVars.battleLabels.lovePve}
        elseif inSection(52000,52999) then
            return {"仙盟GVE",GameVars.battleLabels.guildGve}
        elseif inSection(60000,60199) then
            return {"六界轶事-夺宝",GameVars.battleLabels.missionMonkeyPve}
        elseif inSection(60200,60299) then
            return {"六界轶事-比武",GameVars.battleLabels.missionBattlePve}
        elseif inSection(80000,89999) then
            return {"锁妖塔关卡",GameVars.battleLabels.towerPve}
        elseif inSection(54000,54999) then
            return {"无底深渊",GameVars.battleLabels.endlessPve}
        end
    end

    -- 根据标签存
    local levelGroup = {}
    local levelCfg = require("level.Level")
    for levelId,data in pairs(levelCfg) do
        local info = getTestLabel(levelId)
        if info then
            if not levelGroup[info[2]] then 
                levelGroup[info[2]] = {}
            end
            table.insert(levelGroup[info[2]], {levelId = levelId, des = info[1]})
        end
    end

    -- 需要跑的战斗类型
    local confirmLabel = {
        -- GameVars.battleLabels.worldPve,
        -- GameVars.battleLabels.shareBossPve,
        -- GameVars.battleLabels.lovePve,
        -- GameVars.battleLabels.guildGve,
        -- GameVars.battleLabels.missionMonkeyPve,
        -- GameVars.battleLabels.missionBattlePve,
        -- GameVars.battleLabels.towerPve,
        GameVars.battleLabels.endlessPve,
    }
    -- local myCache = Window_test:getCacheOriginTable()

    -- 使用延迟的方式
    local count = 0
    for _,label in ipairs(confirmLabel) do
        if levelGroup[label] then
            for _,info in ipairs(levelGroup[label]) do
                local des = string.format("%s:%s",info.des,info.levelId)
                WindowControler:globalDelayCall(c_func(sureEnterGame,info.levelId,label,count,des), count*0.1)
                count = count + 1
            end
        end
    end

    --[[
    WindowControler:globalDelayCall(function()
                print("比较表的变化")
                for k,v in pairs(myCache) do
                    local t = require(k)
                    Tool:deepCompareT(v,t,k)
                end
            end, count*0.1)
    ]]

    -- local count = 0
    -- -- 使用尾调用方式
    -- for _,label in ipairs(confirmLabel) do
    --     if levelGroup[label] then
    --         local maxIndex = #levelGroup[label]

    --         local function doBattleConfirm(index)
    --             if index <= maxIndex then
    --                 local info = levelGroup[label][index]
    --                 local des = string.format("%s:%s",info.des,info.levelId)
    --                 sureEnterGame(info.levelId, GameVars.battleLabels.worldPve, index, des)
    --                 index = index + 1
    --                 count = count + 1
    --                 return doBattleConfirm(index)
    --             end
    --         end

    --         doBattleConfirm(1)
    --     end
    -- end
end

function Window_test:enterTestRever( t,battleLabel )



    GameLuaLoader:loadGameBattleInit()
    Fight.cameraWay = Fight.cameraWay * (-1)
    UserModel:init({level =1})
    local battleInfo = { }
    battleInfo.battleUsers = { }
    local defaultHero = ObjectCommon:getServerData()
    for i = 1, #defaultHero do
        table.insert(battleInfo.battleUsers, defaultHero[i])
    end
    battleInfo.levelId = t
    --这是pve
    battleInfo.battleLabel =  battleLabel or GameVars.battleLabels.worldPve  --GameVars.battleLabels.worldPve
    BattleControler:startBattleInfo(battleInfo)
end




--[[
删除多余spine文件

local flaArr = {
        "TreaGiveOut","eff_buff_bing","eff_buff_gongjili","eff_buff_jiafanghudun",
        "eff_buff_jiafangyuli","eff_buff_jianfang","eff_buff_xuanyun",
        }
    self._textureFlaArr = clone(flaArr)

    local spineArr = {
        "eff_treasure0"
        }

]]
function Window_test:checkDelSpine(  )

    local ignoreSpineArr = 
    {
        eff_treasure0 = true,
        eff_huihetishi = true,
    }
    local ignoreFlaArr = 
    {
         TreaGiveOut = true,
         treasure0=true,
         eff_buff_bing=true,
         eff_buff_gongjili=true,
         eff_buff_jiafanghudun=true,
         eff_buff_jiafangyuli = true,
         eff_buff_jianfang = true,
         eff_buff_xuanyun=true

    }

    require("lfs")
    local path=lfs.currentdir()
    -- E:\heracles\svn\tempFiles\roundDemo\Resources
    local svnPath = path.."/../"
    echo(svnPath)
    local targetPath1 = svnPath.."Assets/anim/spine/sourceSvn/"
    local targetPath2 = svnPath.."Resources/asset/anim/spine/"
    local flatargetpath1 = svnPath.."Assets/anim/armature/zipSvn/"
    local flatargetpath2 = svnPath.."tempFiles/roundDemo/Resources/asset/anim/armature/"
    
    local sourceCfg = require("level.Source")
    -- echo("sourceCfg---------")
    -- dump(sourceCfg)
    -- echo("sourceCfg---------")
    --当前使用的文件
    local existSpine ={}
    for k,v in pairs(sourceCfg) do
        if v.spine and v.spine ~= "0" then
            existSpine[v.spine] = true
        end
        --dump(v.effSpine)
        --echoError('aaa')
        if v.effSpine and v.effSpine ~="0" then
            for kk,vv in pairs(v.effSpine) do
                existSpine[vv] = true
            end
        end
        if v.spineFormale and v.spineFormale ~="0" then
            existSpine[v.spineFormale] = true
        end
    end
    dump(existSpine,"__existSpine")
    --"C:\Users\playcrab\Desktop\sourceFile.txt"
    -- local f = assert( io.open("C:/Users/playcrab/Desktop/sourceFile.txt", 'a') )
    -- f:write("spine文件\n")
    -- for k,v in pairs(existSpine) do
    --     f:write(k.."\n")
    -- end
    -- f:close()
    --获取所有当前存在的文件
    local allFiles = {}
    for file in lfs.dir(targetPath2) do 
        if file ~= "." and file ~= ".." then
            local idx = file:match(".+()%.%w+$")  
            local fileWithOutExten = string.sub(file,1,idx-1)
            allFiles[fileWithOutExten] = true
        end
    end 

    local excludeArr = {
        "UI_","art_","plot_","_wenzi","_jingtou","world_","_dazhaowenzi",
        "eff_treasure0","eff_huihetishi","eff_liujie",
        "eff_mannuqi","eff_chenmo",
        "common_plotTex","Extract"
    }

    --当前要删除的文件数组
    local willDel = {}
    for k,v in pairs(allFiles) do
        -- echo(string.find(k, "ui_"),"--")
        -- echo(string.find(k,"art_"),"---")
        --art_
        if existSpine[k] ~= true    then
            local isIgnore = false
            for i,v in ipairs(excludeArr) do
                if string.find(k,v) then
                    isIgnore = true
                end
            end

            if not isIgnore then
                willDel[k] = true
            end
            
        end
    end
    -- echo("要删除的文件数组")
    -- dump(willDel)
    -- echo("要删除的文件数组")

    --删除targetpath2中的数据
    echoWarn("不使用的资源文件")
    for file in lfs.dir(targetPath2) do 
        if file ~= "." and file ~= ".." then
            local idx = file:match(".+()%.%w+$")  
            local fileWithOutExten = string.sub(file,1,idx-1)
            
            if willDel[fileWithOutExten] == true then
                --echo("删除文件",targetPath2..file)
                echo(targetPath2..file)
                --os.remove(targetPath2..file)
            end
        end
    end
    --删除 targetPath1中的目录
    -- for file in lfs.dir(targetPath1) do 
    --     if file ~= "." and file ~= ".." then
    --         local idx = file:match(".+()%.%w+$")  
    --         local fileWithOutExten = string.sub(file,1,idx-1)
    --         if willDel[fileWithOutExten] == true then
    --             echo("删除文件",targetPath2..file)
    --             os.remove(targetPath2..file)
    --         end
    --     end
    -- end

    local existFlas = {}
    for k,v in pairs(sourceCfg) do
        if v.fla and v.fla ~= "0" then
            for kk,vv in pairs(v.fla) do
                existFlas[vv] = true    
            end
        end
    end
    local allFlaFils = {}
    for file in lfs.dir(flatargetpath2) do 
        if file ~= "." and file ~= ".." then
            local idx = file:match(".+()%.%w+$")  
            local fileWithOutExten = string.sub(file,1,idx-1)
            allFlaFils[fileWithOutExten] = true
        end
    end

    local flaWillDel = {}
    for k,v in pairs(allFlaFils) do
        if existFlas[k] ~= true 
            and string.find(k, "UI_") ~= 1 
            and string.find(k,"common") ~=1 
            and string.find(k,"a3") ~=1 
            and string.find(k,"map_")~=1
            and ignoreFlaArr[k] ~= true
            --and string.find(k,"eff_treasure0")~=1  
        then
            flaWillDel[k] = true
        end
    end

    --删除flatargetpath1对应的文件
    -- for file in lfs.dir(flatargetpath1) do 
    --     if file ~= "." and file ~= ".." then
    --         local idx = file:match(".+()%.%w+$")  
    --         local fileWithOutExten = string.sub(file,1,idx-1)
    --         if flaWillDel[fileWithOutExten] == true then
    --             echo("删除fla文件",targetPath2..file)
    --             os.remove(targetPath2..file)
    --         end
    --     end
    -- end
    --echo("删除 ",flatargetpath2,"目录下的文件------")
    --删除flatargetpath2对应的文件
    for file in lfs.dir(flatargetpath2) do 
        if file ~= "." and file ~= ".." then
            local idx = file:match(".+()%.%w+$")  
            local fileWithOutExten = string.sub(file,1,idx-1)
            if flaWillDel[fileWithOutExten] == true then
                echo("删除fla文件",flatargetpath2..file)
                os.remove(flatargetpath2..file)
            end
        end
    end


end





function Window_test:pt()
   self._sp:gotoAndPlay(20);
end 

---道具表里的获取途径配对
function Window_test:daojupipeianniu()
    local  itemData = require("items.Item")
    local  lotteryData = require("lottery.Lottery")
    local  findtype = 201    
    -- dump(lotteryData[tostring(1101)].reward[1])

    -- dump(itemData)
    local data = {}
    for k,v in pairs(itemData) do
        local serverfile = false
        if v.accessWay ~= nil then
            for _k,_v in pairs(v.accessWay) do
                local itemtable = {}
                local itemID = tonumber(k)   --道具表的道具ID
                local number = tonumber(_v)
                if number == findtype then
                    for key,valuer in pairs(lotteryData) do
                        for __k,__v in pairs(valuer.reward) do
                            local rewards = string.split(__v, ",");
                            local lotteryrewarditemID = tonumber(rewards[3]) --奖池道具ID
                            -- print("======抽卡奖池ID=========",lotteryrewarditemID)
                            if lotteryrewarditemID == itemID then
                                -- print("======存在奖池表里====道具ID===抽卡奖池ID==",k,key)
                                serverfile = true
                                break
                            end
                        end
                    end
                    if serverfile == false then
                        -- print("======道具不存在奖池表里====道具ID====",k)
                        -- table.insert(data,k)
                        local itemname = itemData[tostring(k)].name 
                        local name = GameConfig.getLanguage(itemname)
                        data[k] = name
                    end
                end
            end
        end
    end
    -- table.sort(data) 
    dump(data,"以下道具不存在奖池表里")
    local index = 0
    for k,v in pairs(data) do
        index = index + 1
    end
    print("===============总数量=============",index)
end

function Window_test:testMap(  )

    --是否是锁定主角的
    local isLockChar = true






    --背景scale
    local bgScale = 1
    --角色scale
    local charScale =1

    self.dragNode = display.newNode():addto(self)


    local sp = display.newSprite("test/mapTest.jpg"):addto(self.dragNode) 

    --设置
    sp:setScale(bgScale)

    local focusPos = {x= 0, y = 0}

    local clickNode = display.newNode():addTo(self)
    clickNode:setContentSize(cc.size(4000,4000))


    local wayToAction = {
        {"nan_zhengce",-1},
        {"nan_zheng",1},
        {"nan_zhengce",1},
        
        {"nan_houce",-1},
        {"nan_bei",1},
        
        {"nan_houce",1},

    }

    local playerInitPos = {x=200,y = 200}

    local playerSpine = ViewSpine.new("story_nan") :addto(self.dragNode,2)--FuncChar.getSpineAni( "101", 1):addto(self.dragNode,2)
    playerSpine:pos(playerInitPos.x,playerInitPos.y)
    playerSpine:playLabel(wayToAction[1][1])
    playerSpine:setScale(charScale)
    local downPos = {x=0,y = 0}

    local pressDown  = function ( event )
        if isLockChar  then
            return
        end
        local x,y = self.dragNode:getPosition()
        downPos.x = event.x - x
        downPos.y = event.y - y
    end


    local pressMove = function (event  )
        if isLockChar  then
            return
        end
        self.dragNode:pos(event.x - downPos.x,event.y- downPos.y )
    end



    --点击角色
    local pressClick = function (event  )
        
        --
        --转化成相对坐标
        --转化成相对坐标
        playerSpine:stopAllActions()
        local targetPos = self.dragNode:convertToNodeSpace(event)
        local x,y = playerSpine:getPosition()
        local dx = targetPos.x - x
        local dy = targetPos.y - y
        local dis = math.sqrt(dx*dx+dy*dy)
        local speed = 20
        local action = "run"
        if dis < 200 then
            speed = 15
            action = "walk"
        elseif dis > 800 then
            speed = 30
        end

        --8个方位 对应动作和scale
        local ang = math.atan2(dy,dx) * 180/math.pi +180
        
        local index = math.ceil(ang / 60 )
        echo(ang,"_____ang",index,ang - 180)
        if index > #wayToAction then
            index = #wayToAction
        end
        if index < 1 then
            index = 1
        end
        action = wayToAction[index][1]
        local scaleX = wayToAction[index][2]


        local frame = dis / speed
        -- playerSpine:moveTo(frame/30, targetPos.x, targetPos.y)
        playerSpine:setScaleX(scaleX * charScale)
        local act_move = act.moveto(frame/40, targetPos.x, targetPos.y)
        playerSpine:playLabel(action)
        playerSpine:runAction(act_move)


    end

    local focusPos = {x = playerInitPos.x , y = playerInitPos.y}

    --是否跟随屏幕运动
    local updateScreen = function (  )
        if not isLockChar then
            return
        end
        local x1,y1 = playerSpine:getPosition()
        x1 = GameVars.width /2 - x1
        y1 = GameVars.height /2 - y1

        local x2,y2 = self.dragNode:getPosition()

        local dx = x1 - x2
        local dy = y1 - y2
        local ang = math.atan2(dy, dx)
        --缓动运动过去
        local dis =math.sqrt( dx*dx+ dy*dy )
        local minSpeed = 15
        local speed = dis * 0.1
        if speed > 30 then
            speed = 30
        end
        if speed < 15 then
            x2 = x1
            y2 = y1
        else
            x2 = x2 + speed*math.cos(ang)
            y2 = y2 +speed*math.sin(ang)
        end
        self.dragNode:pos(x2,y2)

    end

     self.dragNode:scheduleUpdateWithPriorityLua(updateScreen,0)



    clickNode:setTouchedFunc(pressClick, nil, true, pressDown, pressMove,false,onGloadEnd)

    local lockScreen =function (  )
        isLockChar = not isLockChar
    end

    local btn = self:creatBtns("锁屏", lockScreen)
    btn:pos(50,80)
    btn:parent(self)

end






function Window_test:testMap2(  )

    --是否是锁定主角的
    local isLockChar = true


    --背景scale
    local bgScale = 1
    --角色scale
    local charScale =1

    self.dragNode = display.newNode():addto(self)

    --在这个node上放10个



    local sp = display.newSprite("test/mapTest.jpg"):addto(self.dragNode) 

    --设置
    sp:setScale(bgScale)

    local focusPos = {x= 0, y = 0}

    local clickNode = display.newNode():addTo(self)
    clickNode:setContentSize(cc.size(4000,4000))



    local playerInitPos = {x=200,y = 200}

    local playerModel = require("game.sys.view.world.char.WorldMoveModel").new()

    local playerSpine = ViewSpine.new("story_nv") --FuncChar.getSpineAni( "101", 1):addto(self.dragNode,2)
    playerSpine:zorder(2)
    playerModel:initView(self.dragNode,playerSpine,playerInitPos.x,playerInitPos.y,0)
  
    playerModel:setViewScale(charScale)

    local downPos = {x=0,y = 0}

    local pressDown  = function ( event )
        if isLockChar  then
            return
        end
        local x,y = self.dragNode:getPosition()
        downPos.x = event.x - x
        downPos.y = event.y - y
    end


    local pressMove = function (event  )
        if isLockChar  then
            return
        end
        self.dragNode:pos(event.x - downPos.x,event.y- downPos.y )
    end



    --点击角色
    local pressClick = function (event  )
        
        --
        --转化成相对坐标
        local targetPos = self.dragNode:convertToNodeSpace(event)
        local x,y = playerModel.pos.x,playerModel.pos.y
        local dx = targetPos.x - x
        local dy = targetPos.y - y
        local dis = math.sqrt(dx*dx+dy*dy)
        local speed = 20
        if dis < 200 then
            speed = 15
        elseif dis > 800 then
            speed = 30
        end

        targetPos.speed = speed

        playerModel:moveToPoint(targetPos)

    end

    local focusPos = {x = playerInitPos.x , y = playerInitPos.y}

    --是否跟随屏幕运动
    local updateScreen = function (  )
        playerModel:updateFrame()

        if not isLockChar then
            return
        end
        local x1,y1 = playerModel.pos.x,playerModel.pos.y
        x1 = GameVars.width /2 - x1
        y1 = GameVars.height /2 - y1

        local x2,y2 = self.dragNode:getPosition()

        local dx = x1 - x2
        local dy = y1 - y2
        local ang = math.atan2(dy, dx)
        --缓动运动过去
        local dis =math.sqrt( dx*dx+ dy*dy )
        local minSpeed = 15
        local speed = dis * 0.1
        if speed > 30 then
            speed = 30
        end
        if speed < 15 then
            x2 = x1
            y2 = y1
        else
            x2 = x2 + speed*math.cos(ang)
            y2 = y2 +speed*math.sin(ang)
        end
        self.dragNode:pos(x2,y2)

    end

    self.dragNode:scheduleUpdateWithPriorityLua(updateScreen,0)



    clickNode:setTouchedFunc(pressClick, nil, true, pressDown, pressMove,false,onGloadEnd)

    local lockScreen =function (  )
        isLockChar = not isLockChar
    end

    local btn = self:creatBtns("锁屏", lockScreen)
    btn:pos(50,80)
    btn:parent(self)

end


function Window_test:yuekatequan(  )
    WindowControler:showWindow("MonthCardMainView")
end
function Window_test:yuekashangcheng()
    WindowControler:showWindow("MallMainView")
end

--[[
战斗动画
]]
function Window_test:animDialogTest( animId )
    local callBack = function()
        echoError("回调======================")
    end
    local dialog = AnimDialogControl:showPlotDialog(animId, c_func(callBack))
    
    -- WindowControler:showWindow("MonthCardMainView")
end
--剧情对话
function Window_test:plotDialog(plotId) 
    self.dialog = require("game.sys.controler.PlotDialogControl")
    self.dialog:init() 
    function _callback(ud)
        -- ud{ step,index }
        --print("click---" .. ud.index .. "step..."..ud.step)
    end 
    self.dialog:showPlotDialog(plotId, _callback);

    -- WindowControler:showWindow("MallMainView")
end 

--[[
神器界面
]]
function Window_test:shenqiTest(  ) 
    WindowControler:showWindow("ArtifactMainView")

end

--[[
缘伴界面
]]
function Window_test:yuanbanTest(  )
    local callBack = function()
        echoError("回调======================")
    end
    -- local aa = string.split2d("plot,10202003,7#plot,10202003,7"  ,"#",",")
    -- dump(aa, "==============")
    -- local dialog = AnimDialogControl:showPlotDialog(106031, c_func(callBack))

    
    -- WindowControler:showWindow("AmigoView")
    -- WindowControler:showWindow("AwakenView",103)

end
--[[
战斗动画
]]
function Window_test:fuliText(  )
    local callBack = function()
        echoError("回调======================")
    end
    -- local aa = string.split2d("plot,10202003,7#plot,10202003,7"  ,"#",",")
    -- dump(aa, "==============")
    -- local dialog = AnimDialogControl:showPlotDialog(106031, c_func(callBack))


    
    WindowControler:showWindow("CompChongZhiShowUI")
    -- WindowControler:showWindow("WelfareActFouView")
    -- WindowControler:showWindow("AwakenView",103)
    -- aa = UserModel:getTowerFloor()
    -- echo(aa,"========")
end
function Window_test:animDialogCheck( animId )
    FuncPlot.yijianchacuo( tostring(animId) )
end


--测试代码
    function Window_test:resetPrologue()
    -- PrologueUtils:resetPrologue()
    -- TutorialManager:resetPologueTurtoailStep()
    -- local sp = ViewSpine.new("eff_30014_linyueru"):addto(self)
    -- sp:playLabel("eff_30014_linyueru_attack2")
    require("utils.PosMapTools")
    PosMapTools:init()
    local nd = display.newNode():addto(self):pos(100,GameVars.height-100)
    local gridArr = {}
    for i=2,10,2 do
        for j=1,5,2 do
            local sp = display.newSprite("test/aaa1.png"):addto(nd)
            local pos = PosMapTools:getGridPos(i,j)
            sp:pos(pos.x,pos.y)
            table.insert(gridArr, {x = i,y = j,view = sp})
            local sp = display.newSprite("test/aaa1.png"):addto(nd)
            local pos = PosMapTools:getGridPos(i+1,j+1)
            sp:pos(pos.x,pos.y)
            table.insert(gridArr, {x = i+1,y = j+1,view = sp})
        end

    end

    local tempFunc = function (e  )
        local pos = nd:convertToNodeSpaceAR(e)
        local targetGrid = PosMapTools:getGridPosByWordPos( pos,gridArr )
        if self.lastGrid then
            self.lastGrid.view:setScale(1)
        end
        if targetGrid then
            echo(targetGrid.x,targetGrid.y,"__当前在 这个各自")
            targetGrid.view:setScale(1.2)
        else
            echo("_没有选中各自")
        end
        self.lastGrid = targetGrid
    end

    nd:setTouchedFunc(tempFunc, nil, true)

end

function Window_test:skipPrologue()
    PrologueUtils:skipPrologue()
    -- LoginControler:restarGame()
end

function Window_test:tutorialTest()
    local tutorialManager = TutorialManager.getInstance();
    IS_OPEN_TURORIAL = true;
    if tutorialManager:isAllFinish() == false then 
        tutorialManager:startWork(self);
    end 
end


function Window_test:checkLoginOk()
    if not LoginControler:isLogin() then
        WindowControler:showTips( { text = "请先登入游戏在执行此操作" })
        return false
    end
    return true
end

-- 背包测试
function Window_test:itemTest()
    if not self:checkLoginOk() then return end
    WindowControler:showWindow("ItemListView")
end

function Window_test:roleTest()
    -- WindowControler:showWindow("SelectRoleView") 
    -- WindowControler:showWindow("VoiceDemoView") 
    -- WindowControler:showWindow("GuildInFoView") 
    GuildControler:getMemberList(1)
end

function Window_test:chatTest()
    echo("聊天测试")
    WindowControler:showWindow("MissionQuestView")
end
-- 查找不显示字符
function Window_test.chazhaobuxianshizifu( )
    FuncTranslate._checkNoFoundText()
end
-- 五行阵设置
function Window_test:formationSet( )
    WindowControler:showWindow("DebugFormationView")
end
function Window_test:towerTest(  )
    local callBack = function( event )
        echo("----------- 锁妖塔数据 ------------------")
        if event.result then
            TowerMainModel:updateData(event.result.data)
            WindowControler:showWindow("TowerMapView")
            -- WindowControler:showWindow("WorldMainView")
        end
    end

    TowerServer:getMapData(c_func(callBack))
end

function Window_test:loadingTest()
    local loadingNumber = NewLoadingControler:getLoadingNumberByTypeAndLevelId("pve", 10101)
    dump(loadingNumber, "\n\nloadingNumber===")
    WindowControler:showWindow("CompNewLoading", loadingNumber)
end

function Window_test:guildActivity()
end
function Window_test:newLovePropertyEntrance()
    -- local resultArr = RandomControl.getIndexGroupByGroup( {{"72001",0.4},{"23",0.4},{"444",0.2}},2)
    -- local coin = {}
    -- for i=1,10000000 do
    --     local resultArr = RandomControl.getIndexGroupByGroup({"0.7","0.1","0.1","0.1"},1)
    --     -- dump(resultArr, "resultArr", nesting)
    --     for k,v in pairs(resultArr) do
    --         if not coin[v] then
    --             coin[v] = 0 
    --         end
    --         coin[v] = coin[v] + 1
    --     end
    -- end
    -- dump(coin, "coin", nesting)
    ActConditionModel:openWanderMerchantView()
end

function Window_test:guildActivityChallenge()

end
function Window_test:newLovePropertyLighten()
    WindowControler:showWindow("EliteGearView","1803","EliteOrgan1") 
    -- echo("__ 1,1__",FuncNewLove.getLastCellId( 1,1 ))
    -- echo("__ 1,9__",FuncNewLove.getLastCellId( 1,9 ))
    -- echo("__ 1,10__",FuncNewLove.getLastCellId( 1,10 ))
    -- echo("__ 2,1__",FuncNewLove.getLastCellId( 2,1 ))
    -- echo("__ 2,11__",FuncNewLove.getLastCellId( 2,11 ))
    -- echo("__ 4,0__",FuncNewLove.getLastCellId( 4,0 ))
    -- echo("__ 4,1__",FuncNewLove.getLastCellId( 4,1 ))
    -- echo("__ 0,0__",FuncNewLove.getLastCellId( 0,0 ))

    -- local _foodId = "1"
    -- local _materialArr = {
    --     ["1"] = 760, --1
    --     ["7"] = 200, --2
    --     ["10"] = 300, --3
    --     ["11"] = 100, --2
    --     ["6"] = 200, --2
    -- }

    --     local _materialArr2 = {
    --     ["1"] = 1760, --1
    --     ["7"] = 200, --2
    --     ["10"] = 300, --3
    --     ["11"] = 100, --2
    --     ["6"] = 200, --2
    -- }
    -- FuncGuildActivity.getFoodStar( _foodId,_materialArr )
    -- FuncGuildActivity.getFoodStar( _foodId,_materialArr2 )
    -- GuildActMainModel:getFoodStar()
    -- GuildActMainModel:showScoreNum( 3456 )
    -- local couin = NewLoveModel:getActivateLoveNum( )
    -- echo("dddddd ",couin)
    -- local params = {
    --     guildId = "self._guildId",
    --     teamId = "self._myTeamId"
    -- }
    -- GuildControler:showTowerMainView()
    -- WindowControler:showWindow("GuildActivityTeamInviteView")
    -- WindowControler:showWindow("NewLoveGlobalPropertyLightenView")

    -- GuildActMainModel:getMonsterList( )

     -- GuildActMainModel:getComboScore( "200112",3 )
     -- GuildActMainModel:getComboScore( "200112",5 )
     -- GuildActMainModel:getComboScore( "200112",9 )
     -- local frameCount = 0
     -- local monsterNum = 20
     -- self.dragNode11 = display.newNode():addto(self)
    -- self.downTimeNode = display.newNode():addto(self)
    -- local function updateFrame()
        -- echo("_____________ ")
        -- if monsterNum < 1 then
        --     self.downTimeNode:unscheduleUpdate()
        --     return
        -- end
        -- if (frameCount % 5 == 0) then
        --     local gridIdx = tostring(monsterNum)
        --     echo("__________ CCCC测试 ——————————",monsterNum)
        --     monsterNum = monsterNum - 1
        -- end
        -- frameCount = frameCount + 1
    -- end
    -- self.downTimeNode:scheduleUpdateWithPriorityLua(c_func(updateFrame), 0)

    -- WindowControler:showWindow("GuildActivityAccumulateRewardView")
end

function Window_test:teamTest()
    LS:prv():set(StorageCode.all_team_formation,"")
end
function Window_test:enterTerrainEditor( )
    WindowControler:chgScene("TerrainEditorScene");
end

function Window_test:getBattleLog()
    local inputtxt = UIBaseDef:createPublicComponent( "UI_debug_public","input_1" )
    inputtxt:pos(GameVars.width / 2,GameVars.height / 2)
    inputtxt:addto(self)
    inputtxt:setText("输入battleId")

    local view = UIBaseDef:createPublicComponent( "UI_debug_public","panel_bt" )
    view:pos(GameVars.width / 2,GameVars.height / 2 - 50)
    view.txt_1:setString("点击请求")
    view:addto(self)

    view:setTouchedFunc(function()
        local battleId = inputtxt:getText()
        if not self:checkLoginOk() then 
            echoError("先登录")
            return
        end
        if not tonumber(battleId) then 
            echoError("Id不合法")
            return
        end

        self:clear()
        
        Server:sendRequest({battleId = battleId},MethodCode.test_get_battleInfo_5099,function ( data )
            -- echoError("1")
            -- dump(data)
            local battleData = {}
            local battleResultSingle = data.result.data.battleResultSingle

            battleData.battleId = battleResultSingle._id
            -- 缺少数据证明没取到战报，报错返回
            if not battleResultSingle.seed then
                echoError("没有取到战报",battleResultSingle._id)
                return
            end
            battleData.randomSeed = battleResultSingle.seed
            battleData.battleUsers = json.decode(battleResultSingle.battleUsersStr)
            battleData.battleParams = json.decode(battleResultSingle.battleParamsStr)
            battleData.battleLabel = battleResultSingle.battleLabel
            battleData.operation = json.decode(battleResultSingle.operation)

            -- 这个数据是自己加入的为了存一下服务器计算的结果
            battleData.serverRST = {
                rt = battleResultSingle.rt,
                restartIdx = battleResultSingle.restartIdx,
                version = battleResultSingle.version,
            }

            local saveName = string.format("logget_%s_%s.txt",battleId,UserModel:rid())
            local logsFileName = GameStatistics:getLogsFullPath() .. saveName
            local targetFile, errorMsg = io.open(logsFileName, "a")
            targetFile:write(json.encode(battleData))
            targetFile:close()

            WindowControler:showTips( { text = "已经保存文件名:" .. saveName })
        end)
    end)
end

-- 获取缓存的所有table
function Window_test:getCacheOriginTable()
    local tempT = {}
    for k,v in pairs(package.loaded) do
        local pos = string.find(k, "battle.") or string.find(k, "level.") or string.find(k, "partner.") or string.find(k, "cimelia.") or string.find(k, "char.")

        if pos == 1 then
            tempT[#tempT + 1] = k
        end
    end

    dump(tempT,"表名")

    local ORIGINT = {}
    for _,v in ipairs(tempT) do
        ORIGINT[v] = table.deepCopy(require(v))
    end

    return ORIGINT
end

-- spine换武器测试
function Window_test:spineChangeWeapon()
    for _,children in pairs(self._root:getChildren()) do
        children:visible(false)
    end

    -- 列表
    local p = {
        '30005_lixiaoyao',
        '30006_caiyi',
        '30047_longyou',
        '30004_zhaolinger',
        '30007_murongziying',
        '30014_linyueru',
        'treasure_a1',
        'treasure_b1',
        '30009_yuntianhe',
        '30012_jingtian',
        '30016_tangyurou',
        '30017_xuchangqing',
        '30018_zixuan',
        '30019_xiaoman',
        '30021_jiangyunfan',
        '30022_lankui',
        '30023_xingxuan',
        '30028_xiahoujinxuan',
        '30031_liyiru',
        '30051_lingbo',
    }
    
    local row = 5
    -- local colum = 4
    local hspace = 250 -- 水平间距
    local vspace = 170 -- 竖直间距
    local scale = 1 -- 缩放

    local allSp = {}
    local function allSpIt()
        local count = 0
        return function()
            count = count + 1
            if count > #allSp then
                return nil
            end

            return allSp[count]
        end
    end
    local function createSp(name, num)
        num = num or 10
        for i=1,num do
           local spine = ViewSpine.new(name, {}, "", name)
           spine:playLabel("stand")
           self._root:addChild(spine)

           allSp[#allSp + 1] = spine

           local r = #allSp % row
           local c = math.floor((#allSp - 1) / row)

           spine:pos(r * hspace + 150, c * vspace + 100)
           spine:scale(scale)
           spine.name = name
        end
    end

    local count = 1
    local t = {
        "stand","attack2","attack3","standWeek","run"
    }

    local function cbtn(text, pos, func)
        local btn1 = display.newNode():addto(self._root):anchor(0,0)
        btn1:setPosition(pos)
        btn1:zorder(500)
        btn1:size(130,50)

        display.newRect(cc.rect(0, 0,130, 50),
            {fillColor = cc.c4f(1,1,1,0.8), borderColor = cc.c4f(0,1,0,1), borderWidth = 1}):addto(btn1)
        display.newTTFLabel({text = text, size = 20, color = cc.c3b(255,0,0),font="ttf/"..GameVars.fontName})
                :align(display.CENTER, btn1:getContentSize().width/2, btn1:getContentSize().height/2)
                :addTo(btn1):pos(65,25)
        btn1:setTouchedFunc(func,cc.rect(0,0,127,64))
    end

    local partners = {}

    for _,name in ipairs(p) do
        partners[name] = "wp_" .. name .. "_1"
    end

    local btnH = 20
    cbtn("创建人物", cc.p(100, btnH), function ()
        -- createSp("30005_lixiaoyao", 1)
        -- createSp("30006_caiyi", 1)
        -- createSp("30047_longyou", 1)
        for name,wp in pairs(partners) do
            createSp(name, 1)
        end
    end)

    cbtn("删除人物", cc.p(300, btnH), function ()
        for sp in allSpIt() do
            sp:deleteMe()
        end
        allSp = {}
    end)

    local change = false
    cbtn("换武器",cc.p(500,btnH),function()
        for sp in allSpIt() do
            if not change then
                -- sp:changeAttachmentByFrame("wp_30006_caiyi_1")
                -- sp:changeAttachmentByFrame("wp_30047_longyou_1")
                -- sp:setAttachmentChange({
                --     ["li13"] = "weapon",
                -- })
                sp:changeAttachmentByFrame(partners[sp.name])
            else
                sp:resetAttachmentChange()
            end
        end
        change = not change
    end)

    cbtn("动作",cc.p(700,btnH),function()
        count = count % #t + 1
        for sp in allSpIt() do
            sp:playLabel(t[count])
        end
    end)

    cbtn("清理lua内存",cc.p(900,btnH),function()
        collectgarbage("collect")
    end)

    cbtn("回收缓存",cc.p(1100,btnH),function()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    end)
end

function Window_test:enterSkinFirstShowView(partnerId)
    local data = FuncPartnerSkinShow.getDataByParIdAndType(partnerId, "1")
    if data then
        local param = {
            id = partnerId,
            skin = "1",
        }

        WindowControler:showWindow("PartnerSkinFirstShowView", param)
    end
end

function Window_test:enterMiniBattle(showId)
    local scene = WindowControler:getCurrScene()
    local battleRoot = scene:getBattleRoot()
    -- scene:showBattleRoot()

    local controler = MiniBattleControler.getInstance()
    controler:showMiniBattle(showId)    

    -- self._root:setScale(0.5)
end
--[[
    解析序列化的战报
    
    将战报放在logs/encryptedLog 文件夹下，点按钮;
    解析后会以同名文件形式保存在logs/decodedLog下

    如果没有对应文件夹，直接点击按钮会自动创建文件夹
]]
function Window_test:battleDecode()
    local function prePareDir(path)
        if device.platform == "mac" then
            path = AppHelper:getResourcesRoot() ..path
        end

        if not cc.FileUtils:getInstance():isDirectoryExist(path) then 
            cc.FileUtils:getInstance():createDirectory(path)
        end

        return path
    end

    local logPath = prePareDir("/logs/encryptedLog")
    local targetFilePath = prePareDir("/logs/decodedLog")
    local verifyCtrl = verifyControler.new()

    -- 解析
    local function decode(str)
        local t = verifyCtrl:decrypt(str)
        return table.concat(t, "\n"),t
    end

    local function __handPath(path)
        if string.sub(path,-1,-1) ~= '/' then
            return path .. '/'
        end
        return path
    end

    local function manageEncryptedFile( logPath, file )
        local f = logPath .. file
        local encryptedFile =  io.open(f, "rb")
        if encryptedFile then
            local str = encryptedFile:read("*a")
            encryptedFile:close()
            local decodeStr = decode(str)

            decodedFile = __handPath(targetFilePath)

            local be,ed = string.find(file, ".txt")
            if be and ed then
                decodedFile = decodedFile .. string.sub(file,1,be - 1)
            else
                decodedFile = decodedFile .. file
            end

            -- 保存到文件
            local df = io.open(decodedFile .. ".txt","w")
            df:write(decodeStr)
            df:close()
        end
    end

    local function decodeLogIndir(logPath)
        logPath = __handPath(logPath)

        for file in lfs.dir(logPath) do
            if file ~="." and file~= ".." then
                local f = logPath .. file
                local mode = lfs.attributes(f, "mode")
                if mode == "file" then
                    manageEncryptedFile(logPath, file)
                elseif mode == "directory" then
                    decodeLogIndir(f)
                end
            end
            
        end
    end

    decodeLogIndir(logPath)

    WindowControler:showTips( { text = "解析完毕" })
end

return Window_test