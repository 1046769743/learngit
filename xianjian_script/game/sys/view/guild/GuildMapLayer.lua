--guan
--2015.12.13
--主界面中间层
--2017.02.23 干掉npc事件
--2017.03.21 改版

--todo 太多了 拆 怎么拆……

local GuildMapLayer = class("GuildMapLayer", function()
    return display.newLayer()
end)

local gambleNpcPos = 1400;

--todo 读表
local honorNpcPos = 2370;

--最大屏幕
local maxWidth = 3296 ;

local GLOW_TAG = 562;

local playerPosX = GameVars.width * 2;

 

local nameLaberZorder = 1000;

local minY = 0;
local maxY = 200;

local BUILD_CTN = {
    [1] = "ctn_icon_renwudating_1_100",
    [2] = "ctn_icon_zhangfang_100",
    [3] = "ctn_icon_liliange_100",
    [4] = "ctn_icon_xuanguangdian_100",
    [5] = "ctn_icon_renwudating_100",
    [6] = "ctn_icon_hushanjiejie_100",
    [7] = "ctn_icon_liliange_1_100",
}


function GuildMapLayer:ctor(homeView)

    self.curSceneMoveDistance = GameVars.width / 2; 
    self.enterSceneAniDuring = 1.5;
    self.sceneSpeed = (playerPosX - self.curSceneMoveDistance) / (self.enterSceneAniDuring * 45);

    self._homeView = homeView;
    -- self._homeView.panel_entity:setVisible(false);

    -- self._homeView.panel_rongyao:setVisible(false);
    -- self._buildingClone = self._homeView.mc_build;
    -- self._buildingClone:setVisible(false);

    self._isShowEnterAni = true

    --是不是在封一下比较好
    self._isShowOtherPlayer = LS:pub():get(StorageCode.setting_show_player_st, 
        FuncSetting.SWITCH_STATES.OFF) == FuncSetting.SWITCH_STATES.OFF and true or false;

    --自身要 中下对齐  maxWidth  - 920
    local posx = maxWidth  -  1136 - 510
    self:pos(0, -GameVars.UIOffsetY * 2)

    self._mapPosX = 0
    self._diffX = 0;
    self._diffY = 0;

    self._lastMoveEndPos = {x = 0, y = 0};

    --过了多少帧了
    self._totalFrame = 1;

    self._player = nil; 

    self._friendPlayers ={};
    self._friendNameLabels = {};
    self.mapMC_BuildArr = {} --地图上系统按钮数组
    self.buildRedArr = {}
    self._npsSpines = {};

    self._isNpcClick = false;

    self._touchmainview = false

    --主场景npc头上的新开启特效
    self._aniToDisposeArray = {};
    self._mapButtonArray = {}

    self._winSize = {width = GameVars.width ,height =GameVars.height  } 

    -- self:initFunc()

    -- self:initPlayerAndFriend();
    self:addNodeToMap()


    self:initFriend()

    self:clickInit();
    
    -- self:initHonorNpc();

    -- self:createLayerOnTop();

    -- self:initNpcRedPoint();

    -- self:initActivityShowView();

    -- self:ShowToTimeChange()

    self:registerEvent()

    self.firsttime = HomeModel:setUserTimeInLoacl()
    self:notFrameLua()
    -- self:pos(0, -GameVars.UIOffsetY * 2)
    self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self) ,0)
end 

function GuildMapLayer:notFrameLua()
    self._isShowEnterAni = false;
    self._homeView:delayCall(function ( ... )
        EventControler:dispatchEvent(GuildEvent.SHOW_RES_COMING_ANI);
    end, 0.1);
    self._player:setVisible(true);
    local appearAnim = FuncArmature.createArmature("UI_common_juesexiaoshi_juesechuxian" )
        appearAnim:doByLastFrame(true, true, function ()
    end);  
    local x = self._winSize.width

    self._player:birth(x - 150);
    HomeModel.userPos = nil
    self._playerPosX = self._player:getPositionX();
    self._player:setLocalZOrder(-self._player:getPositionY());
    -- local posx = maxWidth  -  1136 - 510
    self._mapPosX = -1500
    self:updateMapPos(-1500, 0);
    self._middleLayer:pos(-670, 0);

end



