ViewFlashActor = class("ViewFlashActor", function ( )
	return display.sp()
end)

--初始化传入一个 viewId 进来  然后通过id 取 view素材
--ctn 传入的 容器 
ViewFlashActor.aniObj = nil

ViewFlashActor.currentAni = nil    --当前播放的动画

function ViewFlashActor:ctor(name,actions)

    self.aniObj = {}
    --初始化所有动作
    local ani
    if actions then
         for i,v in pairs(actions) do
            ani = PCComponentLibrary:createMovieClip(i.."_"..name)
            ani:addto(self):visible(false):stop()
            self.aniObj[i] = ani
            if not self.currentAni then
                self.currentAni = ani
            end
        end
    else
        ani = PCComponentLibrary:createMovieClip(name)
        self.aniObj[name] = ani
        ani:addto(self):play()
        self.currentAni = ani
    end
    if not self.currentAni then
        dump(actions,name)
        error("没有获取到 动画")
    end
end

function ViewFlashActor:play( )
    self.currentAni:play()
end

function ViewFlashActor:stop(  )
    self.currentAni:stop()
end

--设置播放速度 因为这个view是自动播放的 所以 这个不一样
function ViewFlashActor:setPlaySpeed(speed  )
    speed = speed  or 1.0
    for k,v in pairs(self.aniObj) do
        v:setPlaySpeed(speed)
    end
end


function ViewFlashActor:gotoAndPlay( frame )
    frame = frame or 0
    self.currentAni:gotoAndPlay(frame)
end

function ViewFlashActor:gotoAndStop(frame)
    self.currentAni:gotoAndStop(frame)
end

function ViewFlashActor:updateFrame(dt)
    
end

--播放某个动画
function ViewFlashActor:playLabel( labelName )

    if self.currentAni then
        self.currentAni:stop()
        self.currentAni:visible(false)
    end

    self.currentAni = self.aniObj[labelName]
    if not self.currentAni then
        error("not labelName:"..tostring(labelName))
    end
    self.currentAni:visible(true)
    --从第0帧开始播放
    self.currentAni:gotoAndPlay(0)

    -- for i,v in pairs(self.aniObj) do
    --     if i == labelName then
    --         self.currentAni =v
    --         self.currentAni:visible(true)
    --         --从第0帧开始播放
    --         self.currentAni:gotoAndPlay(0)
    --     else
    --         v:visible(false)
    --     end
    -- end

end

--获取某个标签的帧长度
function ViewFlashActor:getLabelFrames( label )
    local ani = self.currentAni
    if  label then
        ani = self.aniObj[label]
    end
    return ani:getTotalFrames()
end


--让某个动画停止在最后一针 是因为 如果逻辑卡或者游戏卡了 那么就会出现动画不一致的问题
function ViewFlashActor:stopToLastFrame( )
    if not self.currentAni then
        return
    end
    local mcEnd = function()
        self.currentAni:stop()
        self.currentAni:cleanLuaCallBack()
    end
    self.currentAni:setLuaEndCallback(0,mcEnd)

end




return ViewFlashActor


