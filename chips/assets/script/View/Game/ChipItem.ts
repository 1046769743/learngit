import { Chip } from '../../Module/Game/Chip';
import { ObjectPoolManager } from '../../Common/ObjectPoolManager';
import { Log } from '../../FrameWork/Log';
import ResourceManager from '../../FrameWork/ResourceManager';
const { ccclass, property } = cc._decorator;

@ccclass
export default class ChipItem extends cc.Component {
    @property(cc.Sprite)
    public chipSprite: cc.Sprite = null;

    @property(cc.Node)
    public maskNode: cc.Node = null;

    @property(cc.Sprite)
    public maskSprite: cc.Sprite = null;

    @property(sp.Skeleton)
    bombSpine: sp.Skeleton = null;

    private _chipId: number = 0;
    private _curTween: any = null;
    private _localPositon: cc.Vec3 = null;
    private _inSlotIndex: number = 0;

    private _spineSkinName: string = ``;

    Init(chip: Chip) {
        if (chip.Id == this._chipId)
            return;
        this._chipId = chip.Id;
        this.LoadChipSprite(this._chipId);
        this.maskNode.active = false;
        this.chipSprite.node.active = true;
        this.initSpineInfo();
    }

    private initSpineInfo() {
        this._spineSkinName = `piece${this._chipId / 10}`;
        this.bombSpine.setSkin(this._spineSkinName);
        this.bombSpine.node.active = false;
    }

    ChipId() {
        return this._chipId;
    }

    WordPos() {
        let worldPos = this.node.convertToWorldSpaceAR(cc.Vec2.ZERO);
        return new cc.Vec3(worldPos.x, worldPos.y, 0);
    }

    getSlotIndex() {
        return this._inSlotIndex;
    }

    /**
     * 设置筹码的index （移除道具会用到）
     * @param newIndex 
     */
    setSlotIndex(newIndex) {
        this._inSlotIndex = newIndex;
    }

    LoadChipSprite(chipId: number) {
        let path = "Atlas/Game/chips/chip_" + chipId;
        ResourceManager.loadRes(path, cc.SpriteFrame, (spriteFrame) => {
            if (spriteFrame) {
                this.chipSprite.spriteFrame = spriteFrame;
                this.maskSprite.spriteFrame = spriteFrame;
            }
        });
    }

    SetLayerIndex(index: number, inSlotIndex: number) {
        this.node.setSiblingIndex(index);
        this._inSlotIndex = inSlotIndex;
        this.tryShowMaskNode();
    }

    tryShowMaskNode() {
        if (this._inSlotIndex == 9) {
            this.chipSprite.node.active = false;
            this.maskNode.active = true;
        } else {
            this.chipSprite.node.active = true;
            this.maskNode.active = false;
        }
    }

    PlaySelectAnim() {
        this.StopCurAnim();
        this.chipSprite.node.active = true;
        this.maskNode.active = false;
        // 播放0.1s向上位移28像素的动画,然后做pingpong动画
        this._localPositon = new cc.Vec3(this.node.position.x, this.node.position.y, this.node.position.z);
        Log.Debug("PlaySelectAnim: " + this._localPositon);
        let tween = cc.tween(this.node);
        this._curTween = tween;
        let x = this._localPositon.x;
        let y = this._localPositon.y;
        let self = this;
        tween.to(0.15, { position: new cc.Vec3(x, y + 44, 0) }, { easing: 'linear' })
            .call(() => {
                // 保存循环动画的 tween，以便后续可以停止
                self._curTween = cc.tween(self.node)
                    .to(0.5, { position: new cc.Vec3(x, y + 22, 0) }, { easing: 'linear' })
                    .to(0.5, { position: new cc.Vec3(x, y + 44, 0) }, { easing: 'linear' })
                    .union()
                    .repeatForever()
                    .start();
            })
            .start();

        // this.scheduleOnce(() => {
        //     tween.stop();

        // }, 0.13);
    }

    /**
     * 播放碎裂动画
     */
    public playCrashAni(callback: Function = null) {
        this.bombSpine.node.active = true;
        this.chipSprite.node.active = false;
        this.maskNode.active = false;

        this.bombSpine.setAnimation(0, `animation`, false);

        this.bombSpine.setCompleteListener(() => {
            this.bombSpine.node.active = false;

            if (callback != null) {
                callback();
            }
        })
    }

    StopSelectAnim() {
        if (this._curTween != null) {
            this._curTween.stop();
            this._curTween = null;

            this.tryShowMaskNode();
            let tween = cc.tween(this.node);
            this._curTween = tween;
            let x = this._localPositon.x;
            let y = this._localPositon.y;
            tween.to(0.15, { position: new cc.Vec3(x, y, 0) }, { easing: 'sineOut' })
                .start();
        }
    }

    MoveToPos(pos: cc.Vec3, time: number = 0.3, callback: Function = null, easingData: any = { easing: 'sineOut' }, isShowMask: boolean = true) {
        Log.Debug(`[CHECK] 棋子开始移动 ChipsItem MoveToPos: ${pos}`);
        this.StopCurAnim();
        this.chipSprite.node.active = true;
        this.maskNode.active = false;
        this._localPositon = pos;
        let tween = cc.tween(this.node);
        this._curTween = tween;
        // circOut 发牌
        // sineOut 移动
        let self = this;
        tween.to(time, { position: pos }, easingData)
            .call(() => {
                if (isShowMask) {
                    self.tryShowMaskNode();
                }

                if (callback) {
                    Log.Debug(`[CHECK] 棋子结束移动`);
                    callback();
                }
            })
            .start();
    }

    ScaleTo(scale: number, time: number = 0.3, callback: Function = null) {
        this.StopCurAnim();
        let tween = cc.tween(this.node);
        this._curTween = tween;
        tween.to(time, { scaleX: scale, scaleY: scale }, { easing: 'sineInOut' })
            .call(() => {
                if (callback) {
                    callback();
                }
            })
            .start();
    }

    PlayMoveFailAnim() {
        if (this._curTween != null) {
            this._curTween.stop();
            this._curTween = null;
        }

        let self = this;
        let tween = cc.tween(this.node);
        this._curTween = tween;
        let y = this.node.position.y;
        tween.to(0.1, { position: new cc.Vec3(this._localPositon.x + 20, y, 0) }, { easing: 'sineInOut' })
            .to(0.1, { position: new cc.Vec3(this._localPositon.x - 20, y, 0) })
            .union()
            .repeat(2)
            .to(0.1, { position: new cc.Vec3(this._localPositon.x, y, 0) })
            .to(0.1, { position: new cc.Vec3(this._localPositon.x, this._localPositon.y, 0) })
            .call(() => {
                self.tryShowMaskNode();
            })
            .start();
    }

    StopCurAnim() {
        if (this._curTween != null) {
            this._curTween.stop();
            this._curTween = null;
        }

        this.tryShowMaskNode();

        if (this._localPositon != null) {
            this.node.setPosition(this._localPositon);
        }


        // Log.Debug("======================= StopCurAnim ");
    }

    // 回收
    public Recycle() {
        Log.Debug("ChipItem Recycle");
        this.StopCurAnim();
        this._chipId = 0;
        this._inSlotIndex = 0;
        this._curTween = null;
        this._localPositon = null;
        this.node.active = false;
        this.node.parent = null;
        this.bombSpine.setCompleteListener(null);
        ObjectPoolManager.instance.putNode(this.node);
    }
}