function GuildMapLayer:registerEvent()
    EventControler:addEventListener(GuildEvent.GET_QIFU_REWARD, self.initbuildRed, self)
    EventControler:addEventListener(GuildEvent.REFRESH_BOUNS_EVENT, self.initbuildRed, self)
    EventControler:addEventListener(GuildEvent.REFRESH_WISH_LIST_EVENT, self.initbuildRed, self)
    EventControler:addEventListener(GuildEvent.GUILD_ACTIVITY_REDPOINT_CHANGED, self.initbuildRed, self)
    EventControler:addEventListener(GuildEvent.REFRESH_GUILD_WOOD_EVENT, self.initbuildRed, self)
    EventControler:addEventListener(GuildEvent.REFRESH_TASK_RED_UI, self.initbuildRed, self)

    EventControler:addEventListener(GuildExploreEvent.GUILDE_EXPLORE_ROKOU_RED_FRESISH, self.initbuildRed, self)
end


function GuildMapLayer:initbuildRed()
    self:isShowBuildRed()
end



---节点加地图map
function GuildMapLayer:addNodeToMap()
    local mapLayer = display.newNode();
    local frontLayer = display.newNode();
    local middleLayer = display.newNode();
    local backLayer = display.newNode();

    mapLayer:setPosition(0, GameVars.UIOffsetY);  --64
    self:addChild(mapLayer);

    self._player = Player.new();
    self._player:setVisible(false);
    middleLayer:setPosition(cc.p(-maxWidth  + GameVars.gameResWidth  , 0));
    middleLayer:addChild(self._player,200);
    -- self._player:setScale(FuncGuild.MinScal)
    mapLayer:addChild(backLayer, 1);
    mapLayer:addChild(middleLayer, 2);
    mapLayer:addChild(frontLayer, 3);
    
    self.map = MapControler.new(backLayer, frontLayer, "map_xianmengzhucheng");
    self:updateMapPos(0,0)

    self._mapLayer = mapLayer;
    self._backLayer = backLayer;
    self._frontLayer = frontLayer;
    self._middleLayer = middleLayer;
    

    self:doingPlayerInFo()
    self:addCtnIcon()
end


---添加背景资源图片
function GuildMapLayer:addCtnIcon()
    local callfun = {
        [1] = c_func(self.taiqingduan, self),
        [2] = c_func(self.maneyroom, self),
        [3] = c_func(self.qifutan, self),
        [4] = c_func(self.xuanGuanDian, self),
        [5] = c_func(self.taskmain, self),
        [6] = c_func(self.hushangjiejie, self),
        [7] = c_func(self.liliangge, self)
    }

    local allbullid = FuncGuild.getguildBuildAllData()
    for k,v in pairs(allbullid) do
        local ctnname = BUILD_CTN[tonumber(k)]
        local ctn = self.map.map[ctnname]
        local imagename = v.buildid
        local image = FuncRes.iconGuild(imagename)
        local buildID = k
        if tonumber(k) == 7 then
            ctn:removeAllChildren()
            ctn = GuildModel:addBuildSpin(ctn)
        else
            -- local sprite = display.newSprite(image)
            -- ctn:addChild(sprite)
        end

        if tonumber(buildID) <= 4 or tonumber(buildID) >= 6 then
            self.buildRedArr[buildID] = GuildModel:addMapTitle(ctn,buildID)
        elseif tonumber(buildID)  == 5 then  --仙盟任务 暂时添加
            self.buildRedArr[buildID] = GuildModel:addMapTitle(ctn,buildID)
        end
        local function onTouchBegan(touch, event)
            self._isNpcClickMove = false;
            self._isNpcClick = true;
            
            -- echo("------self._isNpcClick-----", tostring(self._isNpcClick) );
            return true
        end

        local function onTouchMove(touch, event)
            if GuildMapLayer._isCanScroll == false then
                self._isNpcClickMove = false;
            else   
                self._isNpcClickMove = true
            end 
            self._isNpcClick = true;
        end

        local function onTouchEnded(touch, event)  
            local chk = true
            if chk == true and self._isNpcClickMove == false then  
                --告诉非强制新手，点npc了
                -- EventControler:dispatchEvent(HomeEvent.CLICK_NPC_EVENT, 
                --     {npcKey = funNpcConfig[id].sysName});
                callfun[tonumber(k)]()
            end 
            self._isNpcClick = true;
        end
        ctn:registerBtnEff()
        ctn:setTouchedFunc( onTouchEnded, nil, true,
             onTouchBegan, onTouchMove);
   end
   self:isShowBuildRed()
