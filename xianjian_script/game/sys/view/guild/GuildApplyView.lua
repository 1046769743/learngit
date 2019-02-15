-- GuildApplyView
-- Author: Wk
-- Date: 2017-10-10
-- 申请界面界面
local GuildApplyView = class("GuildApplyView", UIBase);

function GuildApplyView:ctor(winName)
    GuildApplyView.super.ctor(self, winName);
end

function GuildApplyView:loadUIComplete()


	-- self.txt_1:setString("申请列表")
	-- self.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	-- self.sendquickJoin = false
	-- -- self:registClickClose("out")
	-- self:selectaddGuild()
	-- self:setButton()
	-- self:initData()
		-- 成员列表
	self.btn_1:setTouchedFunc(c_func(self.showMembleView, self),nil,true);
end 

function GuildApplyView:createGuildData()

	-- self.txt_1:setString(GameConfig.getLanguage("#tid_guild_013"))  
	-- self.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);


	self.sendquickJoin = false
	-- self:registClickClose("out")
	-- self:selectaddGuild()
	-- self:setButton()
	self:initData()
end

function GuildApplyView:registerEvent()
	EventControler:addEventListener(GuildEvent.GUILD_REMOVE_REFRESH_UI, self.initData, self)
	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)



end

function GuildApplyView:showMembleView()
	EventControler:dispatchEvent(GuildEvent.SHOW_MEMBLE_VIEW)

end

function GuildApplyView:initData()


	self.applyData = GuildModel.guildApplyList   

	-- dump(self.applyData,"33333333333")
	if #self.applyData ~= 0 then
		self.panel_3:setVisible(false)
	else
		self.panel_3:setVisible(true)
	end
	self.panel_2:setVisible(false)
	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_2);
        self:updateItem(view,itemData)
        return view        
    end
	local params =  {
        {
            data = self.applyData,  ---alldata
            createFunc = createCellFunc,
            -- updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = -5,
            widthGap = 0,
            heightGap = 10,
            itemRect = {x = 0, y = -95, width = 626, height = 95},
            perFrame = 1,
        }
        
    }
	self.scroll_1:styleFill(params)


end


function GuildApplyView:updateItem(view,itemData)
		
	local ability = itemData.abilityNew.formationTotal or itemData.abilityNew.total
	view.txt_1:setString(itemData.name)
	view.txt_2:setString(itemData.level)
	view.txt_3:setString(ability)

	-- view.panel_1.txt_1:setString(itemData.level)

	-- local _node = view.panel_1.ctn_1
	-- ChatModel:setPlayerIcon(_node,itemData.head,itemData.avatar ,0.5)

	view.UI_1:setPlayerInfo(itemData)
	view.btn_1:setTouchedFunc(c_func(self.refusebutton, self,itemData),nil,true);
	view.btn_2:setTouchedFunc(c_func(self.agreebutton, self,itemData),nil,true);
end
function GuildApplyView:agreebutton(itemData)
	if not GuildControler:touchToMainview() then
		return 
	end
	echo("========同意========")
	self:sendServeragree(itemData,1)
end
function GuildApplyView:refusebutton(itemData)
	if not GuildControler:touchToMainview() then
		return 
	end
	echo("========拒绝========")
	self:sendServeragree(itemData,0)
end

function GuildApplyView:sendServeragree(itemData,_type)
-- dump(itemData,"222222222222222")
	local function _callback(_param)
		dump(_param.result,"拒绝和同意返回数据",8)
		if _param.result then
			local resultData = _param.result.data.data
			-- if table.length(resultData) ~= 0 then
				GuildModel:removeAppData(itemData._id)
				GuildModel:setbaseInfoapplys(itemData._id)
				EventControler:dispatchEvent(GuildEvent.GUILD_AGREEANDNOTA_UI)
				self:initData()
			-- else
			-- 	WindowControler:showTips(GameConfig.getLanguage("#tid_guild_task_4007"))
			-- end
		else
			--错误的情况不需要处理
		end
	end 

	local params = {
		id = itemData._id,
		type = _type
	}

	GuildServer:judgeApply(params,_callback)
end



-- function GuildApplyView:setButton()
-- 	self.panel_4.btn_1:setTouchedFunc(c_func(self.quickToJoin, self),nil,true);
-- 	self.panel_4.btn_2:setTouchedFunc(c_func(self.declaration, self),nil,true);
-- end

--快速加入
function GuildApplyView:quickToJoin()
	-- echo("快速邀请 =======还未开发")
	-- if 1 then
	-- 	WindowControler:showTips("等待合并，即可使用")
	-- 	return 
	-- end
	if not GuildControler:touchToMainview() then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_007")) 
		return 
	end
	if not self.sendquickJoin then
		GuildModel:sendWorldInvite()
		self.sendquickJoin = true
	end
	-- self:delayCall(function ()
	-- 	self.sendquickJoin = false
 --    end,5)

	
end

--宣言
function GuildApplyView:declaration()
	if not GuildControler:touchToMainview() then
		return 
	end
	-- echo("宣言 =======还未开发")
	if not GuildModel:judgmentIsForZBoos() then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_001")) 
		return 
	end
	WindowControler:showWindow("GuildAnnouncement",1);
end



-- function GuildApplyView:selectaddGuild()
-- 	self._select = GuildModel.selectAddGuildType
-- 	local panel = self.panel_4
-- 	panel.panel_select:setTouchedFunc(c_func(self.selectbutton, self),nil,true);
-- 	if  self._select == 1 then
-- 		panel.panel_select.panel_dui:setVisible(false)
-- 	else
-- 		panel.panel_select.panel_dui:setVisible(true)
-- 	end
-- end
-- function GuildApplyView:selectbutton()
-- 	if not GuildControler:touchToMainview() then
-- 		return 
-- 	end
-- 	if not GuildModel:judgmentIsForZBoos() then
-- 		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_001"))
-- 		return 
-- 	end

-- 	local panel = self.panel_4
-- 	if self._select == 1 then 
-- 		self._select = 0
-- 		panel.panel_select.panel_dui:setVisible(true)
-- 	else
-- 		self._select = 1
-- 		panel.panel_select.panel_dui:setVisible(false)
-- 	end
-- 	GuildModel.selectAddGuildType =self._select 
-- 	self:sendServer()
-- end
function GuildApplyView:sendServer()
	local function _callback(_param)
		
		if _param.result then
			dump(_param.result,"配置修改数据返回",8)
			GuildModel:setneedApply(self._select)
		else
			--错误和没查找到的情况

		end
	end 

	local params = {
		-- icon = configs.icon,
		needApply = self._select
		-- desc = gettext
		-- notice = configs.notice
	};

	GuildServer:modifyConfig(params,_callback)
end

function GuildApplyView:press_btn_close()
	
	self:startHide()
end


return GuildApplyView;
