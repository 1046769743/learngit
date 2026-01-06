import { GameMgr } from '../../Module/Game/GameMgr';
import { ObjectPoolManager } from '../../Common/ObjectPoolManager';
import { NativeApi } from '../../Platform/Android/NativeApi';
import { ChipSlotStatus, ChipSlotType } from '../../Common/EnumDefine';
import { EventName } from '../../Common/EventName';
import { SOUND_NAME, SoundManager } from '../../Module/Audio/SoundManager';
import { ReceiveEventManager } from '../../Platform/Android/ReceiveEventManager';
import { GuideMgr } from '../../Module/Guide/GuideMgr';
import { EventCenter } from '../../FrameWork/EventCenter';
import { Log } from '../../FrameWork/Log';
import { Tools } from '../../Common/Tools';
import { Chip } from '../../Module/Game/Chip';
import ChipSlotItem from './ChipSlotItem';
import ChipItem from './ChipItem';
import ComboEffect from './ComboEffect';
import MegerEffect from './MegerEffect';

const { ccclass, property } = cc._decorator;

@ccclass
export default class GameUI extends cc.Component {
    @property([cc.Node])
    public chipSlotContainer: cc.Node[] = [];

    @property(cc.Prefab)
    public chipItemPrefab: cc.Prefab = null;

    @property(cc.Prefab)
    public comboPrefab: cc.Prefab = null;

    @property(cc.Prefab)
    public mergerEffectPrefab: cc.Prefab = null;

    @property(cc.Node)
    public effectGroup: cc.Node = null;

    @property(cc.Node)
    public chipsGroup: cc.Node = null;

    @property(cc.Button)
    public btnDeal2: cc.Button = null;

    @property(cc.Button)
    public btnShuff2: cc.Button = null;

    @property(cc.Button)
    public btnRemove2: cc.Button = null;

    @property(cc.Node)
    public slotNode: cc.Node = null;

    // 属性
    private _chipItemListMap: Map<number, ChipItem[]> = new Map<number, ChipItem[]>();
    private _chipSlotList: ChipSlotItem[] = [];
    private _curSlectedSlotId: number = -1;
    private _curPlayingAnim: boolean = false; //标记是否在播放动画
    private _isMerge: boolean = false; //标记是否在合成
    private _isGameStart = false; //游戏开始标记

    public get curPlayingAnim() {
        return this._curPlayingAnim;
    }

    // 方法
    public getChopItemListMap(index: number): ChipItem[] {
        return this._chipItemListMap.get(index);
    }

    protected onLoad(): void {
        cc.systemEvent.on(cc.SystemEvent.EventType.KEY_DOWN, this.onKeyDown, this);

        this.btnDeal2.node.on("click", this.DealChips, this);
        this.btnShuff2.node.on("click", this.OnClickShuff, this);
        this.btnRemove2.node.on("click", this.onClickRemove, this);

        EventCenter.on(EventName.GuideDeal, this.DealChips, this);
        EventCenter.on(EventName.GuideMerge, this.MergeChips, this);
        EventCenter.on(EventName.AutoMerge, this.MergeChips, this);
        EventCenter.on(EventName.GuidShuff, this.OnClickShuff, this);
        EventCenter.on(EventName.ScreenClick, this.onScreenClick, this);
        EventCenter.on(EventName.RemoveChipEvent, this.onRemoveChip, this);
        EventCenter.on(EventName.AutoUnlockSlotEvent, this.onAutoUnlockSlot, this);
        EventCenter.on(EventName.NewUserWelfareReceivedEvent, this.onNewUserWelfareReceived, this);
    }

    onDestroy() {
        cc.systemEvent.off(cc.SystemEvent.EventType.KEY_DOWN, this.onKeyDown, this);

        EventCenter.off(EventName.GuideDeal, this.DealChips, this);
        EventCenter.off(EventName.GuideMerge, this.MergeChips, this);
        EventCenter.off(EventName.AutoMerge, this.MergeChips, this);
        EventCenter.off(EventName.GuidShuff, this.OnClickShuff, this);
        EventCenter.off(EventName.ScreenClick, this.onScreenClick, this);
        EventCenter.off(EventName.RemoveChipEvent, this.onRemoveChip, this);
        EventCenter.off(EventName.AutoUnlockSlotEvent, this.onAutoUnlockSlot, this);
        EventCenter.off(EventName.NewUserWelfareReceivedEvent, this.onNewUserWelfareReceived, this);
    }

    protected start(): void {
        this.InitView();
    }

    onKeyDown(event: cc.Event.EventKeyboard) {
        switch (event.keyCode) {
            case cc.macro.KEY.a:
                // 打印当前筹码
                Log.Debug("游戏页 打印当前筹码的gamedata数据");
                let chipSlotList = GameMgr.Instance.GetChipsSlotList();
                for (let i = 0; i < chipSlotList.length; i++) {
                    let slotData = chipSlotList[i];
                    Log.Debug("游戏页 onKeyDown slotId: " + slotData.SlotId + " slotData.ChipsList.length: " + slotData.ChipsList.length + " slotData.SlotType: " + slotData.SlotType);
                    for (let j = 0; j < slotData.ChipsList.length; j++) {
                        const chip = slotData.ChipsList[j];
                        Log.Debug("游戏页 onKeyDown slotId: " + slotData.SlotId + " chipId: " + chip.Id);
                    }
                }
                break;
            case cc.macro.KEY.b:
                ReceiveEventManager.OnGameReplayEvent();
                break;
            case cc.macro.KEY.c:
                let worldPos1 = this._chipSlotList[8].node.convertToWorldSpaceAR(cc.Vec2.ZERO);
                EventCenter.dispatchEvent(EventName.RefreshRedInfo, new cc.Vec3(worldPos1.x, worldPos1.y, 0), 10, true, 10);
                let worldPos2 = this._chipSlotList[2].node.convertToWorldSpaceAR(cc.Vec2.ZERO);
                EventCenter.dispatchEvent(EventName.RefreshRedInfo, new cc.Vec3(worldPos2.x, worldPos2.y, 0), 10, true, 10);
                break;
            case cc.macro.KEY.d:
                ReceiveEventManager.OnShowFloatBoxEvent();
                break;
            case cc.macro.KEY.e:

                break;
        }
    }

