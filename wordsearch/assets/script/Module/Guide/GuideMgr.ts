import { GuideStep } from './GuideStep';
import { Log } from '../../FrameWork/Log';
import { EventCenter } from '../../FrameWork/EventCenter';
import { EventName } from '../../Common/EventName';
import { UILayer, UIManager } from '../../FrameWork/UIManager';
import GuideUI from '../../View/Guide/GuideUI';
import { PrefabDefine } from '../../FrameWork/PrefabDefine';
import UserDataMgr from '../UserData/UserDataMgr';
import GuideStep_1 from './GuideStep_1';
import GuideStep_2 from './GuideStep_2';
import GuideStep_3 from './GuideStep_3';
import GuideStep_LuckWheel from './GuideStep_LuckWheel';
import GuideStep_IconLuckWheel from './GuideStep_IconLuckWheel';
import GuideStep_IconPig from './GuideStep_IconPig';
import GuideStep_PopPig1 from './GuideStep_PopPig1';
import GuideStep_PopPig2 from './GuideStep_PopPig2';
import GuideStep_4 from './GuideStep_4';
import GuideStep_10 from './GuideStep_10';
import GuideStep_11 from './GuideStep_11';
import GuideStep_GoldenLuckWheel from './GuideStep_GoldenLuckWheel';

/**
 * 引导的类型
 */
export enum GuideType {
    None = -1,
    NewUser = 0, // 新人引导
}

const { ccclass, property } = cc._decorator;

@ccclass('GuideMgr')
export class GuideMgr {
    public static readonly TAG: string = "[Guide]"
    // 创建单例
    private static _instance: GuideMgr;
    static get Instance() {
        if (this._instance) {
            return this._instance;
        }

        this._instance = new GuideMgr();
        return this._instance;
    }

    private _currentStep: GuideStep = null;
    public guideUI: GuideUI = null;

    public static MaxStep: number = 8;

    public isInitOk: boolean = false;

    public get currentStep() {
        return this._currentStep;
    }

    /**
     * 新人引导是否已结束
     */
    public get isGuideEnd() {
        return this.currentStep == null || this.currentStep.tpl.step >= GuideMgr.MaxStep;
    }

    /**
     * 当前是否正在显示引导
     */
    public get isGuide() {
        return !this.isGuideEnd && this._currentStep != null && this.guideUI.isShow;
    }

    /**
     * 初始化
     */
    init() {
        this.startup();
    }

    update(deltaTime: number) {
        if (this._currentStep) {
            this._currentStep.onFrame();
        }
    }

    /**
     * 启动引导
     */
    startup() {
        var self = this;

        EventCenter.on(EventName.GuideClick, this.onClickGuide, this);
        EventCenter.on(EventName.GuideClickMask, this.onClickMask, this);
        EventCenter.on(EventName.GuideSwipeComplete, this.onSwipeComplete, this);

        UIManager.Instance.showUIOnLayer(PrefabDefine.GuideUI, UILayer.Guide, (ui: cc.Node) => {
            if (ui) {
                self.guideUI = ui.getComponent(GuideUI);
                self.guideUI.hide();

                this.tryGuide();
                self.isInitOk = true;
            }
        });
    }

    /**
     * 尝试引导
     */
    tryGuide() {
        let guideStep = UserDataMgr.Instance.guideStep;
        if (guideStep == 1 || guideStep == 2 || guideStep == 3) {
            this.changeStep(GuideType.NewUser, guideStep);
        }
    }

    /**
     * 切换当前展示的指引，具体实现类似于有限状态机中的状态切换，但是不用保存历史引导
     * @param type 
     * @param step 
     */
    changeStep(type: GuideType, step: number) {
        Log.Debug(`${GuideMgr.TAG} changeStep type: ${type}, step: ${step}`);

        if (UserDataMgr.Instance.guideStep > step) {
            // return;
        }

        let guideTpl: SysGuide = this.getGuide(type, step);

        if (guideTpl == null) {
            Log.Debug(`${GuideMgr.TAG} changeStep failed, guideTpl is null type: ${type}, step: ${step}`);
            this.guideUI.hide();

            // 此处没有找到对应的引导数据，说明引导已经结束
            // if (this._currentStep) NativeApi.instance.onNewUserGuideEnd();
            return;
        }

        let guideStep: GuideStep = this.getGuideStep(type, step);

        if (guideStep == null) {
            Log.Debug(`${GuideMgr.TAG} changeStep failed, guideStep is null type: ${type}, step: ${step}`);
            this.guideUI.hide();
            return;
        }

        guideStep.init(guideTpl);

        this._currentStep = guideStep;

        this._currentStep.onEnter();
    }

    /**
     * 当前步骤结束时调用
     */
    onStepEnd() {
        if (this._currentStep) {
            // 判断是否保存进度
            if (this._currentStep.tpl && this._currentStep.tpl.is_save) {
                UserDataMgr.Instance.guideStep = this._currentStep.tpl.step + 1;
            }

            // 触发下一步
            if (this._currentStep.tpl.auto_next) {
                this.changeStep(this._currentStep.tpl.type, this._currentStep.tpl.step + 1);
            } else {
                this._currentStep = null;
                this.guideUI.hide();
            }
        } else {
            Log.Debug(`${GuideMgr.TAG} onStepEnd failed, currentStep is null`);
            // EventCenter.dispatchEvent(EventName.GuideEndEvent);
            this._currentStep = null;
            this.guideUI.hide();
        }
    }

    /**
     * 根据给定的引导类型和系统数据索引，获取相应的步骤系统数据
     */
    getGuide(type: GuideType, step: number) {
        let auto_next = false;
        if (step == 1 || step == 2 || step == 3 || step == 10 || step == 2002) {
            auto_next = true;
        }
        let data: SysGuide = {
            id: "1",
            type: type,
            step: step,
            tips: "新人引导",
            sound: "guide_new_user",
            auto_next: auto_next,
            is_save: true,
        };

        return data;
    }

    /**
     * 获取指定引导步骤的类
     * @param step 
     * @param index 
     */
    getGuideStep(type: GuideType, step: number): GuideStep {
        switch (step) {
            case 1:
                return new GuideStep_1();

            case 2:
                return new GuideStep_2();

            case 3:
                return new GuideStep_3();

            case 4:
                return new GuideStep_4();

            case 10:
                return new GuideStep_10();

            case 11:
                return new GuideStep_11();

            case 1001:
                return new GuideStep_IconLuckWheel();

            case 1002:
                return new GuideStep_LuckWheel();

            case 1003:
                return new GuideStep_GoldenLuckWheel();

            case 2001:
                return new GuideStep_IconPig();

            case 2002:
                return new GuideStep_PopPig2();

            case 2003:
                return new GuideStep_PopPig1();

            default:
                return null;
        }
    }

    private onClickGuide(e) {
        Log.Debug(`${GuideMgr.TAG} onClickGuide`);
        if (this._currentStep) {
            this._currentStep.onClick(e);
        } else {
            this.guideUI.hide();
        }
    }

    private onClickMask(e) {
        Log.Debug(`${GuideMgr.TAG} onClickMask`);
        if (this._currentStep) {
            this._currentStep.onClickMask(e);
        } else {
            this.guideUI.hide();
        }
    }

    private onSwipeComplete(e) {
        Log.Debug(`${GuideMgr.TAG} onSwipeComplete`);
        if (this._currentStep) {
            this._currentStep.onSwipeComplete();
        } else {
            this.guideUI.hide();
        }
    }
}

