--[[
    Author: 张燕广
    Date:2018-07-26
    Description: Game小游戏Func配表表工具类
]]

FuncGame = FuncGame or {}

local gameShenMiRenCfg = nil
local gameGuessMeCfg = nil
local gameQuestionCfg = nil -- 答题索引表
local gameQuestionBankCfg = nil -- 答题题库表

function FuncGame.init(  ) 
    gameShenMiRenCfg = Tool:configRequire("game.GameShenMiRen")
    gameGuessMeCfg = Tool:configRequire("game.GameGuessMe")
    gameQuestionCfg = Tool:configRequire("game.GameQuestion")
    gameQuestionBankCfg = Tool:configRequire("game.GameQuestionBank")

    -- 游戏结果
    FuncGame.GAME_RESULT = {
        WIN = 1,        --胜利 
        FAIL = 2,       --失败
        TIED = 3,       --平局
        HANDOUT = 4,    --退出
    }
end

function FuncGame.getShenMiRenDataCfg()
    return gameShenMiRenCfg
end

function FuncGame.getShenMiRenDataById(id)
    if id == nil or gameShenMiRenCfg[tostring(id)] == nil then
        echoError("FuncGame.getShenMiRenDataById not found id=",id)
    end

    return gameShenMiRenCfg[tostring(id)]
end

function FuncGame.getGuessMeDataCfg()
    return gameGuessMeCfg
end

function FuncGame.getGuessMeDataById(id)
    if id == nil or gameGuessMeCfg[tostring(id)] == nil then
        echoError("FuncGame.getGuessMeDataById not found id=",id)
    end

    return gameGuessMeCfg[tostring(id)]
end

-- 根据题库索引，返回所有问题
function FuncGame.getQuestionsById(id)
    -- 获取题库索引
    if id == nil or gameQuestionCfg[tostring(id)] == nil then
        echoError("FuncGame.getQuestionsById not found id=",id)
        return
    end

    local questionsIndices = gameQuestionCfg[tostring(id)].questBank

    local questions = {}
    local mark = {}
    local function insertquestion(q)
        local question = gameQuestionBankCfg[tostring(q)]
        if not question then return end

        if not mark[q] then
            questions[#questions + 1] = question
            mark[q] = true
        end
    end
    for _,q in ipairs(questionsIndices) do
        local qs = string.split(q, "-")
        -- 配的是范围
        if qs[2] then
            for i=qs[1],qs[2] do
                insertquestion(i)
            end
        else -- 配的是单个题
            insertquestion(qs[1])
        end
    end

    return questions
end