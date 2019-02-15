-- TrialSweepNewView
local TrialSweepNewView = class("TrialSweepNewView", UIBase);


local intervalTime = 0.7;

function TrialSweepNewView:ctor(winName, reward)

    TrialSweepNewView.super.ctor(self, winName);
    self.reward = reward or {};
end

function TrialSweepNewView:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function TrialSweepNewView:registerEvent()
	TrialSweepNewView.super.registerEvent();

    self.UI_1.btn_close:setTap(c_func(self.press_btn_close, self));
    self.UI_1.mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.press_btn_close, self));
    self:registClickClose(nil, function ()
        self:press_btn_close()
    end);

    -- self:setTouchedFunc(GameVars.emptyFunc, nil, true);
end
function TrialSweepNewView:initUI()
	for i=1,5 do
		self.panel_1["UI_"..i]:visible(false)
		if self.reward[i] ~= nil then
			self.panel_1["UI_"..i]:visible(true)
			self.panel_1["UI_"..i]:setResItemData({reward = self.reward[i]})
			self.panel_1["UI_"..i]:showResItemName(false)
			local reward = string.split(self.reward[i], ",");
			local rewardType = reward[1]
			local rewardNum = reward[3]
			local rewardId = reward[2]
			FuncCommUI.regesitShowResView(self.panel_1["UI_"..i],
	            rewardType, rewardNum, rewardId, self.reward[i], true, true);

		end
	end
	



end
function TrialSweepNewView:initUIs()


	-- self.scroll_1
	self.panel_1:visible(false)
	-- self.reward
	self.index = 1
	local createFunc = function (itemdata)
		local itemView = UIBaseDef:cloneOneView( self.panel_1 )
		self:updateItem(itemView, itemdata)
		return itemView
	end


	-- self.reward ={ 	
	-- 				[1] = {"1,4021,1","1,4022,2"},
	-- 				[2] = {"1,4022,3","1,4021,4"}
	-- 			}

		local newparams = {
			{
				data = self.reward,
				createFunc= createFunc,
				perNums=1,
				offsetX =10,
				offsetY =35,
				itemRect = {x=0,y=-150,width=464,height = 150},
				perFrame = 1,
				heightGap = 0
			}
		}

	-- 	table.insert(params,newparams)
	-- end
	-- dump(params,"",6)
	self.scroll_1:styleFill(newparams)


end
function TrialSweepNewView:updateItem(itemView,itemdata)
	dump(itemdata,"1111111111111")
	for i=1,5 do
		itemView["UI_"..i]:visible(false)
	end
	for i=1,#itemdata do
		local itemview = itemView["UI_"..i]
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
	local _str = string.format(GameConfig.getLanguage("#tid_trail_023"),tostring(self.index))
	itemView.txt_1:setString(_str)
	self.index = self.index + 1
end


function TrialSweepNewView:press_btn_close()
	self:startHide()
end





return TrialSweepNewView;






