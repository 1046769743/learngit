local PlayerDetailView = class("PlayerDetailView", UIBase);

function PlayerDetailView:ctor(winName,data)
    PlayerDetailView.super.ctor(self, winName);

    self:initData(data)
end

function PlayerDetailView:loadUIComplete()
	self:registerEvent();
    self:initScrollCfg()

    self:updateUI()
end 

function PlayerDetailView:registerEvent()
	PlayerDetailView.super.registerEvent();

    self:registClickClose()
end

function PlayerDetailView:initData(data)
    if data then
        self.playerData = data
        self:formatTreasureList(data.treasures)
    end
end

-- 格式化法宝列表
function PlayerDetailView:formatTreasureList(treasures)
    self.treasureList = {}
    if not treasures or #treasures <= 0 then
        return {}
    end

    for k,v in pairs(treasures) do
        local tid = v.id
        local level = v.level
        local star = v.star
        local state = v.state
        local enegy = TreasuresModel:getTreasurePower(tid, level, star, state)
        v.enegy = enegy

        self.treasureList[#self.treasureList+1] = v
    end

    table.sort(self.treasureList,function(a,b)
        return a.enegy < b.enegy
    end)
end

-- 初始化滚动配置
function PlayerDetailView:initScrollCfg()
    self.panel_1:setVisible(false)
    local createFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_1)
        self:updateItem(view, itemData)
        return view
    end

    self.scrollParams = {
        {
            data = self.treasureList,
            createFunc= createFunc,
            perNums = 1,
            offsetX = 6,
            offsetY = 6,
            itemRect = {x=0,y=-182,width=150,height = 182},
            heightGap = 0
        },
    }
end

function PlayerDetailView:updateItem(itemView,data)
    -- 法宝名字
    local treasureName = TreasuresModel:getTreasureName(data.id)
    itemView.txt_1:setString(treasureName)

    -- 星级
    itemView.mc_1:showFrame(data.star)

    -- 精炼
    itemView.mc_2:showFrame(data.state)

    -- 等级
    itemView.txt_2:setString(GameConfig.getLanguageWithSwap("rank_14", data.level))
end

function PlayerDetailView:updateUI()
    -- 创建滚动条
    self.scroll_list:styleFill(self.scrollParams)

	local playerData = self.playerData

    -- 玩家立绘
    local playerIcon = display.newSprite(FuncRes.iconHero("HeroIcon_1.png")):anchor(0,1)
    playerIcon:setScale(3)
    self.ctn_player:addChild(playerIcon)

    if playerData.name == "" then
        playerData.name = "无"
    end
    -- 玩家名字
    self.txt_1:setString(playerData.name)

    -- 战斗力
    self.txt_2:setString(GameConfig.getLanguageWithSwap("tid_rank_1005", playerData.ability))

    -- 等级
    self.txt_3:setString(GameConfig.getLanguageWithSwap("rank_2", playerData.level))

    -- 所属仙盟
    local guildName = playerData.guildName
    if guildName == nil or guildName == "" then
        guildName = GameConfig.getLanguage("tid_rank_1011")
    end
    self.txt_4:setString(GameConfig.getLanguageWithSwap("tid_rank_1010", guildName))

    -- 法宝总数量
    self.txt_5:setString(GameConfig.getLanguageWithSwap("tid_rank_1012", playerData.count))

    -- 最高威能法宝
    self.txt_6:setString(GameConfig.getLanguage("tid_rank_1013"))
end


return PlayerDetailView;
