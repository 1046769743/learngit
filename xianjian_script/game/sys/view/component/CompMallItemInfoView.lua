local CompMallItemInfoView = class("CompMallItemInfoView", UIBase)

function CompMallItemInfoView:ctor(winName, data)
	CompMallItemInfoView.super.ctor(self, winName)
	self.data = data
end

function CompMallItemInfoView:loadUIComplete()
	self:registerEvent()
end

function CompMallItemInfoView:registerEvent()
	self.UI_1.btn_close:setTap(c_func(self.close,self))

    self.updateUI()
end



function CompMallItemInfoView:updateUI()
    local data = self.data
    if data._type == "recharge" then

        -- 得到的仙玉数
        local haveNum = data.gold
        self.mc_1.currentView.txt_1:setString(haveNum)
        -- 消费金额
        local cost = data.rmb
        self.txt_1:setString(cost.."元")

        --icon 
        local iconPath = FuncRes.iconRecharge(data.icon)
        local iconSpr = display.newSprite(iconPath)
        self.ctn_1:addChild(iconSpr)

    else
        local name = data.monthCardName
        self.panel_1.txt_1:setString(GameConfig.getLanguage(name))

        -- 消费金额
        local cost = data.cost
        self.txt_1:setString(cost.."元")

        local iconPath = FuncRes.iconRecharge(data.icon)
        local iconSpr = display.newSprite(iconPath)
        self.ctn_1:addChild(iconSpr)

    end
end

function CompMallItemInfoView:btnTap()
    
end


function CompMallItemInfoView:close()
	self:startHide()
end

return CompMallItemInfoView
