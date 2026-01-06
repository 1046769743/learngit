import { ChipSlotType } from "../../Common/EnumDefine";
import ClientConfig, { ConfigKey } from "../../Data/ClientConfig";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { UIManager } from "../../FrameWork/UIManager";
import AdMgr from "../../Module/AdModel/AdMgr";
import { Country, LanguageType } from "../../Module/Language/Language";
import { ReceiveEventManager } from "./ReceiveEventManager";
import { SimulationMgr } from "./SimulationMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export class NativeApi {
    private static _instance: NativeApi;
    public static get instance(): NativeApi {
        if (!this._instance) {
            this._instance = new NativeApi();
        }
        return this._instance;
    }

    private NativeClassUrl: string = "com.search.wool.mas.WSMasWo";

    private cocosToAndroid(methodName: string, parameters: any[]) {
        if (cc.sys.os == cc.sys.OS_ANDROID && cc.sys.isNative) {
            let msg = {
                wsm_1: methodName
            }
            let obj = {};
            for (let i = 0; i < parameters.length; i++) {
                let value = parameters[i];
                let key = "wsm_" + (i + 2);
                obj[key] = value

            }
            Object.assign(msg, obj)
            let str = JSON.stringify(msg);
            let res = jsb.reflection.callStaticMethod(this.NativeClassUrl, "wSMasWo", "(Ljava/lang/String;)Ljava/lang/String;", str);
            Log.Debug("NativeApi cocosToAndroid methodName = " + methodName + " parameters = " + str + " res = " + res);
            return res;
        }
    }

    /**
     * 是否为debug包
     * true: debug; false: release
     */
    public getDebugBuild(): boolean {
        return CC_DEBUG;
    }

    /**
     * cocos 首个场景初始化成功
     */
    public enterGame() {
        if (cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative) {
            this.cocosToAndroid("enterGame", []);
        }
    }

    /**
     * 显示广告 0:double reward  1：claim reward  2：bulb reward 3：fly box
     */
    public showVideo(type: number) {
        Log.Debug("NativeApi showVideo type = " + type);
        if (cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative) {
            this.cocosToAndroid("showVideo", [type]);
        } else {
            UIManager.Instance.open(PrefabDefine.PopAdTest);
        }
    }

    // 获取用户信息
    public getCommonParm() {
        if (cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative) {
            return this.cocosToAndroid("getCommonParm", []);
        }
        var result = {
            language: LanguageType.EN,
            country: Country.US,
            userId: "1234567890",
        };
        return JSON.stringify(result);
    }

    // 是否是白包
    public requestIsWhiteBao() {
        var result = false;
        if (cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative) {
            return this.cocosToAndroid("requestIsWhiteBao", []) !== "1";
        }
        return result;
    }

    // 震动
    public phoneVibrate() {
        if (cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative) {
            this.cocosToAndroid("phoneVibrate", []);
        }
    }

    // 打点
    public buryPoint(event: string, params: string = null) {
        Log.Debug("NativeApi buryPoint event = " + event + " params = " + params);
        if (cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative) {
            this.cocosToAndroid("buryPoint", [event, params]);
        }
    }

    // 打开提现页面
    public showWithdrawPage(str: string) {
        Log.Debug("NativeApi showWithdrawPage str = " + str);
        if (cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative) {
            this.cocosToAndroid("showWithdraw", [str]);
        }
    }

    public getCurrentReward(str: string) {
        Log.Debug("NativeApi getCurrentReward str = " + str);
        if (cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative) {
            return this.cocosToAndroid("getCurrentReward", [str]);
        }
        return null;
    }

    // 隐私协议
    public privacyPolicy() {
        let url = "https://www.google.com";
        if (cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative) {
            // PrivacyPolicy
            let privacyPolicy = ClientConfig.globalConfig.PrivacyPolicy.Value;
            url = privacyPolicy;
        }
        cc.sys.openURL(url);
    }

    // 用户协议
    public termsOfUse() {
        let url = "https://www.google.com";
        if (cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative) {
            let termsOfUse = ClientConfig.globalConfig.TermsOfUse.Value;
            url = termsOfUse;
        }
        cc.sys.openURL(url);
    }

    // 是否可以展示h5按钮
    public canShowH5View() {
        if (cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative) {
            return this.cocosToAndroid("canShowH5View", []) == "1";
        }
        return false;
    }

    // 游戏页点击H5图标
    public showH5View() {
        if (cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative) {
            this.cocosToAndroid("showH5View", []);
        }
    }

    // 更新H5奖励
    public updateH5Cfg(reward: number) {
        if (cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative) {
            this.cocosToAndroid("updateH5Cfg", [reward]);
        }
    }

    // 过关调用
    public passLevel(level: number) {
        if (cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative) {
            this.cocosToAndroid("getMergeReward", [level]);
        }
    }

    // 同步安卓当前余额
    public syncAndroidBalance(currentBalance: string) {
        Log.Debug("NativeApi syncAndroidBalance currentBalance = " + currentBalance);
        if (cc.sys.os === cc.sys.OS_ANDROID && cc.sys.isNative) {
            this.cocosToAndroid("reportBalanceStr", [currentBalance]);
        }
    }

    // chips
    /**
     * 触发震动
     */
    public onVibrate() {

    }

    public vibrateLong() {

    }

    /**
     * unity初始化完成，可以进行刷新ui等操作了
     */
    public onGameInitFinished() {
        SimulationMgr.onGameInitFinished();

    }

    /**
     * 保存游戏数据
     */
    public saveGameData(data: any) {
        Log.Debug(`saveGameData`);
        SimulationMgr.saveGameData(data);
    }

    /**
     * 通知android隐藏loading
     */
    public onRefreshGameStatusFinished() {

    }

    /**
     * 设置挖孔屏手机顶部偏移量
     */
    public getTopOffsetValue(): number {
        var result = 60;
        return result;
    }

    /**
     * 红包收集动画飞入坐标，即红包中心位置
     */
    public onRedPacketEntryPosition(x: number, y: number) {

    }

    /**
     * 钻石icon中心位置
     */
    public onGameDiamondEntryPosition(x: number, y: number) {

    }

    /**
     * 点击悬浮宝箱
     */
    public onClickFloatBox() {

    }

    /**
     * 展示悬浮宝箱 （埋点用）
     */
    public onFloatBoxShow() {

    }

    /**
     * 获取产品Flavor，例如"melon10"
     */
    public getFlavorId(): string {
        var result = "Chips";
        return result;
    }

    /**
     * 用户引导出现
     */
    public onGamePlayGuideShow() {

    }

    /**
     * 点击设置
     */
    public onClickSetting() {

    }

    /**
     * 点击头像区
     */
    public onClickProfileEntry() {

    }

    /**
     * 点击洗牌道具
     */
    public onClickShuffleCard(remainTimes: number) {
        SimulationMgr.onClickShuffleCard();
    }

    /**
     * 解锁筹码盒子 
     */
    public unlockChipBox(slotType: ChipSlotType, slotId: number) {
        let type = slotType == ChipSlotType.Temporary ? 1 : 2;
        Log.Debug("NativeApi unlockChipBox  slotId: " + slotId + " type: " + type);
        SimulationMgr.unlockChipBox(slotType, slotId);
    }

    /**
     * 合成结束
     */
    public onMergeEnd(rewardMap: any, current_max_chip_num: number, red_packet_reward: number) {

    }

    /**
     * 点击发牌
     */
    public onClickDealCard() {

    }

    /**
     * 临时槽位关闭
     */
    public onTemporarySlotClose() {

    }

    public onSlotUnlock(slotType: ChipSlotType, temporSlotCount: number) {

    }

    public onChipMove(from: number, to: number) {

    }

    public onChipMerge(isTempMerge: boolean, isOtherMerge: boolean) {
        Log.Debug(`[Android] Receive onChipMerge isTempMerge =: ${isTempMerge}  isOtherMerge =${isOtherMerge}`);

    }

    public onCurrentMaxChipDetail(currentMaxChipNum: number, currentMaxChipValue: number) {
        Log.Debug(`[Android] Receive onCurrentMaxChipDetail currentMaxChipNum =: ${currentMaxChipNum}  currentMaxChipValue =${currentMaxChipValue}`);

    }

    /**
     * 获取悬浮宝箱开关
     */
    public getFloatBoxSwitch(): boolean {
        var result = true;

        return result;
    }

    /**
     * 游戏失败，展示闯关失败页面
     */
    public onGameOver() {
        SimulationMgr.OnGameReplayEvent();
    }

    /**
     * 显示toast
     * @param msg 
     */
    public showToast(msg: string) {
        Log.Debug(`[NativeApi] showToast,  content:  ${msg}`);

    }

    /**
     * 展示挪不动了，游戏无法进行且还有临时槽位没解锁 
     * @param slotId 临时槽位id
     * @param canShuffleCount 可洗牌次数 如果不限次，请发-1
     * @param canUnlockSlotCount 解锁槽位数量
     */
    public onShowUnlockChipBoxDialog(slotId: number, canShuffleCount: number, canUnlockSlotCount: number) {
        SimulationMgr.onShowUnlockChipBoxDialog(slotId);
    }

    /**
     * 短剧入口
     */
    public onDramaEnterClick() {
        Log.Debug(`[NativeApi] onDramaEnterClick`);

    }

    /**
     * 点击提现按钮
     */
    public onClickRedPacketWithdrawEntry() {

    }

    public updateGuideStep(stepID: number) {
        Log.Debug(`[Guide] updateGuideStep stepID = ${stepID}`);

    }

    public uploadGuideEvent(stepID: number) {
        Log.Debug(`[Guide] uploadGuideEvent stepID = ${stepID}`);

    }

    /**
     * 点击移除道具
     */
    public onClickRemoveProp(remainTimes: number) {
        Log.Debug(`[NativeApi] onClickRemoveProp`);

    }

    /**
     * 玩家历史合成的最大筹码值
     */
    public getHistoryMaxChipNum(): number {
        Log.Debug(`[NativeApi] getHistoryMaxChipNum`);
        let result = -1;
        return result;
    }
}