    // 初始化游戏是会调用
    InitView() {
        let slotDataList = GameMgr.Instance.GetChipsSlotList();
        Log.Debug("游戏页 InitView slotDataList: " + slotDataList.length);
        Log.Debug("游戏页 InitView chipSlotContainer: " + this.chipSlotContainer.length);
        for (let i = 0; i < slotDataList.length; i++) {
            let slotData = slotDataList[i];
            let chipSlotItem = this.chipSlotContainer[i].getComponent(ChipSlotItem);
            chipSlotItem.Init(slotData, this);
            this._chipSlotList.push(chipSlotItem);

            let chipItemList = [];
            Log.Debug("游戏页 InitView" + " 槽位ID: " + slotData.SlotId + " slotData.ChipsList.length: " + slotData.ChipsList.length);
            for (let j = 0; j < slotData.ChipsList.length; j++) {
                let chipItem: ChipItem = this.CreateChipItem(this.GetChipItemPos(j, slotData.SlotId), slotData.ChipsList[j])
                chipItemList.push(chipItem);
                chipItem.SetLayerIndex(this.GetLayerIndex(j, i), j);
            }
            this._chipItemListMap.set(i, chipItemList);
        }

        this.refreshShuffBtn();
        this.refreshBtn();
        this.refreshSlotAnim();
        this.refreshRemoveBtn();

        this.checkGameOver();

        Log.Debug("游戏页 InitView  初始化游戏完成");

        GameMgr.Instance.GameUI = this;

        this._isGameStart = true;
    }

    // 判断游戏是否结束
    checkGameOver() {
        let turp = GameMgr.Instance.isGameOver();
        Log.Debug("游戏页 发牌完成判断是否 gameOver turp: " + turp);
        if (turp[0]) {

            if (!(cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative)) {
                GameMgr.Instance.ResartGame();
                NativeApi.instance.onGameOver();
                return;
            }

            let tempSlotId = GameMgr.Instance.GetLockTempSlotId();
            let unLockSlotCount = GameMgr.Instance.GetUnlockTempSlotNum();
            NativeApi.instance.onShowUnlockChipBoxDialog(tempSlotId, GameMgr.Instance.getRemainShuffleTimes(), GameMgr.Temp_Slot_Max_Num - unLockSlotCount);
        }
    }

    //#region 发牌
    // 发牌
    DealChips() {
        Log.Debug(`[CHECK] 发牌 Start this._curPlayingAnim: ${this._curPlayingAnim}, this._isSlotUnlocking: ${this._isSlotUnlocking}, this._isMerge: ${this._isMerge}`)
        if (this._curPlayingAnim) {
            Log.Debug("====== 当前正在播放动画 =======")
            return;
        }

        if (this._isSlotUnlocking) {
            Log.Debug("========槽位解锁未完成==========");
            return;
        }

        if (this._isMerge) {
            Log.Debug("========合成未完成==========");
            return;
        }

        for (let i = 0; i < 12; i++) {
            this.stopSelectChpisAnim(i);
        }
        NativeApi.instance.onClickDealCard();

        var dealChipsMap = null;

        dealChipsMap = GameMgr.Instance.DealChips();

        Log.Debug(`[CHECK] 发牌 数据变更结束 dealChipsMap: ${dealChipsMap}`);

        if (dealChipsMap == null) {
            return;
        }

        SoundManager.Instance.PlaySound(SOUND_NAME.Deal_Chips);
        NativeApi.instance.onVibrate();
        this.SetPlayingAnimStatus();
        let slotDataList = GameMgr.Instance.GetChipsSlotList();
        let finishTime = 0.4;
        let moveTime = 0.25;
        let self = this;
        (dealChipsMap as Map<number, Chip[]>).forEach((value, key) => {
            if (!this._chipItemListMap.has(key)) {
                this._chipItemListMap.set(key, []);
            }
            let slotData = slotDataList[key];
            let chipItemList = this._chipItemListMap.get(key);
            Log.Debug("游戏页 发牌 slotId: " + key + " 发牌数量: " + value.length + " slotData.ChipsList.length: " + slotData.ChipsList.length);
            for (let i = 0; i < value.length; i++) {
                let index = slotData.ChipsList.length - value.length + i;
                Log.Debug("游戏页 发牌 index: " + index);
                let chipItem: ChipItem = this.CreateChipItem(new cc.Vec3(-228, -788, 0), value[i])
                chipItemList.push(chipItem);
                this.scheduleOnce(() => {
                    Log.Debug(`[CHECK] 棋子因 发牌 开始移动`);
                    chipItem.MoveToPos(self.GetChipItemPos(index, key), moveTime, () => {
                        Log.Debug(`[CHECK] 棋子因 发牌 移动结束`);
                    }, { easing: 'sineOut' });
                    chipItem.SetLayerIndex(this.GetLayerIndex(index, key), index);
                }, 0.05 * i)
            }

            let tTime = 0.05 * value.length + 0.25;
            if (tTime > finishTime) {
                finishTime = tTime;
            }
        });

        let canAutoMerge = GameMgr.Instance.CheckCanAutoMerge();
        if (!canAutoMerge) {
            finishTime = 0.25;
        }

        this.scheduleOnce(() => {
            if (canAutoMerge) {
                self.MergeChips();
            } else {
                self.checkGameOver();
                self.PlayingAnimFinish();
            }
        }, finishTime);

        this.refreshShuffBtn();
        this.refreshBtn();
        this.refreshSlotAnim();
        this.refreshRemoveBtn();
    }

