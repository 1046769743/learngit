
--[[
animation为主时间轴
]]
local AnimDialogView = class("AnimDialogView", UIBase)



require("game.battle.controler.MapControler")


--dump(MapControler )
local BTN_ZORDER = 1000
local BLACK_ZORDER_1 = 1001
local BLACK_ZORDER_2 = 990
local TXT_ZORDER = 2000
--[[ 
ctor
]]
function AnimDialogView:ctor(winName, controler)
	echo("juqing chuangjiang le ========")
    AnimDialogView.super.ctor(self, winName)
    self.controler = controler
    self.jiss = 0

    self._forceLock = false
    self._nowLockType = nil -- 标记一下当前是什么锁
    self.moveBodyTemp = nil -- 在强交互的玩法奇侠传记里用来记录放养人物，平滑抹去到目标位置的成本
    self.btnPos = {
        left = cc.p(0,0),
        right = cc.p(0,0),
    }

    self._changeAnim = {}
end

--[[
加载ui完毕
]]
function AnimDialogView:loadUIComplete()
    self:registerEvent()
    -- AudioModel:playMusic(MusicConfig.m_scene_pve, true)
    self.txt_raidTitle:visible(false)
    self.txt_raidTitle1:visible(false)
    self.panel_1:visible(false)
    self.panel_1:zorder(TXT_ZORDER)
    self.panel_1:pos(-GameVars.gameResWidth/2, GameVars.gameResHeight/2)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1,UIAlignTypes.RightTop)
    self:addNewQuestAndChat()
   
end 


--[[
注册事件
]]
function AnimDialogView:registerEvent()
     --EventControler:dispatchEvent(SystemEvent.SYSTEMEVENT_APP_ENTER_BACKGROUND,{time = timeStap,usec = usec} )
     --plot中读取到的跳转到的帧事件
     EventControler:addEventListener(BattleEvent.BATTLEEVENT_ANIMATION_JUMP_FRAME, self.doJumpToAnimationOrFrame, self)

     EventControler:addEventListener(BattleEvent.ANIMDIALOGVIEW_JUMP,self.doJumpBack,self)
     EventControler:addEventListener(BattleEvent.ANIMDIALOGVIEW_EXIT,self.doExitBack,self)

    -- 关闭轶事问答
    EventControler:addEventListener(MissionEvent.CLOSE_MISSION_QUEST_VIEW,self.closeMissionQuestUI,self);

    self.mc_1xx:setTouchedFunc(c_func(self.showMissionInfo,self))
end 

--[[
事件跳转到某帧或者某个动画片段
]]
function AnimDialogView:doJumpToAnimationOrFrame( params )
	--echo("跳转到某帧或者某个animation label!")
	-- dump(params)
	-- dump(params.params)
	-- dump(params.data)
	local params = params.params
	--dump(params)
	--echo("跳转到某帧或者某个animation label!")
	local lbl = params.animLabel
	local frame = params.frame

	
	if tostring(lbl) == "0" then
		lbl = self.animLabel
		if frame == 0 then
			frame=self.currentFrame
		end
	end

	self:doJumpFrame(lbl,frame)
end

-- 获取label和frame
function AnimDialogView:getLabelAndFrame()
	return self.animLabel, self.currentFrame
end

-- 跳转帧方法
function AnimDialogView:doJumpFrame(lbl,frame)
	if not lbl or not frame then return end

	self.animLabel = tostring(lbl)
	self.currentFrame = frame
	self.spine:playLabel(lbl)
	self:playSceneSpine(self.currentFrame)

	self.totalFrame = self.spine:getTotalFrames(self.animLabel)

	local mapId = self:praseChangeEvent(lbl, frame)
	-- 有地图的切换
	if mapId then
		self.map:setMapId(mapId)
		self.map:updatePos(self.mapOffsetX, 0)
	end
end

-- 解析change事件，找出当前动画指定帧前的最后一次map替换
-- 返回 mapId
function AnimDialogView:praseChangeEvent(lbl, frame)
	if not lbl or not frame then return end

	frame = tonumber(frame)
	if self.events[lbl].change then
		local max,mapId = nil
		for f,info in pairs(self.events[lbl].change) do
			if tonumber(f) < tonumber(frame) and tonumber(info.changeType) == 1 then
				if not max or max < tonumber(f) then
					max = tonumber(f)
					mapId = info.changeMap
				end
			end
		end

		return mapId
	end
end

-- --添加聊天和目标按钮
function AnimDialogView:addNewQuestAndChat()
	-- 不在传记中
	if not BiographyControler:isInBiograpTask() then 
		self:delayCall(function ()
			if self.cfgData then
				if self.cfgData.animTrue  == nil or self.cfgData.animTrue ~= 1 then
				    local arrData = {
				        view = self,---界面
				        systemView = FuncCommon.SYSTEM_NAME.MISSION,
				        pos = {x = 0 ,y = -50},
				        data = self.missionData,
				    }
				    QuestAndChatControler:createInitUI(arrData)
				end
			end
		end,0.5)
	end
end

-- 此时mission是开启的
function AnimDialogView:setMissionOpen(missionOpen,missionData,missionScore)
	self.missionOpen = missionOpen
	self.missionData = missionData
	self.missionScore = missionScore
	-- 添加聊天框
	-- self:addChatView()
	--   添加目标和聊天的界面
	-- self:addQuestAndChat()
    local missionType = FuncMission.getMissionTypeById( self.missionData.id )
    if tonumber(missionType) == FuncMission.MISSIONTYPE.QUEST then
        self:addMissionQuestUI()
    end
end

function AnimDialogView:setRaidId(raidId)
	self.raidId = raidId
end


-- 判断是否将body加入剧情中
function AnimDialogView:checkBodyIntoAnim(bodyId)
	local lowPhone = AppInformation:checkIsLowDevice(  )
	local into = true
	if lowPhone then
		-- 表里的需要加一个新的字段
		local hideBodysInLow = self.cfgData.hidebody or {}
		for i,v in pairs(hideBodysInLow) do
			local id = "body"..v
			if id == bodyId then
				into = false
			end
		end
	end
	return into
end
-- 判断是否将body加入剧情中
function AnimDialogView:checkEffectIntoAnim()
	local lowPhone = AppInformation:checkIsLowDevice(  )
	local into = true
	if lowPhone then
		into = false
	end
	return into
end

--[[
初始化数据
@data:配置文件中的所有的数据
@events:对应spineEvent中所有的事件 key val 格式（key(label),val(对应的事件)）
一次性将所有的事件全部加载进来。然后
]]
function  AnimDialogView:initData ( data,events )
	--cgf中的配置数据
	self.cfgData = data
	--所有的时间 key val
	self.allEvents = events
	--用于更新的所有的models
	self.allModels = {}
	--人物spine models
	self.allBoneModels = {} 
    self.allMissionModels = {} 
    self.allEffectModels = {}
	self.allFaZhenModels = {}

    -- 用于记录body和effect map
    self.bodyEffect = {}

    self.hideIconData = {}

	self.edge = {}
	if self.cfgData.edge then
		self.edge = string.split(self.cfgData.edge[1],",")
	else
        table.insert(self.edge,0)
        table.insert(self.edge,0)
	end

	self.bodys = {}
	--加载所有的body
	for i = 1,35 ,1 do
		local bodyIndex = "body"..i
		if self.cfgData[bodyIndex] ~= nil then
			if self:checkBodyIntoAnim(bodyIndex) then
				self.bodys[bodyIndex] = {}
            	self.bodys[bodyIndex].sourceId = self.cfgData[bodyIndex]
			end
		end
	end
	
	if self.cfgData["box"] then
		self.boxBody = {}
		self.boxBody.spineName = self.cfgData["box"]	
	end



	self.events = {}
	self.allSound = {}

	if not empty(self.allEvents ) then

		for kk,vv in pairs(self.allEvents) do
			self.events[kk] = {}
			self.events[kk].actions = {}
			self.events[kk].effect1 = {}
			self.events[kk].effect2 = {}
			self.events[kk].plots = {}
			self.events[kk].black = {}
			self.events[kk].chat = {}
			self.events[kk].animed = {}
			self.events[kk].emoi = {}
			self.events[kk].sound = {}
			self.events[kk].shake = {}
			self.events[kk].change = {}
			self.events[kk].insertPictures = {}
			self.events[kk].hideBtn = {}

			for k,v in pairs(vv) do
				local keys = string.split(k, "#")
				if keys[1] == "action" then
					self:loadActionEvents(kk,keys,v)
				elseif keys[1] == "effect1" then
					--todo
					 self:loadEffect1Events(kk,keys,v)
				elseif keys[1] == "effect2" then
					--todo
					--这里需要加载effect2对应的特效效果
					self:loadEffect2Events(kk,keys,v)
				elseif keys[1] == "plot" then
					--
					self:loadPlotEvents(kk,keys,v)
				elseif keys[1] == "scene" then
					--黑屏操作
					self:loadSceneEvents(kk,keys,v)
				elseif keys[1] == "chat" then
					--chat加载
					self:loadChatEvents(kk,kyes,v)
				elseif keys[1] == "lock" then
					--todo
					self:loadLockEvents(kk,keys,v)
				elseif keys[1] == "animend" then
					--加载动画结束的事件。当遇到这个事件就结束
					self:loadAnimedEvents(kk,keys,v)	
				elseif keys[1] == "emoticon" then
					--加载表情展示
					self:loadEmoiEvents(kk,keys,v)
				elseif keys[1] == "sound" then
					--加载声音
					self:loadSoundEvents(kk,keys,v)
				elseif keys[1] == "shake" then
					--加载震屏
					self:loadShakeEvents(kk,keys,v)
				elseif keys[1] == "change" then
					self:loadChangeLayerEffect(kk,keys,v)
				elseif keys[1] == "InsertPictures" then
					self:loadInsertPicturesEvents(kk,keys,v)
				elseif keys[1] == "conceal" then
					self:loadHideBtnEvents(kk,keys,v)
				end
			end

		end
	end

end
--[[
加载actions事件
]]
function AnimDialogView:loadInsertPicturesEvents(animLabel,keys,insertPictures)
	for k,v in pairs(insertPictures) do
		self.events[animLabel].insertPictures[tostring(v.frame)] = {}
		self.events[animLabel].insertPictures[tostring(v.frame)].floatVal = v.float
		self.events[animLabel].insertPictures[tostring(v.frame)].intVal = v.int
		self.events[animLabel].insertPictures[tostring(v.frame)].name = v.name
		self.events[animLabel].insertPictures[tostring(v.frame)].stringVal = v.string 
	end
end
--[[
加载actions事件
]]
function AnimDialogView:loadHideBtnEvents(animLabel,keys,hideBtn)
	for k,v in pairs(hideBtn) do
		self.events[animLabel].hideBtn[tostring(v.frame)] = {}
		self.events[animLabel].hideBtn[tostring(v.frame)].floatVal = v.float
		self.events[animLabel].hideBtn[tostring(v.frame)].intVal = v.int
		self.events[animLabel].hideBtn[tostring(v.frame)].name = v.name
		self.events[animLabel].hideBtn[tostring(v.frame)].stringVal = v.string 
	end
end

--[[
加载actions事件
]]
function AnimDialogView:loadActionEvents(animLabel,keys,actions)
	if self.events[animLabel].actions[keys[2]] == nil then
		self.events[animLabel].actions[keys[2]] = {}
	end
    for kk,vv in pairs(actions) do
        self.events[animLabel].actions[keys[2]][tostring(vv.frame)] = {}
        --帧数
	    self.events[animLabel].actions[keys[2]][tostring(vv.frame)].frame = vv.frame
        --动作标签
	    self.events[animLabel].actions[keys[2]][tostring(vv.frame)].actionLabel = keys[3]

        --float参数
	    self.events[animLabel].actions[keys[2]][tostring(vv.frame)].floatVal = vv.float
	    --int参数
	    self.events[animLabel].actions[keys[2]][tostring(vv.frame)].intVal = vv.int
	    --string参数
	    self.events[animLabel].actions[keys[2]][tostring(vv.frame)].stringVal = vv.string
	    -- 特效和动作合并
	    
        --	    if vv.string and vv.string ~= "" then
        --	    	self:loadEffect1Events(animLabel,keys,{vv})
        --	    end
        self:loadEffect1Events(animLabel,keys,{vv})
	    --name参数
	    self.events[animLabel].actions[keys[2]][tostring(vv.frame)].name = vv.name
    end
end


--[[
加载effect1类型效果
]]
function AnimDialogView:loadEffect1Events(animLabel,keys,effect1)
	if empty( self.events[animLabel].effect1[tostring(keys[2])] ) then
		self.events[animLabel].effect1[tostring(keys[2])] = {}	
	end
	for kk,vv in pairs(effect1) do

		-- 低端机处理 用第二套资源
		if self.bodys[tostring(keys[2])] == nil then
			break
		end
		local strD = string.split( vv.string  ,"$")
		local strInfo = strD[1]
		if not self:checkEffectIntoAnim() then
			strInfo = strD[2]
		end
		if strInfo == nil then
			strInfo = strD[1]
		end
		
		self.events[animLabel].effect1[tostring(keys[2])][tostring(vv.frame)] = {}
		--local effect1Item = {}
		--帧
		self.events[animLabel].effect1[tostring(keys[2])][tostring(vv.frame)].frame = vv.frame
		--int参数
		self.events[animLabel].effect1[tostring(keys[2])][tostring(vv.frame)].intVal = vv.int
		--float参数
		self.events[animLabel].effect1[tostring(keys[2])][tostring(vv.frame)].floatVal = vv.float
		--string 参数
		self.events[animLabel].effect1[tostring(keys[2])][tostring(vv.frame)].stringVal = vv.string 
        if vv.string == nil or vv.string == "" then
		    self.events[animLabel].effect1[tostring(keys[2])][tostring(vv.frame)].effects = {}
		    local eff = {}
			eff.effectName = ""   		--特效的名字
			eff.zorder = 0				--特效的层级
            eff.circle = 0				--特效的循环
			eff.binder = keys[2]
			-- table.insert(self.events[animLabel].effect1[tostring(keys[2])][tostring(vv.frame)].effects, eff)
        else
        	local params = string.split2d( strInfo  ,"#",",")
		    self.events[animLabel].effect1[tostring(keys[2])][tostring(vv.frame)].effects = {}
		    for iii,vvv in ipairs(params) do
			    local eff = {}
			    eff.effectName = params[iii][1]   		--特效的名字
			    eff.zorder = tonumber(params[iii][2])				--特效的层级
                eff.circle = params[iii][3] or 0				--特效的循环
                eff.totalFrame = params[iii][4] or 0			--特效停止
			    eff.binder = keys[2]
			    table.insert(self.events[animLabel].effect1[tostring(keys[2])][tostring(vv.frame)].effects, eff)
		    end
        end
	end
end

--[[
加载effect2类型
]]
function AnimDialogView:loadEffect2Events(animLabel,keys,effect2)
	local v = effect2
	self.events[animLabel].effect2[tostring(v[1].frame)] = {}
	--帧
	self.events[animLabel].effect2[tostring(v[1].frame)].frame = v[1].frame
	--int参数
	self.events[animLabel].effect2[tostring(v[1].frame)].intVal = v[1].int
	--float参数
	self.events[animLabel].effect2[tostring(v[1].frame)].floatVal = v[1].float
	--string参数
	self.events[animLabel].effect2[tostring(v[1].frame)].stringVal = v[1].string
	--
	local params = string.split(v[1].string,",")
	self.events[animLabel].effect2[tostring(v[1].frame)].effectName = params[1]
	self.events[animLabel].effect2[tostring(v[1].frame)].zorder = params[2] ~= nil and params[2] or 0
end



function AnimDialogView:loadPlotEvents(animLabel,keys,plots)
	local v = plots
	self.events[animLabel].plots[tostring(v[1].frame)] = {}
	--帧
	self.events[animLabel].plots[tostring(v[1].frame)].frame = v[1].frame
	--float参数
	self.events[animLabel].plots[tostring(v[1].frame)].floatVal = v[1].float
	--int参数
	self.events[animLabel].plots[tostring(v[1].frame)].intVal = v[1].int
	--string参数
	self.events[animLabel].plots[tostring(v[1].frame)].stringVal = v[1].string 
	local params = string.split(v[1].name,"#")
	self.events[animLabel].plots[tostring(v[1].frame)].plotId = params[2]
	local sounds = FuncPlot.getSoundsById(params[2],UserModel:avatar())
	for i,v in pairs(sounds) do
		table.insert(self.allSound, v)
	end
end

