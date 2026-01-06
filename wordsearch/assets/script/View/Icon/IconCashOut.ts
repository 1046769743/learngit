// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import DlgBtn from "../../Common/DlgBtn";
import { CollectEffectType, EffectManager } from "../../Common/EffectManager";
import { EventName } from "../../Common/EventName";
import ClientConfig from "../../Data/ClientConfig";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import { UIManager } from "../../FrameWork/UIManager";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import WithdrawMgr from "../../Module/Withdraw/WithdrawMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export default class IconCashOut extends cc.Component {
    @property(DlgBtn)
    btn: DlgBtn = null;

    @property(cc.Label)
    labelProgress: cc.Label = null;

    @property(cc.Sprite)
    progress: cc.Sprite = null;

    private _isOpened: boolean = false;

    start() {
        EventCenter.on(EventName.CashOutPopupOpened, this.onCashOutPopupOpened, this);
        EventCenter.on(EventName.UpdateGoldenCardNumber, this.updateProgress, this);
        this.btn.addClickCallback(this.onBtnClick, this);

        this._isOpened = WithdrawMgr.Instance.isCanShowCashOutPopup();
        this.node.active = this._isOpened;

        this.updateProgress();
    }

    private onCashOutPopupOpened() {
        if (this._isOpened) {
            return;
        }
        this._isOpened = true;
        this.node.active = WithdrawMgr.Instance.isCanShowCashOutPopup();
        this.updateProgress();
        UIManager.Instance.open(PrefabDefine.PopCashOut);
    }

    private updateProgress(addNum: number = 0) {
        if (!this.node.active) {
            return;
        }
        let currentProgress = UserDataMgr.Instance.goldenCardNumber;
        let targetProgress = parseInt(ClientConfig.globalConfig.CardCash.Value);
        this.labelProgress.string = `${currentProgress}/${targetProgress}`;
        this.progress.fillRange = currentProgress / targetProgress;

        if (addNum > 0) {
            this.scheduleOnce(() => {
                let startNode = this.node.getChildByName("startNode");
                let targetNode = this.node.getChildByName("targetNode");
                let worldStartPos = startNode.convertToWorldSpaceAR(cc.v2(0, 0));
                let worldTargetPos = targetNode.convertToWorldSpaceAR(cc.v2(0, 0));
                EffectManager.instance.playAddProgressEffect(CollectEffectType.CashOut, worldStartPos, worldTargetPos, addNum, () => {
                    startNode.active = false;
                    targetNode.active = false;
                });
            }, 0.1);
        }
    }

    onBtnClick() {
        Log.Debug("IconPig onBtnClick");
        UIManager.Instance.open(PrefabDefine.PopCashOut);
    }
}
