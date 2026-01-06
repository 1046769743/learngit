// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import ClientConfig, { ConfigKey } from "../../Data/ClientConfig";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { UIManager } from "../../FrameWork/UIManager";
import CurrencyManager from "../../Module/Currency/CurrencyManager";
import Language from "../../Module/Language/Language";
import { WheelRewardType } from "../../Module/Reward/RewardMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";
import BasePop from "./BasePop";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopJackpoy extends BasePop {

    @property(cc.Label)
    labelTitle: cc.Label = null;

    @property(cc.Label)
    labelDes: cc.Label = null;

    @property(cc.Label)
    labelReward: cc.Label = null;

    @property(cc.Label)
    labelButton: cc.Label = null;

    @property(cc.Sprite)
    spriteIcon: cc.Sprite = null;

    @property(cc.Button)
    buttonClose: cc.Button = null;


    start() {
        this.buttonClose.node.on("click", this.onClose, this);

        let cashOut = Language.instance.getDes("19");
        if (cashOut) {
            this.labelTitle.string = cashOut;
        }

        let des = Language.instance.getDes("51");
        if (des) {
            this.labelDes.string = des;
        }

        let reward = ClientConfig.getConfigValue(ConfigKey.GlobalConfig, "WithdrawTask");
        if (reward) {
            let rewardNum = parseInt(reward);
            this.labelReward.string = CurrencyManager.instance.formatMoney(rewardNum);
        }

        // 打点
        let esData = {
            rewardType: WheelRewardType.Seven77,
            Amonut: 1,
            isClickDouble: false,
            AdSuccess: false,
        }
        NativeApi.instance.buryPoint("SlotsSettle", JSON.stringify(esData));
    }

    onClose() {
        UIManager.Instance.close(PrefabDefine.PopJackpoy);
        UIManager.Instance.open(PrefabDefine.PopTask);
    }
}
