import { LoadingStep } from './LoadingStep';
import { Log } from '../../FrameWork/Log';
import { GameMgr } from '../Game/GameMgr';
import { SoundManager } from '../Audio/SoundManager';
import Language from '../Language/Language';
import UserDataMgr from '../UserData/UserDataMgr';
import WithdrawMgr from '../Withdraw/WithdrawMgr';
import RewardMgr from '../Reward/RewardMgr';
import WheelMgr from '../Wheel/WheelMgr';
import TaskMgr from '../TaskModule/TaskMgr';
import { NativeApi } from '../../Platform/Android/NativeApi';
import ClientConfig, { ConfigKey } from '../../Data/ClientConfig';
import CurrencyManager from '../Currency/CurrencyManager';
import LuckWheelMgr from '../LuckWheel/LuckWheelMgr';
import PigMgr from '../Pig/PigMgr';
import DailyLoginMgr from '../DailyLogin/DailyLoginMgr';
import { SimulationMgr } from '../../Platform/Android/SimulationMgr';

const { ccclass, property } = cc._decorator;

@ccclass
export class StepInitData extends LoadingStep {
    onStart() {
        Log.Debug("StepInitData onStart");
        UserDataMgr.Instance.init();
        WithdrawMgr.Instance.init();
        RewardMgr.Instance.init();
        SoundManager.Instance.InitSound();
        LuckWheelMgr.Instance.init();
        DailyLoginMgr.Instance.init();
        PigMgr.Instance.init();
        // GameMgr.Instance.InitData(null);
        SimulationMgr.onGameInitFinished();
        NativeApi.instance.syncAndroidBalance(UserDataMgr.Instance.getMoneyString());
        let str = JSON.stringify({
            currentMoney: CurrencyManager.instance.convertToLocalCurrency(UserDataMgr.Instance.moneyNumber),
            withdrawList: WithdrawMgr.Instance.getWithdrawConfigListExchangeRate(),
            jocktopReward: 0,
            musicSwitch: SoundManager.Instance.IsMusicOn,
            soundSwitch: SoundManager.Instance.IsSoundOn,
        });
        NativeApi.instance.getCurrentReward(str);
    }

    onFrame(deltaTime: number) {
        if (GameMgr.Instance.isInitOk) {
            this.onEnd();
        }
    }

    onEnd() {
        this.IsOver = true;
        Log.Debug("StepInitGame onEnd");
    }
}

