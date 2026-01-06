// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import DlgBtn from "../../Common/DlgBtn";
import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { UIManager } from "../../FrameWork/UIManager";
import AdMgr, { AdType, ModuleType } from "../../Module/AdModel/AdMgr";
import CurrencyManager from "../../Module/Currency/CurrencyManager";
import DailyLoginMgr from "../../Module/DailyLogin/DailyLoginMgr";
import FlyBoxMgr from "../../Module/FlyBox/FlyBoxMgr";
import Language from "../../Module/Language/Language";
import RewardMgr from "../../Module/Reward/RewardMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";
import ItemPopTop from "../Common/ItemPopTop";
import ItemDailyLogin from "../Item/ItemDailyLogin";
import BasePop from "./BasePop";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopDailyLogin extends BasePop {
    @property(DlgBtn)
    btnClose: DlgBtn = null;

    @property([ItemDailyLogin])
    itemDailyLoginList: ItemDailyLogin[] = [];

    @property(ItemPopTop)
    itemPopTop: ItemPopTop = null;

    protected start(): void {
        this.btnClose.addClickCallback(this.onClickClose, this);
        EventCenter.on(EventName.ShowPopTop, this.showPopTop, this);

        DailyLoginMgr.Instance.getDailyLoginData();
        for (let i = 0; i < this.itemDailyLoginList.length; i++) {
            let item = this.itemDailyLoginList[i];
            item.initUI(i + 1);
        }
        this.itemPopTop.node.active = false;
        this.itemPopTop.updateUI();
    }

    private showPopTop() {
        this.itemPopTop.node.active = true;
        this.itemPopTop.updateUI();
    }

    private onClickClose() {
        UIManager.Instance.close(PrefabDefine.PopDailyLogin);
    }

    onDestroy() {
        EventCenter.off(EventName.ShowPopTop, this.showPopTop, this);
    }
}
