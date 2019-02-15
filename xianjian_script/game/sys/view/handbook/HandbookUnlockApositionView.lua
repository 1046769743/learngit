--
--Author:      zhuguangyuan
--DateTime:    2018-05-24 10:34:25
--Description: 名册系统 -- 解锁一个位置的弹窗
--


local HandbookUnlockApositionView = class("HandbookUnlockApositionView", UIBase);

function HandbookUnlockApositionView:ctor(winName,dirId,index)
    HandbookUnlockApositionView.super.ctor(self, winName)
    echo("______ dirId,index ____________",dirId,index)
    self.dirId = dirId
    self.index = index
end

function HandbookUnlockApositionView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function HandbookUnlockApositionView:registerEvent()
	HandbookUnlockApositionView.super.registerEvent(self);
	self.UI_1.btn_close:setTap(c_func(self.onClose,self))
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_handbook_jiesuo"))
	self:registClickClose("out")
end

function HandbookUnlockApositionView:initData()
	-- TODO
end

function HandbookUnlockApositionView:initView()
	-- self.txt_1:setString("解锁阵位")
	-- 解锁消耗
	local data = FuncHandbook.getOneDirData( self.dirId )
	-- dump(data, "data", nesting)
	self.txt_3:setString(data.index[tonumber(self.index)])

	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.confirmToUnlock, self))
	self.UI_1.btn_close:setTap(c_func(self.onClose, self))
end

function HandbookUnlockApositionView:confirmToUnlock()
	local data = FuncHandbook.getOneDirData( self.dirId )
	local cost  = tonumber(data.index[tonumber(self.index)] )
	if UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, cost, true) then
		if not self.hasSentRequest then
			self.hasSentRequest = true
			local function _callBack( serverData )
				self.hasSentRequest = false
				if serverData.error then
				else
					local data = serverData.result.data
					dump(data, "解锁一个阵位返回", nesting)
					WindowControler:showTips( GameConfig.getLanguage("#tid_handbook_jiesuochenggongtips"))
					EventControler:dispatchEvent(HandbookEvent.UNLOCK_ONE_POSITION)
					self:onClose()
				end
			end
			HandbookServer:unlockOnePosition(self.dirId,self.index,_callBack)
		end
	end

	
end
function HandbookUnlockApositionView:initViewAlign()
	-- TODO
end

function HandbookUnlockApositionView:updateUI()
	-- TODO
end

function HandbookUnlockApositionView:deleteMe()
	HandbookUnlockApositionView.super.deleteMe(self);
end

function HandbookUnlockApositionView:onClose()
	self:startHide()
end

return HandbookUnlockApositionView;
