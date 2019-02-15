local TrialDifficultySelectView = class("TrialDifficultySelectView", UIBase);

--[[
    self.UI_trial_difficulty,
    self.btn_2,
    self.btn_back,
    self.mc_ndbiaoti,
    self.scale9_1,
    self.scroll_mengban,
    self.txt_2,
    self.txt_chanchu,
]]

function TrialDifficultySelectView:ctor(winName, kind)
    self._kind = kind;
    TrialDifficultySelectView.super.ctor(self, winName);
end

function TrialDifficultySelectView:loadUIComplete()
    self._list = self.scroll_mengban;
	self:registerEvent();
    self:initUI();
end 

function TrialDifficultySelectView:registerEvent()
	TrialDifficultySelectView.super.registerEvent();
    self.btn_back:setTap(c_func(self.press_btn_back, self));
end

function TrialDifficultySelectView:press_btn_back()
    self:startHide();
end

function TrialDifficultySelectView:press_btn_2(data, isOpen)
    if isOpen == true then 
        WindowControler:showWindow("TrialDetailView", data);
    else 
        WindowControler:showTips(GameConfig.getLanguage("#tid_trail_011"));
    end 
end

function TrialDifficultySelectView:updateUI()
	
end

function TrialDifficultySelectView:initUI()
    self.mc_ndbiaoti:showFrame(self._kind);
    self:initList();
end

function TrialDifficultySelectView:initListData()
    self._listData = {};
    for i = 1, 5 do
        local id = TrailModel:getIdByTypeAndLvl(self._kind, i);
        table.insert(self._listData, id);
    end
end

function TrialDifficultySelectView:initList()
    self:initListData();

    self.btn_2:setVisible(false);

    local data = {3, 5};

    local createRankItemFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.btn_2)
        self:updateItem(view, itemData)
        return view
    end

    self._scrollParams = {
        {
            data = self._listData,
            createFunc = createRankItemFunc,
            perNums = 1,
            offsetX = 10,
            offsetY = 0,
            itemRect = {x=0, y=-59, width=250, height=59},
            widthGap = 10,
            perFrame = 0,
        },
    }

    self._list:styleFill(self._scrollParams);
end

function TrialDifficultySelectView:updateItem(itemView, data)
    
    local lvl = FuncTrail.getTrailData(data, "difficulty")
    echo("lvl:" .. tostring(lvl));
    itemView:getUpPanel().panel_nd1.mc_ndicon:showFrame(lvl);

    local playerLvl = UserModel:level();
    local needLvl = FuncTrail.getTrailData(data, "startLevel");
    local isOpen = true;
    if playerLvl < needLvl then 
        itemView:getUpPanel().panel_nd1.txt_1:setString(
            "开启等级" .. tostring(needLvl));
        isOpen = false;
    end 
    itemView:setTap(c_func(self.press_btn_2, self, data, isOpen))
end

return TrialDifficultySelectView;














