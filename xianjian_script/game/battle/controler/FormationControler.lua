--[[
	阵位控制器
	Author:李朝野
	Date: 2017.09.07
]]
local Fight = Fight
-- local BattleControler = BattleControler
FormationControler = class("FormationControler")

FormationControler.controler = nil -- 控制器
FormationControler.layer = nil -- 容器层

FormationControler.buZhenAni_camp1 = nil -- 阵营1布阵特效
FormationControler.buZhenAni_camp2 = nil -- 阵营2布阵特效
FormationControler.blackScreen = nil -- 布阵黑屏遮罩
FormationControler.buZhenTargetAni = nil -- 布阵目标位置特效

FormationControler.changeElementUI = nil -- 换灵UI

FormationControler.elementsInfo = nil -- 阵位五行信息

FormationControler.eleChangeInfo = nil -- 保存换灵信息
--[[
{
	element = ,换成的元素
	origin = ,原元素及原强化属性
	pos = ,生效位置
	round = ,持续回合
}
]]
-- 换灵数据存储
FormationControler.huanlingInfo = nil
-- 可换灵次数
FormationControler.changeEleTimes = Fight.changeEleMaxTimes
-- 存放格子实例
FormationControler.latticeArr_1 = nil
FormationControler.latticeArr_2 = nil

-- 构造
function FormationControler:ctor(controler)
	self.controler = controler
    self.layer = controler.layer
    -- 初始化基础结构
    self.elementsInfo = { -- 阵位五行信息
		[Fight.camp_1] = {}, 
		[Fight.camp_2] = {}
	}

	self.eleChangeInfo = { -- 保存换灵信息
		[Fight.camp_1] = {}, 
		[Fight.camp_2] = {}
	}

	self.huanlingInfo = {
		[Fight.camp_1] = {},
		[Fight.camp_2] = {}
	}
	self.latticeArr_1 = {}
	self.latticeArr_2 = {}
	self.changeElementUI = nil

    -- 初始化阵位五行信息
    for i,camp in ipairs(self.elementsInfo) do
    	for posIndex=1,6 do
    		camp[posIndex] = {
    			element = Fight.element_non, -- 五行属性
    			exLv = Fight.element_ex_lv, -- 技能强化等级，便于扩展
    			exDef = Fight.element_reduce_rate, -- 属性防御力，便于扩展
	    	}
    	end
    end
end
-- 设置玩家换灵信息
function FormationControler:setUserhuanlingInfo(info,camp )
	self.huanlingInfo[camp]=info
end

--[[
	设置队伍五行信息
]]
function FormationControler:setElementsInfo( info,camp )
	if not info then
		return
	end

	for pos,eleInfo in pairs(info) do
		local tempInfo = self.elementsInfo[camp][tonumber(pos)]
		tempInfo.element = tonumber(eleInfo.element or tempInfo.element)
		tempInfo.exLv = tonumber(eleInfo.exLv or tempInfo.exLv)
		tempInfo.exDef = tonumber(eleInfo.exDef or tempInfo.exDef) + self:getTowerAddDef(tempInfo.element)
	end

	self:updateFormationView(camp)
