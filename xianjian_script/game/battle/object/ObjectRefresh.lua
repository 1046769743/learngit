--
-- Author: xd
-- Date: 2016-08-18 18:38:08
--刷新信息 每个刷怪点都会附带这个属性
ObjectRefresh = class("ObjectRefresh")
local Fight = Fight
-- local BattleControler = BattleControler
--激活方式
ObjectRefresh.activateType = nil
--激活参数
ObjectRefresh.activateParams = nil 
--开始时间  秒为单位
ObjectRefresh.startTime = nil 
--刷新点相对位置
ObjectRefresh.posType = nil 
ObjectRefresh.posParams = nil
--敌人的hid
ObjectRefresh.heroHid = nil
--英雄属性
ObjectRefresh.heroData = nil

--出场效果
ObjectRefresh.appearEff = nil

--刷怪间隔 0死后在刷, 否则表示间隔多少秒刷
ObjectRefresh.freshTime = nil

--销毁类型 和销毁参数
ObjectRefresh.destoryType = nil
ObjectRefresh.destoryParams = nil

ObjectRefresh.groupPos = 0

--方向
ObjectRefresh.way = 1

--剩余刷怪数量
ObjectRefresh.freshNums = 0

--状态 0表示未激活 1表示激活中 2 表示暂时不能刷怪 3表示完全失效
ObjectRefresh.state = 0

--剩余刷新时间 每次都会递减
ObjectRefresh.leftTime = 0


function ObjectRefresh:ctor( cfgs )
	self._cfgs = cfgs
	self.activateType = cfgs.a
	self.activateParams = cfgs.ap
	self.startTime = cfgs.t
	self.posType = cfgs.p
	self.posParams = cfgs.pp
	self.heroHid = cfgs.i
	self.appearEff = cfgs.e
	self.freshNums = cfgs.r
	self.freshTime =cfgs.d
	self.destoryType = cfgs.o
	self.destoryParams = cfgs.op

	self.leftTime = 0 
	self.state = 0  --未激活

	if self.freshTime > 0 then
		self.leftTime = self.freshTime
	end

end

function ObjectRefresh:initData(  )
	local enemyInfo = EnemyInfo.new(self.heroHid)
	self.heroData = enemyInfo.attr
end

--让这个刷新点失效
function ObjectRefresh:destory(  )
	self.state = 3
end

--激活刷新点
function ObjectRefresh:activate( ... )
	--如果已经失效了
	if self.state ~= 0 then
		return
	end
	self.state = 1
end

--暂时不能刷怪
function ObjectRefresh:pause( )
	if self.state ~= 1 then
		return 
	end
	self.state = 2
end

--恢复刷怪
function ObjectRefresh:resume(  )
	if self.state ~= 2 then
		return 
	end
	self.state = 1
end

--是否是销毁的
function ObjectRefresh:isDestory(  )
	return self.state ==3
end

--是否激活
function ObjectRefresh:isActivate(  )
	return self.state >= 1
end

function ObjectRefresh:tostring(  )
	return "刷新点位置:"..self.groupPos.."_"..json.encode(self._cfgs)
end