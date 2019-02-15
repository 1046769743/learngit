-- TrailPreviewView

--试炼系统
--2017-2-8 17:10
--@Author:wukai


local TrailPreviewView = class("TrailPreviewView", UIBase);
function TrailPreviewView:ctor(winName,_trailKind,_selectIndex)
    TrailPreviewView.super.ctor(self, winName);
    self._trailKind = _trailKind
    self._selectIndex = _selectIndex

    echo("======_trailKind========_selectIndex=====",_trailKind,_selectIndex) 
end

function TrailPreviewView:loadUIComplete()
	

	self.btn_close:setTap(c_func(self.press_btn_close,self))
	self:registClickClose(nil, function ()
        self:press_btn_close()
    end);
    self:initUI()

end 





function TrailPreviewView:initUI()
	local TrailId = TrailModel:getIdByTypeAndLvl(self._trailKind,self._selectIndex)
	local onekey = "trialReward1"
	local twokey = "trialReward2"
	local threekey = "trialReward3"
	local onedata = FuncTrail.getTrailData(TrailId, onekey)
	local twodata = FuncTrail.getTrailData(TrailId, twokey)
	local threedata = FuncTrail.getTrailData(TrailId, threekey)
	-- echo("====TrailId======",TrailId)
	-- dump(onedata,"1")
	-- dump(twodata,"2")
	-- dump(threedata,"3")
	local data_1 = {[1] = onedata}
	local data_2 = {[1] = twodata}-- -{{"1,4021,2","1,4022,3"}}
	local data_3 = {[1] = threedata}--{{"1,4021,3","1,4022,4"}}
	self.panel_1:visible(false)
	self._yulanindex = 1
	local createFunc = function (itemdata)
		local itemView = UIBaseDef:cloneOneView( self.panel_1 )
		self:updateItem(itemView, itemdata)
		return itemView
	end
	local params = {
		{
			data = data_1,
			createFunc= createFunc,
			perNums=1,
			offsetX =10,
			offsetY =30,
			itemRect = {x=0,y=-145,width=464,height = 145},
			perFrame = 1,
			heightGap = 0
		},
		{
			data = data_2,
			createFunc= createFunc,
			perNums=1,
			offsetX =10,
			offsetY =15,
			itemRect = {x=0,y=-145,width=464,height = 145},
			perFrame = 1,
			heightGap = 0
		},
		{
			data = data_3,
			createFunc= createFunc,
			perNums=1,
			offsetX =10,
			offsetY =15,
			itemRect = {x=0,y=-145,width=464,height = 145},
			perFrame = 1,
			heightGap = 0
		},
	}
	self.scroll_1:styleFill(params)

end
function TrailPreviewView:updateItem(view,itemdata)
	-- dump(itemdata,"数据赋值")
	view.txt_1:setString(self._yulanindex..GameConfig.getLanguage("#tid_trail_002")) 
	view.mc_1:showFrame(self._yulanindex)
	for i=1,5 do
		view["UI_"..i]:visible(false)
	end
	for i=1,#itemdata do
		local itemview = view["UI_"..i]
		if itemview ~= nil then
			itemview:visible(true)
			itemview:setResItemData({reward = itemdata[i]})
			itemview:showResItemName(false)
			local reward = string.split(itemdata[i], ",");
			local rewardType = reward[1]
			local rewardNum = reward[3]
			local rewardId = reward[2]
			FuncCommUI.regesitShowResView(itemview,
	            rewardType, rewardNum, rewardId, itemdata[i], true, true);
		end
	end
	self._yulanindex = self._yulanindex + 1
end

function TrailPreviewView:updateUI()
	
end





function TrailPreviewView:press_btn_close()
    self:startHide()
end

return TrailPreviewView;







