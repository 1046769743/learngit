local ArenaListBaseItem = class("ArenaListBaseItem", UIBase)

function ArenaListBaseItem:ctor(winName)
	ArenaListBaseItem.super.ctor(self, winName)
end

function ArenaListBaseItem:loadUIComplete()
	for i=1,4 do
		local playerView = self["UI_p"..i]
        if playerView then
		    playerView:visible(false)
        end
	end
end

function ArenaListBaseItem:setArenaList(arenaScrolllist)
	self.scroll_list = arenaScrolllist
end

----less than or equal to three players
--function ArenaListBaseItem:setPlayerInfos(players)
--    if type(players) ~= "table" then players = {} end
--    if type(players[1]) ~="table" then players = {} end
--    self.players = players or {}
--    local sortByRank = function(a, b)
--        return tonumber(a.rank)<tonumber(b.rank)
--    end
--    table.sort(self.players, sortByRank)
--end

--function ArenaListBaseItem:updateUI()
--    for i=1,3 do
--        local playerInfo = self.players[i]
--        local playerView = self["UI_p"..i]
--        if not playerInfo then
--            playerView:visible(false)
--        else
--        end
--    end
--end

function ArenaListBaseItem:updateOnePlayer(index, info, arenaMainView)
	local playerView = self["UI_p"..index]
	if type(info)~= "table" then
		playerView:visible(false)
	else
		self:initOnePlayer(playerView, info, arenaMainView)
	end
	return playerView
end

function ArenaListBaseItem:initOnePlayer(playerView, playerInfo, arenaMainView)
	playerView:visible(true)
	playerView:setArenaMainView(arenaMainView)
    playerView:updatePlayerAttachState(false);
	playerView:setPlayerInfo(playerInfo)
    --
--    local _uid = UserModel:rid()
--    local _user_rank = PVPModel:getUserRank()
--    if playerInfo.rid == _uid then --如果为自身的信息
--        playerView:setTapFunc(c_func(self.clickButtonLayoutSelf,self))
--    elseif playerInfo.rank >  _user_rank then--如果小于玩家自己的排名
--        playerView:setTapFunc(c_func(self.clickButtonChange5Times,self))
--    else
--	    playerView:setTapFunc(c_func(self.clickButtonLayoutPlayer, self, playerView))
--    end
	playerView:updateUI(true)
end
--查看角色的布阵
function ArenaListBaseItem:clickButtonLayoutPlayer(_playerInfo)
    --如果是机器人
    if _playerInfo.type == FuncPvp.PLAYER_TYPE_ROBOT  then
        self:robotLayoutView(_playerInfo)
        return
    end
    --如果角色是真实玩家

end
--查看角色布阵之后的回复
function ArenaListBaseItem:onEventLayoutPlayer(_playerInfo,_event)
    
end
--机器人的布局查看
function ArenaListBaseItem:robotLayoutView(_playerInfo)

end
--点击自己为进入防御布阵UI
function ArenaListBaseItem:clickButtonLayoutSelf()

end
--挑战5次
function ArenaListBaseItem:clickButtonChange5Times()

end

-- 废弃方法 by ZhangYanguang
-- function ArenaListBaseItem:challenge(playerView)
-- 	if not self.scroll_list:isMoving() then
-- 		playerView:tryToChallenge()
-- 	end
-- end

--//清理
function ArenaListBaseItem:removePlayers()
    for _index=1,3  do
          self["UI_p".._index]:removeOriginPlayer();
    end
end
return ArenaListBaseItem

