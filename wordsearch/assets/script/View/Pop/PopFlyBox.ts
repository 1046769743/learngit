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
import FlyBoxMgr from "../../Module/FlyBox/FlyBoxMgr";
import Language from "../../Module/Language/Language";
import RewardMgr from "../../Module/Reward/RewardMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";
import BasePop from "./BasePop";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopFlyBox extends BasePop {

    @property(cc.Label)
    labelTitle: cc.Label = null;

    @property(cc.Label)
    labelReward: cc.Label = null;

    @property(cc.Label)
    labelButton: cc.Label = null;

    @property(DlgBtn)
    btnAd: DlgBtn = null;

    @property(DlgBtn)
    btnClaim: DlgBtn = null;


    protected start(): void {
        this.btnAd.addClickCallback(this.onClickAd, this);
        this.btnClaim.addClickCallback(this.onClickClaim, this);

        this.labelButton.string = Language.instance.getDes("60");
        this.labelTitle.string = Language.instance.getDes("54");
        let reward = RewardMgr.Instance.getFlyBoxRewardConfig();
        this.labelReward.string = CurrencyManager.instance.formatMoney(reward);
    }

    private onClickAd() {
        AdMgr.Instance.showAd(ModuleType.FlyBox, AdType.FlyBox);
        NativeApi.instance.buryPoint("WordChestCollectClick");
        UIManager.Instance.close(PrefabDefine.PopFlyBox);
    }

    private onClickClaim() {
        FlyBoxMgr.Instance.addRejectCount();
        if (FlyBoxMgr.Instance.isForceRv()) {
            AdMgr.Instance.showAd(ModuleType.FlyBox, AdType.FlyBoxClaim);
        }
        UIManager.Instance.close(PrefabDefine.PopFlyBox);
    }

    protected onDestroy(): void {
    }
}
