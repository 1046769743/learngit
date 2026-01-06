// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { GameMgr } from "../../Module/Game/GameMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemSelectShow extends cc.Component {

    @property(cc.Label)
    label: cc.Label = null;

    @property(cc.Node)
    bg: cc.Node = null;

    private currentTween: cc.Tween = null;

    updateShow(cells: cc.Vec2[], color: cc.Color) {
        if (this.currentTween) {
            this.currentTween.stop();
        }
        this.node.active = true;
        this.node.opacity = 255;
        this.node.angle = 0;
        this.node.position = cc.v3(0, 174, 0);
        let grid = GameMgr.Instance.getCurrentWordSearchGameData().grid;
        let text = "";
        for (let cell of cells) {
            text += grid[cell.x][cell.y];
        }
        if (text.length === 0) {
            this.node.active = false;
            return;
        }
        this.label.string = text;
        this.scheduleOnce(() => {
            let width = this.label.node.width + 40;
            width = Math.max(width, 80);
            this.bg.width = width;
        });

        this.bg.color = color;
    }

    showErrorAnimation() {
        this.node.active = true;
        if (this.currentTween) {
            this.currentTween.stop();
        }
        this.currentTween = cc.tween(this.node)
            .parallel(
                cc.tween(this.node).sequence(
                    cc.tween(this.node).to(0.07, { angle: 10 }),
                    cc.tween(this.node).to(0.07, { angle: 0.0 }),
                    cc.tween(this.node).to(0.07, { angle: -10 }),
                    cc.tween(this.node).to(0.07, { angle: 0.0 }),
                    cc.tween(this.node).to(0.07, { angle: 10 }),
                    cc.tween(this.node).to(0.07, { angle: 0.0 })
                ),
                cc.tween(this.node).to(0.45, { opacity: 0.0 })
            )
            .call(() => {
                this.node.active = false;
                this.currentTween = null;
            })
            .start();
    }

    // 已完成的动画
    showFoundedAnimation() {
        this.node.active = true;
        if (this.currentTween) {
            this.currentTween.stop();
        }
        // 左右位移
        this.currentTween = cc.tween(this.node)
            .to(0.07, { x: this.node.x + 10 })
            .to(0.07, { x: this.node.x - 10 })
            .to(0.07, { x: this.node.x + 10 })
            .to(0.07, { x: this.node.x - 10 })
            .to(0.07, { x: this.node.x + 10 })
            .to(0.07, { x: this.node.x - 10 })
            .to(0.07, { x: this.node.x + 10 })
            .call(() => {
                this.node.active = false;
                this.currentTween = null;
            })
            .start();
    }

    hide() {
        this.node.active = false;
    }

    onDestroy() {
        if (this.currentTween) {
            this.currentTween.stop();
        }
    }
}
