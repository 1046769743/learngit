// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html

import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { UIManager } from "../../FrameWork/UIManager";

const { ccclass } = cc._decorator;

/**
 * 弹窗序列项配置
 */
export interface PopupSequenceItem {
    /** 弹窗名称（PrefabDefine中的名称） */
    popupName: string;
    /** 是否显示的条件判断函数，返回true则显示，false则跳过 */
    shouldShow?: () => boolean;
    /** 弹窗关闭后的事件名称（可选，如果不提供则使用通用关闭事件） */
    closeEventName?: string;
    /** 显示前的回调函数 */
    onBeforeShow?: () => void;
    /** 关闭后的回调函数 */
    onAfterClose?: () => void;
}

/**
 * 弹窗序列管理器
 * 用于管理多个弹窗按顺序显示，一个关闭后再显示下一个
 */
@ccclass
export default class PopupSequenceMgr {
    private static _instance: PopupSequenceMgr = null;

    public static get Instance(): PopupSequenceMgr {
        if (this._instance) {
            return this._instance;
        }
        this._instance = new PopupSequenceMgr();
        return this._instance;
    }

    /** 当前弹窗序列队列 */
    private _popupQueue: PopupSequenceItem[] = [];

    /** 当前正在显示的弹窗项 */
    private _currentPopupItem: PopupSequenceItem = null;

    /** 是否正在显示序列 */
    private _isShowingSequence: boolean = false;

    /** 通用弹窗关闭事件监听器 */
    private _onPopupCloseHandler: Function = null;

    /**
     * 显示弹窗序列
     * @param popupList 弹窗序列列表
     */
    public showSequence(popupList: PopupSequenceItem[]): void {
        if (!popupList || popupList.length === 0) {
            Log.Debug("PopupSequenceMgr: 弹窗序列为空");
            return;
        }

        // 过滤掉不需要显示的弹窗
        const filteredList = popupList.filter(item => {
            if (item.shouldShow) {
                return item.shouldShow();
            }
            return false;
        });

        if (filteredList.length === 0) {
            Log.Debug("PopupSequenceMgr: 所有弹窗都不满足显示条件");
            return;
        }

        // 如果已经有序列在显示，将新序列追加到队列
        if (this._isShowingSequence) {
            this._popupQueue.push(...filteredList);
            Log.Debug(`PopupSequenceMgr: 已有序列在显示，将新序列追加，当前队列长度: ${this._popupQueue.length}`);
            return;
        }

        // 清空队列并设置新序列
        this._popupQueue = [...filteredList];
        this._isShowingSequence = true;

        // 监听弹窗关闭事件
        this._setupCloseListener();

        // 开始显示第一个弹窗
        this._showNextPopup();
    }

    /**
     * 显示下一个弹窗
     */
    private _showNextPopup(): void {
        // 如果队列为空，序列结束
        if (this._popupQueue.length === 0) {
            Log.Debug("PopupSequenceMgr: 弹窗序列显示完成");
            this._isShowingSequence = false;
            this._currentPopupItem = null;
            this._removeCloseListener();
            return;
        }

        // 获取下一个弹窗项
        this._currentPopupItem = this._popupQueue.shift();

        // 执行显示前回调
        if (this._currentPopupItem.onBeforeShow) {
            this._currentPopupItem.onBeforeShow();
        }

        // 显示弹窗
        Log.Debug(`PopupSequenceMgr: 显示弹窗 ${this._currentPopupItem.popupName}`);
        UIManager.Instance.open(this._currentPopupItem.popupName, (node: cc.Node) => {
            if (!node) {
                Log.Error(`PopupSequenceMgr: 弹窗 ${this._currentPopupItem.popupName} 打开失败，跳过`);
                // 如果打开失败，继续下一个
                this._onCurrentPopupClosed();
            }
        });
    }

    /**
     * 当前弹窗关闭后的处理
     */
    private _onCurrentPopupClosed(): void {
        if (!this._currentPopupItem) {
            return;
        }

        // 执行关闭后回调
        if (this._currentPopupItem.onAfterClose) {
            this._currentPopupItem.onAfterClose();
        }

        // 显示下一个弹窗
        this.scheduleOnce(() => {
            this._showNextPopup();
        }, 0.1); // 延迟0.1秒显示下一个，确保当前弹窗完全关闭
    }

    /**
     * 设置关闭事件监听
     */
    private _setupCloseListener(): void {
        if (this._onPopupCloseHandler) {
            return; // 已经设置了监听
        }

        this._onPopupCloseHandler = this._handlePopupClose.bind(this);

        // 监听通用弹窗关闭事件（由UIManager派发）
        EventCenter.on(EventName.PopupClose, this._onPopupCloseHandler, this);

    }

    /**
     * 移除关闭事件监听
     */
    private _removeCloseListener(): void {
        if (!this._onPopupCloseHandler) {
            return;
        }

        EventCenter.off(EventName.PopupClose, this._onPopupCloseHandler, this);
        this._onPopupCloseHandler = null;
    }

    /**
     * 处理通用弹窗关闭事件
     */
    private _handlePopupClose(popupName: string): void {
        if (!this._isShowingSequence || !this._currentPopupItem) {
            return;
        }

        // 检查是否是当前弹窗关闭
        if (popupName !== this._currentPopupItem.popupName) {
            // 不是当前弹窗关闭，忽略
            return;
        }

        this._onCurrentPopupClosed();
    }

    /**
     * 手动关闭当前序列（跳过剩余弹窗）
     */
    public closeSequence(): void {
        if (!this._isShowingSequence) {
            return;
        }

        Log.Debug("PopupSequenceMgr: 手动关闭弹窗序列");
        this._popupQueue = [];
        this._isShowingSequence = false;
        this._currentPopupItem = null;
        this._removeCloseListener();
    }

    /**
     * 是否正在显示序列
     */
    public get isShowingSequence(): boolean {
        return this._isShowingSequence;
    }

    /**
     * 延迟执行函数（用于在非Component中使用scheduleOnce）
     */
    private scheduleOnce(callback: Function, delay: number): void {
        // 使用 setTimeout 作为延迟执行
        setTimeout(callback, delay * 1000);
    }
}