--[[
加载scene效果
]]
function AnimDialogView:loadSceneEvents(animLabel,keys,scenes)
	local v = scenes
	for kk ,vv in pairs(v) do
		self.events[animLabel].black[tostring(vv.frame)] = {}	
		self.events[animLabel].black[tostring(vv.frame)].floatVal = vv.float
		self.events[animLabel].black[tostring(vv.frame)].intVal = vv.int
		self.events[animLabel].black[tostring(vv.frame)].frame = vv.frame
		self.events[animLabel].black[tostring(vv.frame)].stringVal = vv.string
		local params = string.split(vv.string,",")
		local btype = tonumber(params[1])
		--黑屏特效的类型  目前只有一种类型
		self.events[animLabel].black[tostring(vv.frame)].type = btype

		local frameCnt = nil
		local start = nil
		local colorFrame = nil
		-- 第一种
		if btype == 1 then
			frameCnt = tonumber(params[2])
			start = 3
			colorFrame = 1
		elseif btype == 2 then
			frameCnt = tonumber(params[2])
			start = 4
			colorFrame = tonumber(params[3])
		end
		--黑屏特效的时长
		self.events[animLabel].black[tostring(vv.frame)].frameCnt = frameCnt
		--字颜色
		self.events[animLabel].black[tostring(vv.frame)].colorFrame = colorFrame
        -- 对话内容
        local _dialog = {}

        for i = start,#params do
            _dialog[#_dialog + 1] = params[i]
        end
        self.events[animLabel].black[tostring(vv.frame)].dialog = _dialog

        echo("-------黑屏事件====时长= ",params[2])
	end
end


--[[
加载chat事件
]]
function AnimDialogView:loadChatEvents(animLabel,keys,chats)
	for k,v in pairs(chats) do
		local params = string.split( v.string,"," )
		if self.bodys[tostring(params[1])] == nil then
			break
		end
		self.events[animLabel].chat[tostring(v.frame)] = {}
		self.events[animLabel].chat[tostring(v.frame)].frame = v.frame
		self.events[animLabel].chat[tostring(v.frame)].floatVal = v.float
		self.events[animLabel].chat[tostring(v.frame)].intVal = v.int
		self.events[animLabel].chat[tostring(v.frame)].name = v.name
		self.events[animLabel].chat[tostring(v.frame)].stringVal = v.string 
		
		--body头上出现相应的图标
		self.events[animLabel].chat[tostring(v.frame)].body = params[1]
		--图标的类型
		self.events[animLabel].chat[tostring(v.frame)].dialog1 = params[2]
		--图标的偏移x
		self.events[animLabel].chat[tostring(v.frame)].dialog2 = params[3]
		--图标的偏移y
		self.events[animLabel].chat[tostring(v.frame)].dialog3 = params[4]
	end
	--echo(animLabel,"============")
	--dump(self.events[animLabel].chat)
end


--[[
加载镜头事件
]]
function AnimDialogView:loadCamerEvents(keys,camera)

end




--[[
加载lock事件
]]
function AnimDialogView:loadLockEvents(animLabel,keys,locks)
	--dump(locks)
	if empty( self.locks ) then
		self.locks = {}
	end
	if empty(self.locks[animLabel]) then
		self.locks[animLabel] = {}
	end
	for k,v in pairs(locks) do
		self.locks[animLabel][tostring(v.frame)] = {}
		self.locks[animLabel][tostring(v.frame)].frame = v.frame
		self.locks[animLabel][tostring(v.frame)].floatVal = v.float
		self.locks[animLabel][tostring(v.frame)].intVal = v.int
		self.locks[animLabel][tostring(v.frame)].name = v.name
		self.locks[animLabel][tostring(v.frame)].stringVal = v.string 
        --		local params = string.split(v.string ,",")
        local paramsT = string.split2d(v.string  ,"#",",")
        for ii,vv in pairs(paramsT) do
            params = vv
            --解锁类型
		    self.locks[animLabel][tostring(v.frame)].type = params[1]
            -- plot单独处理
            if params[1] == "plot" then
                local _data = {};
                _data.param1 = vv[2]
                _data.param2 = vv[3]
                _data.param3 = vv[4]
                _data.param4 = vv[5]
                if self.locks[animLabel][tostring(v.frame)].data then
                    table.insert(self.locks[animLabel][tostring(v.frame)].data,_data)
                else
                    self.locks[animLabel][tostring(v.frame)].data = {}
                    table.insert(self.locks[animLabel][tostring(v.frame)].data,_data)
                end
            elseif params[1] == "collect" then
            	if not self.locks[animLabel][tostring(v.frame)].data then
            		self.locks[animLabel][tostring(v.frame)].data = {}
            	end
            	local temp = self.locks[animLabel][tostring(v.frame)].data
            	temp.movebd = params[2] -- 放养的角色
            	temp.num = params[3] -- 采集数量
            	temp.collects = {}

            	for i=4,#params,2 do
            		local bd = params[i]
            		local num = tonumber(params[i+1])
            		table.insert(temp.collects, {
            			bd = bd,
            			num = num,
            		})
            	end
        	elseif params[1] == "position" then
        		self.locks[animLabel][tostring(v.frame)].data = {}
        		local temp = self.locks[animLabel][tostring(v.frame)].data
        		temp.movebd = params[2]
        		temp.x = tonumber(params[3])
        		temp.y = tonumber(params[4])
        		temp.width = tonumber(params[5])
        		temp.height = tonumber(params[6])
    		elseif params[1] == "multiplechat" then
    			self.locks[animLabel][tostring(v.frame)].data = {}
    			local temp = self.locks[animLabel][tostring(v.frame)].data
    			temp.movebd = params[2]
    			temp.unlockbody = params[3]
    			temp.bodyplots = {}

    			for i=4,#params,2 do
    				local bd = params[i]
    				local plotId = params[i+1]
    				table.insert(temp.bodyplots, {
    					bd = bd,
    					plotId = plotId,
    				})
    			end
			elseif params[1] == "battle" then
				self.locks[animLabel][tostring(v.frame)].data = {}
				local temp = self.locks[animLabel][tostring(v.frame)].data
				temp.movebd = params[2]
				temp.battletype = params[3]
				temp.bodybattles = {}

				for i=4,#params,2 do
					table.insert(temp.bodybattles, {
						bd = params[i],
						params = params[i+1],
					})
				end
			elseif params[1] == "game" then
				self.locks[animLabel][tostring(v.frame)].data = {}
				local temp = self.locks[animLabel][tostring(v.frame)].data
				temp.triggertype = tonumber(params[2]) -- 触发类型
				temp.gtype = tonumber(params[3]) -- 游戏类型
				temp.gid = tonumber(params[4]) -- 游戏id
				if temp.triggertype == 1 then
					temp.movebd = params[5] -- 放养body
					temp.unlockbody = params[6] -- 解锁body
				end
            else
                --解锁参数1  放养的角色
		        self.locks[animLabel][tostring(v.frame)].param1 = params[2]
		        --解锁参数2   头顶有chaticon的角色
		        self.locks[animLabel][tostring(v.frame)].param2 = params[3]
		        --图标类型
		        self.locks[animLabel][tostring(v.frame)].param3 = params[4]
		        --跳转到的label
		        self.locks[animLabel][tostring(v.frame)].param4 = params[5]
            end
        end
	end
	--self.tempLocktab = table.deepCopy(self.locks)
end


--[[
加载事件结束事件
]]
function AnimDialogView:loadAnimedEvents( animLabel,keys,animed )
	--self.events[animLabel].animed = {}
	for k,v in pairs(animed) do
		self.events[animLabel].animed[tostring(v.frame)] = {}
		self.events[animLabel].animed[tostring(v.frame)].frame = v.frame
		self.events[animLabel].animed[tostring(v.frame)].floatVal = v.float
		self.events[animLabel].animed[tostring(v.frame)].intVal = v.int
		self.events[animLabel].animed[tostring(v.frame)].name = v.name
		self.events[animLabel].animed[tostring(v.frame)].stringVal = v.string 
	end

end


--[[
加载表情事件
]]
function AnimDialogView:loadEmoiEvents( animLabel,keys,emois )
	-- echo("表情符号")
	-- dump(emois)
	-- echo("表情符号")

	for k,v in pairs(emois) do
		local params = string.split(v.string,",")
		if self.bodys[tostring(params[1])] == nil then
			break
		end
		self.events[animLabel].emoi[tostring(v.frame)] = {}
		self.events[animLabel].emoi[tostring(v.frame)].floatVal = v.float
		self.events[animLabel].emoi[tostring(v.frame)].intVal = v.int
		self.events[animLabel].emoi[tostring(v.frame)].name = v.name
		self.events[animLabel].emoi[tostring(v.frame)].stringVal = v.string 

		
		self.events[animLabel].emoi[tostring(v.frame)].body = params[1]
		self.events[animLabel].emoi[tostring(v.frame)].type = params[2] 		
	end

end
--[[
加载声音事件
]]
function AnimDialogView:loadSoundEvents( animLabel,keys,sounds )
	-- dump(sounds)

	for k,v in pairs(sounds) do
		self.events[animLabel].sound[tostring(v.frame)] = {}
		self.events[animLabel].sound[tostring(v.frame)].floatVal = v.float
		self.events[animLabel].sound[tostring(v.frame)].intVal = v.int
		self.events[animLabel].sound[tostring(v.frame)].name = v.name
		self.events[animLabel].sound[tostring(v.frame)].stringVal = v.string 

		local params = string.split(v.string,",")
		self.events[animLabel].sound[tostring(v.frame)].soundName = params[1]
		self.events[animLabel].sound[tostring(v.frame)].type = params[2]  -- 是否替换背景音乐  0 不替换 1替换	 	
		
		table.insert(self.allSound, params[1])
	end

end
--[[
加载声音震屏事件 
]]
function AnimDialogView:loadShakeEvents( animLabel,keys,shakes )

	for k,v in pairs(shakes) do
		self.events[animLabel].shake[tostring(v.frame)] = {}
		self.events[animLabel].shake[tostring(v.frame)].floatVal = v.float
		self.events[animLabel].shake[tostring(v.frame)].intVal = v.int
		self.events[animLabel].shake[tostring(v.frame)].name = v.name
		self.events[animLabel].shake[tostring(v.frame)].stringVal = v.string 

		local params = string.split(v.string,",")
		self.events[animLabel].shake[tostring(v.frame)].frameCnt = params[1] -- 震屏时长
	end

end

--[[
加载转场特效事件
]]
function AnimDialogView:loadChangeLayerEffect(animLabel,keys,changes)
	for k,v in pairs(changes) do
		self.events[animLabel].change[tostring(v.frame)] = {}
		self.events[animLabel].change[tostring(v.frame)].floatVal = v.float
		self.events[animLabel].change[tostring(v.frame)].intVal = v.int
		self.events[animLabel].change[tostring(v.frame)].name = v.name
		self.events[animLabel].change[tostring(v.frame)].stringVal = v.string 

		local params = string.split(v.string,",")
		self.events[animLabel].change[tostring(v.frame)].changeType = params[1]
		if tonumber(params[1]) == 1 then
			self.events[animLabel].change[tostring(v.frame)].changeMap = params[2]  
			self.events[animLabel].change[tostring(v.frame)].changeTime = params[3] 
		else
			self.events[animLabel].change[tostring(v.frame)].changeMap = nil  
			self.events[animLabel].change[tostring(v.frame)].changeTime = params[2] 
		end 
		self.events[animLabel].change[tostring(v.frame)].effectType = params[4]
		self.events[animLabel].change[tostring(v.frame)].effectFlashName = params[5]
	end
end

-- 给一个系统级的锁定的接口
function AnimDialogView:chkSystemLock()
	if self._forceLock then
		return true
	end

	-- 有临时移动对象，需要锁定
	if self.moveBodyTemp then
		return true
	end

	return false
end

-- 设置强制锁定
function AnimDialogView:setForceLock(flag)
	if not type(flag) == "boolean" then return end

	self._forceLock = flag
end

--[[
检查帧是否开启
1帧出现一个lock所有可以按照 key (帧),value(condAttr)来存储
--这里标示 帧不能往下走 要停在当前帧
]]
function AnimDialogView:chkLock()
	-- 这个时候动画等着Loading，锁定到1帧
	if BattleControler:isWaitLoadingAni() and self.currentFrame > 0 then
		return true
	end

	if not empty(self.locks) and not empty( self.locks[self.animLabel] )  then
		--如果有上锁条件
		if not empty( self.locks[self.animLabel][tostring(self.currentFrame)] )  then
			local lockType = tostring(self.locks[self.animLabel][tostring(self.currentFrame)].type)
			--这个是plot锁
			if lockType == "plot" then
				--暂时这么写 为了测试plot锁
				--dump(self.locks[tostring(self.currentFrame)])
				--echo()
				--echo("锁上了---",self.currentFrame)
				self._nowLockType = "plot"
				return true
			end
			--这个是chat锁
			if lockType == "chat" then
				local data = self.locks[self.animLabel][tostring(self.currentFrame)]
				--这个时候 要放养
				self:autoMoveBody(data.param1)
				--头顶有chatIcon
				local body = self.bodys[tostring(data.param2)].spine
                if tonumber(data.param3) > 0 then
                    body:setChatIcon(data.param3,0,0,c_func(self.doChatClick,self,body,self.currentFrame))
                    local chat_data = {}
                    chat_data.modeType = "chat"
                    chat_data.posX = body:getPositionX()
                    chat_data.posY = body:getPositionY() + body:getChatHeight()
                    chat_data.iconType = data.param3
                    self.hideIconData["chat"] = chat_data
                end
				
				IS_SHOW_CLICK_EFFECT = false
				self.touchNode:setTouchEnabled(true)

				--echo("这里要执行一个跳转label")
				self.spineMainData.frame = self.currentFrame

				local lbl = data.param4
				--echo("Chat上锁了-------- 当前lbl",lbl,tostring(lbl) ~= "0")
				local fcnt = 0
				self.continueFrame = false
				if tostring(lbl) == "0" then
					lbl = self.animLabel
					fcnt = self.currentFrame
				else
					--播放跳转帧动画
					self.spine:playLabel(lbl)
					self.spine:gotoAndPlay(fcnt)
					self.animLabel = tostring(lbl)
					self.currentFrame = fcnt
					self.totalFrame = self.spine:getTotalFrames(self.animLabel)
					self.continueFrame = true
				end
                self:showBuZhenBtn()

                self._nowLockType = "chat"
				return true
			end
			--宝箱锁
			if lockType == "box" then
				local data = self.locks[self.animLabel][tostring(self.currentFrame)]
				-- dump(data)
				-- echoError("===================")
				--宝箱上边的chatIcon
				local body = self.boxBody.spine
				--echo("锁的帧数-------",self.currentFrame,"=-===================")

				-- 宝箱出现效果，宝箱有三个过程（出现activate，lock循环，打开open）
				body:visible(true)
				body:playLabel("activate")
				body:setActivateCall(function()
					--要放养的角色
					self:autoMoveBody(data.param1)
					self.atuoBodyPosX = self.moveBody:getPositionX()
					self.atuoBodyPosY = self.moveBody:getPositionY()
					IS_SHOW_CLICK_EFFECT = false
					self.touchNode:setTouchEnabled(true)

					body:setChatIcon(1, c_func(self.doBoxIconClick,self,body,self.currentFrame))
					-- 给引导发一条消息
	                EventControler:dispatchEvent(TutorialEvent.CUSTOM_TUTORIAL_MESSAGE, {tutorailParam = TutorialEvent.CustomParam.AnimBoxLock .. self.cfgData.id})
				end)

                local box_data = {}
                box_data.modeType = "box"
                box_data.posX = body:getPositionX() + 60
                box_data.posY = body:getChatHeight() - 140
                box_data.iconType = 3
                self.hideIconData["box"] = box_data
				

				--这里先不处理跳转动画的逻辑
				self.spineMainData.frame = self.currentFrame

				local lbl = data.param2
				--echo("lbl",lbl)
				local fcnt = 0
				self.continueFrame = false
				if tostring(lbl) == "0" then
					--echo("---------------")
					lbl = self.animLabel
					fcnt = self.currentFrame
				else
					--播放跳转帧动画
					self.spine:playLabel(lbl)
					self:playSceneSpine(fcnt)
					self.animLabel = tostring(lbl)
					self.currentFrame = fcnt
					self.totalFrame = self.spine:getTotalFrames(self.animLabel)
					self.continueFrame = false
				end
				
                self:showBuZhenBtn()                
                
				--是锁定了

				self._nowLockType = "box"
				return true
			end
			--手势锁
			if lockType == "action" then
				--是锁定了
				self.handAction = true
				local data = self.locks[self.animLabel][tostring(self.currentFrame)]
				local paramT = string.split(data.stringVal,",")
				if self.bodys[paramT[5]] and not self.handBodyPos then
					local body = self.bodys[paramT[5]].spine
					self.handBodyPos = {x=body:getPositionX(),y=body:getPositionY()}
				end
				if tonumber(paramT[2]) == 2 then
					if not self.handActionAnim then
						local aniName = "UI_qiangzhitishi_tishihuanren01"
						self.handActionAnim = self.controler.view:createUIArmature("UI_qiangzhitishi",aniName,self.mainNode,
							true, GameVars.emptyFunc)
						self.handActionAnim:setPositionX(self.handBodyPos.x+tonumber(paramT[3]))
						self.handActionAnim:setPositionY(self.handBodyPos.y+tonumber(paramT[4]))
						self.handActionAnim:setLocalZOrder(888)
					end
				elseif tonumber(paramT[2]) == 5 then
					if not self.handActionAnim then
						local aniName = "UI_qiangzhitishi_002"
						self.handActionAnim = self.controler.view:createUIArmature("UI_qiangzhitishi",aniName,self.mainNode,
							true, GameVars.emptyFunc)
						self.handActionAnim:setPositionX(tonumber(paramT[3]))
						self.handActionAnim:setPositionY(tonumber(paramT[4]))
						self.handActionAnim:setScale(0.5)
						self.handActionAnim:setLocalZOrder(888)
						self.handActionAnim:visible(false)
					end
				end

				self._nowLockType = "action"
				return true
			end
			-- 收集锁
			if lockType == "collect" then
				local params = self.locks[self.animLabel][tostring(self.currentFrame)].data
				-- echoError("收集锁")
				self:autoMoveBody(params.movebd)

				IS_SHOW_CLICK_EFFECT = false
				self.touchNode:setTouchEnabled(true)

				for _,info in ipairs(params.collects) do
					-- 注册收集的事件
					local model = self:getAnimBody(info.bd)
					model:setBodyTouchFunc(c_func(self.doBodyCollectClick,self,model,self.currentFrame,params,info),"collect")
				end

				self._nowLockType = "collect"
				return true
			end
			-- 位置锁
			if lockType == "position" then
				-- echoError("位置锁")
				local params = self.locks[self.animLabel][tostring(self.currentFrame)].data
				self:autoMoveBody(params.movebd)

				IS_SHOW_CLICK_EFFECT = false
				self.touchNode:setTouchEnabled(true)

				self._nowLockType = "position"
				return true
			end
			-- 多人物对话类型
			if lockType == "multiplechat" then
				local params = self.locks[self.animLabel][tostring(self.currentFrame)].data
				self:autoMoveBody(params.movebd)
				for _,info in ipairs(params.bodyplots) do
					-- 注册点击的对话事件
					local model = self:getAnimBody(info.bd)
					model:setBodyTouchFunc(c_func(self.doBodyMultipleClick,self,model,self.currentFrame,params.unlockbody,info.plotId),"multiplechat")
				end

				self._nowLockType = "multiplechat"
				return true
			end
			-- 战斗类型（点击后的结果是进战斗，需要考虑的是从战斗回来恢复的问题）
			if lockType == "battle" then
				local params = self.locks[self.animLabel][tostring(self.currentFrame)].data
				self:autoMoveBody(params.movebd)

				-- 注册战斗的事件
				for _,info in ipairs(params.bodybattles) do
					-- 注册点击战斗的事件
					local model = self:getAnimBody(info.bd)
					model:setBodyTouchFunc(c_func(self.doBodyBattleClick, self, model, self.currentFrame, params.battletype, info.params), "battle")
					-- 战斗icon
					model:setChatIcon(2,0,0)
				end

				-- 暂时考虑战斗不需要处理解锁，因为进战斗后回来恢复可以直接跳过锁
				self._nowLockType = "battle"
				return true
			end
			-- 游戏类型锁
			if lockType == "game" then
				local params = self.locks[self.animLabel][tostring(self.currentFrame)].data
				if params.triggertype == 1 then
					-- 放养和注册解锁
					self:autoMoveBody(params.movebd)
					local model = self:getAnimBody(params.unlockbody)
					model:setBodyTouchFunc(c_func(self.doGameClick, self, model, self.currentFrame, params), "game")
				elseif params.triggertype == 2 then
					self:doGameClick(nil, self.currentFrame, params)
				end

				self._nowLockType = "game"
				return true
			end
		end
	end
	--echo("不锁---------------")
	return false
end

function AnimDialogView:getAnimBody(body)
	return self.bodys[body].spine
end

-- 获取某人物在动画中的位置
function AnimDialogView:getAnimBodyPos(body)
	if not body then return end
	local name = body:getNameStr()
	local x = self.spine:getBoneTransformValue(name, "x")
	local y = self.spine:getBoneTransformValue(name, "y")
	local sx = self.spine:getBoneTransformValue(name, "sx")
	local sy = self.spine:getBoneTransformValue(name, "sy")

	return x,y,sx,sy
end

--[[
放养 parms2对应的参数
params对应的参数
]]
function AnimDialogView:autoMoveBody(body)
	
	if not self.autoMove then
		--echo("放养对象----------",self.currentFrame,"===========",body,"=====")
		local model = self.bodys[body].spine
		local posx = model:getPositionX()
		local posy = model:getPositionY()

		--这里要进行放养角色的按钮事件的相应处理。弹出   布阵和更换时装的菜单
		model:setMenuClick(true,c_func(self.doShiZhuangClick,self),c_func(self.doBuZhenClick,self) )

		self.moveBody = model
		self.autoMove = true

		if self:isLandMark() then
			if self.initPosX and self.initPosY then
				-- 放养对象的起始位置（暂时只有地标用）
				self.moveBody:setPosition(cc.p(self.initPosX, self.initPosY ))
				-- 设置显示
				self.moveBody:visible(true)
			end
		end
	end
end


function AnimDialogView:followToTargetPos( targetX,targetY ,sx,sy)
	if not targetY then
		targetY = 0
	end
	if not self.screenFocusX then
		self.screenFocusX = targetX
	end
	if not self.screenFocusY then
		self.screenFocusY = targetY
	end
	local disX = targetX - self.screenFocusX
	local disY = targetY - self.screenFocusY
	local dis = math.sqrt(disX * disX +  disY * disY)
	local minDis = 25
	if dis < minDis then
		self.screenFocusX = targetX
		self.screenFocusY = targetY
	else
		local ang = math.atan2(disY, disX)
		-- 0.1是缓动系数
		local moveDistance = dis * 0.1
		if moveDistance < minDis then
			moveDistance = minDis
		end
		self.screenFocusX = self.screenFocusX + moveDistance * math.cos(ang)
		self.screenFocusY = self.screenFocusY + moveDistance * math.sin(ang)
	end

	--在做边界判断
	local halfWid = GameVars.width/2
	local xoffset = 0

	if self.map then
		if self.screenFocusX >  0 then
			self.screenFocusX = 0
		elseif self.screenFocusX < -self.map:getMaxMapWidth()+GameVars.gameResWidth then
			self.screenFocusX = -self.map:getMaxMapWidth()+GameVars.gameResWidth
		end
	end
	self.mapOffsetX = self.screenFocusX
	local realX =  - self.screenFocusX
	local realY = -(-GameVars.height/2 -self.screenFocusY )
	if self.map then 
		self.map:updatePos(realX,0)
	end
	self.mainNode:pos(realX,0)
	--暂时暴力
	if sx and sy then
		--更新scale
		self.jintouNode:setScaleX(sx)
		self.jintouNode:setScaleY(sy)
	end
	self:addHintIcon(realX)
end

--边界提示点击事件
function AnimDialogView:hintIconClick( _type)
	self:delayCall(function ()
        if tonumber(_type) == 3 then
			self:doBoxIconClick(self.boxBody.spine,self.currentFrame)
		else
			local data = self.locks[self.animLabel][tostring(self.currentFrame)]
		    local body = self.bodys[tostring(data.param2)].spine
		    local frame = self.currentFrame
		    self:doChatClick(body,frame)
		end
    end,1/GameVars.GAMEFRAMERATE)
end
--添加信息提示功能
function AnimDialogView:addHintIcon(realX)
    if not self.chatIconSp and table.isEmpty(self.hideIconData) then
        return
    end
    
    if not table.isEmpty(self.hideIconData) then
        local _data = nil
        for i,v in pairs(self.hideIconData) do
            _data = v
        end
        if not self.chatIconSp or self.chatIconType ~= _data.iconType then
        	self.chatIconSp = nil
	        self:insterArmatureTexture("UI_shijieditu");
	        if tonumber(_data.iconType) == 1 then
	        	-- 对话提示
				self.chatIconSp = FuncArmature.createArmature("UI_shijieditu_duihua",self._root, 
					true, GameVars.emptyFunc)
	        elseif tonumber(_data.iconType) == 2 then
	        	-- 对话提示
				self.chatIconSp = FuncArmature.createArmature("UI_shijieditu_zhandou",self._root, 
					true, GameVars.emptyFunc)
	        elseif tonumber(_data.iconType) == 3 then
	        	-- 宝箱提示
	        	self.chatIconSp = FuncArmature.createArmature("UI_shijieditu_baoxiang",self._root, 
					true, GameVars.emptyFunc)
	        end
	        self.chatIconType = _data.iconType
	        self.chatIconSp:scale(0.7)
	        -- local totalFrame = self.chatIconSp:getAnimation():getRawDuration()
	        -- self.chatIconSp:gotoAndPause(totalFrame)
	        self.chatIconSp:playWithIndex(1, true)
	        self.chatIconSp:setTouchEnabled(true)
	        self.chatIconSp:setTouchedFunc(c_func(self.hintIconClick,self,_data.iconType))
        end
    end
    if table.isEmpty(self.hideIconData) then
        self.chatIconSp:visible(false)
    end
    if not table.isEmpty(self.hideIconData) then
        local _data = nil
        for i,v in pairs(self.hideIconData) do
            _data = v
        end
        local iconPosX = GameVars.width/2 - 45;
        local posX = -_data.posX
        local posY = _data.posY
        local disX = realX - posX ;
        local offsetX = 20
        if tonumber(self.chatIconType) == 3 and disX > 0 then
        	offsetX = 80
        end
        if disX > 0 and math.abs(disX) > (GameVars.width/2 + offsetX) then
            self.chatIconSp:visible(true)
            self.chatIconSp:pos(iconPosX,posY)
        elseif disX < 0 and math.abs(disX) > (GameVars.width/2 + 40 ) then
            self.chatIconSp:visible(true)
            self.chatIconSp:pos(-iconPosX,posY)
        else
            self.chatIconSp:visible(false)
        end
    end
end

--[[
点击时装菜单
]]
function AnimDialogView:doShiZhuangClick()
	--echo("点击时装菜单=============")
	if self.moveBody then
		self.moveBody:doHideMenu()	
	end
	-- 判断是否开启
	-- if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.GARMENT) == true then 
	-- 	WindowControler:showWindow("CharMainView", 4)
	-- else
	-- 	WindowControler:showTips({text = "时装系统暂未开启"})
	-- end

	-- 6.28版本屏蔽 
	WindowControler:showTips(GameConfig.getLanguage("tid_common_2055"))
