// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { Log } from "../FrameWork/Log";
import { SOUND_NAME, SoundManager } from "../Module/Audio/SoundManager";

const { ccclass, property, menu } = cc._decorator;

@ccclass
@menu("UI 组件/DlgBtn")
export default class DlgBtn extends cc.Button {

    @property({
        displayName: "防连点间隔(秒)",
        tooltip: "设置按钮点击的最小间隔时间，防止用户快速连点"
    })
    clickInterval: number = 0.3;

    @property({
        displayName: "启用防连点",
        tooltip: "是否启用防连点功能"
    })
    enableClickProtection: boolean = true;

    private _lastClickTime: number = 0;
    private _isClicking: boolean = false;

    onLoad() {
        super.onLoad && super.onLoad();
        this._lastClickTime = 0;
        this._isClicking = false;
    }

    // 注册的点击事件回调列表
    private _clickCallbacks: Array<{ callback: Function, target: any }> = [];

    start() {
        super.start && super.start();
        // 监听按钮的点击事件，添加防连点逻辑
        this.node.on('click', this._onClick, this);
    }

    /**
     * 处理按钮点击事件，添加防连点逻辑
     */
    private _onClick() {
        Log.Debug("DlgBtn _onClick -----------------------");
        SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        if (!this.enableClickProtection) {
            // 如果未启用防连点，直接触发所有注册的回调
            this._triggerClickCallbacks();
            return;
        }

        const currentTime = Date.now();
        const timeSinceLastClick = currentTime - this._lastClickTime;

        // 检查是否在防连点间隔内（clickInterval 为 0 时禁用防连点）
        if (this.clickInterval > 0 && timeSinceLastClick < this.clickInterval * 1000) {
            // console.log(`[DlgBtn] 防连点保护：距离上次点击仅 ${timeSinceLastClick}ms，忽略此次点击`);
            return;
        }

        // 检查是否正在处理点击
        if (this._isClicking) {
            // console.log(`[DlgBtn] 防连点保护：正在处理点击中，忽略此次点击`);
            return;
        }

        // 更新点击时间和状态
        this._lastClickTime = currentTime;
        this._isClicking = true;

        Log.Debug("[DlgBtn] 允许点击事件: " + this.node.name);

        // 触发所有注册的回调
        this._triggerClickCallbacks();

        // 立即重置点击状态，避免长时间阻塞
        this._isClicking = false;
    }

    /**
     * 触发所有注册的点击回调
     */
    private _triggerClickCallbacks() {
        this._clickCallbacks.forEach(item => {
            if (item.callback && item.target) {
                try {
                    SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
                    item.callback.call(item.target, this);
                } catch (error) {
                    Log.Error("[DlgBtn] 回调函数执行出错: " + error, error);
                }
            }
        });
    }

    /**
     * 注册点击事件回调
     * @param callback 回调函数
     * @param target 回调函数的 this 上下文
     */
    public addClickCallback(callback: Function, target: any) {
        if (!callback || !target) {
            Log.Debug("[DlgBtn] addClickCallback: callback 或 target 为空");
            return;
        }

        // 检查是否已经注册过相同的回调
        const exists = this._clickCallbacks.some(item =>
            item.callback === callback && item.target === target
        );

        if (exists) {
            Log.Debug("[DlgBtn] addClickCallback: 回调已存在，跳过重复注册");
            return;
        }

        this._clickCallbacks.push({ callback, target });
        Log.Debug("[DlgBtn] addClickCallback: 注册回调: " + callback.name + " " + target.name);
    }

    /**
     * 移除点击事件回调
     * @param callback 要移除的回调函数
     * @param target 回调函数的 this 上下文
     */
    public removeClickCallback(callback: Function, target: any) {
        if (!callback || !target) {
            Log.Debug("[DlgBtn] removeClickCallback: callback 或 target 为空");
            return;
        }

        const index = this._clickCallbacks.findIndex(item =>
            item.callback === callback && item.target === target
        );
        if (index !== -1) {
            this._clickCallbacks.splice(index, 1);
            Log.Debug("[DlgBtn] removeClickCallback: 移除回调");
        } else {
            Log.Debug("[DlgBtn] removeClickCallback: 未找到要移除的回调");
        }
    }

    /**
     * 检查回调是否已注册
     * @param callback 回调函数
     * @param target 回调函数的 this 上下文
     * @returns 是否已注册
     */
    public hasClickCallback(callback: Function, target: any): boolean {
        if (!callback || !target) {
            return false;
        }

        return this._clickCallbacks.some(item =>
            item.callback === callback && item.target === target
        );
    }

    /**
     * 清空所有点击事件回调
     */
    public clearClickCallbacks() {
        this._clickCallbacks = [];
    }

    /**
     * 手动重置防连点状态
     * 在某些特殊情况下可能需要调用此方法
     */
    public resetClickProtection() {
        this._lastClickTime = 0;
        this._isClicking = false;
    }

    /**
     * 设置防连点间隔时间
     * @param interval 间隔时间（秒），设置为 0 时禁用防连点
     */
    public setClickInterval(interval: number) {
        if (typeof interval !== 'number' || interval < 0) {
            Log.Debug("[DlgBtn] setClickInterval: 无效的间隔时间，使用默认值 0.3");
            this.clickInterval = 0.3;
            return;
        }
        this.clickInterval = interval;
    }

    /**
     * 启用或禁用防连点功能
     * @param enable 是否启用
     */
    public setClickProtection(enable: boolean) {
        this.enableClickProtection = enable;
        if (!enable) {
            this.resetClickProtection();
        }
    }

    onDestroy() {
        // 清理事件监听
        this.node.off('click', this._onClick, this);
        // 清空回调列表
        this.clearClickCallbacks();
        // 清理定时器
        this.unscheduleAllCallbacks();
        super.onDestroy && super.onDestroy();
    }
}
