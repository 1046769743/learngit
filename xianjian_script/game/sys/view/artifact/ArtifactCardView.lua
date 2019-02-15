-- ArtifactCardView
-- Author: Wk
-- Date: 2017-11-8
-- 神器抽卡单独UI
local ArtifactCardView = class("ArtifactCardView", UIBase);

function ArtifactCardView:ctor(winName,dataui)
    ArtifactCardView.super.ctor(self, winName);
end

function ArtifactCardView:loadUIComplete()
	self:registerEvent()
end 

function ArtifactCardView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)

end

--[[
	- "奖励数据结构===" = {
-     1 = "1,20201,1"
- }

奖励数据结构===" = {
   1 = "1,19001,68"
   2 = "1,30103,1"
   3 = "1,40401,1"
   4 = "1,40401,1"
   5 = "1,30101,1"
  }
]]




function ArtifactCardView:initData(reward,_callback)
	self._callback = _callback
	self.ctn_te:removeAllChildren()
	self.noder = display.newNode()
	self.ctn_te:addChild(self.noder,100)
	self.nodek = display.newNode()
	self.ctn_te:addChild(self.nodek,1100)

	local rewards = string.split(reward, ",");
	local rewardtype = rewards[1]
	local rewardid = rewards[2]
	local rewardnum = rewards[3]
	local itemdata = nil
	local sprite = nil
	local quality = nil
	local name = ""
	local scale = 1
	if tonumber(rewardtype) == tonumber(FuncDataResource.RES_TYPE.ITEM) then
		itemdata = FuncItem.getItemData(rewardid)
		if itemdata == nil then
			rewardid = "19001"  --当数据不存在时默认给一个阶石，为了不卡死游戏
			itemdata = FuncItem.getItemData(rewardid)
			rewardnum = 1
		end
		if itemdata.subType == FuncArtifact.ItemsubType.CONSUME then
			sprite = FuncRes.iconItem(rewardid)
		else
			sprite = FuncRes.iconCimelia( itemdata.icon)
			scale = 0.5
		end
		quality = itemdata.quality
		self.txt_1:setString(rewardnum or 1)
		name = GameConfig.getLanguage(itemdata.name)
		
	else
		sprite = FuncRes.iconRes(rewardtype)
		quality = FuncDataResource.getQualityById(rewardtype)
		scale = 0.9
		self.txt_1:setString(rewards[2])
		name = FuncDataResource.getResNameById(rewardtype,rewardid)
	end


	local icon = display.newSprite(sprite)
	icon:setScale(scale)
	self.ctn_1:removeAllChildren()
	self.ctn_1:addChild(icon)
	self.mc_fuzhou:showFrame(quality - 1 )
	self.mc_fuzhou:getViewByFrame(quality - 1).txt_1:setString(name)
	self:addEffcet(quality)
end

--加特效
function ArtifactCardView:addEffcet(quality)
	
	if quality >= 4 then
		self.ctn_1:setVisible(false)
		self.txt_1:setVisible(false)
		self.mc_fuzhou:showFrame(5)
		self.mc_fuzhou:setTouchedFunc(c_func(self.settouchFrame, self,quality),nil,true);
		self:addborderEffect(quality)
		ArtifactModel:setGoodCardNum(1)
	else
		
		self:delayCall(function( )
			self:dissolveCard(quality,true)
		end,0.2)
	end
end
--卡牌变边框特效
function ArtifactCardView:addborderEffect(quality)
	-- local _ctn = self.ctn_te
	local _ctn = self.nodek
	_ctn:removeAllChildren()
	local flaName = "UI_shenqi_chouka_d" 
	local armatureName = ""
	if quality == 4 then
		armatureName = "UI_shenqi_chouka_d_ziguang"
	else
		armatureName = "UI_shenqi_chouka_d_chengguang"
	end
	local aim = self:createUIArmature(flaName, armatureName ,_ctn, true ,function () end )
	aim:setPosition(cc.p(5,-5))
end
--溶解卡牌特效
function ArtifactCardView:dissolveCard(quality,_isfive)
	local ctn = self.noder
	ctn:removeAllChildren()
	local flaName = "UI_shenqi_chouka_b" 
	local armatureName = "UI_shenqi_chouka_b_fankai"
	local aim = self:createUIArmature(flaName, armatureName ,ctn, false ,function ()
		-- ctn:removeAllChildren()
		if not _isfive then
			self:addborderEffect(quality)
			-- self.mc_fuzhou:showFrame(tonumber(quality)-1)
			self.ctn_1:setVisible(true)
			self.txt_1:setVisible(true)
		end
		if self._callback then
			self._callback()
		end

	end)
	if not _isfive then
		ArtifactModel:setGoodCardNum(-1)
	end
	self.mc_fuzhou:setTouchEnabled(false)
	-- aim:getBoneDisplay("node1"):setVisible(false)
	self.ctn_1:setOpacity(0)
	self.ctn_1:setVisible(true)
	self.txt_1:setVisible(true)
	self.mc_fuzhou:showFrame(tonumber(quality)-1)
	self.ctn_1:runAction(act.fadeto(0.5,255))
	FuncArmature.changeBoneDisplay(aim, "node1", self.mc_fuzhou)  --替换
	self.mc_fuzhou:setPosition(cc.p(-192/2,295/2))
end



function ArtifactCardView:settouchFrame(quality)
	echo("=======quality11=========",quality)
	FuncArtifact.playArtifactFanPaiSound()
	self:dissolveCard(quality)

end

function ArtifactCardView:press_btn_close()
	
	self:startHide()
end


return ArtifactCardView;