    // 创建筹码
    CreateChipItem(pos: cc.Vec3, chip: Chip) {
        let chipItemNode: cc.Node = ObjectPoolManager.instance.getNode(this.chipItemPrefab);
        chipItemNode.parent = this.chipsGroup;
        chipItemNode.active = true;
        chipItemNode.setPosition(pos);
        chipItemNode.setScale(1, 1, 1);
        let chipItem: ChipItem = chipItemNode.getComponent(ChipItem);
        chipItem.Init(chip);

        return chipItem;
    }

    // 播放一个合成粒子效果
    PlayMergerEffect(pos: cc.Vec3) {
        let mergerEffectNode: cc.Node = ObjectPoolManager.instance.getNode(this.mergerEffectPrefab);
        mergerEffectNode.parent = this.effectGroup;
        mergerEffectNode.active = true;
        mergerEffectNode.setPosition(pos);
        let mergerEffect: MegerEffect = mergerEffectNode.getComponent(MegerEffect);
        mergerEffect.Play();
    }

    // 播放一个combo效果
    PlayComboEffect(num: number) {
        // let comboNumNode: cc.Node = ObjectPoolManager.instance.getNode(this.comboPrefab);
        // comboNumNode.parent = this.effectGroup;
        // this.effectGroup.setPosition(-20, 0, 0)
        // comboNumNode.active = true;
        // let comboEffect: ComboEffect = comboNumNode.getComponent(ComboEffect);
        // comboEffect.ShowEffect(num);
    }

    // 获取每个格子的坐标
    GetChipItemPos(index: number, slotId: number) {
        let slotP: cc.Vec2 = new cc.Vec2(slotId % 4, Math.floor(slotId / 4));
        let localPos = new cc.Vec3(-303 + slotP.x * 200, -248 + 380 * slotP.y, 0);
        localPos.y -= 28 * index;

        Log.Debug("游戏页 发牌 位置 GetChipItemPos index: " + index + " slotId: " + slotId + " localPos: " + localPos);
        return localPos;
    }

    GetLayerIndex(index: number, slotId: number) {
        return index + slotId * 1000;
    }

    //#endregion

    //#region 合成

    private _isSlotUnlocking = false; //标记是否解锁完成

    MergeChips() {
        Log.Debug(`[CHECK] 合成 Start this._curPlayingAnim: ${this._curPlayingAnim}, this._isMerge: ${this._isMerge}`);
        Log.Debug("游戏页 MergeChips");
        if (this._curPlayingAnim && !GameMgr.Instance.gameStatusData.auto_merge_chips_switch) {
            Log.Debug("====== 当前正在播放动画 =======")
            return;
        }

        if (this._isMerge) {
            Log.Debug("========合成未完成==========");
            return;
        }

        this._isMerge = true;

        this.stopSelectChpisAnim(this._curSlectedSlotId);
        this.SetPlayingAnimStatus();
        var mergeChipsMap = GameMgr.Instance.Merge();
        let moveTime = 0.03;
        var self = this;

        SoundManager.Instance.PlaySound(SOUND_NAME.Chips_Merge);
        NativeApi.instance.vibrateLong();
        // 遍历map做动画
        let mergeIndex = 0;
        let flyNum = 0;
        mergeChipsMap.forEach((value, key) => {
            let chipItemList = this._chipItemListMap.get(key);
            if (!chipItemList || chipItemList.length == 0) {
                return;
            }
            this._curSlectedSlotId = -1;

            let len = chipItemList.length;
            Log.Debug("游戏页 MergeChips key: " + key + " value: " + value + " len: " + len);
            for (let i = chipItemList.length - 1; i >= 0; i--) {
                const chipItem = chipItemList[i];
                // 前八个移动到位之后消失
                if (i < 8) {
                    Log.Debug(`[CHECK] 前8个棋子因合成开始移动`);
                    chipItem.MoveToPos(this.GetChipItemPos(0, key), moveTime * i, () => {
                        chipItem.Recycle();
                        Log.Debug(`[CHECK] 前8个棋子因合成 移动结束`);
                    }, { easing: 'sineOut' }, false);
                } else {
                    Log.Debug(`[CHECK] 后2个棋子因合成开始移动`);
                    // 9  10 移动到位置之后 做缩小动画，并且创建两个新的筹码
                    chipItem.MoveToPos(self.GetChipItemPos(-(8 - i), key), moveTime * 8, () => {
                        Log.Debug(`[CHECK] 后2个棋子因合成 移动结束`);
                        chipItem.ScaleTo(0, 0.15, () => {

                            Log.Debug("游戏页 MergeChips 合成动画 i: " + i + " len: " + len);
                            if (i == len - 1) {
                                // 最后一个
                                this.PlayMergerEffect(this.GetChipItemPos(0, key));
                                this._chipItemListMap.set(key, []);
                                let chipItemList = this._chipItemListMap.get(key);
                                let chipItem1: ChipItem = self.CreateChipItem(self.GetChipItemPos(0, key), value[0]);
                                let chipItem2: ChipItem = self.CreateChipItem(self.GetChipItemPos(1, key), value[1]);
                                chipItem1.SetLayerIndex(self.GetLayerIndex(0, key), 0);
                                chipItem2.SetLayerIndex(self.GetLayerIndex(1, key), 1);
                                chipItemList.push(chipItem1);
                                chipItemList.push(chipItem2);

                                chipItem1.node.setScale(0, 0, 0);
                                chipItem1.ScaleTo(1.15, 0.15, () => {
                                    chipItem1.ScaleTo(1, 0.3, () => {
                                        let moveToSlotId = GameMgr.Instance.MoveTempSlotChip(key);
                                        Log.Debug("游戏页 MergeChips 移动到临时槽位 moveToSlotId: " + moveToSlotId + " key: " + key);
                                        if (moveToSlotId > -1) {
                                            self.PlayingAnimFinish();
                                            self.moveChips(key, moveToSlotId, 2, () => {
                                                let slot = GameMgr.Instance.GetChipSlotById(key);
                                                slot.SlotSatus = ChipSlotStatus.Lock;
                                                let slotItem = self._chipSlotList[key];
                                                slotItem.UpdateView();
                                            });
                                        } else {
                                            self.PlayingAnimFinish();
                                        }
                                    })
                                })
                                chipItem2.node.setScale(0, 0, 0);
                                chipItem2.ScaleTo(1.15, 0.15, () => {
                                    chipItem2.ScaleTo(1, 0.3)
                                    Log.Debug("游戏页 MergeChips 合成完成 添加两个新的筹码 slotId key: " + key + " chipItemList.length: " + chipItemList.length);
                                })

                                let redReward = GameMgr.Instance.GetMergerReward(value[0].Id);
                                flyNum += redReward;
                                mergeIndex++;
                                Log.Debug("测试 =========  mergeIndex = " + mergeIndex + " mergeChipsMap.size = " + mergeChipsMap.size + " flyNum = " + flyNum);
                                if (mergeIndex == mergeChipsMap.size) {
                                    EventCenter.dispatchEvent(EventName.RefreshRedInfo, chipItem1.WordPos(), redReward, true, flyNum);
                                } else {
                                    EventCenter.dispatchEvent(EventName.RefreshRedInfo, chipItem1.WordPos(), redReward, false, 0);
                                }
                            }

                            chipItem.Recycle();
                        });
                    }, { easing: 'sineOut' }, false);
                }

            }
        });

        if (mergeChipsMap.size >= 2) {
            this.scheduleOnce(() => {
                self.PlayComboEffect(mergeChipsMap.size);
                SoundManager.Instance.PlaySound(SOUND_NAME.Combo);
            }, 0.5);
        }

        // 遍历list 尝试解锁session插槽
        for (let i = 0; i < this._chipSlotList.length; i++) {
            let chipSlotItem = this._chipSlotList[i];
            chipSlotItem.CanUnLockAnim();
        }

        this.refreshShuffBtn();
        this.refreshBtn();
        this.refreshSlotAnim();
        this.refreshRemoveBtn();

        //模拟自动解锁
        //if (!(sys.os === sys.OS.ANDROID && sys.isNative)) {
        self.onAutoUnlockSlot();
        //}

        // 合成动画结束后判断游戏是否结束
        this.scheduleOnce(() => {
            GameMgr.Instance.TryResartGame();
            self._isMerge = false;
        }, 0.6);
    }

