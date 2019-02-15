FuncRes=FuncRes or {}


--目前动画材质的类型 配备为 png
FuncRes.armatureTextType = "png"
-- FuncRes.armatureTextType = "pvr.ccz"

-- 目前动画配置文件的类型
-- FuncRes.armatureFileType = "xml"
FuncRes.armatureFileType = "bobj"

FuncRes.pngSuffix = ".png"
--获取NPC图标和相关的对话内容
function        FuncRes.getNpcIconDialog(_id)
         return      FuncCommon.getNpcIconDialog(_id);
end
--获取某个map名称
function FuncRes.map(image )
	return "map/"..image
end

--获取某个icon路径
function FuncRes.icon( image )
	return "icon/"..image
end

--[[
获取boss多血条图片
]]
function FuncRes.iconBar( image )
    return "icon/bar/"..image
end

function FuncRes.iconBattle( image )
    local basePath = "icon/battle/"
    local tempIcon = basePath .. "battle_qiu.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

function FuncRes.iconHandbook( image )
    local basePath = "icon/handbook/"
    local tempIcon = basePath .. "handbook_img_fangshu.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--创建纯黑背景
function FuncRes.a_black( wid,hei,alpha )
    alpha = alpha or 255
    local sp = display.newSprite("a/a2_4.png",0,0)

    local scaleX=wid and wid/4 or 1
    local scaleY = hei and hei/4 or 1
    sp:setOpacity(alpha)
    sp:setScaleX(scaleX)
    sp:setScaleY(scaleY)
    return sp
end

--创建纯白背景
function FuncRes.a_white( wid,hei,alpha)
    alpha = alpha or 255
    local sp = display.newSprite("a/a1_4.png")
    sp:opacity(alpha)
    local scaleX=wid and wid/4 or 1
    local scaleY = hei and hei/4 or 1

    sp:setScaleX(scaleX)
    sp:setScaleY(scaleY)
    return sp
end

function FuncRes.a_alpha( wid,hei)
    --用空node 代替alpha 效率更高
    local nd = display.newNode()
    nd:setContentSize(wid,hei)
    nd:anchor(0.5,0.5)
    return nd

    -- local sp = display.newSprite("a/a0_4.png")
    -- local scaleX=wid and wid/4 or 1
    -- local scaleY = hei and hei/4 or 1
    -- sp:setScaleX(scaleX)
    -- sp:setScaleY(scaleY)

    -- return sp
end

--拿对应的icon buffword路径
function FuncRes.iconBuffword( frame,kind,isRandom )
    local spName= "icon/buffword/buffword_".. frame .."_"..kind..".png"
    local randomName
    local targetSp = display.newSprite(spName)
    if isRandom then
        randomName = "icon/buffword/buffword_gailv_".. kind..".png"
        local ranSp =  display.newSprite(randomName)
        local targetNode = display.newNode ()
        targetSp:addto(targetNode)
        ranSp:addto(targetNode)
        local size1 = targetSp:getContentSize().width - 14
        local size2 = ranSp:getContentSize().width - 18
        local halfWid1 = size1/2
        local halfWid2 = size2/2
        targetSp:pos( halfWid2,0)
        ranSp:pos( -  halfWid1,0)

        return  targetNode
    else
        return targetSp
    end

    return spName
end
    
