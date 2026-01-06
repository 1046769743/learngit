// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { UIManager } from "../../FrameWork/UIManager";
import AdMgr, { ModuleType } from "../../Module/AdModel/AdMgr";
import { ReceiveEventManager } from "../../Platform/Android/ReceiveEventManager";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopAdTest extends cc.Component {

    @property(cc.Label)
    label: cc.Label = null;

    @property(cc.Button)
    buttonSuccess: cc.Button = null;

    @property(cc.Button)
    buttonFail: cc.Button = null;

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {}

    start() {
        this.buttonSuccess.node.on("click", this.onButtonSuccess, this);
        this.buttonFail.node.on("click", this.onButtonFail, this);

        let moduleType = AdMgr.Instance.getCurrentAdModule();
        this.label.string = ModuleType[moduleType] || "None";
    }

    onButtonSuccess() {
        ReceiveEventManager.showVideoCallBack('{"showAdRes":1}');
        UIManager.Instance.close(PrefabDefine.PopAdTest);
    }

    onButtonFail() {
        ReceiveEventManager.showVideoCallBack('{"showAdRes":0}');
        UIManager.Instance.close(PrefabDefine.PopAdTest);
    }

    // update (dt) {}
}
