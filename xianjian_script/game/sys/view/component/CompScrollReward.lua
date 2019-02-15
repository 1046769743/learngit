--的tips显示
local CompScrollReward = class("CompScrollReward", UIBase);

function CompScrollReward:ctor(winName,rewards,callBack)
    CompScrollReward.super.ctor(self, winName);
    self.rewards = rewards
    self.closeCallBack = callBack
end

function CompScrollReward:loadUIComplete()
	self:registerEvent();
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.scroll_1,UIAlignTypes.Middle)

    self:updateUI();
end 

function CompScrollReward:registerEvent()
	CompScrollReward.super.registerEvent();
    
end
function CompScrollReward:updateUI()
    self.panel_reward:visible(false)
    local posX  = GameVars.gameResWidth / 2
    self.rewardPanel = {}
    local num = #self.rewards
    self.index = 0
    for i,v in pairs(self.rewards) do
        local _view = UIBaseDef:cloneOneView(self.panel_reward):addTo(self)
        _view:opacity(0)
        self:updatePanel(_view,v )
        table.insert(self.rewardPanel, _view)
        local posY = 50 - (GameVars.gameResHeight - num * 60) / 2 - (i-1) * 60
        self:delayCall(function (  )
            local yy = posY - 200
            _view:pos(posX,yy)
            local _anim = act.spawn(
                act.fadein(0.3),
                act.moveto(0.3,posX,posY)
                )
                _view:runAction(_anim) 

                self.index = self.index + 1
                if self.index >= num then
                    local closeFunc = function ( ... )
                        if self.closeCallBack then
                            self.closeCallBack()
                        end
                        self:startHide()
                    end
                    self:delayCall(function ( )
                        closeFunc()
                    end,1)
                    
                end
        end,0.2 * (i-1))
    end
end
function CompScrollReward:updatePanel( panel,data )
    local params = {
        reward = data,
    }
    panel.UI_1:setRewardItemData(params)
    panel.UI_1:showResItemName(false)
    panel.UI_1:showResItemNum(false)
    local name,quality,num = panel.UI_1:getItemInfo(  )
    panel.mc_zi:showFrame(quality+2)
    panel.mc_zi.currentView.txt_1:setString(name.."x"..num)
    panel.rich_2:visible(false)
end 


function CompScrollReward:updateUI_Feiqi()
    self.UI_reward:visible(false)

    local createFunc = function(_data)
        local _view = UIBaseDef:cloneOneView(self.UI_reward)
        self:updateViewItem(_view, _data)
        return _view
    end

    local updateCellFunc = function (_data,_view)
        self:updateViewItem(_view,_data)
    end
    local _param = {
        data = self.rewards,
        createFunc = createFunc,
        updateCellFunc = updateCellFunc,
        perNums = 1,
        offsetX = 207,
        offsetY = 47,
        widthGap = 10,
        heightGap = 0,
        itemRect = { x = 0, y = - 74, width = 414, height = 74 },
        perFrame = 1,
    }
    self.scroll_1:styleFill({_param})
end
function CompScrollReward:updateViewItem( _view,_data )
    _view:setRewardInfo(_data )
end


return CompScrollReward;
