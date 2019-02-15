--
-- Author: Your Name
-- Date: 2014-12-09 17:18:43
--
local SceneGame = class("SceneGame", SceneBase)


function SceneGame:onEnter()  
    SceneGame.super.onEnter(self)
    SceneSwitch:doSceneIn(self)
end

function SceneGame:setCampData(mode,battleInfo)
    self.gameControl =  GameControler.new()

    local gameData = {
        mapId = "1001",
        win = 1,  -- 至死方休，或者超时
        time = 120,--时间
        randomSeed = 100,
        gameMode = mode,
    }

    -- 关卡怪物
    local levelObj = ObjectLevel.new("101" )
    gameData.time = levelObj.prototypeData.time * GameVars.GAMEFRAMERATE
    gameData.win = levelObj.prototypeData.win
    gameData.waveData = levelObj.enemys
    gameData.campData1 = {}
    local heroData = ObjectCommon.getHeroCfg()

    if mode == Fight.gameMode_pve then -- 单人推本

        local userrid = UserModel:rid()
        gameData.campData1[1] = clone(heroData[1])
        gameData.campData1[1].rid = userrid

        gameData.protecter = levelObj.prototypeData.protecter

        if  gameData.win == Fight.levelWin_time then
            gameData.winparam = tonumber(levelObj.prototypeData.winparam[1])
            gameData.winparam = self.gameData.time - self.gameData.winparam * GameVars.GAMEFRAMERATE
        else
            gameData.winparam = levelObj.prototypeData.winparam
            gameData.winparam[1] = "10001"
        end

    elseif mode == Fight.gameMode_gve then 
        local userrid = UserModel:rid()
        for i=1,#battleInfo.campArr_1 do
            gameData.campData1[i] = clone(heroData[1])
            gameData.campData1[i].rid = clone(battleInfo.campArr_1[i]._id)
        end

        gameData.randomSeed = clone(battleInfo.battleInfo)

        gameData.protecter = levelObj.prototypeData.protecter
        if  gameData.win == Fight.levelWin_time then
            gameData.winparam = tonumber(levelObj.prototypeData.winparam[1])
            gameData.winparam = self.gameData.time - self.gameData.winparam * GameVars.GAMEFRAMERATE
        else
            gameData.winparam = levelObj.prototypeData.winparam
            gameData.winparam[1] = "10001"
        end

    elseif mode == Fight.gameMode_pvp then
        gameData.randomSeed = battleInfo.battleInfo
        -- 调整关卡参数 
        gameData.time = levelObj.prototypeData.time * GameVars.GAMEFRAMERATE

        local heroData = ObjectCommon.getHeroCfg()
        gameData.campData1 = {}
        for i=1,#battleInfo.campArr_1 do
            gameData.campData1[i] = heroData[i]
            gameData.campData1[i].rid = battleInfo.campArr_1[i].rid
        end
        -- gameData.waveData = {}
        -- for i=1,#battleInfo.campArr_2 do
        --     gameData.waveData[i] = levelObj.enemys[i]
        --     gameData.waveData[i].rid = battleInfo.campArr_2[i].rid
        -- end  
    end

    self.gameControl:checkLoadTexture(self._root,mode, gameData)
end


function SceneGame:onExit()
    if self.gameControl and ( not self.gameControl.died) then
        self.gameControl:deleteMe()
        self.gameControl = nil
    end
	--self.gameControl:deleteMe()
end
return SceneGame