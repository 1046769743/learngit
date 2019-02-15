--[[
	神器数据

	继承自ObjectHero主要为了避免大量重写技能相关的方法，神器本身没有显示逻辑，只负责放技能
]]
local Fight = Fight
-- local BattleControler = BattleControler

ObjectArtifact = class("ObjectArtifact", ObjectHero)

function ObjectArtifact:ctor( ... )
	ObjectArtifact.super.ctor(self, ...)
end
-- 重写下获得技能的方法
function ObjectArtifact:getAllSkills()
	return self.curTreasure:getAllSkills()
end

function ObjectArtifact:getArtifactSkill(atSkillType)
	return self.curTreasure:getArtifactSkill(atSkillType)
end

function ObjectArtifact:getArtifactSkillById(...)
	return self.curTreasure:getArtifactSkillById(...)
end

function ObjectArtifact:getAllSpiritSkill()
	return self.curTreasure:getAllSpiritSkill()
end

function ObjectArtifact:getSpiritSkillById(skillId)
	return self.curTreasure:getSpiritSkillById(skillId)
end

-- 添加一个改变五灵的方法
function ObjectArtifact:setHeroElement(element)
	self.__element = element
end
-- 添加一个获取五灵的方法
function ObjectArtifact:getHeroElement()
	return self.__element or Fight.element_non
end

--[[
	直接改变神器的属性，用于处理策划言而无信的神器有伤害技能的问题
	name 属性名
	value 改变值
]]
function ObjectArtifact:setAttribute(name, value)
	local keyName = self:getKey(name)
    local old = self[keyName]

    self[keyName] = value
end
-- 需要重写一些不需要的方法规避报错或无用内容 --

function ObjectArtifact:changeValue( ... )
	return 0,0
end

function ObjectArtifact:useTreasure( treasure,treasureIndex,isInit )
	-- 首先清除光环这个法宝自带的光环
	local isChangeTreasure = false
	if self.curTreasure and treasure ~= self.curTreasure then
	    self:cancleAure()
	    isChangeTreasure = true
	end
	self.curTreasureIndex = treasureIndex
	treasure:initData()

	self.curTreasure = treasure
	self._curTreasureHid = self.curTreasure.hid

	-- 如果是初始化不在这里作用光环，会在阵营初始化后统一作用，不然会报错，因为__heroModel还没有初始化
	if not isInit then
	    self:initAure()
	end

	-- 2017.08.09 pangkangning 这里给职业赋值 当更换法宝的时候也应该发一个角色更换的方法
	self.datas.profession = self.curTreasure:sta_profession()
end

function ObjectArtifact:updateDatas(datas, init)
	self.datas = table.copy(datas)
	 --初始化治疗上限 ,生命上限不能超过治疗上限
    self.datas.maxtreahp = self.datas.maxhp
    --初始化二级属性
    self:initSecondProp()
    self.treasures = {}

    local treasurArr = self.datas.treasures

    local sex = 1

    -- 法宝
    for i=1,#treasurArr do
        local num = #self.treasures + 1
        local treasueObj = ObjectArtifactTreasure.new(treasurArr[i].hid,treasurArr[i],sex)
        self.treasures[num] = treasueObj
        treasueObj.treaType = treasurArr[i].treaType
        if treasurArr[i].treaType == Fight.treaType_base then
            --上来使用的法宝都是默认法宝 baseTrea
            self:useTreasure(treasueObj,nil,true)
        end
    end
end
-- 需要重写一些不需要的方法规避报错或无用内容 --

return ObjectArtifact