    //#endregion

    //#region 移动
    // 移动
    moveChips(fromSlot: number, toSlot: number, moveCount: number, callback: Function = null) {

        Log.Debug("游戏页 移动 moveChips fromSlot: " + fromSlot + " toSlot: " + toSlot + " moveCount: " + moveCount);

        if (this._curPlayingAnim) {
            Log.Debug("====== 当前正在播放动画 =======")
            return;
        }
        this.SetPlayingAnimStatus();
        // 遍历map
        this.logChipItemList();
        GameMgr.Instance.MoveChip(fromSlot, toSlot);
        NativeApi.instance.onChipMove(fromSlot, toSlot);

        let fromChipItemList = this._chipItemListMap.get(fromSlot);
        let toChipItemList = this._chipItemListMap.get(toSlot);

        Log.Debug("游戏页 移动  toChipItemList: " + toChipItemList.length);
        let self = this;
        let j = 0;
        for (let i = fromChipItemList.length - moveCount; i < fromChipItemList.length; i++) {
            let chipItem = fromChipItemList[i];
            let index = toChipItemList.length;
            toChipItemList.push(chipItem);
            let targetP = this.GetChipItemPos(index, toSlot);
            chipItem.SetLayerIndex((2000 + i), 0);

            let moveIndex = j;
            if (fromSlot > toSlot) {
                moveIndex = moveCount - j - 1;
            }
            this.scheduleOnce(() => {
                chipItem.MoveToPos(targetP, 0.2, () => {
                });
            }, 0.02 * moveIndex)

            self.scheduleOnce(() => {
                chipItem.SetLayerIndex(self.GetLayerIndex(index, toSlot), index);
                chipItem.tryShowMaskNode();
            }, 0.3);
            j++;
            if (i >= fromChipItemList.length - 1) {
                this.scheduleOnce(() => {
                    if (callback) {
                        callback();
                    }
                }, 0.5);

                let slot = GameMgr.Instance.GetChipSlotById(fromSlot);
                Log.Debug("游戏页 移动 fromSlot: " + fromSlot + " slot.GetEmptyNum(): " + slot.GetEmptyNum() + " slotStatus: " + slot.SlotSatus);
                if (slot.SlotType == ChipSlotType.Temporary && slot.GetEmptyNum() == GameMgr.Slot_Chips_Max_Num) {
                    let slotItem = self._chipSlotList[fromSlot];
                    slotItem.UpdateView();
                    NativeApi.instance.onTemporarySlotClose();
                }
            }
        }

        let canAutoMerge = GameMgr.Instance.CheckCanAutoMerge();

        this.scheduleOnce(() => {
            if (canAutoMerge) {
                self.MergeChips();
            } else {
                self.PlayingAnimFinish();
            }
            // 触发自动合成
        }, 0.3 + 0.03 * moveCount + 0.1);

        fromChipItemList.splice(fromChipItemList.length - moveCount, moveCount);

        this.refreshSlotAnim();
        this.refreshBtn();
    }

    logChipItemList() {
        Log.Debug("游戏页 logChipItemList -----------------");
        this._chipItemListMap.forEach((value, key) => {
            for (let i = 0; i < value.length; i++) {
                const chipItem = value[i];
                Log.Debug("游戏页 logChipItemList key: " + key + " num: " + value.length + " i: " + i + " chipItem: " + chipItem.ChipId());
            }
        });
    }
    //#endregion

