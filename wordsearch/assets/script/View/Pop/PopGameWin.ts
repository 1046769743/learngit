// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { EventName } from "../../Common/EventName";
import ClientConfig, { ConfigKey } from "../../Data/ClientConfig";
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
import RewardMgr from "../../Module/Reward/RewardMgr";
import TaskMgr from "../../Module/TaskModule/TaskMgr";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";
import BasePop from "./BasePop";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopGameWin extends BasePop {
    @property(cc.Node)
    levelNode: cc.Node = null;

    @property(cc.Label)
    labelDouble: cc.Label = null;

    @property(cc.Label)
    labelClaim1: cc.Label = null;

    @property(cc.Label)
    labelClaim2: cc.Label = null;

    @property(cc.Label)
    labelMore: cc.Label = null;

    @property(cc.Label)
    labelLevel: cc.Label = null;

    @property(cc.Node)
    oneRewardNode: cc.Node = null;

    @property(cc.Label)
    labelOneReward: cc.Label = null;

    @property(cc.Sprite)
    spriteOneReward: cc.Sprite = null;

    @property(cc.Button)
    btnOneReward: cc.Button = null;

    @property(cc.Node)
    twoRewardNode: cc.Node = null;

    @property(cc.Label)
    labelOneReward1: cc.Label = null;

    @property(cc.Sprite)
    spriteOneReward1: cc.Sprite = null;

    @property(cc.Label)
    labelTwoReward: cc.Label = null;

    @property(cc.Sprite)
    spriteTwoReward: cc.Sprite = null;

    @property(cc.Button)
    btnOneReward1: cc.Button = null;

    @property(cc.Button)
    btnDouble: cc.Button = null;

    @property(cc.Node)
    oneRewardAnimNode: cc.Node = null;

    @property(cc.Node)
    twoRewardAnimNode: cc.Node = null;

    @property(sp.Skeleton)
    caidaiSpine: sp.Skeleton = null;

    private _reward: number = 0;
    private _enterAnimEnd: boolean = false;
    private _isClickDouble: boolean = false;
    private _currentLevelId: number = 0;

    /**1.0.1需求 */
    // 关闭弹窗时是否出插屏广告
    private _interstitialAdType: AdType = AdType.None;

    protected onLoad(): void {
        // 注册事件
        Log.Debug("PopGameWin onLoad");
        EventCenter.on(EventName.onAdComplete, this.onAdComplete, this);
    }

    start() {
        // 注册按钮点击事件
        this.btnOneReward.node.on('click', this.onClaimClick, this);
        this.btnOneReward1.node.on('click', this.onClaimClick, this);
        this.btnDouble.node.on('click', this.onDoubleClick, this);

        this._enterAnimEnd = false;
        this._isClickDouble = false;
        this._interstitialAdType = AdType.None;

        this.caidaiSpine.node.active = false;

        let currentLevelConfig = GameMgr.Instance.getCurrentWordSearchLevelConfig();

        let rewardConfig = RewardMgr.Instance.getRewardConfig();
        let betReward = 2;
        let rewardShowBet = 2;
        if (rewardConfig) {
            betReward = rewardConfig.ADRewardBet;
            rewardShowBet = rewardConfig.RewardShowBet;
        }

        // 替换描述
        this.labelDouble.string = Language.instance.getDes("60");
        this.labelClaim1.string = Language.instance.getDes("60");
        this.labelClaim2.string = Language.instance.getDes("10");
        this.labelMore.string = rewardShowBet.toString();

        let levelData = GameMgr.Instance.getCurrentWordSearchGameData();
        this._currentLevelId = levelData.levelId;
        this.labelLevel.string = Language.instance.getDes("34") + " " + levelData.levelId;


        this._reward = RewardMgr.Instance.getLevelFinishRewardConfig();
        // 是否有视频入口
        let hasVideo = currentLevelConfig.IsRewardedADShow;
        if (hasVideo === 1 && betReward > 1) {
            this.oneRewardNode.active = false;
            this.twoRewardNode.active = true;

            this.labelOneReward1.string = "+" + CurrencyManager.instance.formatMoney(this._reward, true);
            ResourceManager.loadRes(CurrencyManager.instance.getOneMoneyIcon(), cc.SpriteFrame, (frame: cc.SpriteFrame) => {
                if (frame && cc.isValid(this.spriteOneReward1)) {
                    this.spriteOneReward1.spriteFrame = frame;
                } else {
                    Log.Error("PopGameWin loadRes error, url = " + CurrencyManager.instance.getOneMoneyIcon());
                }
            });

            this.labelTwoReward.string = "+" + CurrencyManager.instance.formatMoney(this._reward * betReward, true);
            ResourceManager.loadRes(CurrencyManager.instance.getMoreMoneyIcon(), cc.SpriteFrame, (frame: cc.SpriteFrame) => {
                if (frame && cc.isValid(this.spriteTwoReward)) {
                    this.spriteTwoReward.spriteFrame = frame;
                } else {
                    Log.Error("PopGameWin loadRes error, url = " + CurrencyManager.instance.getMoreMoneyIcon());
                }
            });
        } else {
            this.oneRewardNode.active = true;
            this.twoRewardNode.active = false;

            this.labelOneReward.string = "+" + CurrencyManager.instance.formatMoney(this._reward, true);
            ResourceManager.loadRes(CurrencyManager.instance.getMoreMoneyIcon(), cc.SpriteFrame, (frame: cc.SpriteFrame) => {
                if (frame && cc.isValid(this.spriteOneReward)) {
                    this.spriteOneReward.spriteFrame = frame;
                } else {
                    Log.Error("PopGameWin loadRes error, url = " + CurrencyManager.instance.getMoreMoneyIcon());
                }
            });
        }

        SoundManager.Instance.PlaySound(SOUND_NAME.LevelComplete);
    }

    /**
     * 下一关按钮点击
     */
    onClaimClick() {
        if (!this._enterAnimEnd) {
            return;
        }
        this._isClickDouble = false;
        Log.Debug('zq onClaimClick ----------------------- ');
        SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        // 是否会强制看广告
        let currentLevelConfig = GameMgr.Instance.getCurrentWordSearchLevelConfig();
        let isForceVideo = currentLevelConfig.ADRewardClaim;
        if (isForceVideo === 2) {
            // 强制看插屏
            if (currentLevelConfig.IsRewardedADShow === 1) {
                this._interstitialAdType = AdType.ClaimReward;
            } else {
                this._interstitialAdType = AdType.GameWinCollect;
            }
            AdMgr.Instance.showInterstitialAd(ModuleType.LevelFinish, this._interstitialAdType);

            UserDataMgr.Instance.addMoneyNumber(this._reward, true);
            // 关闭弹窗
            UIManager.Instance.close(PrefabDefine.PopGameWin);
            // 开始下一关   
            GameMgr.Instance.startNextLevel();
            Log.Debug('zq onClaimClick  单倍奖励----------------------- end');
        } else if (isForceVideo == 1) {
            AdMgr.Instance.showAd(ModuleType.LevelFinish, AdType.DoubleReward);
        } else {
            UserDataMgr.Instance.addMoneyNumber(this._reward, true);
            // 关闭弹窗
            UIManager.Instance.close(PrefabDefine.PopGameWin);
            // 开始下一关   
            GameMgr.Instance.startNextLevel();
        }

        // 打点
        let esData = { level: this._currentLevelId, coinAmount: this._reward, isClickDouble: false, AdSuccess: false }
        NativeApi.instance.buryPoint("LevelFinish", JSON.stringify(esData));


    }

    /**
     * 双倍奖励按钮点击
     */
    onDoubleClick() {
        if (!this._enterAnimEnd) {
            return;
        }
        this._isClickDouble = true;
        Log.Debug('onDoubleClick');
        SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        AdMgr.Instance.showAd(ModuleType.LevelFinish, AdType.DoubleReward);
        NativeApi.instance.buryPoint("LevelButtonClick");
    }

    private onAdComplete(isSuccess: boolean, moduleType: ModuleType) {
        if (moduleType !== ModuleType.LevelFinish) {
            return;
        }

        if (isSuccess) {
            let rewardConfig = RewardMgr.Instance.getRewardConfig();
            let betReward = 2;
            if (rewardConfig) {
                betReward = rewardConfig.ADRewardBet;
            }

            UserDataMgr.Instance.addMoneyNumber(this._reward * betReward, true);
        } else {
            UserDataMgr.Instance.addMoneyNumber(this._reward, true);
        }
        // 打点
        let esData = { level: this._currentLevelId, coinAmount: this._reward, isClickDouble: this._isClickDouble, AdSuccess: isSuccess }
        NativeApi.instance.buryPoint("LevelFinish", JSON.stringify(esData));
        // 关闭弹窗
        UIManager.Instance.close(PrefabDefine.PopGameWin);
        // 开始下一关   
        GameMgr.Instance.startNextLevel();
    }

    /**
    * 组件销毁时清理事件
    */
    onDestroy() {
        Log.Debug("PopGameWin onDestroy");
        EventCenter.off(EventName.onAdComplete, this.onAdComplete, this);
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
            .call(() => {
                this._enterAnimEnd = true;
            })
            .start();

        this.btnOneReward1.node.opacity = 0;
        cc.tween(this.btnOneReward1.node)
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
            this.caidaiSpine.node.active = true;
        }, 0.5);
    }
}
