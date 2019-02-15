--[[
	guan
	2017.2.13
	每个版本更新一次，不要10分钟一次，更新内容太多，sdk没有只获得版本号（上次更新时间的方法）
	
	eg:
	local ret, afterReplace = BanWordsHelper:isStringPlayerCanUse("蒋介 石大将军andfuck");
	ret为false, 包含敏感词
	afterReplace 为 *and* 
]]


BanWordsHelper = BanWordsHelper or {}

BanWordsHelper.gameBanWordsUrl = "http://gscservice.gamebean.net/gscproxy/s/100301.htm?pid=10001087&sid=1007";
BanWordsHelper.playerBanWordsUrl = "http://gscservice.gamebean.net/gscproxy/s/100301.htm?pid=10001087&sid=1006";

--后端最后一次更新敏感字库的时间，相当于字库版本号
BanWordsHelper.gameBanUpdateTimeInServer = nil;
BanWordsHelper.playerBanUpdateTimeInServer = nil;

--[[
	游戏内禁止使用
	{
		"毛泽东" = "毛泽东"，
		"习近平" = "习近平"，
		"胡锦涛" = "胡锦涛"，
	}
]]
BanWordsHelper.gameBanWords = nil;
--[[
	用户禁止使用
	{
		"毛泽东" = "毛泽东"，
		"习近平" = "习近平"，
		"胡锦涛" = "胡锦涛"，
	}
]]
BanWordsHelper.playerBanWords = nil;

BanWordsHelper.BanWordsType = {
	GAME = 1,
	PLAYER = 2,	
};

BanWordsHelper.gameBanWordUpdateTimeKeyInLS = "gameBanWordUpdateTimeInLs";
BanWordsHelper.playerBanWordUpdateTimeKeyInLS = "playerBanWordUpdateTimeKeyInLS";

BanWordsHelper.gameBanWordUpdateFail = "gameBanWordUpdateFail";
BanWordsHelper.playerBanWordUpdateFail = "playerBanWordUpdateFail";



BanWordsHelper.dirInWritablePath = "other/banWords";
BanWordsHelper.fileName = {
	GAME = "gameBanWord.txt",
	PLAYER = "playerBanWord.txt"
}

--[[
	初始化
]]
function BanWordsHelper:initBanWord()
	if IS_CLOSE_BAN_WORDS == true  then 
		return
	end 
	local t1 = os.clock()
	local gameBanWordPath = self:getGameBanWordFilePath();
	local gameBanStr = FS.readFileContent(gameBanWordPath);
	gameBanStr = string.gsub(gameBanStr, "*", "")


	local tableInFile = json.decode(gameBanStr);

	self.gameBanWords = tableInFile.keyList;
	self.gameBanUpdateTimeInServer = tableInFile.updateTime;


	local playerBanWordPath = self:getPlayerBanWordFilePath();
	local playerBanStr = FS.readFileContent(playerBanWordPath);
	playerBanStr = string.gsub(playerBanStr, "*", "")
	local tableInFile = json.decode(playerBanStr);

	self.playerBanWords = tableInFile.keyList;
	self.playerBanUpdateTimeInServer = tableInFile.updateTime;

end

--[[
	强更 热更后 执行，更新
]]
-- function BanWordsHelper:updateAllBanWords()
-- 	if IS_CLOSE_BAN_WORDS == true then 
-- 		return
-- 	end 

-- 	self:updateGameBanWords();
-- 	self:updatePlayerBanWords();
-- end

--[[
	游戏内是否可用
]]
function BanWordsHelper:isStringGameCanUse(str, replaceStr)
	if IS_CLOSE_BAN_WORDS == true  then 
		return true
	end 

	local banWords = self.gameBanWords;

	if self.gameBanWords == nil then 
		echo("---error:BanWordsHelper没有初始化！！！");
		--掌趣有可能来个空list……
		if self.tempGameBanWords == nil then 
			self:setUpWithTempBanWord(BanWordsHelper.BanWordsType.GAME);
		end 

		if self.tempGameBanWords == nil then 
			echo("--error:本地敏感词也没有"); 
			return true, str;
		else 
			echo("使用本地敏感词");
		end

		banWords = self.tempGameBanWords;
	end 

	local afterReplace = string.stripAndLower(str);
	local replaceStr = replaceStr or "*"
	
	for _, v in ipairs(banWords) do

		local ret = string.find( afterReplace, 
			v );

		if ret ~= nil then 
			afterReplace = string.gsub(afterReplace,
				v, replaceStr);
			break;
		end 
	end

	if afterReplace == str then 
		return true, afterReplace;
	else 
		return false, afterReplace
	end 

end


