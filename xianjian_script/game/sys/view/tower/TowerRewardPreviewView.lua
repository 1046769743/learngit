--
--Author:      zhuguangyuan
--DateTime:    2018-03-10 10:16:44
--Description: 每层的奖励列表界面
-- 1.总进度条上下滚动 之上有 完美奖励滚动条 一次性宝箱滚动条 杀星级怪滚动条 野怪及非一次性宝箱滚动条
-- 2.监听宝箱领取消息 及 杀怪消息 选择性更新相应的滚动条及完成进度
-- 3.宝箱及杀怪奖励 不再绑定到怪物身上 只跟层数及怪类型(1=普通星级怪 2=boss星级怪 3=野怪)有关

local TowerRewardPreviewView = class("TowerRewardPreviewView", UIBase);

function TowerRewardPreviewView:ctor(winName,floorId)
    TowerRewardPreviewView.super.ctor(self, winName)
    self.curFloorId = floorId
    self.curFloorConfigData = FuncTower.getOneFloorData( floorId )
    -- dump(self.curFloorConfigData, "self.curFloorConfigData")
end

function TowerRewardPreviewView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerRewardPreviewView:registerEvent()
	TowerRewardPreviewView.super.registerEvent(self);
	self:registClickClose("out")
	self.btn_close:setTap(c_func(self.press_btn_close, self))
    -- 监听宝箱领取及杀怪事件
    EventControler:addEventListener(TowerEvent.TOWEREVENT_MONSTER_DIE,self.onKillMonsterSuccess,self)
    EventControler:addEventListener(TowerEvent.TOWEREVENT_SUCCESS_GETMAINREWARDVIEW,self.onGotBoxSuccess,self)
    EventControler:addEventListener(TowerEvent.TOWEREVENT_OPEN_BOX_SUCCESS,self.onGotBoxSuccess,self)
end

function TowerRewardPreviewView:initData()
	-- TODO
end

function TowerRewardPreviewView:initView()
	self:initBossSpine()
	self:initFirstPassReward()
	self:initScrollCfg()
end

function TowerRewardPreviewView:initViewAlign()
	-- TODO
end

function TowerRewardPreviewView:onGotBoxSuccess( event )
    self:updateAllScrollView(true,false)
end

function TowerRewardPreviewView:onKillMonsterSuccess( event )
    self:updateAllScrollView(false,true)
end

function TowerRewardPreviewView:updateUI()
	self:updateAllScrollView(true,true)
end

function TowerRewardPreviewView:initBossSpine()
    -- 立绘形象
	local bossId = self.curFloorConfigData.bossID
	local bossData = FuncTower.getMonsterData(bossId)
	local bossSpine,offsetY = self:createSpineById(bossData.spineId)
    -- local size = bossSpine:getBoundingBox()
    -- dump(size, "size")
    -- local offsetY
    -- if size.height > 30 then
    --     offsetY = -size.height/5
    -- end
    bossSpine:setScale(1)
    self.panel_zuo.ctn_1:removeAllChildren()
    self.panel_zuo.ctn_1:addChild(bossSpine)
    if offsetY then
        bossSpine:pos(0,-offsetY)
    end

    -- 名字
    local bossName = GameConfig.getLanguage(bossData.name)
	self.panel_zuo.panel_name.txt_1:setString(bossName)
end

-- 创建怪的立绘,返回怪立绘及y轴偏移量
function TowerRewardPreviewView:createSpineById(npcId)
	local npcSourceData = FuncTreasure.getSourceDataById(npcId)
	local npcAnimName = npcSourceData.spine
    local npcAnimLabel = npcSourceData.stand
    local npcNode = nil
    local npcAnim = nil
    if npcId == nil or npcAnimName == nil or npcAnimLabel == nil then
        echoError("npcId =",npcId,",npcAnimName=",npcAnimName,",npcAnimLabel=",npcAnimLabel)
    else
        local spbName = npcAnimName .. "Extract"
        npcAnim = ViewSpine.new(spbName, {}, nil,npcAnimName);
        npcAnim:playLabel(npcAnimLabel);
    end
    -- if table.isValueIn(self.bigGuys,npcAnimName) then
    dump(npcSourceData.viewSize, "npcSourceData.viewSize", nesting)
    local scaleto = 100/npcSourceData.viewSize[2]
    echo("__________ scaleto",scaleto)
    npcAnim:setScale(scaleto)
    -- end

    local offsety = (npcSourceData.viewSize[2] - 120)/2
    return npcAnim,offsety
