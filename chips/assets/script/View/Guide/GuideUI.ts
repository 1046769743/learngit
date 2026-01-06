// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import ResourceManager from "../../FrameWork/ResourceManager";
import { GameMgr } from "../../Module/Game/GameMgr";
import Language from "../../Module/Language/Language";
import GameUI from "../Game/GameUI";

const { ccclass, property } = cc._decorator;

@ccclass
export default class GuideUI extends cc.Component {

    @property(cc.Node)
    hollowOut: cc.Node = null; // 用于镂空的目标

    @property(cc.Node)
    finger: cc.Node = null; // 手指

    @property(cc.Node)
    fingerSkeleton: cc.Node = null; // 手指的骨骼动画

    @property(cc.Node)
    tipsTarget: cc.Node = null; // 提示框的目标

    @property(cc.Node)
    tips: cc.Node = null; // 提示框

    @property(cc.Label)
    tipsLabel: cc.Label = null; // 提示框的文字

    @property(cc.Node)
    black: cc.Node = null; // 黑色遮罩

    @property(cc.Node)
    mask: cc.Node = null; // 全屏遮罩（透明）

    @property(cc.Button)
    maskButton: cc.Button = null; // 全屏遮罩（透明）

    @property(cc.Button)
    clickNode: cc.Button = null; // 点击区域

    @property(cc.Node)
    swipeNode: cc.Node = null; // 滑动区域

    @property(cc.Label)
    closeTipsLabel: cc.Label = null; // 关闭引导的提示文字

    private _allowTime: number = 0; // 遮罩和指引目标遮罩的允许点击时间 

    private _target: cc.Node = null; // 镂空的目标
    private _tipsShowTarget: cc.Node = null; // 是否显示提示框的目标
    private _otherTarget: cc.Node = null; // 镂空的第二个目标
    private _isBlack: boolean = false; // 是否显示黑色遮罩
    private _isShowClickNode: boolean = false; // 是否显示点击区域

    private _clickMaskCb: Function = null; //点击mask回调（临时调用引导的时候用）
    private _clickNodeCb: Function = null; //点击Node回调（临时调用引导的时候用）

    // 滑动引导相关属性
    private _isSwipeGuide: boolean = false; // 是否为滑动引导
    private _swipeDirection: cc.Vec2 = null; // 滑动方向（归一化的方向向量）
    private _swipeStartPos: cc.Vec2 = null; // 滑动起始位置
    private _swipeEndPos: cc.Vec2 = null; // 滑动结束位置
    private _swipeDistance: number = 0; // 滑动距离
    private _swipeAnimation: cc.Tween = null; // 滑动动画
    private _swipeCallback: Function = null; // 滑动完成回调
    private _swipeTarget: cc.Node = null; // 滑动目标节点
    private _hasPrintedBounds: boolean = false; // 是否已打印边界信息

    public get isShow() {
        return this.node.active;
    }

    start() {
        this.clickNode.node.on("click", this.onClickTarget, this);
        this.maskButton.node.on("click", this.onClickMask, this);

        // 默认隐藏滑动节点
        this.swipeNode.active = false;
    }

    update(deltaTime: number) {
        if (this.node.active && this._target) {
            this.refreshTarget();
        }
    }

    /**
     * 展示指引
     */
    show(isMask: boolean = true, clickNodeCb: Function = null, clickMaskCb: Function = null) {
        this.node.active = true;
        this.mask.active = isMask;

        this.tipsTarget.active = false;
        this.finger.active = false;
        this.fingerSkeleton.active = false;
        this.hollowOut.active = false;
        this.clickNode.node.active = false;

        this._tipsShowTarget = null;
        this._target = null;
        this._otherTarget = null;
        this._isBlack = false;
        this._isShowClickNode = false;
        this.closeTipsLabel.node.active = false;

        this._clickMaskCb = clickMaskCb;
        this._clickNodeCb = clickNodeCb;
    }

