local TreasureMainView = class("TreasureMainView", UIBase)

function TreasureMainView:ctor(winName)
	TreasureMainView.super.ctor(self, winName)
end

function TreasureMainView:loadUIComplete()
    self:initList()
    
end

function TreasureMainView:initList()
    local data = FuncTreasureNew.getTreasureData()

    local itemPanel = self.panel_latiao.mc_1
    local createFunc = function ( itemData )
		local view = UIBaseDef:cloneOneView(itemPanel)
		self:updateItem(view, itemData)
		return view
    end
    local reuseUpdateCellFunc = function (itemData, view)
        self:updateItem(view, itemData,true)
        return view;  
    end
    
	local _scrollParams = {
			{
				data = data,
				createFunc= createFunc,
				perFrame = 1,
				offsetX =0,
				offsetY =0,
				itemRect = {x=0,y= -130,width=130,height = 130},
				widthGap = 5,
                heightGap = 0,
                updateFunc = reuseUpdateCellFunc,

			}
		}
    self.panel_latiao.scroll_1:styleFill(_scrollParams);
	self.panel_latiao.scroll_1:hideDragBar()
end

function TreasureMainView:updateItem(view,data)
    view:showFrame(1)

    -- 星级
    local star = 1
    view.currentView.mc_dou:showFrame(star)
    -- 品质
    local quality = 1
    view.currentView.mc_2:showFrame(quality)
    -- icon
    -- local icon = 
    -- 选中框
    view.currentView.panel_1:visible(false)
end

function TreasureMainView:setAlignment()
	--设置对齐方式
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_3, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_1, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_icon, UIAlignTypes.LeftTop)
    FuncCommUI.setScale9Align(self.widthScreenOffset,self.scale9_1,UIAlignTypes.MiddleTop, 1, 0)
end
function TreasureMainView:registerEvent()
    TreasureMainView.super.registerEvent();
    self.btn_back:setTap(c_func(self.onBtnBackTap,self))
end


--返回 
function TreasureMainView:onBtnBackTap()
	self:startHide()
end

return TreasureMainView