end

-- 初始化首通能获得的奖励
-- 或者解锁的锁妖塔商品
function TowerRewardPreviewView:initFirstPassReward( ... )
	local firstPassReward = TowerMainModel:getPassOneFloorReward( self.curFloorId )
    local isShopUnlockGoods = false
    if type(firstPassReward) == "table" then
        self.panel_zuo.panel_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_task_1"))
        -- dump(firstPassReward, "首通奖励")
    else
        self.panel_zuo.panel_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_task_2"))
        isShopUnlockGoods = true
        local shops = FuncShop.getTowerShopGoods()
        
        local itemId = shops[tonumber(firstPassReward)].itemId
        local itemData = FuncItem.getItemData(itemId)
        -- dump(itemData, "itemData")
        firstPassReward = {}
        firstPassReward[1] = FuncDataResource.RES_TYPE.ITEM..","..itemData.id..",".."1"
    end
    self.panel_zuo.panel_1.mc_shoutong:showFrame(#firstPassReward)
    local contentView = self.panel_zuo.panel_1.mc_shoutong:getCurFrameView()
    -- 判断有没有领取
    local isGotFirstPass = false
    local haveGotBox = TowerMainModel:getTowerFloorReward() or {}
    for k,v in pairs(haveGotBox) do
        if tostring(self.curFloorId) == tostring(k) then
            isGotFirstPass = true
        end
    end

    for k,v in pairs(firstPassReward) do 
        contentView["panel_reward"..k].panel_got1:visible(false)
        local rewardUI = contentView["panel_reward"..k].UI_1
        local reward = string.split(v,",")
        local rewardType = reward[1];
        local rewardNum = reward[table.length(reward)];
        local rewardId = reward[table.length(reward) - 1];
        
        rewardUI:visible(true)
        rewardUI:setResItemData({reward = v})
        rewardUI:showResItemName(false)
        FuncCommUI.regesitShowResView(rewardUI,rewardType,rewardNum,rewardId,v,true,true)
        if isGotFirstPass then
            if isShopUnlockGoods then
            else
            end
            contentView["panel_reward"..k].panel_got1:visible(true)
        end
    end
end

-- 根据传入的参数决定更新哪部分
-- gotBox 获取了宝箱
-- KillMonster 击杀了怪物
function TowerRewardPreviewView:updateAllScrollView(gotBox,KillMonster)
	self.totalScrollParams[1].data = {{1}}
	self.scroll_1:styleFill(self.totalScrollParams)

	local data1 = TowerMainModel:getPerfectOneFloorReward( self.curFloorId )
	-- dump(data1, "完美通关奖励")
    local curStarNum = TowerMainModel:getAllStar()
    self.isPerfect = TowerMainModel:checkIsPerfectPassOneFloor( self.curFloorId )
    if self.isPerfect then
        curStarNum = self.curFloorConfigData.starNum
    end
    local onefloorMaxStarNum = self.curFloorConfigData.starNum
    self.panel_2.panel_1.txt_2:setString(curStarNum.."/"..onefloorMaxStarNum)

    -- 完美通关奖励滚动条
    self.perfectParams[1].data = data1
    self.panel_2.panel_1.scroll_1:styleFill(self.perfectParams)
    self.panel_2.panel_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_task_3"))

    local data2,data22 = nil,nil
    if gotBox then
    	data2,data22 = TowerMainModel:getOneFloorOneOffBoxes( self.curFloorId )
        dump(data2, "一次性宝箱")
    	dump(data22, "非一次性宝箱")

        local totalOneOffBox = #data2
        local haveGotNum = 0
        for k,v in pairs(data2) do
            if self:checkHasGotBox(v) then
                haveGotNum = haveGotNum + 1
            end
        end
        local tips1 = GameConfig.getLanguage("#tid_tower_task_7")
        self.panel_2.panel_2.txt_2:setString(tips1..haveGotNum.."/"..totalOneOffBox)
    	
        if totalOneOffBox == 0 then
            self.offsetY = self.panel_2.panel_2:getPositionY()
            self.panel_2.panel_2:visible(false)
        else
            self.oneOffBoxesParams[1].data = data2
            self.panel_2.panel_2.scroll_1:styleFill(self.oneOffBoxesParams)
            self.panel_2.panel_2.txt_1:setString(GameConfig.getLanguage("#tid_tower_task_4"))
        end
    end
    
    local data3,data33 = nil,nil
    if KillMonster then
    	data3,data33 = TowerMainModel:getOneFloorAllStarMonsters( self.curFloorId )
        -- dump(data3, "星级怪")
    	-- dump(data33, "非星级怪")
    	self.starMonsteresParams[1].data = data3
        if self.offsetY then
            local basicPosY = self.panel_2.panel_3:getPositionY()
            self.panel_2.panel_3:setPositionY(self.offsetY)
            self.offsetY = basicPosY - 100
        end
        self.panel_2.panel_3.scroll_1:styleFill(self.starMonsteresParams)
        self.panel_2.panel_3.txt_1:setString(GameConfig.getLanguage("#tid_tower_task_5"))
        local totalSatrMonster = #data3
        local haveKilledNum = 0
        for k,v in pairs(data3) do
            if self:checkHasKilledMonster(v) then
                haveKilledNum = haveKilledNum + 1
            end
        end
        local tips1 = GameConfig.getLanguage("#tid_tower_task_8")
        self.panel_2.panel_3.txt_2:setString(tips1..haveKilledNum.."/"..totalSatrMonster)
    end

    local otherReward = {}
    for k,v in pairs(data22) do
        local temp = {}
        temp.type = FuncTowerMap.GRID_BIT_TYPE.BOX
        temp.id = v
        otherReward[#otherReward + 1] = temp
    end
    for k,v in pairs(data33) do
        local temp = {}
        temp.type = FuncTowerMap.GRID_BIT_TYPE.MONSTER
        temp.id = v
        otherReward[#otherReward + 1] = temp
    end
    dump(otherReward, "其他类型奖励 == 非星级怪及非一次性宝箱")
	self.wildMonsteresParams[1].data = otherReward
    if self.offsetY then
        local basicPosY = self.panel_2.panel_4:getPositionY()
        self.panel_2.panel_4:setPositionY(self.offsetY)
    end
    self.panel_2.panel_4.scroll_1:styleFill(self.wildMonsteresParams)
    self.panel_2.panel_4.txt_1:setString(GameConfig.getLanguage("#tid_tower_task_6"))
    local totalSatrMonster = #otherReward
    local haveKilledNum = 0
    for k,v in pairs(otherReward) do
        if (v.type == FuncTowerMap.GRID_BIT_TYPE.BOX and self:checkHasGotBox(v.id)) 
            or (v.type == FuncTowerMap.GRID_BIT_TYPE.MONSTER and self:checkHasKilledMonster(v.id)) 
        then
            haveKilledNum = haveKilledNum + 1
        end
    end
    local tips1 = GameConfig.getLanguage("#tid_tower_task_9")
    self.panel_2.panel_4.txt_2:setString(tips1..haveKilledNum.."/"..totalSatrMonster)
end

function TowerRewardPreviewView:checkHasGotBox( boxId )
    local isOneOff,isHasGot = TowerMainModel:isOneOffBoxAndHaveGot( boxId )
    echo("_____isOneOff,isHasGot________________",isOneOff,isHasGot)
    return isHasGot
end

function TowerRewardPreviewView:checkHasKilledMonster( monsterId )
    local isKilled = TowerMainModel:isOneOffMonsterRewardHaveGot( monsterId )
    echo("_____isKilled ____________",isKilled)

    return isKilled
end

function TowerRewardPreviewView:initScrollCfg()
	self.scroll_1:hideDragBar()
	self.panel_2.panel_1.scroll_1:hideDragBar()
	self.panel_2.panel_2.scroll_1:hideDragBar()
	self.panel_2.panel_3.scroll_1:hideDragBar()
	self.panel_2.panel_4.scroll_1:hideDragBar()
	-- -------------------------------------------------------
    -- 竖直滚动条
    local createTotalFunc = function ( itemData )
		local view = self.panel_2
        return view
    end
    local updateTotalFunc = function(itemData,itemView)
        return itemView
    end
    -- itemView参数配置
    self.totalScrollParams = {
		{        
			data = nil,
	        itemRect = {x=0,y=-974,width = 470,height = 974},
	        createFunc = createTotalFunc,
	        updateCellFunc = updateTotalFunc,
	        perNums= 1,
	        offsetX = 0,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
	        cellWithGroup = 1,
	    }
    }

    -- -------------------------------------------------------
    -- 完美通关奖励
    local createPerfectFunc = function ( itemData )
    	self.panel_2.panel_1.panel_got1:visible(false)
        local view = UIBaseDef:cloneOneView(self.panel_2.panel_1.panel_got1)
        view:visible(true)
        self:setPerfectRewardData(view,itemData)
        return view
    end

    -- local updatePerfectFunc = function(itemData,itemView)
    --     self:setPerfectRewardData(itemView,itemData)
    --     return itemView
    -- end

    -- itemView参数配置
    self.perfectParams = {
		{        
			data = nil,
	        itemRect = {x=0,y=-60,width = 90,height = 70},
	        createFunc = createPerfectFunc,
	        perNums= 1,
	        offsetX = -61,
	        offsetY = 0,
	        widthGap = -8,
	        heightGap = 0,
	        perFrame = 1,
	        cellWithGroup = 1,
	    }
    }

    -- -------------------------------------------------------
    -- 一次性宝箱
    local createOneOffBoxesFunc = function ( itemData )
    	self.panel_2.panel_2.mc_box:visible(false)
        local view = UIBaseDef:cloneOneView(self.panel_2.panel_2.mc_box)
        view:visible(true)
        self:setOneOffBoxesData(view,itemData)
        return view
    end
    local updateOneOffBoxesFunc = function(itemData,itemView)
        self:setOneOffBoxesData(itemView,itemData)
        return itemView
    end
    -- itemView参数配置
    self.oneOffBoxesParams = {
		{        
			data = nil,
	        itemRect = {x=0,y=-40,width = 70,height = 70},
	        createFunc = createOneOffBoxesFunc,
	        updateCellFunc = updateOneOffBoxesFunc,
	        perNums= 1,
	        offsetX = 170,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
	        cellWithGroup = 1,
	    }
    }

    -- -------------------------------------------------------
    -- 星级怪
    local createStarMonsteresFunc = function ( itemData )
    	self.panel_2.panel_3.panel_zhua:visible(false)
        local view = UIBaseDef:cloneOneView(self.panel_2.panel_3.panel_zhua)
        view:visible(true)
        self:setStarMonsteresData(view,itemData)
        return view
    end
    local updateStarMonsteresFunc = function(itemData,itemView)
        self:setStarMonsteresData(itemView,itemData)
        return itemView
    end
    -- itemView参数配置
    self.starMonsteresParams = {
		{        
			data = nil,
	        itemRect = {x=0,y=-229,width = 232,height = 229},
	        createFunc = createStarMonsteresFunc,
	        -- updateCellFunc = updateStarMonsteresFunc,
	        perNums= 1,
	        offsetX = 0,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
	        cellWithGroup = 1,
	    }
    }

    -- -------------------------------------------------------
    -- 非星级怪及非一次性宝箱
    local createWildMonsteresFunc = function ( itemData )
    self.panel_2.panel_4.panel_zhua:visible(false)
        local view = UIBaseDef:cloneOneView(self.panel_2.panel_4.panel_zhua)
        view:visible(true)
        self:setWildMonsteresData(view,itemData)
        return view
    end
    local updateWildMonsteresFunc = function(itemData,itemView)
        self:setWildMonsteresData(itemView,itemData)
        return itemView
    end
    -- itemView参数配置
    self.wildMonsteresParams = {
        {        
            data = nil,
            itemRect = {x=0,y=-202,width = 282,height = 202},
            createFunc = createWildMonsteresFunc,
            -- updateCellFunc = updateWildMonsteresFunc,
            perNums= 1,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            perFrame = 1,
            cellWithGroup = 1,
        }
    }
end

function TowerRewardPreviewView:setPerfectRewardData(itemView,itemData)
	-- dump(itemData, "完美通关奖励 一个itemData")
    -- 完美通关奖励 一个itemData" = "-1,3,100000,1"
    if self.isPerfect then
        itemView.panel_got1:visible(true)
    else
        itemView.panel_got1:visible(false)
    end

    local rewardUI = itemView.UI_1 --[""..k]
    local ddd = string.split(itemData,"-1,")[2]
    local reward = string.split(ddd,",")
    local rewardType = reward[1];
    local rewardNum = reward[3];
    local rewardId = reward[2];
    
    rewardUI:visible(true)
    rewardUI:setResItemData({reward = ddd})
    rewardUI:showResItemName(false)
    FuncCommUI.regesitShowResView(rewardUI,rewardType,rewardNum,rewardId,ddd,true,true)
end

function TowerRewardPreviewView:setOneOffBoxesData(itemView,itemData)
    -- dump(itemData, "一次性宝箱 一个itemData")
    -- - "一次性宝箱 一个itemData" = "1101"
    local boxId = itemData
    local isOneOff,isGotBox = TowerMainModel:isOneOffBoxAndHaveGot( boxId ) 
    if not isOneOff then
        echoError("_______ 错误!一个非一次性宝箱放到了一次性宝箱组里 ________")
    end
    if isOneOff and isGotBox then
        itemView:showFrame(2)
    else
        itemView:showFrame(1)
    end
end

function TowerRewardPreviewView:setStarMonsteresData(itemView,itemData,isWildMonster)
    -- dump(itemData, "星级怪 一个itemData")
    -- "星级怪 一个itemData" = "1004"
    local monsterId = itemData
    local monsterData = FuncTower.getMonsterData(itemData)
    -- dump(monsterData, "monsterData", nesting)
    local monsterSpine,offsety = self:createSpineById(monsterData.spineId)
    -- monsterSpine:setScale(0.8)
    if monsterData.type and monsterData.type == FuncTowerMap.MONSTER_TYPE.BOSS then
        -- monsterSpine:setScale(0.5)
    end

    monsterSpine:pos(0,-40)
    itemView.ctn_1:removeAllChildren()
    itemView.ctn_1:addChild(monsterSpine)

    -- 是否击杀返回星级,未击杀返回false
    local isKilled = self:checkHasKilledMonster(monsterId) 
    -- 如果是野怪则还按原来的显示逻辑,显示击杀
    if isWildMonster then
        if isKilled then
            itemView.mc_yinzhang1:visible(true)
            itemView.mc_yinzhang1:showFrame(2)
        else
            itemView.mc_yinzhang1:visible(false)
        end

        -- 怪首杀奖励不再绑定怪身上 只跟当前所在层及怪的种类有关
        local rewardId = self.curFloorConfigData.monsterStarReward[tonumber(monsterData.type)]
        local monsterReward = FuncItem.getRewardArrayByCfgData({FuncDataResource.RES_TYPE.REWARD..","..rewardId})
        -- itemView.mc_1:setScale(0.5)
        itemView.mc_1:pos(itemView.mc_1:getPositionX(),itemView.mc_1:getPositionY())
        itemView.mc_1:showFrame(#monsterReward)
        local contentView = itemView.mc_1:getCurFrameView()
        for k,v in pairs(monsterReward) do 
            local rewardUI = contentView["UI_"..k]
            local reward = string.split(v,",")
            local rewardType = reward[1];
            local rewardNum = reward[table.length(reward)];
            local rewardId = reward[table.length(reward) - 1];
            
            rewardUI:visible(true)
            rewardUI:setResItemData({reward = v})
            rewardUI:showResItemName(false)
            FuncCommUI.regesitShowResView(rewardUI,rewardType,rewardNum,rewardId,v,true,true)
        end
    else
        -- 根据怪物类型获取相应奖励str
        local mainRewardStr = self.curFloorConfigData.monsterStarReward[tonumber(monsterData.type)]
        -- 区分简单普通困难等级奖励
        local mainRewardArr = string.split(mainRewardStr,",")
        for k,oneRewardId in ipairs(mainRewardArr) do
            local contentView = itemView["panel_"..k]
            local rewardUI = contentView.UI_1
            local rewardStr = FuncItem.getRewardArrayByCfgData({FuncDataResource.RES_TYPE.REWARD..","..oneRewardId})[1]
            local reward = string.split(rewardStr,",")
            local rewardType = reward[1];
            local rewardNum = reward[table.length(reward)];
            local rewardId = reward[table.length(reward) - 1];
            
            rewardUI:visible(true)
            rewardUI:setResItemData({reward = rewardStr})
            rewardUI:showResItemName(false)
            FuncCommUI.regesitShowResView(rewardUI,rewardType,rewardNum,rewardId,rewardStr,true,true)

            if k <= tonumber(isKilled or 0) then
                contentView.panel_got1:visible(true)
            else
                contentView.panel_got1:visible(false)
            end
        end
    end
end

function TowerRewardPreviewView:setWildMonsteresData(itemView,itemData)
    -- dump(itemData, "野怪 及 非一次性宝箱 一个itemData")
    if itemData.type == FuncTowerMap.GRID_BIT_TYPE.MONSTER then
        self:setStarMonsteresData(itemView,itemData.id,true)
    elseif itemData.type == FuncTowerMap.GRID_BIT_TYPE.BOX then
        local boxData = FuncTower.getBoxData(itemData.id)
        local boxSpine = display.newSprite(FuncRes.iconTowerEvent(boxData.png))
        -- boxSpine:setScale(0.6)
        boxSpine:pos(0,0)
        itemView.ctn_1:removeAllChildren()
        itemView.ctn_1:addChild(boxSpine)

        local isOneOff,isGotBox = TowerMainModel:isOneOffBoxAndHaveGot( itemData.id ) 
        if isOneOff then
            echoError("______ 错误! 一个一次性宝箱 放到了非一次性宝箱组里 ________")
        end
        if isGotBox then
            itemView.mc_yinzhang1:visible(true)
            itemView.mc_yinzhang1:showFrame(1)
        else
            itemView.mc_yinzhang1:visible(false)
        end

        -- 宝箱奖励 抽到了tower 表  只跟当前所在层有关 所有当前层的非一次性宝箱奖励都一样
        -- local rewardArr = FuncItem.getRewardData(boxData.reward).info
        local rewardId = self.curFloorConfigData.boxReward
        local rewardArr = FuncItem.getRewardData(rewardId).info
        -- local rewardArr = FuncItem.getRewardArrayByCfgData({FuncDataResource.RES_TYPE.REWARD..","..rewardId})
        -- itemView.mc_1:setScale(0.5)
        itemView.mc_1:pos(itemView.mc_1:getPositionX(),itemView.mc_1:getPositionY()) 
        itemView.mc_1:showFrame(#rewardArr)
        local contentView = itemView.mc_1:getCurFrameView()
        for k,v in pairs(rewardArr) do 
            -- dump(v, "desciption")
            local rewardUI = contentView["UI_"..k]
            local reward = string.split(v,",")
            local rewardType = reward[2];
            local rewardNum = reward[4];
            local rewardId = reward[3];
            local vv = rewardType..","..rewardId..","..rewardNum
            
            rewardUI:visible(true)
            rewardUI:setResItemData({reward = vv})
            rewardUI:showResItemName(false)
            FuncCommUI.regesitShowResView(rewardUI,rewardType,rewardNum,rewardId,vv,true,true)
        end
    end
end

function TowerRewardPreviewView:deleteMe()
	TowerRewardPreviewView.super.deleteMe(self);
end

function TowerRewardPreviewView:press_btn_close()
	self:startHide()
end


return TowerRewardPreviewView;