-- 获取资源icon  
function FuncRes.iconRes(resType,resId)
    if resType == nil or resType == "" then
        echo("FuncRes.iconRes not found resType=",resType,resId)
        return nil
    end

    local basePath = "icon/res/"

    local iconPath = nil
    local rType = tostring(resType)
    if rType == FuncDataResource.RES_TYPE.ITEM then
        local itemId = resId

        if ItemsModel:isTreasurePiece(resType, itemId) == true then 
            iconPath = FuncRes.iconTreasure(itemId);
        elseif ItemsModel:isPartnerPiece(resType, itemId) == true then
            iconPath = FuncRes.partnerIcon(itemId);
        elseif ItemsModel:isEquipmentPiece(resType, itemId) then
            iconPath = FuncRes.iconPartnerEquipment(FuncItem.getIconPathById(itemId))
        else 
            iconPath = FuncRes.iconItem(itemId)
        end 

    elseif rType == UserModel.RES_TYPE.TREASURE then
        local treasureId = resId
        iconPath = FuncRes.iconTreasure(treasureId)
    else
        iconPath = FuncDataResource.getIconPathById(resType)
        if iconPath == nil or iconPath == "" then
            iconPath = basePath .. "ResIconTemp.png"
        else
            iconPath = basePath .. iconPath
        end
    end

    return iconPath
end

function FuncRes.getIconResByName(name)
    local basePath = "icon/res/"
    local tempIcon = basePath .. "ResIconTemp.png"
    local imagePath = FuncRes.getImagePath(basePath, name,tempIcon)
    return imagePath
end

--时装立绘
function FuncRes.artGarment(name)
    local basePath = "icon/garmentArt/"
    local tempIcon = basePath .. "garment_icon_temp.png"

    local imagePath = FuncRes.getImagePath(basePath, name,tempIcon)
    return imagePath
end
function FuncRes.getUserIcon(icon,avatar)
    if icon == "" or not icon or icon == "0" then
        if avatar == "101" then
            return "icon/headicon/".."manHead_101" ..".png"
        else
            return "icon/headicon/".."womHead_101" ..".png"
        end
    else
        return icon
    end
    
end
--时装icon
function FuncRes.iconGarment(name)
    local basePath = "icon/garmentIcon/"
    local tempIcon = basePath .. "garment_icon_temp.png"

    local imagePath = FuncRes.getImagePath(basePath, name,tempIcon)
    return imagePath
end
--充值icon
function FuncRes.iconRecharge(name)
    local basePath = "icon/monthCard/"
    local tempIcon = basePath .. "food_img_zhurou.png"

    local imagePath = FuncRes.getImagePath(basePath, name,tempIcon)
    return imagePath
end
-- 月卡背景
function FuncRes.iconMonthCardBg(name)
    local basePath = "icon/monthCard/"
    local tempIcon = basePath .. "monthcard_img_lingshi.png"

    local imagePath = FuncRes.getImagePath(basePath, name,tempIcon)
    return imagePath
end

--quest图标
function FuncRes.iconQuest(name)
    local basePath = "icon/quest/"
    local tempIcon = basePath .. "quest_4_1.png"   ---默认用带剑的

    local imagePath = FuncRes.getImagePath(basePath, name,tempIcon)
    return imagePath
end

-- 签到中签背景
function FuncRes.bgNewSign( name )
    local basePath = "icon/sign/"
    local tempIcon = basePath .. "sign_bg_pingqian.png"

    local imagePath = FuncRes.getImagePath(basePath, name,tempIcon)
    return imagePath
end

-- 六界地标的图标
function FuncRes.iconWorldSpace(name)
    local basePath = "icon/space/"
    local tempIcon = basePath .. "temp.png"

    local imagePath = FuncRes.getImagePath(basePath,name,tempIcon)
    return imagePath
end

-- 六界地图山体
function FuncRes.iconWorldMontain(name)
    local basePath = "icon/world/mapMountain/"
    local tempIcon = basePath .. "temp.png"

    local imagePath = FuncRes.getImagePath(basePath,name,tempIcon)
    return imagePath
end

-- 六界神界山体
function FuncRes.iconGodMontain(name)
    local basePath = "icon/world/godMountain/"
    local tempIcon = basePath .. "temp.png"

    local imagePath = FuncRes.getImagePath(basePath,name,tempIcon)
    return imagePath
end

-- 六界神界地图
function FuncRes.iconGodMap()
    local imagePath = "icon/world/godMap/sky.png"
    return imagePath
end

