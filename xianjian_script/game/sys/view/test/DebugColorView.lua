--
-- Author: guan
-- Date: 2016-10-14
--
DebugColorView = class("DebugColorView", UIBase)


function DebugColorView:loadUIComplete()	
	self:initUI();
end

function DebugColorView:initUI()
	self:initColorize();
	self:initAmount();
	self:initContrast();
	self:initBrightness();
	self:initSatuation();
	self:initHue();
	self:initThreshold();

    self.panel_back:setTouchedFunc(c_func(self.clickBackBtn, self));
    self.btn_1:setTouchedFunc(c_func(self.clickLogShowBtn, self));

    self:initPic();
end

function DebugColorView:testNodeGen()
	--swf 里那个采花小孩
	-- return display.newSprite("asset/test/test123.png");

    local sp = ViewSpine.new("30005_liXiaoYao", {}, "", "30005_liXiaoYao");

    sp:playLabel("run", true);

    sp.currentAni:setScale(2);
    sp:setPlaySpeed(1);

    return sp;
end

function DebugColorView:initPic()
	local sprite1 = self:testNodeGen();
	self.ctn_p1:addChild(sprite1);

	local sprite2 = self:testNodeGen();
	self.ctn_p2:addChild(sprite2);

end


function DebugColorView:initColorize()

    self.mc_color:setTouchedFunc(function ( ... )
    	local curframe = self.mc_color.currentFrame;
    	if curframe == 1 then 
    		self.mc_color:showFrame(2);

    	else 
    		self.mc_color:showFrame(1);
    	end 
    	self:clickApplyBtn();

    end);

    local showColorLayer = function (color)
    	local color = cc.c4b(color.r, color.g, color.b, 255);

    	local colorLayer = display.newColorLayer(color);
    	colorLayer:setPlotLayerSize(100, 100);
    	colorLayer:setPosition(-50, -50)
    	colorLayer:anchor(0.5, 0.5)

    	colorLayer:ignoreAnchorPointForPosition(false);

    	self.ctn_color:removeAllChildren();
    	self.ctn_color:addChild(colorLayer);
    end

    local inputEndCallback = function ()

    	local inputStr = self.input_color:getText();
    	local numColor = "0x" .. inputStr;

    	local n = tonumber(numColor);

    	if n == nil then 
    		WindowControler:showTips(GameConfig.getLanguage("tid_common_2061")); 
    		return;
    	end 

    	local c3b = numberToColor(numColor);
    	showColorLayer(c3b);

    	if self.mc_color.currentFrame == 2 then 
    		self:clickApplyBtn();
    	end 

    	self.panel_color.slider_r:setPercent((c3b.r / 255) * 100, true, true);
    	self.panel_color.slider_g:setPercent((c3b.g / 255) * 100, true, true);
    	self.panel_color.slider_b:setPercent((c3b.b / 255) * 100, true, true);
    end

    self.input_color:setInputEndCallback(inputEndCallback);
    self.input_color:setText("000000");

    local colorStr = self.input_color:getText();

    local numColor = "0x" .. colorStr;
	local c3b = numberToColor(numColor);

    showColorLayer(c3b);


    local colorSliderChange = function ( ... )
    	echo("---colorSliderChange---");

    	local r = tonumber( self.panel_color.slider_r:getTxtPercent() );
    	local g = tonumber( self.panel_color.slider_g:getTxtPercent() );
    	local b = tonumber( self.panel_color.slider_b:getTxtPercent() );

    	-- echo(r, g, b);

    	local hexR =  string.format("%#x", r);
    	local hexG = string.format("%#x", g);
    	local hexB = string.format("%#x", b);

    	local pureR = string.gsub(hexR, "0x", "");
    	if string.len(pureR) == 1 then 
    		pureR = "0" .. pureR;
    	end 
    	
    	local pureG = string.gsub(hexG, "0x", "");
    	if string.len(pureG) == 1 then 
    		pureG = "0" .. pureG;
    	end 
    	
    	local pureB = string.gsub(hexB, "0x", "");
    	if string.len(pureB) == 1 then 
    		pureB = "0" .. pureB;
    	end 

    	local color = pureR .. pureG .. pureB
    	self.input_color:setText(color);

    	-- echo(color)

    	local numColor = "0x" .. color;
		local c3b = numberToColor(numColor);

	    showColorLayer(c3b);

	    if self.mc_color.currentFrame == 2 then 
    		self:clickApplyBtn();
    	end 
    end

    self.panel_color.slider_r:setMinMax(0, 255);
    self.panel_color.slider_r:onSliderChange(colorSliderChange);

    self.panel_color.slider_g:setMinMax(0, 255);
    self.panel_color.slider_g:onSliderChange(colorSliderChange);

    self.panel_color.slider_b:setMinMax(0, 255);
    self.panel_color.slider_b:onSliderChange(colorSliderChange);

end

function DebugColorView:initAmount()
    self.mc_amount:setTouchedFunc(function ( ... )
    	local curframe = self.mc_amount.currentFrame;
    	if curframe == 1 then 
    		self.mc_amount:showFrame(2);
    	else 
    		self.mc_amount:showFrame(1);
    	end 
    	self:clickApplyBtn();

    end);

    self.slider_amount:setMinMax(0, 30);
    self.slider_amount:setTxtDiv(10);

    self.slider_amount:onSliderChange(function ( ... )
    	if self.mc_amount.currentFrame == 2 then 
    		self:clickApplyBtn();
    	end 
    end)
end

