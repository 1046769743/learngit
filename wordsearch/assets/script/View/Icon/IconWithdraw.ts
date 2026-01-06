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

    /** 1.0.1版本需求 */
    @property(cc.Node)
    nodeQipao: cc.Node = null;

    @property(cc.Node)
    nodeQipaoNo: cc.Node = null;

    @property(cc.Label)
    labQipaoNo: cc.Label = null;

    @property(cc.Node)
    nodeQipaoYes: cc.Node = null;

    @property(cc.Label)
    labQipaoYes: cc.Label = null;

    private _qipaoDuration: number = 0;
    private _curMoney: number = 0;

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
        this._curMoney = UserDataMgr.Instance.moneyNumber;
        this.nodeQipao.active = false;
    }

    protected update(dt: number): void {
        this._qipaoDuration -= dt;
        if (this._qipaoDuration > 0) {
            this.nodeQipao.active = true;
        } else {
            this.nodeQipao.active = false;
        }
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

        if (UserDataMgr.Instance.moneyNumber > this._curMoney) {
            this._qipaoDuration = 3;
            this.refreshQiPao();
        }

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

    private refreshQiPao() {
        let targetWithdraw = UserDataMgr.Instance.myTargetWithdrawMoney;
        let curMoney = UserDataMgr.Instance.moneyNumber;
        if (curMoney >= targetWithdraw) {
            this.nodeQipaoNo.active = false;
            this.nodeQipaoYes.active = true;

            // this.labQipaoNo.string = "";
        } else {
            this.nodeQipaoNo.active = true;
            this.nodeQipaoYes.active = false;

            let left = targetWithdraw - curMoney;
            let leftStr = CurrencyManager.instance.formatMoney(left);

            let str = "There is still %s left to withdraw."
            str = str.replace("%s", leftStr);
            this.labQipaoNo.string = str;
        }
    }
}
