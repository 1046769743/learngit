--
--Author:      zhuguangyuan
--DateTime:    2018-01-09 18:29:14
--Description: gve场景中点击弹出规则界面
--


local GuildActivitySceneRuleView = class("GuildActivitySceneRuleView", UIBase);

function GuildActivitySceneRuleView:ctor(winName)
    GuildActivitySceneRuleView.super.ctor(self, winName)
end

function GuildActivitySceneRuleView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildActivitySceneRuleView:registerEvent()
	GuildActivitySceneRuleView.super.registerEvent(self);
	self:registClickClose("out")
end

function GuildActivitySceneRuleView:initData()
	-- TODO
end

function GuildActivitySceneRuleView:initView()
	self.UI_1.txt_1:setString("玩法说明")
	self.UI_1.btn_close:setTap(c_func(self.onClose,self))
	self.UI_1.mc_1:showFrame(1)
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.onClose,self))
	self.panel_kb:visible(false)
	self:initScrollCfg()
end

function GuildActivitySceneRuleView:initScrollCfg( ... )
	local createItemFunc = function ( itemData )
		local itemView = UIBaseDef:cloneOneView(self.panel_kb)
		self:updateRuleTxtView(itemView,itemData)
		return itemView
	end

	self.scrollParams = {
		{
	        data = {{}},
	        createFunc = createItemFunc,
	        -- updateCellFunc = updateRaidFuncUnfold,
	        perNums= 1,
	        offsetX = 10,
	        offsetY = 2,
	        widthGap = 0,
	        heightGap = 10,
	        itemRect = {x=0,y=0,width = 778,height = 326}, 
	        perFrame = 1
		}
	}
end

function GuildActivitySceneRuleView:updateRuleTxtView( itemView,itemData )
	itemView:visible(true)
end
function GuildActivitySceneRuleView:initViewAlign()
	-- TODO
end

function GuildActivitySceneRuleView:updateUI()
	self.scroll_1:styleFill(self.scrollParams)
end

function GuildActivitySceneRuleView:onClose()
	self:startHide()
end
function GuildActivitySceneRuleView:deleteMe()
	-- TODO

	GuildActivitySceneRuleView.super.deleteMe(self);
end

return GuildActivitySceneRuleView;