end
-- -- 更新五行信息（比如锁妖塔对五行阵位的加强）
-- function FormationControler:updateElementsInfo( info,camp )
-- 	for k,v in pairs(info) do
-- 		for i=1,6 do
-- 			-- 如果上相同的五行阵位，则需要都加
-- 			local tempInfo = self.elementsInfo[camp][i]
-- 			if tempInfo.element == v.element then
-- 				tempInfo.exLv = tempInfo.exLv + v.exLv
-- 				tempInfo.exDef = tempInfo.exDef + v.exDef
-- 			end
-- 		end
-- 	end
-- end
--[[
	换灵
	changeInfo = {
		element = -- 替换的属性
		round = -- 生效回合
		pos = -- 生效位置
		camp = -- 阵营
	}
]]
function FormationControler:changeElement(changeInfo)
	local pos = changeInfo.pos
	local camp = changeInfo.camp
	local element = changeInfo.element
	if not pos or not camp then return end
	if not self.huanlingInfo[camp][element] then return end
	local cInfo = self.huanlingInfo[camp][element] --玩家换灵养成

	local tmpInfo = self.elementsInfo[camp][pos] 
	local origin = table.copy(tmpInfo) --保存以前的五灵养成

	tmpInfo.element = cInfo.element
	tmpInfo.exLv = cInfo.exLv
	tmpInfo.exDef = cInfo.exDef + self:getTowerAddDef(element)

	table.insert(self.eleChangeInfo[camp],{
		origin = origin,
		element = changeInfo.element,
		pos = pos,
		round = changeInfo.round,
	})

	self:updateFormationView(camp)
	-- 换灵使用怒气
	self.controler.energyControler:useEnergy(Fight.changeEleEnergyCost, camp)
	self.changeEleTimes = self.changeEleTimes - 1
	self:chkShowChangeElement()
	
	local hero = AttackChooseType:findHeroByPosIndex(pos, self.controler:getCampArr(camp))
	if hero then
		hero:updateElementEnhance()
	end
end
--[[
	本方回合结束后刷新
]]
function FormationControler:updateRoundEnd( camp )
	self:updateChangeElement(camp)

	-- 维护格子buff
	for tcamp=1,2 do
		for _,lattice in ipairs(self["latticeArr_" .. tcamp]) do
			if tcamp == camp then
				lattice:updateRoundEnd()
			else
				lattice:updateToRoundEnd()
			end
		end
	end
end

-- 更新换灵
function FormationControler:updateChangeElement(camp)
	if #self.eleChangeInfo[camp] == 0 then return end

	local tempInfo = self.eleChangeInfo[camp]

	for i=#tempInfo,1,-1 do
		local info = tempInfo[i]
		info.round = info.round - 1
		if info.round <= 0 then
			-- 还原
			local eInfo = self.elementsInfo[camp][info.pos]
			eInfo = info.origin
			-- 删除
			table.remove(tempInfo, i)
		end
	end

	self:updateFormationView(camp)
end
-- 返回一个人物是否受到阵位技能加强
function FormationControler:isHeroEnhanceSkill( targetHero )
	local camp = targetHero.camp
	local posIndex = targetHero.data.posIndex
	local targetElement = targetHero:getHeroElement()
	local elementInfo = self:getElementInfoByPos(camp, posIndex)

	return (elementInfo.element ~= 0 and elementInfo.element == targetElement)
end
-- 返回一个人物是否受到阵位防御加强
function FormationControler:isHeroEnhanceDef( targetHero, targetElement )
	local camp = targetHero.camp
	local posIndex = targetHero.data.posIndex
	local targetElement = targetElement or 0
	local elementInfo = self:getElementInfoByPos(camp, posIndex)

	return (elementInfo.element ~= 0 and elementInfo.element == targetElement)
end
-- 返回人物技能增强等级
function FormationControler:getHeroEnhanceSkillLvl( targetHero )
	local result = 0
	if self:isHeroEnhanceSkill(targetHero) then
		local camp = targetHero.camp
		local posIndex = targetHero.data.posIndex
		local elementInfo = self:getElementInfoByPos(camp, posIndex)

		result = elementInfo.exLv
	end

	return result
end
-- 返回人物属性减伤增强
function FormationControler:getHeroEnhanceDef( targetHero, targetElement )
	local result = 0
	if self:isHeroEnhanceDef(targetHero, targetElement) then
		local camp = targetHero.camp
		local posIndex = targetHero.data.posIndex
		local elementInfo = self:getElementInfoByPos(camp, posIndex)

		result = elementInfo.exDef
	end
	return result
end
-- 根据五灵获取对应的锁妖塔属性加成
function FormationControler:getTowerAddDef(targetElement )
	-- 锁妖塔有属性减伤增强
	if BattleControler:checkIsTower() then
		local bInfo = self.controler.levelInfo:getBattleInfo()
		local towerInfo = bInfo.battleParams.towerInfo
		if towerInfo and towerInfo.soulBuffs then
			if towerInfo.soulBuffs[tostring(targetElement)] then
				return tonumber(towerInfo.soulBuffs[tostring(targetElement)])
			end
		end
	end
	return 0