end

--红点是否显示
function GuildMapLayer:isShowBuildRed()
    local reddata = GuildModel:buildRedData()
    for k,v in pairs(self.buildRedArr) do
        local isShowRed = reddata[tonumber(k)]
        local panel = self.buildRedArr[k] 
        if panel ~= nil then
            if panel.panel_red ~= nil then
                panel.panel_red:setVisible(isShowRed)
            end
        end
    end
end


--处理玩家自身数据
function GuildMapLayer:doingPlayerInFo()
    self._playerPosX = self._player:getPositionX();
    local playerNamePanel = UIBaseDef:cloneOneView(self._homeView.panel_playerTitle);

    self._playerNameLabel = playerNamePanel;
    self._playerNameLabel.txt_name:setString(UserModel:name() or GameConfig.getLanguage("tid_common_2006"));

    local guilddata = GuildModel.MySelfGuildDataList
    local guildType = GuildModel.guildName._type
    local postype = guilddata.right or 4
    local str,spritename   = FuncGuild.byIdAndPosgetName(guildType,postype)
    --仙盟类型
    self._playerNameLabel.txt_gName:setVisible(false)
    playerNamePanel.ctn_1:removeAllChildren()
    local right = FuncRes.iconGuild(spritename)
    local icon = display.newSprite(right)
    icon:setScale(0.6)
    playerNamePanel.ctn_1:addChild(icon)

    self._middleLayer:addChild(playerNamePanel, nameLaberZorder);
end



