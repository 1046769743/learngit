--[[
	Author: 张燕广
	Date:2018-04-06
	Description: 分享服务工具类
]]

PCShareHelper = {}

local PLANTFORM_ANDROID = "android"
local PLANTFORM_IOS = "ios"

local javaPCCommHelperClsName = PCSdkHelper.javaPCCommHelperClsName
local ocPCCommHelperClsName = PCSdkHelper.ocPCCommHelperClsName

PCShareHelper.defaultAndroidSign = PCSdkHelper.defaultAndroidSign

PCShareHelper.EVENT_SHARE_SUCESS = "PCShareHelper.EVENT_SHARE_SUCESS"
PCShareHelper.EVENT_SHARE_FAIL = "PCShareHelper.EVENT_SHARE_FAIL"

-- 分享平台
PCShareHelper.SHARE_TYPE = {

	SceneQQ = 1,
	SceneQzone = 2,
	SceneWeChat = 3,
	SceneWeChatLine = 4,
	SceneSinaWeibo = 5	
}

-- 截图文件夹(固定名称,不可更改,与native保持一致)
local corpFileDir = "UserIcon"

-- playcrab/com.playcrab.xianpro.zq/share
-- local shareSaveDir = "share"

-- TODO:iOS分享如果图片过大，必须传一个缩略图才能成功，临时解决方案
local share_thumb_image_url = cc.FileUtils:getInstance():fullPathForFilename("static/a/a0_4.png")

function PCShareHelper:init()
	if device.platform == PLANTFORM_ANDROID then
	-- if true then
		local sharePath = self:getShareFilePath()
		echo("share-sharePath=",sharePath)
		cc.FileUtils:getInstance():setSaveFileDir(sharePath)
	end
end

--[[
	检查分享功能是否开启
]]
function PCShareHelper:checkIsOpen()
	if GameStatic and GameStatic:checkShareClosed() then
		return false
	end

	return true
end

-- 分享成功
function PCShareHelper:onShareSucess()
	-- TODO确定需求再决定怎么实现
	-- WindowControler:showTips("PCShareHelper-分享成功")
	echo("PCShareHelper-分享成功")
	EventControler:dispatchEvent(PCShareHelper.EVENT_SHARE_SUCESS)
	-- self:removeShareImageFile()
	ActivityServer:sharedSuccess()
end

-- 分享失败
function PCShareHelper:onShareFail()
	-- TODO确定需求再决定怎么实现
	-- WindowControler:showTips("PCShareHelper-分享失败")
	echo("PCShareHelper-分享失败")
	EventControler:dispatchEvent(PCShareHelper.EVENT_SHARE_FAIL)
	-- self:removeShareImageFile()
end

--[[
	分享文本
	shareType:分享平台，见PCShareHelper.SHARE_TYPE
	text:文本内容

	注意：
		1.QQ Android不支持纯文本分享/iOS支持纯文本分享
		2.不建议使用该接口，如果非要用，需要区分Android/iOS及是否分享到QQ等
]]
function PCShareHelper:shareText(shareType,text)
	local shareContentDict = {
		type = 1,
		shareType = shareType,
		text = text
	}
	self:share(shareContentDict)
end

--[[
	分享图片
	shareType:分享平台，见PCShareHelper.SHARE_TYPE
	imageUrl:图片url(本地文件全路径)
	thumbImage:缩略图url(本地文件全路径)，可选
	url:点击后打开的地址，可选
	text:文本，可选

	注意:iOS 
		1.imageUrl超过600KB,必须传thumbImageUrl
			,否则分享不成功(理论上仅微信需要传,但实际上QQ/WeiBo不传也会失败)
		2.thumbImageUrl最大不要超过32KB

]]
function PCShareHelper:shareImage(shareType,imageUrl,url,thumbImageUrl,text)
	if thumbImageUrl == nil and device.platform == PLANTFORM_IOS then
		thumbImageUrl = share_thumb_image_url
	end

	local shareContentDict = {
		type = 2,
		shareType = shareType,
		image_url = imageUrl,
		thumbImage = thumbImageUrl,
		text = text,
		url = url
	}

	-- QQ空间title不能为空
	if shareType  == PCShareHelper.SHARE_TYPE.SceneQzone then
		shareContentDict.title = "分享"
	end

	self.shareImagePath = imageUrl

	self:share(shareContentDict)
end