    //#region 洗牌
    public OnClickShuff() {
        if (!(cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative)) {
            this.ShuffChips();
            return;
        }

        if (this._isMerge) {
            Log.Debug("========合成未完成==========");
            return;
        }

        let restShuffleTimes = GameMgr.Instance.getRemainShuffleTimes();
        Log.Debug("游戏页 OnClickShuff 剩余次数= " + restShuffleTimes);

        let curProgress = GameMgr.Instance.GetCurProgress();

        if (restShuffleTimes == -1 || restShuffleTimes > 0) {
            if (curProgress < 50) {
                this.ShuffChips();

            } else {
                NativeApi.instance.onClickShuffleCard(restShuffleTimes);
            }

        } else {
            NativeApi.instance.showToast(`已无洗牌次数，试试其他选项吧～`);
        }

        // this.refreshShuffBtn();
    }

    public ShuffChips() {
        Log.Debug("游戏页 ShuffChips");
        if (this._curPlayingAnim) {
            Log.Debug("====== 当前正在播放动画 =======")
            return;
        }
        this.SetPlayingAnimStatus();
        SoundManager.Instance.PlaySound(SOUND_NAME.Chips_Shuffe);
        NativeApi.instance.onVibrate();
        let deletChips = GameMgr.Instance.Shuffle();
        Log.Debug("游戏页 ShuffChips  删除棋子类型列表 deletChips = " + deletChips)

        // 临时map 记录筹码
        let tempMap = new Map<number, ChipItem[]>();
        this._chipItemListMap.forEach((value, key) => {
            let slotData = GameMgr.Instance.GetChipSlotById(key);
            if (slotData.SlotType != ChipSlotType.Temporary) {
                let count = value.length;
                for (let i = count - 1; i >= 0; i--) {
                    const chipItem = value.pop();
                    let chipId = chipItem.ChipId();
                    if (deletChips.indexOf(chipId) >= 0) {
                        chipItem.Recycle();
                    } else {
                        if (!tempMap.has(chipId)) {
                            tempMap.set(chipId, []);
                        }
                        tempMap.get(chipId).push(chipItem);
                    }
                }
            }
        });

        this._chipItemListMap.forEach((value, key) => {
            let slotData = GameMgr.Instance.GetChipSlotById(key);
            if (slotData.SlotType != ChipSlotType.Temporary) {
                this._chipItemListMap.set(key, []);
            }
        });

        // 随机之后的数据
        let slotDataList = GameMgr.Instance.GetChipsSlotList();
        for (let i = 0; i < slotDataList.length; i++) {
            let slotData = slotDataList[i];
            if (slotData.SlotType != ChipSlotType.Temporary) {
                let chipId = slotData.GetLastChipId();
                if (chipId > 0) {
                    let chipItemList = tempMap.get(chipId);
                    for (let j = 0; j < chipItemList.length; j++) {
                        let chipItem = tempMap.get(chipId)[j]
                        if (j < 10) {
                            this._chipItemListMap.get(i).push(chipItem);
                            chipItem.MoveToPos(this.GetChipItemPos(j, i), 0.3);
                            chipItem.SetLayerIndex(this.GetLayerIndex(j, i), j);
                        } else {
                            chipItem.Recycle();
                        }
                    }
                }
            }
        }

        let canAutoMerge = GameMgr.Instance.CheckCanAutoMerge();
        this.scheduleOnce(() => {
            if (canAutoMerge) {
                this.MergeChips();
            } else {
                this.PlayingAnimFinish();
            }
        }, 0.31);

        this.refreshShuffBtn();
        this.refreshBtn();
        this.refreshSlotAnim();
        this.refreshRemoveBtn();
    }

    //#endregion

