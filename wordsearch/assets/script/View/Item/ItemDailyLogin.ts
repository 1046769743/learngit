// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import DlgBtn from "../../Common/DlgBtn";
import { CollectEffectType, CollectMultipleEffect, EffectManager } from "../../Common/EffectManager";
import { RewardType } from "../../Common/EnumDefine";
import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import ResourceManager from "../../FrameWork/ResourceManager";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import AdMgr, { AdType, ModuleType } from "../../Module/AdModel/AdMgr";
import CurrencyManager from "../../Module/Currency/CurrencyManager";
import DailyLoginMgr, { DailyLoginRewardInfo, DailyLoginRewardState } from "../../Module/DailyLogin/DailyLoginMgr";
import Language from "../../Module/Language/Language";
import { NativeApi } from "../../Platform/Android/NativeApi";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemDailyLogin extends cc.Component {
    @property(cc.Node)
    nodeBgNormal: cc.Node = null;

    @property(cc.Node)
    nodeBgCollect: cc.Node = null;

    @property(cc.Node)
    nodeBgFinish: cc.Node = null;

    @property(cc.Label)
    labelDay: cc.Label = null;

    @property(cc.Label)
    labelCollect: cc.Label = null;

    @property(cc.Label)
    labelReward1: cc.Label = null;

    @property(cc.Label)
    labelReward2: cc.Label = null;

    @property(cc.Sprite)
    spriteReward1: cc.Sprite = null;

    @property(cc.Sprite)
    spriteReward2: cc.Sprite = null;

    @property(cc.Label)
    labelRewardCollect1: cc.Label = null;

    @property(cc.Label)
    labelRewardCollect2: cc.Label = null;

    @property(DlgBtn)
    btnCollect: DlgBtn = null;

    private _index: number = 0;
    private _isAd: boolean = false;
    /**1.0.1需求 */
    // 关闭弹窗时是否出插屏广告
    private _isCloseAdInterstitial: boolean = false;

    start() {
        this.btnCollect.node.on('click', this.onCollect, this);

        EventCenter.on(EventName.onAdComplete, this.onAdComplete, this);

        this._isCloseAdInterstitial = false;
    }

    public initUI(index: number) {
        this._index = index;
        this.btnCollect.interactable = false;
        if (this.labelRewardCollect1) {
            this.labelRewardCollect1.node.active = false;
        }
        if (this.labelRewardCollect2) {
            this.labelRewardCollect2.node.active = false;
        }

        if (this.labelReward1) {
            this.labelReward1.node.active = false;
        }
        if (this.labelReward2) {
            this.labelReward2.node.active = false;
        }

        this.labelDay.string = "Day " + (index).toString();

        this.labelCollect.string = Language.instance.getDes("60");

        let state = DailyLoginMgr.Instance.getRewardState(index);
        switch (state) {
            case DailyLoginRewardState.Normal:
                this.nodeBgNormal.active = true;
                this.nodeBgCollect.active = false;
                this.nodeBgFinish.active = false;
                if (this.labelReward1) {
                    this.labelReward1.node.active = true;
                }
                if (this.labelReward2) {
                    this.labelReward2.node.active = true;
                }
                break;

            case DailyLoginRewardState.CanClaim:
                this.btnCollect.interactable = true;
                this.nodeBgNormal.active = false;
                this.nodeBgCollect.active = true;
                this.nodeBgFinish.active = false;

                if (this.labelRewardCollect1) {
                    this.labelRewardCollect1.node.active = true;
                }
                if (this.labelRewardCollect2) {
                    this.labelRewardCollect2.node.active = true;
                }
                break;

            case DailyLoginRewardState.Claimed:
                this.nodeBgNormal.active = true;
                this.nodeBgCollect.active = false;
                this.nodeBgFinish.active = true;
                if (this.labelReward1) {
                    this.labelReward1.node.active = true;
                }
                if (this.labelReward2) {
                    this.labelReward2.node.active = true;
                }
                break;
        }

        // 奖励
        let rewardInfo = DailyLoginMgr.Instance.getDailyLoginRewardInfo(index);
        if (!rewardInfo) {
            Log.Error("ItemDailyLogin getRewardInfo error, index = " + index);
            return;
        }

        for (let i = 0; i < rewardInfo.rewards.length; i++) {
            let reward = rewardInfo.rewards[i];
            let label = null;
            let labelCollect = null;
            let sprite = null;
            if (i == 0) {
                label = this.labelReward1;
                sprite = this.spriteReward1;
                labelCollect = this.labelRewardCollect1;
            } else {
                label = this.labelReward2;
                sprite = this.spriteReward2;
                labelCollect = this.labelRewardCollect2;
            }

            if (cc.isValid(label) && cc.isValid(sprite)) {
                if (reward.rewardType == RewardType.Money) {
                    let path = CurrencyManager.instance.getMoreMoneyIcon();
                    ResourceManager.loadRes(path, cc.SpriteFrame, (frame: cc.SpriteFrame) => {
                        if (frame && cc.isValid(sprite)) {
                            sprite.spriteFrame = frame;
                        } else {
                            Log.Error("ItemDailyLogin loadRes error, url = " + path);
                        }
                    });
                    sprite.node.scale = 0.5
                    label.string = CurrencyManager.instance.formatMoney(reward.rewardAmount, true);
                    labelCollect.string = CurrencyManager.instance.formatMoney(reward.rewardAmount, true);
                } else if (reward.rewardType == RewardType.GoldenCard) {
                    label.string = reward.rewardAmount.toString();
                    labelCollect.string = reward.rewardAmount.toString();
                    sprite.node.scale = 1;
                    let path = "Atlas/DailyLogin/gold_card";
                    ResourceManager.loadRes(path, cc.SpriteFrame, (frame: cc.SpriteFrame) => {
                        if (frame && cc.isValid(sprite)) {
                            sprite.spriteFrame = frame;
                        } else {
                            Log.Error("ItemDailyLogin loadRes error, url = " + CurrencyManager.instance.getOneMoneyIcon());
                        }
                    });
                }
            }
        }

        // UI 调整
        if (rewardInfo.rewards.length == 1 && this._index == 7) {
            this.labelReward2.node.active = false;
            this.spriteReward2.node.active = false;
            this.labelRewardCollect2.node.active = false;
            this.spriteReward2.node.active = false;

            this.labelReward1.node.x = 0;
            this.spriteReward1.node.x = 0;
            this.labelRewardCollect1.node.x = 0;
        }
    }

    private onCollect() {
        let state = DailyLoginMgr.Instance.getRewardState(this._index);
        if (state == DailyLoginRewardState.CanClaim) {
            EventCenter.dispatchEvent(EventName.ShowPopTop);
            let rewardInfo = DailyLoginMgr.Instance.getRewardInfo(this._index);
            if (rewardInfo.shouldShowAd) {
                this._isAd = true;

                this._isCloseAdInterstitial = true;
            } else {
                this._isCloseAdInterstitial = false;
            }

            if (rewardInfo) {
                DailyLoginMgr.Instance.claimReward(this._index);
                this.onClaimReward(rewardInfo);
            }
        }
    }

    private onAdComplete(isSuccess: boolean, moduleType: ModuleType) {
        if (this._isAd && isSuccess && moduleType == ModuleType.DailyLogin) {
            let rewardInfo = DailyLoginMgr.Instance.claimReward(this._index);
            if (rewardInfo) {
                this.onClaimReward(rewardInfo);
            }
        }
    }

    private onClaimReward(rewardInfo: DailyLoginRewardInfo) {
        EventCenter.dispatchEvent(EventName.ShowPopTop);
        let collectMultipleEffects: CollectMultipleEffect[] = [];
        for (let i = 0; i < rewardInfo.rewards.length; i++) {
            let reward = rewardInfo.rewards[i];
            let collectType = CollectEffectType.Money;
            let targetPos = null;
            let startPos = null;
            let collectNum = 10;
            let collectCallback = null;

            if (reward.rewardType == RewardType.Money) {
                collectType = CollectEffectType.Money;
                targetPos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.POP_TOP_MONEY);
            } else if (reward.rewardType == RewardType.GoldenCard) {
                collectType = CollectEffectType.GoldenCard;
                targetPos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.POP_TOP_GOLDEN_CARD);

            } else if (reward.rewardType == RewardType.Bulb) {
                collectType = CollectEffectType.Bulb;
                targetPos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.POP_TOP_BLUB);
            }

            startPos = this.spriteReward1.node.position;
            startPos = this.spriteReward1.node.parent.convertToWorldSpaceAR(startPos);
            if (i == 1) {
                startPos = this.spriteReward2.node.position;
                startPos = this.spriteReward2.node.parent.convertToWorldSpaceAR(startPos);
            }
            collectNum = 10;
            collectCallback = () => {
                if (reward.rewardType == RewardType.Money) {
                    EventCenter.dispatchEvent(EventName.RefreshMoneyNumber, reward.rewardAmount);
                } else if (reward.rewardType == RewardType.GoldenCard) {
                    EventCenter.dispatchEvent(EventName.UpdateGoldenCardNumber, reward.rewardAmount);
                }
            };

            collectMultipleEffects.push({
                collectType: collectType,
                num: collectNum,
                startPos: startPos,
                targetPos: targetPos,
                collectCallback: collectCallback,
            });
        }
        EffectManager.instance.playCollectMultipleEffect(collectMultipleEffects);

        NativeApi.instance.buryPoint("TotalLoginTimes");

        // 刷新UI
        this.initUI(this._index);
    }

    protected onDestroy(): void {
        EventCenter.off(EventName.onAdComplete, this.onAdComplete, this);
        if (this._isCloseAdInterstitial) {
            let adType = AdType.DailyLogin3;
            if (this._index == 7) {
                adType = AdType.DailyLogin7;
            }
            AdMgr.Instance.showInterstitialAd(ModuleType.DailyLogin, adType);
        }
    }

}
