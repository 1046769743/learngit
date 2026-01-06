// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import DlgBtn from "../../Common/DlgBtn";
import ClientConfig from "../../Data/ClientConfig";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { UIManager } from "../../FrameWork/UIManager";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import WithdrawMgr from "../../Module/Withdraw/WithdrawMgr";
import BasePop from "./BasePop";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopCashOut extends BasePop {
    @property(cc.Label)
    title: cc.Label = null;

    @property(cc.Label)
    des: cc.Label = null;

    @property(cc.Label)
    labBtn: cc.Label = null;

    @property(cc.Sprite)
    sprProgress: cc.Sprite = null;

    @property(cc.Label)
    labelProgress: cc.Label = null;

    @property(DlgBtn)
    btnClose: DlgBtn = null;

    start() {
        this.btnClose.addClickCallback(this.onClose, this);
        let curCard = UserDataMgr.Instance.goldenCardNumber;
        let targetCard = parseInt(ClientConfig.globalConfig.CardCash.Value);
        this.labelProgress.string = curCard + "/" + targetCard;
        this.sprProgress.fillRange = curCard / targetCard;
    }

    private onClose() {
        // WithdrawMgr.Instance.CashOutPopOpened = true;
        UIManager.Instance.close(PrefabDefine.PopCashOut);
    }
}