-- 锁妖塔格子图标
function FuncRes.iconTowerGrid(color)
    local basePath = "icon/towerMap/"
    local name = "grid_" .. color
    local tempIcon = basePath .. "temp.png"

    local imagePath = FuncRes.getImagePath(basePath,name,tempIcon)
    return imagePath
end

-- 锁妖塔事件图标
function FuncRes.iconTowerEvent(image)
    local basePath = "icon/tower/"
    local tempIcon = basePath .. "OtherTemp.png"
    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

-- 小游戏icon
function FuncRes.iconGame(image)
    local basePath = "icon/game/"
    local tempIcon = basePath .. "OtherTemp.png"
    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

-- 精英副本图标
function FuncRes.iconElite(image)
    local basePath = "icon/elite/"
    local tempIcon = basePath .. "OtherTemp.png"
    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end


-- pve图标
function FuncRes.iconPVE(bgName)
    local basePath = "icon/pve/"
    local tempIcon = basePath .. "temp.png"

    local imagePath = FuncRes.getImagePath(basePath,bgName,tempIcon)
    return imagePath
end

-- 获取六界瓦块地图
function FuncRes.getWorldMapImagePath(tileName)
    local imagePath = "world/" .. tileName .. ".png"
    return imagePath
end

-- buff图标
function FuncRes.iconBuff(image)
    local basePath = "icon/buff/"
    local tempIcon = basePath .. "temp.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--获取途径icon 
function FuncRes.iconWay( image )
    local basePath = "icon/way/"
    local tempIcon = basePath .. "WayIconTemp.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--获取bar 
function FuncRes.bar( image )
    local basePath = "icon/bar/"
    local tempIcon = basePath .. "BarIconTemp.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--英雄图标
function FuncRes.iconHero( image )
    local basePath = "icon/head/"
    local tempIcon = basePath .. "HeadIconTemp.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end
-- 奇侠唤醒
function FuncRes.iconQixiaAwaken( image )
    local basePath = "icon/partnerAwaken/"
    local tempIcon = basePath .. "partnerawaken_txt_liyiru.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--法宝
function FuncRes.iconTreasure( treasureId )
    local basePath = "icon/treasure/"
    local tempIcon = basePath .. "TreasureIconTemp.png"
    
    echo("\n\n_treasureId===", treasureId)
    local iconName = FuncTreasure.getIconPathById(treasureId)
    local imagePath = FuncRes.getImagePath(basePath,iconName,tempIcon)
    return imagePath
end

-- 新法宝
function FuncRes.iconTreasureNew( treasureId )
    local basePath = "icon/treasure/"
    local tempIcon = basePath .. "TreasureIconTemp.png"
    
    local iconName = FuncTreasureNew.getTreasureDataByKeyID(treasureId,"icon")
    local imagePath = FuncRes.getImagePath(basePath,iconName,tempIcon)
    return imagePath
end
-- 新法宝 名称
function FuncRes.NameTreasureNew( treasureId )
    local basePath = "icon/treasure/"
    local tempIcon = basePath .. "TreasureIconTemp.png"
    
    local iconName = FuncTreasureNew.getTreasureDataByKeyID(treasureId,"nameImage")
    local imagePath = FuncRes.getImagePath(basePath,iconName,tempIcon)
    return imagePath
end
--那女猪脚半身像 1:男,2:nv
function FuncRes.iconChar( sex )
    local basePath = "icon/char/"
    local tempIcon = basePath .. "char_nv.png"
    
    local iconName = "char_nv.png";

    if sex == 1 then 
        iconName = "char_nan.png";
    end 

    local imagePath = FuncRes.getImagePath(basePath, iconName, tempIcon)
    return imagePath
end

--巅峰竞技场的段位icon
function FuncRes.crossSegmentIcon( iconName )
    local basePath = "icon/crosspeak/"
    local tempIcon = basePath .. "crosspeak_img_zhang01.png"
    local imagePath = FuncRes.getImagePath(basePath,iconName,tempIcon)
    return imagePath