function DebugColorView:initContrast()
    self.mc_contrast:setTouchedFunc(function ( ... )
    	local curframe = self.mc_contrast.currentFrame;
    	if curframe == 1 then 
    		self.mc_contrast:showFrame(2);
    	else 
    		self.mc_contrast:showFrame(1);
    	end 
    	self:clickApplyBtn();

    end);

    self.slider_co:setMinMax(-30, 30);
    self.slider_co:setTxtDiv(10);
    self.slider_co:setPercent(50);

    self.slider_co:onSliderChange(function ( ... )
    	if self.mc_contrast.currentFrame == 2 then 
    		self:clickApplyBtn();
    	end 
    end)

end

function DebugColorView:initBrightness()
    self.mc_brightness:setTouchedFunc(function ( ... )
    	local curframe = self.mc_brightness.currentFrame;
    	if curframe == 1 then 
    		self.mc_brightness:showFrame(2);
    	else 
    		self.mc_brightness:showFrame(1);
    	end 
    	self:clickApplyBtn();
    end);

    self.slider_brightness:setMinMax(-30, 30);
    self.slider_brightness:setTxtDiv(10);
    self.slider_brightness:setPercent(50);

    self.slider_brightness:onSliderChange(function ( ... )
    	if self.mc_brightness.currentFrame == 2 then 
    		self:clickApplyBtn();
    	end 
    end)

end

function DebugColorView:initSatuation()
    self.mc_satuartion:setTouchedFunc(function ( ... )
    	local curframe = self.mc_satuartion.currentFrame;
    	if curframe == 1 then 
    		self.mc_satuartion:showFrame(2);
    	else 
    		self.mc_satuartion:showFrame(1);
    	end 
    	
    	self:clickApplyBtn();
    end);

    self.slider_sa:setMinMax(-30, 30);
    self.slider_sa:setTxtDiv(10);
    self.slider_sa:setPercent(50);

    self.slider_sa:onSliderChange(function ( ... )
    	if self.mc_satuartion.currentFrame == 2 then 
    		self:clickApplyBtn();
    	end 
    end)
end

function DebugColorView:initHue()
    self.mc_hue:setTouchedFunc(function ( ... )
    	local curframe = self.mc_hue.currentFrame;
    	if curframe == 1 then 
    		self.mc_hue:showFrame(2);
    	else 
    		self.mc_hue:showFrame(1);
    	end 
    	self:clickApplyBtn();
    end);

    self.slider_hue:setMinMax(0, 36);
    self.slider_hue:setTxtDiv(0.1);
    self.slider_hue:setPercent(0);

    self.slider_hue:onSliderChange(function ( ... )
    	if self.mc_hue.currentFrame == 2 then 
    		self:clickApplyBtn();
    	end 
    end)

end

function DebugColorView:initThreshold()
    self.mc_threshold:setTouchedFunc(function ( ... )
    	local curframe = self.mc_threshold.currentFrame;
    	if curframe == 1 then 
    		self.mc_threshold:showFrame(2);
    	else 
    		self.mc_threshold:showFrame(1);
    	end 
    	
    	self:clickApplyBtn();

    end);

    self.slider_th:setMinMax(0, 255);

    self.slider_th:onSliderChange(function ( ... )
    	if self.mc_threshold.currentFrame == 2 then 
    		self:clickApplyBtn();
    	end 
    end)
end

function DebugColorView:clickApplyBtn()

    self.ctn_p2:removeAllChildren();
	local sprite2 = self:testNodeGen();
	self.ctn_p2:addChild(sprite2); 

	local params = self:getParams();

    local matrix = ColorMatrixFilterPlugin:genColorTransForm(params);
    FilterTools.setColorMatrix(sprite2, matrix);

end

function DebugColorView:getParams( ... )
	--todo colorize输入是否合法

	local inputStr = self.input_color:getText();
	local numColor = "0x" .. inputStr;

	local n = tonumber(numColor);

	if n == nil then 
		WindowControler:showTips(GameConfig.getLanguage("tid_common_2061"));
		return;
	end 

	local colorize = nil;
	if self.mc_color.currentFrame == 2 then 
		colorize = self.input_color:getText();
	end 

	local amount = nil;
	if self.mc_amount.currentFrame == 2 then
		echo("---" .. self.slider_amount:getTxtPercent());
		amount = tonumber(self.slider_amount:getTxtPercent());
	end 

	local contrast = nil;
	if self.mc_contrast.currentFrame == 2 then
		contrast = tonumber(self.slider_co:getTxtPercent());
	end 

	local brightness = nil;
	if self.mc_brightness.currentFrame == 2 then
		brightness = tonumber(self.slider_brightness:getTxtPercent());
	end 

	local saturation = nil;
	if self.mc_satuartion.currentFrame == 2 then
		saturation = tonumber(self.slider_sa:getTxtPercent());
	end

	local hue = nil;
	if self.mc_hue.currentFrame == 2 then
		hue = tonumber(self.slider_hue:getTxtPercent());
	end 

	local threshold = nil;
	if self.mc_threshold.currentFrame == 2 then
		threshold = tonumber(self.slider_th:getTxtPercent());
	end 

    local params = {
        colorize = colorize,
        amount = amount,

        contrast = contrast,

        brightness = brightness,
        saturation = saturation,
        hue = hue,
        threshold = threshold,
    };

    return params;
end

function DebugColorView:clickLogShowBtn()
	dump(self:getParams(), "------====ColorMatrixFilterPlugin Params===-------");
end

function DebugColorView:clickBackBtn()
	self:startHide();
end

return DebugColorView