end


--[[
点击布阵菜单
]]
function AnimDialogView:doBuZhenClick()
	-- echo("点击布阵菜单=============")
	--WindowControler:showTips({text = "布阵系统已经开启了"})
	if self.moveBody then
		self.moveBody:doHideMenu()	
	end

	if LoginControler:isLogin() then
		local isOpen,_,_,locKTip = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.ARRAY)
		if isOpen then
			WindowControler:showTutoralWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.pve)
		else
			WindowControler:showTips(locKTip)
		end
	else 
		WindowControler :showTips(GameConfig.getLanguage("tid_common_2056"))
	end



	--WindowControler:showTutoralWindow("TeamFormationView",FuncTeamFormation.formation.pve)
end




--[[


这个方法写的有问题   需要优化 代码


检查解锁条件
检查解锁条件，是否执行了解锁
有两种情况会解锁
1:plotDialog播放到了某个order
2:玩家点击了某个body上边的chat Icon
-- 在这里就需要 self.currentFrame= self.currentFrame+1
@params type 解锁的类型
@params params1 参数1 
@params params2 参数2
]]
function AnimDialogView:chkUnLock(type,param1,param2)
	-- echo(type,param1,params2,"================")
	local lbl = self.spineMainData.label
	if self.locks and self.locks[lbl] then
		if tostring(type) == "plot" then
			for k,v in pairs(self.locks[lbl]) do
				if tostring(v.type) == tostring(type) then
				    for kk,vv in pairs(v.data) do
				        if tostring(vv.param1) == tostring(param1) and
					    tostring(vv.param2) == tostring(param2)  then
				            self:__unlock(k )
				            self:showJumpAndExitBtn()
				        end
				    end
				end
			end
		end
		if self.locks and self.locks[lbl] then
			if tostring(type) == "action" then
				for k,v in pairs(self.locks[lbl]) do
					if tostring(v.type) == tostring(type) then
					    if tostring(v.param1) == tostring(param1) then
					    -- tostring(v.param2) == tostring(param2)  then
				            self:__unlock(k )
				            self.handAction = nil
				            self.handActionAnim:removeFromParent()
				            self.handActionAnim = nil
				            self.handBodyPos = nil
							self.handToucSp:removeAllChildren()
							
				        end
					end
				end
			end
		end

		if tostring(type) == "chat" then
			-- echo("=-========---------------")
			for k,v in pairs(self.locks[lbl]) do
				--echo(v.frame,param1)
				if tostring(v.type) == tostring(type) and
					tostring(v.frame) == tostring(param1)
				then
					-- 赋值临时人物
					self.moveBodyTemp = self.moveBody

					self.autoMove = false
					-- 不置空这里，人物会不受剧情的运动约束
					self.moveBody = nil

					-- 为了保证能取到后续人物，需要多跳5帧（约定这几帧没有实际事件）
					self.currentFrame = self.currentFrame + 4
					self:__unlock( k)
				end
			end
		end   

		if tostring(type) == "box" then
			for k,v in pairs(self.locks[lbl]) do
				--echo(v.frame,params1)
				if tostring(v.type) == tostring(type) and
					tostring(v.frame) == tostring(param1)
				then
					self.moveBody = nil
					self.autoMove = false
					self:__unlock(k )				
				end
			end
		end

		if tostring(type) == "collect" then
			for k,v in pairs(self.locks[lbl]) do
				if tostring(v.type) == tostring(type) and
					tostring(v.frame) == tostring(param1)
				then
					-- 赋值临时人物
					self.moveBodyTemp = self.moveBody

					self.moveBody = nil
					self.autoMove = false
					-- 清理事件(注册在人物身体上的对应事件)
					for i,info in ipairs(v.data.collects) do
						local model = self:getAnimBody(info.bd)
						model:clearBodyTouchFunc("collect")
					end

					-- 为了保证能取到后续人物，需要多跳5帧（约定这几帧没有实际事件）
					self.currentFrame = self.currentFrame + 4
					self:__unlock(k )
				end
			end
		end

		if tostring(type) == "position" then
			for k,v in pairs(self.locks[lbl]) do
				if tostring(v.type) == tostring(type) and
					tostring(v.frame) == tostring(param1)
				then
					-- 赋值临时人物
					self.moveBodyTemp = self.moveBody

					self.moveBody = nil
					self.autoMove = false

					-- 为了保证能取到后续人物，需要多跳5帧（约定这几帧没有实际事件）
					self.currentFrame = self.currentFrame + 4
					self:__unlock(k )
				end
			end
		end

		if tostring(type) == "multiplechat" then
			for k,v in pairs(self.locks[lbl]) do
				if tostring(v.type) == tostring(type) and
					tostring(v.frame) == tostring(param1)
				then
					-- 赋值临时人物
					self.moveBodyTemp = self.moveBody

					self.moveBody = nil
					self.autoMove = false

					-- 清理事件(注册在人物身体上的对应事件)
					for i,info in ipairs(v.data.bodyplots) do
						local model = self:getAnimBody(info.bd)
						model:clearBodyTouchFunc("multiplechat")
					end

					-- 为了保证能取到后续人物，需要多跳5帧（约定这几帧没有实际事件）
					self.currentFrame = self.currentFrame + 4
					self:__unlock(k )
				end
			end
		end

		if tostring(type) == "game" then
			for k,v in pairs(self.locks[lbl]) do
				if tostring(v.type) == tostring(type) and
					tostring(v.frame) == tostring(param1)
				then
					if v.data.triggertype == 1 then
						-- 赋值临时人物
						self.moveBodyTemp = self.moveBody

						self.moveBody = nil
						self.autoMove = false

						-- 为了保证能取到后续人物，需要多跳5帧（约定这几帧没有实际事件）
						self.currentFrame = self.currentFrame + 4
						-- 清理事件
						local model = self:getAnimBody(v.data.unlockbody)
						model:clearBodyTouchFunc("game")
					end

					self:__unlock(k )
				end
			end
		end
	end
end

--[[
	处理平滑过渡
	即不论玩家最终将人物停在了什么位置
	我们都让他跑到预设位置
]]
function AnimDialogView:moveBodyTransition()
	if not self.moveBodyTemp then return end
	-- 找到当前帧应该在的位置
	local endX,endY = self:getAnimBodyPos(self.moveBodyTemp)

	local startX = self.moveBodyTemp:getPositionX()
	local startY = self.moveBodyTemp:getPositionY()

	local  speed = 17
	local xdis = math.abs(startX-endX)
	local ydis = math.abs(startY-endY)*3
	local time = math.sqrt( xdis*xdis + ydis*ydis )/speed

	if startX>endX then
		self.moveBodyTemp.view:setScaleX(-1)
		self.mapSpeed = -9
	else
		self.moveBodyTemp.view:setScaleX(1)
		self.mapSpeed = 9
	end

	self.moveBodyTemp:stopAllActions()
	self.moveBodyTemp:playLabel(Fight.actions.action_run)
	-- 开始移动
	self.moveBodyTemp:runAction(cc.Sequence:create({
		act.moveto(time/GameVars.GAMEFRAMERATE , endX, endY),
		act.callfunc(function()
			self.moveBodyTemp:playLabel(Fight.actions.action_stand)
			self.moveBodyTemp = nil
		end)
	}))
end

function AnimDialogView:__unlock(k )
	local lbl = self.spineMainData.label
	self._nowLockType = nil
	self.locks[lbl][k] = nil
	self.animLabel = self.spineMainData.label
	-- self.currentFrame = self.spineMainData.frame
	self.currentFrame = self.currentFrame + 1
	self.spine:playLabel(self.animLabel)
	self:playSceneSpine(self.currentFrame)
	self.totalFrame = self.spine:getTotalFrames(self.animLabel)

	-- 做一个移动的过渡
	self:moveBodyTransition()

    self.hideIconData = {}
    self:hideBuZhenBtn()
end

--[[
创建动画的背景
这个是地图，以后可能会游戏中的内容一样，要分为不通的场景
]]
function AnimDialogView:setScene(  )
	local rowData = self.cfgData
    if rowData.map ~= nil then
        self.map = MapControler.new(self.mapBackNode,self.mapFontNode,rowData.map)
        self.map:updatePos(self.mapOffsetX,0)
    end
    self:updateSceneScale()
end

--目前因为场景左右没有扩展 导致有些场景会漏边 所以需要整体放大
function AnimDialogView:updateSceneScale(  )
	if not self.map:isWidthMap() then
    	
    	local scale = GameVars.UIOffsetX  /GameVars.width
    	self._scaleNode:setScale(1+scale)
    	--需要将offsetY向上偏移
    	local offsetY = scale * GameVars.gameResHeight/2
    	self._scaleNode:pos(GameVars.UIOffsetX,-offsetY)
    else
    	self._scaleNode:setScale(1)
    	self._scaleNode:pos(0,0)
    end
end

--[[
初始化黑屏效果
]]
function AnimDialogView:initSceneBlack()
	self.blackImage = display.newSprite("a/a2_4.png"):addto(self.mainNode,1000):visible(false):anchor(0.5,0.5)
	self.blackImage:opacity(255 * 0.9)
	--黑屏的zorder 写死为999 要挡住所有的中景元素的 所以要大些
	self.blackImage:zorder(10000)
	--考虑到最大缩放系数所以黑屏的区域尽量大点
	self.blackImage:size(GameVars.width*4 ,GameVars.height*2  )
