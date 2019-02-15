
local CompMallItemView = class("CompMallItemView", UIBase);

function CompMallItemView:ctor(_winName)
    CompMallItemView.super.ctor(self, _winName);
end
--
function CompMallItemView:loadUIComplete()
	CompMallItemView.super.loadUIComplete(self)
end
function CompMallItemView:registerEvent()
end

function CompMallItemView:updateUI( d )
	self.data = d
	self.mc_malltop2:visible(false)
	if d._type == "recharge" then
		local data = d._data
		self.mc_1:showFrame(1)

		self.panel_1:visible(false)

		-- 得到的仙玉数
		local haveNum = data.gold
		self.mc_1.currentView.txt_1:setString(haveNum)
		-- 消费金额
		local cost = data.price
		self.txt_1:setString(cost.."元")

		--icon 
		local iconPath = FuncRes.iconRecharge(data.icon)
		local iconSpr = display.newSprite(iconPath)
		self.ctn_1:addChild(iconSpr)

		iconSpr:setTouchedFunc(c_func(self.btnTap,self,data))
	else
		local data = d._data
		self.mc_1:showFrame(2)
		local name = data.monthCardName
		self.mc_1.currentView.txt_1:setString(GameConfig.getLanguage(name))

		self.panel_1:visible(true)
		self.panel_1.txt_1:setString(GameConfig.getLanguage(name))

		self.panel_1.txt_1:setTouchedFunc(function (  )
			WindowControler:showWindow("MonthCardMainView", FuncMonthCard.CARDYEQIAN[data.monthCardLevel] )
		end)
		-- 消费金额
		local cost = data.cost
		self.txt_1:setString(cost.."元")

		local iconPath = FuncRes.iconRecharge(data.icon)
		local iconSpr = display.newSprite(iconPath)
		self.ctn_1:addChild(iconSpr)

		iconSpr:setTouchedFunc(c_func(self.btnTap,self,data))

	end

end

function CompMallItemView:btnTap(  )
	-- 跳到充值
	-- WindowControler:showTips("跳到充值")
	MonthCardModel:setChargeData(self.data)
	self:delayCall(function (  )
		WindowControler:showTips("充值仙玉")
		dump(self.data._data,"充值信息表里的 =====",5)
		
		local data = self.data._data
		local propId = data.id
		local propName = GameConfig.getLanguage(data.typeName) 
		-- 代币数量
		local propCount = data.gold
		local chargeCash = data.price -- 以分为单位
		PCChargeHelper:charge(propId,propName,propCount,chargeCash)
		
	end,1.0)
end

return CompMallItemView;
