--
--Author:      zhuguangyuan
--DateTime:    2017-10-24 08:40:12
--Description: 仙盟GVE活动
--Description: 活动游戏规则
--


local GuildActivityRuleView = class("GuildActivityRuleView", UIBase);

function GuildActivityRuleView:ctor(winName)
    GuildActivityRuleView.super.ctor(self, winName)
end

function GuildActivityRuleView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildActivityRuleView:registerEvent()
	GuildActivityRuleView.super.registerEvent(self);
	self.UI_diban.btn_close:setTap(c_func(self.onClose, self))  
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP, self.onClose, self)
	
end
function GuildActivityRuleView:onClose()
	self:startHide()
end
function GuildActivityRuleView:initData()
	-- TODO
end

function GuildActivityRuleView:initView()
	self.UI_diban.txt_1:setVisible(false)
	self.UI_diban.panel_1:setVisible(false)
	self.UI_diban.mc_1:setVisible(false)
	self.rich_1:setVisible(false)

	self.txt_name:setString(GameConfig.getLanguage("#tid_guild_067")) 

	self:initScrollCfg()
end

function GuildActivityRuleView:initScrollCfg()
	local function createTxtFunc(themeData)
		local itemView = UIBaseDef:cloneOneView(self.rich_1)
			local ruleText = GameConfig.getLanguage("#tid_food_tip_3000")
			-- ruleText = GameConfig.getLanguage(ruleText)
			echo("GVE游戏规则",ruleText)
			itemView:setString(ruleText)
		return itemView
	end
	self.themeListParams =  {
		{
		   	data = {{}},
	        createFunc = createTxtFunc,
	        perNums= 1,
	        offsetX = 10,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 10,
	        itemRect = {x = 0,y = -600,width = 550,height = 600},
	        perFrame = 1,
	        cellWithGroup = 1
		}
	}	
end

function GuildActivityRuleView:initViewAlign()
	-- TODO
end
function GuildActivityRuleView:updateUI()
	self.scroll_huadong:styleFill(self.themeListParams);
end

function GuildActivityRuleView:deleteMe()
	-- TODO

	GuildActivityRuleView.super.deleteMe(self);
end

return GuildActivityRuleView;