--点击走路
function GuildMapLayer:clickInit()
    -- local rect = cc.rect(100, minY, 
    --     GameVars.width, GameVars.height - 150 - 120);
    local rect = cc.rect(0, 0, 
        GameVars.width, GameVars.height - 100);

    local moveTouchNode = display.newNode()
    local onPosChangeFunc = function ( moveX,moveY )
        self:moveView(moveX)
    end

    local touchEndCallBack = function (event)  
        self._isMoveNow = false;
        self._isGoOnMove = false;

        local point = self:convertToNodeSpace(event)
        local disX = point.x - self._lastMoveEndPos.x
        EaseMapControler:startEaseMap(moveTouchNode,onPosChangeFunc ,nil,self._lastMoveSpeed or 0,0)
        self._lastMoveSpeed = 0
        -- self._touchmainview = false;
    end

    local touchBeginCallBack = function (event)

        if GuildMapLayer._isCanScroll == false then 
            return false;
        end 

        local touchPoint = event-- touch:getLocation();
        local chk = rectEx.contain(rect, touchPoint.x, touchPoint.y);
        if chk == true then 
            self._isNpcClick = false;
            self._isGoOnMove = true;
            self._isMoveNow = false;
            self._lastMoveEndPos = self:convertToNodeSpace(touchPoint);
            self._lastClickBeginPos = self._lastMoveEndPos;

            local uiPos = self._lastMoveEndPos;
            -- self._homeView:delayCall(function ( ... )
            --     local uiPos = self:convertToNodeSpace(touchPoint);
                local point = self._player:convertToWorldSpace(cc.p(0,0));

                self.cachePos = {x = self._player:getPositionX(),y = self._player:getPositionY()}

                local playerY = self._player:getPositionY();

                self._diffX = uiPos.x - point.x;
               
                local touchY = touchPoint.y;
                if touchY > maxY then 
                    touchY = maxY;
                elseif touchY < minY then  
                    touchY = minY;
                end 

                self._diffY = touchY - point.y;
                -- echo("self._diffY =================",self._diffY)
                self._player:setCurSpeedY(self._diffX, self._diffY);

                if self._diffX ~= 0 then 
                    if self._diffX < 0 then
                        self._player:getShowNode():setRotationSkewY(180);
                    else 
                        self._player:getShowNode():setRotationSkewY(0);
                    end

                    if self._isNpcClick == false then
                        self._player:getShowNode():playLabel("run");
                    end 
                end

            -- end, 2 / GameVars.GAMEFRAMERATE);
            self._isGoOnMove = true;
            EaseMapControler:stopEaseMap()
            return true;
        end 
    end

    local touchMoveCallBack = function (event) 
        -- dump(event,"111111",6)
        local point = self:convertToNodeSpace(event)--touch:getLocation());
        if self._lastClickBeginPos == nil then
            return
        end
        local diffXBetweenMove = self._lastClickBeginPos.x - point.x;

        --滚大于50个像素才算滚
        if diffXBetweenMove > 30 or diffXBetweenMove < -30 then 
            diffXBetweenMove = self._lastMoveEndPos.x - point.x;
            if diffXBetweenMove >= 100 then
                diffXBetweenMove = 45
            end
            self._isGoOnMove = false;
            self._isMoveNow = true;

            self._diffY = 0;
            self._diffX = 0;
            
            self._lastMoveEndPos = {x = point.x, y = point.y};
            self._lastMoveSpeed = diffXBetweenMove
            -- echo("--diffXBetweenMove--", diffXBetweenMove);
            --背景移动
            if diffXBetweenMove > 0 then  --右往左滑动
                diffXBetweenMove = -diffXBetweenMove;
                local targetPosX = self._mapPosX + diffXBetweenMove;

                -- if  self._mapPosX  < 20 then
                --屏幕内才滚
                -- echo("========99999=================",self._mapPosX,targetPosX,-maxWidth + self._winSize.width)
                if targetPosX < self._winSize.width and self._mapPosX  < 0  then 
                    -- self:moveView(-diffXBetweenMove);
                    if  self._mapPosX <= -5 then
                        self:moveView(-diffXBetweenMove);
                    end
                end

            elseif diffXBetweenMove < 0 then --左往右滑
                
                diffXBetweenMove = diffXBetweenMove;
                if diffXBetweenMove <= -100 then
                    diffXBetweenMove = -45
                end
                local targetPosX = diffXBetweenMove + self._mapPosX;
                --屏幕内才滚
                if targetPosX < 0 and self._mapPosX  > -(maxWidth - self._winSize.width)   then 
                    if  self._mapPosX >= -(maxWidth - self._winSize.width - 15) then
                        self:moveView(diffXBetweenMove);
                    end
                end 
            end 
        else
            self._lastMoveEndPos = {x = point.x, y = point.y};
            self._lastMoveSpeed = 0
        end 
    end
    local isPlayComClick2Music = function () 

    end

    moveTouchNode:setContentSize(cc.size(maxWidth,GameVars.height))
    moveTouchNode:anchor(0,1)
    moveTouchNode:addTo(self,100)
    -- moveTouchNode:pos(-GameVars.UIOffsetX,GameVars.UIOffsetY)
    moveTouchNode:setTouchedFunc(GameVars.emptyFunc, nil, false, 
        touchBeginCallBack, touchMoveCallBack,
         isPlayComClick2Music, touchEndCallBack)
end

