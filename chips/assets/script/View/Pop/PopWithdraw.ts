// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import DlgBtn from "../../Common/DlgBtn";
import { Tools } from "../../Common/Tools";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { UIManager } from "../../FrameWork/UIManager";
import { SoundManager } from "../../Module/Audio/SoundManager";
import CurrencyManager from "../../Module/Currency/CurrencyManager";
import Language from "../../Module/Language/Language";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import WithdrawMgr from "../../Module/Withdraw/WithdrawMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";
import BasePop from "./BasePop";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopWithdraw extends BasePop {
    @property(cc.Label)
    title: cc.Label = null;

    @property(cc.Label)
    des: cc.Label = null;

    @property(cc.Label)
    money: cc.Label = null;

    @property(cc.Label)
    labBtn: cc.Label = null;

    @property(DlgBtn)
    btn: DlgBtn = null;


    start() {
        this.btn.addClickCallback(this.onClick, this);

        this.des.string = Language.instance.getDes("93");

        let str = CurrencyManager.instance.formatMoney(UserDataMgr.Instance.moneyNumber);
        this.money.string = Tools.replaceToBmfontString(str);
    }

    private onClick() {
        WithdrawMgr.Instance.openWithdraw(2);
        UIManager.Instance.close(PrefabDefine.PopWithdraw);
    }
}
