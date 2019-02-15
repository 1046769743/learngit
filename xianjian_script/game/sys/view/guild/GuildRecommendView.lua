-- GuildRecommendView
-- Author: Wk
-- Date: 2017-09-29
-- 公会推荐可以申请的玩家view
local GuildRecommendView = class("GuildRecommendView", UIBase);

function GuildRecommendView:ctor(winName)
    GuildRecommendView.super.ctor(self, winName);
end

function GuildRecommendView:loadUIComplete()
	self:registerEvent()
	self.panel_1:setVisible(false)
	-- self:initData()
end 

function GuildRecommendView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end
function GuildRecommendView:initData()

	local numberdata = GuildModel.inviteDataList   
	self.panel_zwtj:setVisible(false)
	if #numberdata == 0 then
		self.panel_zwtj:setVisible(true)
	end

	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_1);
        self:updateItem(view,itemData)
        return view        
    end

 	local params =  {
        {
            data = numberdata,
            createFunc = createCellFunc,
            updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 10,
            offsetY = 0,
            widthGap = 0,
            heightGap = 2,
            itemRect = {x = 0, y = -130, width = 930, height =130},
            perFrame = 1,
        }
        
    }
    self.scroll_1:styleFill(params)


end
function GuildRecommendView:updateItem(view,itemData)
	dump(itemData,"玩家详情",8)
	local level = view.txt_2
	local invitebutton = view.mc_1:getViewByFrame(1).btn_1
	local power = view.txt_3
	local name = view.txt_1
	local headpanel = view.panel_1
	local _node = headpanel.ctn_1
	--添加圆形头像
	ChatModel:setPlayerIcon(_node,itemData.head,itemData.avatar ,0.9)
	--设置等级
	headpanel.txt_1:setString(itemData.level or 1)
	level:setVisible(false)
    -- setString(itemData.level or 1)
	--设置玩家名称
    local nnname = itemData.name
    if itemData.name == nil or itemData.name == "" then
        nnname = GameConfig.getLanguage("tid_common_2006")  
    end
	name:setString(nnname)
	--设置战力
	local ability = 0
    if itemData.abilityNew ~= nil then
        if itemData.abilityNew.formationTotal ~= nil then
            ability = itemData.abilityNew.formationTotal
        end
    end
	power:setString(GameConfig.getLanguage("#tid_guild_040") .. ability) 
	--设置按钮
	invitebutton:setTouchedFunc(c_func(self.clickinvite, self,view,itemData),nil,true);
	headpanel:setTouchedFunc(c_func(self.getPlayerInfo, self,itemData),nil,true);
end
function GuildRecommendView:getPlayerInfo(itemData)
if not GuildControler:touchToMainview() then
        return 
    end
    local  function   callback(param)
        if(param.result~=nil)then
            WindowControler:showWindow("CompPlayerDetailView",param.result.data.data[1],self,3)--param.result.data.data[1],self,2);--//从好友系统中进入
        end
    end
    local   param={};
    param.rids={};
    param.rids[1]=itemData._id;
    ChatServer:queryPlayerInfo(param,callback);
end

--邀请按钮
function GuildRecommendView:clickinvite(view,itemData)
if not GuildControler:touchToMainview() then
        return 
    end
	echo("======邀请======")
	local function callback(param)
        if (param.result ~= nil) then
        	dump(param.result,"邀请返回数据",8)
        	view.mc_1:showFrame(2)
        	-- local invitebutton = view.mc_1:getViewByFrame(2).btn_1
        	-- invitebutton:setTouchedFunc(c_func(self.alreadyinvite, self),nil,true);
        end
    end

	local params = {
		id = itemData._id
	};	
	GuildServer:inviteMember(params,callback)
	
end


function GuildRecommendView:alreadyinvite()
	WindowControler:showTips(GameConfig.getLanguage("#tid_guild_041")) 
end


return GuildRecommendView;