end
-- 返回位置对应的element
function FormationControler:getElementInfoByPos( camp,posIndex )
	return self.elementsInfo[camp][posIndex]
end
--[[
	初始化视图
]]
function FormationControler:initView()
	if not self.blackScreen then
	    self.blackScreen = FuncRes.a_black( 50000,5000,125):addto(self.controler.layer.a121):pos(0,0)
	end
	self.blackScreen:visible(false)

	if not self.buZhenAni_camp1 then
        self.buZhenAni_camp1 = self:createUIArmature("UI_zhandou_zhenwei", "UI_zhandou_zhenwei_buzhen",self.layer.a122,false,GameVars.emptyFunc)
        --local posx,posy = self.controler.reFreshControler:turnPosition( 1,3,2, self.controler.middlePos)
        self.buZhenAni_camp1:startPlay(true)
    end
    self.buZhenAni_camp1:visible(false)

	if not self.buzhenAni_camp2 then
        self.buZhenAni_camp2 = self:createUIArmature("UI_zhandou_zhenwei", "UI_zhandou_zhenwei_buzhen",self.layer.a122,false,GameVars.emptyFunc)
        self.buZhenAni_camp2:setScaleX(-1)
        self.buZhenAni_camp2:startPlay(true)
    end
    self.buZhenAni_camp2:visible(false)

    self:updateFormationPos()

    -- self:initChangeElementUI()
end
--[[
	更新阵位位置
]]
function FormationControler:updateFormationPos()
	if Fight.isDummy then
		return
	end
	-- 阵营1
    local posx,posy = self.controler.reFreshControler:turnPosition( 1,3,2, self.controler.middlePos, true)
    self.buZhenAni_camp1:zorder(Fight.zorder_formation)
    self.buZhenAni_camp1:pos(posx-20,-posy)
    

    -- 阵营2
    local posx2,posy2 = self.controler.reFreshControler:turnPosition( 2,3,2, self.controler.middlePos, true)
    self.buZhenAni_camp2:zorder(Fight.zorder_formation)
    self.buZhenAni_camp2:pos(posx2 + 25, -posy2)
end
--[[
	更新阵位视图
]]
function FormationControler:updateFormationView(camp)
	if not camp then return end
	if Fight.isDummy then return end
	local camp = camp
	-- 相关格子的位置
	local transPos = {
		[1] = {1,10,100,1000},
		[2] = {2},
		[3] = {3,20,200},
		[4] = {4},
		[5] = {5,30},
		[6] = {6}
	}
	-- 改变特效里的每一个原件
	local function changeAllEff(baseAni, element)
		for i=1,12 do
			local bone = baseAni:getBoneDisplay("a" .. i)
			if bone then
				bone:playWithIndex(element, 0)
			end
		end
	end
	for posIndex=1,6 do
		local element = self.elementsInfo[camp][posIndex].element
		for _,boneIdx in ipairs(transPos[posIndex]) do
			local bone = self["buZhenAni_camp" .. camp]:getBoneDisplay("a"..boneIdx)
			bone:playWithIndex(element, 0)

			changeAllEff(self["buZhenAni_camp" .. camp]:getBoneDisplay("a"..boneIdx.."_ks"), element)
		end
	end
end
--[[
	展示被击防御强化的效果
	@@heroTable 显示阵位的人物
	@@camp 阵营
	@@isBlack 是否有蒙黑
]]
function FormationControler:showHitEnhanceDefElement( heroTable, camp, isBlack)
	local function showPos( hero, camp )
	    return true
	end
	self["buZhenAni_camp" .. camp]:visible(true)
	if isBlack then
		self["buZhenAni_camp" .. camp]:zorder(Fight.zorder_formation + Fight.zorder_blackChar)
	end

	local boneT = self:_manageFigureBuZhen(heroTable,camp,showPos,false,true)
end
--[[
	创建特效的方法
]]
function FormationControler:createUIArmature( ... )
	if self.controler.gameUi then
		return self.controler.gameUi:createUIArmature(...)
	end
