--[[
	Author: 张燕广
	Date:2017-11-21
	Description: 六界控制器
]]

local WorldControler = WorldControler or {}

function WorldControler:init()
	self:registEvent()
end

function WorldControler:registEvent()
    -- 进入地标
	EventControler:addEventListener(WorldEvent.WORLDEVENT_ENTER_ONE_MISSION,self.moveCharEnterSpace,self)
    -- 靠近地标
    EventControler:addEventListener(WorldEvent.WORLDEVENT_NEAR_ONE_SPACE,self.moveCharNearSpace,self)
    -- 先将主角设置到屏幕中央再自动点击当前npc
    EventControler:addEventListener(WorldEvent.WORLDEVENT_AUTO_CLICK_CUR_NPC, self.autoClickCurNpc,self)
end

--[[
    移动主角靠近地标附近，不进入
]]
function WorldControler:moveCharNearSpace(event)
    if event and event.params then
        local ui = WindowControler:showWindow("WorldMainView")
        local spaceName = event.params.spaceName
         if self.mapControler and spaceName then
            self.mapControler:moveCharNearSpace(spaceName)
        end
    end
end

function WorldControler:moveCharEnterSpace(event)
	if event and event.params then
		local ui = WindowControler:showWindow("WorldMainView")
		EventControler:dispatchEvent(WorldEvent.WORLDEVENT_ENTER_ONE_SPACE,{spaceName=event.params.spaceName})
	end
end
-- 直接打开六界地图并且打开仙灵委托界面
function WorldControler:openDelegateView()
    -- 判断是否开启挂机
    if not DelegateModel:isOpen( ) then
        WindowControler:showTips(GameConfig.getLanguage("#tid1566"))
        return
    end
    WindowControler:showWindow("WorldMainView")
    EventControler:dispatchEvent(WorldEvent.WORLDEVENT_OPEN_SHIJIAN_VIEW)
end

-- 保存六界地图按钮数据
function WorldControler:setWorldMapBtnInfo(mapBtnInfo)
	self.mapBtnInfo = mapBtnInfo
end

-- 获取六界地图btn按钮世界坐标
function WorldControler:getWorldMapBtnWorldPos(sysName)
	local pos = {x=0,y=0}
	if self.mapBtnInfo then
		for k,v in pairs(self.mapBtnInfo) do
			if v and v.sys == sysName then
				local btn = v.btn

				local box = btn:getContainerBox()
			    local cx = box.x + box.width/2
			    local cy = box.y + box.height/2
			    local turnPos = btn:convertToWorldSpaceAR(cc.p(cx,cy))
			    pos = turnPos
			    break
			end 
		end
	end

	return pos
end

-- 副本类型跳转
function WorldControler:jumpToPVEView(fromGetWay,raidId,resId,resNum)
	if not raidId then
		echoWarn("WorldControler:jumpToPVEView raidId=",raidId)
		-- return
	end

    local stageType = WorldModel.stageType.TYPE_STAGE_MAIN
    if raidId then
        stageType = FuncChapter.getRaidAttrByKey(raidId,"type")
    end

	self:showWorldView(fromGetWay,stageType,raidId,resId,resNum)
end

-- 跳到PVE列表通用界面
function WorldControler:showPVEListView()
    self:showWorldView(true,WorldModel.stageType.TYPE_STAGE_MAIN)
end

--[[
副本相关跳转
1.精英副本：
A.通关或解锁跳转到指定关卡
B.未解锁，设置为灰色不可跳转，弹出tips

2.普通副本：
A.通关的跳转到旧的回忆 
B.未通关已解锁
  1).有raidID参数，跳转到六界大地图，锁定npc，主角自动飞过去
  2).没有raidID参数，直接跳转到旧的回忆(策划保证开启了最少一个关卡)
C.未解锁，设置为灰色不可跳转，弹出tips
--]]
function WorldControler:showWorldView(fromGetWay,stageType,raidId,resId,resNum)
    echo("WorldControler:showWorldView fromGetWay,stageType,raidId,resId,resNum=",fromGetWay,stageType,raidId,resId,resNum)
	local isSysOpen = false
    
    if stageType == WorldModel.stageType.TYPE_STAGE_MAIN then
        isSysOpen = FuncCommon.isjumpToSystemView(FuncCommon.SYSTEM_NAME.PVE)
        if not isSysOpen then
        	return
        end

        if raidId then
        	-- 已通关
            if WorldModel:isPassRaid(raidId) then
                WindowControler:showWindow("WorldPVEListView",fromGetWay,raidId,resId,resNum);
            -- 已开启
            elseif WorldModel:isOpenRaid(raidId) then
                local ui = WindowControler:showWindow("WorldMainView")
                ui:jumpToTargetRaid(raidId)
            else
                -- echo("手动报错 --关卡未解锁raidId=",raidId)
                local ui = WindowControler:showWindow("WorldMainView")
                ui:jumpToTargetRaid(raidId)
            end
        else
            WindowControler:showWindow("WorldPVEListView",fromGetWay);
        end
    elseif stageType == WorldModel.stageType.TYPE_STAGE_ELITE then
        isSysOpen = FuncCommon.isjumpToSystemView(FuncCommon.SYSTEM_NAME.ROMANCE)
        if  isSysOpen then
        	if raidId then
        		-- 跳转到指定关卡
        		if WorldModel:isPassRaid(raidId) or WorldModel:isOpenRaid(raidId) then
        			WindowControler:showWindow("EliteLieBiaoView",raidId)
        		else
        			EliteMainModel:enterEliteExploreScene()
        		end
        	else
        		EliteMainModel:enterEliteExploreScene()
        	end
        end
    end
end

--[[
    设置WorldMapControler实例
]]
function WorldControler:setWorldMapControler(mapControler)
    self.mapControler = mapControler
end

--[[
    获取当前地图上npc的坐标
]]
function WorldControler:getCurNpcPosition()
    local pos = cc.p(0,0)
    if self.mapControler then
        local pos = self.mapControler:getCurNpcWorldPos()
        return pos
    end

    echoTag('tag_world',5,"获取npc坐标发送错误",self.mapControler)
    
    return pos
end

--[[
    旧的回忆中自动点击npc模拟
]]
function WorldControler:autoClickCurNpc()
    local ui = WindowControler:showWindow("WorldMainView")
    if self.mapControler then
        self.mapControler:autoClickCurNpc()
    end
end

WorldControler:init()

return WorldControler
