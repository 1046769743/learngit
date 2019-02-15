local ShareBossControler = ShareBossControler or {}


function ShareBossControler:enterShareBossMainView()
     ShareBossServer:getShareBossList(c_func(self.showShareBossMainView, self))
end

function ShareBossControler:showShareBossMainView(event)
    if event.error then
        echo("没有拉取到共享副本的数据")
    else
        ShareBossModel:updateData(event.result.data)
        ShareBossModel:setNeedFindMaxStar(true)
        WindowControler:showWindow("ShareBossNewMainView")
    end    
end

return ShareBossControler