end
-- 巅峰竞技场 换人
function FormationControler:doChangeHero( )
	if Fight.isDummy then return end
	self:doBeginBuZhen()
	if BattleControler:checkIsCrossPeak() then
		self.controler.gameUi.crossPeakView:updateViewVisible()
	else
		self.controler.logical:updateBattleState(Fight.battleState_formation)
	end
end
--[[
	开始布阵
]]
function FormationControler:doBeginBuZhen()
	if Fight.isDummy then return end
	self:setBuZhenVisible(true)
	self:chkShowChangeElement()
	self:checkSpecialShow()
end
--[[
	结束布阵
]]
function FormationControler:doFinishBuZhen()
	if Fight.isDummy then return end
	
	self:setBuZhenVisible(false)
	if not self.changeElementUI then return end

	self.changeElementUI:setChangeElementVisible(false)
	self.changeElementUI:cancelChangeElement()
end
function FormationControler:checkSpecialShow( )
	-- 这里写死的一个代码、主线关卡10101，第二波李逍遥显示大招攻击的对象
	local isFirst = tonumber(LS:prv():get(StorageCode.FIRST_SHOW,0))
	if isFirst == 0 then
		if self.controler.levelInfo.hid == "10101" and
			self.controler.__currentWave == 2 then
			local campArr = self.controler:getCampArr(Fight.camp_1)
			for k,v in pairs(campArr) do
				local sourceId = v.data:getCurrTreasureSourceId()
				if sourceId == "30005" then
					echo ("特殊处理的李逍遥攻击红圈")
					v:addSkillEffectAperture()
					LS:prv():set(StorageCode.FIRST_SHOW,1)
					break
				end
			end
		end
	end
end
-- 检查是否开启换灵
function FormationControler:chkHuanlingIsOpenAndCan()
	local teamCamp = BattleControler:getTeamCamp( )
	if #self.huanlingInfo[teamCamp] == 0 then
		return false
	end
	return true
end
--[[
	检查显示换灵UI
]]
function FormationControler:chkShowChangeElement()
	if Fight.isDummy then return end
	if not self.changeElementUI then return end
	if not self.controler:chkIsOnMyCamp() then
		return
	end
	local teamCamp = BattleControler:getTeamCamp( )
	-- local camp = self.controler:getUIHandleCamp()
	if self.changeEleTimes > 0 and self.controler.energyControler:isEnergyEnough(Fight.changeEleEnergyCost, teamCamp) then
		self.changeElementUI:setChangeElementVisible(true)
	else
		self.changeElementUI:setChangeElementVisible(false)
	end
	-- 未开启换灵
	if not self:chkHuanlingIsOpenAndCan() then
		self.changeElementUI:setChangeElementVisible(false)
	end
