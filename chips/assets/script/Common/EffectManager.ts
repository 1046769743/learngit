import { ObjectPoolManager } from './ObjectPoolManager';
import { Log } from '../FrameWork/Log';
import ItemCollect from '../View/Item/ItemCollect';
import { UIManager } from '../FrameWork/UIManager';
import { TargetNodeKeys } from '../FrameWork/TargetNodeKeys';
import ItemAddChuizi from '../View/Item/ItemAddChuizi';
const { ccclass, property } = cc._decorator;

/** 收集效果类型 */
export enum CollectEffectType {
    Money, // 金钱
    Char, // 字母
    Bulb, // 灯泡
    GoldenCard, // 黄金卡
    Hammer, // 锤子
    LuckyWheel, // 幸运轮盘
}

/** 特效类型 */
export enum EffectType {
    UI,
    Pop,
}

export interface CollectMultipleEffect {
    collectType: CollectEffectType;
    num: number;
    startPos?: cc.Vec2;
    targetPos: cc.Vec2;
    collectCallback: Function;
}

@ccclass
export class EffectManager extends cc.Component {
    @property(cc.Node)
    public uiEffect: cc.Node = null;

    @property(cc.Node)
    public popEffect: cc.Node = null;

    @property({ type: cc.Prefab })
    public Real: cc.Prefab = null;

    @property({ type: cc.Prefab })
    public Fake: cc.Prefab = null;

    @property({ type: cc.Prefab })
    public Bulb: cc.Prefab = null;

    @property({ type: cc.Prefab })
    public GoldenCard: cc.Prefab = null;

    @property({ type: cc.Prefab })
    public AddChuizi: cc.Prefab = null;

    @property({ type: cc.Prefab })
    public AddLuckyWheel: cc.Prefab = null;

    public static instance: EffectManager = null;

    protected onLoad(): void {
        Log.Debug("EffectManager load");
        EffectManager.instance = this;
    }
    // 播放收集动画，传入初始坐标，目标坐标，回调函数
    public playCollectEffect(collectType: CollectEffectType, num: number, startPos: cc.Vec2, targetPos: cc.Vec2, callback: Function) {
        let localStartPos = this.node.convertToNodeSpaceAR(startPos);
        let localTargetPos = this.node.convertToNodeSpaceAR(targetPos);
        //创建10个real,使用Tween 控制 每个real 从startpos 运动到 targetpos，运动时间0.5秒，每一个的间隔时间0.05秒
        var effectPrefab = null;
        if (collectType == CollectEffectType.Bulb) {
            effectPrefab = this.Bulb;
        } else if (collectType == CollectEffectType.GoldenCard) {
            effectPrefab = this.GoldenCard;
        } else {
            effectPrefab = this.Real;
        }

        if (effectPrefab == null) {
            if (callback) {
                callback();
            }
            return;
        }

        if (num <= 0) {
            if (callback) {
                callback();
            }
            return;
        }

        if (num == 1) {
            let item = ObjectPoolManager.instance.getNode(effectPrefab)
            item.parent = this.node;
            item.position = localStartPos;

            // step1: 创建一个针对目标的Tween对象
            let tw = new cc.Tween(item);
            tw.to(0.5, { position: localTargetPos }, { easing: 'sineInOut' });
            // step4: 动画播放完成，回收item
            tw.call(() => {
                // ObjectPoolManager.instance.putNode(item);
                item.destroy();
                callback();
            });
            // step4: 开始执行tween对象
            tw.start();

            return;
        }

        if (num > 30) {
            num = 30;
        }

        for (let i = 0; i < num; i++) {
            let item = ObjectPoolManager.instance.getNode(effectPrefab, effectPrefab.name);
            let itemCollect = item.getComponent(ItemCollect) as ItemCollect;
            if (itemCollect) {
                itemCollect.updateIcon(collectType);
            }
            item.active = true;
            item.parent = this.node;
            item.position = localStartPos;

            // 随机散开的位置
            const randomX = Math.random() * 200 - 100; // -100 到 100
            const randomY = Math.random() * 200 - 100; // -100 到 100
            let randomPos = cc.v2(localStartPos.x + randomX, localStartPos.y + randomY);
            // step1: 创建一个针对目标的Tween对象
            let tw = new cc.Tween(item);
            tw.to(0.2, { position: randomPos }, { easing: 'sineInOut' });
            // step2: 延时0.05s
            tw.delay(0.05 * i + 0.2);
            // step3: 添加执行过程
            tw.to(1, { position: localTargetPos }, { easing: 'sineInOut' });
            // step4: 动画播放完成，回收item
            tw.call(() => {
                item.active = false;
                ObjectPoolManager.instance.putNode(item);
                if (i == num - 1) {
                    callback();
                }
            });
            // step4: 开始执行tween对象
            tw.start();
        }
    }

    // 支持收集多种物品
    public playCollectMultipleEffect(collectMultipleEffects: CollectMultipleEffect[]) {
        let basePos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.CENTER_POINT) || cc.v2(0, 0);
        // 将basePos转换为节点本地坐标，用于计算相对位置
        let localBasePos = this.node.convertToNodeSpaceAR(basePos);
        let len = collectMultipleEffects.length;
        // 根据屏幕宽度和len 计算初始x 和 间隔（使用本地坐标）
        let screenWidth = cc.winSize.width;
        let interval = screenWidth / len;
        let startX = -screenWidth / 2 + interval / 2;

        for (let i = 0; i < collectMultipleEffects.length; i++) {
            let collectMultipleEffect = collectMultipleEffects[i];
            // 计算本地坐标位置
            let localStartPos = cc.v2(startX + i * interval, localBasePos.y);
            Log.Debug("zq playCollectMultipleEffect ----------------------- localStartPos = " + localStartPos);
            // 将本地坐标转换为世界坐标，传给playCollectEffect
            let startPos = collectMultipleEffect.startPos;
            if (collectMultipleEffect.startPos == null || collectMultipleEffect.startPos == undefined) {
                startPos = this.node.convertToWorldSpaceAR(localStartPos);
            }

            this.playCollectEffect(collectMultipleEffect.collectType, collectMultipleEffect.num, startPos, collectMultipleEffect.targetPos, collectMultipleEffect.collectCallback || null);
        }
    }

    // 播放增加锤子动画
    public playAddProgressEffect(collectType: CollectEffectType, startPos: cc.Vec2, targetPos: cc.Vec2, num: number, callback: Function) {
        let localStartPos = this.node.convertToNodeSpaceAR(startPos);
        let localTargetPos = this.node.convertToNodeSpaceAR(targetPos);
        let effectPrefab = null;
        if (collectType == CollectEffectType.Hammer) {
            effectPrefab = this.AddChuizi;
        } else if (collectType == CollectEffectType.LuckyWheel) {
            effectPrefab = this.AddLuckyWheel;
        } else {
            effectPrefab = this.AddChuizi;
        }
        let item = ObjectPoolManager.instance.getNode(effectPrefab);
        let rootNode = this.uiEffect;
        item.parent = rootNode;
        item.position = localStartPos;
        item.opacity = 255;
        item.active = true;
        let itemAddChuizi = item.getComponent(ItemAddChuizi) as ItemAddChuizi;
        itemAddChuizi.updateUI(num);

        let tw = new cc.Tween(item);
        tw.to(1.5, { position: localTargetPos, opacity: 100 }, { easing: 'sineInOut' });
        tw.call(() => {
            item.active = false;
            ObjectPoolManager.instance.putNode(item);
            if (callback) {
                callback();
            }
        });
        tw.start();
    }
}

