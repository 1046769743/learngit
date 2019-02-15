-- CharBuyTouXianView
--三皇抽奖系统
--2016-12-27 10:40
--@Author:wukai

local CharBuyTouXianView = class("CharBuyTouXianView", UIBase);

function CharBuyTouXianView:ctor(winName)
    CharBuyTouXianView.super.ctor(self, winName);
end

function CharBuyTouXianView:loadUIComplete()
	self:registerEvent()
    self.UI_1.btn_close:setTap(c_func(self.press_btn_close,self))

    self:registClickClose(-1, c_func( function()
            self:press_btn_close()
    end , self))



    self.UI_1:setTouchEnabled(true)
    self:initData()

    -- currentView

end 
function CharBuyTouXianView:registerEvent()
	EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE,self.initData,self);
end
function CharBuyTouXianView:initData()
	local TouXianId = UserModel:crown()
	-- echo("=============1111111=========",TouXianId)
	if TouXianId >= 10 then
		self.mc_1:showFrame(2)
		self.UI_1.mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.TuiChuJView,self))
	else
		self:ShowData(TouXianId)
	end
end
function CharBuyTouXianView:TuiChuJView( ) 
	WindowControler:showTips(GameConfig.getLanguage("#tid_char_title_001"))
end
function CharBuyTouXianView:ShowData(TouXianId)
	self.mc_1:showFrame(1)
	local charAbility = UserModel:getAbility()
	
	self.mc_1.currentView.mc_1:showFrame(TouXianId)
	self.mc_1.currentView.mc_2:showFrame(TouXianId+1)
	-- local costdata = FuncChar.ByIDgetCharCrowndata(TouXianId+1)
	local costdata = FuncChar.ByIDgetCharCrowndata(TouXianId+1)
	local costs = string.split(costdata.cost[1], ",")
	self.mc_1.currentView.UI_2:setPower(costdata.condition)
	self.mc_1.currentView.txt_2:setString(costs[2])
	self.mc_1:getViewByFrame(1).mc_1.currentView.panel_red:setVisible(false)
    self.mc_1:getViewByFrame(1).mc_2.currentView.panel_red:setVisible(false)

	if  tonumber(UserModel:getCoin()) >= tonumber(costs[2]) then
		self.mc_1.currentView.txt_2:setColor(cc.c3b(0x7D,0x56,0x3c));
	else
		self.mc_1.currentView.txt_2:setColor(cc.c3b(255,0,0));
	end
	self.TouXianId = TouXianId
	self.UI_1.mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.queRenButton,self))
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_char_title_002")) 
	self.UI_1.mc_1:getViewByFrame(1).btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_char_title_003"))
end
function CharBuyTouXianView:queRenButton()
	local issure,_errortype = CharModel:isShowCharCrownRed()    --CharModel:getCharBility()
	if issure == false then
		if _errortype == 1 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_char_title_001"))
		elseif _errortype == 2 then
			WindowControler:showTips(GameConfig.getLanguage("tid_common_2054")) 
			FuncCommUI.showCoinGetView()
		elseif _errortype == 3 then
			WindowControler:showTips(GameConfig.getLanguage("tid_common_2023"))
		end
		return
	else
		-- local coin = UserModel:getCoin()
		-- local costdata = FuncChar.ByIDgetCharCrowndata(self.TouXianId+1)
		-- local costs = string.split(costdata.cost[1], ",")
		-- if tonumber(coin)  >= tonumber(costs[2]) then
			local callBack = function ( params )
	            -- dump(params.result,"购买头衔升级")
	            if params.result ~= nil then
	            	self:initData()
	            	 WindowControler:showWindow("PlayerTouXianPromotion");
	            	-- WindowControler:showTips("提升成功")
	                EventControler:dispatchEvent("BUY_TOUXIAN_EVENT")
	                self:press_btn_close()
	            end
	        end
			CharServer:SendTouXianShengJi(callBack)
		-- else
		-- 	WindowControler:showTips("铜钱不足")
		-- end
	end
end

function CharBuyTouXianView:press_btn_close()
    self:startHide()
end



return CharBuyTouXianView
