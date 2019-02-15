--三皇抽奖系统
--2016-12-27 10:40
--@Author:wukai

local NewLotteryTwoSureView = class("NewLotteryTwoSureView", UIBase);

function NewLotteryTwoSureView:ctor(winName,types)
    NewLotteryTwoSureView.super.ctor(self, winName);
    self.types = types or 1
end

function NewLotteryTwoSureView:loadUIComplete()
	
    self.UI_1.btn_close:setTap(c_func(self.press_btn_close,self))

    self:registClickClose(nil, function ()
        self:press_btn_close()
    end);
    self:initData()

end 


function NewLotteryTwoSureView:initData()
	local onermb = FuncNewLottery.consumeOnceRMB()
	local tenrmb = FuncNewLottery.consumeTenRMB()
	if self.types == 1 then
		if NewLotteryModel:getRMBoneLottery() == 1 then
			if NewLotteryModel:getRMBPayLottery() == 0 then
				onermb = onermb/2
			end
		end
		self.txt_2:setString(onermb)
		self.txt_3:setString(GameConfig.getLanguage("#tid_chouka_025")) 
	else
		self.txt_2:setString(tenrmb)
		self.txt_3:setString(GameConfig.getLanguage("#tid_chouka_026"))
	end
	
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_chouka_027"))
	self.UI_1.mc_1:showFrame(1)
	self.UI_1.mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.queRenButton,self))

end
function NewLotteryTwoSureView:queRenButton()
	self:press_btn_close()
	EventControler:dispatchEvent("LOTTERY_TWO_QUEREN_BUOOTN")
end

function NewLotteryTwoSureView:press_btn_close()
    self:startHide()
end



return NewLotteryTwoSureView