end
--[[
	脚下格子，显示与否
	heroArr 要做处理的人物列表
	camp 处理的阵营
	func(hero, camp) 作用于每一个hero,返回人所在的阵位是否显示
	noHeroShow 没有人的位置是否显示
	isShowEff 是否显示特效

	return boneT 阵位上每个骨骼的显示情况
]]
function FormationControler:_manageFigureBuZhen(heroArr, camp, func, noHeroShow, isShowEff)
	local noHeroShow = noHeroShow
	local isShowEff = isShowEff
	if noHeroShow == nil then noHeroShow = false end
	if isShowEff == nil then isShowEff = false end
	-- 位置和体型返回对应的骨骼尾号
	local function transPos( pos, figure )
	    local result
	    if figure == 1 then
	        result = pos
	    elseif figure == 2 then
	        result = (math.floor((pos - 1) / 2) + 1) * 10
	    elseif figure == 4 then
	        if pos > 3 then pos = 3 end
	        result = (math.floor((pos - 1) / 2) + 1) * 100
	    elseif figure == 6 then
	        if pos > 1 then pos = 1 end
	        result = (math.floor((pos - 1) / 2) + 1) * 1000
	    else
	        result = transPos(pos, 1)
	    end

	    return result
	end
	--判断应该隐藏或者显示哪些格子
	local campArr = heroArr
	-- 初始化
	local boneT = {
	    [10] = false,
	    [20] = false,
	    [30] = false,
	    [100] = false,
	    [200] = false,
	    [1000] = false,
	}
	-- 初始化是否显示
	for i=1,6 do
	    boneT[i] = noHeroShow
	end
	-- 2格怪一定站5 4 格怪一定站3 6格怪一定站1
	for _,hero in ipairs(campArr) do
	    local pos = hero.data.posIndex
	    local figure = hero.data:figure() or 1
	    local bonePos = transPos(pos, figure)

	    -- 显示
	    if func(hero, camp) then
	    	boneT[bonePos] = true
	    	-- 根据体型隐藏
	    	if figure > 1 then
	    	    for i = pos,pos + figure - 1 do
	    	        boneT[i] = false
	    	    end
	    	end
	    else
	    	boneT[bonePos] = false
	    end
	end

	-- 如果是序章2（第三关）只能在1、2号位之间换（特殊处理）
	if camp == 1 then
		local changePos = nil

		if changePos then
		    for i=1,6 do
		        if not array.isExistInArray(changePos, i) then
		            boneT[i] = false
		        end
		    end
		end
	end

	for pos,show in pairs(boneT) do
	    local bone = self["buZhenAni_camp" .. camp]:getBone("a"..pos)
	    local boneAni = self["buZhenAni_camp" .. camp]:getBone("a"..pos.."_ks")
	    if bone then
	        bone:visible(show)
	        boneAni:visible(show and isShowEff)
	    else
	        echo("联系技术 布阵 没有找到 bone", pos)
	    end
	end

	return boneT
end

--[[
	阵位显示
]]
function FormationControler:setBuZhenVisible(flag)
	if Fight.isDummy then return end
	if self.blackScreen then
	    self.blackScreen:visible(flag)
	end
	if self.buZhenAni_camp1 then
	    self.buZhenAni_camp1:visible(flag)
	    -- 改变回默认层级
	    self.buZhenAni_camp1:zorder(Fight.zorder_formation)
	end
	if self.buZhenAni_camp2 then
	    self.buZhenAni_camp2:visible(flag)
	    -- 改变回默认层级
	    self.buZhenAni_camp2:zorder(Fight.zorder_formation)
	end

	if not flag then

	else
		-- 根据体型处理格子显示
		-- 传入函数
		local function showPos( hero, camp )
			local result = true
			if camp == uiCamp and not hero:jianChaShiFangJiNengHeDaZhao() then
		        result = false
		    end

		    return result
		end
		-- 巅峰竞技场时刻显示敌方阵营的五行属性
		local function showPosTmp( hero,camp )
			return true
		end
		self:_manageFigureBuZhen(self.controler.campArr_1,1,showPos,true,false)

		if BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPvp then
			self:_manageFigureBuZhen(self.controler.campArr_2,2,showPosTmp,true,false)
		else
			self:_manageFigureBuZhen(self.controler.campArr_2,2,showPos,true,false)
		end

		-- 以前上面是不显示特效的，现在要显示，在后面再刷新一遍
		self:updateElementDefEffByCamp(Fight.camp_1)
		self:updateElementDefEffByCamp(Fight.camp_2)
	end
end

--[[
	更新阵位显示
]]
function FormationControler:updateElementDefEffByCamp(camp)
	for posIndex=1,6 do
		self:updateElementDefEff(camp, posIndex)
	end
end

--[[
	更新阵位强化显示
]]
function FormationControler:updateElementDefEff( camp, posIndex )
	if not camp or not posIndex then return end

	local camp = camp
	local posIndex = posIndex
	-- 相关格子的位置
	local transPos = {
		[1] = {1,10,100,1000},
		[2] = {2,20,200},
		[3] = {3,30},
		[4] = {4},
		[5] = {5},
		[6] = {6}
	}

	-- 是否强化le 
	local hero = self.controler.logical:findHeroModel(camp, posIndex)
	local isEnhance = hero and self:isHeroEnhanceSkill(hero) or false
	local buzhenAni = self["buZhenAni_camp" .. camp]
	for i,pos in ipairs(transPos[posIndex]) do
		local bone = buzhenAni:getBone("a"..pos)
	    local boneAni = buzhenAni:getBone("a"..pos.."_ks")

	    boneAni:visible(bone:isVisible() and isEnhance)
	end
