local ServerErrorTipControler = {}

ServerErrorTipControler.error_tips = require("game.sys.data.ServerErrorTips")

function ServerErrorTipControler:checkShowTipByError(errorData)
	local message = FuncTranslate.getServerErrorMessage(errorData)
	WindowControler:showTips(message)
	return message
end


return ServerErrorTipControler