end
function FuncRes.crossBoxIcon( iconName )
    local basePath = "icon/crosspeak/"
    local tempIcon = basePath .. "crosspeak_img_zhang01.png"
    local imagePath = FuncRes.getImagePath(basePath,iconName,tempIcon)
    return imagePath
end

--情景卡 背景
function FuncRes.memoryCardIcon( iconName )
    local basePath = "bg/"
    local tempIcon = basePath .. "memory_bg_xxwq1.png"
    local imagePath = FuncRes.getImagePath(basePath,iconName,tempIcon)
    return imagePath 
end
function FuncRes.memoryCardZhezhaoIcon( iconName )
    local basePath = "icon/memory/"
    local tempIcon = basePath .. "1.png"
    local imagePath = FuncRes.getImagePath(basePath,iconName,tempIcon)
    return imagePath 
end


--敌人法宝
function FuncRes.iconEnemyTreasure( image )
    local basePath = "icon/treasure/"
    local tempIcon = basePath .. "TreasureIconTemp.png"
    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--//本命法宝,天赋,输入的是天赋法宝的图标名字
function FuncRes.iconTalent( _iconName)
    local basePath = "icon/treasure/"
    local tempIcon = basePath .. "TreasureIconTemp.png"
    
    local imagePath = FuncRes.getImagePath(basePath,_iconName,tempIcon)
    return imagePath
end
-- item图标
function FuncRes.iconItem(itemId)
    local basePath = "icon/item/"
    local tempIcon = basePath .. "ItemIconTemp.png"

    local iconName = FuncItem.getIconPathById(itemId)
    local imagePath = FuncRes.getImagePath(basePath,iconName,nil,true)

    -- todo 临时方案 by ZhangYanguang
    -- 伙伴碎片icon在head目录下
    if imagePath == nil then
        imagePath = FuncRes.iconHead(iconName)
    end

    return imagePath
end

-- item图标
function FuncRes.iconItemWithImage(image)
    local basePath = "icon/item/"
    local tempIcon = basePath .. "ItemIconTemp.png"

    local imagePath = FuncRes.getImagePath(basePath, image, tempIcon);
    return imagePath
end
-- 伙伴装备图标
function FuncRes.iconPartnerEquipment(image)
    local basePath = "icon/equipment/"
    local tempIcon = basePath .. "img_Icon4022.png"

    local imagePath = FuncRes.getImagePath(basePath, image, tempIcon);
    return imagePath
end
--guild icon
function FuncRes.iconGuild(image)
    local basePath = "icon/guild/"
    local tempIcon = basePath .. "cimeliaIcon_haotianlu.png"
    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end
function FuncRes.iconCimelia(image)
    local basePath = "icon/cimelia/"
    local tempIcon = basePath .. "cimeliaIcon_haotianlu.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

-- guildActivity
-- 获取食物icon 或者 食材icon
function FuncRes.getFoodIcon(image)
    local basePath = "icon/food/"
    local tempIcon = basePath .. "food_img_huaiwangyugeng.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

-- 获取食物icon 或者 食材icon
function FuncRes.getActiveFoodIcon(image)
    local basePath = "icon/activity/"
    local tempIcon = basePath .. "activity_img_huagao.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end
-- 获取活动标题
function FuncRes.getActiveTitleIcon(image)
    local basePath = "icon/activity/"
    local tempIcon = basePath .. "activity_txt_czzz.png"

    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

-- 情缘全局属性拼图背景图
function FuncRes.getNewLovePuzzleIcon(_id)
    -- echo("_________id______",_id)
    local basePath = "icon/love/"
    local tempIcon = basePath .. "love_img_1.png"

    local imagePath = FuncRes.getImagePath(basePath,_id,tempIcon)
    return imagePath
end

