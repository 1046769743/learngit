import { ChipSlotStatus, ChipSlotType, ChipType } from '../../Common/EnumDefine';
import { GameMgr } from './GameMgr';
import { Chip } from './Chip';
import { Log } from '../../FrameWork/Log';
const { ccclass, property } = cc._decorator;

@ccclass('ChipSlot')
export class ChipSlot {
    ChipsList: Chip[] = [];
    SlotId: number = 0;
    SlotType: ChipSlotType = ChipSlotType.None;
    SlotSatus: ChipSlotStatus = ChipSlotStatus.None;
    Mgr: GameMgr = null;

    public Init(id: number, type: ChipSlotType, status: ChipSlotStatus, chipsList: Chip[] = [], mgr: GameMgr = null) {
        this.SlotId = id;
        this.SlotType = type;
        this.SlotSatus = status;
        Log.Debug("ChipSlot Init: " + this.SlotId + " type:" + this.SlotType + " status:" + this.SlotSatus + " chipsList:" + chipsList.length);
        if (status != ChipSlotStatus.Unlock) {
            this.ChipsList = [];
        } else {
            this.ChipsList = chipsList;
        }
        this.Mgr = mgr;
    }

    /**
     * 获取数据对象
     */
    getData(): any {
        var chipsList = [];
        for (let i = 0; i < this.ChipsList.length; i++) {
            const element = this.ChipsList[i];
            chipsList.push(element.getData());
        }
        return {
            ChipsList: chipsList,
            SlotId: this.SlotId,
            SlotType: this.SlotType,
            SlotSatus: this.SlotSatus
        }
    }

    // 是否解锁
    public IsUnLock() {
        // Log.Debug("IsUnLock: " + this.SlotSatus + " slotId:" + this.SlotId);
        return this.SlotSatus == ChipSlotStatus.Unlock;
    }

    // 解锁插槽
    public UnLock() {
        this.SlotSatus = ChipSlotStatus.Unlock;
        this.ChipsList = [];
        GameMgr.Instance.SaveData();

        Log.Debug("解锁插槽: " + this.SlotId);
    }

    public Push(chip: Chip) {
        this.ChipsList.push(chip);
        chip.ChipsSlotId = this.SlotId;
    }

    public PushList(chipsList: Chip[]) {
        this.ChipsList = this.ChipsList.concat(chipsList);
        for (let i = 0; i < chipsList.length; i++) {
            const element = chipsList[i];
            element.ChipsSlotId = this.SlotId;
        }
    }

    public Pop() {
        return this.ChipsList.pop();
    }

    /*
    * count 可以取的最大值
    * 从后往前取
    */
    public PopList(count: number) {
        var tuple = this.GetCanMoveArray();
        count = Math.min(count, tuple[0]);
        return this.ChipsList.splice(this.ChipsList.length - count, count);
    }

    public removeChipUnderValue(value: number) {
        for (let i = this.ChipsList.length - 1; i >= 0; i--) {
            let curChip = this.ChipsList[i];

            if (curChip.Id < value) {
                this.ChipsList.slice(i, 1);
            }
        }
    }

    public GetCanMoveArray() {
        if (!this.IsUnLock() || this.ChipsList.length == 0)
            return [0, 0];

        var lastChips = this.ChipsList[this.ChipsList.length - 1];
        var num = 0;
        // 遍历数组
        for (let i = this.ChipsList.length - 1; i >= 0; i--) {
            const element = this.ChipsList[i];
            if (element.Type == ChipType.Fixed && element.Id == lastChips.Id) {
                num++;
            } else {
                break;
            }
        }

        return [num, lastChips.Id]
    }

    // 获取可以移动的筹码的id和数量
    public CanPushChipsIdAndCount() {
        if (this.IsUnLock()) {
            var tuple = this.GetCanMoveArray();
            var count = tuple[0];
            var id = tuple[1];
            return [id, this.GetEmptyNum()];
        } else {
            return [-1, 0]
        }
    }

    // 判断是否可入栈
    public CanPush(chipid: number, count: number = 1) {
        if (this.SlotSatus == ChipSlotStatus.Lock || this.SlotSatus == ChipSlotStatus.None) {
            return false;
        }

        if (count > this.GetEmptyNum()) {
            return false;
        }

        let lastChipId = this.GetLastChipId();
        if (lastChipId != chipid && lastChipId != 0) {
            return false
        }
        return true;
    }

    // 判断是否可合成
    public CanMerge() {
        var tuple = this.GetCanMoveArray();
        var count = tuple[0];
        var id = tuple[1];
        return count >= GameMgr.Slot_Chips_Max_Num && id != 0;
    }

    // 合成
    public Merge() {
        var tuple = this.GetCanMoveArray();
        var count = tuple[0];
        var id = tuple[1];
        if (count >= GameMgr.Slot_Chips_Max_Num && id != 0) {
            var chips1 = new Chip();
            chips1.Init(id + 10, ChipType.Fixed, this.SlotId);

            var chips2 = new Chip();
            chips2.Init(id + 10, ChipType.Fixed, this.SlotId);

            this.ChipsList = [];
            this.ChipsList.push(chips1, chips2);
        }

        return this.ChipsList[0].Id;
    }

    // 当前空位数量
    public GetEmptyNum() {
        return GameMgr.Slot_Chips_Max_Num - this.ChipsList.length;
    }

    // 当前最外层筹码的id
    public GetLastChipId() {
        if (this.ChipsList.length == 0) {
            return 0;
        }
        return this.ChipsList[this.ChipsList.length - 1].Id;
    }

    // 是否可以发相同筹码
    public CanDealSameChip() {
        var curProgress = this.Mgr.GetCurTargetProgress() - 2;
        var tuple = this.GetCanMoveArray();
        if (tuple[0] == 0) {
            return true;
        } else {
            return tuple[1] != 0 && tuple[1] <= curProgress;
        }
    }

    // 当前槽位上有几种筹码
    public GetChipTypeNum() {
        var chipTypeList = []
        for (let i = 0; i < this.ChipsList.length; i++) {
            const element = this.ChipsList[i];
            if (chipTypeList.indexOf(element.Id) == -1) {
                chipTypeList.push(element.Id);
            }
        }
        return chipTypeList.length;
    }



}

