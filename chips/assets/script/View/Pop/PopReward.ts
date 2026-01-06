// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { EventName } from "../../Common/EventName";
import ClientConfig, { ConfigKey, WheelConfig } from "../../Data/ClientConfig";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import ResourceManager from "../../FrameWork/ResourceManager";
import { UIManager } from "../../FrameWork/UIManager";
import AdMgr, { AdType, ModuleType } from "../../Module/AdModel/AdMgr";
import { SOUND_NAME, SoundManager } from "../../Module/Audio/SoundManager";
import CurrencyManager from "../../Module/Currency/CurrencyManager";
import { GameMgr } from "../../Module/Game/GameMgr";
import Language from "../../Module/Language/Language";
import RewardMgr, { WheelRewardType } from "../../Module/Reward/RewardMgr";
import TaskMgr from "../../Module/TaskModule/TaskMgr";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import WheelMgr from "../../Module/Wheel/WheelMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";
import BasePop from "./BasePop";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopReward extends BasePop {
    @property(cc.Label)
    labelCongratulation: cc.Label = null;

    @property(cc.Node)
    oneRewardNode: cc.Node = null;

    @property(cc.Node)
    twoRewardNode: cc.Node = null;

    // one reward node
    @property(cc.Label)
    labelOneReward: cc.Label = null;

    @property(cc.Sprite)
    spriteOneReward: cc.Sprite = null;

    @property(cc.Button)
    btnOneReward: cc.Button = null;

    @property(cc.Label)
    labelClaim1: cc.Label = null;

    // double reward node
    @property(cc.Label)
    labelDouble: cc.Label = null;

    @property(cc.Label)
    labelClaim: cc.Label = null;

    @property(cc.Label)
    labelOneReward1: cc.Label = null;

    @property(cc.Sprite)
    spriteOneReward1: cc.Sprite = null;

    @property(cc.Label)
    labelTwoReward: cc.Label = null;

    @property(cc.Label)
    labelMore: cc.Label = null;

    @property(cc.Sprite)
    spriteTwoReward: cc.Sprite = null;

    @property(cc.Button)
    btnClaim: cc.Button = null;

    @property(cc.Button)
    btnDouble: cc.Button = null;

    @property(cc.Node)
    oneRewardAnimNode: cc.Node = null;

    @property(cc.Node)
    twoRewardAnimNode: cc.Node = null;

    @property(cc.Node)
    levelNode: cc.Node = null;

    @property(cc.Node)
    caidaiSpineNode: cc.Node = null;

    private _enterAnimEnd: boolean = false;

    private _reward: number = 0;
    private _doubleReward: number = 0;
    private _rewardType: WheelRewardType = WheelRewardType.Dollar;
    private _isClickDouble: boolean = false;

    private _currentWheelConfig: WheelConfig = null;

    protected onLoad(): void {
        // 注册事件
        Log.Debug("PopGameWin onLoad");
        EventCenter.on(EventName.onAdComplete, this.onAdComplete, this);
    }

    start() {
        // 注册按钮点击事件
        this.btnClaim.node.on('click', this.onClaimClick, this);
        this.btnDouble.node.on('click', this.onDoubleClick, this);
        this.btnOneReward.node.on('click', this.onClaimClick, this);

        // 替换描述
        this.labelCongratulation.string = Language.instance.getDes("11");
        this.labelDouble.string = Language.instance.getDes("60");
        this.labelClaim.string = Language.instance.getDes("10");
        this.labelClaim1.string = Language.instance.getDes("60");

        this._isClickDouble = false;
    }

    updateUI(isOneReward: boolean, rewardType: WheelRewardType, rewardValue: number, doubleReward: number, more: number) {

        if (isOneReward) {
            this.oneRewardNode.active = true;
            this.twoRewardNode.active = false;
        } else {
            this.oneRewardNode.active = false;
            this.twoRewardNode.active = true;
        }

        this._reward = rewardValue;
        this._doubleReward = doubleReward;
        this._rewardType = rewardType;
        this._currentWheelConfig = WheelMgr.Instance.getCurrentWheelConfig();

        this.labelMore.string = more.toString();

        if (rewardType == WheelRewardType.Dollar) {
            ResourceManager.loadRes(CurrencyManager.instance.getOneMoneyIcon(), cc.SpriteFrame, (frame: cc.SpriteFrame) => {
                if (frame && cc.isValid(this.spriteOneReward1)) {
                    this.spriteOneReward1.spriteFrame = frame;
                    this.spriteOneReward1.node.scale = 1.5;
                } else {
                    Log.Error("PopReward loadRes error, url = " + CurrencyManager.instance.getOneMoneyIcon());
                }
            });

            ResourceManager.loadRes(CurrencyManager.instance.getMoreMoneyIcon(), cc.SpriteFrame, (frame: cc.SpriteFrame) => {
                if (frame && cc.isValid(this.spriteTwoReward)) {
                    this.spriteTwoReward.spriteFrame = frame;
                    this.spriteTwoReward.node.scale = 1;
                } else {
                    Log.Error("PopReward loadRes error, url = " + CurrencyManager.instance.getMoreMoneyIcon());
                }
            });

            ResourceManager.loadRes(CurrencyManager.instance.getMoreMoneyIcon(), cc.SpriteFrame, (frame: cc.SpriteFrame) => {
                if (frame && cc.isValid(this.spriteOneReward)) {
                    this.spriteOneReward.spriteFrame = frame;
                    this.spriteOneReward.node.scale = 1;
                } else {
                    Log.Error("PopReward loadRes error, url = " + CurrencyManager.instance.getOneMoneyIcon());
                }
            });

            this.labelOneReward.string = "+" + CurrencyManager.instance.formatMoney(this._reward, true);
            this.labelOneReward1.string = "+" + CurrencyManager.instance.formatMoney(this._reward, true);
            this.labelTwoReward.string = "+" + CurrencyManager.instance.formatMoney(doubleReward, true);
        } else {
            let one_path = "Atlas/Common/daoju_big";
            let more_path = "Atlas/Common/daoju_more";
            ResourceManager.loadRes(one_path, cc.SpriteFrame, (frame: cc.SpriteFrame) => {
                if (frame && cc.isValid(this.spriteOneReward1)) {
                    this.spriteOneReward1.spriteFrame = frame;
                    this.spriteOneReward1.node.scale = 1;
                } else {
                    Log.Error("PopReward loadRes error, url = " + one_path);
                }
            });

            ResourceManager.loadRes(more_path, cc.SpriteFrame, (frame: cc.SpriteFrame) => {
                if (frame && cc.isValid(this.spriteTwoReward)) {
                    this.spriteTwoReward.spriteFrame = frame;
                    this.spriteTwoReward.node.scale = 1;
                } else {
                    Log.Error("PopReward loadRes error, url = " + more_path);
                }
            });

            ResourceManager.loadRes(more_path, cc.SpriteFrame, (frame: cc.SpriteFrame) => {
                if (frame && cc.isValid(this.spriteOneReward)) {
                    this.spriteOneReward.spriteFrame = frame;
                    this.spriteOneReward.node.scale = 1;
                } else {
                    Log.Error("PopReward loadRes error, url = " + more_path);
                }
            });

            this.labelOneReward.string = "+" + CurrencyManager.instance.formatMoney(this._reward, true);
            this.labelOneReward1.string = "+" + CurrencyManager.instance.formatMoney(this._reward, true);
            this.labelTwoReward.string = "+" + CurrencyManager.instance.formatMoney(doubleReward, true);
        }
    }

    /**
     * 下一关按钮点击
     */
    onClaimClick() {
        Log.Debug('zq onClaimClick ----------------------- ');
        this._isClickDouble = false;
        SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        // 是否会强制看广告
        let wheelConfig = this._currentWheelConfig;
        if (!wheelConfig) {
            wheelConfig = WheelMgr.Instance.getCurrentWheelConfig();
        }
        let isForceVideo = wheelConfig.ADRewardClaim;
        if (isForceVideo === 1) {
            // 强制看广告
            AdMgr.Instance.showAd(ModuleType.CommonReward, AdType.ClaimReward);
        } else {

            if (this._rewardType == WheelRewardType.Dollar) {
                UserDataMgr.Instance.addMoneyNumber(this._reward, true);
            } else {
                UserDataMgr.Instance.addTipNumber(this._reward);
            }
            this.buryPoint(false);

            // 关闭弹窗
            UIManager.Instance.close(PrefabDefine.PopReward);
        }
    }

    /**
     * 双倍奖励按钮点击
     */
    onDoubleClick() {
        Log.Debug('onDoubleClick');
        this._isClickDouble = true;
        SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        AdMgr.Instance.showAd(ModuleType.CommonReward, AdType.DoubleReward);
    }

    private onAdComplete(isSuccess: boolean, moduleType: ModuleType) {
        if (moduleType !== ModuleType.CommonReward) {
            return;
        }

        let reward = this._reward;
        if (isSuccess) {
            reward = this._doubleReward;
        }

        if (this._rewardType == WheelRewardType.Dollar) {
            UserDataMgr.Instance.addMoneyNumber(reward, true);
        } else {
            UserDataMgr.Instance.addTipNumber(reward);
        }
        this.buryPoint(isSuccess);

        // 关闭弹窗
        UIManager.Instance.close(PrefabDefine.PopReward);
    }

    private buryPoint(adSuccess: boolean) {
        // 打点
        let esData = {
            rewardType: this._rewardType,
            Amonut: this._reward,
            isClickDouble: this._isClickDouble,
            AdSuccess: adSuccess,
        }
        NativeApi.instance.buryPoint("SlotsSettle", JSON.stringify(esData));
    }

    /**
    * 组件销毁时清理事件
    */
    onDestroy() {
        EventCenter.off(EventName.onAdComplete, this.onAdComplete, this);
        EventCenter.dispatchEvent(EventName.PopRewardClose);
    }

    showEnterAnim() {
        this.contentNode.active = true;
        this.contentNode.scale = 1
        this.contentNode.opacity = 255;

        cc.tween(this.bgNode)
            .to(0.2, { opacity: 255 })
            .start();

        this.levelNode.opacity = 1;
        this.levelNode.scale = 0.3;
        cc.tween(this.levelNode)
            .to(0.25, { scale: 1.14, opacity: 255 }, { easing: cc.easing.sineOut })
            .to(0.1, { scale: 1, opacity: 255 }, { easing: cc.easing.sineOut })
            .start();

        this.oneRewardAnimNode.opacity = 0;
        this.oneRewardAnimNode.scale = 0.3;
        cc.tween(this.oneRewardAnimNode)
            .delay(0.2)
            .to(0.2, { opacity: 255, scale: 1.14 }, { easing: cc.easing.sineOut })
            .to(0.1, { scale: 1 }, { easing: cc.easing.sineOut })
            .start();

        this.twoRewardAnimNode.opacity = 0;
        this.twoRewardAnimNode.scale = 0.3;
        cc.tween(this.twoRewardAnimNode)
            .delay(0.2)
            .to(0.2, { opacity: 255, scale: 1.14 })
            .to(0.1, { scale: 1 })
            .start();

        this.btnOneReward.node.opacity = 0;
        this.btnOneReward.node.scale = 0.3;
        cc.tween(this.btnOneReward.node)
            .delay(0.4)
            .to(0.2, { opacity: 255, scale: 1.14 })
            .to(0.1, { scale: 1 })
            .start();

        this.btnClaim.node.opacity = 0;
        cc.tween(this.btnClaim.node)
            .delay(0.4)
            .to(0.2, { opacity: 120 })
            .start();

        this.btnDouble.node.opacity = 0;
        cc.tween(this.btnDouble.node)
            .delay(0.4)
            .to(0.2, { opacity: 255 })
            .call(() => {
                this._enterAnimEnd = true;
            })
            .start();

        this.scheduleOnce(() => {
            this.caidaiSpineNode.active = true;
        }, 0.5);
    }
}
