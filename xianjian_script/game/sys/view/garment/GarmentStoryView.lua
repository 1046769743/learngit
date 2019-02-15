--
--Author:      zhuguangyuan
--DateTime:    2017-07-31 22:09:34
--Description: 某件时装的故事
--


local GarmentStoryView = class("GarmentStoryView", UIBase);

function GarmentStoryView:ctor(winName, garmentId)
    GarmentStoryView.super.ctor(self, winName)
    self.garmentId = garmentId
end

function GarmentStoryView:loadUIComplete()
	self:initData()
	self:initView()

	self:registerEvent()
	self:initViewAlign()

	self:updateUI()
end 



function GarmentStoryView:initData()
	-- TODO
end



function GarmentStoryView:initView()
	self.txtGarmentName = self.txt_name
    self.txtForever = self.txt_name2

    self.scale9 = self.scale9_2
    self.txtStory = self.txt_1


	self.ctnIcon = self.ctn_icon
    self.txtTips = self.panel_bao.txt_shengxiao
    self.mcAttributes = self.panel_bao.mc_1
end



function GarmentStoryView:registerEvent()
	GarmentStoryView.super.registerEvent(self)
	self:registClickClose()  -- 点击任意地方关闭
end



function GarmentStoryView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.txtGarmentName, UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.txtForever, UIAlignTypes.Left);

    FuncCommUI.setViewAlign(self.widthScreenOffset, self.txtStory, UIAlignTypes.Right);
    FuncCommUI.setScale9Align( self.widthScreenOffset,self.scale9_1,UIAlignTypes.Middle,0,1)
    -- FuncCommUI.setScale9Align( self.widthScreenOffset,self.scale9_2,UIAlignTypes.right,0,1)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctnIcon, UIAlignTypes.LeftBottom);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_bao, UIAlignTypes.MiddleBottom);
end



function GarmentStoryView:updateUI()
	--故事
    local strotyStr = FuncGarment.getStoryStr(self.garmentId);
    FuncCommUI.setVerTicalTXT( {str = strotyStr, space = 3, txt = self.txtStory} );

    --名字
    local nameStr = FuncGarment.getGarmentName(self.garmentId);
    self.txtGarmentName:setString(nameStr);

    --立绘
    local artSp = FuncGarment.getGarmentLihui(self.garmentId, UserModel:avatar(),"dynamicStory")
    -- artSp:setScale(0.75)

    -- local spConfig = FuncGarment.getValueByKey(self.garmentId, UserModel:avatar(), "dynamicStory")
    -- local arr = string.split(spConfig, ",")


    local artMaskSprite = display.newSprite(FuncRes.iconOther("garment_img_zhezhao"))
    artMaskSprite:setScaleY(5)

    artMaskSprite:anchor(0.5,1)  
    artMaskSprite:pos(0,-40+5)
    
    -- 获得遮罩层
    local function getMaskCan1(maskSprite, contentNode,...)
        local clipper = cc.ClippingNode:create()
        clipper:setCascadeOpacityEnabled(true)
        clipper:setOpacityModifyRGB(true)
        clipper:setStencil(maskSprite)
        clipper:setInverted(true)
        clipper:setAlphaThreshold(0.01)
        contentNode:parent(clipper)
        local args = {...}
        if args and #args >0 then
            for i,v in ipairs(args) do
                v:parent(clipper)
            end
        end
        return clipper
    end
    --遮罩与立绘合成
    local newAnim = getMaskCan1(artMaskSprite,artSp)
    -- newAnim:pos(0,0)

    self.ctnIcon:removeAllChildren()
    self.ctnIcon:addChild(newAnim)



    --限时与否
    local isOwn = GarmentModel:isOwnOrNot(self.garmentId)
    if isOwn == false then
    	self.txt_name2:setVisible(false)
    else
	    local isForeverOwn = GarmentModel:isForeverOwn(self.garmentId)
	    if isForeverOwn == true then
	        self.txt_name2:setString(GameConfig.getLanguage("#tid_Garment_003"))
	    else 
	        self.txt_name2:setString(GameConfig.getLanguage("#tid_Garment_006"))
	    end 
    end

    local _str1 = GameConfig.getLanguage("#tid_Garment_007") --生命 
    local _str2 = GameConfig.getLanguage("#tid_Garment_008") --攻击
    local _str3 = GameConfig.getLanguage("#tid_Garment_009") --物防
    local _str4 = GameConfig.getLanguage("#tid_Garment_010") --法防
    local map1 = {	"", _str1, "", "", "", 
				"", "", "", "", _str2,
				_str3, _str4, "", "", ""
	}
    -- 属性加成
    self.mcAttributes:visible(false)
    local attr = FuncGarment.getValueByKey(self.garmentId, UserModel:avatar(), "attr")
    dump(attr,"读取到的数据为：")
    if attr then
        self.mcAttributes:visible(true)
        self.mcAttributes:showFrame(#attr)
        for i,v in pairs(attr) do
        	if v.mode == 3 or v.mode == "3" then
	        	local str1 = map1[tonumber(v.key)]
	        	str1 = str1..": +"..v.value        	
	            self.mcAttributes.currentView["txt_shu"..i]:setString( str1 )
	        end
        end
    else
        self.mcAttributes:visible(true)
        self.mcAttributes:showFrame(1)
        self.mcAttributes.currentView["txt_shu"..1]:setString(GameConfig.getLanguage("#tid_Garment_des_21703"))
    end
end



function GarmentStoryView:deleteMe()
	-- TODO
	GarmentStoryView.super.deleteMe(self);
end

return GarmentStoryView;
