local LineUpViewControler = class("LineUpViewControler")

function LineUpViewControler:ctor()
	-- body
end
--[[
	params = {
		-- isSelf = true, 	-- 是否查看自己 弃用，不是查看他人默认查看自己
		-- 查看他人信息时需要
		trid = "dev_7",		-- 玩家rid
		tsec = "dev",		-- 玩家所在区服
		formationId = "99",	-- 阵型id
		-- 查看机器人时
		isRobot = true,		-- 机器人
		... -- 其他信息
	}
]]
-- 打开查看阵容主界面
function LineUpViewControler:showMainWindow( params )
	local params = params or {}
	
	if params.isRobot then -- 机器人
		LineUpModel:initRobotLineUpInfo(params)
		-- 这条要在上条下面 不然serverInfo会被初始化的时候重新覆盖掉
		-- 存一下当前玩家的id和区服
		LineUpModel:setServerInfo(params.rid, LoginControler:getServerId())
		echo("\n-----------查看的是机器人------------")
		-- WindowControler:showWindow("WuXingCheckTeamEmbattleView",FuncTeamFormation.formation.check_lineup)
	else
		if params.trid and tostring(UserModel:_id()) ~= tostring(params.trid) then -- 查看别人
			-- -- 如果已经打开了这个界面，说明是从自己的页面里去查看他人的信息
			-- if WindowControler:checkHasWindow("WuXingCheckTeamEmbattleView") then
			-- 	-- 缓存一份自己的信息
			-- 	LineUpModel:cacheOwnInfo()
			-- end

			LineUpServer:requestFormationInfo({
				trid = params.trid, 
				tsec = params.tsec, 
				formationId = params.formationId,
			    callBack = function()
				    -- 存一下当前玩家的id和区服
					local param = {}
			    	param.rids = {}
			    	param.rids[1] = params.trid
			    	param.detailed = 1
			    	LineUpModel:setServerInfo(params.trid, params.tsec)
			    	ChatServer:queryPlayerInfo(param, function (event)
						if event.result then
							local _playerInfo = event.result.data.data[1]
							WindowControler:showWindow("RankListAbilityInfoView",
												 1, {rid=params.trid}, _playerInfo)
						else
							echoError("获取玩家信息返回数据报错")
							return
						end
					end)
			    	-- WindowControler:showWindow("RankListAbilityInfoView", 1, {rid=params.trid})
			        -- WindowControler:showWindow("WuXingCheckTeamEmbattleView",FuncTeamFormation.formation.check_lineup)
			        -- 如果当前存在赞我的人列表，进行一下可能存在的刷新
			        if WindowControler:checkHasWindow("LineUpPraiseListView") then
			        	LineUpModel:udpatePraiseListByInfo(LineUpModel:getCurCharInfo())
			        	EventControler:dispatchEvent(LineUpEvent.PRAISE_LIST_UPDATE_EVENT)
			        end
			    end
			})
		else -- 查看自己
			if LineUpModel:hasCacheOwnInfo() then -- 有缓存信息
				LineUpModel:popCacheOwnInfo()
				local window = WindowControler:getWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.pve)
				-- 刷新一下界面
				-- window:onBecomeTopView()
				-- 把赞我的人列表置顶
				-- WindowControler:showWindow("LineUpPraiseListView")
			else
				-- LineUpServer:getOwnPraiseInfo(function()
				-- 	-- 存一下当前玩家的id和区服
				-- 	LineUpModel:setServerInfo(UserModel:rid(), LoginControler:getServerId())
					WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.pve)
				-- end)
			end
		end
	end
end
-- 打开查看阵容，赞我的人列表界面
function LineUpViewControler:showPraiseListWindow()
	LineUpServer:getPraiseList(1, function()
		WindowControler:showWindow("LineUpPraiseListView")
	end, true)
end
-- 查看预览里打开主界面
function LineUpViewControler:showMainWindowInPrewiew()
	WindowControler:showWindow("LineUpMainView")
end

return LineUpViewControler