function GuildMapLayer:updateFrame()
    if self._isNpcClick == true then 
        self._player:getShowNode():playLabel("stand");
        return;
    end 

    self._totalFrame = self._totalFrame + 1;
    --todo 
    local playerWidth = 20;
    --移动相关
    local curSpeed = self._player:getCurSpeed();
    local curSpeedY = self._player:getCurSpeedY();

    if self._isShowEnterAni == true and self._totalFrame > 30 then 
        self.curSceneMoveDistance = self.curSceneMoveDistance + self.sceneSpeed;

        return;
    end

    --网上走
    -- echo("=======yyyyy========",self._diffY,self._player:getPositionY())--,(self._player:getPositionY() + curSpeedY))
 ---[[   
    local posy = self._player:getPositionY()
    local posx = self._player:getPositionX()
    local _pos = {x = posx,y = posy}
    if self._diffY > 0 then 
         
        -- local isdistance = FuncGuild.guildMapPlayerPos(_pos)
        -- if isdistance  then
        --     self._diffX = 0
        -- end
         -- local endpos = {x = self._player:getPositionX(),y = self._player:getPositionY()}
        -- local ishave = FuncGuild.guildMapPlayerPos(self.cachePos,endpos) 
        -- if ishave then
        --     self._diffY = 0;
        -- end
        local  rightTab = FuncGuild.MapPointTab.right
        if posx >= rightTab.x then
            if posy >= rightTab.y - 40 then
                self._diffY = 0;
            end
        end
        local isArea = FuncGuild.walkingArea(posx,posy)
        -- echo("====isArea======",isArea)
        if isArea then
             self._diffY = 0
        end
        if self._diffY ~= 0 then
            self._diffY = self._diffY - curSpeedY;
            self._player:setPositionY( self._player:getPositionY() + curSpeedY ); 
        end
        if self._diffY < 0 then
            self._diffY = 0;
        end

    elseif self._diffY < 0 then 
        local isdistance FuncGuild.guildMapPlayerPos(_pos)
        if isdistance  then
            self._diffX = 0
        end
        local  rightTab = FuncGuild.MapPointTab.right
        if posx >= rightTab.x then
            if posy <= rightTab.y -100 then
                self._diffY = 0;
            end
        elseif posx >= rightTab.x - 100 then
            if posy <= rightTab.y - 80 then
                self._diffY = 0;
            end
        end
        if self._diffY ~= 0 then
            self._diffY = self._diffY + curSpeedY;
            self._player:setPositionY( self._player:getPositionY() - curSpeedY); 
            if self._player:getPositionY() <= -600 then
                self._diffY = 0;
            end
        end
    end


    if self._diffX > 0 then  --往右走
        if self._isGoOnMove == false then 
            -- echo("---self._diffX > 0---");
            self._diffX = self._diffX - curSpeed;
        end
        local  rightTab = FuncGuild.MapPointTab.right
        if posy >= rightTab.y - 50 then
            if self._playerPosX >= rightTab.x then
                self._diffX = 0;
            end
        elseif posy <= rightTab.y - 80 then
            if posx >= rightTab.x - 150 then
                if posy <= rightTab.y - 120 then
                    self._diffX = 0;
                end
            end
        end
        if self._diffX ~= 0 then
            if posy >= rightTab.y - 50 and self._playerPosX >= rightTab.x  then
                self._diffX = 0;
            else
                self._playerPosX = self._playerPosX + curSpeed;
                if self._playerPosX >= maxWidth - 150 then
                    self._playerPosX = maxWidth - 150  ---最右边的位置
                end
                self._player:setPositionX(self._playerPosX);
                --屏幕内才滚
                if self:isPlayerInMapMiddleToRight() == true and self._isMoveNow == false then 
                    if  self._mapPosX <= -5 then
                        self:moveView(curSpeed-3);
                    end
                end
                if self._diffX < 0 then 
                    self._diffX = 0;
                end 
            end
        end
        -- echo("======xxxxx==========yyyy===",self._player:getPositionX(),self._player:getPositionY())
        self._player:getShowNode():playLabel("run");
    elseif self._diffX < 0 then --往左走
        if self._isGoOnMove == false then 
            self._diffX = self._diffX + curSpeed;
        end 

        local isArea =  FuncGuild.walkingArea(posx,posy)
        if isArea then
             self._diffX = 0
        end

        -- local _pos = {x = posx,y = posy}
        -- local isdistance FuncGuild.guildMapPlayerPos(_pos)
        -- if isdistance  then
        --     self._diffX = 0
        -- end
        if self._diffX ~= 0 then
            self._playerPosX = self._playerPosX - curSpeed;
            local playerx =  self._player:getPositionX()
            if self._playerPosX <= 200 then
                self._playerPosX = 200  ---最左边的位置
            end
            self._player:setPositionX(self._playerPosX);
            --屏幕内才滚
            if self:isPlayerInMapMiddleToLeft() == true  then
                if  self._mapPosX >= -(maxWidth - self._winSize.width - 15) then
                    self:moveView(-(curSpeed-3));
                end
            end

            if self._diffX > 0 then 
                self._diffX = 0;
            end
        end
        self._player:getShowNode():playLabel("run");
    else 
        if self._diffY == 0 then 
            self._player:getShowNode():playLabel("stand");
        end 
    end 
--]]
    local isUpdateFriend = function ( ... )
        local isFrameReach = self._totalFrame % GameStatic._local_data.onLineUserHeart == 0;
        local isHomeViewShow = self._homeView:isVisible() == true;
        local isOtherFriendShow =  self._isShowOtherPlayer == true;

        if isFrameReach and isHomeViewShow and isOtherFriendShow then 
            return true;
        else
            return false;
        end
    end
 
    --人物进出相关 没 onLineUserHeart 帧率进行一次判断
    if isUpdateFriend() == true then 
        local rids = self:getRids();

        EventControler:dispatchEvent(HomeEvent.GET_ONLINE_PLAYER_EVENT_AGAIN,
            {rids = rids});
    end 

    --设置所有人zOrder
    self:updatePlayerZorder();
    self:updateLabelPos();
    self:updateLabelZorder();
    local _playerX = self._player:getPositionX()
    local _playerY = self._player:getPositionY()
    -- echo("======_playerX===============",_playerX,_playerY)
    if _playerX ~= 0 and _playerY ~= 0 then
        HomeModel:setsaveUserPos(_playerX,_playerY)
    end
