-- GuildExploreCheckPlayerView.lua
--[[
	Author: wk
	Date:2018-07-06
	Description: 查看看家详情
]]

local GuildExploreCheckPlayerView = class("GuildExploreCheckPlayerView", UIBase);

function GuildExploreCheckPlayerView:ctor(winName,data,controler)
    GuildExploreCheckPlayerView.super.ctor(self, winName)
    self.allData = data 
    self.controler = controler
end

function GuildExploreCheckPlayerView:loadUIComplete()
	self:registerEvent()
	self:initViewAlign()
	self:initData()
	
end 

function GuildExploreCheckPlayerView:registerEvent()
	GuildExploreCheckPlayerView.super.registerEvent(self);
	self:registClickClose("-1")
	self.panel_1:setVisible(false)
	self.UI_1.btn_close:setTap(c_func(self.startHide,self))
	self.UI_1.mc_1:setVisible(false)
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_Explore_des_125"))

end

function GuildExploreCheckPlayerView:initData()

	
	local createFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_1);
        self:cellLineUpviewData(baseCell, itemData)
        return baseCell;
    end
     local updateCellFunc = function (itemData,view)
    	self:cellLineUpviewData(view, itemData)
	end



    local  _scrollParams = {
        {
            data = self.allData,
            createFunc = createFunc,
            updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 5,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -88, width = 445, height = 88},
            perFrame = 1,
        }
    }    
    self.scroll_1:refreshCellView( 1 )
    self.scroll_1:styleFill(_scrollParams);
    self.scroll_1:hideDragBar()
    -- self.scroll_2.setEnableScroll(false)
end

function GuildExploreCheckPlayerView:cellLineUpviewData(baseCell, itemData)
    local userInfo = itemData.userInfo
	local guildType,postype = GuildExploreModel:getMemberAuth( itemData.rid )
	local str,spritename   = FuncGuild.byIdAndPosgetName(guildType,postype)
    local right = FuncRes.iconGuild(spritename)
    local icon = display.newSprite(right)
    icon:size(100,35)
    baseCell.ctn_t:removeAllChildren()
    baseCell.ctn_t:addChild(icon)

    baseCell.UI_2:setPlayerInfo(userInfo)
    local name = userInfo.name
    baseCell.txt_1:setString(name)
    local power = userInfo.ability or " no ability"
    baseCell.txt_3:setString(power)
    baseCell.btn_1:setTouchedFunc(c_func(self.checkPlayinfo, self,itemData),nil,true);
end

function GuildExploreCheckPlayerView:checkPlayinfo(itemData)
    self.controler:showOnePlayerInfo( itemData )
end

function GuildExploreCheckPlayerView:initView()
	-- TODO
end

function GuildExploreCheckPlayerView:initViewAlign()
	-- TODO
end

function GuildExploreCheckPlayerView:updateUI()
	-- TODO
end

function GuildExploreCheckPlayerView:deleteMe()
	-- TODO

	GuildExploreCheckPlayerView.super.deleteMe(self);
end

return GuildExploreCheckPlayerView;
