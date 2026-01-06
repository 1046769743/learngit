// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { EventName } from "../../Common/EventName";
import ClientConfig from "../../Data/ClientConfig";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import { UIManager } from "../../FrameWork/UIManager";
import { NativeApi } from "../../Platform/Android/NativeApi";
import { SoundManager } from "../Audio/SoundManager";
import CurrencyManager from "../Currency/CurrencyManager";
import { GameMgr } from "../Game/GameMgr";
import UserDataMgr from "../UserData/UserDataMgr";

const { ccclass, property } = cc._decorator;

export class WithdrawHistoryData {
    public id: string = "";
    public money: number = 0;
    public time: number = 0;
}

@ccclass
export default class WithdrawMgr {

    private static _instance: WithdrawMgr;
    // 是否弹出过弹出
    private readonly IS_POP_WITHDRAW_OPENED_KEY: string = "isPopWithdrawOpened";
    // cash out 弹窗是否出现过
    private readonly IS_POP_CASH_OUT_OPENED_KEY: string = "isPopCashOutOpened";
    // 是否首次提现成功
    private readonly IS_FIRST_WITHDRAW_SUCCESS_KEY: string = "isFirstWithdrawSuccess";

    static get Instance() {
        if (this._instance) {
            return this._instance;
        }
        this._instance = new WithdrawMgr();
        return this._instance;
    }

    // 提现配置列表
    private _withdrawConfigList: number[] = [];
    private _withdrawConfigListExchangeRate: number[] = [];
    // 提现条件
    private _withdrawConditionList: { type: number, value: number }[] = [];
    // 提现需要的金卡数量
    private _withdrawGoldenCardCount: number = 0;
    // 弹窗是否出现过
    private _popOpened: boolean = false;
    // cash out 弹窗是否出现过
    private _cashOutPopOpened: boolean = false;

    /**1.0.1需求 */
    // 提现条件列表
    private _withdrawConditionList101: number[] = [];
    private _withdrawGoldenCardCount101: number[] = [];

    public init() {
        let info = ClientConfig.globalConfig.WithdrawList;
        let str = info.Value;
        this._withdrawConfigList = str.split("|").map(item => parseInt(item));

        this._withdrawConfigListExchangeRate = this._withdrawConfigList.map(item => CurrencyManager.instance.convertToLocalCurrency(item));

        let conditionInfo101 = ClientConfig.globalConfig.WithdrawListCondition.Value;
        let conditionList101 = conditionInfo101.split("|");
        for (let i = 0; i < conditionList101.length; i++) {
            let item = conditionList101[i];
            this._withdrawConditionList101.push(parseInt(item));
        }

        let goldenCardInfo101 = ClientConfig.globalConfig.WithdrawGoldenCard.Value;
        let goldenCardList101 = goldenCardInfo101.split("|");
        for (let i = 0; i < goldenCardList101.length; i++) {
            let item = goldenCardList101[i];
            this._withdrawGoldenCardCount101.push(parseInt(item));
        }

        let conditionInfo = ClientConfig.globalConfig.WithdrawListCondition;
        let conditionStr = conditionInfo.Value;
        let conditionList = conditionStr.split("|");
        for (let i = 0; i < conditionList.length; i++) {
            let item = conditionList[i];
            let list = item.split(";");
            if (list.length == 1) {
                this._withdrawConditionList.push({ type: 1, value: CurrencyManager.instance.convertToLocalCurrency(this._withdrawConfigList[i]) });
            }
            else if (list.length == 2) {
                this._withdrawConditionList.push({ type: parseInt(list[0]), value: parseInt(list[1]) });
            }
        }

        let goldenCardInfo = ClientConfig.globalConfig.WithdrawGoldenCard;
        let goldenCardStr = goldenCardInfo.Value;
        this._withdrawGoldenCardCount = parseInt(goldenCardStr);

        Log.Debug("WithdrawMgr _withdrawConditionList = " + JSON.stringify(this._withdrawConditionList));
        Log.Debug("WithdrawMgr _withdrawConfigList = " + JSON.stringify(this._withdrawConfigList));

        this._popOpened = StorageManager.Instance.getBoolean(this.IS_POP_WITHDRAW_OPENED_KEY, false);
        this._cashOutPopOpened = StorageManager.Instance.getBoolean(this.IS_POP_CASH_OUT_OPENED_KEY, false);

        EventCenter.on(EventName.PopupClose, this.onPopupClose, this);
    }

