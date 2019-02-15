--仙盟挖宝或者兑换  10个以下获得奖励弹窗

local GuildDigRewardView = class("GuildDigRewardView", UIBase);
--- from 表示从哪传过来的数据    isBest 代表挖宝的奖励是不是极品   isExchange 代表是否有宝箱可以兑换 用于奖励界面处理
function GuildDigRewardView:ctor(winName, itemArray, from, rewardID, isBest, isExchange, callBack)  
    GuildDigRewardView.super.ctor(self, winName);
    dump(itemArray, "\n\n---itemArray---");
    self._itemArray = itemArray;
    self._from = from;
    self._rewardID = rewardID;
    self._isBest = isBest;
    self._isExchange = isExchange
    self._callback = callBack or GameVars.emptyFunc;
end

function GuildDigRewardView:loadUIComplete()
	self:registerEvent();
    self.mc_1:setVisible(false)
	self:initUI();
    AudioModel:playSound(MusicConfig.s_com_reward);
end 

function GuildDigRewardView:registerEvent()
	GuildDigRewardView.super.registerEvent();
end

--初始化界面
function GuildDigRewardView:initUI()
    local itemViewArr = {}

    local showItem = function ()
        if not self._itemArray then
            echoError("__没有传入道具",self._itemArray )
            return
        end
        
        local itemNum = table.length(self._itemArray);

        if itemNum > 10 then 
            echo("warning!!!  GuildDigRewardView:initUI() itemNum is more then 10!!!");
        end

        self.mc_1:setVisible(true)
        self.mc_1:showFrame(itemNum);

        for i = 1, itemNum do
            local itemCommonUI = nil
            local itemPanel = self.mc_1:getCurFrameView()["panel_" .. tostring(i)]

            itemCommonUI = itemPanel.UI_1
            itemCommonUI:setResItemData(
                {reward = self._itemArray[i]});
            itemCommonUI:showResItemName(true, true);
            itemCommonUI:showResItemNameWithQuality()

            local _reward = self._itemArray[i]
            
            local rewardType = nil
            local rewardNum = nil
            local rewardId = nil
            local rewardStr = nil

            if type(_reward) == "table" then
                rewardType = _reward[1]
                rewardNum = _reward[table.length(_reward)]
                rewardId = _reward[table.length(_reward) - 1]
                if table.length(_reward) > 2 then
                    rewardStr = string.format("%s,%s,%s",_reward[1],_reward[2],_reward[3])
                else
                    rewardStr = string.format("%s,%s",_reward[1],_reward[2])
                end
            else
                local reward_table = string.split(_reward, ",")
                rewardType = reward_table[1]
                rewardNum = reward_table[table.length(reward_table)]
                rewardId = reward_table[table.length(reward_table) - 1]
                rewardStr = _reward
            end
            

            FuncCommUI.regesitShowResView(itemCommonUI, rewardType, rewardNum, rewardId, rewardStr, true, true)
            itemCommonUI:setTouchSwallowEnabled(true)

            if itemPanel then
                -- itemCommonUI:setVisible(false)
                itemViewArr[#itemViewArr+1] = itemPanel
            end
        end

        -- 播放通用动画效果
        -- 坐标偏移值用于调整动画位置效果
        local ofssetX = 11
        local offsetY = -7
        FuncCommUI.playCommonRewardAnim(self,itemViewArr,ofssetX,offsetY)
    end
    -- echo("界面从哪过来的 = = = == = = == = = ",self._from)
    -- echo("是不是极品 = = = = = == = ",self._isBest)
    -- echo("是否有宝箱可以兑换 = = = = = = = ",self._isExchange)
    ---- 从挖宝界面过来的 
    local anim
    if self._from == FuncGuild.guildDig_Reward_From.DIGREWARD then
        ---- 应该先判断是不是挖到道具后可兑换   然后再判断是不是极品宝物
        if self._isExchange == true then
            self.txt_1:setVisible(true)
            self.txt_1:setString(GameConfig.getLanguage("#tid_guild_dig_003"))
            self.mc_2:setVisible(true)
            self.mc_2:showFrame(3)
            self.mc_2:getCurFrameView().btn_1:setTap(c_func(self.clickOk,self))
            self.mc_2:getCurFrameView().btn_2:setTap(c_func(self.goExchange,self))
            -- 奖品特效ß
            anim = FuncCommUI.addCommonBgEffect(self.ctn_1, FuncCommUI.EFFEC_TTITLE.GONGXIHUODE, c_func(showItem), true, true, -85)
            

            anim:registerFrameEventCallFunc(10, 1, function ( ... )
                self:registClickClose(nil, function ( ... )
                    self._callback();
                end);
            end);
        else
            -- 如果挖的宝物是极品  显示中间txt_1  隐藏动画下面的文字
            if self._isBest == true then 
                self.txt_1:setVisible(true)
                self.txt_1:setString(GameConfig.getLanguage("#tid_guild_dig_002"))
                self.mc_2:setVisible(true)
                self.mc_2:showFrame(1)
                self.mc_2:getCurFrameView().btn_1:setTap(c_func(self.clickOk,self))
                -- 奖品特效
                anim = FuncCommUI.addCommonBgEffect(self.ctn_1, FuncCommUI.EFFEC_TTITLE.GONGXIHUODE, c_func(showItem), true, true, -85)
                

                anim:registerFrameEventCallFunc(10, 1, function ( ... )
                    self:registClickClose(nil, function ( ... )
                        self._callback();
                    end);
                end);
            else
                ---- 普通道具
                self.txt_1:setVisible(false)
                self.mc_2:setVisible(false)
                -- 奖品特效ß
                anim = FuncCommUI.addCommonBgEffect(self.ctn_1, FuncCommUI.EFFEC_TTITLE.GONGXIHUODE, c_func(showItem), true, false, -85)
                
                anim:registerFrameEventCallFunc(10, 1, function ( ... )
                    self:registClickClose(nil, function ( ... )
                        self._callback();
                        self:startHide();
                    end);
                end);
            end

        end
    elseif self._from == FuncGuild.guildDig_Reward_From.DUIHUAN then
        self.txt_1:setVisible(false)
        self.mc_2:setVisible(true)
        self.mc_2:showFrame(1)
        self.mc_2:getCurFrameView().btn_1:setTap(c_func(self.clickOk,self))
        -- self.mc_2:getCurFrameView().btn_2:setTap(c_func(self.againOpen,self)) -----  再开一次先屏蔽
        anim = FuncCommUI.addCommonBgEffect(self.ctn_1, FuncCommUI.EFFEC_TTITLE.GONGXIHUODE, c_func(showItem), true, true, -85)
        self.showItem = showItem
                
        anim:registerFrameEventCallFunc(10, 1, function ( ... )
            self:registClickClose(nil, function ( ... )
                self._callback();
            end);
        end);
    end
end

function GuildDigRewardView:clickOk(  )
    self:startHide();
end

function GuildDigRewardView:goExchange(  )
    -- WindowControler:showWindow("GuildTreasureMainView",FuncGuild.guild_Treasure_Main_view_First.TREASURE)
    WindowControler:showWindow("GuildTreasureMainView")
    self:startHide();
end

function GuildDigRewardView:againOpen(  )
    GuildModel:clickAgainExchange(self._rewardID)
    self:startHide();
end

return GuildDigRewardView;