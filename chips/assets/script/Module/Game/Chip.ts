import { ChipType } from '../../Common/EnumDefine';
const { ccclass, property } = cc._decorator;

export class Chip {
    Id: number = 0;
    Type: ChipType = ChipType.None;
    ChipsSlotId: number = 0;

    public Init(id: number, type: ChipType, chipSlotId: number) {
        this.Id = id;
        this.Type = type;
        this.ChipsSlotId = chipSlotId;
    }

    public ChangeSlotId(id: number) {
        this.ChipsSlotId = id;
    }

    // todo 随机筹码变成固定筹码 

    /**
     * 获取数据对象
     */
    getData(): any {
        return {
            Id: this.Id,
            Type: this.Type,
            ChipsSlotId: this.ChipsSlotId
        }
    }
}

