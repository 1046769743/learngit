// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { EventName } from "../../Common/EventName";
import { Tools } from "../../Common/Tools";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import CurrencyManager from "../../Module/Currency/CurrencyManager";
import UserDataMgr from "../../Module/UserData/UserDataMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemPopTop extends cc.Component {
    // 黄金卡
    @property(cc.Node)
    nodeGoldenCard: cc.Node = null;

    @property(cc.Label)
    labelGoldenCardNumber: cc.Label = null;

    // 金币
    @property(cc.Sprite)
    sprMoney: cc.Sprite = null;

    @property(cc.Label)
    labelMoneyNumber: cc.Label = null;

    // 道具
    @property(cc.Node)
    nodeBlub: cc.Node = null;

    @property(cc.Label)
    labelBlubNumber: cc.Label = null;

    start() {
        EventCenter.on(EventName.RefreshMoneyNumber, this.updateNumber, this);
        EventCenter.on(EventName.UpdateGoldenCardNumber, this.updateNumber, this);
        EventCenter.on(EventName.UpdateTipNumber, this.updateNumber, this);
    }

    updateUI() {
        CurrencyManager.instance.changeMoneyIcon(this.sprMoney);

        // 更新坐标
        let worldPos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.ICON_MONEY);
        let localPos = this.node.parent.convertToNodeSpaceAR(worldPos);
        if (localPos) {
            let x = this.node.position.x;
            this.node.position = cc.v3(x, localPos.y, 0);
        }

        UIManager.Instance.registerTargetNode(TargetNodeKeys.POP_TOP_GOLDEN_CARD, this.nodeGoldenCard);
        UIManager.Instance.registerTargetNode(TargetNodeKeys.POP_TOP_MONEY, this.sprMoney.node);

        this.updateNumber();
    }

    updateNumber() {
        this.labelGoldenCardNumber.string = UserDataMgr.Instance.goldenCardNumber.toString();
        let str = CurrencyManager.instance.formatMoneyForHome(UserDataMgr.Instance.moneyNumber);
        this.labelMoneyNumber.string = Tools.replaceToBmfontString(str);

        if (this.nodeBlub) {
            UIManager.Instance.registerTargetNode(TargetNodeKeys.POP_TOP_BLUB, this.nodeBlub);
            this.labelBlubNumber.string = UserDataMgr.Instance.tipNumber.toString();
        }
    }

    onDestroy() {
        UIManager.Instance.unregisterTargetNode(TargetNodeKeys.POP_TOP_GOLDEN_CARD);
        UIManager.Instance.unregisterTargetNode(TargetNodeKeys.POP_TOP_MONEY);
        if (this.nodeBlub) {
            UIManager.Instance.unregisterTargetNode(TargetNodeKeys.POP_TOP_BLUB);
        }
        EventCenter.off(EventName.RefreshMoneyNumber, this.updateNumber, this);
        EventCenter.off(EventName.UpdateGoldenCardNumber, this.updateNumber, this);
        EventCenter.off(EventName.UpdateTipNumber, this.updateNumber, this);
    }
}