    //#region 选中
    //尝试选中插槽
    onClickSlot(slotId: number) {
        Log.Debug("游戏页 onClickSlot");

        if (this._curPlayingAnim) {
            return;
        }

        Log.Debug("游戏页 onClickSlot slotId: " + slotId + " _curSlectedSlotId: " + this._curSlectedSlotId);
        NativeApi.instance.onVibrate();
        if (this._curSlectedSlotId == slotId) {
            // 停止播放选中动效
            this.stopSelectChpisAnim(slotId);
            SoundManager.Instance.PlaySound(SOUND_NAME.Slot_Select);
            return;
        }

        if (this._curSlectedSlotId == -1) {
            let slotData = GameMgr.Instance.GetChipSlotById(slotId);
            if (slotData.GetEmptyNum() == GameMgr.Slot_Chips_Max_Num) {
                return;
            }

            this._curSlectedSlotId = slotId;

            Log.Debug("游戏页 onClickSlot slotId: " + slotId + " slotData.ChipsList.length: " + slotData.ChipsList.length);
            var tuple = slotData.GetCanMoveArray();

            Log.Debug("游戏页 onClickSlot 当前选中信息 tuple: " + tuple);

            SoundManager.Instance.PlaySound(SOUND_NAME.Slot_Select);

            this.playSelectChpisAnim(slotId, tuple[0]);
        } else {
            let curSeletSlotData = GameMgr.Instance.GetChipSlotById(this._curSlectedSlotId);
            let tryToSlotData = GameMgr.Instance.GetChipSlotById(slotId);

            let toPushChipsIdAndCount = tryToSlotData.CanPushChipsIdAndCount();
            let toPushId = toPushChipsIdAndCount[0];
            let toPushCount = toPushChipsIdAndCount[1];
            let fromMoveCountAndId = curSeletSlotData.GetCanMoveArray();
            let fromMoveCount = fromMoveCountAndId[0];
            let fromMoveId = fromMoveCountAndId[1];
            Log.Debug("移动---- canMoveCount: " + fromMoveCount + " canMoveId: " + fromMoveId + " moveSlotId " + this._curSlectedSlotId);
            Log.Debug("移动---- toPushCount: " + toPushCount + " toPushId: " + toPushId + " toSlotId " + slotId);
            if ((fromMoveId == toPushId || toPushId == 0) && toPushCount > 0 && tryToSlotData.SlotSatus == ChipSlotStatus.Unlock) {
                // 移动
                let moveCount = Math.min(toPushCount, fromMoveCount);
                Log.Debug("游戏页 onClickSlot 移动 canMoveCount   moveCount: " + moveCount);
                let self = this;
                let moveSlotId = this._curSlectedSlotId;
                this.moveChips(moveSlotId, slotId, moveCount, () => {
                    let slot = GameMgr.Instance.GetChipSlotById(moveSlotId);
                    if (slot.SlotType == ChipSlotType.Temporary) {
                        if (slot.GetEmptyNum() == 0) {
                            slot.SlotSatus = ChipSlotStatus.Lock;
                            let slotItem = self._chipSlotList[moveSlotId];
                            slotItem.UpdateView();
                        }
                    }
                });

                let soundName = SOUND_NAME.Chips_Move;
                switch (moveCount) {
                    case 1:
                    case 2:
                        soundName = SOUND_NAME.Chips_Move;
                        break;
                    case 3:
                    case 4:
                        soundName = SOUND_NAME.Chips_Move_2;
                        break;
                    case 5:
                    case 6:
                        soundName = SOUND_NAME.Chips_Move_4;
                        break;
                    case 7:
                    case 8:
                        soundName = SOUND_NAME.Chips_Move_6;
                        break;
                    case 9:
                    case 10:
                        soundName = SOUND_NAME.Chips_Move_8;
                        break;
                }
                SoundManager.Instance.PlaySound(soundName);

                this.stopSelectChpisAnim(this._curSlectedSlotId);
            } else {
                // 播放移动失败动画
                this.playMoveFailAnim(this._curSlectedSlotId);
                SoundManager.Instance.PlaySound(SOUND_NAME.Chips_Move_Fail);
            }

            this._curSlectedSlotId = -1;
        }
    }

    playSelectChpisAnim(slotId: number, num: number) {
        let chipItemList = this._chipItemListMap.get(slotId);
        if (!chipItemList || chipItemList.length == 0) {
            return;
        }

        let slotData = GameMgr.Instance.GetChipSlotById(slotId);
        if (!slotData) {
            return;
        }

        for (let i = chipItemList.length - num; i < chipItemList.length; i++) {
            const chipItem = chipItemList[i];
            chipItem.PlaySelectAnim();
        }
    }

    stopSelectChpisAnim(slotId: number) {
        this._curSlectedSlotId = -1;

        let chipItemList = this._chipItemListMap.get(slotId);
        if (!chipItemList || chipItemList.length == 0) {
            return;
        }

        for (let i = chipItemList.length - 1; i >= 0; i--) {
            const chipItem = chipItemList[i];
            chipItem.StopCurAnim();
        }
    }

    playMoveFailAnim(slotId: number) {
        let chipItemList = this._chipItemListMap.get(slotId);
        if (!chipItemList || chipItemList.length == 0) {
            return;
        }

        let tuple = GameMgr.Instance.GetChipSlotById(slotId).GetCanMoveArray();

        for (let i = chipItemList.length - tuple[0]; i < chipItemList.length; i++) {
            const chipItem = chipItemList[i];
            chipItem.PlayMoveFailAnim();
        }
    }

    //#endregion

    //#region 解锁槽位
    // 解锁槽位
    unlockSlot(slotId: number) {
        Log.Debug("游戏页========================== unlockSlot slotId: " + slotId);
        let chipSlotItem = this._chipSlotList[slotId];
        if (slotId == 11) {
            chipSlotItem.TryDiamondUnlock();
        } else if (9 <= slotId && slotId <= 10) {
            chipSlotItem.TryTempUnlock();
        } else {
            chipSlotItem.SessionUnlockAnim();
        }
        this.refreshShuffBtn();
        this.refreshBtn();

        let slotTpye = GameMgr.Instance.GetChipSlotById(slotId).SlotType;
        NativeApi.instance.onSlotUnlock(slotTpye, GameMgr.Instance.GetUnlockTempSlotNum());
    }
    //#endregion

    //#region 移除道具

    /**
     * 点击移除道具
     */
    public onClickRemove() {

        if (this._curPlayingAnim) {
            return;
        }

        if (this._isMerge) {
            Log.Debug("========合成未完成==========");
            return;
        }

        if (!(cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative)) {
            this.onRemoveChip(30, false);
            // var slotId: number = GameMgr.Instance.GetCurProgress() - 4 * GameMgr.Unit_Chips_Num;
            // if (slotId > 0) this.onRemoveChip(slotId, false);
            return;
        }

        let curProgress = GameMgr.Instance.GetCurProgress();
        let hasCfg = GameMgr.Instance.removeSmallChipConfig.has(curProgress);

        let removeValue = -1;
        let hasChips = false;
        if (hasCfg) {
            removeValue = GameMgr.Instance.removeSmallChipConfig.get(curProgress);
            hasChips = this.hasChipsUnderValue(removeValue);
        }

        Log.Debug(`GameUI  onClickRemove,  curProgress: ${curProgress}, hasCfg:  ${hasCfg},  removeValue:  ${removeValue}`)

        let remainRemoveTimes = GameMgr.Instance.getRemainRemoveTimes();

        Log.Debug(`GameUI  onClickRemove,  remainRemoveTimes: ${remainRemoveTimes}`)

        if ((remainRemoveTimes == -1 || remainRemoveTimes > 0) && hasChips) {
            if (curProgress < 50) {
                if (removeValue != -1) {
                    this.onRemoveChip(removeValue, false);
                } else {
                    NativeApi.instance.onClickRemoveProp(remainRemoveTimes);
                    return;
                }
            } else {
                NativeApi.instance.onClickRemoveProp(remainRemoveTimes);
                return;
            }
        } else {
            if (!hasChips) {
                NativeApi.instance.showToast(`场上没有小于${removeValue / 10}的筹码`)
                return;
            }
            NativeApi.instance.showToast(`已无使用次数，试试其他道具吧～`);
            return;
        }

    }

