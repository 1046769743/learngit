import { GuideMgr, GuideType } from './GuideMgr';
import { SoundManager } from '../Audio/SoundManager';
import { Log } from '../../FrameWork/Log';
import { EventName } from '../../Common/EventName';
import { EventCenter } from '../../FrameWork/EventCenter';
const { ccclass, property } = cc._decorator;

@ccclass('GuideStep')
export class GuideStep {
    index: number = 0; // 步骤索引

    protected isCheckCanStart: boolean = false; // 是否需要检测开始
    protected isCheckCanEnd: boolean = false; // 是否需要检测结束

    tpl: SysGuide = null; // 引导模板

    // 滑动引导相关
    protected isSwipeGuide: boolean = false; // 是否为滑动引导

    init(tpl: SysGuide) {
        this.tpl = tpl;
        this.index = tpl.step;
    }

    /**
     * 当进入当前步骤时调用，
     * 如果进入就可以显示展示，则直接在这个方法中调用onStart；
     * 如果只是开启了这个步骤，但还需要监听某些状态达成，可以设置IsCheckCanStart=true
     * 新手引导中虽然未必展示引导的显示部分，但是可以先显示遮罩层，阻挡玩家操作
     */
    onEnter() {
        Log.Debug(`[Guide] onEnter: ${this.index}`);
    }

    /**
     * 当前步骤正式开始时调用，开始展示指引，控制GuideUI的显示
     * 如果在此设置IsCheckCanEnd=true，那么这个步骤就是自动检测结束
     * 调用onStart将切换GuideMgr中的current
     */
    onStart() {
        Log.Debug(`[Guide] onStart: ${this.index}`);

        if (this.tpl.sound) {
        }
    }

    /**
     * 心跳，每帧调用，如果某一步骤的心跳间隔不同，可以自行以此进行进一步计时，例如累计到秒
     */
    onFrame() {
        if (this.isCheckCanStart) {
            if (this.CheckCanStart()) {
                this.isCheckCanStart = false;
                this.onStart();
            }
        }

        if (this.isCheckCanEnd) {
            if (this.CheckCanEnd()) {
                this.isCheckCanEnd = false;
                this.onEnd();
            }
        }
    }

    /**
     * 当前步骤执行结束时调用，代表着引导的展示结束，可以是玩家的本步骤操作结束，并且操作有效达成指引要求；也可以一些等待计时类的目标到期
     */
    onEnd() {
        Log.Debug(`[Guide] onEnd: ${this.index}`);

        if (this.tpl.sound) {
            SoundManager.Instance.StopSound(this.tpl.sound);
        }

        GuideMgr.Instance.onStepEnd();
    }

    /**
     * 退出当前步骤时调用，可在此持久化引导的阶段数，如果是某一个强制引导的分支末尾，也可以在此隐藏遮罩层
     */
    onExit() {
        Log.Debug(`[Guide] onExit: ${this.index}`);
    }

    /**
     * 检测是否可以开始展示引导，如果返回为true，将由管理器调用onStart接口
     */
    CheckCanStart(): boolean {
        return false;
    }

    /**
     * 检测是否可以结束引导展示，如果返回为true，将由管理器调用onEnd接口
     */
    CheckCanEnd(): boolean {
        return false;
    }

    /**
     * 引导显示对象上发生的点击，将有事件通知到这里
     * @param e 
     */
    onClick(e) {
        Log.Debug(`[Guide] onClick: ${this.index}`);
    }

    /**
     * 点击引导的遮罩层，将有事件通知到这里
     */
    onClickMask(e) {
        Log.Debug(`[Guide] onClickMask: ${this.index}`);
    }

    /**
     * 滑动引导完成时调用
     */
    onSwipeComplete() {
        Log.Debug(`[Guide] onSwipeComplete: ${this.index}`);
        this.onEnd();
    }

    /**
     * 显示滑动引导
     * @param target 目标节点
     * @param direction 滑动方向 (1,0)从左往右 (-1,0)从右往左
     * @param swipeDistance 滑动距离
     * @param tipsShowTarget 提示框目标
     * @param isBlack 是否显示黑色遮罩
     */
    protected showSwipeGuide(target: cc.Node, direction: cc.Vec2, swipeDistance: number = 200, tipsShowTarget: cc.Node = null, isBlack: boolean = true) {
        this.isSwipeGuide = true;

        if (GuideMgr.Instance.guideUI) {
            GuideMgr.Instance.guideUI.showSwipeTarget(target, direction, swipeDistance, tipsShowTarget, isBlack, () => {
                this.onSwipeComplete();
            });
        }
    }

    /**
     * 显示点击引导
     * @param target 目标节点
     * @param tipsShowTarget 提示框目标
     * @param showFinger 是否显示手指
     * @param showClickNode 是否显示点击区域
     * @param isBlack 是否显示黑色遮罩
     */
    protected showClickGuide(target: cc.Node, tipsShowTarget: cc.Node = null, showFinger: boolean = true, showClickNode: boolean = true, isBlack: boolean = true) {
        this.isSwipeGuide = false;

        if (GuideMgr.Instance.guideUI) {
            GuideMgr.Instance.guideUI.showTarget(target, tipsShowTarget, showFinger, showClickNode, isBlack);
        }
    }
}