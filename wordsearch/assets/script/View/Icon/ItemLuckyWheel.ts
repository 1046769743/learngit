// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import DlgBtn from "../../Common/DlgBtn";
import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { UIManager } from "../../FrameWork/UIManager";
import LuckWheelMgr from "../../Module/LuckWheel/LuckWheelMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export default class IconLuckyWheel extends cc.Component {

    @property(cc.Sprite)
    progress: cc.Sprite = null;

    @property(DlgBtn)
    btn: DlgBtn = null;

    @property(cc.Label)
    labelProgress: cc.Label = null;

    start() {
        this.btn.addClickCallback(this.onBtnClick, this);

        this.updateProgress();
        EventCenter.on(EventName.UpdateLuckWheelProgress, this.updateProgress, this);
    }

    updateProgress() {
        let currentProgress = LuckWheelMgr.Instance.getCurrentFinishWordCount();
        let targetProgress = LuckWheelMgr.Instance.getTargetCount();
        this.labelProgress.string = `${currentProgress}/${targetProgress}`;
        this.progress.fillRange = currentProgress / targetProgress;
    }

    private onBtnClick() {
        UIManager.Instance.open(PrefabDefine.PopLuckWheel);
    }
}
