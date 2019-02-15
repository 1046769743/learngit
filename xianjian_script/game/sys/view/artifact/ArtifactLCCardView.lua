-- ArtifactLCCardView
-- Author: Wk
-- Date: 2017-11-8
-- 神器抽卡连抽UI
local ArtifactLCCardView = class("ArtifactLCCardView", UIBase);

function ArtifactLCCardView:ctor(winName,_type,reward)
    ArtifactLCCardView.super.ctor(self, winName);

end


function ArtifactLCCardView:loadUIComplete()
	-- self:registerEvent()
	-- self:initData()

end 

function ArtifactLCCardView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end
function ArtifactLCCardView:initData(_type,reward,_callback)


	 -- dump(reward,"奖励数据结构===",6)
	 -- echo("====_type=======",_type)
	self._callback = _callback
    self._type = _type
    self.reward = reward

	local frame = 1
	if self._type == 1 then
		frame = 1
	else 
		frame = 2
	end
	local _ctn = self.ctn_1
	_ctn:removeAllChildren()
	self.cardui = {}
	self.mc_1:setVisible(false)
	local mc_view =  UIBaseDef:cloneOneView(self.mc_1)  --self.mc_1:getViewByFrame(frame)
	_ctn:addChild(mc_view)
	mc_view:setVisible(false)
	for i=1,self._type do
		self.cardui[i] = mc_view:getViewByFrame(frame)
		self.cardui[i]["UI_"..i]:initData(self.reward[i],_callback)
		self.cardui[i]["UI_"..i]:setVisible(false)
	end
	self:addEffectChouKa(self._type,_callback)

end


--添加抽卡特效
function ArtifactLCCardView:addEffectChouKa(_type,_callback)
	local _ctn = self.ctn_1
	local node = display.newNode()
	node:anchor(0.5,0.5)
	node:size(250,360)
	node:pos(250/2,360/2)
	_ctn:addChild(node)
	node:zorder(1000)
	local flaName = "UI_shenqi_chouka_a" 
	local armatureName = ""
	if _type == 1 then
		armatureName = "UI_shenqi_chouka_a_danchou"
	else
		armatureName = "UI_shenqi_chouka_a_wulianchou"
	end
	if _type == 1 then
		local aim = self:createUIArmature(flaName, armatureName ,_ctn, false ,function ()
			if _type == 1 then
				local rewards = string.split(self.reward[1], ",");
				local rewardid = rewards[2]
				local rewardtype = rewards[1]
				if tonumber(rewardtype) == tonumber(FuncDataResource.RES_TYPE.ITEM) then
					local  itemdata = FuncItem.getItemData(rewardid)
					quality = itemdata.quality
				else
					quality = FuncDataResource.getQualityById(rewardtype)
				end
				local aims = self:effectchouka(_ctn)
				FuncArmature.changeBoneDisplay(aims, "node1", self.cardui[1]["UI_1"])  --替换
				self.cardui[1]["UI_1"]:setPosition(cc.p(-189/2,290/2))
				aims:playWithIndex(0)
			else   ---五抽 
				-- node:removeFromParent()
			end
			-- if _callback ~= nil then
			-- 	_callback()
			-- end
		end)
	end
	local num = _type

	local pames = {
		[1] = 26,
		[2] = 27,
		[3] = 28,
		[4] = 29,
		[5] = 30,
	}
	
	---[[
	if _type ~= 1 then
		self:delayCall(function ()
			local aim = self:createUIArmature(flaName, armatureName ,_ctn, false ,function ()
			end)
			aim:startPlay(false, false)
			local boneNameArr = {
				"a51","a52","a53","a54","a55"
			}
			local offsetPos = {x=-21,y=-19}
			for i,v in ipairs(boneNameArr) do
				aim:getBoneDisplay(v):startPlay(false,false)
				local childAni = aim:getBoneDisplay(v)
				local flaName = "UI_shenqi_chouka_b"
				local armatureName = "UI_shenqi_chouka_b_fankai"
				local nd = display.newNode()
				local child_childAni = self:createUIArmature(flaName, armatureName ,nd, false ,GameVars.emptyFunc)
				child_childAni:pos(offsetPos.x,offsetPos.y)
				child_childAni:startPlay(false, stopChild)
				child_childAni:playWithIndex(0)
				FuncArmature.changeBoneDisplay( childAni,"a1",nd )
				FuncArmature.changeBoneDisplay(child_childAni, "node1", self.cardui[i]["UI_"..i])  --替换
				self.cardui[i]["UI_"..i]:setPosition(cc.p(-235/2-offsetPos.x,254/2-offsetPos.y))
			end
			echo("===========time===1============",os.clock())
		end,0.05)
	end
	--]]
end

function ArtifactLCCardView:effectchouka(aimbone,isBone)
	local index = index or 1
	local flaName = "UI_shenqi_chouka_b" 
	local armatureName = "UI_shenqi_chouka_b_fankai"
	local aim = self:createUIArmature(flaName, armatureName ,aimbone, true ,GameVars.emptyFunc)
	
	if isBone then
		aimbone:addDisplay(aim,0)
	else

	end
	aim:parent(aimbone)

	return aim
end

--溶解卡牌特效
function ArtifactLCCardView:dissolveCard(index,_ctn,quality)
	-- _ctn:removeAllChildren()
	local index = index or 1
	local aim = self:effectchouka(_ctn)
	FuncArmature.changeBoneDisplay(aim, "node1", self.cardui[index]["UI_"..index])  --替换
	aim:playWithIndex(1)
	self.cardui[index]["UI_"..index]:setPosition(cc.p(-189/2,290/2))
	if quality ~= nil then
		_ctn:setTouchEnabled(false)
	end
	-- echo("32333333333333333333333")
	if self._callback then
		-- echo("444444444444444444444")
		self._callback()
	end
end

--卡牌变边框特效
function ArtifactLCCardView:addborderEffect(node,quality,_file)
	
	local flaName = "UI_shenqi_chouka_d" 
	local armatureName = ""
	if quality >= 4 then
		armatureName = "UI_shenqi_chouka_d_ziguang"
	else
		armatureName = "UI_shenqi_chouka_d_chengguang"
	end
	local aim = self:createUIArmature(flaName, armatureName ,node, true ,function ()

	end )
	aim:zorder(2000000)
	aim:setPosition(cc.p(0,0))
	if _file ~= nil then
		node:setTouchedFunc(c_func(self.dissolveCard, self,nil,node,quality),nil,true);
	end
	-- aim:startPlay(false, true )
end


function ArtifactLCCardView:press_btn_close()
	EventControler:dispatchEvent(ArtifactEvent.ACTEVENT_CHOUKA_BACK_IN_UI)
	self:startHide()
end


return ArtifactLCCardView;
