local BattleDebugHeroView = class("BattleDebugHeroView", UIBase);

--[[
    self.UI_MyTest,
    self.txt_goodsshuliang,
]]

function BattleDebugHeroView:ctor(winName)
    BattleDebugHeroView.super.ctor(self, winName);
end

function BattleDebugHeroView:loadUIComplete()
	
end 
--设置controler
function BattleDebugHeroView:setControler( controler )
	self.controler = controler      
	--必须是pve 才可以
	if self.controler.gameMode ~= Fight.gameMode_pve  then
		self._root:visible(false)
		return
	end

	self:updateInfo()

	self.mc_1:setTouchedFunc(c_func(self.pressSureBtn,self),nil,true)

end

function BattleDebugHeroView:pressSureBtn(  )
	echo("_____aaaaaaaaa")

	--如果不是调试模式的
	if not self.controler.isDebugHero then
		self.mc_1:showFrame(2)
		self.controler:setDebugHero(true)
		return
	else
		
		
	end

	local campArr = self.controler.campArr_2
	--如果不是调试模式的 return
	if (not self.controler.isDebugHero) or self.controler.logical.attackNums ~= 0
		or self.controler.logical.currentCamp ~= 2
	  then
		WindowControler:showTips(GameConfig.getLanguage("tid_common_2060")) 
		return
	end

	--先确定要刷怪的地方
	local infoArr = {}
	for i=1,6 do
		local panel = self["panel_"..i]
		if panel.input_1:getText() ~= "0" and  panel.input_1:getText() ~= "" then
			infoArr[i] = panel.input_1:getText()
		end
	end

	local length = #campArr
	for i=length,1,-1 do
		local hero = campArr[i]
		local posIndex = hero.data.posIndex
		--如果这个位置要刷怪,判断id是否相等
		if infoArr[posIndex] then
			--如果id不相等
			if hero.data.hid ~= infoArr[posIndex] then
				hero:deleteMe()
			else
				--置空这个对象
				infoArr[posIndex] = nil
			end
		end
	end

	--在重新遍历空地上的人
	for k,v in pairs(infoArr) do
		local posIndex = k
		local hero = self.controler.reFreshControler:createHeroByHid( v,2,posIndex ,"1001",v.."_"..v)
		hero.data:initAure() --初始化光环
		hero:doHelpSkill()
	end
	
	self.mc_1:showFrame(1)
	self.controler:setDebugHero(false)



end


--初始化id信息
function BattleDebugHeroView:updateInfo(  )
	local campArr = self.controler.campArr_2
	for i=1,6 do
		local panel = self["panel_"..i]
		panel.input_1:setText("0")
	end

	--拿到
	for i,v in ipairs(campArr) do
		local pos = v.data.posIndex
		local panel = self["panel_"..pos]
		panel.input_1:setText(v.data.hid)
	end

end





function BattleDebugHeroView:registerEvent()
end

function BattleDebugHeroView:updateUI()
	
end


return BattleDebugHeroView;
