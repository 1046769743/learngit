// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { TaskConfig } from "../../Data/ClientConfig";
import Language from "../../Module/Language/Language";
import TaskMgr from "../../Module/TaskModule/TaskMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemTask extends cc.Component {
    @property(cc.Node)
    nodeFinishBg: cc.Node = null;

    @property(cc.Node)
    nodeUnfinishBg: cc.Node = null;

    @property(cc.Node)
    nodeComplete: cc.Node = null;

    @property(cc.Label)
    labelComplete: cc.Label = null;

    @property(cc.Label)
    labelDes: cc.Label = null;

    @property(cc.Label)
    labelProgress: cc.Label = null;

    @property(cc.ProgressBar)
    sprProgress: cc.ProgressBar = null;

    updateUI(config: TaskConfig) {
        let desId = config.TaskLanguageID;

        let des = Language.instance.getDes(desId);
        this.labelDes.string = des;

        let progress = TaskMgr.Instance.getCurrentTaskFinishCount(config.ID);
        this.labelProgress.string = progress + "/" + config.TaskGoal;

        this.sprProgress.progress = progress / config.TaskGoal;

        // 是否完成
        if (progress >= config.TaskGoal) {
            this.nodeFinishBg.active = true;
            this.nodeUnfinishBg.active = false;
            this.nodeComplete.active = true;
            this.labelComplete.string = Language.instance.getDes("8");
        } else {
            this.nodeFinishBg.active = false;
            this.nodeUnfinishBg.active = true;
            this.nodeComplete.active = false;
        }
    }
}