    /**
     * 隐藏指引
     */
    hide() {
        this.mask.active = false;
        this.node.active = false;

        this.tipsTarget.active = false;
        this.finger.active = false;
        this.hollowOut.active = false;
        this.clickNode.node.active = false;

        this._isBlack = false;
        this._isShowClickNode = false;
        this._tipsShowTarget = null;
        this._target = null;
        this._otherTarget = null;
        this.closeTipsLabel.node.active = false;

        // 停止滑动动画
        this.stopSwipeAnimation();
        this._isSwipeGuide = false;
        this._swipeDirection = null;
        this._swipeStartPos = null;
        this._swipeEndPos = null;
        this._swipeDistance = 0;
        this._swipeCallback = null;
        this._swipeTarget = null;
        this._hasPrintedBounds = false;

        // 隐藏滑动区域并取消事件监听
        this.swipeNode.active = false;
        this.removeSwipeNodeEvents();
    }

    /**
     * 展示引导的对话
     * @param content 对话内容
     * @param offY 对话框的Y轴偏移
     * @param height 对话框的高度
     */
    showTips(content: string, width: number = 500, height: number = 200, offY: number = 0, offX: number = 0) {
        if (content) {
            this.tipsTarget.active = true;
            this.tipsLabel.string = content;
            if (height > 0) {
                this.tips.width = width;
                this.tips.height = height;
            }

            this._allowTime = Date.now() + 200;
            this.tips.setPosition(offX, offY);
        } else {
            this.tipsTarget.active = false;
        }
    }

    showCloseTipsLabel() {
        this.closeTipsLabel.node.active = true;
        this.closeTipsLabel.string = Language.instance.getDes("46");
    }

    /**
     * 展示引导的目标
     * @param target 镂空显示的目标（手指会指向的目标）
     * @param tipsShowTarget 是否显示提示框的目标
     * @param showFinger 是否显示手指
     * @param showClickNode 是否显示点击区域, 该点击区域将代替实际的目标进行点击
     * @param isBlack 是否显示黑色遮罩
     * @param callback 显示后的回调
     * @param otherTarget 如果有第二个镂空的目标，可以传入，最多仅支持两个镂空目标
     */
    showTarget(target: cc.Node, tipsShowTarget: cc.Node = null, showFinger: boolean = true, showClickNode: boolean = true, isBlack: boolean = true, callback: Function = null, otherTarget: cc.Node = null) {
        this._target = target;
        this._tipsShowTarget = tipsShowTarget;
        this._otherTarget = otherTarget;
        this._isBlack = isBlack;
        this._isShowClickNode = showClickNode;

        this.scheduleOnce(() => {
            const targetWorldPos = this._target.convertToWorldSpaceAR(cc.v2(0, 0));
            const targetLocalPos = this.node.convertToNodeSpaceAR(targetWorldPos);
            if (showFinger) {
                this.fingerSkeleton.active = true;
                this.fingerSkeleton.setPosition(targetLocalPos.x, targetLocalPos.y - 10);
            } else {
                this.fingerSkeleton.active = false;
            }
        }, 0.1);


        this._allowTime = Date.now() + 200;

        this.refreshTarget();

        if (callback) callback();
    }

    // 手指位置偏移
    public setFingerOffsetPos(offX: number = 0, offY: number = 0) {
        let offsetPos = cc.v2(offX, offY);
        let originPos = this.fingerSkeleton.getPosition();
        let newPos = cc.v2(originPos.x + offsetPos.x, originPos.y + offsetPos.y);
        this.fingerSkeleton.setPosition(newPos);
    }

    public updateHollowOut() {
        let mask = this.hollowOut.getComponent(cc.Mask);
        mask.type = cc.Mask.Type.ELLIPSE;
        // let sp = mask.spriteFrame;
        // let iconPath = "Atlas/Guide/guide_rect";
        // ResourceManager.loadRes(iconPath, cc.SpriteFrame, (frame: cc.SpriteFrame) => {
        //     if (frame && cc.isValid(sp)) {
        //         if (frame instanceof cc.SpriteFrame && frame.getTexture) {
        //             sp = frame;
        //             Log.Debug("updateHollowOut - 更新镂空区域成功");
        //         }
        //     }
        // });
    }

