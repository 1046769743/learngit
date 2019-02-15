--
--Author:      zhuguangyuan
--DateTime:    2017-10-24 08:39:13
--Description: 仙盟GVE活动
--Description: 拥有食材能做成的菜品可以获得的奖励的规则界面
--


local GuildActivityRewardRuleView = class("GuildActivityRewardRuleView", UIBase);

function GuildActivityRewardRuleView:ctor(winName)
    GuildActivityRewardRuleView.super.ctor(self, winName)
end

function GuildActivityRewardRuleView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildActivityRewardRuleView:registerEvent()
	GuildActivityRewardRuleView.super.registerEvent(self);
	self.UI_diban.btn_close:setTap(c_func(self.onClose, self))  -- 返回
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP, self.onClose, self)
	
end
function GuildActivityRewardRuleView:onClose( ... )
	self:startHide()
end
function GuildActivityRewardRuleView:initData()
	-- TODO
end

function GuildActivityRewardRuleView:initView()
	self.UI_diban.txt_1:setVisible(false)
	self.UI_diban.panel_1:setVisible(false)
	self.UI_diban.mc_1:setVisible(false)
	self.panel_gundong:setVisible(false)

	self.txt_name:setString(GameConfig.getLanguage("#tid_guild_066")) 

	self:initScrollCfg()
end

function GuildActivityRewardRuleView:initScrollCfg()
	local createItemFunc = function ( _data )
		local itemView = UIBaseDef:cloneOneView(self.panel_gundong)
		local text = GameConfig.getLanguage("#tid_food_tip_3001")
		itemView.txt_1:setString(text)
		-- itemView.txt_2:setVisible(false)
		-- itemView.txt_3:setVisible(false)
		text = GameConfig.getLanguage("#tid_food_tip_3002")
		itemView.txt_4:setString(text)
		-- itemView.txt_5:setVisible(false)
		-- itemView.txt_6:setVisible(false)

		for i = 1,5 do
			local text = i.."星菜品奖励："
			local rewardData = FuncGuildActivity.getXXFoodLevelReward( GuildActMainModel:getCurFoodId(),i )
			for k,v in pairs(rewardData) do
				-- dump(v, "一个食材奖励")
				local itemArr = string.split(v, ",")
				text = text..FuncItem.getItemName(itemArr[2]).." X "..itemArr[3].." "
			end
			text =  "<color = CC6600>"..text.."<->"
			itemView["rich_"..i]:setString(text)	
		end
		return itemView
	end
	self.scrollParams = {
		{
	        data = {{}},
	        itemRect = {x=0,y=-380,width = 615,height = 379},
	        createFunc = createItemFunc,
	        perNums= 1,
	        offsetX = 15,
	        offsetY = 5,
	        widthGap = 4,
	        heightGap = 8,
	        perFrame = 1,	
		}
	}
end
function GuildActivityRewardRuleView:initViewAlign()
	-- TODO
end

function GuildActivityRewardRuleView:updateUI()
    self.scroll_huadong:styleFill(self.scrollParams)
end

function GuildActivityRewardRuleView:deleteMe()
	-- TODO

	GuildActivityRewardRuleView.super.deleteMe(self);
end

return GuildActivityRewardRuleView;