end


--太清殿
function GuildMapLayer:taiqingduan()
    if not GuildControler:touchToMainview() then
        return 
    end
    GuildControler:getGuildInfoData(3)
   -- WindowControler:showWindow("GuildMainBuildView")

end
--祈福堂
function GuildMapLayer:qifutan()
   echo("=======祈福堂========")
    if not GuildControler:touchToMainview() then
        return 
    end
   -- GuildControler:getWishList()
   WindowControler:showWindow("GuildWelfareMainView")
   -- WindowControler:showWindow("GuildBlessingView")
end
--账房
function GuildMapLayer:maneyroom()
    echo("=======账房 ========")
    if not GuildControler:touchToMainview() then
        return 
    end
    -- WindowControler:showWindow("GuildWelfareMainView")
    ----获取地图数据  刷新地图的状态
    local function _callback( event )
        if event.result then
            local digTool = event.result.data.digTool or 0
            WindowControler:showWindow("GuildTreasureMainView",nil,digTool)
        end
    end
    GuildServer:getGuildDigList(_callback)
end


--GVE活动
function GuildMapLayer:gveActive()
    -- echo("=======GVE活动========")
    -- if not GuildControler:touchToMainview() then
    --     return 
    -- end
    -- WindowControler:showWindow("GuildActivityMainView")
end


--璇光殿
function GuildMapLayer:xuanGuanDian()
    -- WindowControler:showTips("==璇光殿正在研发==");
    -- WindowControler:showTips("旋光殿暂未开启")
    WindowControler:showWindow("ShopView",FuncShop.SHOP_TYPES.GUILD_SHOP)
end

--任务大厅
function GuildMapLayer:taskmain()
    -- WindowControler:showTips("==任务大厅正在研发==");
    -- WindowControler:showTips(GameConfig.getLanguage("#tid_guild_sys_001"))
    WindowControler:showWindow("GuildTaskMainView")
        
end

--护山结界
function GuildMapLayer:hushangjiejie()
    -- WindowControler:showTips("==护山结界正在研发==");
    -- WindowControler:showTips(GameConfig.getLanguage("#tid_guild_sys_002"))
    if not GuildControler:touchToMainview() then
        return 
    end
    WindowControler:showWindow("GuildSkillMainView")

end

--历练阁
function GuildMapLayer:liliangge()
    echo("=======GVE活动========")
    if not GuildControler:touchToMainview() then
        return 
    end
    WindowControler:showWindow("GuildActivityEntranceView")
end


function GuildMapLayer:moveView( xoffize )

    local targetPosX = self._mapPosX + xoffize;
    --如果是向右运动
    if xoffize > 0 then

        if targetPosX > 0  then  
            xoffize = -self._mapPosX
        end

    else
        --向左运动
        if targetPosX  < -(maxWidth - self._winSize.width)  then
            xoffize = -(maxWidth - self._winSize.width) - self._mapPosX
        end
    end

    self._mapPosX = self._mapPosX + xoffize;
    self:updateMapPos(self._mapPosX, 0);
    local x = self._middleLayer:getPositionX()
    self._middleLayer:pos(x - xoffize, 0);

    -- echo("==========1111=======",self._mapPosX,x - xoffize)
end
function GuildMapLayer:updatePlayerZorder()
    self._player:setLocalZOrder(-self._player:getPositionY());

    for k, v in pairs(self._friendPlayers) do
        v:setLocalZOrder(-v:getPositionY());
    end 
