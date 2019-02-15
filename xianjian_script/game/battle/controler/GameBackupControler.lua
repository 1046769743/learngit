

GameBackupControler = class("GameBackupControler")

GameBackupControler.defaultInfo = nil
GameBackupControler.fragmentInfo = nil -- 回退时候的时间片信息
GameBackupControler.operateInfo = nil -- 回退时的操作信息
GameBackupControler.serverFrame = nil -- 服务器帧数
GameBackupControler._infoIdx = 0
GameBackupControler._backUp = false

GameBackupControler.keyMap = {      
   
}


function GameBackupControler:ctor( controler )
	self.controler = controler
	self.defaultInfo = {}

	self:initDefautInfo()
end

function GameBackupControler:initDefautInfo()
	
end


function GameBackupControler:pushTimeLine(frame)
	
end

function GameBackupControler:checkPushTimeLine(frame,info)
	
end

function GameBackupControler:clearPushTimeLine()
end


-- 跳转到相应的时间片
function GameBackupControler:jumpToFragment()
	
end

-----------------------------------------------------------------------------------------------
---------------------  加密时间片信息    ------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- 与默认值相等不会赋值 encode
function GameBackupControler:checkDataByDefaultE(inT,outT,default,encode)
	
end

-- decode
function GameBackupControler:checkDataByDefaultD(inT,outT,default,encode)
	
end

-----------------------------------------------------------------------------------------------
--------------------- 时间片备份  -------------------------------------------------------------
-----------------------------------------------------------------------------------------------

-- 战斗数据备份
function GameBackupControler:makeMirrorData()

end

-----------------------------------------------------------------------------------------------
--------------------- 按照时间片信息回退 ------------------------------------------------------
-----------------------------------------------------------------------------------------------


-- 倒带复原英雄，如果第二个参数不为Nil 则第一个参数不起作用
function GameBackupControler:battleBackups(updateCount,info)
	
end

-- screen
function GameBackupControler:screenBackup(info)
	
end

-- enemyFreshBackUp
function GameBackupControler:enemyRefreshBackup(info)
	
end


-- 清除实例和放技能的信息 
function GameBackupControler:clearAllObj()
	
end

-- 其中object为复原的英雄
function GameBackupControler:heroBackup(info)
	
end

-- 检测打击的人
function GameBackupControler:checkHitObjs(hero)
	
end

-- 其中object为复原的英雄，heroinfo是原来备份的信息
function GameBackupControler:heroDataRecover(object,heroinfo)
	

end

-- 遍历法宝,然后查找到技能
function GameBackupControler:missleFindSkill(treasure,skillHid )
	
end

function GameBackupControler:missleBackup(info)
	
end

--=============================================================================
-- 查看备份前后的信息
local beforeInfo = {}
local afterInfo = {}
function GameBackupControler:showCampInfo( isBefore )	
	
end

--@调试用的回退特定帧用，不删
function GameBackupControler:jumpToJustFragment(updateCount)
	
end


-- 刷新时间片备份信息
function GameBackupControler:updateFrame(updateCount)
	
end




function GameBackupControler:deleteMe()
	self.defaultInfo = nil
	self.fragmentInfo = nil
	self.operateInfo = nil
	self.serverFrame = nil
end

return GameBackupControler