    refreshTarget() {
        let mask = this.hollowOut.getComponent(cc.Mask);

        if (this._target) {
            // 将target的世界坐标转换为GuideUI的本地坐标
            const targetWorldPos = this._target.convertToWorldSpaceAR(cc.v2(0, 0));
            const targetLocalPos = this.node.convertToNodeSpaceAR(targetWorldPos);

            if (this._isBlack) {
                this.hollowOut.active = true;

                if (this._isSwipeGuide && this._swipeDirection) {
                    // 滑动引导：镂空区域只覆盖目标节点本身，不受滑动距离影响
                    // 滑动距离只用于手指动画路径，不影响镂空区域大小

                    // 判断是否为对角线方向（非水平且非垂直）
                    const isDiagonal = Math.abs(this._swipeDirection.x) > 0.1 && Math.abs(this._swipeDirection.y) > 0.1;

                    if (isDiagonal) {
                        // 对角线方向：镂空区域旋转以匹配滑动方向
                        // 计算滑动角度（弧度转角度）
                        const angleRad = Math.atan2(this._swipeDirection.y, this._swipeDirection.x);
                        const angle = angleRad * 180 / Math.PI;

                        // 镂空区域保持目标节点的大小和位置，只旋转
                        this.hollowOut.width = this._target.width * 1.25;
                        this.hollowOut.height = this._target.height;
                        this.hollowOut.setPosition(targetLocalPos);
                        this.hollowOut.angle = angle;

                        // 更新swipeNode的位置、大小和旋转
                        if (this.swipeNode) {
                            this.swipeNode.width = this.hollowOut.width;
                            this.swipeNode.height = this.hollowOut.height;
                            this.swipeNode.setPosition(this.hollowOut.getPosition());
                            this.swipeNode.angle = this.hollowOut.angle;
                        }
                    } else {
                        // 水平或垂直方向：保持原有逻辑不变，不旋转
                        this.hollowOut.width = this._target.width;
                        this.hollowOut.height = this._target.height;
                        this.hollowOut.setPosition(targetLocalPos);
                        this.hollowOut.angle = 0;

                        // 更新swipeNode的位置和大小（不旋转）
                        if (this.swipeNode) {
                            this.swipeNode.width = this.hollowOut.width;
                            this.swipeNode.height = this.hollowOut.height;
                            this.swipeNode.setPosition(this.hollowOut.getPosition());
                            this.swipeNode.angle = 0;
                        }
                    }
                } else {
                    // 普通引导：将target的尺寸设置到镂空层上
                    this.hollowOut.width = this._target.width;
                    this.hollowOut.height = this._target.height;
                    this.hollowOut.setPosition(targetLocalPos);
                    this.hollowOut.angle = 0; // 重置旋转角度

                    // 如果是滑动引导，同时更新swipeNode的位置
                    if (this._isSwipeGuide && this.swipeNode) {
                        this.swipeNode.setPosition(targetLocalPos);
                        this.swipeNode.angle = 0;
                    }
                }

                mask.alphaThreshold = 0.1;

                this.clickNode.node.active = this._isShowClickNode;

                this.clickNode.node.width = this.hollowOut.width;
                this.clickNode.node.height = this.hollowOut.height;

                this.clickNode.node.setPosition(this.hollowOut.getPosition());
            } else {
                this.hollowOut.active = false;

                this.clickNode.node.active = this._isShowClickNode;

                if (this._isShowClickNode) {
                    this.clickNode.node.width = this._target.width;
                    this.clickNode.node.height = this._target.height;

                    this.clickNode.node.setPosition(targetLocalPos);
                }
            }
        } else {
            this.hollowOut.active = false;
            this.clickNode.node.active = false;
        }

        // if (this._tipsShowTarget) {
        //     this.tipsTarget.setPosition(this._tipsShowTarget.getPosition());
        // } else {
        //     this.tipsTarget.setPosition(0, 0, 0);
        // }
    }

