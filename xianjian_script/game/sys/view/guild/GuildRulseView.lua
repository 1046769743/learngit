-- GuildRulseView
-- Author: Wk
-- Date: 2017-11-20
-- 公会规则
local GuildRulseView = class("GuildRulseView", UIBase);

function GuildRulseView:ctor(winName,_type)
    GuildRulseView.super.ctor(self, winName);
    self._type = _type
end

function GuildRulseView:loadUIComplete()
	self:registClickClose("out")
	local defaultStr = "#tid_guild_042"
	if self._type == FuncGuild.Help_Type.WUJIGE then
		defaultStr = "#tid_group_rule_100"
	elseif self._type == FuncGuild.Help_Type.TASK then
		defaultStr = "#tid_group_rule_100"
    elseif self._type == FuncGuild.Help_Type.QIFU then
        defaultStr = "#tid_group_rule_103"
	end
	-- self.UI_1.txt_1:setString(GameConfig.getLanguage(defaultStr)) 
	
	self.UI_1.panel_1:setVisible(false)
	self.UI_1.txt_1:setVisible(false)
	self.UI_1.mc_1:setVisible(false)
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self:initScrollUI()
end
function GuildRulseView:iniData()
	local str = FuncGuild.getRulseStr(self._type)
	self.txt_12:setString(str)
end
function GuildRulseView:initScrollUI()
    self.rich_1:setVisible(false);

        local createRankItemFunc = function(itemData)
            local view = UIBaseDef:cloneOneView(self.rich_1);
            self:updateItem(view, itemData)
            return view;
        end
        self._scrollParams = {
            {
                    data = {1},
                    createFunc= createRankItemFunc,
                    perNums= 1,
                    offsetX =15,
                    offsetY = 20,
                    itemRect = {x=0,y=-600,width=530,height = 600},
                    perFrame = 1,
                    heightGap = 0
                }
        }
        self.indexID = self.openType
    self.scroll_1:styleFill(self._scrollParams);
end

function GuildRulseView:updateItem(view, itemData)

	local str = FuncGuild.getRulseStr(self._type)
	view:setString(str)

end


function GuildRulseView:press_btn_close()
	
	self:startHide()
end


return GuildRulseView;