--获得三皇台的资源
function FuncRes.getNewLotteryIcon(image)
    local basePath = "icon/lottery/"
    local tempIcon = basePath .. "lottery_img_cailiaojin.png"
    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

function FuncRes.getGuildExporeIcon(image)
    local basePath = "icon/explore/"
    local tempIcon = basePath .. "explore_img_lingmeng.png"
    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end



--获取背景
function FuncRes.iconBg( image )
    local basePath = "bg/"
    local tempIcon = basePath .. "bg_denglu.png"
    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--获得新手指引箭头
function FuncRes.iconGuide(arrowName)
    local basePath = "icon/guide/"
    local tempIcon = basePath .. "weapon_203.png"

    local imagePath = FuncRes.getImagePath(basePath, arrowName, tempIcon)
    return imagePath
end

--shade
function FuncRes.getShade(image)
    local basePath = "icon/shade/"
    local tempIcon = basePath .. "ShadeIconTemp.png"
    
    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--获取头像及npc头像
function FuncRes.iconHead( image )
    local basePath = "icon/head/"
    local tempIcon = basePath .. "HeadIconTemp.png"
    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

--获取伙伴头像
function FuncRes.partnerIcon(partnerId)
    local _partnerInfo = FuncPartner.getPartnerById(partnerId);
    if _partnerInfo then
        local _iconPath = FuncRes.iconHero(_partnerInfo.icon)
        return _iconPath
    else
        echoError("没有找到".. partnerId .."数据")
    end
end
--获取奇侠name
function FuncRes.iconName( image )
    local basePath = "icon/partnerName/"
    local tempIcon = basePath .. "paternershow_lxy_lanse.png"
    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end
function FuncRes.partnerName(partnerId,_type)
    local data = FuncPartnerSkinShow.getDataByParIdAndType( partnerId,_type )
    if data then
        local _iconPath = FuncRes.iconName(data.name)
        return _iconPath
    else
        echoError("没有找到".. partnerId .."数据",_type)
    end
end
-- npc动画
function FuncRes.npcAnim(npcAnimFileName,label)
    local animFileName = npcAnimFileName or "art_Spine30005"
    local animLabel = label or "stand"

    local npcAnim = ViewSpine.new(animFileName, {}, animFileName);
    npcAnim:playLabel(animLabel)
    return npcAnim
end

--英雄的头像
function FuncRes.iconAvatarHead(hid)
	local iconName = FuncChar.getHeroAvatar(hid)
	return FuncRes.iconHead(iconName)
end


--获取其他icon
function FuncRes.iconOther( image )
    local basePath = "icon/other/"
    local tempIcon = basePath .. "OtherTemp.png"
    local imagePath = FuncRes.getImagePath(basePath,image,tempIcon)
    return imagePath
end

-- 获取系统title
function FuncRes.iconSysTitle(image)
    image = (image or "")
    local basePath = "icon/systemIcon/"
    local tempIcon = basePath .. "tempIcon.png"
    image = image .. "_title"
    local imagePath = FuncRes.getImagePath(basePath, image, tempIcon)
    return imagePath
end

--获取系统icon
function FuncRes.iconSys( image )
    local basePath = "icon/systemIcon/"
    local tempIcon = basePath .. "tempIcon.png"
    local imagePath = FuncRes.getImagePath(basePath, image, tempIcon)
    return imagePath
end

-- 获取大系统icon
function FuncRes.iconSysBig(image)
    image = (image or "")
    local basePath = "icon/systemIcon/"
    local tempIcon = basePath .. image .. ".png" -- 用小图标替
    image = image .. "_big"
    local imagePath = FuncRes.getImagePath(basePath, image, tempIcon)
    return imagePath
end

--获取系统icon
function FuncRes.iconWuXing( image )
    local basePath = "icon/spirit/"
    local tempIcon = basePath .. "tempIcon.png"
    local imagePath = FuncRes.getImagePath(basePath, image, tempIcon)
    return imagePath
end


