--
-- Author: XD
-- Date: 2014-01-11 16:47:35
--

local packageName = "utils."

if not DEBUG_SERVICES then
	sqlite =require(packageName.."sqlite")
	storage = require(packageName.."storage")
	storagechat = require(packageName.."storagechat")
	act =require(packageName.."act")

	FS =require(packageName.."FS")
	LS =require(packageName.."LS")
	LSChat =require(packageName.."LSChat")
	--require("tools.AnimateTools")
	require(packageName.."shortapi")
	require(packageName.."component.init")
	require(packageName.."ColorMatrixFilterPlugin")
	require(packageName.."FilterTools")
	require(packageName.."IOSDeviceHelper")
	require(packageName.."PCSdkHelper")
	require(packageName.."VoiceSdkHelper")
	require(packageName.."ScreenAdapterTools")
	require(packageName.."PushHelper")
	require(packageName.."PCLBSHelper")
	require(packageName.."PCShareHelper")
	require(packageName.."PCLogHelper")
	require(packageName.."PCChargeHelper")
	html = require(packageName..'html')
	require(packageName.."PCHtmlHelper")
end

require(packageName..'GameResUtils')
require(packageName..'GameLuaLoader')
require(packageName.."table")
require(packageName.."string")
require(packageName.."Functions")

require(packageName.."Equation")
require(packageName.."EventEx")
require(packageName.."Tool")

require(packageName.."numEncrypt")

require(packageName.."number")
require(packageName.."Cache")
require(packageName.."BanWordsHelper")

require(packageName.."FakeServerDataHelper")


require(packageName..'PrologueUtils')
require(packageName..'UniqueIdCreater')
require(packageName..'PosMapTools')