--[[
	用户是否可用
]]
function BanWordsHelper:isStringPlayerCanUse(str, replaceStr)
	if IS_CLOSE_BAN_WORDS == true  then 
		return true, str
	end 

	local banWords = self.playerBanWords;

	if self.playerBanWords == nil then 
		echo("---error:BanWordsHelper没有初始化！！！");
		--掌趣有可能来个空list……
		if self.tempPlayerBanWords == nil then 
			self:setUpWithTempBanWord(BanWordsHelper.BanWordsType.PLAYER);
		end 

		if self.tempPlayerBanWords == nil then
			echo("--error:本地敏感词也没有"); 
			return true, str;
		else 
			echo("使用本地敏感词");
		end

		banWords = self.tempPlayerBanWords;
	end 


	local afterReplace = string.stripAndLower(str);
	local oldStr = afterReplace

	local replaceStr = replaceStr or "*"

	for _, v in ipairs(banWords) do
		--1, true, 原文匹配， 转义字符 (). % + - * ? [ ^ $  都不起作用
		local ret = string.find( afterReplace, 
			v, 1, true);

		if ret ~= nil then 
			afterReplace = string.gsub(afterReplace,
				v, replaceStr);

			echo("---包含敏感词为---", v);
			break
		end 
	end
	if afterReplace == oldStr then 
		return true, str;
	else 
		return false, afterReplace
	end 
end



--------============private function=============-------------


function BanWordsHelper:getGameBanWordFilePath()
	
	return self.dirInWritablePath .. "/" .. BanWordsHelper.fileName.GAME;
end

function BanWordsHelper:getPlayerBanWordFilePath()
	
	return self.dirInWritablePath .. "/" .. BanWordsHelper.fileName.PLAYER;
end

--[[
	更新本地banwords库
]]
-- function BanWordsHelper:updateGameBanWords()
-- 	local gameBanWordGetRequest = network.createHTTPRequest(c_func(self.onDownloadedGameBanWords, self), 
-- 		self.gameBanWordsUrl, "GET");
-- 	gameBanWordGetRequest:start()
-- end

-- function BanWordsHelper:updatePlayerBanWords()
-- 	local playerBanWordGetRequest = network.createHTTPRequest(c_func(self.onDownloadedplayerBanWords, self), 
-- 		BanWordsHelper.playerBanWordsUrl, "GET");
-- 	playerBanWordGetRequest:start()
-- end

--[[
	敏感词更新后的回调
]]
function BanWordsHelper:onDownloadedGameBanWords(message)
	local req = message.request;
	local messageName = message.name;

	if messageName == "failed" then 
		echo("----error:onDownloadedGameBanWords fail-----");

		--todo 告诉后端或是错误收集更新失败了 
		if self:isLocalGameBanWordExist() == false then 
			self:setUpWithTempBanWord(BanWordsHelper.BanWordsType.GAME);
		end 

		LS:pub():set(BanWordsHelper.gameBanWordUpdateFail, 
			BanWordsHelper.gameBanWordUpdateFail);

		return 
	end

	if messageName == "progress" then
		----说明请求在路上---
		return
	end

	if messageName == "completed" and statusCode == 200 then 
		local state = req:getState()
		local statusCode = req:getResponseStatusCode()
		local resString = req:getResponseString()
		local resJsonTable = json.decode(resString);
		local updateTime = resJsonTable.updateTime;
		local banWords = resJsonTable.keyList;
		local resetStr = resJsonTable.reset

		if tostring(resetStr) == "1000" then
			echo("---onDownloadedGameBanWords success!---");

			local filePath = self:getGameBanWordFilePath(); 
			--计入数据库更新版本号
			LS:pub():set(self.gameBanWordUpdateTimeKeyInLS, updateTime);
			
			--删除旧的文件
			-- FS.removeFile(filePath);

			self.gameBanWords = banWords;
			LS:pub():set(BanWordsHelper.gameBanWordUpdateFail, "default");
			
			--创建文件存储
			echo("-------filePath-----", filePath);
			local file = io.open(filePath, "w");
			local jsonStr = resString;

			file:write(jsonStr);
			file:close();

		else 
			--todo 告诉后端或是错误收集更新失败了
			echo("---onDownloadedGameBanWords error!----详细状态码", resetStr);

			if self:isLocalGameBanWordExist() == false then 
				self:setUpWithTempBanWord(BanWordsHelper.BanWordsType.GAME);
			end 
			--记录在本地，下次运行游戏继续更新
			LS:pub():set(BanWordsHelper.gameBanWordUpdateFail, 
				BanWordsHelper.gameBanWordUpdateFail);
		end 

	end 

	-- dump(message, "---onDownloadedGameBanWords---");
end

function BanWordsHelper:onDownloadedplayerBanWords(message)
local req = message.request;
	local messageName = message.name;

	if messageName == "failed" then 
		echo("----error:onDownloadedplayerBanWords fail-----");

		--todo 告诉后端或是错误收集更新失败了 
		if self:isLocalPlayerBanWordExist() == false then 
			self:setUpWithTempBanWord(BanWordsHelper.BanWordsType.PLAYER);
		end 

		LS:pub():set(BanWordsHelper.playerBanWordUpdateFail, 
			BanWordsHelper.playerBanWordUpdateFail);

		return 
	end

	if messageName == "progress" then
		----说明请求在路上---
		return
	end

	local state = req:getState()
	local statusCode = req:getResponseStatusCode()
	local resString = req:getResponseString()

	if messageName == "completed" and statusCode == 200 then 
		local resJsonTable = json.decode(resString);

		local updateTime = resJsonTable.updateTime;
		local banWords = resJsonTable.keyList;
		local resetStr = resJsonTable.reset

		if tostring(resetStr) == "1000" then
			echo("---onDownloadedGameBanWords success!---");

			local filePath = self:getPlayerBanWordFilePath(); 

			echo("-------filePath-----", filePath);

			--计入数据库更新版本号
			LS:pub():set(self.playerBanWordUpdateTimeKeyInLS, updateTime);
			
			--删除旧的文件
			-- FS.removeFile(filePath);

			self.playerBanWords = banWords;
			LS:pub():set(BanWordsHelper.playerBanWordUpdateFail, "default");
			
			--创建文件存储
			local file = io.open(filePath, "w");
			local jsonStr = resString;

			file:write(jsonStr);
			file:close();

		else 
			--todo 告诉后端或是错误收集更新失败了
			echo("---onDownloadedGameBanWords error!----详细状态码", resetStr);

			if self:isLocalPlayerBanWordExist() == false then 
				self:setUpWithTempBanWord(BanWordsHelper.BanWordsType.PLAYER);
			end 
			--记录在本地，下次运行游戏继续更新
			LS:pub():set(BanWordsHelper.playerBanWordUpdateFail, 
				BanWordsHelper.playerBanWordUpdateFail);
		end 

	end 
	
end

function BanWordsHelper:isLocalGameBanWordExist()
	local gameBanWordPath = self:getGameBanWordFilePath();

	return FS.exists(gameBanWordPath);
end

function BanWordsHelper:isLocalPlayerBanWordExist()
	local playerBanWordPath = self:getPlayerBanWordFilePath();

	return FS.exists(playerBanWordPath);
end

--[[
	内更或强更后，需要更新banWord
]]
function BanWordsHelper:isNeedToUpdatePlayerBanWords()
	local isPlayerBanExist = self:isLocalPlayerBanWordExist();

	local valueInLS = LS:pub():get(BanWordsHelper.gameBanWordUpdateFail, "defaultValue");
	local isLastUpdateFail = false;
	if valueInLS == BanWordsHelper.gameBanWordUpdateFail then 
		isLastUpdateFail = true;
	end 

	if isPlayerBanExist == false or isLastUpdateFail == true then 
		return true;
	else 
		return false;
	end 

end

function BanWordsHelper:isNeedToUpdateGameBanWords()
	local isGameBanExist = self:isLocalGameBanWordExist();

	local valueInLS = LS:pub():get(BanWordsHelper.playerBanWordUpdateFail, "defaultValue");
	local isLastUpdateFail = false;
	if valueInLS == BanWordsHelper.playerBanWordUpdateFail then 
		isLastUpdateFail = true;
	end 

	if isGameBanExist == false or isLastUpdateFail == true then 
		return true;
	else 
		return false;
	end 

end

--[[
	传输失败先用假的敏感词
	屏蔽字库使用config下的
]]
function BanWordsHelper:setUpWithTempBanWord(wordType)
	if BanWordsHelper.BanWordsType.GAME == wordType then 
		local fileUtil = cc.FileUtils:getInstance()
		local gameBanWordPath = fileUtil:fullPathForFilename("banWords/gameBanWord.txt")

		local gameBanStr = FS.readFileContent(gameBanWordPath);
		local tableInFile = json.decode(gameBanStr);
		self.tempGameBanWords = tableInFile.keyList;

	elseif BanWordsHelper.BanWordsType.PLAYER == wordType then 
		local fileUtil = cc.FileUtils:getInstance()
		local playerBanWordPath = fileUtil:fullPathForFilename("banWords/playerBanWord.txt")

		local playerBanStr = FS.readFileContent(playerBanWordPath);
		local tableInFile = json.decode(playerBanStr);

		self.tempPlayerBanWords = tableInFile.keyList;
	end 
end












