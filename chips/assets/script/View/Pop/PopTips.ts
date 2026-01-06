// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { UIManager } from "../../FrameWork/UIManager";
import BasePop from "./BasePop";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopTips extends BasePop {

    @property(cc.Label)
    laTitle: cc.Label = null;

    @property(cc.Label)
    laContent: cc.Label = null;

    @property(cc.Button)
    btnClose: cc.Button = null;

    @property(cc.Button)
    btnSure: cc.Button = null;

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {}

    start() {
        this.btnClose.node.on('click', this.onClose, this);
        this.btnSure.node.on('click', this.onClose, this);
    }

    onClose() {
        UIManager.Instance.close(PrefabDefine.PopTips);
    }

    public initContent(content: string) {
        this.laContent.string = content;
    }

    public initTitle(title: string) {
        this.laTitle.string = title;
    }
}
