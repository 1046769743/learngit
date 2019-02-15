--
-- Author: pangkangning
-- Date: 2017-07-31
-- 主要是试炼战斗中角色使用buff后
-- 额外对任意N个单位造成等量伤害 N通过buff表中配置的value字段决定
--
ModelTrialHero = class("ModelTrialHero", ModelHero)


function ModelTrialHero:ctor(...)
	ModelTrialHero.super.ctor(self,...)
end

function ModelTrialHero:doRoundFirst( )
	self.__trialAddChooseBuff = nil --该buff只会在当前回合生效
	ModelTrialHero.super.doRoundFirst(self)
end

function ModelTrialHero:checkCreateBuff( buffHid,attacker,skill )
	local buffObj = ModelTrialHero.super.checkCreateBuff(self,buffHid,attacker,skill)
	-- dump(buffObj)
	if buffObj.type == Fight.buffType_trialAddChoose then
		self.__trialAddChooseBuff = buffObj
		-- echo("试炼中使用某个增加额外任意单位的buff的时候，这个buff会顶替掉原先拥有的buff")
		if buffObj.changeType ~= 1 or buffObj.value <= 0 or buffObj.value >= 6 then
			echoError("试炼bbuff额外人员数值不对---buffID :%s",buffObj.hid)
		end

		if not Fight.isDummy then
			-- if self._addChooseBuffView and (not tolua.isnull(self._addChooseBuffView)) then
			-- 	self._addChooseBuffView:removeFromParent()
			-- 	self._addChooseBuffView = nil
			-- end
			-- local gameUi = BattleControler.gameControler.gameUi
		 --    local anim = gameUi:createUIArmature("UI_shilian_zhandou","UI_shilian_zhandou_hudun", self.myView, false,GameVars.emptyFunc)
		 --    local x,y = self.data.viewSize[1],self.data.viewSize[2]
		 --    anim:pos(x/2-28,y/2)
		 --    anim:playWithIndex(1)
		 --    self._addChooseBuffView = anim
		end
	end
end

-- 当角色身上拥有攻击时 额外对另外两名玩家造成本次攻击第一个受击角色的等量伤害
function ModelTrialHero:onSkillActionComplete( ... )
	if self.__trialAddChooseBuff then
		if not Fight.isDummy then
			-- 将身上的试炼buff特效请掉
			-- if self._addChooseBuffView and (not tolua.isnull(self._addChooseBuffView)) then
			-- 	self._addChooseBuffView:removeFromParent()
			-- 	self._addChooseBuffView = nil
			-- end
		end
		-- echo("开始走---试炼buff逻辑")
		local skill = self.currentSkill
		if not skill then return end
		local realDmg
		local hitPos = {} --攻击过的角色
		for k,v in pairs(skill.attackInfos) do
			local atkData = v[3]
			if atkData.hasChooseArr and #atkData.hasChooseArr > 0 then
				for _,o in pairs(atkData.hasChooseArr) do
					-- 将打过的角色位置标记起来
					hitPos[o.data.gridPos] = true
				end
				if atkData:sta_dmg() and atkData.isFirst then
					local dmgInfo = self:getRecordDmgInfo(atkData.hasChooseArr[1],skill)
					realDmg = dmgInfo.dmg
					-- echo("总伤害-----",dmgInfo.dmg)
					-- 如果是攻击伤害，则获取第一个人的攻击伤害，直接附加到额外两个角色的身上
				end
			end
		end
		-- 获取所有敌方数据，然后剔除攻击过的角色
		local unHitObj = {}
		if realDmg and #self.controler.campArr_2 > 0 then
			for k,v in pairs(self.controler.campArr_2) do
				if not hitPos[v.data.gridPos] then
					table.insert(unHitObj,v)
				end
			end
			echo("未攻击的角色个数---",#unHitObj)
			if #unHitObj > 0 then
				local count = self.__trialAddChooseBuff.value
				local num = #unHitObj >= count and count or 1
				-- echo("额外伤害个数----",num)
				local arr = BattleRandomControl.getNumsByGroup(unHitObj,num)
				-- echo("筛选出来的个数---------",#arr,"============")
				for k,v in pairs(arr) do
					-- echo("执行额外伤害--------------x:%s,y:%s",v.data.gridPos.x,v.data.gridPos.y)

					v.data:changeValue(Fight.value_health , -realDmg, 1, 0)
					AttackUseType:checkClearHeroFromArr(v,{isFinal= true},skill,self )
					if v.data:hp() <= 0 then
						v:justFrame(Fight.actions.action_die, nil, true)
					end
				end
			end
		end
	end


	ModelTrialHero.super.onSkillActionComplete(self,...)

	-- echo("技能播放完毕-------",self.__trialAddChooseBuff,dmg)
	-- if not Fight.isDummy then
	-- end
end