-- 获取image路径
function FuncRes.getImagePath(basePath,image,tempIcon,isIgnore)
    if basePath == nil or image == nil then
        echoError("传入的image为空:")
        return tempIcon
    end

	if not string.find(image, FuncRes.pngSuffix) then
		image = image..FuncRes.pngSuffix
	end
    local path = basePath .. image
	if FS.exists(path) then
		return path
	end
    if not isIgnore then
        echoError("========资源不存在，请找对应的策划==临时用一张资源== FuncRes.getImagePath " .. basePath .. "" .. image .. " not found")
    end

    return tempIcon

    -- if FS.exists(path) then
    --     return path
    -- else
    --     path = path .. FuncRes.pngSuffix
    --     if FS.exists(path) then
    --         return path
    --     end

    --     echoWarn(basePath .. "" .. image .. " not found")

    --     return tempIcon
    -- end
end

function FuncRes.getParticlePath()
	return "anim/particle/"
end

--获取某个动画的路径 分别返回  图片url  plist  和 xml
function FuncRes.armature( name )
    local textureFile = "anim/armature/"..name.."." ..FuncRes.armatureTextType
    local plistFile = "anim/armature/"..name..".plist"
    local xmlFile = "anim/armature/"..name.."."..FuncRes.armatureFileType
    return textureFile,plistFile,xmlFile
end

function FuncRes.getSpineTexturePath( spine )
    return "anim/spine/"..spine..".png"
end

--获取spine动画路径
function FuncRes.spine( name, atlasName )
    local foder = "anim/spine/"

    --如果是剧情动画
    if string.sub(name,1,5) == "plot_" then
        echo( name.."剧情动画的纹理用通用的common_plotTex")
        atlasName = "common_plotTex"
        TextureControler:noteOneTexture(name)
        TextureControler:noteOneTexture(atlasName)
    end

    atlasName = atlasName or name;

    local atlasName = foder..atlasName..".atlas";
    local configName = nil;

    local defautArtName = "art_30005_lixiaoyao"

    if IS_USE_SPINE_JSON_CONFIG ~= true then 
        --测试用，先放在这
        pc.PCSkeletonDataCache:getInstance():setIsUseBinaryConfig(true);

        configName = foder..name..".spb";
    else  
        --默认是这个，所以不用设置
        -- pc.PCSkeletonDataCache:getInstance():setIsUseBinaryConfig(false);
        configName = foder..name..".json";
    end 

    if not cc.FileUtils:getInstance():isFileExist(atlasName) then 
        echoError("找策划,这个spine资源没有" .. tostring(atlasName) );
        --如果是art 那么默认用 art_
        if string.find(atlasName,"art_") then
            echoWarn("没有这个art资源,用李逍遥立绘代替",defautArtName)
            atlasName = foder..defautArtName ..".atlas"
            configName = foder..defautArtName..".spb"
        else
            return
        end


    end 

    if not cc.FileUtils:getInstance():isFileExist(configName) then 
        echoError("FuncRes.spine configName " .. tostring(configName) .. " is not exist!");
    end 

    return configName, atlasName;
end
--获取spine立绘路径
 function FuncRes.artPath( name )
--    local foder = "anim/spine/" 
    return FuncRes.spine(name)
end
--获取spine立绘 默认步行
function FuncRes.getArtSpineAni( resName ,label)
     local _json,_atlas = FuncRes.artPath(resName)
     if cc.FileUtils:getInstance():isFileExist(_atlas) then
         local skeletonNode = pc.PCSkeletonAnimation:createWithFile(_json, _atlas, 1);
         local lableAction = "stand"
         if label then
            lableAction = label
         end
         skeletonNode:setAnimation(0, lableAction, true); 
         return skeletonNode
     end 
     return nil 
end 
--字体目录
function FuncRes.fnt( fnt )
    return "fnt/"..fnt
end

--ui目录
function FuncRes.ui(name )
    return "ui/"..name