end

-- 显示布阵按钮
function AnimDialogView:showBuZhenBtn()
    echo("显示 布阵按钮-=---=-===",self.cfgData.animTrue) -- 只有剧情动画才有布阵按钮
    -- 判断布阵是否开启
    local isOpen,_,_,locKTip = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.ARRAY)
    -- 这版本要隐掉
    if isOpen and false then
    	if self.cfgData.animTrue and self.cfgData.animTrue == 1  then 
	    	if self.buzhenBtn then 
		        self.buzhenBtn:visible(true)
		    else
		        self.buzhenBtn = UIBaseDef:createPublicComponent( "UI_world_new_3","btn_zhenrong" )
	            self.buzhenBtn:getUpPanel().panel_red:setVisible(false)
		        self._root:addChild(self.buzhenBtn,21)
		        self.buzhenBtn:visible(true)
		        self.buzhenBtn:pos(GameVars.gameResWidth /2- self.widthScreenOffset/2-100,
		        	-GameVars.gameResHeight/2+100)
				FuncCommUI.setViewAlign(self.widthScreenOffset,self.buzhenBtn,UIAlignTypes.RightBottom)
		    	self.buzhenBtn:setTouchedFunc(c_func(self.doBuZhenClick,self))
		    end
	    end
    end
    self:hideBuZhenBtn()
end
-- 隐藏布阵按钮
function AnimDialogView:hideBuZhenBtn()
    if self.buzhenBtn then
        self.buzhenBtn:visible(false)
    end
end
--[[
点击事件
event中给出的坐标是全局坐标  x,y
]]
function AnimDialogView:onTouchEvent(event,isHide)
	local point = self.mainNode:convertToNodeSpace(cc.p(event.x,event.y))
	-- echo("touc point === ",point.x,point.y)
	if self.moveBody then
		self.moveBody:doHideMenu()	
	end
	--现在有放养的角色
	if not self.autoMove then
		return
	end

	local startX = self.moveBody:getPositionX()
	local startY = self.moveBody:getPositionY()
	local endX
	local endY

	--上边的边界
	local xiaY = -240
	--下边界
	local shangY = 40
	
	local callBack = event.callBack
	if callBack ~= nil then
		--这个直接就是骨骼中的坐标
		endX = event.x
		endY = event.y
	else
		--这里的坐标是场景坐标
		local point = self.mainNode:convertToNodeSpace(cc.p(event.x,event.y))
		endX = point.x
		endY = point.y
		-- echo("_______33333_______",point.x,point.y)
		-- echo("_______44444_______",self.mapOffsetX)
   --      local _point = self:checkInBlock(startX,startY, endX ,endY )
   --      if _point then
   --      	endX = _point.x
			-- endY = _point.y
   --      end
   	
		--经转化成为骨头坐标
		--这里需要重新计算限定位置
		
		--范围限定的目标坐标
		if endY>shangY or endY<xiaY then
			--如果超出区域了则不处理，下边的代码没有影响，但是不需要了。先不去掉，万一哪天又要改回来
			return
		end
		--X方向范围限定
		if endX < (-1966 + tonumber(self.edge[2])) then -- 右边界
			endX = -1966 + tonumber(self.edge[2])
		end
		if endX > (690 - tonumber(self.edge[1])) then -- 左边界
			endX = 690 - tonumber(self.edge[1])
		end

		local targetX = endX
		local targetY = endY

		if startX == endX then
			targetX = endX
			if endY>shangY then
				targetY = shangY
			end
			if endY<xiaY then
				targetY = xiaY
			end
		else
			-- 数学算法
			if endY< xiaY or endY>shangY then
				local kRaid = (startY-endY)/(startX-endX)
				if endY>shangY then
					targetY = shangY
				end
				if endY<xiaY then
					targetY = xiaY
				end	
				targetX = startX - (startY-targetY)/kRaid
			end
		end
		endX = targetX
		endY = targetY
	end


	local  scale = 0.9+0.1*(1-(endY-xiaY  )/280)

	if self.autoMove or callBack ~= nil then
		if not self.touchAnimT then
			self.touchAnimT = {}
			self.touchIndex = 0
		end
		if not isHide then
			if table.length(self.touchAnimT) < 3 then
				local targetAni = self:createUIArmature("UI_zhujiemian","UI_zhujiemian_dianji", self.mainNode, false,GameVars.emptyFunc)
				targetAni:setTouchEnabled(false)
				targetAni:pos(endX,endY)
				targetAni:playWithIndex(0,false)
				targetAni:doByLastFrame(false, false, function (  )
					targetAni:visible(false)
				end)
				table.insert(self.touchAnimT,targetAni )
			else
				self.touchIndex = self.touchIndex + 1
				if self.touchIndex > 3 then
					self.touchIndex = self.touchIndex - 3
				end
				local anim = self.touchAnimT[self.touchIndex]
				anim:pos(endX,endY)
				anim:visible(true)
				anim:startPlay(true,false)
				anim:doByLastFrame(false, false, function (  )
					anim:visible(false)
				end)

			end
		end
		
		--[[
		if endX>startX then
			self.moveBody.view:setScaleX(1)
		else
			--todo
			self.moveBody.view:setScaleX(-1)
		end
		]]
		-- 修改一下，如果endX == startX 不转向
		if endX>startX then
			self.moveBody.view:setScaleX(1)
		elseif endX<startX then
			self.moveBody.view:setScaleX(-1)
		end

		
		local  speed = 17
		local xdis = math.abs(startX-endX)
		local ydis = math.abs(startY-endY)*3
		local time = math.sqrt( xdis*xdis + ydis*ydis )/speed

		if callBack == nil then
			callBack = c_func(self.autoMoveBodyEnd,self)
		end

		self.moveBody:stopAllActions()

		self.moveBody:playLabel(Fight.actions.action_run)

		local dis = math.sqrt((startX-endX)*(startX-endX) + (startY-endY)*(startY-endY))
		
		if startX>endX then
			self.mapSpeed = -9
		else
			self.mapSpeed = 9
		end
		 
		--local sscale = self.moveBody:getScaleX()
		echo(" ======  endX",endX,"endY,",endY,"xiaY",xiaY)
		self.moveBody:runAction(cc.Sequence:create(
				act.spawn(
						act.moveto(time/GameVars.GAMEFRAMERATE , endX, endY),
						act.scaleto(time/GameVars.GAMEFRAMERATE ,math.abs(scale),scale)
					),
				act.callfunc(c_func(callBack))
			)) 



	end
end


--[[
放养角色移动完成
]]
function AnimDialogView:autoMoveBodyEnd()
	-- echoError("11111111111111111")
	self.moveBody:playLabel(Fight.actions.action_stand)
end
-- 获取放养角色的坐标
function AnimDialogView:autoMoveBodyPos()
	local posX = self.moveBody:getPositionX()
	local posY = self.moveBody:getPositionY()
	return posX,posY
end
--[[
设置打开的时机
]]
function AnimDialogView:setAnimDialogTime(time)
	self.dialogTime = time
end


--[[
执行退出
该属性标识是战斗还是剧情回顾
self.controler.onlyStory
]]
function AnimDialogView:doExitBack1(  )
	-- echoError("执行退出操作-----------")
	self.animStop = true
	
	-- 情缘系统退出剧情
	EventControler:dispatchEvent(NewLoveEvent.NEWLOVEEVENT_PLOT_EXIT)
	-- 移除弹幕事件
	EventControler:dispatchEvent(BarrageEvent.REMOVE_BARRAGE_UI)
	

	if self.cfgData.beginEnd and self.cfgData.beginEnd == 1 then
		WindowControler:setisNeedJumpToHome(true)
	end
    self.currentFrame = 0
    self:unscheduleUpdate()
	PlotDialogControl:setAfterOrderCallBack(GameVars.emptyFunc)
	self.controler:destoryDialog(true)

	if self.controler.onlyStory then
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SUREQUIT )
		EventControler:dispatchEvent(WorldEvent.WORLDEVENT_PLAY_BGMUSIC)
	else
		-- 如果是序章调用的剧情动画，没有BattleControler和BattleControler.gameControler
		if BattleControler and BattleControler.gameControler then
			BattleControler.gameControler:setIsPauseOut(true)
		end
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SUREQUIT_BEFORE_BATTLE_LOOP)
	end
	if self.plotControl then
		self.plotControl:destoryDialog(true)
	end
end
function AnimDialogView:doExitBack( )
	EventControler:dispatchEvent(BarrageEvent.REMOVE_BARRAGE_UI)
	self.animStop = true
	local awakenId = self.cfgData.awakenId
	-- 需要弹出一个奇侠唤醒的UI
	local awakenQiXiaFunc = function ( ... )
		if awakenId then
			local partnerId = FuncGuide.getAwakenPartner(awakenId)
			local isHavePart = PartnerModel:isHavedPatnner(partnerId)
			if not isHavePart then
				WindowControler:showTutoralWindow("AwakenView",awakenId,c_func(self.doExitBack1,self))
			else
				self:doExitBack1(  )
			end
		else
			self:doExitBack1(  )
		end
	end
	local isXuZhang = PrologueUtils:showPrologue()
	local hasBaoxiang = self.controler:hasUsedExtraBox()
	if isXuZhang and awakenId then
	-- if true then
		if self.controler then
			self.controler:doOpenExtraBox(awakenQiXiaFunc)
		else
			awakenQiXiaFunc()
		end
	elseif hasBaoxiang and self.boxBody and self.cfgData.awakenId then
		-- 判断是否有未领取宝箱
		if self.controler then
			self.controler:doOpenExtraBox(awakenQiXiaFunc)
		else
			awakenQiXiaFunc()
		end
	else
		self:doExitBack1(  )
	end
end
--[[
执行跳过
]]
function AnimDialogView:doJumpBack1(  )
	echo("-------6666666666666------------------------")
	-- 情缘系统跳过剧情 直接参加战斗
	EventControler:dispatchEvent(NewLoveEvent.NEWLOVEEVENT_PLOT_JUMP)
	-- 移除弹幕事件
	EventControler:dispatchEvent(BarrageEvent.REMOVE_BARRAGE_UI)
    self.currentFrame = 0
	self:unscheduleUpdate()
	PlotDialogControl:setAfterOrderCallBack(GameVars.emptyFunc)
	if TutorialManager.getInstance():isHomeExistGuide() 
	   and (self.cfgData.beginEnd and self.cfgData.beginEnd == 1) then
		if self.plotControl then
			self.plotControl:destoryDialog()
		end
		WindowControler:setisNeedJumpToHome(true)
		
		self.controler:destoryDialog(true)
		if self.controler.onlyStory then
			FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SUREQUIT )
		else
			BattleControler.gameControler:setIsPauseOut(true)
			FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SUREQUIT_BEFORE_BATTLE_LOOP)
		end
	else

		self.controler:destoryDialog()
	end
	if self.plotControl then
		self.plotControl:destoryDialog()
	end
end
-- 点击跳过判断是否有宝箱
function AnimDialogView:doJumpBack( )
	if tostring(self.cfgData.id) == "100000" then
		ClientActionControler:sendTutoralStepToWebCenter("story-yk-100-tg-1")
	elseif tostring(self.cfgData.id) == "100001" then
		ClientActionControler:sendTutoralStepToWebCenter("story-yk-100-tg-2")
	elseif tostring(self.cfgData.id) == "100002" then
		ClientActionControler:sendTutoralStepToWebCenter("story-yk-100-tg-3")
	elseif tostring(self.cfgData.id) == "100003" then
		ClientActionControler:sendTutoralStepToWebCenter("story-yk-100-tg-4")
	end

	EventControler:dispatchEvent(BarrageEvent.REMOVE_BARRAGE_UI)
	self.animStop = true
	local awakenId = self.cfgData.awakenId
	-- 需要弹出一个奇侠唤醒的UI
	local awakenQiXiaFunc = function ( ... )
		if awakenId then
			local partnerId = FuncGuide.getAwakenPartner(awakenId)
			local isHavePart = PartnerModel:isHavedPatnner(partnerId)
			if not isHavePart then
				WindowControler:showTutoralWindow("AwakenView",awakenId,c_func(self.doJumpBack1,self))
			else
				self:doJumpBack1(  )
			end
		else
			self:doJumpBack1(  )
		end
	end
	local isXuZhang = PrologueUtils:showPrologue()
	local hasBaoxiang = self.controler:hasUsedExtraBox()
	-- echoError(hasBaoxiang,"-------------",self.raidId,"---self.boxBody-",self.boxBody)
	if isXuZhang and awakenId then
	-- if true then
		if self.controler and not self.isGetXuzhangBox then
			self.controler:doOpenExtraBox(awakenQiXiaFunc)
		else
			if not self.isGetXuzhangBox then
				awakenQiXiaFunc()
			else
				self:doJumpBack1(  )
			end
			
		end
	elseif hasBaoxiang and self.boxBody and self.cfgData.awakenId then
		-- 判断是否有未领取宝箱
		if self.controler then
			self.controler:doOpenExtraBox(awakenQiXiaFunc)
		else
			awakenQiXiaFunc()
		end
	else
		self:doJumpBack1(  )
	end
end

--[[
初始化Spine
--地图的长度是0-4000
]] 
function AnimDialogView:initSpine( )
	self.mapOffsetX = 0 ---800 -- -330

	-- self.data = data
	-- self.allEvents = events
	local name  = self.cfgData["order"]

	self._root:pos(GameVars.gameResWidth /2 - self.widthScreenOffset/2,-GameVars.gameResHeight/2)
	self._scaleNode = display.newNode():addto(self._root)

	self.jintouNode = display.newNode():addto(self._scaleNode):pos(0,-GameVars.UIOffsetY)
	self.spine = ViewSpine.new(name,{},nil,name):addto(self.jintouNode):pos(0,0)
	self.spine:setTimelineType(1)
	self.mapBackNode = display.newNode():addto(self.jintouNode):pos(-GameVars.width/2,GameVars.gameResHeight/2)
	
	self.touchNode = display.newNode():addto(self.jintouNode,20):pos(0,0)
	self.handActionNode = display.newNode():addto(self.jintouNode,30):pos(0,0)
	--self.touchNode
	FuncRes.a_alpha(GameVars.width *8 , GameVars.height  *4 ):anchor(0.5,0.5):addto(self.touchNode)
	self.handToucSp = FuncRes.a_alpha(GameVars.width *8 , GameVars.height  *4 ):anchor(0.5,0.5):addto(self.handActionNode)
	--self.touchNode:setTouchEnabled(true)
	self.touchNode:setTouchedFunc(c_func(self.onTouchEvent,self),nil, false,nil,nil,false)
	self.handActionNode:setTouchEnabled(true)
	self.handActionNode:setTouchSwallowEnabled(false)
	self.handActionNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		local result = self:handActionTouch(event)
        return true
	end)
	
	--echo("新手引导判定是否FinishForceGuide()",TutorialManager.getInstance():isFinishForceGuide(),"=====")
	if  TutorialManager.getInstance():isFinishForceGuide() or true then
		--echoError("跳过按钮------要显示----")
		local view = self.btn_1
		local ox,oy = view:getPosition()
		local offSetX = -GameVars.gameResWidth / 2
		local offSetY = GameVars.gameResHeight / 2

		view:pos(ox + offSetX, oy + offSetY)
		FuncCommUI.setViewAlign(self.widthScreenOffset,view,UIAlignTypes.RightTop)
		view:setTouchedFunc(c_func(self.doExitBack,self))
		view:zorder(BTN_ZORDER)
		
		local view1 = self.btn_jump
		local ox,oy = view1:getPosition()

		view1:pos(ox + offSetX, oy + offSetY)
		FuncCommUI.setViewAlign(self.widthScreenOffset,view1,UIAlignTypes.RightTop)
		view1:setTouchedFunc(c_func(self.doJumpBack,self))
		view1:zorder(BTN_ZORDER)

        self.btn_jump = view1
        self.btn_exit = view
        
        self.btnPos.left = cc.p(self.btn_jump:getPosition())
        self.btnPos.right = cc.p(self.btn_exit:getPosition())

        self:showJumpAndExitBtn(false)
        
        -- 序章跳过出现时间置后
        local time = PrologueUtils:showPrologue() and 3 or 1
        self:delayCall(function (  )
        	self:showJumpAndExitBtn()
        end, time)
	end
	local node = display.newNode():addto(self.jintouNode):pos(0,0)
	self.mainNode = node
	self.mapFontNode = display.newNode():addto(self.jintouNode):pos(-GameVars.width/2,GameVars.gameResHeight/2)

	--偏移量
	self.minOffX = 0
	self.maxOffY = 1136*2-GameVars.width+GameVars.UIbgOffsetX --4000- GameVars.width+GameVars.UIbgOffsetX

	--将每个body放入到场景中
	for k,v in pairs(self.bodys) do
		--这里放一个很远的位置，只要在场景中看不到就可以了
		--v.spine:pos(0,0):addto(node)--:visible(false)
			local sp = nil
			local sId = v.sourceId
            local isChar = false

			if tostring(sId) == "1" then
			 	local avator = UserModel:avatar()
			 	local garmentId = ""
			 	if not PrologueUtils:isInPrologue() then
			 		garmentId = UserExtModel:garmentId()
			 	end
			 	
			 	--echoError("avator",avator,"garmentId",garmentId,"===================")
			 	sId = FuncGarment.getGarmentSource(garmentId, avator);
			 	local charData = CharModel:getCharData()
			 	sp = FuncGarment.getSpineViewByAvatarAndGarmentId(avator, garmentId,true,charData)
                isChar = true
			else
                if sId == "empty" then
                else
                	local sourceData = FuncTreasure.getSourceDataById(sId)
				    sp = FuncRes.getSpineViewBySourceId(sId,nil,true,sourceData )
                	sp:setTimelineType(1)
                end
			end

            local model = nil
			if sp then
				model = AnimModelBody.new(self.controler,sp,FuncAnimPlot.getSourceDataById(sId)):addto(node)
				v.spine = model
				model:setNameStr(k)
				self:insertOneObject(model)
                if isChar then
                    model:isCharBody(true)
                    model:addJiaoxiaGuanghuan( )
                end
            elseif sId == "empty" then
				model = AnimModelBasic.new(self.controler):addto(node)

				v.spine = model
				model:setNameStr(k)
				model:setViewType("bone")
				self:insertOneObject(model,"bone")
			end	

            --
	        model:visible(true)
            
	end

	--暂时点击宝箱就可以实现功能
	if self.boxBody then
		local boxName = self.boxBody.spineName
		-- local boxName =  "box_linghunrongqi" 
		local spine =  ViewSpine.new(boxName,{},nil,boxName)
		spine:setTimelineType(1)
		local model = AnimModelBox.new(self.controler,spine):addto(node)
		self.boxBody.spine  = model
		-- 宝箱初始先隐藏
		model:visible(false)
		--model:setNameStr()
		self:insertOneObject(model)
	end

    self:addblockModel(model,posx,posy)

	self.spine:playLabel("animation")
	self.animLabel = "animation"

	--这里保存一个主线的播放数据
	self.spineMainData = {}
	self.spineMainData.label = "animation"
	self.spineMainData.frame = 0
	self.spineMainData.totalFrame = self.spine:getTotalFrames(self.animLabel)

	self:startPlayMusic()

	self:clickMapInit()
	
	-- 处理mission详情
	self:updateMission()
	self:missionReward()

	self:addBarrageUI()

	self:updateBodysPos()

	EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_ONENTER_ANIMDIALOGVIEW, {controler = self.controler,cfg =self.cfgData })