    public getWithdrawConfigList(): number[] {
        return this._withdrawConfigList;
    }

    public getWithdrawConfigListExchangeRate(): number[] {
        return this._withdrawConfigList.map(item => CurrencyManager.instance.convertToLocalCurrency(item));
    }

    // 判断是否可提现
    public isCanWithdraw(index: number) {
        let currentMoneyCount = UserDataMgr.Instance.moneyNumber;
        let withdrawCount = this._withdrawConfigList[index];
        return currentMoneyCount >= withdrawCount;
    }

    public shouldShowPopupOnFirstLogin(): boolean {
        if (this._popOpened) {
            return false;
        }

        let list = this._withdrawConfigList;
        if (list.length == 0) {
            return false;
        }

        let target = list[0];
        let currentMoney = UserDataMgr.Instance.moneyNumber;
        if (currentMoney >= target) {
            StorageManager.Instance.set(this.IS_POP_WITHDRAW_OPENED_KEY, true);
            this._popOpened = true;
            return true;
        }
        return false;
    }

    private onPopupClose(name: string) {
        if (this.shouldShowPopupOnFirstLogin()) {
            UIManager.Instance.open(PrefabDefine.PopWithdraw);
        }
    }

    public openWithdraw(showGuide: number = 0) {

        let cardList = [];
        cardList.push(UserDataMgr.Instance.goldenCardNumber);
        cardList.push(this._withdrawGoldenCardCount);

        for (let i = 0; i < this._withdrawConditionList.length; i++) {
            let item = this._withdrawConditionList[i];
            if (item.type == 3) {
                cardList.push(item.value);
            }
        }



        let str = JSON.stringify({
            currentMoney: CurrencyManager.instance.convertToLocalCurrency(UserDataMgr.Instance.moneyNumber),
            goldCard: UserDataMgr.Instance.goldenCardNumber,
            withdrawList: this._withdrawConfigListExchangeRate,
            withdrawListCondition: this._withdrawConditionList101,
            withdrawGoldenCardList: this._withdrawGoldenCardCount101,
            musicSwitch: SoundManager.Instance.IsMusicOn,
            soundSwitch: SoundManager.Instance.IsSoundOn,
            showGuide: showGuide,
            level: GameMgr.Instance.getCurrentLevel(),
        });
        NativeApi.instance.showWithdrawPage(str);
    }

    // 是否 cash out icon是否可以显示
    public isCanShowCashOutPopup() {
        return this._cashOutPopOpened;
    }

    public set CashOutPopOpened(value: boolean) {
        this._cashOutPopOpened = value;
        StorageManager.Instance.set(this.IS_POP_CASH_OUT_OPENED_KEY, value);
        EventCenter.dispatchEvent(EventName.CashOutPopupOpened);
    }

    public canCashOutPopup() {
        if (this._cashOutPopOpened) {
            return false;
        }
        return true;
    }

    // 提现成功
    public withdrawSuccess() {
        // 是不是首次提现成功
        let isFirstWithdrawSuccess = StorageManager.Instance.getBoolean(this.IS_FIRST_WITHDRAW_SUCCESS_KEY, false);
        if (isFirstWithdrawSuccess) {
            return;
        }
        StorageManager.Instance.set(this.IS_FIRST_WITHDRAW_SUCCESS_KEY, true);
        UIManager.Instance.open(PrefabDefine.PopCashOut);
    }
}