end

--ui散图目录
function FuncRes.uipng(name )
    if string.sub(name,-4,-1) ~= ".png" then
        name = name ..".png"
    end
    --如果是用散图
    if CONFIG_USEDISPERSED then
        return "uipng/"..name
    end
    --那么直接返回这个ui图片对应的材质集
    return "#"..name
end


function FuncRes.test( name )
    return "test/"..name
end

function FuncRes.playerBigImg(image)
	return "icon/player/"..image
end

function FuncRes.playerBiaoQinImg(image)
    return "icon/chat/"..image..".png"
end

-- 获取灵宝ICON
function FuncRes.iconLingBao(image)
	return "icon/lingbao/"..image
end

-- 获取查看阵容功能背景
function FuncRes.iconLineUp( image )
    return "icon/teaminfo/" .. image
end
--修炼图集
function FuncRes.iconpartnerpractice( image )
    return "icon/partner/" .. image..".png"
end
function FuncRes:icontitleImg( image )
    return "icon/title/"..image..".png"
end


-- 获取功法ICON
function FuncRes.iconSkill(image)
	-- return "icon/skill/"..image
    local basePath = "icon/skill/"
    local tempIcon = basePath .. "skill_st1.png"
    
    local imagePath = FuncRes.getImagePath(basePath, image, tempIcon)
    return imagePath
end

--获取case
function FuncRes.iconTreasureCase(quality,color)
    local image = "treasure_case_"..quality.."_"..color
    local basePath = "icon/case/"
    local tempIcon = basePath .. "treasure_case_1_1.png"
    
    local imagePath = FuncRes.getImagePath(basePath, image, tempIcon)
    return imagePath
end


--主界面功能 npc icon
function FuncRes.iconIconHome(image)
    -- return "icon/skill/"..image
    local basePath = "icon/home/"
    local tempIcon = basePath .. "main_img_zhubao.png"
    
    local imagePath = FuncRes.getImagePath(basePath, image, tempIcon)
    return imagePath
end

--获取场景的icon
function FuncRes.iconMap(mapName, image )
    local imagePath = FuncRes.getImagePath("icon/map/"..mapName.."/",image)
    return imagePath
end


--加载一个ui材质集 不包含后缀名
function FuncRes.addOneUITexture( textureName ,handler )
    local plistUrl = "ui/"..textureName..".plist"
    local pngUrl = "ui/"..textureName.. GameVars.configTextureType
    if cc.FileUtils:getInstance():isFileExist(plistUrl) then
        display.addSpriteFrames(plistUrl, pngUrl, handler)
    end
    
end

--移除一个ui材质集 
function FuncRes.removeOneUITexture( textureName )
    local plistUrl = "ui/"..textureName..".plist"
    local pngUrl = "ui/"..textureName.. GameVars.configTextureType
    if cc.FileUtils:getInstance():isFileExist(plistUrl) then
        display.removeSpriteFramesWithFile(plistUrl, pngUrl)
    end
end

--创建一个spine对象 原则上不允许直接调用,只有在viewSpine里面调
function FuncRes.createOneSpineAni( name,atlasName ,scale)
    scale = scale or 1
    local configName, atlas= FuncRes.spine(name, atlasName)
    local ani = pc.PCSkeletonAnimation:createWithFile(configName,atlas,scale)
    return ani
end

--移除背景
function FuncRes.removeBgTexture( bgName )
    if string.sub(bgName,-4,-1) ==".png" then
        bgName = string.sub(bgName,1,-5)
    end
    local plistUrl = "bg/"..bgName..".plist"
    local pngUrl = "bg/"..bgName.. GameVars.configTextureType
    cc.Director:getInstance():getTextureCache():removeTextureForKey(pngUrl)
end

--单独移除某一个散图 纹理缓存
function FuncRes.removeOneTexture( texturePath )
    cc.Director:getInstance():getTextureCache():removeTextureForKey(texturePath)
