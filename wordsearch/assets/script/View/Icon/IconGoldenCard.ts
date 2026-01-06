// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import DlgBtn from "../../Common/DlgBtn";
import { RewardType } from "../../Common/EnumDefine";
import { EventName } from "../../Common/EventName";
import { ObjectPoolManager } from "../../Common/ObjectPoolManager";
import { EventCenter } from "../../FrameWork/EventCenter";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import { SoundManager } from "../../Module/Audio/SoundManager";
import CurrencyManager from "../../Module/Currency/CurrencyManager";
import LuckWheelMgr from "../../Module/LuckWheel/LuckWheelMgr";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import WithdrawMgr from "../../Module/Withdraw/WithdrawMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";
import ItemAddMoney from "../Item/ItemAddMoney";

const { ccclass, property } = cc._decorator;

@ccclass
export default class IconGoldenCard extends cc.Component {

    @property(DlgBtn)
    btn: DlgBtn = null;

    @property(cc.Node)
    nodeIcon: cc.Node = null;

    @property(cc.Label)
    labelNumber: cc.Label = null;

    @property(cc.Prefab)
    prefabAddAni: cc.Prefab = null;

    start() {
        EventCenter.on(EventName.UpdateGoldenCardNumber, this.updateGoldenCardNumber, this);
        UIManager.Instance.registerTargetNode(TargetNodeKeys.ICON_GOLDEN_CARD, this.nodeIcon);
        this.btn.addClickCallback(this.onBtnClick, this);
        this.labelNumber.string = UserDataMgr.Instance.goldenCardNumber.toString();
    }

    updateGoldenCardNumber(value: number, isAni: boolean = false) {
        this.labelNumber.string = UserDataMgr.Instance.goldenCardNumber.toString();
        if (isAni) {
            let addMoneyNode = ObjectPoolManager.instance.getNode(this.prefabAddAni);
            let itemAddMoney = addMoneyNode.getComponent(ItemAddMoney) as ItemAddMoney;
            itemAddMoney.updateShow("+" + value.toString(), RewardType.GoldenCard);
            addMoneyNode.parent = this.node;
            addMoneyNode.position = cc.v3(-40, -54, 0);
            addMoneyNode.opacity = 255;
            cc.tween(addMoneyNode)
                .to(0.7, { position: cc.v3(-40, 0, 0), opacity: 100 }, { easing: 'sineInOut' })
                .call(() => {
                    ObjectPoolManager.instance.putNode(addMoneyNode);
                })
                .start();
        }
    }

    private onBtnClick() {
        WithdrawMgr.Instance.openWithdraw();
    }
}
