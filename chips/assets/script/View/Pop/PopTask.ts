// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { EventName } from "../../Common/EventName";
import ClientConfig, { ConfigKey } from "../../Data/ClientConfig";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import { SOUND_NAME, SoundManager } from "../../Module/Audio/SoundManager";
import CurrencyManager from "../../Module/Currency/CurrencyManager";
import Language from "../../Module/Language/Language";
import TaskMgr from "../../Module/TaskModule/TaskMgr";
import ItemTask from "../Item/ItemTask";
import BasePop from "./BasePop";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopTask extends BasePop {

    @property(cc.Button)
    btnClose: cc.Button = null;

    @property(cc.Button)
    btnCashOut: cc.Button = null;

    @property(cc.Label)
    labelTitle: cc.Label = null;

    @property(cc.Label)
    labelDes: cc.Label = null;

    @property(cc.Node)
    content: cc.Node = null;

    @property(ItemTask)
    itemTask: ItemTask = null;

    @property(cc.Label)
    labelButton: cc.Label = null;

    @property(cc.Node)
    nodeTips: cc.Node = null;

    private readonly KEY_IS_FIRST_OPEN_TASK_POP = "is_first_open_task_pop";

    private isShowAniFinished: boolean = false;

    start() {
        this.updateUI();
        this.btnClose.node.on('click', this.onClose, this);
        this.btnCashOut.node.on('click', this.onCashOutClick, this);

        this.isShowAniFinished = StorageManager.Instance.getBoolean(this.KEY_IS_FIRST_OPEN_TASK_POP, false);
    }

    private updateUI() {
        this.nodeTips.active = false;

        let allCfg = TaskMgr.Instance.getAllTaskCfg();
        let list = [];
        allCfg.forEach((value, key) => {
            list.push(key);
        });

        list.sort();

        this.itemTask.updateUI(allCfg.get(list[0]));

        // 标题
        let title = Language.instance.getDes("55");
        if (title) {
            this.labelTitle.string = title;
        }

        // 描述
        let des = Language.instance.getDes("53");
        if (des) {
            this.labelDes.string = des;
        }

        // 按钮
        let cashOut = Language.instance.getDes("19");
        if (cashOut) {
            this.labelButton.string = cashOut;
        }
    }

    private onClose() {
        SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        UIManager.Instance.close(PrefabDefine.PopTask);
    }

    private onCashOutClick() {
        SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        if (this.nodeTips.active) {
            return;
        }
        this.nodeTips.active = true;
        this.nodeTips.scaleY = 0;
        this.nodeTips.opacity = 255;
        cc.tween(this.nodeTips)
            .to(0.2, { scaleY: 1 })
            .delay(0.5)
            .to(0.4, { opacity: 0 })
            .call(() => {
                this.nodeTips.active = false;
            })
            .start();
    }
}
