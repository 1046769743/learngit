--
--Author:      zhuguangyuan
--DateTime:    2017-10-24 08:38:40
--Description: 仙盟GVE活动
--Description: 五轮战斗结束后获得食材和积分奖励界面
--


local GuildActivityKillMonsterRewardView = class("GuildActivityKillMonsterRewardView", UIBase);

function GuildActivityKillMonsterRewardView:ctor(winName,rewardData)
    GuildActivityKillMonsterRewardView.super.ctor(self, winName)
    self.rewardData = rewardData
    if FuncGuildActivity.isDebug then
    	dump(self.rewardData,"奖励信息")
    end
--   optional ComboReward comboReward =
--    {
-- 	  optional int32 score = 1;
-- 	  map<string, int32> ingredients = 2;
-- 	}
	if not self.rewardData then
		self.rewardData = {
			score = 20,
			ingredients = {
	            ["1"] = 0,
	            ["4"] = 0,
	            ["5"] = 0,
	            ["7"] = 0,
	            ["6"] = 0,
			},
		}
	end
	
	-- 2018.09.28线上包容错处理(从报错看食材数据混乱，桂花芙蓉糕里出现了淮王鱼羹的食材)
	-- 最大奖励展示数量
	self.maxRewardNum = 5
end

function GuildActivityKillMonsterRewardView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildActivityKillMonsterRewardView:registerEvent()
	GuildActivityKillMonsterRewardView.super.registerEvent(self);
	local zOrder = WindowControler:getWindowLastZorder("GuildActivityKillMonsterRewardView")
	self:registClickClose(zOrder)
	-- self:registClickClose("out")
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP, self.onClose, self)
end
function GuildActivityKillMonsterRewardView:onClose()
	self:startHide()
end
function GuildActivityKillMonsterRewardView:initData()
	-- TODO
end

-- 显示积分
function GuildActivityKillMonsterRewardView:showScoreNum( _mcView,_score )
-- 参照战力组件
	local mcView = _mcView or self.mc_shuzi
	local nums = number.split(_score)
    local len = table.length(nums);
    --不能高于6
    if len > 6 then 
        return
    end 
    mcView:showFrame(len);
    for k, v in ipairs(nums) do
        local mcs = mcView:getCurFrameView();
        local childMc = mcs["mc_" .. tostring(k)]
        childMc:showFrame(v + 1);
    end
end

function GuildActivityKillMonsterRewardView:initView()
	self.txt_jixu:setVisible(false)
	FuncCommUI.addCommonBgEffect(self.ctn_biaoti, FuncCommUI.EFFEC_TTITLE.GONGXIHUODE, nil, true, false)
	self:showScoreNum( self.mc_shuzi,self.rewardData.score )
	local numOfReward = table.length(self.rewardData.ingredients)
	if numOfReward <=0 then
		numOfReward = 1
		self.mc_2:visible(false)
		return
	elseif numOfReward > self.maxRewardNum then
		numOfReward = self.maxRewardNum
	end
	self.mc_2:showFrame(numOfReward)
	local contentView = self.mc_2:getCurFrameView()

	local i = 1
	for k,v in pairs(self.rewardData.ingredients) do
		if contentView["panel_"..i] == nil then
			return
		end
		contentView["panel_"..i].mc_xing:setVisible(false)
		contentView["panel_"..i].UI_1.mc_1:showFrame(1)
		local btnView = contentView["panel_"..i].UI_1.mc_1:getCurFrameView()
		if btnView.btn_1:getUpPanel().panel_1.panel_skin then
	        btnView.btn_1:getUpPanel().panel_1.panel_skin:setVisible(false)
	    end
		btnView.btn_1:getUpPanel().panel_1.txt_goodsshuliang:setString(v)
		btnView.btn_1:getUpPanel().panel_1.panel_red:setVisible(false)
		btnView.btn_1:getUpPanel().panel_1.mc_zi:showFrame(1)
		btnView.btn_1:getUpPanel().panel_1.mc_ziqian:setVisible(false)
		btnView.btn_1:getUpPanel().panel_1.mc_kuang:setTouchEnabled(true)
		btnView.btn_1:getUpPanel().panel_1.mc_kuang:setTouchedFunc(c_func(self.showTipView,self))

		local textView = btnView.btn_1:getUpPanel().panel_1.mc_zi:getCurFrameView()
		local materialName = FuncGuildActivity.getMaterialName(k)
		materialName = GameConfig.getLanguage(materialName)
		textView.txt_1:setString(materialName)

		local itemId = FuncGuildActivity.getMaterialIcon(k)
		local itemPath = FuncRes.getFoodIcon(itemId)
		itemSprite = display.newSprite(itemPath):anchor(0.5,0.5)
		itemSprite:pos(0,0)
		itemSprite:setScale(1)
		btnView.btn_1:getUpPanel().panel_1.ctn_1:removeAllChildren()
		btnView.btn_1:getUpPanel().panel_1.ctn_1:addChild(itemSprite)
		i = i + 1
	end
end
function GuildActivityKillMonsterRewardView:showTipView()
	echo("_____ 展示食材tips _____________ ")
end
function GuildActivityKillMonsterRewardView:initViewAlign()
	-- TODO
end

function GuildActivityKillMonsterRewardView:updateUI()
	-- TODO
end

function GuildActivityKillMonsterRewardView:deleteMe()
	-- TODO

	GuildActivityKillMonsterRewardView.super.deleteMe(self);
end

function GuildActivityKillMonsterRewardView:startHide()
	GuildActivityKillMonsterRewardView.super.startHide(self)
	-- 返回主界面
	-- 重登后正好遇到挑战结束 从主城展示该奖励界面 没有经过仙盟
	-- 再次创建队伍的时候会报错 原因是仙盟数据没有准备 所以加了仙盟数据准备语句
	--  准备guildModel的伙伴数据
 --    GuildControler:getMemberList("")
	-- WindowControler:showWindow("GuildActivityMainView")
end


return GuildActivityKillMonsterRewardView;
