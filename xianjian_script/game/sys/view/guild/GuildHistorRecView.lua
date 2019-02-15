-- GuildHistorRecView
-- Author: Wk
-- Date: 2017-10-12
-- 公会历史记录界面
local GuildHistorRecView = class("GuildHistorRecView", UIBase);

function GuildHistorRecView:ctor(winName)
    GuildHistorRecView.super.ctor(self, winName);
end

function GuildHistorRecView:loadUIComplete()

	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_029")) 
	
	self.selectItem = 1  ---默认第一个
	self.selectindex = 1
	self.select_partnerId = nil
	self.selectView = nil
	self:registerEvent()
	self:initData()
	self:setbutton()
end 
function GuildHistorRecView:setbutton()
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self:registClickClose(-1, c_func( function()
        self:press_btn_close()
    end , self))

	self.UI_1.mc_1:showFrame(1) 
	self.UI_1.mc_1:getViewByFrame(1).btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("tid_common_2037"))
	self.UI_1.mc_1:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.confirmButton, self),nil,true);

end
function GuildHistorRecView:confirmButton()
	-- self.select_partnerId
	if not GuildControler:touchToMainview() then
		return 
	end
	echo("====  确定按钮  =======")
	self:press_btn_close()
end



function GuildHistorRecView:registerEvent()
	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end

function GuildHistorRecView:initData()

	local alldata = GuildModel:getAllHistorRec()
	local newalldata = {}
	for i=1,#alldata do
		local _info  = alldata[i]
		local receivedata = GuildModel._membersInfo[_info.receive]   --接受
		local senddata = GuildModel._membersInfo[_info.send]   ---发送
		if receivedata ~= nil or senddata ~= nil then
			table.insert(newalldata,_info)
		end
	end



	if #alldata == 0 then
		self.txt_1:setVisible(true)
	else
		self.txt_1:setVisible(false)
	end
	self.rich_1:setVisible(false)
	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.rich_1);
        self:updateItem(view,itemData)
        return view        
    end
	local params =  {
        {
            data = newalldata,  ---alldata
            createFunc = createCellFunc,
            -- updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 10,
            offsetY = 5,
            widthGap = 0,
            heightGap = 5,
            itemRect = {x = 0, y = -40, width = 450, height =40},
            perFrame = 1,
        }
    }
    -- self.scroll_1:cancleCacheView();
	self.scroll_1:styleFill(params)

end
function GuildHistorRecView:updateItem(view,itemData)
	-- local str = "玩家名字六字赠送了你李逍遥碎片x2"
	-- dump(itemData,"itemData = = = = == = = ")
	local itemid = itemData.itemId
	local itemdata = FuncItem.getItemData(itemid)
	dump(itemdata,"赠送了")
	local itemname = GameConfig.getLanguage(itemdata.name )  
	local receivedata = GuildModel._membersInfo[itemData.receive]   --接受
	local senddata = GuildModel._membersInfo[itemData.send]   ---发送
	if senddata ~= nil then
		local sendname =  "<color =  66cc00>"..senddata.name.."<->"
		local receivename ="<color =  66cc00>"..receivedata.name.."<->"
		if itemData.receive == UserModel:rid() then
			receivename = "您"
		end
		if  itemData.send ==  UserModel:rid() then
			sendname = "您"
		end

		local str = sendname.."赠送了"..receivename.."<color = a80ad5>"..itemname.."x1<->"
		view:setString(str)
	else
		echoError("==========获得历史事件错误，把标签<查看心愿历史事件列表>== log发我==================")
	end
end


function GuildHistorRecView:press_btn_close()
	self:startHide()
end


return GuildHistorRecView;
