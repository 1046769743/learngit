--
--Author:      zhuguangyuan
--DateTime:    2018-01-31 17:42:59
--Description: 场景中点击宝箱 弹出的诗歌填词界面
--


local ElitePoetryView = class("ElitePoetryView", UIBase);

function ElitePoetryView:ctor(winName,boxId)
    ElitePoetryView.super.ctor(self, winName)
    self.boxId = boxId
end

function ElitePoetryView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function ElitePoetryView:registerEvent()
	ElitePoetryView.super.registerEvent(self);
	self:registClickClose("out")
	self.UI_1:setTouchEnabled(true)
	self.UI_1:setTouchSwallowEnabled(true)
	self.UI_1.btn_close:setTap(c_func(self.startHide,self))
end

function ElitePoetryView:initData()
	-- 正确答案
	local isChange = false
	self.CurQuestion = EliteMainModel:getCurQuestion(self.boxId,isChange)
	dump(self.CurQuestion, "当前随机出来的题目 self.CurQuestion")

	self.numOfAnswer = 4
	self.correctAnswer = self.CurQuestion.correctAnswer
end

function ElitePoetryView:initView()
	self.txt_2:visible(false)
	
	self.UI_1.mc_1:visible(false)
	-- self.UI_1.mc_1:showFrame(1)
	-- self.UI_1.mc_1:getCurFrameView().btn_1:setTap(c_func(self.confirmAnswer,self))
	self.UI_1.txt_1:setString("谜题")
	self:updateOneQuestion()

	-- 答案选项
	self.btn_1:setTap(c_func(self.selectAnswer,self,1))
	self.panel_dui1:visible(false)
	self.panel_cuo1:visible(false)

	self.btn_2:setTap(c_func(self.selectAnswer,self,2))
	self.panel_dui2:visible(false)
	self.panel_cuo2:visible(false)

	self.btn_3:setTap(c_func(self.selectAnswer,self,3))
	self.panel_dui3:visible(false)
	self.panel_cuo3:visible(false)
	
	self.btn_4:setTap(c_func(self.selectAnswer,self,4))
	self.panel_dui4:visible(false)
	self.panel_cuo4:visible(false)
end

-- 更新一道题目
function ElitePoetryView:updateOneQuestion(isChange)
	-- local isChange = true
	self:resumeUIClick()
	self.CurQuestion = EliteMainModel:getCurQuestion(self.boxId,isChange)

	self.txt_1:setString(GameConfig.getLanguage(self.CurQuestion.question))
	self.btn_1:setBtnStr( GameConfig.getLanguage(self.CurQuestion.answer[1]),"txt_1")
	self.btn_2:setBtnStr( GameConfig.getLanguage(self.CurQuestion.answer[2]),"txt_1")
	self.btn_3:setBtnStr( GameConfig.getLanguage(self.CurQuestion.answer[3]),"txt_1")
	self.btn_4:setBtnStr( GameConfig.getLanguage(self.CurQuestion.answer[4]),"txt_1")

	-- 答案选项
	self.panel_dui1:visible(false)
	self.panel_cuo1:visible(false)

	self.panel_dui2:visible(false)
	self.panel_cuo2:visible(false)

	self.panel_dui3:visible(false)
	self.panel_cuo3:visible(false)
	
	self.panel_dui4:visible(false)
	self.panel_cuo4:visible(false)
	self.selectedAnswer = nil
end

-- 选中答案
function ElitePoetryView:selectAnswer( answerNum )
	self:disabledUIClick()
	for i = 1,4 do
		self["panel_dui"..i]:visible(false)
		self["panel_cuo"..i]:visible(false)
		if tonumber(self.CurQuestion.correctAnswer) == i then
			self["panel_dui"..i]:visible(true)
		end

		if tonumber(answerNum) == i then
			if tonumber(answerNum) == tonumber(self.CurQuestion.correctAnswer) then
				-- WindowControler:showTips("回答正确",1)
				local function callback()
					EventControler:dispatchEvent(EliteEvent.ELITE_OPEN_BOX_CONDITION_MET,{Id = self.boxId} )
					self:startHide()
				end
				self:delayCall(c_func(callback),2)
			else
				self["panel_cuo"..i]:visible(true)
				-- WindowControler:showTips("不对,再想想",1)
				self:delayCall(c_func(self.updateOneQuestion,self,true),2)
			end
		end
	end
end

function ElitePoetryView:initViewAlign()
	-- TODO
end

function ElitePoetryView:updateUI()
	-- TODO
end

function ElitePoetryView:deleteMe()
	-- TODO

	ElitePoetryView.super.deleteMe(self);
end

return ElitePoetryView;
