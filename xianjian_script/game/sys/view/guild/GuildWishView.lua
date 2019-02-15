-- GuildWishView
-- Author: Wk
-- Date: 2017-10-12
-- 公会心愿界面
local GuildWishView = class("GuildWishView", UIBase);

function GuildWishView:ctor(winName)
    GuildWishView.super.ctor(self, winName);
end

function GuildWishView:loadUIComplete()

	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_049")) 
	
	self.selectItem = 1  ---默认第一个
	self.selectindex = 1
	self.select_partnerId = nil
	self.selectView = nil
	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)
	self:initData()
	self:setbutton()


	
end 
function GuildWishView:setbutton()
	
	
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self:registClickClose(-1, c_func( function()
        self:press_btn_close()
    end , self))

	self.UI_1.mc_1:showFrame(1)
	local btn_1 = self.UI_1.mc_1:getViewByFrame(1).btn_1
	local file,time =  GuildModel:getPleaseAddCount()
	if file == false then
		FilterTools.setGrayFilter(btn_1);
		btn_1:setTouchedFunc(c_func(self.notconfirmButton, self),nil,true);
	else
		FilterTools.clearFilter(btn_1);
		btn_1:setTouchedFunc(c_func(self.confirmButton, self),nil,true);
	end

end

function GuildWishView:notconfirmButton()
	if not GuildControler:touchToMainview() then
		return 
	end
	WindowControler:showTips(GameConfig.getLanguage("#tid_guild_050")) 
end



function GuildWishView:confirmButton()
	-- self.select_partnerId
	if not GuildControler:touchToMainview() then
		return 
	end
	echo("=====确定伙伴ID=======",self.select_partnerId)
	-- self.itemData
	---[[ 测试用
		-- GuildModel:setAllWishList({})
		-- EventControler:dispatchEvent(GuildEvent.REFRESH_WISH_LIST_EVENT)
		-- self:press_btn_close()
	--]]
	local item = {
		partnerID = self.select_partnerId,
		name = UserModel:name(),
		guildtype = GuildModel.guildName._type,
		position = GuildModel.MySelfGuildDataList.right,
		hasnum = 0,
		_time = TimeControler:getServerTime() + 22 * 3600,
		_id = UserModel:rid(),
	}



	local function _callback(param)
        if (param.result ~= nil) then
        	dump(param.result,"我的心愿数据返回",8)
        	GuildModel:setMySelfWishList(item)
        	EventControler:dispatchEvent(GuildEvent.REFRESH_WISH_LIST_EVENT)
         	self:press_btn_close()
        else
            
        end
    end
	local params = {
		id = self.select_partnerId,
	};
	GuildServer:sendSendWish(params,_callback)

end



-- function GuildWishView:registerEvent()
-- 	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
-- 		--创建
-- 	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
-- 	-- --加入
-- 	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
-- end

function GuildWishView:initData()

	local alldata = GuildModel:getAllPartnerData()

	self.panel_1:setVisible(false)
	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_1);
        self:updateItem(view,itemData)
        return view        
    end
	local params =  {
        {
            data = alldata,  ---alldata
            createFunc = createCellFunc,
            -- updateCellFunc = updateCellFunc,
            perNums = 3,
            offsetX = 40,
            offsetY = 10,
            widthGap = 0,
            heightGap = 5,
            itemRect = {x = 0, y = -127, width = 130, height =127},
            perFrame = 3,
        }
    }
    -- self.scroll_1:cancleCacheView();
	self.scroll_1:styleFill(params)

end
function GuildWishView:updateItem(view,itemData)



	local _partnerId = itemData.id  --伙伴ID
	view.UI_1:updataUI(_partnerId)

	view.panel_1:setVisible(false)
	if self.selectItem == self.selectindex then
		view.panel_1:setVisible(true)
		self.select_partnerId = _partnerId
		self.selectView = view.panel_1
	end
	view:setTouchedFunc(c_func(self.touchItem, self,view,itemData),nil,true);

	self.selectindex = self.selectindex + 1
end

function GuildWishView:touchItem(view,itemData)
	if not GuildControler:touchToMainview() then
		return 
	end
	local _partnerId = itemData.id  --伙伴ID
	self.selectView:setVisible(false)
	view.panel_1:setVisible(true)
	self.selectView = view.panel_1
	self.select_partnerId = _partnerId
	self.itemData = itemData
end

function GuildWishView:press_btn_close()
	self:startHide()
end


return GuildWishView;
