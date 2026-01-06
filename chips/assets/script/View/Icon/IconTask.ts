// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { UIManager } from "../../FrameWork/UIManager";
import Language from "../../Module/Language/Language";
import TaskMgr from "../../Module/TaskModule/TaskMgr";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";

const { ccclass, property } = cc._decorator;

@ccclass
export default class IconTask extends cc.Component {

    @property(cc.Button)
    btn: cc.Button = null;

    @property(cc.RichText)
    richTextDes: cc.RichText = null;

    @property(cc.Label)
    labSpine: cc.Label = null;

    start() {
        EventCenter.on(EventName.WheelFinish, this.onWheelFinish, this);

        let isWhiteBao = UserDataMgr.Instance.isWhiteBao;
        if (isWhiteBao) {
            this.node.active = false;
            return;
        }

        this.btn.node.on("click", this.onBtnClick, this);
        this.richTextDes.string = "<b><outline color=black width=1>" + Language.instance.getDes("53") + "</outline></b>";

        let count = TaskMgr.Instance.getCurrentTaskFinishCount(1);
        this.labSpine.string = Language.instance.getDes("61") + count.toString();

        this.node.active = false;
    }

    private onBtnClick() {
        UIManager.Instance.open(PrefabDefine.PopTask);
        // 打点
        NativeApi.instance.buryPoint("BannerViewButtonClick");
    }

    private onWheelFinish() {
        let count = TaskMgr.Instance.getCurrentTaskFinishCount(1);
        this.labSpine.string = count.toString();
    }
}
