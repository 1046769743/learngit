import { ChipSlot } from '../../Module/Game/ChipSlot';
import { GameMgr } from '../../Module/Game/GameMgr';
import { ChipSlotStatus, ChipSlotType } from '../../Common/EnumDefine';
import { NativeApi } from '../../Platform/Android/NativeApi';
import { EventName } from '../../Common/EventName';
import { SOUND_NAME, SoundManager } from '../../Module/Audio/SoundManager';
import { Log } from '../../FrameWork/Log';
import GameUI from './GameUI';
const { ccclass, property } = cc._decorator;

@ccclass
export default class ChipSlotItem extends cc.Component {
    @property(cc.Node)
    public bg: cc.Node = null;

    @property(cc.Node)
    public lock: cc.Node = null;

    @property(cc.Node)
    public canUnlock: cc.Node = null;

    @property(cc.Node)
    public temp_lock: cc.Node = null;

    @property(cc.Node)
    public diamond_lock: cc.Node = null;

    @property(cc.Node)
    public saoGuang: cc.Node = null;

    // @property(cc.Animation)
    // public slotAnim: cc.Animation = null;

    @property(sp.Skeleton)
    public spine: sp.Skeleton = null;

    @property(cc.Node)
    public btn: cc.Node = null;

    private _slotId: number = 0;
    private _chipSlot: ChipSlot = null;
    private _gameUI: GameUI = null;
    private _isUnLock: boolean = false;

    protected onLoad(): void {
        this.btn.on("click", this.onSlotClick, this);
    }

    // protected onDestroy() {
    //     this.btn.off(Button.EventType.CLICK, this.onSlotClick, this);
    // }

    public getSlotId() {
        return this._slotId;
    }

    public onSlotClick(event: cc.Event) {
        // 注意这种方式注册的事件，无法传递 customEventData
        Log.Debug("ChipSlotItem callback slotId: " + this._slotId);
        if (this._chipSlot == null) {
            Log.Debug("ChipSlotItem callback _chipSlot == null");
            return;
        }

        // 如果当前未解锁
        if (!this._chipSlot.IsUnLock()) {
            Log.Debug("当前未解锁");
            // 是否是临时插槽
            if (this._chipSlot.SlotType == ChipSlotType.Temporary) {
                NativeApi.instance.unlockChipBox(ChipSlotType.Temporary, this._slotId);
                return;
            }

            // 是否是永久插槽
            if (this._chipSlot.SlotType == ChipSlotType.Permanent) {
                NativeApi.instance.unlockChipBox(ChipSlotType.Permanent, this._slotId);
                return;
            }

            //是否是普通插槽
            if (this._chipSlot.SlotType == ChipSlotType.Session) {
                Log.Debug("普通插槽");
                if (this._chipSlot.SlotSatus == ChipSlotStatus.CanUnLock) {
                    this._gameUI.unlockSlot(this._slotId);
                    return;
                } else {
                    Log.Debug("普通插槽解锁 未达到解锁条件");
                    return;
                }
            }
        }

        this._gameUI.onClickSlot(this._slotId);
    }

    public Init(chipSlot: ChipSlot, gameUI: GameUI) {
        Log.Debug("ChipSlotItem Init slotId: " + chipSlot.SlotId);
        this._chipSlot = chipSlot;
        this._slotId = chipSlot.SlotId;
        this._gameUI = gameUI;

        this._isUnLock = this._chipSlot.IsUnLock();

        this.UpdateView();
    }

    /**
     * 移除值小于value的筹码
     * @param value 
     */
    public removeChipsUnderValue(value: number) {

        //未解锁的不用管
        if (this._chipSlot.IsUnLock()) {
            return;
        }

        this._chipSlot.removeChipUnderValue(value);


    }

