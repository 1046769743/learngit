// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { UIManager } from "../../FrameWork/UIManager";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import { EventCenter } from "../../FrameWork/EventCenter";
import { EventName } from "../../Common/EventName";
import { NativeApi } from "../../Platform/Android/NativeApi";
import WithdrawMgr from "../../Module/Withdraw/WithdrawMgr";
import CurrencyManager from "../../Module/Currency/CurrencyManager";
import { ObjectPoolManager } from "../../Common/ObjectPoolManager";
import ItemAddMoney from "../Item/ItemAddMoney";
import { RewardType } from "../../Common/EnumDefine";
import DlgBtn from "../../Common/DlgBtn";
import { SoundManager } from "../../Module/Audio/SoundManager";
import { Tools } from "../../Common/Tools";

const { ccclass, property } = cc._decorator;

@ccclass
export default class IconWithdraw extends cc.Component {

    @property(cc.Sprite)
    iconMoney: cc.Sprite = null;

    @property(cc.Label)
    label: cc.Label = null;

    @property(DlgBtn)
    btn: DlgBtn = null;

    @property(cc.Prefab)
    prefabAddAni: cc.Prefab = null;

    @property(cc.Node)
    nodeGuide: cc.Node = null;

    onLoad() {
        EventCenter.on(EventName.RefreshMoneyNumber, this.onRefreshMoneyNumber, this);
        EventCenter.on(EventName.RefreshMoneyShow, this.refreshMoneyShow, this);

    }

    start() {
        let isWhiteBao = UserDataMgr.Instance.isWhiteBao;
        if (isWhiteBao) {
            this.node.active = false;
            return;
        }

        // 注册金币图标到UIManager，供其他UI使用
        UIManager.Instance.registerTargetNode(TargetNodeKeys.ICON_MONEY, this.iconMoney.node);
        UIManager.Instance.registerTargetNode(TargetNodeKeys.GUIDE_WITHDRAW, this.nodeGuide);

        this.btn.addClickCallback(this.onBtnClick, this);

        this.refreshMoneyShow();
    }

    private onBtnClick() {
        WithdrawMgr.Instance.openWithdraw();

        // 打点
        let esData = {
            Amonut: UserDataMgr.Instance.moneyNumber
        }
        NativeApi.instance.buryPoint("WithdrawClick", JSON.stringify(esData));
    }

    protected onDestroy(): void {
        // 取消注册
        UIManager.Instance.unregisterTargetNode(TargetNodeKeys.ICON_MONEY);
        EventCenter.off(EventName.RefreshMoneyNumber, this.onRefreshMoneyNumber, this);
        EventCenter.off(EventName.RefreshMoneyShow, this.refreshMoneyShow, this);
    }

    private onRefreshMoneyNumber(value: number) {
        this.refreshMoneyShowString();

        let moneyStr = CurrencyManager.instance.formatMoneyForHome(value, false);
        let addMoneyNode = ObjectPoolManager.instance.getNode(this.prefabAddAni);
        let itemAddMoney = addMoneyNode.getComponent(ItemAddMoney) as ItemAddMoney;
        itemAddMoney.updateShow("+" + moneyStr, RewardType.Money);
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

    // 刷新整个显示
    private refreshMoneyShow() {
        CurrencyManager.instance.changeMoneyIcon(this.iconMoney);
        this.refreshMoneyShowString();
    }

    private refreshMoneyShowString() {
        let str = CurrencyManager.instance.formatMoneyForHome(UserDataMgr.Instance.moneyNumber);
        this.label.string = Tools.replaceToBmfontString(str);
    }
}
