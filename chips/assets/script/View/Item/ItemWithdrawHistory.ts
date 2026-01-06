// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemWithdrawHistory extends cc.Component {

    @property(cc.Label)
    labelId: cc.Label = null;

    @property(cc.Label)
    labelMoney: cc.Label = null;

    @property(cc.Label)
    labelStatus: cc.Label = null;

    public updateHistory(id: string, money: number) {
        this.labelId.string = id;
        this.labelMoney.string = money.toString();
        this.labelStatus.string = "进行中...";
    }

    // update (dt) {}
}
