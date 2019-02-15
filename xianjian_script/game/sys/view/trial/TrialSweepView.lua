local TrialSweepView = class("TrialSweepView", UIBase);


local intervalTime = 0.7;

function TrialSweepView:ctor(winName, reward)

    TrialSweepView.super.ctor(self, winName);
    self.reward = reward or {};
end

function TrialSweepView:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function TrialSweepView:registerEvent()
	TrialSweepView.super.registerEvent();
    self:registClickClose("out");
    EventControler:addEventListener(TrialEvent.CLOSE_SWEEP_EVENT,
        self.startHide, self);

    self.panel_Bg.btn_close:setTap(c_func(self.startHide, self));
    self.panel_Bg.btn_1:setTap(c_func(self.startHide, self));

    self:setTouchedFunc(c_func(self.startHide, self));

    self.panel_Bg:setTouchedFunc(GameVars.emptyFunc, nil, true);
end

function TrialSweepView:initListt()
    self.panel_diban:setVisible(false);

    local createRankItemFunc = function(itemData)
        local view = UIBaseDef:cloneOneView(self.panel_diban);
        self:updateItem(view, itemData)
        return view;
    end

    self._scrollParams = {
        {
            data = self.reward,
            createFunc = createRankItemFunc,
            perFrame = 0,
        },
    }

    self.scroll_huadong:styleFill(self._scrollParams);
    
    self:playAction();
end

function TrialSweepView:setBtnClickEnable(isEnable)
    self.panel_Bg.btn_close:enabled(isEnable);
    self.panel_Bg.btn_1:enabled(isEnable);
end

function TrialSweepView:playAction()
    local allItem = self.scroll_huadong:getAllView();
    for i, itemView in ipairs(allItem) do
        if i <= 2 then 
            self:delayCall(function ()
                itemView:setVisible(true);
            end, intervalTime * (i - 1))
        else 
            self:delayCall(function ()
                echo("delayCall");
                itemView:setVisible(true);
                self.scroll_huadong:gotoTargetPos(i-1, 1, 0, 0.1 );

                --是否升级了
                if self:isLvlUp() then 
                    EventControler:dispatchEvent(UserEvent.USEREVENT_LEVEL_CHANGE, 
                        {level = UserModel:level()}); 
                end 

                self:setBtnClickEnable(true);
            end, intervalTime * (i - 1))
        end 
    end
end

function TrialSweepView:isLvlUp()
    local preLv = UserModel:getCacheUserData().preLv;
    local curLv = UserModel:level();

    if preLv ~= curLv then 
        return true;
    else 
        return false;
    end 
end

function TrialSweepView:updateItem(view, itemData)
    view:setVisible(false);
    local index = table.find(self.reward, itemData);
    view.mc_wenzi:showFrame(index);

    for i = 1, 3 do
        local reward = itemData[i];
        dump(reward, "reward");
        if reward == nil then 
            view["panel_daoju" .. tostring(i)]:setVisible(false);
            view["txt_djmingzi" .. tostring(i)]:setVisible(false);
        else 
            local data = string.split(reward, ",");
            dump(data, "data")
            local count = data[table.length(data)];

            view["panel_daoju" .. tostring(i)].txt_goodsshuliang:setString(tostring(count));
            
            local icon = FuncRes.iconRes(data[1], data[2]);
            echo("icon : " .. icon);
            local sprite =  display.newSprite(icon);

            view["panel_daoju" .. tostring(i)].ctn_1:addChild(sprite);

            local name = FuncItem.getItemName(data[2]);
            view["txt_djmingzi" .. tostring(i)]:setString(name);
        end 
    end
end

function TrialSweepView:initUI()
    -- self:setBtnClickEnable(false);
    self:initListt();
end

function TrialSweepView:updateUI()
	
end


return TrialSweepView;






