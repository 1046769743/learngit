
--  User: cjh
--  Date: 2015/7/24
--  跟新版本界面

local VerView = class("VerView", UIBase)

function VerView:ctor(winName)
    VerView.super.ctor(self,winName)

    self.LN = {
		[1]="检查数据，请稍候...",
		[2]="数据载入中",
		[3]="数据更新，请稍候...",
		[4]="网络错误",
		[5]="当前网络连接出错，请重试！",
		[7]="更新",
		[9]="下载资源中，请稍候...",
		[10]="已下载资源",
		[11]="下载资源完成",
		[12]="解压资源中，请稍候...",
		[13]="已解压资源",
		[14]="解压资源完成",
		[15]="正在更新版本，请稍候...",
		[16]="下载失败,请检查您的网络",
		[17]="安装失败，正在准备重新下载",
	}

    self.targetVer = "1.0.0"
    self.serverDlList = {
        [1] = {
            patch = "1.0.0/res/a/cocoslogo1.png",
            save = "res/a/cocoslogo1.png",
            md5 = "12345678901234567890123456789012",
            size = "5301",
            type = "res",
            plat = "qqandroid",
            svn = "100",
            version = "1.1.0",
            version_code = "10100",
        },
        [2] = {
            patch = "1.0.0/res/a/cocoslogo2.png",
            save = "res/a/cocoslogo2.png",
            md5 = "12345678901234567890123456789012",
            size = "16467",
            type = "res",
            plat = "qqandroid",
            svn = "100",
            version = "1.1.0",
            version_code = "10100",
        },
        [3] = {
            patch = "1.0.0/res/a/OA.png",
            save = "res/a/OA.png",
            md5 = "12345678901234567890123456789012",
            size = "27439",
            type = "res",
            plat = "qqandroid",
            svn = "100",
            version = "1.1.0",
            version_code = "10100",
        },
        [4] = {
            patch = "1.0.0/res/a/Ordering.png",
            save = "res/a/Ordering.png",
            md5 = "12345678901234567890123456789012",
            size = "24439",
            type = "res",
            plat = "qqandroid",
            svn = "100",
            version = "1.1.0",
            version_code = "10100",
        },
        [5] = {
            patch = "1.0.0/res/a/Outlook.png",
            save = "res/a/Outlook.png",
            md5 = "12345678901234567890123456789012",
            size = "25944",
            type = "res",
            plat = "qqandroid",
            svn = "100",
            version = "1.1.0",
            version_code = "10100",
        },
        [6] = {
            patch = "1.0.0/res/a/Tower.png",
            save = "res/a/Tower.png",
            md5 = "12345678901234567890123456789012",
            size = "24005",
            type = "res",
            plat = "qqandroid",
            svn = "100",
            version = "1.1.0",
            version_code = "10100",
        },
    }
end

function VerView:loadUIComplete()
    VerView.super.loadUIComplete(self)
    
    
end

-- UI显示完毕
function VerView:showComplete()
	-- 注册事件
	self:registerEvent()
	
	
	
	self:updateView()
end

-- 注册事件
function VerView:registerEvent()

end

-- 更新界面
function VerView:updateView()
	self:updateVer(self.targetVer, self.serverDlList)
end

--[[
--targetVer 目标版本号
--fileList   服务器返回的要下载的文件列表
 ]]
function VerView:updateVer(targetVer,serverDlList)
	if empty(serverDlList) then
        serverDlList = {}
    end
    --下载回调函数
    local function verListener(msg)
        local progress = self.panel_dengji.mc_jingyan
        progress.currentView.progress_jingyan:setDirection(0)
        local descLabel = self.txt_sz

        local name = msg.name
        if(name=="start") then
            descLabel:setString(self.LN[3])
            progress.currentView.progress_jingyan:setPercent(0*100/0)
        elseif(name=="downloadStart") then
            descLabel:setString(self.LN[9])
            progress.currentView.progress_jingyan:setPercent(0*100/0)
        elseif(name=="downloading") then
            descLabel:setString(self.LN[10]..fmtBytes(msg.size).."/"..fmtBytes(self.totalDownloadSize))
            progress.currentView.progress_jingyan:setPercent(100*msg.size/self.totalDownloadSize)
        elseif(name=="downloadSuccess") then
            descLabel:setString(self.LN[11])
            progress:showFrame(2)
        elseif(name=="installStart") then
            descLabel:setString(self.LN[12])
            progress.currentView.progress_jingyan:setPercent(0*100/0)
        elseif(name=="installing") then
            descLabel:setString(self.LN[13]..toint(msg.installs*100/self.totalInstalls).."%")
            progress.currentView.progress_jingyan:setPercent(100*msg.installs/self.totalInstalls)
        elseif(name=="installSuccess") then
            descLabel:setString(self.LN[14])
            progress:showFrame(2)
        elseif(name=="success") then
            progress:showFrame(2)
            --self:updateSuccess()
        elseif(name=="downloadFail") then
            descLabel:setString(self.LN[16])
        elseif(name=="installFail") then
            descLabel:setString(self.LN[17])
        elseif(name=="fail") then
            -- self:delayCall(c_func(self.updateFail,self), 3)
        end
    end
    VerControler:init(targetVer,serverDlList,verListener)
    self.totalDownloadFiles,self.totalDownloadSize = VerControler:getTotalDownloads()
    self.totalInstalls = VerControler:getTotalInstalls()
    if self.totalDownloadFiles == 0 and self.totalInstalls == 0 then
        --echo("__________________enterGameMain---by 222222222222222")
        --self:enterGameMain()
        return
    end
    -- if self.totalDownloadSize>100*1024 then
    --     echo(self.totalDownloadSize)
    --     echo("self.totalDownloadSize>100*1024")
    --     --Mgr.showUpdateVerAlert(self.totalDownloadSize,c_func(self.doUpdateClick,self))
    -- else
        self:updateStart()
    -- end
end

--更新开始
function VerView:updateStart()
    VerControler:start()
end



return VerView