end


-- 手势解锁监听
function AnimDialogView:handActionTouch(event)
	if not self.handAction then
		return 
	end
	local dis = 200
	local lockData = self.locks[self.animLabel][tostring(self.currentFrame)]
	local lockT = string.split(lockData.stringVal,",")
	local point = self.mainNode:convertToNodeSpace(cc.p(event.x,event.y))
	local handType = tonumber(lockT[2])
	
	local targetBody = lockT[5]
	local body = nil
	if self.bodys[tostring(targetBody)] then
		body = self.bodys[tostring(targetBody)].spine
	end
	local targetX = tonumber(lockT[3])
	local targetY = tonumber(lockT[4])
	if body then
		targetX = self.handBodyPos.x + targetX
		targetY = self.handBodyPos.y + targetY
	end

	local lockType = lockT[1]

	if event.name == "began" then
		-- 要在起始点周围
        self.beganPoint = {x = point.x,y = point.y}
        if math.abs(point.x-targetX) < 150 and 
        	math.abs(point.y-targetY) < 50 then
        	self.beginPointTouch = true
        else
        	self.beginPointTouch = false
        end
        return true
	elseif event.name == "moved" then
		if not self.beginPointTouch then
			return
		end
		if handType >= 5 then
			return
		end
		local endX = point.x
		local endY = point.y
		
		if handType == 1 then
		elseif handType == 2 then
			-- echo("endX == ,targetX ==",endX,targetX)
			if (endX - targetX) >= dis then
				-- echo("jies ======== ")
				self:chkUnLock(lockType,handType,targetX)
			end 
		elseif handType == 3 then
		elseif handType == 4 then
		end
		if body then
			if handType == 1 or handType == 2 then
				body:setPositionX(point.x)
			elseif handType == 3 or handType == 4 then
				body:setPositionY(point.y)
			end
		end

	elseif  event.name == "ended" then
		if not self.beginPointTouch then
			return
		end
		local endX = point.x
		local endY = point.y
		if handType < 5 then
			if body then
				echo("复位-------------",self.handBodyPos.x)
				body:setPositionX(self.handBodyPos.x) 
				body:setPositionY(self.handBodyPos.y)
			end
		elseif handType == 5 then
			-- 点击
			echo("endx == endy == ",endX,endY,targetX,targetY)
			if math.abs(endX - targetX) <= 150 then
				if math.abs(endY - targetY) <= 40 then
					-- echo("解锁----5--")
					if tostring(self.cfgData.id) == "100001" then
						ClientActionControler:sendTutoralStepToWebCenter("guide-yaokai-10000-ntgm")
					end
					self:chkUnLock(lockType,handType,targetX)
				end
			end
		end
	end
end

--点击地图移动
function AnimDialogView:clickMapInit()
	self._player = self.mapFontNode
    local moveTouchNode = FuncRes.a_alpha(GameVars.width *8 , GameVars.height  *4 )
    local rect = cc.rect(0, 0, 
        GameVars.width, GameVars.height - 100);


    local onPosChangeFunc = function ( moveX,moveY )
        -- echo("_________mapMove________",moveX)
        self.mapOffsetX = self.mapOffsetX + moveX
        if self.moveBody then
    		self.mapOffsetY = self.moveBody:getPositionY()
    	end
        self:followToTargetPos(self.mapOffsetX,self.mapOffsetY)
    end

    local touchFlag = false -- 标志是否完成整个点击流程

    local touchEndCallBack = function (event) 
    	if not (self.controler and self.controler:isCanScroll()) then
    		return
    	end
    	if not self.autoMove then
    		return
    	end 
        self._isMoveNow = false;
        self._isGoOnMove = false;

        local point = self.jintouNode:convertToNodeSpace(event)
        -- echo("__________2222222222______",point.x,point.y)

        -- echo("self._lastMoveSpeed ======",self._lastMoveSpeed)
        -- local disX = point.x - self._lastMoveEndPos.x
        EaseMapControler:startEaseMap(moveTouchNode,onPosChangeFunc,nil,self._lastMoveSpeed or 0,0)
        self._lastMoveSpeed = 0

        touchFlag = false
    end

    local touchBeginCallBack = function (event)
    	if not (self.controler and self.controler:isCanScroll()) then
    		return
    	end
    	if not self.autoMove then
    		return
    	end
        local touchPoint = self.jintouNode:convertToNodeSpace(event)
        -- echo("point.x__________",touchPoint.x)
		self.touchBeginPoint = touchPoint
        EaseMapControler:stopEaseMap()

        touchFlag = true

        return true;
    end

    local touchMoveCallBack = function (event) 
    	if not (self.controler and self.controler:isCanScroll()) then
    		return
    	end
    	if not self.autoMove then
    		return
    	end

    	if not touchFlag then
    		return
    	end
    	
        local point = self.jintouNode:convertToNodeSpace(event)
        local diffXBetweenMove = self.touchBeginPoint.x - point.x;
        -- echo("point.x__________",point.x)
        --滚大于30个像素才算滚
        if diffXBetweenMove > 20 or diffXBetweenMove < -20 then 
            diffXBetweenMove = self.touchBeginPoint.x - point.x;
            if diffXBetweenMove >= 100 then
                diffXBetweenMove = 45
            end
            if diffXBetweenMove <= -100 then
                diffXBetweenMove = -45
            end
            self.touchBeginPoint = {x = point.x, y = point.y};
            if diffXBetweenMove > 0 then
            	self._lastMoveSpeed = diffXBetweenMove
            else
            	self._lastMoveSpeed = diffXBetweenMove
            end
            
        else
        	self._lastMoveSpeed = 0
        end 
        self.touchBeginPoint = {x = point.x, y = point.y};
        self.mapOffsetX = self.mapOffsetX + diffXBetweenMove
    	-- echo("self.mapOffsetX ========",self.mapOffsetX,diffXBetweenMove)
    	if self.moveBody then
    		self.mapOffsetY = self.moveBody:getPositionY()
    	end
    	self:followToTargetPos(self.mapOffsetX,self.mapOffsetY)
    end
    local isPlayComClick2Music = function () 

    end

    
    moveTouchNode:opacity(0)
    moveTouchNode:anchor(0.5,0.5)
    moveTouchNode:addTo(self.jintouNode,100)
    moveTouchNode:setTouchedFunc(GameVars.emptyFunc, nil, false, 
        touchBeginCallBack, touchMoveCallBack,
         nil, touchEndCallBack)


    -- self._mapTutoriallistener = tutoriallistener;
end

--添加剧情弹幕的UI
function AnimDialogView:addBarrageUI()

	local arrPame = {
		system = FuncBarrage.SystemType.plot,  --系统参数
		btnPos = {x = 650 + GameVars.UIOffsetX ,y = -20 + GameVars.UIOffsetY},  --弹幕按钮的位置
		barrageCellPos = {x =  0 - GameVars.UIOffsetX,y = 60}, --弹幕区域的位置
		addview = self,--索要添加的视图
		plotData = FuncPlot.getAllPlotsByEvents(self.allEvents),
	}
	BarrageControler:showBarrageCommUI(arrPame)
end

function AnimDialogView:missionReward()
	if self.missionOpen then
		local index = MissionModel:getBattleReward()
		if index then
			MissionModel:setBattleReward(nil)
			echo("zhanshi jiangli UI  ----- ",index)
			WindowControler:showTutoralWindow("MissionRewardView", index,self.missionData.id)
		end
	end
end
function AnimDialogView:setBodysHide(isHide )
	self.bodysHide = isHide
end
-- 开始播放配置的背景音乐
function AnimDialogView:startPlayMusic()
	if self.cfgData and self.cfgData.bgm then
		echo("kaishi bofang  peizhi de bgm ")
		AudioModel:playMusic(self.cfgData.bgm, true)
	end
end

function AnimDialogView:showMissionInfo()

	if self.missionData then
		WindowControler:showWindow("MissionMiaoshuView",self.missionData)
	end
end
-- 添加聊天框
function AnimDialogView:addChatView()
	if self.missionOpen then
		if not self.chatmainview then
			self.chatmainview =  WindowControler:createWindowNode("ChatAddMainview")
		    self.chatmainview:setPosition(cc.p(-GameVars.width/2,-GameVars.height/2 + 130))
		    self._root:addChild(self.chatmainview)
		    self.chatmainview:zorder(10)
		    local node = FuncRes.a_white( 346,118)
		    self.chatNode = node
		    self._root:addChild(node)
		    node:zorder(12)
		    node:setPosition(cc.p(-GameVars.width/2 + 173,-GameVars.height/2 + 59 ))
		    node:opacity(0)
			node:setTouchedFunc(function ( ... )
				FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.CHAT)
			end,nil,true);
		end
	end
end
-- 刷新聊天是否隐藏
function AnimDialogView:updateChatPanel(  )
	if self.missionOpen then
		if self.chatmainview then
			self.chatmainview:visible(true)
		end
		if self.chatNode then
			self.chatNode:visible(true)
		end
	else
		if self.chatmainview then
			self.chatmainview:visible(false)
		end
		if self.chatNode then
			self.chatNode:visible(false)
		end
	end
end
-- 是否显示场景的名字或者 当前章节
function AnimDialogView:showMapName()
	self.panel_id:visible(true)
	self.panel_id.txt_2:visible(false)
	self.panel_id.txt_3:visible(false)
	self.panel_id:zorder(100)
	self.panel_id:pos(-GameVars.width/2 + GameVars.toolBarWidth, GameVars.height/2)
	if self.controler:getNameShow() and self.controler and self.controler.order then
		-- echoError("self.controler.order == ",self.controler.order)
		-- dump(self.controler.mapData,"333333333333",3)
		local _name = self.controler.mapData[tostring(self.controler.order)].name
		_name = GameConfig.getLanguage(_name)
		self.panel_id.txt_1:setString(_name)
	elseif self.controler.raidId then
		local raidId = self.controler.raidId
		local raidData = FuncChapter.getRaidDataByRaidId(raidId)
        local raidName = WorldModel:getRaidName(raidId)
        local chapter = FuncChapter.getChapterByStoryId(raidData.chapter)
        local section = FuncChapter.getSectionByRaidId(raidId)
        local str = ""
        if chapter > 0 then
        	str = chapter.."-"..section.." "..raidName
        else
        	str = "序章 "..raidName
        end 
		self.panel_id.txt_1:setString(str)
	else
		-- echo("_________隐藏地图进度")
		self.panel_id:visible(false)
	end
end
-- updateMissionDes
function AnimDialogView:updateMission(  )
	if self.missionOpen then
        -- self.mc_1xx:visible(true)
        self.mc_1xx:visible(false)
        self.mc_1xx:zorder(10)
        self.mc_1xx:pos(GameVars.width/2 - 230 , GameVars.height/4)
        local missionType = FuncMission.getMissionTypeById( self.missionData.id )
	    if tonumber(missionType) == FuncMission.MISSIONTYPE.QUEST then
            self.mc_1xx:showFrame(2)
            local panel_xxa = self.mc_1xx.currentView.panel_jifen
            local missionData = self.missionData

            local score = MissionModel:getMissionJindu(self.missionData.id,self.missionData.startTime)
            local dataCfg = FuncMission.getMissionDataById( missionData.id )
			local total = dataCfg.goalParam

			local _str1 = string.format(GameConfig.getLanguage("#tid_mission_009"),tostring(score),tostring(total))
            panel_xxa.txt_2:setString(_str1)

            local allAnswerNum = MissionModel:getMissionQuestNum(self.missionData.startTime)
            local rightNum = MissionModel:getMissionQuestRightNum(self.missionData.startTime)
            local _str2 = string.format(GameConfig.getLanguage("#tid_mission_010"),tostring(rightNum),tostring(allAnswerNum - rightNum))
            panel_xxa.txt_3:setString(_str2)

            local missionState,leftTime = MissionModel:getMissionState(self.missionData)
            if leftTime <= 0 then
            	WindowControler:showTips(GameConfig.getLanguage("#tid_mission_011"))
            	self:doExitBack1()
            end

	    else
            self.mc_1xx:showFrame(1)
            local panel_xxa = self.mc_1xx.currentView.panel_xxa
		    self.panel_id:visible(true)
		    self.panel_id:zorder(10)
		    self.panel_id:pos(-GameVars.width/2 , GameVars.height/2)

		    local missionId = self.missionData.id
		    local finishTime = self.missionData.finishTime
		    -- 任务地点
		    self.panel_id.txt_1:setString(FuncMission.getMissionSpaceName(missionId))
		    -- 剩余时间
            local serverTime = TimeControler:getServerTime()
		    local data = os.date("*t", serverTime)
		    -- 今天的秒数
		    local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
		    local leftTime = finishTime - currentMiao
            if leftTime < 0 then
                self.missionOpen = false
            end   

		    self.panel_id.txt_2:setString(GameConfig.getLanguage("#tid_mission_012")..fmtSecToHHMMSS(leftTime))
		    -- 当前积分
		    self.panel_id.txt_3:setString(GameConfig.getLanguage("#tid_mission_013")..self.missionScore)

            -- 任务名称
            panel_xxa.txt_1:setString(FuncMission.getMissionName(missionId))
            -- 任务进度
            -- echo("yishi id === ",missionId)
            local jindu = MissionModel:getMissionJindu(missionId,self.missionData.startTime)
            panel_xxa.txt_2:setString(FuncMission.getMissionGoal(missionId,jindu))        
	    end
	else
		self.mc_1xx:visible(false)
		self:showMapName()
		if not self.missionOverDis then
			self.missionOverDis = true
			EventControler:dispatchEvent(MissionEvent.MISSIONUI_OVER) 
		end
		
	end
end

-- add答题UI
function AnimDialogView:addMissionQuestUI( )
	self.missionQuestUI = WindowControler:createWindowNode("MissionQuestView")
	self.mainNode:addChild(self.missionQuestUI)
	-- 写死位置 1400,以前(-GameVars.width/5*5)有偏移
	self.missionQuestUI:pos(-1400,GameVars.height/2)
	self.missionQuestUI:setParent( self )
	self.missionQuestUI:initData()
	self.missionQuestUI:updateUI()
	self.datiPos = self.missionQuestUI:initQuyu(  )
end

--[[
    关闭六界轶事问答
]]
function AnimDialogView:closeMissionQuestUI()
	if self.missionQuestUI then
		self.missionQuestUI:deleteMe()
	end
end

--[[
spine开始播放
]]
function AnimDialogView:startUpdate(  )
	
	self:initSpine()
	self:setScene()
	self:initSceneBlack()

	--self:showBlackImage()

	--当前帧位置
	self.currentFrame = 0
	self.totalFrame = self.spine:getTotalFrames("animation")

	-- 预加载 音效
	self.soundIndex = 0
	self.soundPreloadFinish = false
	self.handle = self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self), 0)
end
function AnimDialogView:proloadSound()
	-- 每帧加载4个音效
	if self.soundIndex > table.length(self.allsound) then
		self.soundPreloadFinish = true
	else
		self.soundIndex = self.soundIndex + 1
		AudioModel:preloadSound(self.allsound[self.allsound])
	end
end
function AnimDialogView:initBodysPos(  )
	for k,v in pairs(self.bodys) do
		local body = v.spine
		if body ~= self.moveBody and v.sourceId ~= "nil" then
			local x = self.spine:getBoneTransformValue(k, "x")
			local y = self.spine:getBoneTransformValue(k, "y")
			local sx = self.spine:getBoneTransformValue(k, "sx")
			local sy = self.spine:getBoneTransformValue(k, "sy")

			local viewSx = 1
			if sx<0 then
				viewSx = -1
			end
			--echo("viewSx",viewSx,"=================")
			if v.sourceId ~= "empty" then
				body.view:setScaleX(viewSx)
				body.view:setScaleY(1)
			end
			
			--这里还有 其他属性，比如 r 等几种
			body:setPositionX(x)
			body:setPositionY(y)

			local xiaY = -240

			local  scale = 0.9+0.1*(1-(y-xiaY )/280)
			body:setScaleX(math.abs(sx)*scale)
			body:setScaleY(sy*scale)

		end
	end
end

--[[
spine播放完成
]]
function AnimDialogView:endUpdate(  )
	-- body
end