    /**
     * 移除筹码事件
     */
    public onRemoveChip(maxId: number, isAuto: boolean) {
        GameMgr.Instance.removeChipUnderValue(maxId);
        GameMgr.Instance.UseRemoveProp(isAuto);

        let hasRemove = false;
        this.SetPlayingAnimStatus();
        for (let i = 0; i < this._chipSlotList.length; i++) {
            let curSlot = this._chipSlotList[i];

            if (curSlot == null) {
                continue;
            }
            hasRemove = true;
            curSlot.removeChipsUnderValue(maxId);

            let slotId = curSlot.getSlotId();
            let chipItemList = this._chipItemListMap.get(slotId);
            if (!chipItemList || chipItemList.length == 0) {
                continue;
            }
            let emptyIndexList = [];

            for (let j = chipItemList.length - 1; j >= 0; j--) {
                let chipItem = chipItemList[j];
                if (chipItem.ChipId() >= maxId) {
                    continue;
                }
                this._chipItemListMap.get(slotId).splice(j, 1);

                emptyIndexList.push(chipItem.getSlotIndex());
                //chipItem.Recycle();
                chipItem.playCrashAni(() => {
                    chipItem.Recycle();
                });
            }

            this.refreshSlotAnim();
            this.refreshBtn();

            this.delayPlayComppactAni(slotId, emptyIndexList, 0.7);

            this._chipSlotList[i].UpdateView();
        }

        if (hasRemove) {
            SoundManager.Instance.PlaySound(SOUND_NAME.Chip_Remove);
            NativeApi.instance.onVibrate();
            this.scheduleOnce(() => {
                SoundManager.Instance.PlaySound(SOUND_NAME.Chips_Shuffe);
            }, 0.7);
        }

        this.refreshRemoveBtn();
    }

    /**
     * 延迟播放紧凑动画
     * @param slotId 
     * @param emptyIndexList 
     * @param delayTime 
     */
    private delayPlayComppactAni(slotId: number, emptyIndexList: number[], delayTime: number = 0.5) {
        Log.Debug("delayPlayComppactAni slotId: " + slotId + " emptyIndexList: " + emptyIndexList.join(","));
        this.scheduleOnce(() => {
            this.playCompactAni(slotId, emptyIndexList, () => {
                this.PlayingAnimFinish();
            });
        }, delayTime);
    }

    /**
     * 槽位筹码补齐动画
     * @param slotId 槽位id
     * @param emptyIndexList 空位置的筹码索引列表
     */
    private playCompactAni(slotId: number, emptyIndexList: number[], callBack: Function = null) {
        if (emptyIndexList == null || emptyIndexList.length <= 0) {
            if (callBack != null) {
                callBack();
            }
            return;
        }

        emptyIndexList.sort((a, b) => {
            return a - b;
        });
        let chipMoveLogicDistanceList = []; //筹码移动的距离列表（逻辑距离）
        let chipItemList = this._chipItemListMap.get(slotId);

        for (let i = 0; i < chipItemList.length; i++) {
            let emptyCount = 0;

            let curChipItem = chipItemList[i];
            if (curChipItem === null) {
                chipMoveLogicDistanceList.push(0);
                continue;
            }

            let curChipIndex = curChipItem.getSlotIndex();

            //计算当前chip前面有多少个空位
            for (let j = 0; j < emptyIndexList.length; j++) {
                if (emptyIndexList[j] < curChipIndex) {
                    emptyCount++;
                }
            }

            chipMoveLogicDistanceList.push(emptyCount);
            curChipItem.setSlotIndex(curChipIndex - emptyCount); //修改对应的chipItem数据
        }

        //具体移动逻辑
        for (let i = 0; i < chipItemList.length; i++) {
            if (chipMoveLogicDistanceList[i] == 0) {
                continue;
            }

            let chipPos = chipItemList[i].node.position;
            chipItemList[i].MoveToPos(new cc.Vec3(chipPos.x, chipPos.y + chipMoveLogicDistanceList[i] * 28, chipPos.z), 0.3);
        }

        this.scheduleOnce(() => {
            if (callBack != null) {
                callBack();
            }
        }, 0.4)

    }

    /**
     * 自动解锁槽位
     */
    private onAutoUnlockSlot() {
        Log.Debug("[CHECK] 尝试自动解锁 onAutoUnlockSlot ");
        var hasUnlockSlot = false;
        for (let i = 0; i < this._chipSlotList.length; i++) {
            let chipSlotItem = this._chipSlotList[i];
            let slotId: number = chipSlotItem.getSlotId();

            if (GameMgr.Instance.canUnlockSlot(slotId)) {
                Log.Debug("[CHECK] 自动解锁 slotId: " + slotId);
                this.unlockSlot(slotId);
                hasUnlockSlot = true;

                break;
            }
        }

        if (hasUnlockSlot) {
            this.scheduleOnce(() => {
                this._isSlotUnlocking = false;
            }, 1)
        } else {
            this._isSlotUnlocking = false;
        }
    }

    private onNewUserWelfareReceived() {
        this.refreshShuffBtn();
        this.refreshRemoveBtn();
    }

