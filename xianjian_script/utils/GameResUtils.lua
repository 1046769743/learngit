GameResUtils = GameResUtils or {}

function GameResUtils:loadTexture(plistFile, texFile)
	local plistExist = cc.FileUtils:getInstance():isFileExist(plistFile)
	local texExist = cc.FileUtils:getInstance():isFileExist(texFile)
	if plistExist and texExist then
		display.addSpriteFrames(plistFile, texFile)
	else
		echo("plist or texture file not exist:", plistFile, texFile)
	end
end
