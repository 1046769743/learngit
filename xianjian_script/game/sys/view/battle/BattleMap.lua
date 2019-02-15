--
-- User: cwb
-- Date: 2015/6/2
-- 战斗地图ui

local BattleMap = class("BattleMap", UIBase)

BattleMap.speed = {
	-- panel_1 = 0,
	-- panel_2 = 1,
	-- panel_3 = 0.6,
	-- panel_4 = 0.4,
	-- panel_5 = 0,
}


BattleMap.scaleCtns =nil

function BattleMap:ctor(winName)
	BattleMap.super.ctor(self,winName)
	self.scaleCtns = {}
end

function BattleMap:loadUIComplete()
	BattleMap.super.loadUIComplete()


	local uiDatas = self.__uiCfg
	self.speed = uiDatas.ex.speed
	self.landIndex = uiDatas.ex.land
	self.ctnNameArr = uiDatas.ex.ctn 
end

function BattleMap:deleteMe(  )
	local uiCfg = self.__uiCfg
	BattleMap.super.deleteMe(self)
	local textureName = uiCfg.ex.fla
	FuncRes.removeMapTexture(textureName)
	echo("移除场景材质：".."map/"..textureName..".plist" );
end
	


return BattleMap