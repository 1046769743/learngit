// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { RewardType } from "../../Common/EnumDefine";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import ResourceManager from "../../FrameWork/ResourceManager";
import { UIManager } from "../../FrameWork/UIManager";
import { SOUND_NAME, SoundManager } from "../../Module/Audio/SoundManager";
import CurrencyManager from "../../Module/Currency/CurrencyManager";
import UserDataMgr from "../../Module/UserData/UserDataMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopRewardClaim extends cc.Component {

    @property(cc.Sprite)
    spriteReward: cc.Sprite = null;

    @property(cc.Label)
    labelReward: cc.Label = null;

    @property(cc.Button)
    btnClaim: cc.Button = null;

    private rewardType: RewardType = RewardType.None;
    private rewardValue: number = 0;

    start() {
        this.btnClaim.node.on('click', this.onClaim, this);
    }

    updateUI(rewardType: RewardType, rewardValue: number) {
        this.rewardType = rewardType;
        this.rewardValue = rewardValue;
        let paht = "Atlas/Common/daoju";
        if (rewardType == RewardType.Money) {
            paht = CurrencyManager.instance.getMoreMoneyIcon();
            this.labelReward.string = "+" + CurrencyManager.instance.formatMoney(rewardValue, true);
        } else {
            this.labelReward.string = "+" + rewardValue.toString();
        }

        ResourceManager.loadRes(paht, cc.SpriteFrame, (frame: cc.SpriteFrame) => {
            if (frame && cc.isValid(this.spriteReward)) {
                this.spriteReward.spriteFrame = frame;
            } else {
                Log.Error("PopRewardClaim loadRes error, url = " + paht);
            }
        });
    }

    private onClaim() {
        SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        if (this.rewardType == RewardType.Money) {
            UserDataMgr.Instance.addMoneyNumber(this.rewardValue, true);
        } else {
            UserDataMgr.Instance.addTipNumber(this.rewardValue, true);
        }

        UIManager.Instance.close(PrefabDefine.PopRewardClaim);
    }
}