    /**
     * 展示滑动引导
     * @param target 镂空显示的目标
     * @param direction 滑动方向 (1,0)从左往右 (-1,0)从右往左 (0,1)从下往上 (0,-1)从上往下 (1,1)右下 (1,-1)右上 (-1,1)左下 (-1,-1)左上
     * @param swipeDistance 滑动距离，默认200
     * @param tipsShowTarget 是否显示提示框的目标
     * @param isBlack 是否显示黑色遮罩
     * @param callback 滑动完成回调
     */
    showSwipeTarget(target: cc.Node, direction: cc.Vec2, swipeDistance: number = 200, tipsShowTarget: cc.Node = null, isBlack: boolean = true, callback: Function = null) {
        this._target = target;
        this._tipsShowTarget = tipsShowTarget;
        this._isBlack = isBlack;
        this._isSwipeGuide = true;

        // 归一化方向向量，确保方向向量的长度为1（先克隆避免修改原始向量）
        const normalizedDirection = cc.v2(direction.x, direction.y).normalize();
        this._swipeDirection = normalizedDirection;
        this._swipeDistance = swipeDistance;
        this._swipeCallback = callback;
        this._swipeTarget = target;



        // 设置滑动区域
        this.setupSwipeNode(target, normalizedDirection, swipeDistance);

        this._allowTime = Date.now() + 200;

        this.refreshTarget();

        this.scheduleOnce(() => {
            // 计算滑动路径 - 转换为GuideUI的本地坐标
            const targetWorldPos = target.convertToWorldSpaceAR(cc.v2(0, 0));
            const targetLocalPos = this.node.convertToNodeSpaceAR(targetWorldPos);

            // 计算起始和结束位置，同时考虑x和y方向
            const halfDistance = swipeDistance / 2;
            this._swipeStartPos = cc.v2(
                targetLocalPos.x - normalizedDirection.x * halfDistance + 70,
                targetLocalPos.y - normalizedDirection.y * halfDistance - 70
            );
            this._swipeEndPos = cc.v2(
                targetLocalPos.x + normalizedDirection.x * halfDistance + 70,
                targetLocalPos.y + normalizedDirection.y * halfDistance - 70
            );

            // 显示手指在起始位置
            this.finger.active = true;
            this.finger.setPosition(this._swipeStartPos);

            this.startSwipeAnimation();
        }, 0.3);
    }

    /**
     * 设置滑动节点
     */
    private setupSwipeNode(target: cc.Node, direction: cc.Vec2, swipeDistance: number) {
        if (!target || !this.swipeNode) {
            Log.Debug("setupSwipeNode - target或swipeNode为空", "target:", !!target, "swipeNode:", !!this.swipeNode);
            return;
        }

        Log.Debug("setupSwipeNode - 开始设置", "target:", target.name, "swipeNode:", this.swipeNode.name);

        // 使用和refreshTarget相同的坐标转换逻辑
        const targetWorldPos = target.convertToWorldSpaceAR(cc.v2(0, 0));
        const targetLocalPos = this.node.convertToNodeSpaceAR(targetWorldPos);

        Log.Debug("setupSwipeNode - 坐标转换", "targetWorldPos:", `(${targetWorldPos.x.toFixed(2)}, ${targetWorldPos.y.toFixed(2)})`, "targetLocalPos:", `(${targetLocalPos.x.toFixed(2)}, ${targetLocalPos.y.toFixed(2)})`);

        // 设置滑动区域的大小和位置 - 和hollowOut保持一致
        this.swipeNode.width = target.width;
        this.swipeNode.height = target.height;
        this.swipeNode.setPosition(targetLocalPos);
        this.swipeNode.active = true;

        // 计算滑动路径 - 转换为GuideUI的本地坐标，同时考虑x和y方向
        const halfDistance = swipeDistance / 2;
        this._swipeStartPos = cc.v2(
            targetLocalPos.x - direction.x * halfDistance,
            targetLocalPos.y - direction.y * halfDistance
        );
        this._swipeEndPos = cc.v2(
            targetLocalPos.x + direction.x * halfDistance,
            targetLocalPos.y + direction.y * halfDistance
        );

        Log.Debug("setupSwipeNode - 设置完成", "width:", this.swipeNode.width, "height:", this.swipeNode.height, "position:", `(${this.swipeNode.x.toFixed(2)}, ${this.swipeNode.y.toFixed(2)})`, "active:", this.swipeNode.active);

        // 验证设置后的位置
        const actualPos = this.swipeNode.getPosition();
        Log.Debug("setupSwipeNode - 验证位置", "实际位置:", `(${actualPos.x.toFixed(2)}, ${actualPos.y.toFixed(2)})`);

        // 确保滑动节点在最上层
        this.swipeNode.setSiblingIndex(this.swipeNode.parent.children.length - 1);

        // 注册滑动节点的触摸事件
        this.addSwipeNodeEvents();
    }

