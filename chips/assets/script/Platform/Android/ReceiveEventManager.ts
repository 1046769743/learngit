import { EventName } from '../../Common/EventName';
import { EventCenter } from '../../FrameWork/EventCenter';
import { Log } from '../../FrameWork/Log';
import { PrefabDefine } from '../../FrameWork/PrefabDefine';
import { UIManager } from '../../FrameWork/UIManager';
import AdMgr from '../../Module/AdModel/AdMgr';
import CurrencyManager from '../../Module/Currency/CurrencyManager';
import { GameMgr } from '../../Module/Game/GameMgr';
import { GuideMgr } from '../../Module/Guide/GuideMgr';
import RewardMgr from '../../Module/Reward/RewardMgr';
import TaskMgr from '../../Module/TaskModule/TaskMgr';
import UserDataMgr from '../../Module/UserData/UserDataMgr';
import { NativeApi } from './NativeApi';
import GameUI from '../../View/Game/GameUI';

const { ccclass, property } = cc._decorator;
declare global {
    interface Window {
        ReceiveEventManager: any;
    }
}

export class ReceiveEventManager {

    public static showVideoCallBack(result: string) {
        Log.Debug("ReceiveEventManager OnAdCompleteEvent result = " + result);
        let res = JSON.parse(result);
        if (res && res.showAdRes == 1) {
            AdMgr.Instance.onAdComplete(true);
        } else {
            AdMgr.Instance.onAdComplete(false);
        }
    }

    public static reportCurrentRewardStr(result: string) {
        Log.Debug("ReceiveEventManager reportCurrentRewardstr result = " + result);
        let res = JSON.parse(result);
        if (res && res.amount > 0) {
            UserDataMgr.Instance.restTargetWithdrawMoney(res.amount);
            Log.Debug("ReceiveEventManager reportCurrentRewardStr success, amount = " + res.amount);
        }
    }

    public static withdrawSuccess(result: string) {
        Log.Debug("ReceiveEventManager withdrawSuccess result = " + result);
        UserDataMgr.Instance.addWithdrawIndex();
        let res = Number(result);
        let rate = CurrencyManager.instance.getExchangeRate();
        let money = (res * 1000 / rate) / 1000;
        UserDataMgr.Instance.updateMoneyNumber(money);
    }

    // 可以显示H5的图标
    public static showH5ViewIconCallBack(result: string) {
        Log.Debug("ReceiveEventManager showH5ViewIconCallBack result = " + result);
        let res = JSON.parse(result);
        let isAttributionUser = res && res.isAttributionUser;
        EventCenter.dispatchEvent(EventName.ShowH5ViewIcon, isAttributionUser);

    }

    // H5中增加金额后调用，，，增加金额之后，cocos 会回调updateH5Cfg，然后更新下一次任务奖励。
    public static showH5ViewCallBack(result: string) {
        Log.Debug("ReceiveEventManager showH5ViewCallBack result = " + result);
        let res = JSON.parse(result);
        if (res && res.amount) {
            UserDataMgr.Instance.addMoneyNumber(res.amount);
        }

        let newH5Reward = RewardMgr.Instance.getH5RewardConfig();
        NativeApi.instance.updateH5Cfg(newH5Reward);
    }

    // h5关闭后调用
    public static showH5ViewCloseCallBack() {
        Log.Debug("ReceiveEventManager showH5ViewCloseCallBack");

    }

    // 提现时间限制结束
    public static withdrawTimeLimitEnd() {
        Log.Debug("ReceiveEventManager withdrawTimeLimitEnd");
        TaskMgr.Instance.setIsWithdrawTaskOpen(true);
        UserDataMgr.Instance.isWithdrawTimeLimitEnd = true;
    }

    // 提现页主动点击
    public static wdToGameOpenTimeLimitEndEvent() {
        Log.Debug("ReceiveEventManager wdToGameOpenTimeLimitEndEvent");
        UIManager.Instance.open(PrefabDefine.PopTask);
    }

    // 消耗金卡
    public static consumeGoldCard(result: string) {
        Log.Debug("ReceiveEventManager consumeGoldCard result = " + result);
        let res = Number(result);
        UserDataMgr.Instance.subGoldenCardNumber(res);
    }



    public static OnGetGameStatusSuccessEvent(jsonData: any) {
        Log.Debug(`[Android] Receive OnGetGameStatusSuccessEvent: ${JSON.stringify(jsonData)}`);

        GameMgr.Instance.InitData(jsonData as GameStatusData);
    }

    /**
     * 展示奖励进度条(同时也是新人冲关福利已经领取的事件)
     */
    public static OnNewUserWelfareReceivedEvent() {
        GameMgr.Instance.receiveNewUserWelfare();
        EventCenter.dispatchEvent(EventName.NewUserWelfareReceivedEvent);
    }

