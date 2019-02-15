local ArenaBattleReplayResult = class("ArenaBattleReplayResult", UIBase)

function ArenaBattleReplayResult:ctor(winName)
	echo("__________ArenaBattleReplayResult___")
	ArenaBattleReplayResult.super.ctor(self, winName)
end

function ArenaBattleReplayResult:loadUIComplete()
	self:registerEvent()
end

function ArenaBattleReplayResult:registerEvent()
	--self:registClickClose()
	self.btn_quit:setTap(c_func(self.quit, self))
	self.btn_replay:setTap(c_func(self.replay, self))
end

function ArenaBattleReplayResult:quit()
	PVPModel:clearReplayData()
	echo("__ArenaBattleReplayResult------11111")
	self:pressClose()
end

function ArenaBattleReplayResult:pressClose()
	echo("ArenaBattleReplayResult __",self.replay_button_clicked)
	self:startHide()
   if (not self.replay_button_clicked) then
	     FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
    end
    self.replay_button_clicked=nil;
	
end

function ArenaBattleReplayResult:replay()
    self.replay_button_clicked=true;
	self:pressClose()
	
	local battleInfo =  BattleControler._battleInfo   --PVPModel:composeBattleInfoForReplay(currentData)
	
	
	BattleControler:replayLastGame(battleInfo,true)
end

function ArenaBattleReplayResult:hideComplete( )
	echo("ArenaBattleReplayResult,hideComplete()")
	ArenaBattleReplayResult.super.hideComplete(self)
	
end

function ArenaBattleReplayResult:deleteMe(  )
	ArenaBattleReplayResult.super.deleteMe(self)
	echo("___ArenaBattleReplayResult____?ArenaBattleReplayResult")
end


return ArenaBattleReplayResult