end
-- 更新背景色是否显示隐藏(开战特效调用的)
function FormationControler:changeBlackScreenVisible( b )
	if self.blackScreen then
		if not b then
			-- 当前是布阵状态的时候，不需要将blackScreen 设置为false
			if self.buZhenAni_camp1 and self.buZhenAni_camp1:isVisible() then
				return
			end
		end
	    self.blackScreen:visible(b)
	end
end

--[[
	布阵中移动任务目标位置的
]]
function FormationControler:buZhenSetTargetPos( posIndex,targetHero )
	-- 先不显示这个2017.9.11
	if true then return end
	if posIndex == 0 then
        if self.buZhenTargetAni then
            self.buZhenTargetAni:visible(false)
        end
        
        return
    end
    local posx,posy = self.controler.reFreshControler:turnPosition( 1,posIndex,1, self.controler.middlePos)
    if not self.buZhenTargetAni  then
        self.buZhenTargetAni = self:createUIArmature("UI_zhandou", "UI_zhandou_szxz", self.controler.layer.a121,false,GameVars.emptyFunc)
        self.buZhenTargetAni:startPlay(true)
    end
    posx = posx+5
    posy = posy+7
    if posIndex%2 ==0 then
        posy = posy - 8
        posx = posx + 2
    else
        posy = posy - 5 --+18
        posx = posx + 2
    end
    self.buZhenTargetAni:pos(posx,-posy)
    self.buZhenTargetAni:visible(true)
end

--[[
	换灵视图init
]]
function FormationControler:initChangeElementUI()
	if Fight.isDummy then return end
	-- 临时这么写，有了UI以后取UI
	self.changeElementUI = self.controler.gameUi.huanling_view
end
-- 检查是否开启了换灵
function FormationControler:checkIsOpenFormation( )
	if not LoginControler:isLogin() then
		return true
	end
	return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.FIVESOUL)
end

-------------------- 实现一些格子管理相关功能，目前涉及到作用于阵位的功能了 --------------------
function FormationControler:initLattice()
	-- 双方都要初始化
	for camp=1,2 do
		for pos=1,Fight.maxCampNums do
			local lattice = ModelLattice.new(self.controler, {posIndex = pos,camp = camp})
			table.insert(self["latticeArr_" .. camp], lattice)
		end
	end
end

-- 切波更新格子
function FormationControler:waveUpdateLattice()
	-- 目前考虑清理buff重置位置即可
	for camp=1,2 do
		for _,lattice in ipairs(self["latticeArr_" .. camp]) do
			lattice:waveUpdateLattice()
		end
	end
end

-- 获取阵营格子
function FormationControler:getLatticeByCamp(camp)
	return three(camp == Fight.camp_1, self.latticeArr_1, self.latticeArr_2)
end
-- 设置可以布阵的玩家Rid
function FormationControler:setBZUserRid( rid )
	self.__bzUseRid = rid
end
function FormationControler:checkIsMeBZ()
	return self.__bzUseRid == self.controler:getUserRid()
end

-- 打印一下buff情况
function FormationControler:printBuffs()
	for _,lattice in ipairs(self.latticeArr_1) do
		echo("--------",lattice.camp,lattice.data.posIndex,lattice:getBuffNums())
	end
	echo("================")
	for _,lattice in ipairs(self.latticeArr_2) do
		echo("--------",lattice.camp,lattice.data.posIndex,lattice:getBuffNums())
	end
end

--test
-- eff_30022_lankui_attack2_buff,1,1,0,0;
function FormationControler:test()
	local atkData = ObjectAttack.new("3001821")
	for i,v in ipairs(self["latticeArr_" .. 1]) do
		v:createEffGroup(atkData:sta_aniArr())
	end
end

return FormationControler