    /**
     * 添加滑动节点事件监听
     */
    private addSwipeNodeEvents() {
        Log.Debug("addSwipeNodeEvents - 开始注册触摸事件", "swipeNode存在:", !!this.swipeNode, "swipeNode激活:", this.swipeNode?.active);

        this.swipeNode.on(cc.Node.EventType.TOUCH_START, this.onSwipeTouchStart, this);
        this.swipeNode.on(cc.Node.EventType.TOUCH_MOVE, this.onSwipeTouchMove, this);
        this.swipeNode.on(cc.Node.EventType.TOUCH_END, this.onSwipeTouchEnd, this);
        this.swipeNode.on(cc.Node.EventType.TOUCH_CANCEL, this.onSwipeTouchCancel, this);

        // 添加一个简单的测试触摸事件
        this.swipeNode.on(cc.Node.EventType.TOUCH_START, () => {
            Log.Debug("swipeNode 触摸测试 - 触摸开始");
        }, this);

        Log.Debug("addSwipeNodeEvents - 触摸事件注册完成");
    }

    /**
     * 移除滑动节点事件监听
     */
    private removeSwipeNodeEvents() {
        this.swipeNode.off(cc.Node.EventType.TOUCH_START, this.onSwipeTouchStart, this);
        this.swipeNode.off(cc.Node.EventType.TOUCH_MOVE, this.onSwipeTouchMove, this);
        this.swipeNode.off(cc.Node.EventType.TOUCH_END, this.onSwipeTouchEnd, this);
        this.swipeNode.off(cc.Node.EventType.TOUCH_CANCEL, this.onSwipeTouchCancel, this);
    }

    /**
     * 开始滑动动画
     */
    private startSwipeAnimation() {
        if (!this._isSwipeGuide || !this.finger.active) return;

        // 停止之前的动画
        this.stopSwipeAnimation();

        // 创建滑动动画
        this.finger.setPosition(this._swipeStartPos);
        this.finger.opacity = 255;
        this._swipeAnimation = cc.tween(this.finger)
            .to(1.5, { position: cc.v3(this._swipeEndPos.x, this._swipeEndPos.y, 0) }, { easing: cc.easing.sineInOut })
            .to(0.5, { opacity: 0 }, { easing: cc.easing.sineInOut })
            .delay(0.5)
            .call(() => {
                // 循环播放
                if (this._isSwipeGuide) {
                    this.startSwipeAnimation();
                }
            })
            .start();
    }

    /**
     * 停止滑动动画
     */
    private stopSwipeAnimation() {
        if (this._swipeAnimation) {
            this._swipeAnimation.stop();
            this._swipeAnimation = null;
        }
    }

    /**
     * 完成滑动引导
     */
    completeSwipeGuide() {
        if (this._isSwipeGuide) {
            this.stopSwipeAnimation();

            if (this._swipeCallback) {
                this._swipeCallback();
                this._swipeCallback = null;
            } else {
                EventCenter.dispatchEvent(EventName.GuideSwipeComplete);
            }
        }
    }

