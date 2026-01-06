// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemWithdrawInfo extends cc.Component {
    @property(cc.Button)
    btn: cc.Button = null;

    @property(cc.Label)
    label: cc.Label = null;

    @property(cc.Node)
    bgNode: cc.Node = null;

    private _isSelect: boolean = false;
    private _money: number = 0;
    private _index: number = 0;

    start() {
        this.btn.node.on('click', this.onBtnClick, this);
        EventCenter.on(EventName.ItemWithdrawSelect, this.onWithdrawSelect, this);
    }

    init(money: number, index: number) {
        this._money = money;
        this._index = index;
        this._isSelect = false;
        this.bgNode.color = cc.Color.WHITE;
        this.label.string = money.toString();
    }

    public setSelect(select: boolean) {
        this._isSelect = select;
        this.bgNode.color = select ? cc.Color.GREEN : cc.Color.WHITE;
    }

    private onBtnClick() {
        this._isSelect = !this._isSelect;
        this.bgNode.color = this._isSelect ? cc.Color.GREEN : cc.Color.WHITE;
        EventCenter.dispatchEvent(EventName.ItemWithdrawSelect, this._index);
    }

    private onWithdrawSelect(index: number) {
        if (index == this._index) {
            this._isSelect = true;
            this.bgNode.color = cc.Color.GREEN;
        } else {
            this._isSelect = false;
            this.bgNode.color = cc.Color.WHITE;
        }
    }

    public onDestroy() {
        EventCenter.off(EventName.ItemWithdrawSelect, this.onWithdrawSelect, this);
    }
}
