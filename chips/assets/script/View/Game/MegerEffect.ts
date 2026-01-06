import { Chip } from '../../Module/Game/Chip';
import { ObjectPoolManager } from '../../Common/ObjectPoolManager';
const { ccclass, property } = cc._decorator;

@ccclass
export default class MegerEffect extends cc.Component {
    @property(sp.Skeleton)
    public spine: sp.Skeleton = null;

    public Play() {
        this.spine.setAnimation(0, "animation", false);
        // 1秒后回收
        this.scheduleOnce(this.Recycle, 1);
    }

    // 回收
    public Recycle() {

        ObjectPoolManager.instance.putNode(this.node);
    }
}