    /**
     * 滑动节点触摸开始事件
     */
    private onSwipeTouchStart(event: cc.Event.EventTouch) {
        Log.Debug("=== onSwipeTouchStart 被调用 ===", "target:", event.target.name, "currentTarget:", event.currentTarget.name, "swipeGuide:", this._isSwipeGuide);
        if (!this._isSwipeGuide || !this._swipeTarget) {
            Log.Debug("onSwipeTouchStart - 条件不满足，忽略事件");
            return;
        }

        // 强制打印边界信息
        this._hasPrintedBounds = false;

        // 将触摸事件透传给GameUI的网格组
        this.passTouchEventToGameUI(event, cc.Node.EventType.TOUCH_START);
    }

    /**
     * 滑动节点触摸移动事件
     */
    private onSwipeTouchMove(event: cc.Event.EventTouch) {
        if (!this._isSwipeGuide || !this._swipeTarget) return;

        // 将触摸事件透传给GameUI的网格组
        this.passTouchEventToGameUI(event, cc.Node.EventType.TOUCH_MOVE);
    }

    /**
     * 滑动节点触摸结束事件
     */
    private onSwipeTouchEnd(event: cc.Event.EventTouch) {
        if (!this._isSwipeGuide || !this._swipeTarget) return;

        // 将触摸事件透传给GameUI的网格组
        this.passTouchEventToGameUI(event, cc.Node.EventType.TOUCH_END);
    }

    /**
     * 滑动节点触摸取消事件
     */
    private onSwipeTouchCancel(event: cc.Event.EventTouch) {
        if (!this._isSwipeGuide || !this._swipeTarget) return;

        // 将触摸事件透传给GameUI的网格组
        this.passTouchEventToGameUI(event, cc.Node.EventType.TOUCH_CANCEL);
    }

    /**
     * 将触摸事件透传给GameUI
     */
    private passTouchEventToGameUI(event: cc.Event.EventTouch, eventType: string) {
        if (!this._swipeTarget) {
            Log.Debug("passTouchEventToGameUI - _swipeTarget为空");
            return;
        }

        // 获取GameUI实例
        const gameUI = GameMgr.Instance.getGameUI();
        if (!gameUI) {
            Log.Debug("passTouchEventToGameUI - gameUI为空");
            return;
        }

        // 在GuideUI中限制触摸位置，然后传递给GameUI
        const clampedEvent = this.clampTouchEventToSwipeBounds(event);

        // 调用GameUI的引导触摸事件处理方法
        gameUI.handleGuideTouchEvent(clampedEvent, eventType);
    }

    /**
     * 限制触摸事件的位置在swipeNode边界内
     */
    private clampTouchEventToSwipeBounds(event: cc.Event.EventTouch): cc.Event.EventTouch {

        if (!this.swipeNode || !this.swipeNode.active) {
            return event;
        }

        // 只在第一次触摸时打印边界信息
        if (!this._hasPrintedBounds) {
            this.printSwipeNodeBounds();
            this._hasPrintedBounds = true;
        }

        // 获取原始触摸位置
        const originalLocation = event.getLocation();
        const originalPreviousLocation = event.getPreviousLocation();

        // 限制位置在swipeNode边界内
        const clampedLocation = this.clampPositionToSwipeBounds(originalLocation);
        const clampedPreviousLocation = this.clampPositionToSwipeBounds(originalPreviousLocation);

        // 打印传出的点坐标
        const isLocationInBounds = this.isPositionInSwipeBounds(clampedLocation);
        const isPreviousLocationInBounds = this.isPositionInSwipeBounds(clampedPreviousLocation);


        // 创建限制后的触摸事件对象
        const clampedEvent = {
            ...event,
            getLocation: () => clampedLocation,
            getPreviousLocation: () => clampedPreviousLocation,
            target: event.target,
            currentTarget: event.currentTarget
        } as cc.Event.EventTouch;

        return clampedEvent;
    }