    /**
     * 刷新移除道具按钮显示
     */
    private refreshRemoveBtn() {
        let restRemoveTimes = GameMgr.Instance.getRemainRemoveTimes();

        let isBtnCanInteract = true;
        if (restRemoveTimes == -1) {
            isBtnCanInteract = true;
        } else {

            if (restRemoveTimes > 0) {
                isBtnCanInteract = true;
            } else {
                isBtnCanInteract = false;
            }

        }

        //显示移除提示
        let curProgress = GameMgr.Instance.GetCurProgress();
        let hasCfg = GameMgr.Instance.removeSmallChipConfig.has(curProgress);
        let hasChip: boolean = false; //场上是否有可消除的筹码

        if (hasCfg) {
            let removeValue = GameMgr.Instance.removeSmallChipConfig.get(curProgress);
            hasChip = this.hasChipsUnderValue(removeValue);
        } else {
            hasChip = true;
        }



        Tools.setImageGray(this.btnRemove2.node.getComponent(cc.Sprite), (!isBtnCanInteract) || (!hasChip));

    }

    /**
     * 判断场上是否有小于value值的筹码
     * @param value 
     * @returns 
     */
    private hasChipsUnderValue(value: number): boolean {

        for (let i = 0; i < this._chipSlotList.length; i++) {
            let curSlot = this._chipSlotList[i];

            if (curSlot == null) {
                continue;
            }

            let slotId = curSlot.getSlotId();
            let chipItemList = this._chipItemListMap.get(slotId);

            for (let j = chipItemList.length - 1; j >= 0; j--) {
                let chipItem = chipItemList[j];
                if (chipItem.ChipId() < value) {
                    return true;
                }
            }
        }
        return false;
    }


    /**
     * 显示洗牌引导
     */
    private tryShowShuffleGuid(dt: number) {
        if (dt < 3) {
            return;
        }

        //统计筹码填充率
        let fillRate = GameMgr.Instance.getChipFillRate();

        if (fillRate < 0.8) {
            return;
        }

        let chipColors = GameMgr.Instance.getAllChipColorCount();

        if (chipColors < 2) {
            return;
        }

        let shuffleTimes = GameMgr.Instance.getRemainShuffleTimes();
        if (!(shuffleTimes == -1 || shuffleTimes > 0)) {
            return;
        }
    }

    //#endrigion
    // 刷新洗牌按钮
    refreshShuffBtn() {
        let remainShuffleTime = GameMgr.Instance.getRemainShuffleTimes();

        let isBtnCanInteract = true;
        if (remainShuffleTime == -1) {
            isBtnCanInteract = true;
        } else {
            if (remainShuffleTime > 0) {
                isBtnCanInteract = true;
            } else {
                isBtnCanInteract = false;
            }
        }

        Tools.setImageGray(this.btnShuff2.node.getComponent(cc.Sprite), !isBtnCanInteract);
    }

    // 刷新合成按钮
    refreshBtn() {
        let canDeal = GameMgr.Instance.CanDealChips();
        if (canDeal) {
            this.btnDeal2.interactable = true;
            Tools.setImageGray(this.btnDeal2.node.getComponent(cc.Sprite), false);
        } else {
            this.btnDeal2.interactable = false;
            Tools.setImageGray(this.btnDeal2.node.getComponent(cc.Sprite), true);
        }
    }

    // 刷新槽位动效显示
    refreshSlotAnim() {
        for (let i = 0; i < this._chipSlotList.length; i++) {
            let chipSlotItem = this._chipSlotList[i];
            let canPlay = chipSlotItem.TryPlayMegerEffect();
            if (!canPlay) {
                chipSlotItem.HideMegerEffect();
            }
        }
    }

    gameOver() {
        this._chipItemListMap.forEach((chipItemList, key) => {
            for (let i = 0; i < chipItemList.length; i++) {
                let chipItem = chipItemList[i];
                chipItem.Recycle();
            }
        });

        this._isGameStart = false;
    }

    // 设置当前正在播放动画
    SetPlayingAnimStatus() {
        this._curPlayingAnim = true;

        Log.Debug(`[CHECK] SetPlayingAniStatus this._curPlayingAnim = ${this._curPlayingAnim}`);

        // 做保护两秒后自动置为false
        this.unschedule(this.autoSetAnimFinish)
        this.scheduleOnce(this.autoSetAnimFinish, 2.5);
        Log.Debug("当前游戏动画状态 设置当前正在播放动画 SetPlayingAnimStatus: " + this._curPlayingAnim + " _curSlectedSlotId:" + this._curSlectedSlotId)
    }

    autoSetAnimFinish() {
        this._curPlayingAnim = false;
        Log.Debug("当前游戏动画状态 动画播放完 autoSetAnimFinish >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    }

    // 动画播放完
    PlayingAnimFinish() {
        this._curPlayingAnim = false;
        Log.Debug(`[CHECK] PlayingAniFinish this._curPlayingAnim = ${this._curPlayingAnim}`);
        this.unschedule(this.autoSetAnimFinish)
        Log.Debug("当前游戏动画状态 动画播放完 PlayingAnimFinish: " + this._curPlayingAnim + " _curSlectedSlotId:" + this._curSlectedSlotId);
    }


    //是否有槽位筹码种类大于某个数量
    isSlotTypeOverNum(value: number) {
        Log.Debug("游戏页 GetRemainGameGuideCount " + GameMgr.Instance.GetRemainGameGuideCount());
        if (GameMgr.Instance.GetRemainGameGuideCount() <= 0) {
            return false;
        }

        let slotDataList = GameMgr.Instance.GetChipsSlotList();
        let isOverValue = true;
        for (let i = 0; i < slotDataList.length; i++) {
            let slotData = slotDataList[i];
            if (slotData.SlotType == ChipSlotType.Session &&
                slotData.SlotSatus == ChipSlotStatus.Unlock) {
                if (slotData.GetChipTypeNum() > value) {
                    isOverValue = false;
                    break;
                }
            }
        }

        return isOverValue;
    }

    //只要点击屏幕，就不显示引导
    onScreenClick(event: cc.Event.EventMouse | cc.Event.EventTouch) {

    }
}

