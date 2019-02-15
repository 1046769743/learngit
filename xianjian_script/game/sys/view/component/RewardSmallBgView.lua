--10个以下获得奖励弹窗
--guan
--2016.7.15

local RewardSmallBgView = class("RewardSmallBgView", UIBase);

function RewardSmallBgView:ctor(winName, itemArray, callBack, tipStr)
    RewardSmallBgView.super.ctor(self, winName);
    dump(itemArray, "\n\n---itemArray---");
    self._itemArray = itemArray;
    self._callback = callBack or GameVars.emptyFunc;
    self.tipStr = tipStr
end

function RewardSmallBgView:loadUIComplete()
	self:registerEvent();
    self.mc_1:setVisible(false)
	self:initUI();
    AudioModel:playSound(MusicConfig.s_com_reward);
end 

function RewardSmallBgView:registerEvent()
	RewardSmallBgView.super.registerEvent();
end

--初始化界面
function RewardSmallBgView:initUI()
    self.txt_tips:setVisible(false)
    self.txt_tips:opacity(0)
    if self.tipStr then
        self.txt_tips:setString(self.tipStr)
    end

    local itemViewArr = {}

    local showItem = function ()
        if not self._itemArray then
            echoError("__没有传入道具",self._itemArray )
            return
        end
        
        local itemNum = table.length(self._itemArray);

        if itemNum > 10 then 
            echo("warning!!!  RewardSmallBgView:initUI() itemNum is more then 10!!!");
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

    -- 奖品特效
    local anim = FuncCommUI.addCommonBgEffect(self.ctn_1, FuncCommUI.EFFEC_TTITLE.GONGXIHUODE, c_func(showItem), true, false, -85)
    -- local anim = FuncCommUI.playSuccessArmature(self.UI_1, 
    --     FuncCommUI.SUCCESS_TYPE.GET, 2, true);

    -- FuncCommUI.addBlackBg(self.widthScreenOffset,self._root);

    anim:registerFrameEventCallFunc(10, 1, function ( ... )
		self:registClickClose(nil, function ( ... )
			self._callback();
            self:startHide();
		end);
        if self.tipStr then
            self.txt_tips:setVisible(true)
            self.txt_tips:fadeIn(0.5)
        end
		-- self:registClickClose();
    end);
end

return RewardSmallBgView;