--[[
	分享链接
	shareType:分享平台，见PCShareHelper.SHARE_TYPE
	title:标题
	url:链接地址
	des:描述
	imageUrl:图片url(本地文件全路径),必选
			缩略图大小不能大于32K
			
	注意：QQ 按照链接方式分享， 打开的只能是应用宝。  
		按照图文，传个链接进去才能打开指定的链接
	
	iOS:
		imageUrl(带缩略图)，微信/朋友圈可用
	
]]
function PCShareHelper:shareUrl(shareType,title,url,des,imageUrl)
	local shareContentDict = {
		type = 3,
		shareType = shareType,
		title = title,
		url = url,
		des = des,
		image_url = imageUrl
	}
	self:share(shareContentDict)
end

function PCShareHelper:share(shareContentDict)
	local functionName = "share"
	echo("share shareContentDict=",json.encode(shareContentDict))

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {shareContentDict}, PCShareHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName ,shareContentDict)
	else
		WindowControler:showTips("pc平台模拟分享")
		self:onShareSucess()
	end
end

--[[
	截屏生成图片-Lua截图版本
]]
function PCShareHelper:captureScreenAndShareImageToFile(view,imageName,callBackFunc)
	local contentInfo = view.contentInfo
	-- dump(contentInfo,"contentInfo-----------")

	-- 截屏前保存信息，用于截屏后恢复
	local preAnchorPoint = view:getAnchorPoint()
	local prePos = cc.p(view:getPosition())
	local isVisible = view:isVisible()

	local width = contentInfo.width or GameVars.width
	local height = contentInfo.height or GameVars.height
	
	if width > GameVars.width then
		width = GameVars.width
	end

	if height > GameVars.height then
		height = GameVars.height
	end

	local offsetX = contentInfo.offsetX or 0
	local offsetY = contentInfo.offsetY or 0

	local extend = ".png"
	-- if device.platform == PLANTFORM_ANDROID then
	-- 	extend = ".png"
	-- end

	local normalImageName = imageName .. extend
	-- local compressImageName = imageName .. "_compress" .. extend

	-- 默认压缩质量
	local quality = 10

	-- 创建RenderTexture
	local renderTexture = cc.RenderTexture:create(width, height)
	renderTexture:setAnchorPoint(cc.p(0.5,0.5))

	local showWatermark = false
	local sprite = nil
	-- 加水印或二维码，暂时未用到
	if showWatermark then
		sprite = display.newSprite("icon/buff/battle_img_bfbaoji2.png")
		sprite:setScale(5)
		sprite:pos((width - 100),(height - 200))
		renderTexture:addChild(sprite)
	end

	-- 截屏前设置位置信息
	view:pos(offsetX,offsetY)
	view:anchor(0,0)

	renderTexture:begin()
	view:visit()
	if showWatermark and sprite then
		sprite:visit()
	end
	renderTexture:endToLua()
	renderTexture:getSprite():getTexture():setAntiAliasTexParameters()

	local path = PCShareHelper:getShareFilePath()

	local normalImageName = imageName .. extend
	-- local compressImageName = imageName .. "_compress" .. extend

	if renderTexture.setSaveQuality then
		-- Android压缩图片
		renderTexture:setSaveQuality(10)
	end
	renderTexture:saveToFile(normalImageName)

	-- 延迟做回调
	WindowControler:globalDelayCall(function()
		local filePath = path .. normalImageName
		echo("ourpalm share path=",filePath)
		-- if cc.FileUtils:getInstance():isFileExist(filePath) then
		if self:isShareFileExist(filePath) then
			echo("share 文件存在=",filePath)
			if callBackFunc then
				callBackFunc(filePath)
			end
		else
			WindowControler:showTips("分享失败,请在应用设置里允许游戏读写手机存储")
			echo("ourpalm share 不存在")
		end
	end, 5 / GameVars.GAMEFRAMERATE)

	-- 恢复属性
	view:setAnchorPoint(preAnchorPoint)
	view:setPosition(prePos)
	view:setVisible(isVisible)
end

function PCShareHelper:isShareFileExist(filePath)
	if not filePath or filePath == "" then
		return false
	end

	if device.platform == PLANTFORM_ANDROID then
		return PCSdkHelper:isFileExist(filePath)
	else
		return cc.FileUtils:getInstance():isFileExist(filePath)
	end
end