--[[
每帧的刷新事件
这里先不考虑 加速的问题


self.isSceneBlack = true
			self.sceneBlackCnt = frameCnt


]]
function AnimDialogView:updateFrame(dt)
	-- 如果此时是加载音效
	-- self:proloadSound()
	-- if not self.soundPreloadFinish then
	-- 	return
	-- end

	--这是动画结束的条件  如果执行跳转就不能这么判断了。要遇到
	if self.stopUpdate then
		echo("直接返回不再更新了------")
		return
	end


	if self.animLabel ~= self.spineMainData.label then
		if self.currentFrame>self.totalFrame then
			self.currentFrame = 0
		end
	end
	
	-- echoError("self.currentFrame",self.currentFrame,"===============")
	
	if (self.animLabel == self.spineMainData.label and  self.currentFrame>self.totalFrame) 
		or self:chkAnimed() 
	then
		--echo("动画结束---------------ViewSpin--- ------- return",self.handle)
		self.currentFrame = 0
		self:unscheduleUpdate()

		PlotDialogControl:setAfterOrderCallBack(GameVars.emptyFunc)

		self.controler:destoryDialog()
		-- 移除弹幕界面的事件
		EventControler:dispatchEvent(BarrageEvent.REMOVE_BARRAGE_UI)
		return 
	end
	--这里其实用gotoAndStop更合适，但是gotoAndStop有bug 因为每帧都更新，结果都是一样的
	--self.spine:gotoAndStop(self.currentFrame)
	-- echo(self.currentFrame,"=============")
	self:playSceneSpine(self.currentFrame)
	
	--echo("self.currentFrame,",self.currentFrame,"=============")
	if ( not self.isSceneBlack or true ) and  -- 黑屏不卡时间轴
		(not self:hasLock()) and
		(not self.autoMove) and 
		(not self:chkLock()) and
		(not self:chkSystemLock()) and
		(not self.animStop) and 
		(not self.isPicting)  -- 插画特效
	then
		--没有黑屏且没有被上锁
		self:updateBodyAction(dt)
		self:updateBox(dt)
		self:updateChat()
		self:updateEmoi()
		self:updateSound()
		self:updateChangeEffect()
        self:updateShake()
        self:shakeScene()
		self:updateEffect1(dt)
		self:updatePlot(dt)
		self:updateSceneBlack(dt)
		self:updateInsertPictures()
		self:updateHideBtn( )
		self.currentFrame = self.currentFrame +1

        self.effectGo = true
    else
        self.effectGo = false
	end
	
	--这里先去掉
	if self.autoMove  then
		if self.currentFrame > 0 then
			self:updateBodyAction(dt)
		end
		
		self:updateBox(dt)
		self:updateChat(dt)

		self:updateFaZhenEffect()

		self:updateLockPosition()

		if self.continueFrame then
			self.currentFrame = self.currentFrame +1
		end
	end
	for k,v in pairs(self.allModels) do
		v:updateFrame(self.currentFrame)
	end


 --    for k,v in pairs(self.allEffectModels) do
	-- 	v:updateFrame()
	-- end

	if self.isSceneBlack then
		self.sceneBlackCnt = self.sceneBlackCnt-1
		if self.sceneBlackCnt ==0 then
			self.isSceneBlack = false
			self:hideBlackImage()
		end
	end
	--echo("sortDepth()---")
	self:sortDepth()

	self:updateCamer()

	self:updateScreen()
	--self:chkUpdateScreen()
	self:effectTimeSwitch(self.effectGo)

	self:hideBoneDisplay()

    -- 处理mission详情
	self:updateMission(  )
	self:updateChatPanel(  )

end


function AnimDialogView:playSceneSpine( frame )
	local curFrame = self.spine:getCurrentFrame()
	-- if curFrame <= frame or frame  <= 1 then
		self.spine:gotoAndStop(frame)
	-- end
end


--[[
ggg
]]
function AnimDialogView:chkUpdateScreen()
	if self.autoMove then
		--只有散养的时候移动镜头
		--人物的坐标位置
	-- 	local x = self.moveBody:getPositionX()
	-- 	local y = self.moveBody:getPositionY()
	-- 	local wpos = self.mainNode:convertToWorldSpace(cc.p(x,y))
	-- 	-- local spos = self:convertToNodeSpace(wpos)
	-- 	-- local sx,sy= spos.x,spos.y
	-- 	local sx,sy = wpos.x,wpos.y
	-- 	--echo(sx,sy,"=======",GameVars.gameResWidth )
	-- 	if sx <150 or sx>GameVars.width-150 then
	-- 		--需要坐标移动
	-- 		echo("需要移动----------")


	-- 	else
	-- 		echo("不需要移动-=-------")
	-- 	end

	-- else
	-- 	--固定镜头到原始位置
	-- 	--todo

	end
end

--[[
更新屏幕位置   更新地图位置
]]
function AnimDialogView:updateScreen(  )
	if self.autoMove then

		--autoMoveBody


		local x = self.moveBody:getPositionX()
		local y = self.moveBody:getPositionY()
		self.mapOffsetY = y

		if self.moveBody.label == Fight.actions.action_run then
			if self.mapSpeed > 0 and x > self.mapOffsetX then
				self.mapOffsetX = self.mapOffsetX + self.mapSpeed
				self:followToTargetPos(self.mapOffsetX,self.mapOffsetY)
			elseif self.mapSpeed < 0 and x < self.mapOffsetX then
				self.mapOffsetX = self.mapOffsetX + self.mapSpeed
				self:followToTargetPos(self.mapOffsetX,self.mapOffsetY)
			end
			EaseMapControler:stopEaseMap()
		end
		-- self:followToTargetPos(self.mapOffsetX,y)

	end
end

--[[
检测touch点是否在 block区域内 
判断 直线是否 穿过圆， 并返回 end点
]]
function AnimDialogView:checkInBlock( startX,startY,endX ,endY )
    
    if true then
    	-- 障碍物 逻辑 暂时不添加
    	return
    end
    --首先判断star和end 是否是在圆心的同一边
    local isTB = true
    if self.blockX >= startX and self.blockX >= endX then
    elseif self.blockX <= startX and self.blockX <= endX then
    else
        isTB = false
        echo("==============butongce===========")
    end
    if isTB then
        local xdis = math.abs(endX- self.blockX)
	    local ydis = math.abs(endY- self.blockY)
	    local dis = math.sqrt( xdis*xdis + ydis*ydis )
	    if dis > self.blockR then
		    echo("===================不在 block区域内")
	    else
		    echo("++++++++++++++++====在 block区域内")
		    local aa = Tool:GetLineAndCirclePoint(self.blockX,self.blockY,self.blockR,
	    	startX,startY,endX ,endY)
		    echo("endx ===== ",endX)
		    echo("endY ===== ",endY)
		    dump(aa, "-------+++++++++-----------", 4)
		    local event = nil
		    if aa then
		        event = {}
		        event.x = aa.x
		        event.y = aa.y
		       	return event
		    end
	    end
    else
    	local aa = Tool:GetLineAndCirclePoint(self.blockX,self.blockY,self.blockR,
    	startX,startY,endX ,endY)
	    echo("endx ===== ",endX)
	    echo("endY ===== ",endY)
	    dump(aa, "-------+++++++++-----------", 4)
	    local event = nil
	    if aa then
	        event = {}
	        event.x = aa.x
	        event.y = aa.y
	       	return event
	    end
    end
	
end


--[[
在动画中增加一个Node对象
]]
function AnimDialogView:addNewAnimModel(model,posx,posy)
	--echoError("在对象中增加一个新的对象")
	if  model then
		self.blockR = 150
		posx = posx or 0
		posy = posy or 0
		model:addto(self.mainNode):pos(posx,posy)
		self:insertOneObject(model)
        -- if (self.bodysHide or self.missionOpen) and model.viewType == "bone" then
        --     model:visible(false)
		if model.viewType == "missionBone" then
            model:visible(true)
        end
	end
end

--[[
在动画中 插入block对象
]]
function AnimDialogView:addblockModel(model,posx,posy)
	if true then
		return
	end
	self.blockX = -315
    self.blockY = -33
	local nod = FuncRes.a_white( 200,200)
    nod:anchor(0.5,0.5)
	nod:pos(-315,-33)
	self.mainNode:addChild(nod,10)
	nod:opacity(180)
end



--[[
插入一个model模型
插入一个模型对象
]]
function AnimDialogView:insertOneObject(target,viewType)
	if table.indexof(self.allModels, target) == false then
		table.insert(self.allModels, target)
	end

	if target:getViewType() == "bone" then
		if table.indexof(self.allBoneModels,target) == false then
			table.insert(self.allBoneModels, target)
		end
	end
    if target:getViewType() == "missionBone" then
		if table.indexof(self.allMissionModels,target) == false then
			table.insert(self.allMissionModels, target)
		end
	end
    

    if target:getViewType() == "effect" then
        if table.indexof(self.allEffectModels,target) == false then
			table.insert(self.allEffectModels, target)
		end
    end
	--法阵特效-----
	if target:getViewType() == "effectFaZhen" then
		if table.indexof(self.allFaZhenModels,target) == false then
			table.insert(self.allFaZhenModels,target)
		end
	end
end
-- 删除一个model
function AnimDialogView:deleteModel( model )
	for i = #self.allModels , 1 do
		if self.allModels[i] == model then
			table.remove(self.allModels,i)
			model = nil
		end
	end
	for i = #self.allMissionModels , 1 do
		if self.allMissionModels[i] == model then
			table.remove(self.allMissionModels,i)
			model = nil
		end
	end
end

--[[
任务执行深度排序
]]
function AnimDialogView:sortDepth()
	if self.sortFrame == nil then
		self.sortFrame = 0
	end
    if self.sortFrame<5 then
    	self.sortFrame = self.sortFrame+1
        return
    end
    --self.sortFrame = self.sortFrame +1

    if self.sortFrame==5 then
    	self.sortFrame = 0
    end

	local arr =self.allBoneModels
    local arr = {}
    for i,v in pairs(self.allBoneModels) do
        table.insert(arr,v)
    end
    for i,v in pairs(self.allMissionModels) do
        table.insert(arr,v)
    end
    
	--dump(arr)

    table.sort( arr, function(a,b)
        local asx = 1
        local bsx = 1
        if a.view and b.view then
	        asx = a.view:getScaleX()
            bsx = b.view:getScaleX()
        end

        local ax = a:getPositionX()*asx
        local ay = a:getPositionY()
        local bx = b:getPositionX()*bsx
        local by = b:getPositionY()

        if by>ay then
	        return false
        elseif by<ay then
	        return true
        elseif by == ay then
	        if bx>ax then
	 	        return false
	        elseif bx<ax then
	 	        return true
	        else
	 	        return false
	        end
        end
        end )
	    --echo("============================================")
	    for i = 1,#arr,1 do
		    arr[i]:setAnimOrder( i*10)
		    arr[i]:zorder(i*10)
		    --echo(arr[i]:getNameStr(),arr[i]:getAnimOrder(),arr[i]:getScaleX(),arr[i]:getPositionX(),arr[i]:getPositionY())
	    end
	--echo("============================================")

	


	for k,v in pairs(self.allModels) do
		if v:getViewType() == "effect" then
			local bone =  self:getAnimBone(v:getparentStr())
			local order = bone:getAnimOrder()
			local effOrder = tonumber(v:getAnimOrder())
			if effOrder == -2 or effOrder == 2 then
				order = bone:getAnimOrder()*effOrder*10
				--v:zorder(bone:getAnimOrder()*order*10)
			end
			if effOrder == 1 or effOrder == -1 or effOrder == 0 then
				order = bone:getAnimOrder()*effOrder
				--v:zorder(bone:getAnimOrder()+order)
			end
			v:zorder(order)
			--echo(order,v:getparentStr(),"=======")
		end
	end


end

-- 循环特效计时
function AnimDialogView:effectTimeSwitch(isOpen)
    for k,v in pairs(self.allEffectModels) do
	    v:setTimeSwitch(self.effectGo)
	end
end

--[[
获取对应的Bone
]]
function AnimDialogView:getAnimBone (name)
	for k,v in pairs(self.allBoneModels) do
		if v:getNameStr() == name then
			return v
		end
	end
end



--[[
更新body
]]
function AnimDialogView:updateBodyAction( dt )

	local actionCallBack = function (body,label)
		--echo("播放完成======")
		--body:playLabel("stand")
	end

	--执行动作
	if not empty(self.events) then
		for k,v in pairs(self.bodys) do
			local body = v.spine
			--echo("self.animLabel",self.animLabel,"============")
			if self.events[self.animLabel].actions and self.events[self.animLabel].actions[k] then
				local evt = self.events[self.animLabel].actions[k][tostring(self.currentFrame)]
				if evt ~= nil then
                    echo("---------evt.intVal -----",evt.intVal,evt.actionLabel,self.currentFrame)
					body:playLabel(evt.actionLabel,evt.intVal)
				end
			end
		end
	end

	self:updateBodysPos()
	
end

--更新body位置
function AnimDialogView:updateBodysPos(  )
	if self.handAction then
		return
	end
	--更新位移
	for k,v in pairs(self.bodys) do
		--echo("----------",k)
		local body = v.spine
		if body ~= self.moveBody and v.sourceId ~= "nil" then
			local x = self.spine:getBoneTransformValue(k, "x")
			local y = self.spine:getBoneTransformValue(k, "y")
			local sx = self.spine:getBoneTransformValue(k, "sx")
			local sy = self.spine:getBoneTransformValue(k, "sy")

			local viewSx = 1
			if sx<0 then
				viewSx = -1
			end
			--echo("viewSx",viewSx,"=================")
			if v.sourceId ~= "empty" then
				body.view:setScaleX(viewSx)
				body.view:setScaleY(1)
			end
			
			
			-- if k == "body1" and self.currentFrame == 10 then
			-- 	echo("sx  sy",sx,sy,"x,y",x,y,"=====================")
			-- end
			--local  = 1
			--这里还有 其他属性，比如 r 等几种
			body:setPositionX(x)
			body:setPositionY(y)
			-- body.view:setScaleX(sx)
			-- body.view:setScaleY(sy)

			local xiaY = -240

			local  scale = 0.9+0.1*(1-(y-xiaY )/280)
			--echo("scale---",scale,"=======",sx,sy,sx*scale,sy*scale)
			--body.view:setScaleX(sx*scale)
			--body.view:setScaleY(sy*scale)
			-- body:setScaleX(sx*scale)
			-- body:setScaleY(sy*scale)

			body:setScaleX(math.abs(sx)*scale)
			body:setScaleY(sy*scale)
		end
	end
end

--[[

更新宝箱
]]
function AnimDialogView:updateBox( dt )
	if self.boxBody then
		local box = self.boxBody.spine
		local x = self.spine:getBoneTransformValue("box", "x")
		local y = self.spine:getBoneTransformValue("box", "y")
		local sx = self.spine:getBoneTransformValue("box", "sx")
		local sy = self.spine:getBoneTransformValue("box", "sy")

		local viewSx = 1
		if sx<0 then
			viewSx = -1
		end
		box.view:setScaleX(viewSx)
		box.view:setScaleY(1)
		box:setPositionX(x)
		box:setPositionY(y)
		local xiaY = -240
		local  scale = 0.9+0.1*(1-(y-xiaY )/280)
		box:setScaleX(math.abs(sx)*scale)
		box:setScaleY(sy*scale)

		--执行宝箱 默认动画
		-- 判断是否奖励已领取
		box:playDefaultLabel()

		--注册事件  chkLock的时候注册事件 todo dev


	end
end




--[[
更新effect1
effect的资源释放怎么处理
self.events[animLabel]
]]
function AnimDialogView:updateEffect1(dt)
	--更新effect1
	--echo("updateEffect1-------------",self.currentFrame,"==============")
	--dump(self.events)
	if not empty(self.events) and not empty(self.events[self.animLabel]) then
		if self.events[self.animLabel].effect1 then

			for body,effects in pairs(self.events[self.animLabel].effect1) do
				local  effs = effects[tostring(self.currentFrame)]
				if effs  then
					for _,v in pairs(effs.effects)  do
                        if v.effectName == "" then -- 此时要隐藏循环特效
                        	if self.bodyEffect[v.binder] then
                        		self.bodyEffect[v.binder]:visible(false)
                            	self.bodyEffect[v.binder] = nil
                        	end
                           	break
                        end
						local order = v.zorder
						local name = FuncArmature.getSpineName(v.effectName)

						if name == nil then
							echoError(v.effectName,"空不存在这样的资源")
							return
						end
						local binder = v.binder
						-- echoError("name  name   ",name,"==================",self.currentFrame,"----------------",v.effectName)
						local effSpine = ViewSpine.new(name,{},nil,nil)
						effSpine:setTimelineType(1)
						--echo("创建特效---------")
						local model =  AnimModelEffect.new(self.controler,effSpine):addto(self.mainNode)
                        if self.bodys[tostring(body)] and self.bodys[tostring(body)].spine and
                        	self.bodys[tostring(body)].spine.view then
                            local scaleX = self.bodys[tostring(body)].spine.view:getScaleX()
						    local scaleY = self.bodys[tostring(body)].spine.view:getScaleY()
						    --特效需要翻转 todo dev
						    --echo("scaleX",scaleX,"==============")
						    model:setScaleX(scaleX)
						    model:setScaleY(scaleY)
                        else
                        	local sx = self.spine:getBoneTransformValue(tostring(body), "sx")
							local sy = self.spine:getBoneTransformValue(tostring(body), "sy")
                            model:setScaleX(sx)
						    model:setScaleY(sy)
                        end
                        -- echo("eff self.currentFrame === ",self.currentFrame)
						model:setParentStr(binder)
						model:setAnimOrder(order)
						model:updateFrame(self.currentFrame)
						model:playLabel(v.effectName,v.circle,v.totalFrame)  
						self:insertOneObject(model)
                        self.bodyEffect[v.binder] = model
					end

				end
				
			end
		end
	end

 
	 --更新特效的位置
		for k,v in pairs(self.allModels) do
			if v:getViewType() == "effect" then
				local bone =  self:getAnimBone(v:getparentStr())
				if bone then
				    local x = bone:getPositionX()
				    local y = bone:getPositionY()
				    v:setPositionX(x)
				    v:setPositionY(y)
				end
			end
		end


