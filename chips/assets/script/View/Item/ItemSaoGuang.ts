// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemSaoGuang extends cc.Component {

    @property(cc.Node)
    nodeSaoGuang: cc.Node = null;

    start() {
        let width = this.nodeSaoGuang.width;
        let startX = -width / 2 - 50;
        this.nodeSaoGuang.setPosition(startX, 0);
        cc.tween(this.nodeSaoGuang)
            .sequence(
                cc.tween(this.nodeSaoGuang).to(0.5, { position: cc.v3(width / 2 + 50, 0, 0) }),
                cc.tween(this.nodeSaoGuang).to(0.01, { position: cc.v3(-width / 2, -1000, 0) }),
                cc.tween(this.nodeSaoGuang).to(0.01, { position: cc.v3(-width / 2 - 50, 0, 0) })
            )
            .repeatForever()
            .start();
    }
}
