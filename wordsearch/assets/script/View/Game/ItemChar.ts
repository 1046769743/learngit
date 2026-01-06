// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { Log } from "../../FrameWork/Log";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemChar extends cc.Component {

    @property(cc.Label)
    label: cc.Label = null;

    @property(cc.Node)
    background: cc.Node = null; // 背景节点

    private _isSelected: boolean = false;
    private _isFound: boolean = false;

    public updateChar(text: string, cellSize: number) {
        this.label.string = text;
        let fontSize = Math.max(cellSize / 2, 40);
        this.label.fontSize = fontSize;
    }

    public setSelected(selected: boolean) {
        this._isSelected = selected;
        if (selected) {
            this.label.node.color = cc.Color.WHITE;
            this.playSelectAnimation();
        } else {
            this.label.node.color = cc.Color.BLACK;
        }
    }

    public setFound(found: boolean) {
        this._isFound = found;
        this.label.node.color = cc.Color.BLACK;

        if (found) {
            this.playFoundAnimation();
        }
    }

    public setError() {
        this.node.color = cc.Color.BLACK;
        this.playErrorAnimation();
    }

    public isSelected(): boolean {
        return this._isSelected;
    }

    public isFound(): boolean {
        return this._isFound;
    }

    private playSelectAnimation() {
        // 选中时的动画效果
        // cc.tween(this.node)
        //     .to(0.1, { scale: 1.1 })
        //     .to(0.1, { scale: 1.0 })
        //     .start();
    }

    private playFoundAnimation() {
        // 找到时的动画效果
        // cc.tween(this.node)
        //     .to(0.1, { scale: 1.2 })
        //     .to(0.1, { scale: 1.0 })
        //     .start();
    }

    private playErrorAnimation() {
        // 错误时的动画效果
        // cc.tween(this.node)
        //     .to(0.1, { scale: 0.9 })
        //     .to(0.1, { scale: 1.0 })
        //     .start();
    }

    public reset() {
        this._isSelected = false;
        this._isFound = false;
        this.label.node.color = cc.Color.BLACK;
        this.node.color = cc.Color.WHITE;  // 节点颜色设为白色，避免影响子节点
        this.node.scale = 1.0;
    }
}