end

--[[
更新chat事件


--body头上出现相应的图标
		self.events.chat[tostring(v.frame)].body = params[1]
		--图标的类型
		self.events.chat[tostring(v.frame)].type = params[2]
		--图标的偏移x
		self.events.chat[tostring(v.frame)].offfX = params[3]
		--图标的偏移y
		self.events.chat[tostring(v.frame)].offY = params[4]


]]
function AnimDialogView:updateChat()
	--dump(self.events[self.animLabel].chat)
	--echo(self.animLabel,self.currentFrame)
	if self.currentFrame == 60 and self.animLabel == "circle" then
		--dump(self.events[self.animLabel].chat[tostring(self.currentFrame)])
		
	end
	if self.events then
		-- echo(self.currentFrame,self.animLabel,"-------------\n\n")
		if self.events[self.animLabel].chat and self.events[self.animLabel].chat[tostring(self.currentFrame)] then
			local data = self.events[self.animLabel].chat[tostring(self.currentFrame)]
			if self.bodys[tostring(data.body)] == nil then
				return
			end
			local body = self.bodys[tostring(data.body)].spine
			
			--body:setChatIcon(data.type,toint(data.offX),toint(data.offY),c_func(self.doChatClick,self,body))

			local params1 = self.events[self.animLabel].chat[tostring(self.currentFrame)].dialog1
			local params2 = self.events[self.animLabel].chat[tostring(self.currentFrame)].dialog2
			local params3 = self.events[self.animLabel].chat[tostring(self.currentFrame)].dialog3

			body:setChatDialog(params1,params2,params3)
            self.hideIconData["chat"] = nil;   
			--IS_SHOW_CLICK_EFFECT = false
			--self.touchNode:setTouchEnabled(true)

		end
	end
	if self.currentFrame == 60 and self.animLabel == "circle" then
		--echoError("===========================")
	end
end


function AnimDialogView:updateEmoi(  )
	-- echo("更新表情")
	-- dump(self.events[self.animLabel].emoi[tostring(self.currentFrame)])
	-- echo(self.events[self.animLabel] ~= nil , self.events[self.animLabel].emoi ~= nil and  self.events[self.animLabel].emoi[tostring(self.currentFrame)] ~= nil)
	if self.events then
		if self.events[self.animLabel] 
			and self.events[self.animLabel].emoi 
			and self.events[self.animLabel].emoi[tostring(self.currentFrame)] 
		then
			local body = self.events[self.animLabel].emoi[tostring(self.currentFrame)].body
			local _type = self.events[self.animLabel].emoi[tostring(self.currentFrame)].type
			if self.bodys[tostring(body)] then
				local bodyModel = self.bodys[tostring(body)].spine
			 	bodyModel:setEmoi(_type) 
			else
				echo(self.currentFrame,"___________self.currentFrame")
				echoError("剧情"..self.cfgData.id.."中"..body.."没有")
			end
		end
	end
end

function AnimDialogView:updateSound(  )
	if self.events then
		if self.events[self.animLabel] 
			and self.events[self.animLabel].sound
			and self.events[self.animLabel].sound[tostring(self.currentFrame)] 
		then
			local soundName = self.events[self.animLabel].sound[tostring(self.currentFrame)].soundName
			echo("soundName ==== ",soundName)
			local _type = self.events[self.animLabel].sound[tostring(self.currentFrame)].type
		 	if tonumber(_type) == 1 then
		 		AudioModel:playMusic(soundName, true)
		 	else
		 		if self.currentSoundId then
		 			AudioModel:stopSound(self.currentSound)
		 		end
		 		self.currentSoundId = AudioModel:playSound(soundName, false)
		 	end
		end
	end
end

--[[
转场特效实现
]]
function AnimDialogView:updateChangeEffect(  )
	local changeMapFunc = function ( ... )
		
 		self:delayCall(function ( ... )
 			self.map:setMapId(self.changeMapId)
    		self.map:updatePos(self.mapOffsetX,0)
    		
    		self.changemapType = nil
    		self.changeMapId = nil
    		if self.effectSp then 
    			self.effectSp:removeFromParent()
    			self.effectSp = nil
    		end
 		end,0.1)
	end

	if self.events then
		if self.events[self.animLabel] 
			and self.events[self.animLabel].change
			and self.events[self.animLabel].change[tostring(self.currentFrame)] 
		then
			local changeData = self.events[self.animLabel].change[tostring(self.currentFrame)]
			local changeType = changeData.changeType
			local changeMap = changeData.changeMap
			local changeTime = changeData.changeTime
			local effectType = changeData.effectType
			local effectFlashName = changeData.effectFlashName
			self.effectSpRemoveTime = tonumber(changeTime) + self.currentFrame
			self.changMapTime = tonumber(changeTime)/2 + self.currentFrame
			self.changemapType = changeType
			self.changemapEffectType = tonumber(effectType) or 1
			self.effectFlashName = effectFlashName
			self.changeMapId = changeMap
		 	if self.effectSp then
		 		self.effectSp:removeFromParent()
		 	end
		 	
		    
			if self.changemapEffectType == 1 then
				-- echoError("____________滤镜效果_____________")
				local effectSp = FilterTools.setWaterWave({node = self._root,w = GameVars.width,h = GameVars.height,offX = 0,offY = 0},{type = 2,pos = cc.p(0.5,0.5)})
			    effectSp:pos(0,0):anchor(0.5,0.5)
			    effectSp:addto(self._root)
			    self.effectSp = effectSp
			elseif self.changemapEffectType == 2 then
				echo("____________过场动画_________________",self.currentFrame)
				local animName = "UI_zhuanchangyun"
				self:useChangeEff(self.changemapEffectType, animName, changeMapFunc)
			elseif self.changemapEffectType == 3 then
				local animName = self.effectFlashName
				self:useChangeEff(self.changemapEffectType, animName, changeMapFunc)
			end
		end
		if self.changMapTime == self.currentFrame then
			if tonumber(self.changemapType) == 1 and self.changemapEffectType == 1 then
				-- 需要替换地图
				changeMapFunc()
		 		self:delayCall(function ( ... )
			 		if self.effectSpRemoveTime and self.effectSpRemoveTime > self.changMapTime then 
			 			local effectSp = FilterTools.setWaterWave({node = self._root,w = GameVars.width,h = GameVars.height,offX = 0,offY = 0},{type = 2,pos = cc.p(0.5,0.5)})
					    effectSp:pos(0,0):anchor(0.5,0.5)
					    effectSp:addto(self._root)
					    self.effectSp = effectSp

					    self:updateSceneScale()
			 		end
		 		end,0.15)
			end
		end
		if self.effectSpRemoveTime == self.currentFrame then
			if self.effectSp then
		 		self.effectSp:removeFromParent()
		 		self.effectSp = nil
		 		self.effectSpRemoveTime = nil
		 	end
		end
	end
end

-- 使用转场效果
function AnimDialogView:useChangeEff(changemapEffectType, animName, callBack)
	local animName = animName or "UI_zhuanchangyun"
	local changeAnim = self._changeAnim[changemapEffectType .. animName]
	if not changeAnim then
		changeAnim = self:createUIArmature(animName,animName, nil, false, GameVars.emptyFunc)
		self._changeAnim[changemapEffectType .. animName] = changeAnim					
		-- echoError("没有转场特效 name == ",animName)
		changeAnim:addto(self._root,1000)
	end
	changeAnim:visible(true)
	changeAnim:doByLastFrame(false,false,function()changeAnim:visible(false) end)
	changeAnim:pos(-GameVars.width/2-116,GameVars.height/2+63 )
	changeAnim:gotoAndPlay(0)
	self:delayCall(function (  )
		if callBack then callBack() end
	end,1.0)
end

function AnimDialogView:updateInsertPictures()
	if self.events then
		if self.events[self.animLabel] 
			and self.events[self.animLabel].insertPictures
			and self.events[self.animLabel].insertPictures[tostring(self.currentFrame)] 
		then
			echo("____________插入特效_________________",self.currentFrame)
			local effectName = "eff_10506_loveintower"
			local labelName = "eff_10506_loveintower"
			local effectSpin = ViewSpine.new(effectName,{},nil,nil)
			effectSpin:playLabel(labelName,false,true)
			self._root:addChild(effectSpin,1000)
			self.isPicting = true

			local allFrames = effectSpin:getLabelFrames(labelName )
			self:delayCall(function (  )
				self.isPicting = false
			end,allFrames/GameVars.GAMEFRAMERATE)

		end
		
	end
end

function AnimDialogView:updateHideBtn( )
	if self.events then
		if self.events[self.animLabel] 
			and self.events[self.animLabel].hideBtn
			and self.events[self.animLabel].hideBtn[tostring(self.currentFrame)] 
		then
			self.hideBtnEvent = true
			local hideTime = self.events[self.animLabel].hideBtn[tostring(self.currentFrame)].stringVal
			if hideTime and hideTime ~= "" then
				self.hideBtnOverTime = self.currentFrame + tonumber(hideTime)
			else
				self.hideBtnOverTime = self.spine:getTotalFrames(self.animLabel)
			end
			self:showJumpAndExitBtn()
		end
	end

	if self.hideBtnOverTime and self.currentFrame > self.hideBtnOverTime then
		self.hideBtnEvent = nil
		if (self:showJumpAndExitBtn()) == self.hideBtnOverTime then
			self:showJumpAndExitBtn()
		end
	end
end


function AnimDialogView:updateShake()
	if self.events then
		if self.events[self.animLabel] 
			and self.events[self.animLabel].shake
			and self.events[self.animLabel].shake[tostring(self.currentFrame)] 
		then
			local frameCnt = self.events[self.animLabel].shake[tostring(self.currentFrame)].frameCnt

		    self.shakeInfo = {
		        frame = frameCnt,
		        shakeType = "xy",
		        range = { 2, 2 }
		    }
		    
			self.oldPos = { self.jintouNode:getPosition() }
		end
	end
end
-- 执行震屏
function AnimDialogView:shakeScene()
    if not self.shakeInfo then
        return
    end
    local shakeLayer = self.jintouNode
    self.shakeInfo.frame = self.shakeInfo.frame - 1

    local oldXpos = self.oldPos[1] or 0
    local oldYpos = self.oldPos[2] or 0
    local pianyi =(self.shakeInfo.frame % 2 * 2 - 1)

    shakeLayer:pos(oldXpos + pianyi * self.shakeInfo.range[1], oldYpos + pianyi * self.shakeInfo.range[2])

    if self.shakeInfo.frame == 0 then
        self.shakeInfo = nil
        shakeLayer:pos(oldXpos, oldYpos)
        self.oldPos = nil
    end
end


function AnimDialogView:chkAnimed(  )
	if self.events then
		if self.events[self.animLabel] 
			and self.events[self.animLabel].animed 
			and self.events[self.animLabel].animed[tostring(self.currentFrame)] then
			return true
		end
	end
	return false
end


--[[
更新人物头上的表情符号
]]
-- function AnimDialogView:updateEmoi(  )
-- 	if self.events then
-- 		if self.self.events[self.animLabel].enoi[tostring(self.currentFrame)] then

-- 		end
-- 	end
-- end