end
function GuildMapLayer:updateLabelPos()
    local x, y = self._player:getPosition();
    self._playerNameLabel:setPosition(x, y + 140);

    for id, v in pairs(self._friendPlayers) do
        local x, y = v:getPosition();
        -- if x >= 550 then
        --     x = 550 
        -- end
        self._friendNameLabels[id]:setPosition(x, y + 140);
    end
end




function GuildMapLayer:updateMapPos( xpos,ypos )
    -- xpos = maxWidth + xpos -GameVars.width 
    -- echo("=====11111========",GameVars.width)
    if xpos > 0  then
        xpos = 0
    elseif  xpos < -(maxWidth-GameVars.width) then
        xpos = -(maxWidth-GameVars.width)+8
    end
    -- echo("=======-xpos=========",-xpos)
    self.map:updatePos(-xpos, ypos);
end

function GuildMapLayer:updateLabelZorder()
    self._playerNameLabel:setLocalZOrder(-self._player:getPositionY() + nameLaberZorder);
    for k, v in pairs(self._friendPlayers) do
        self._friendNameLabels[k]:setLocalZOrder(-v:getPositionY() + nameLaberZorder);
    end 
end

function GuildMapLayer:isPlayerInMapMiddleToLeft()
    local _playerpos = self._player:getPositionX(); --玩家的位置
    local pimupos = -(self._middleLayer:getPositionX());  --屏幕的位置
    local diff = math.abs( pimupos + self._winSize.width / 2 );
    if  _playerpos <= diff then
        return true
    end
    return false
end

--主角是不是在屏幕中间  b ---往右的
function GuildMapLayer:isPlayerInMapMiddleToRight()

    -- local playerPosXRelativeToOrign = self._mapPosX + self._player:getPositionX();
    local _playerpos = self._player:getPositionX(); --玩家的位置
    local pimupos = -(self._middleLayer:getPositionX());  --屏幕的位置
    local diff = math.abs( pimupos + self._winSize.width / 2 );
    if  _playerpos >= diff then
        return true
    end
    return false
end

function GuildMapLayer:initFriend()
    

    --所有展示的玩家


    self._friendPlayers = {};
    local newshowPlayer = {}
    local function _callback(_param)
        -- dump(_param,"在线数据",8)
        if _param then
            local showPlayer = GuildModel:getGuildMembersInfo()
            for i=1,#_param do
                local _id = _param[i]
                if _id ~= UserModel:rid() then
                    newshowPlayer[i] = showPlayer[_id]
                end
            end
            for i, key in pairs(newshowPlayer) do
                self._homeView:delayCall(c_func(self.frientPlayerCome, self,newshowPlayer[i]), 
                    (i * 2 - 1) / GameVars.GAMEFRAMERATE);
                i = i + 1;
            end
        else
        end

    end
    GuildServer:sendMotched(_callback)
end
-- function function_name( ... )
--     -- body
-- end