end


--移除map场景
function FuncRes.removeMapTexture( mapName )
   
    local mapTexturePath
    for i=1,2 do
        mapTexturePath =  "map/"..mapName.."-"..(i-1) 
        if  (cc.FileUtils:getInstance():isFileExist(mapTexturePath..GameVars.configTextureType ))  then
            display.removeSpriteFramesWithFile(mapTexturePath..".plist", mapTexturePath..GameVars.configTextureType)
        end
    end

    local anires = FuncRes.armature(mapName)
    if  (cc.FileUtils:getInstance():isFileExist(anires ))  then
        FuncArmature.clearOneArmatureTexture(mapName,true)
        echo("移除场景动画："..mapName..".bobj" );
    end
end

--添加场景材质
function FuncRes.addMapTexture( mapName )

    local mapTexturePath
    for i=1,2 do
        mapTexturePath =  "map/"..mapName.."-"..(i-1) 
        if  (cc.FileUtils:getInstance():isFileExist(mapTexturePath ..GameVars.configTextureType))  then
            display.addSpriteFrames(mapTexturePath..".plist", mapTexturePath..GameVars.configTextureType)
        end
    end
    
    local anires = FuncRes.armature(mapName)
    if  (cc.FileUtils:getInstance():isFileExist(anires ))  then
        FuncArmature.loadOneArmatureTexture(mapName,nil,true)
    end
end

--获取战斗中角色的spine动画
-- sex 性别 1或者a 是男,2或者b是女, 空表示男
--isWhole 是否是完整spine 默认是简易的
function FuncRes.getSpineViewBySourceId(sourceId,sex,isWhole,sourceData )
    local sourceCfg = FuncTreasure.getSourceDataById(sourceId)
    local spineName = sourceCfg.spine
    if sex == "b"  or sex == 2  then
        spineName = sourceCfg.spineFormale or sourceCfg.spine
    end
    local spbName = spineName
    if not isWhole then
        spbName =  spbName .. "Extract";
    end
    local spineView =  ViewSpine.new(spbName, {}, nil, spineName,nil,sourceData);
    spineView.actionArr =sourceCfg
    --默认播放战力
    spineView:playLabel(sourceCfg.stand, true)
    return spineView
end
-- 获取战斗中展示奇侠的图片名称
function FuncRes.getParnterShowNameIcon(str )
    if not str or str == "" then
        echoWarn ("imaget name is nil,use Default _0003_battle_txt_zls")
        str = "_0003_battle_txt_zls"
    end
    return display.newSprite("icon/heroname/".. str ..".png")
end
-- 根据攻防辅标签获取奇侠展示底
function FuncRes.getParnterShowBg(_type )
    if not _type then return end
    local bgPngArr = {
        [1] = "battle_bg_gong",
        [2] = "battle_bg_fang",
        [3] = "battle_bg_fu",
    }
    _type = tonumber(_type)
    return display.newSprite(FuncRes.iconBg(bgPngArr[_type]))
end
-- 根据共仿佛获奇侠展示标签底
function FuncRes.getParnterShowTopBg(_type )
    if not _type then return end
    local bgPngArr = {
        [1] = "battle_bg_gongtiao",
        [2] = "battle_bg_fangtiao",
        [3] = "battle_bg_futiao",
    }
    _type = tonumber(_type)
    return display.newSprite("icon/heroname/".. bgPngArr[_type] ..".png")
end

function FuncRes.checkSpineBySourceId( sourceId,sex,isWhole  )
    local sourceCfg = FuncTreasure.getSourceDataById(sourceId)
    local spineName = sourceCfg.spine
    if sex == "b"  or sex == 2  then
        spineName = sourceCfg.spineFormale or sourceCfg.spine
    end
    local spbName = spineName
    if not isWhole then
        spbName =  spbName .. "Extract";
    end

    FuncRes.spine(spbName, spineName)
end