--[[
更新法阵上边的信息
]]
function AnimDialogView:updateFaZhenEffect()
	--[[
	判定法阵信息  如果法阵的位置和人物的做包位置很接近 则判定人物进入法阵，读取法阵应该调到的Anim
	法阵所在的self.mainNode  放养的人物也是在self.mainNode节点中
	判定直接使用距离远近判定的方法
	]]

	if not ( self.allFaZhenModels and #self.allFaZhenModels>0 ) then
		--如果不存在法阵model则需要判定
		return
	end

	if self.autoMove and self.moveBody and self.moveBody.label == Fight.actions.action_stand then
		for k,v in pairs(self.allFaZhenModels) do
			local fazhenPosx = v:getPositionX()
			local fazhenPosY = v:getPositionY()

			local moveX = self.moveBody:getPositionX()
			local moveY = self.moveBody:getPositionY()

			local dis  = math.sqrt( (moveX- fazhenPosx)*(moveX- fazhenPosx) + (fazhenPosY-moveY)*(fazhenPosY-moveY) )

			if dis<=50 then
				echo("放养的人物进入到了法阵---可以执行跳转了")
				local cfg = v:getTransferPos()
				if not self.tiaozhuan then
					self.tiaozhuan = true
					self.controler:showPlotDialogByCurrentOrder(cfg)
					self:fazhenTiaoChu()
				end
				
				return
			end

		end
	end
end

--[[
	更新位置锁定的检查
]]
function AnimDialogView:updateLockPosition()
	if self._nowLockType ~= "position" then return end

	if self.autoMove and self.moveBody then
		-- 为了提高效率就不每帧都创建rect和point了
		local moveX = self.moveBody:getPositionX()
		local moveY = self.moveBody:getPositionY()

		local params = self.locks[self.animLabel][tostring(self.currentFrame)].data
		local wd2 = params.width/2
		local hd2 = params.height/2
		if (moveX >= params.x - wd2) and (moveX <= params.x + wd2) and 
			(moveY >= params.y - hd2) and (moveY <= params.y + hd2) then
			self.moveBody:stopAllActions()
			self:autoMoveBodyEnd()

			self:chkUnLock("position",self.locks[self.animLabel][tostring(self.currentFrame)].frame)
			EventControler:dispatchEvent(BiographyUEvent.EVENT_POSITION_FINISH)
		end
	end
end

--法阵跳转的时候 判断是否是轶事答题
function AnimDialogView:fazhenTiaoChu( )
	if self.missionOpen then
		local missionType = FuncMission.getMissionTypeById( self.missionData.id )
	    if tonumber(missionType) == FuncMission.MISSIONTYPE.QUEST then
	        MissionServer:quitMissionQuestActive( {},nil )
	    end
	end
end


--[[
执行chat解锁
这里要点击解锁操作
]]
function AnimDialogView:doChatClick(body,frame)

	if self.autoMove and self.moveBody then
		IS_SHOW_CLICK_EFFECT = true

		local tx,ty = self:getMoveTargetByBody(body)

		local events = {}
		events.x = tx
		events.y = ty

		self.moveBody:setMenuClick(false)

		local callBack = function()
			--echo("移动到制初始点")
			body:clearChatIcon()

			self.moveBody:playLabel(Fight.actions.action_stand)
			self.moveBody:setPositionX(tx)
			self.moveBody:setPositionY(ty)

            -- self.moveBody:visible(false)

			-- self.autoMove = false
			-- -- 不置空这里，人物会不受剧情的运动约束
			-- self.moveBody = nil

            -- self:doJumpBack(  )
            self:chkUnLock("chat", frame)
		end
		events.callBack = callBack
		self:onTouchEvent(events,true)
	end

end


--[[
点击宝箱头顶的气泡
]]
function AnimDialogView:doBoxIconClick(body,frame )
		
	echo("执行放养的任务直接移动到 放养前的位置")
	echo("这里需要弹出掉落面板，然后在面板关闭后解锁")

	self.touchNode:setTouchEnabled(false)	
	body:clearChatIcon()



	if self.autoMove and self.moveBody then
		IS_SHOW_CLICK_EFFECT = true

		local events = {}
		-- local name = self.moveBody:getNameStr()
		events.x = self.spine:getBoneTransformValue("box", "x")
		events.y = self.spine:getBoneTransformValue("box", "y") + 5
		local sx = self.spine:getBoneTransformValue("box", "sx")
		local sy = self.spine:getBoneTransformValue("box","sy")

		--宝箱消失回调
		local boxDisCallBack = function ( ... )
			
			-- self.moveBody = nil
			local event = {}
			event.x = self.atuoBodyPosX
			event.y = self.atuoBodyPosY

			-- 用完将参数置回
			self.atuoBodyPosX = nil
			self.atuoBodyPosY = nil

			event.callBack = function ( )
				self.isOpening = false
				self.autoMove = false
				self.moveBody:playLabel(Fight.actions.action_stand)
				self:chkUnLock("box", frame)
			end
			self:onTouchEvent(event,true)

			
		end
		-- 需要弹出一个奇侠唤醒的UI
		local awakenQiXiaFunc = function ( ... )
			local awakenId = self.cfgData.awakenId
            echo("此时 awakenId ==== ",awakenId)
			if awakenId then
                if self.controler.animBoxReward then
                    self.controler.animBoxReward = nil
                    local partnerId = FuncGuide.getAwakenPartner(awakenId)
				    if not PartnerModel:isHavedPatnner(partnerId) then
					    WindowControler:showTutoralWindow("AwakenView",awakenId,boxDisCallBack)
				    else
					    boxDisCallBack()
				    end
                else
                    boxDisCallBack()
                end
			else
				boxDisCallBack()
			end
		end
		--[[
		打开宝箱的回调
		]]
		local openBoxCallBack = function ( ... )
	        -- 宝箱渐隐
			body:playDisplayBox(awakenQiXiaFunc)
			
		end
		local openCallBack = function ( ... )
			if self.controler then
				self.controler:doOpenExtraBox(openBoxCallBack)
			else
				openBoxCallBack()
			end
		end



		local callBack = function()
			
			self.moveBody:playLabel(Fight.actions.action_stand)
			self.moveBody:setPositionX(events.x)
			self.moveBody:setPositionY(events.y)

			-- body:delayCall(openCallBack, 13/GameVars.GAMEFRAMERATE )
			body:setOpenCall(openCallBack)
			body:playOpenBox()
			
		end
		events.callBack = callBack
		self:onTouchEvent(events,true)

		self.btn_jump:visible(false)
		self.btn_exit:visible(false)
	end





	-- if self.boxBody and self.boxBody.spine then
	-- 	self.boxBody.spine:playOpenBox()




	-- 	echo("这里暂时先不处理。直接解锁-----")

	-- 	self:chkUnLock("box",frame)
	-- end


end
-- 序章宝箱领取成功
function AnimDialogView:xuzhangBox( )
	self.isGetXuzhangBox = true
end

-- 获取移动位置
function AnimDialogView:getMoveTargetByBody(body)
	local tx,ty = self:getAnimBodyPos(body)

	local moveX = self.moveBody:getPositionX()
	local moveY = self.moveBody:getPositionY()

	if tx > moveX then
		tx = tx - 100
		ty = ty
	else
		tx = tx + 100
		ty = ty
	end

	return tx,ty
end

--[[
	做人物被采集的点击
]]
function AnimDialogView:doBodyCollectClick(body,frame,allinfo,bodyinfo)
	if self.autoMove and self.moveBody then
		IS_SHOW_CLICK_EFFECT = true

		local tx,ty = self:getMoveTargetByBody(body)

		local events = {}
		events.x = tx
		events.y = ty

		local function callBack()
			self.moveBody:playLabel(Fight.actions.action_stand)
			self.moveBody:setPositionX(tx)
			self.moveBody:setPositionY(ty)

			-- 开始采集，之后做采集成功的内容
			self.moveBody:setCollect(true)
			-- 终止UI点击
			self:disabledUIClick()
			-- 采集一个时长
			self.moveBody:delayCall(function()
				-- 去掉采集效果
				self.moveBody:setCollect(false)
				-- 放开UI点击
				self:resumeUIClick()
				-- 做采集
				allinfo.num = allinfo.num - 1
				bodyinfo.num = bodyinfo.num - 1
				-- echoError("采我",allinfo.num,bodyinfo.num)
				-- 采完了，隐藏
				if bodyinfo.num == 0 then
					body:visible(false)
				else -- 没采完，先隐藏再显示
					body:setTouchEnabled(false)
					body:opacity(0)
					body:stopAllActions()
					body:runAction(cc.Sequence:create({
						cc.DelayTime:create(1),
						cc.FadeIn:create(0.3),
						cc.CallFunc:create(function()
							-- 恢复点击
							body:setTouchEnabled(true)
						end)
					}))
				end

				if allinfo.num == 0 then
					-- 检查解锁
					self:chkUnLock("collect",frame)
					-- 发相关消息
					EventControler:dispatchEvent(BiographyUEvent.EVENT_COLLECT_FINISH)
				end
			end, 1.5)
		end
		events.callBack = callBack
		self:onTouchEvent(events,true)
	end
end

--[[
	做人物被点击对话的事件
]]
function AnimDialogView:doBodyMultipleClick(body,frame,unlockbd,plotId)
	if self.autoMove and self.moveBody then
		IS_SHOW_CLICK_EFFECT = true

		local tx,ty = self:getMoveTargetByBody(body)

		local events = {}
		events.x = tx
		events.y = ty

		local function callBack()
			self.moveBody:playLabel(Fight.actions.action_stand)
			self.moveBody:setPositionX(tx)
			self.moveBody:setPositionY(ty)

			local afterplot = nil
			echo("body:getNameStr() == unlockbd",body:getNameStr(),unlockbd)
			-- 此人在此人处解锁
			if body:getNameStr() == unlockbd then
				afterplot = function()
					self:chkUnLock("multiplechat",frame)
				end
			end

			local function onplotCallBack(event)
				if not event.isJump then
					-- 发对话完成的消息
					EventControler:dispatchEvent(BiographyUEvent.EVENT_PLOT_FINISH,{plotId = plotId})

					if afterplot then
						afterplot()
					end
				end
			end

			-- 到了做对话
			PlotDialogControl:init() 
			PlotDialogControl:setAnimId(self.cfgData.id)
			self.plotControl = PlotDialogControl:showPlotDialog(plotId, onplotCallBack)
		end

		events.callBack = callBack
		self:onTouchEvent(events,true)
	end
end

--[[
	战斗锁定的人物事件
]]
function AnimDialogView:doBodyBattleClick(body,frame,battleType,params)
	if self.autoMove and self.moveBody then
		IS_SHOW_CLICK_EFFECT = true

		local tx,ty = self:getMoveTargetByBody(body)

		local events = {}
		events.x = tx
		events.y = ty

		local function callBack()
			self.moveBody:playLabel(Fight.actions.action_stand)
			self.moveBody:setPositionX(tx)
			self.moveBody:setPositionY(ty)

			-- 调用方法进战斗
			if tonumber(battleType) == 1 then
				BiographyControler:enterBattle(params)
			end
		end

		events.callBack = callBack
		self:onTouchEvent(events,true)
	end
end

--[[
	游戏锁定人物事件
]]
function AnimDialogView:doGameClick(body,frame,params)
	-- 点人触发的类型
	if params.triggertype == 1 then
		if self.autoMove and self.moveBody and body then
			local tx,ty = self:getMoveTargetByBody(body)

			local events = {}
			events.x = tx
			events.y = ty

			local function callBack()
				self.moveBody:playLabel(Fight.actions.action_stand)
				self.moveBody:setPositionX(tx)
				self.moveBody:setPositionY(ty)

				-- 调用游戏方法
				self:doEnterGame(params.triggertype,params.gtype,params.gid,frame)
			end

			events.callBack = callBack
			self:onTouchEvent(events,true)
		end
	else -- 直接触发的方式
		-- 调用游戏方法
		self:doEnterGame(params.triggertype,params.gtype,params.gid,frame)
	end
end

--[[
	调用进入游戏玩法
]]
function AnimDialogView:doEnterGame(triggertype,gtype,gid,frame)
	local view = {
		"GameGuessMeView",
		"GameQuestionView",
	}
	-- 和奇侠传记类型的映射
	local bioevt = {
		[1] = 3,
		[2] = 6,
	}
	-- 猜人，答题
	if gtype == 1 or gtype == 2 then
		local gameData = {gameId = gid}
		local gameView = WindowControler:showWindow(view[gtype], gameData)

		local gameListener = {}
		-- 游戏结束回调
		gameListener.onGameOver = function(gameResultData)
			-- 这个玩法似乎只会收到成功的消息
			if gameResultData then
				if gameResultData.rt == FuncGame.GAME_RESULT.WIN then
					-- 检查解锁
					self:chkUnLock("game", frame)
					EventControler:dispatchEvent(BiographyUEvent.EVENT_GAME_FINISH,{subtype = bioevt[gtype]})
				end
			end
		end

		gameView:setGameListener(gameListener)

		-- 此类型不允许主动结束，屏蔽按钮
		if triggertype == 2 then
			gameView:hideCloseBtn()
		end
	end
end

--[[
更新镜头的缩放
]]

function AnimDialogView:updateCamer()
	if self.jintouNode then
		



		-- self.jintouNode:setScaleX(sx)
		-- self.jintouNode:setScaleY(sy)
		-- self.jintouNode:setPositionX(x)
		-- self.jintouNode:setPositionY(y)

		if not self.autoMove then
			local bone = "jingtou"
			local x = self.spine:getBoneTransformValue(bone, "x")
			local y = self.spine:getBoneTransformValue(bone, "y")
			local sx = self.spine:getBoneTransformValue(bone, "sx")
			local sy = self.spine:getBoneTransformValue(bone, "sy")

			self:followToTargetPos(-x,y,sx,sy)
		end
	end
end



--[[
检测帧，是否显示plotDialogView
]]
function AnimDialogView:updatePlot(dt)

	local plotData = self.events[self.animLabel].plots[tostring(self.currentFrame)]
	if plotData ~= nil then
		local plotId = plotData.plotId
    	PlotDialogControl:init() 
    	PlotDialogControl:setAnimId(self.cfgData.id)
    	PlotDialogControl:setAfterOrderCallBack(c_func(self.afterShowPlotOrderCallBack,self))
    	self.plotControl = PlotDialogControl:showPlotDialog(plotId, c_func(self.showPlotCallBack,self))
        --发消息 显示跳过和退出按钮
        local _tiaoguo,_fanhui = self:isJumpBtnShow()
        EventControler:dispatchEvent(BattleEvent.PLOTVIEW_BTN_SHOW,{ show = _tiaoguo,show2 = _fanhui})
        self:showJumpAndExitBtn(false)
	end
end
--是否显示跳过/返回（0或空都显示，1：隐藏跳过，2：隐藏返回，3：全隐藏）
function AnimDialogView:isJumpBtnShow(  )
	if self.hideBtnEvent then
		return false,false
	end
	local btnShow = self.cfgData.btnShow or 0
	local _tiaoguo = false
	local _fanhui = false
	if btnShow == 0 then
		_tiaoguo = true
		_fanhui = true
	elseif btnShow == 1 then
		_tiaoguo = false
		_fanhui = true
	elseif btnShow == 2 then
		_tiaoguo = true
		_fanhui = false
	elseif btnShow == 3 then
		_tiaoguo = false
		_fanhui = false
	end
	return _tiaoguo,_fanhui
end
function AnimDialogView:showJumpAndExitBtn(isShow)
	
	if self.btn_exit then
        self.btn_exit:visible(false)
    end
    if self.btn_jump then
        self.btn_jump:visible(false)
    end
	if isShow ~= nil then
		self.btn_jump:visible(isShow)
		self.btn_exit:visible(isShow)

		self.btn_jump:setPosition(self.btnPos.left)
	else
		local _tiaoguo,_fanhui = self:isJumpBtnShow()
		self.btn_jump:visible(_tiaoguo)
		self.btn_exit:visible(_fanhui)

		-- 返回显示，自己在自己的位置
		if _fanhui then
		    self.btn_jump:setPosition(self.btnPos.left)
		else
		    -- 跳过放到右边
		    self.btn_jump:setPosition(self.btnPos.right)
		end
	end
	
end

--[[
整个plot播放完成
]]
function AnimDialogView:showPlotCallBack(params)
	EventControler:dispatchEvent(TutorialEvent.CUSTOM_TUTORIAL_MESSAGE, 
                    {tutorailParam = TutorialEvent.CustomParam.PlotFinish .. params.plotId})
	if not params.isJump then
		EventControler:dispatchEvent(BiographyUEvent.EVENT_PLOT_FINISH,{plotId = params.plotId})
	end
end

--[[
plot显示完成的灰掉
]]
function AnimDialogView:afterShowPlotOrderCallBack(plot,order)
	self:chkUnLock("plot",plot,order)
end

--[[
黑屏特效
]]
function AnimDialogView:updateSceneBlack(dt)
	if self.events and self.events[self.animLabel].black then
		local blacks = self.events[self.animLabel].black 
		if blacks[tostring(self.currentFrame)] then
			--有黑屏效果
			--黑屏的特效类型  这里不使用 todo dev
			local ty = blacks[tostring(self.currentFrame)].type
			--黑屏特效的时长
			local frameCnt = blacks[tostring(self.currentFrame)].frameCnt
			self.isSceneBlack = true
			self.sceneBlackCnt = frameCnt
			self:showBlackImage(blacks[tostring(self.currentFrame)])
		end
	end
end

--显示黑屏
function AnimDialogView:showBlackImage(info)
	local _dialog = info.dialog or {}
	-------- 这部分代码是以前的保留，不动 --------
	self.blackImage:visible(true)
	
	self.blackImage:stopAllActions()
	self.mapBackNode:stopAllActions()
	self.mapFontNode:stopAllActions()
	self.panel_1:stopAllActions()
	if info.type == 1 then
		self.mapBackNode:visible(false)
		self.mapFontNode:visible(false)
		self.blackImage:opacity(255)
		self.blackImage:zorder(BLACK_ZORDER_1)
		self.panel_1:visible(false)
	else
		self.panel_1:visible(true)
		self.panel_1:opacity(255)
		self.blackImage:opacity(60)
		self.blackImage:zorder(BLACK_ZORDER_2)
	end
	self.blackImage:stopAllActions()

	if self.blackDialog and table.length(self.blackDialog) > 0 then
		for i,v in pairs(self.blackDialog) do
			v:visible(false)
		end
	end
    self.blackDialog = {}
	local showDialogFunc = function (  )
		-- 此时要添加对话
		-- 计算初始位置
		local scale = 1/(self.jintouNode:getScale()*self.mainNode:getScale())
		local mainofX = self.mainNode:getPositionX()
		local mainofY = self.mainNode:getPositionY()
		local jtofX = self.jintouNode:getPositionX()
		local jtofY = self.jintouNode:getPositionY()
		local offsetY = GameVars.gameResHeight /2 + 50 * scale - (GameVars.gameResHeight - 40 * (#_dialog )) / 2
        for i,v in pairs(_dialog) do
            local titleView =   UIBaseDef:cloneOneView( self.txt_raidTitle1)
            self._root:addChild(titleView,10001)
            table.insert(self.blackDialog,titleView)
		    titleView:opacity(0)
		    -- titleView:scale(scale)
		    local str = GameConfig.getLanguageWithSwapForPlot(v,UserModel:name())
		    titleView:setString(str)
            titleView:setPositionX(-450 )
            titleView:setPositionY(offsetY - i * 40 )
            function _fadeTo()
                transition.fadeTo(titleView,{time = 0.4,opacity = 255* 1.0})
            end
            titleView:delayCall(_fadeTo,0.5*(i - 1))
		    
        end
	end
	-------- 这部分代码是以前的保留，不动 --------
	local function showAnim()
		local max = 16
		local nums = #_dialog
		for i=1,max do
			local view = self.panel_1["mc_"..i]
			if i <= nums then
				view:visible(true)
				view:opacity(0)
				view:showFrame(info.colorFrame)
				view.currentView.txt_1:setString(GameConfig.getLanguageWithSwapForPlot(_dialog[i],UserModel:name()))
				view:stopAllActions()
				view:runAction(cc.Sequence:create({
					cc.DelayTime:create((i - 1) * 0.5),
					cc.FadeIn:create(0.4),
				}))
			else
				view:visible(false)
			end
		end
	end
	if info.type == 1 then
		transition.fadeTo(self.blackImage,{time = 0.5,opacity = 255* 1.0,onComplete = showDialogFunc})
	elseif info.type == 2 then
		showAnim()
	end
end

--关闭黑屏
function AnimDialogView:hideBlackImage(  )
	-- self.blackImage:visible(false)
	-- self.blackImage:opacity(0)
	self.mapBackNode:visible(true)
	
	for i,v in pairs(self.blackDialog) do
	    v:visible(false)
        v:removeFromParent()  
	end
	self.blackDialog = {}
	self.blackImage:stopAllActions()
	-- self.blackImage:fadeTo(0.5, 0)
	local onComplete = function (  )
		self.blackImage:visible(false)
		self.mapFontNode:visible(true)
		self.panel_1:visible(false)
	end
	transition.fadeTo(self.blackImage,{time = 0.5,opacity = 0,onComplete = onComplete})
	transition.fadeTo(self.panel_1,{time = 0.5,opacity = 0,onComplete = onComplete})
end



function AnimDialogView:addAnim2Battle(callBack )
	BattleControler:setXuQing(true)
	-- 入战斗的转场特效
    -- FuncArmature.loadOneArmatureTexture("UI_kaizhan" ,nil ,true)
    local kzAnim = FuncArmature.createArmature("UI_kaizhan_kaizhan_a",self, false,GameVars.emptyFunc)
    kzAnim:playWithIndex(1,0)
    kzAnim:pos(GameVars.halfResWidth,-GameVars.halfResHeight)--绝对中心位置
    kzAnim:delayCall(function( )
        if kzAnim then
            kzAnim:removeFromParent()
        end
        -- FuncArmature.clearOneArmatureTexture("UI_kaizhan" ,true)
        if callBack then
            callBack()
        end
    end,20/GameVars.GAMEFRAMERATE)
end

function AnimDialogView:hideBoneDisplay( )

end
-- 清除所有的missionModel
function AnimDialogView:removeAllMissionModel()
    for i = #self.allModels,1,-1 do
		local v = self.allModels[i]
		if v.viewType == "missionBone" then
            v:visible(false)
            v:removeFromParent()
            table.remove(self.allModels,i)  
        end
	end
	self.allMissionModels = nil
    self.allMissionModels = {}
end

-- 设置地标相关的内容初始化
function AnimDialogView:setInitLandMark(posX,posY)
	self:setLandMark(true)
	if posX and posY then
		-- 先隐藏人物位置防止闪
		local model = self.bodys["body1"].spine
		model:visible(false)
		-- 设置人物初始位置
		self:setMoveBodyPos(posX,posY)
		-- 把镜头放到相应的位置
		self:followToTargetPos(self.initPosX,self.initPosY)
	end
end

function AnimDialogView:setMoveBodyPos(posX,posY)
	self.initPosX = posX
	self.initPosY = posY
end

function AnimDialogView:setLandMark(flag)
	self._isLandMark = flag
end

function AnimDialogView:isLandMark()
	return self._isLandMark
end

function AnimDialogView:hasLock()
	return self._nowLockType ~= nil
end

function AnimDialogView:showBiographyTaskFinish(callBack)
	-- 屏蔽点击
	self:disabledUIClick()

	-- 动画
	local finishAnim = self:createUIArmature("UI_qixiazhuanji","UI_qixiazhuanji_wenzichuxian", self._root, false, function()
		-- 再等1s
		self:delayCall(function()
			if callBack then callBack() end
		end, 1)
	end)

	finishAnim:pos(0, GameVars.height/2 - 150)
end

--[[
deleteMe() 方法 清除自身
]]
function AnimDialogView:deleteMe()
    
    self.controler = nil
    if self.map then
    	self.map:deleteMe()
    end
    if self.plotControl then 
    	self.plotControl = nil
    end
    AnimDialogView.super.deleteMe(self)
end 



return AnimDialogView;