    /**
     * 展示下一个目标高亮
     */
    public static OnShowNextTargetHighlightEvent() {
        Log.Debug(`ReceiveEventManager  OnShowNextTargetHighlightEvent `);

        let cb = () => {
            GuideMgr.Instance.guideUI.hide();
        };

        GuideMgr.Instance.guideUI.show(true, cb, cb);
        GuideMgr.Instance.guideUI.showTarget(GameMgr.Instance.GameUI.maxRewardGuideTarget, GameMgr.Instance.GameUI.maxRewardTipTarget, false);
        let wdHightCofig = GameMgr.Instance.gameStatusData.game_config_json.wd_config_high;
        let wdRealConfig = GameMgr.Instance.gameStatusData.game_config_json.wd_config_real;
        GameMgr.Instance.gameStatusData.is_new_user_welfare_received = true;
        let nextTarget = GameMgr.Instance.GetCurTargetProgress();
        let targetLevel = 15;
        if (GameMgr.Instance.gameStatusData.is_new_user_welfare_received) {
            let index = nextTarget / 10;
            let target = wdRealConfig.find(_ => _ >= index);
            if (target) {
                targetLevel = target;
            } else {
                targetLevel = wdRealConfig[wdRealConfig.length - 1];
            }
        } else {
            if (wdHightCofig) {
                let target = wdHightCofig[0];
                targetLevel = target;
            }
        }
        GuideMgr.Instance.guideUI.showTips(`合成到${targetLevel}，就能提现啦`, 600, 150);
    }

    /**
     *
     * @param jsonData
     * @returns
     */
    public static OnRemoveChipEvent(jsonData: any) {
        Log.Debug(`ReceiveEventManager  OnRemoveChipEvent:   ${JSON.stringify(jsonData)} `);
        if (jsonData == null) {
            return;
        }

        let removeValue = jsonData["remove_chips_value"] as number ?? 0;
        let isAuto = jsonData["is_auto"] as boolean ?? false;
        Log.Debug(`ReceiveEventManager  OnRemoveChipEvent:   removeValue:  ${removeValue}, isAuto:  ${isAuto} `);
        EventCenter.dispatchEvent(EventName.RemoveChipEvent, removeValue, isAuto);
    }

    /**
     * 使用洗牌道具状态 status :bool true代表成功 false 代表失败
     */
    public static OnUseShuffleCardStatusEvent(jsonData: any) {
        Log.Debug(`[Android] Receive OnUseShuffleCardStatusEvent: ${JSON.stringify(jsonData)}`);
        var data = jsonData as UseShuffleCardStatus;
        if (data.status) {
            let ComboGroup = cc.find("Canvas/UILayer/HomeUI/GameUI")
            ComboGroup.getComponent(GameUI).ShuffChips();
        }
    }

    /**
     * 解锁筹码盒子状态 type: Int //解锁槽位类型 1:临时槽位 2:钻石槽位  status ：bool // true 解锁成功 false 解锁失败
     */
    public static OnUnlockChipBoxStatusEvent(jsonData: any) {
        Log.Debug(`[Android] Receive OnUnlockChipBoxStatusEvent: ${JSON.stringify(jsonData)}`);
    }

    /**
     * 展示悬浮宝箱
     */
    public static OnShowFloatBoxEvent() {
        Log.Debug(`[Android] Receive OnShowFloatBoxEvent`);
        EventCenter.dispatchEvent(EventName.PlayNpcAnimation);
    }

    /**
     * 刷新货币体系的数值（游戏货币+红包）
     */
    public static OnRefreshCurrencyValueEvent(jsonData: any) {
        Log.Debug(`[Android] Receive OnRefreshCurrencyValueEvent: ${JSON.stringify(jsonData)}`);
        var data = jsonData as RefreshCurrencyValue;
        GameMgr.Instance.OnRefreshCurrencyValueEvent(data);

    }

    /**
     * 用户GameOver选择继续闯关
     */
    public static OnGameReplayEvent() {
        Log.Debug(`[Android] Receive OnGameReplayEvent`);
        // GameMgr.Instance.ResartGame();
    }

    public static OnWithdrawDialogCloseEvent() {
        Log.Debug(`[Android] Receive OnWithdrawDialogCloseEvent`);

    }

    /**
     * 自动解锁槽位
     */
    public static OnAutoUnlockSlotEvent() {
        //EventCenter.dispatchEvent(EventName.AutoUnlockSlotEvent);
    }

    public static OnShowGuide15Event() {
        GuideMgr.Instance.changeStep(0, 15);
    }
}

window.ReceiveEventManager = ReceiveEventManager;