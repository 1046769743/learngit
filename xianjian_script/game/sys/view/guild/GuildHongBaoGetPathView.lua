-- GuildHongBaoGetPathView.lua
-- Author: Wk
-- Date: 2018-03-07
-- 公会红包过去路径界面
local GuildHongBaoGetPathView = class("GuildHongBaoGetPathView", UIBase);

function GuildHongBaoGetPathView:ctor(winName)
    GuildHongBaoGetPathView.super.ctor(self, winName);
end

function GuildHongBaoGetPathView:loadUIComplete()
	self:registerEvent()

    self.panel_1.panel_1:setVisible(false)
    self.panel_2.panel_1:setVisible(false)
    self:initData()
end 

function GuildHongBaoGetPathView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	self.UI_1.btn_1:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	-- --加入
  self.UI_1.txt_1:setString( GameConfig.getLanguage("#tid_guild_redpacket_010"))

end

function GuildHongBaoGetPathView:onBecomeTopView()


    if GuildRedPacketModel.redPAcketView then
        GuildRedPacketModel.redPAcketView:setVisible(false)
    end

    local function callBack(event)
        self:initData()
    end

    GuildRedPacketModel:getServeData(callBack)


end




function GuildHongBaoGetPathView:initData()

    local dailyData,achievementData = GuildRedPacketModel:getPathAllData()



	self.dailyData = dailyData  --每日红包数据
	self.achievementData = achievementData  --成就数据

	self:setDailyHongBaoList()
	self:setAchievementList()

    -- self.panel_1:setVisible(true)
    -- self.panel_2:setVisible(true)
end

--设置每日红包获取列表
function GuildHongBaoGetPathView:setDailyHongBaoList()
	local panel = self.panel_1
	panel.panel_1:setVisible(false)
	panel.txt_x:setVisible(false)
	if self.dailyData and table.length(self.dailyData) == 0 then
		panel.txt_x:setVisible(true)
    panel.scroll_1:setVisible(false)
		return 
	end
	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(panel.panel_1);
        self:updateLeftCell(view,itemData)
        return view        
    end

    local function updateCellFunc(itemData,view)
    	 self:updateLeftCell(view,itemData)
    end
	local params =  {
        {
            data = self.dailyData,
            createFunc = createCellFunc,
            updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = -2,
            offsetY = 5,
            widthGap = 0,
            heightGap = 3,
            itemRect = {x = 0, y = -85, width = 481, height =85},
            perFrame = 0,
        }
        
    }
    panel.scroll_1:setVisible(true)
    panel.scroll_1:cancleCacheView()
    panel.scroll_1:styleFill(params)
    panel.scroll_1:hideDragBar(  )
end


function GuildHongBaoGetPathView:updateLeftCell(view,itemData)
	-- dump(itemData,"数据===111=====")
     self:commonUI(view,itemData)
end


--设置每日红包获取列表
function GuildHongBaoGetPathView:setAchievementList()
	local panel = self.panel_2
	panel.panel_1:setVisible(false)
	panel.txt_x:setVisible(false)
	if self.achievementData and table.length(self.achievementData) == 0 then
      panel.scroll_1:setVisible(false)
		  panel.txt_x:setVisible(true)
		return 
	end
	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(panel.panel_1);
        self:updateRightCell(view,itemData)
        return view        
    end

    local function updateCellFunc(itemData,view)
    	 self:updateRightCell(view,itemData)
    end
	local params =  {
        {
            data = self.achievementData,
            createFunc = createCellFunc,
            updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = -2,
            offsetY = 5,
            widthGap = 0,
            heightGap = 5,
            itemRect = {x = 0, y = -85, width = 481, height =85},
            perFrame = 0,
        }
        
    }
    panel.scroll_1:setVisible(true)
    panel.scroll_1:cancleCacheView()
    panel.scroll_1:styleFill(params)
    panel.scroll_1:hideDragBar(  )
end

function GuildHongBaoGetPathView:updateRightCell(view,itemData)
	-- dump(itemData,"数据===2222=====")
    self:commonUI(view,itemData)
end



function GuildHongBaoGetPathView:commonUI(view,itemData)
   local desc = FuncGuild.getRedPacketType(itemData.id,"description")  
   view.txt_1:setString(GameConfig.getLanguage("#tid_guild_redpacket_011")..GameConfig.getLanguage(desc))
   local condition = itemData.condition

   for k,v in pairs(FuncGuild.RedPacket_Conditions) do
        if itemData.type == v then
            condition = 1
        end
   end

   local isFinsh,count =  GuildRedPacketModel:completeConditionsAndCount(itemData.id)


   local jindu = count.."/"..condition  --处理一下
   view.txt_2:setString(GameConfig.getLanguage("#tid_guild_redpacket_011")..jindu)


   view.ctn_1:removeAllChildren()

   local rewardType = itemData.rewardType
    
   local iconPath = FuncRes.iconRes(rewardType)---资源路径
   local icon = display.newSprite(iconPath)
   view.ctn_1:addChild(icon)
   icon:setScale(0.4)
   local num = itemData.reward
   view.txt_3:setString("x"..num)

   view:setTouchedFunc(c_func(self.getButton, self,itemData),nil,true);

end


--获取的按钮，--跳转到不同系统界面
function GuildHongBaoGetPathView:getButton(itemData)
    echo("=======跳转到对应系统界面===========",itemData.id)
    -- self:press_btn_close()
    GuildRedPacketModel:goToRedPacketPathView(itemData.id)

end



function GuildHongBaoGetPathView:press_btn_close()
	
	self:startHide()
end


return GuildHongBaoGetPathView;
