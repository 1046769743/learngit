local CompResTopSLView = class("CompResTopSLView", UIBase);

function CompResTopSLView:ctor(winName)
    CompResTopSLView.super.ctor(self, winName);
end

function CompResTopSLView:loadUIComplete()
	self:registerEvent();

	self:updateUI()
end 

function CompResTopSLView:registerEvent()
	CompResTopSLView.super.registerEvent();
    self.btn_xianyujiahao:setTap(c_func(self.press_btn_xianyujiahao, self));
	-- self._root:setTouchedFunc(c_func(self.onAddTap, self))
	 EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, 
        self.updateUI, self);  
end

function CompResTopSLView:press_btn_xianyujiahao()
	WindowControler:showWindow("GetWayListView",FuncTrail.TrailIiemId)
end


function CompResTopSLView:updateUI()
	local num = ItemsModel:getItemNumById(FuncTrail.TrailIiemId)
	self.txt_xianyu:setString(num)
end


return CompResTopSLView;