    /**
     * 限制位置在swipeNode边界内
     */
    private clampPositionToSwipeBounds(worldPos: cc.Vec2): cc.Vec2 {
        if (!this.swipeNode || !this.swipeNode.active) return worldPos;

        // 将世界坐标转换为swipeNode的本地坐标
        const localPos = this.swipeNode.convertToNodeSpaceAR(worldPos);

        // 获取swipeNode的边界
        const nodeWidth = this.swipeNode.width;
        const nodeHeight = this.swipeNode.height;
        const halfWidth = nodeWidth / 2;
        const halfHeight = nodeHeight / 2;

        // 限制在边界内
        const clampedLocalPos = cc.v2(
            Math.max(-halfWidth, Math.min(halfWidth, localPos.x)),
            Math.max(-halfHeight, Math.min(halfHeight, localPos.y))
        );

        // 转换回世界坐标
        const clampedWorldPos = this.swipeNode.convertToWorldSpaceAR(clampedLocalPos);

        return clampedWorldPos;
    }

    /**
     * 打印swipeNode的边界信息
     */
    private printSwipeNodeBounds() {
        if (!this.swipeNode || !this.swipeNode.active) {
            Log.Debug("printSwipeNodeBounds: swipeNode不存在或未激活");
            return;
        }

        // 获取swipeNode的世界位置
        const swipeNodeWorldPos = this.swipeNode.convertToWorldSpaceAR(cc.v2(0, 0));

        // 计算左上角世界坐标
        const leftTopLocal = cc.v2(-this.swipeNode.width / 2, this.swipeNode.height / 2);
        const leftTopWorld = this.swipeNode.convertToWorldSpaceAR(leftTopLocal);

        // 计算右下角世界坐标
        const rightBottomLocal = cc.v2(this.swipeNode.width / 2, -this.swipeNode.height / 2);
        const rightBottomWorld = this.swipeNode.convertToWorldSpaceAR(rightBottomLocal);

        // Log.Debug(`swipeNode边界信息: 位置(${swipeNodeWorldPos.x.toFixed(2)}, ${swipeNodeWorldPos.y.toFixed(2)}) 尺寸(${this.swipeNode.width}x${this.swipeNode.height}) 左上角(${leftTopWorld.x.toFixed(2)}, ${leftTopWorld.y.toFixed(2)}) 右下角(${rightBottomWorld.x.toFixed(2)}, ${rightBottomWorld.y.toFixed(2)}) 范围(x:${leftTopWorld.x.toFixed(2)}~${rightBottomWorld.x.toFixed(2)}, y:${rightBottomWorld.y.toFixed(2)}~${leftTopWorld.y.toFixed(2)})`);
    }

    /**
     * 验证位置是否在swipeNode边界内
     */
    public isPositionInSwipeBounds(worldPos: cc.Vec2): boolean {
        if (!this.swipeNode || !this.swipeNode.active) return false;

        // 将世界坐标转换为swipeNode的本地坐标（自动处理旋转）
        const localPos = this.swipeNode.convertToNodeSpaceAR(worldPos);

        // 使用引擎API：创建矩形并检查点是否在矩形内
        const rect = cc.rect(
            -this.swipeNode.width / 2,
            -this.swipeNode.height / 2,
            this.swipeNode.width,
            this.swipeNode.height
        );

        return rect.contains(localPos);
    }

    /**
     * 点击区域被点击
     */
    private onClickTarget() {
        if (Date.now() < this._allowTime) return;

        if (this._clickNodeCb != null) {
            this._clickNodeCb();
            this._clickNodeCb = null;
        } else {
            EventCenter.dispatchEvent(EventName.GuideClick);
        }

    }

    /**
    * 全屏遮罩层被点击
    */
    private onClickMask() {
        if (Date.now() < this._allowTime) return;

        if (this._clickMaskCb != null) {
            this._clickMaskCb();
            this._clickMaskCb = null;
        } else {
            EventCenter.dispatchEvent(EventName.GuideClickMask);
        }
    }

}