--[[
	获取截屏文件存储路径
]]
function PCShareHelper:getShareFilePath()
	local sharePath = nil
	-- /sdcard/playcrab/com.playcrab.xianpro.zq
	if device.platform == PLANTFORM_ANDROID then
		local targetSdkVersion = PCSdkHelper:getTargetSdkVersion()
		echo("share targetSdkVersion=",targetSdkVersion)
		-- if targetSdkVersion == "26" then
		if true then
			local sdcardRootPath = PCSdkHelper:getSdcardRootPath()
			local packageName = PCSdkHelper:getPackageName()
			if packageName then
				packageName = packageName .. "/"
			else
				packageName = ""
			end
			-- sharePath = sdcardRootPath  .. "/playcrab/" .. packageName
			sharePath = sdcardRootPath  .. "/" .. packageName
		else
			sharePath = cc.FileUtils:getInstance():getWritablePath()
		end
	else
		sharePath = cc.FileUtils:getInstance():getWritablePath()
	end

	return sharePath
end

--[[
	截屏生成图片-C++截图版本
	目前使用的是Lua版
]]
function PCShareHelper:captureScreenAndShareImageToFile_CPP(view,imageName,callBackFunc)
	local contentInfo = view.contentInfo
	dump(contentInfo,"contentInfo-----------")

	local width = contentInfo.width or GameVars.width
	local height = contentInfo.height or GameVars.height

	if width > GameVars.width then
		width = GameVars.width
	end

	if height > GameVars.height then
		height = GameVars.height
	end

	local offsetX = contentInfo.offsetX or 0
	local offsetY = contentInfo.offsetY or 0

	local extend = ".png"
	-- if device.platform == PLANTFORM_ANDROID then
	-- 	extend = ".png"
	-- end

	local normalImageName = imageName .. extend
	-- local compressImageName = imageName .. "_compress" .. extend

	local quality = 10
	-- 截图
	AppHelper:captureScreenToFile(view,width,height,offsetX,offsetY,normalImageName,quality)

	local path = cc.FileUtils:getInstance():getWritablePath()

	if device.platform == PLANTFORM_IOS then
		WindowControler:globalDelayCall(function()
			local filePath = path .. normalImageName
			-- iOS压缩图片
			-- self:compressJpg(path .. normalImageName, filePath, 10)
			if cc.FileUtils:getInstance():isFileExist(filePath) then
				-- 延迟做回调
				WindowControler:globalDelayCall(function()
					if callBackFunc then
						callBackFunc(filePath)
					end
				end, 5 / GameVars.GAMEFRAMERATE)
			end
		end, 5/GameVars.GAMEFRAMERATE )
	else
		-- 延迟做回调
		WindowControler:globalDelayCall(function()
			local filePath = path .. normalImageName
			echo("ourpalm share path=",filePath)
			if cc.FileUtils:getInstance():isFileExist(filePath) then
				if callBackFunc then
					callBackFunc(filePath)
				end
			else
				echo("ourpalm share 不存在")
			end
		end, 5 / GameVars.GAMEFRAMERATE)
	end
end

--[[
	Test测试截屏
]]
function PCShareHelper:captureScreen2()
	local callBack = function()

	end

	local writablePath = cc.FileUtils:getInstance():getWritablePath()
	local filepath = writablePath .. "/test.png"

	display.captureScreen(callBack,filepath)
end

--[[
	当截屏成功
]]
function PCShareHelper:onCorpImageSuccess(data)
	local fileFullPath = nil
	if device.platform == PLANTFORM_IOS then
		local writablePath = cc.FileUtils:getInstance():getWritablePath()
		local filepath = data.filepath
		fileFullPath = string.format("%s%s/%s",writablePath,corpFileDir,filepath)
	elseif device.platform == PLANTFORM_ANDROID then
		local filepath = data.filepath
		local ur = data.url
		fileFullPath = data.fileFullPath
		
		echo("corp-filepath=",filepath)
		echo("corp-ur=",ur)
	end

	echo("fileFullPath=",fileFullPath)

	WindowControler:showTips("截屏成功")
end

--[[
	当截屏失败
]]
function PCShareHelper:onCorpImageFail()
	echo("share-截屏失败")
end

--[[
	截取图片(相机或相册作为输入源)
	fileName:文件名称
]]
function PCShareHelper:corpImage(filename)
	local functionName = "corpImage"
	local params = {
		filepath = filename
	}
	if device.platform == PLANTFORM_ANDROID then
		echo("share corpImage,filename=",filename)
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCShareHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName ,params)
	else
		WindowControler:showTips("pc平台不支持截屏功能")
	end