function GuildMapLayer:frientPlayerCome(playerInfo)
    local playerId = playerInfo._id
    local avatarId = tostring(playerInfo.avatar or 101);

    -- if tostring(avatarId) == tostring(102) then 
    --     avatarId = tostring(104);
    -- end 
    if playerInfo.garmentId == 0 then
        playerInfo.garmentId = nil
    end

    local garmentId = playerInfo.garmentId or GarmentModel.DefaultGarmentId;

    -- local sp = FuncChar.getSpineAni(avatarId, playerInfo.level);
    -- local sp = FuncChar.getCharSkinSpine(
    --     avatarId, playerInfo.level, playerInfo.downtownTreasure);
    -- echo("----avatarId, garmentId----", avatarId, garmentId);
    -- if garmentId == "" then 
    --     garmentId = GarmentModel.DefaultGarmentId;
    -- end 

    local sp = GarmentModel:getSpineViewByAvatarAndGarmentId(avatarId, garmentId)
    
    sp:playLabel("stand");
    -- sp:setScale(FuncGuild.OtherScal)
    local friendPlayer = FriendPlayer.new(sp, playerInfo);
    -- friendPlayer:setScale(FuncGuild.OtherScal)
    self._middleLayer:addChild(friendPlayer, 100);
    friendPlayer:birth(self._middleLayer);

    local cloneTitleUI = UIBaseDef:cloneOneView(self._homeView.panel_otherPlayerTitle);

    self._friendNameLabels[playerId] = cloneTitleUI;
    cloneTitleUI.txt_name:setString(playerInfo.name or GameConfig.getLanguage("tid_common_2006")); 
    ---盟主类型
    local guilddata = GuildModel.MySelfGuildDataList
    local guildType = GuildModel.guildName._type
    local postype = playerInfo.right or 4
    local str,spritename = FuncGuild.byIdAndPosgetName(guildType,postype)

    cloneTitleUI.txt_gName:setVisible(false)
    cloneTitleUI.ctn_1:removeAllChildren()
    local right = FuncRes.iconGuild(spritename)
    local icon = display.newSprite(right)
    icon:setScale(0.6)
    cloneTitleUI.ctn_1:addChild(icon)

    self._middleLayer:addChild(cloneTitleUI, nameLaberZorder);

    -- local bubbleUI = UIBaseDef:cloneOneView(self._homeView.panel_playerBubble);
    -- friendPlayer:setChatBubbleUI(bubbleUI);  
    -- if cloneTitleUI.mc_touxian ~= nil then
    --     cloneTitleUI.mc_touxian:showFrame(playerInfo.crown or 1)
    --     self:TouXianAndNameShiPei(cloneTitleUI.mc_touxian,cloneTitleUI.txt_name,playerInfo.name )
    -- end

    friendPlayer:setLocalZOrder(-friendPlayer:getPositionY());

    self._friendPlayers[playerId] = friendPlayer;

    local touchEndCallBack = function (playerInfo, friendPlayer)

        self._homeView.ctn_OtherIcon:removeAllChildren();

        -- local clonePanel = UIBaseDef:cloneOneView(self._homeView.panel_otherLvl);
        local clonePanel = WindowsTools:createWindow("CompPlayerInfoView")
        clonePanel:setPlayerInfo(playerInfo)
        clonePanel:setScale(0.85)

        local action = FuncArmature.createArmature("UI_common_tubiaofeiru", 
            self._homeView.ctn_OtherIcon, false);

        clonePanel:setPosition(0, 0);
        clonePanel:setVisible(true);
        clonePanel:addTo(self._homeView.ctn_OtherIcon)
        -- FuncArmature.changeBoneDisplay(action, "layer2", clonePanel,0);

        local tempFunc = function ()
                -- dump(playerInfo,"22222222222",8)
            FriendViewControler:showPlayer(playerInfo._id, playerInfo)
            self._homeView.ctn_OtherIcon:removeAllChildren();
        end

        clonePanel:setTouchedFunc(tempFunc,nil,true)--c_func(self.getactive, self,itmedata.id),nil,true);
        -- setTouchedFuncWithPriority(tempFunc, 3);

        clonePanel:setTouchSwallowEnabled(true);

        friendPlayer:addGrowDown();
        self._lastSelectPlayer = friendPlayer;

        AudioModel:playSound("s_com_click1")
    end

    local node = display.newNode();
    node:setTouchSwallowEnabled(false)
    node:setTouchEnabled(true)
    node:anchor(0, 0);
    node:setContentSize(100, 100);
    node:pos(-50,0)

    friendPlayer:addChild(node);

    friendPlayer:setTouchedFunc(c_func(touchEndCallBack, playerInfo, friendPlayer));
    friendPlayer:setTouchSwallowEnabled(true);

    -- if TutorialManager.getInstance():isAllFinish() == false then 
    --     friendPlayer:setTouchEnabled(false);
    -- end 
end




function GuildMapLayer:getRids()
    local rids = {};
    for k, v in pairs(self._friendPlayers) do
        --只算真人
        if v:isRobot() ~= true then 
            table.insert(rids, k);
        end 
    end
    return rids;
end
function GuildMapLayer:dispose()
    WindowControler:getScene()._topRoot:removeChildByTag(
        WindowControler.ZORDER_TopOnUI, true);

    -- local eventDispatcher = cc.Director:getInstance():getEventDispatcher();

    -- if self._mapTutoriallistener ~= nil then 
    --     eventDispatcher:removeEventListener(self._mapTutoriallistener);
    --     self._mapTutoriallistener = nil;
    -- end 

    self.map:deleteMe();
    EventControler:clearOneObjEvent(self)
    FightEvent:clearOneObjEvent(self)
end


return GuildMapLayer;