    public UpdateView() {
        if (this._chipSlot == null) {
            Log.Debug("ChipSlotItem UpdateView _chipSlot == null");
            return;
        }
        this.bg.active = true;
        if (this._chipSlot.IsUnLock()) {
            this.bg.active = true;
            this.lock.active = false;
            this.canUnlock.active = false;
            this.temp_lock.active = false;
            this.diamond_lock.active = false;
            this.saoGuang.active = false;
        } else if (this._chipSlot.SlotSatus == ChipSlotStatus.CanUnLock) {
            this.lock.active = false;
            this.canUnlock.active = true;
            this.temp_lock.active = false;
            this.diamond_lock.active = false;
            this.saoGuang.active = true;
            this.canUnlock.setContentSize(320, 400);
            // this.slotAnim.play("SlotItem_idel");
        } else {
            if (this._chipSlot.SlotType == ChipSlotType.Temporary) {
                this.lock.active = false;
                this.canUnlock.active = false;
                this.temp_lock.active = true;
                this.temp_lock.setPosition(0, 0);
                this.diamond_lock.active = false;
                this.saoGuang.active = false;
            } else if (this._chipSlot.SlotType == ChipSlotType.Permanent) {
                this.lock.active = false;
                this.canUnlock.active = false;
                this.temp_lock.active = false;
                this.diamond_lock.active = true;
                this.saoGuang.active = false;
            } else {
                this.lock.active = true;
                this.canUnlock.active = false;
                this.temp_lock.active = false;
                this.diamond_lock.active = false;
                this.saoGuang.active = false;
            }
        }
    }

    // 可解锁状态动画
    public CanUnLockAnim() {
        if (this._chipSlot.SlotSatus == ChipSlotStatus.CanUnLock) {
            this.lock.active = false;
            this.canUnlock.active = true;
            this.temp_lock.active = false;
            this.diamond_lock.active = false;
            this.saoGuang.active = true;

            // 播放解锁动画
            // let self = this;
            // // 停止播放当前动画
            // this.slotAnim.play("SlotItem_Unlocking");
            // this.slotAnim.on(cc.Animation.EventType.FINISHED, () => {
            //     self.slotAnim.stop();
            //     self.UpdateView();
            //     self.slotAnim.off(cc.Animation.EventType.FINISHED);
            // }, this)

            this.UpdateView();
        }
    }

    // 合成解锁
    public SessionUnlockAnim() {
        this.SlotUnlockAnim();
    }

    // 临时插槽解锁
    public TryTempUnlock() {
        this.SlotUnlockAnim();
    }

    // 砖石插槽解锁
    public TryDiamondUnlock() {
        this.SlotUnlockAnim();
    }

    private SlotUnlockAnim() {
        SoundManager.Instance.PlaySound(SOUND_NAME.Slot_Unlock);
        this._gameUI.SetPlayingAnimStatus();
        let self = this;
        GameMgr.Instance.PrintSlotChipsNum();
        Log.Debug("-------------------------------")
        self._chipSlot.UnLock();
        GameMgr.Instance.PrintSlotChipsNum();
        // // 停止播放当前动画
        // self.slotAnim.play("SlotItem_move");
        // this.slotAnim.on(cc.Animation.EventType.FINISHED, () => {
        //     Log.Debug("TryTempUnlock anim end");

        //     self.slotAnim.stop();
        //     self.UpdateView();
        //     self.slotAnim.off(cc.Animation.EventType.FINISHED);
        //     self.PlayUnlockSuccessEffect();
        //     this.scheduleOnce(() => {
        //         self._gameUI.PlayingAnimFinish();
        //     }, 1)
        // }, this)
        self.UpdateView();
        self.PlayUnlockSuccessEffect();
    }

    // 尝试播放提示合成动效
    public TryPlayMegerEffect() {
        if (this._chipSlot == null)
            return false;

        if (this._chipSlot.CanMerge()) {
            this.showMergeEffect();
            return true;
        }

        return false;
    }

    // 播放解锁成功的效果
    public PlayUnlockSuccessEffect() {
        this.setSpineActive(true)
        this.spine.setAnimation(0, "animation2", false);
        let self = this;
        this.scheduleOnce(() => {
            self.spine.node.active = false;
        }, 2)
    }

    // 隐藏合成动效
    public HideMegerEffect() {
        if (this._chipSlot == null)
            return;

        this.setSpineActive(false)
    }

    public showMergeEffect() {
        if (this._chipSlot == null) {
            return;
        }

        this.setSpineActive(true);
        this.spine.setAnimation(0, "animation", true);
    }

    private setSpineActive(isActive: boolean) {
        this.spine.node.active = isActive;
    }

}