end

--[[
	压缩图片,仅支持iOS
]]
function PCShareHelper:compressJpg(normalImageName,compressImageName,quality)
	local functionName = "compressJpg"
	local params = {
		path = normalImageName,
		dstPath =  compressImageName,
		quality = tostring(quality)
	}
	if device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName ,params)
	else
		WindowControler:showTips("该功能不支持当前平台")
	end
end

function PCShareHelper:removeShareImageFile()
	if self.shareImagePath then
		cc.FileUtils:getInstance():removeFile(self.shareImagePath)
		self.shareImagePath = nil
	end
end

function PCShareHelper:testShareAPI()
	local fileUtil = cc.FileUtils:getInstance()
    -- "asset/icon/food/food_img_babaofan.png"
    local img = nil
    img = "asset/icon/food/food_img_babaofan.png"
    img = "asset/bg/arena_bg_duizhan.png"
    
    img = "asset/bg/guild_bg_tqd.png"
    -- img = "asset/bg/activity_bg_lyr.png"

    img = "asset/icon/food/food_img_lajiao.png"
    img = "asset/test/share_test.png"
    
    local imgurl = fileUtil:fullPathForFilename(img)

    echo("imgurl=",imgurl)

    local isExist = cc.FileUtils:getInstance():isFileExist(imgurl)
	echo("share isExist=",isExist)

    local thumbImageUrl = fileUtil:fullPathForFilename("asset/icon/cimelia/cimeliaIcon_beimingxuanzhu.png")
    
    -- iOS测试
    -- SceneSinaWeibo 	ok 
    -- SceneWeChat  	ok
    -- SceneWeChatLine 
    -- SceneQQ          ok
    -- SceneQzone		ok

    -- 微信ok
    -- PCShareHelper:shareText(PCShareHelper.SHARE_TYPE.SceneWeChat,"仙剑测试文本分享")
    PCShareHelper:shareImage(PCShareHelper.SHARE_TYPE.SceneSinaWeibo,imgurl,nil,thumbImageUrl)
    
    -- PCShareHelper:shareUrl(PCShareHelper.SHARE_TYPE.SceneWeChatLine,"分享标题"
    --     ,"http://www.qq.com/","分享描述",thumbImageUrl)

    -- qq
    -- PCShareHelper:shareImage(PCShareHelper.SHARE_TYPE.SceneQQ,imgurl)
    -- PCShareHelper:shareUrl(PCShareHelper.SHARE_TYPE.SceneQzone,"仙剑分享标题"
    --     ,"http://www.qq.com/","仙剑分享描述",thumbImageUrl)
end

--[[
	截屏、压缩、分享测试
]]
function PCShareHelper:testShare(testView,width,height)
	WindowControler:showTips("testShare")
	width = width or 500
	height = height or 500

    local view = testView
    local fileName = "zygtest-1"
        
    -- 图片分享
    local callback = function(filepath)
        local rt = cc.FileUtils:getInstance():isFileExist(filepath)
        echo("ourpalm share rt=====",rt,"filepath=",filepath)
        -- PCShareHelper:shareImage(PCShareHelper.SHARE_TYPE.SceneWeChat,filepath,filepath,"图片分享")
        -- android
        PCShareHelper:shareImage(PCShareHelper.SHARE_TYPE.SceneWeChatLine,filepath)
    end

    PCShareHelper:captureScreenAndShareImageToFile(view,width,height,fileName,c_func(callback))
end

function PCShareHelper:testShare2()
	local view = WindowControler:getWindow("WorldMainView")
	WindowControler:showTips("testShare2")
	-- test3 case
    local writablePath = cc.FileUtils:getInstance():getWritablePath()
    local imgName = "test10"
    

    local filepath = writablePath .. imgName
    -- PCShareHelper:shareImage(PCShareHelper.SHARE_TYPE.SceneWeChatLine,filepath)
    local callback = function()
    	echo("filepath=",filepath)
        local rt = cc.FileUtils:getInstance():isFileExist(filepath)
        PCShareHelper:shareImage(PCShareHelper.SHARE_TYPE.SceneWeChatLine,filepath)
    end

    -- WindowControler:globalDelayCall(c_func(callback), 5/30)
    PCShareHelper:captureScreenAndShareImageToFile(view,300,200,imgName,c_func(callback))
end

return PCShareHelper
